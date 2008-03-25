-- Used to hold tables that aren't currently being used.
local free_tables = {}
local used, free = 0, 0

-- Creates a new table, optionally assigning a metatable to it.
-- If the metatable contains the key 'onCreate', that function is invoked on the new table, along with any
-- additional arguments passed to create.
local function create(metatable, ...)
  -- Can't allow metatable to have __metatable set, otherwise we won't be able to remove it later when release is called.
  assert(not metatable or not metatable.__metatable)
  
  local tbl = next(free_tables)
  
  if tbl then
    free = free - 1
    free_tables[tbl] = nil
  else
    tbl = {}
  end
  
  setmetatable(tbl, metatable)
  
  local onCreate = metatable and metatable.onCreate
  if onCreate then onCreate(tbl, ...) end
  
  used = used + 1
  return tbl
end

-- Creates a reference to a table.
-- Adds a 'ref_count' key to the table, or increases it if it already exists.
local function reference(tbl)
  rawset(tbl, "ref_count", (rawget(tbl, "ref_count") or 1)+1)
  return tbl
end

-- Removes a reference to a table, and then returns that table.
-- This is similar to release, except the table isn't released if the reference count reaches 0.
-- 
-- Assuming the a called function invokes reference on the table, this would make
--   func(unreference(table))
-- the same as
--   func(table) release(table)
-- 
-- This function is just a convenience, and the second form is safer in case for
-- some reason func doesn't actually create their own reference.
local function unreference(tbl)
  local ref_count = (rawget(tbl, "ref_count") or 1)
  assert(ref_count > 0, "Attempt to unreference a table with no references.")
  rawset(tbl, "ref_count", ref_count-1)
  return tbl
end

-- Releases a table.
-- If the table has a 'ref_count' key, it is decreased, and the table is not released unless this value reached 0.
-- If the table's metatable has an "onRelease" key, it is invoked before the metatable is removed from the table.
local function release(tbl)
  assert(type(tbl) == "table", "Argument must be a table.")
  assert(free_tables[tbl] == nil, "Already released.")
  
  -- Decrease the tables ref_count if it has one.
  local ref_count = rawget(tbl, "ref_count")
  if ref_count and ref_count > 1 then
    rawset(tbl, "ref_count", ref_count - 1)
    return
  end
  
  -- If table has an onRelease function, we'll invoke it.
  local metatable = getmetatable(tbl)
  local onRelease = metatable and metatable.onRelease
  if onRelease then onRelease(tbl) end
  
  -- Remove the table's metatable, and store it in free_tables.
  free_tables[setmetatable(tbl, nil)] = true
  free = free + 1
  used = used - 1
  
  -- Remove any keys left by the table.
  for key in pairs(tbl) do tbl[key] = nil end
end

-- Returns how many tables have been created but not yet released,
-- and the number of released tables that are available to be
-- recycled in future table creations.
local function pool()
  return used, free
end

-- Gets a value from nested tables.
-- get(x, a, b, c) is the same as x[a][b][c], except that if any of the nested tables don't exist,
-- nil is returned instead of raising an error.
local function get(tbl, ...)
  assert(type(tbl) == "table", "Expected table argument.")
  
  for i = 1,select("#", ...) do
    tbl = rawget(tbl, select(i, ...))
    if not tbl then return end
  end
  
  return tbl
end

-- Sets a value in a nested table, creating any missing tables if they don't exist.
-- get(x, y, a, b, c) is the same as x[a][b][c] = y, except that if any of the nested tables don't exist,
-- they're created.
-- Returns the previous value it replaces.
local function set(tbl, value, ...)
  local c = select("#", ...)
  
  for i = 1,c-1 do
    local k = select(i, ...)
    local tbl2 = rawget(tbl, k)
    if tbl2 then
      tbl = tbl2
    else
      tbl2 = create()
      rawset(tbl, k, tbl2)
      tbl = tbl2
    end
  end
  
  local k = select(c, ...)
  local oldvalue = rawget(tbl, k)
  rawset(tbl, k, value)
  
  return oldvalue
end

-- Helper for the array(...) function, populates the table.
local function append(tbl, ...)
  local base = #tbl
  for i = 1,select("#", ...) do
    rawset(tbl, base+i, select(i, ...))
  end
end

-- Creates an array from its arguments.
-- Unlike {...}, will recycle an unused table if one exists, rather than creating
-- a new table each call.
local function array(...)
  local tbl = create()
  append(tbl, ...)
  return tbl
end

QuestHelper.create = create
QuestHelper.reference = reference
QuestHelper.unreference = unreference
QuestHelper.release = release
QuestHelper.pool = pool
QuestHelper.get = get
QuestHelper.set = set
QuestHelper.append = append
QuestHelper.array = array
