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

local function pool()
  return used, free
end

-- Gets a value from nested tables.
-- get(x, a, b, c) is the same as x[a][b][c], except that if any of the nested tables don't exist,
-- nil is returned instead of raising an error.
local function get(tbl, key, ...)
  if tbl and key then
    assert(type(tbl) == "table", "Expected table argument.")
    return get(tbl[key], ...)
  end
  return tbl
end

-- Sets a value in a nested table, creating any missing tables if they don't exist.
-- get(x, y, a, b, c) is the same as x[a][b][c] = y, except that if any of the nested tables don't exist,
-- they're created.
local function set(tbl, value, key, n, ...)
  assert(type(tbl) == "table", "Expected table argument.")
  
  if n then
    local tbl2 = tbl[key]
    if not tbl2 then
      tbl2 = createTable()
      tbl[key] = tbl2
    end
    set(tbl2, value, n, ...)
  end
  
  tbl[key] = value
  return value
end

-- Helper for the array(...) function, populates the table.
local function array_helper(tbl, i, val, ...)
  if val then
    tbl[i] = val
    array_helper(tbl, i+1, ...)
  end
end

-- Creates an array from its arguments.
-- Unlike {...}, will recycle an unused table if one exists, rather than creating
-- a new table each call.
local function array(...)
  local tbl = create()
  array_helper(tbl, 1, ...)
  return tbl
end

QuestHelper.create = create
QuestHelper.reference = reference
QuestHelper.release = release
QuestHelper.pool = pool
QuestHelper.get = get
QuestHelper.set = set
QuestHelper.array = array
