QuestHelper_File["db_get.lua"] = "Development Version"
QuestHelper_Loadtime["db_get.lua"] = GetTime()

-- yoink
--[[
local QHDB_temp = QHDB
QHDB = nil
local QHDB = QHDB_temp]]
QuestHelper: Assert(#QHDB == 4)

local weak_v = { __mode = 'v' }

local cache = {}

local function DBC_Get(group, id)
  if not cache[group] then return end
  return cache[group][id]
end

local function DBC_Put(group, id, item)
  if not cache[group] then cache[group] = setmetatable({}, weak_v) end
  QuestHelper: Assert(not cache[group][id])
  cache[group][id] = item
end

local function mark(tab, tomark)
  for k, v in pairs(tab) do
    if type(v) == "table" then
      mark(v, tomark)
    end
  end
  tab.__owner = tomark
end

function DB_GetItem(group, id)
  QuestHelper: Assert(group, string.format("%s %s", tostring(group), tostring(id)))
  QuestHelper: Assert(id, string.format("%s %s", tostring(group), tostring(id)))
  local ite = DBC_Get(group, id)
  if ite then return ite end
  
  --QuestHelper:TextOut(string.format("%s %d", group, id))
  
  local ite
  --print("dbs")
  for _, db in ipairs(QHDB) do
    --print(db, db[group], db[group] and db[group][id], type(group), type(id))
    if db[group] and db[group][id] then
      if not ite then ite = {} end
      for k, v in pairs(db[group][id]) do
        QuestHelper: Assert(not ite[k])
        ite[k] = v
      end
    end
  end
  --print("dbe", ite)
  
  if ite then
    mark(ite, ite)
    
    DBC_Put(group, id, ite)
  else
    QuestHelper:TextOut(string.format("Tried to get %s/%s, failed", tostring(group), tostring(id)))
  end
  
  return ite
end

function DB_ListItems(group)
  local tab = {}
  for _, db in ipairs(QHDB) do
    if db[group] then for k, _ in pairs(db[group]) do
      tab[k] = true
    end end
  end
  
  local rv = {}
  for k, _ in pairs(tab) do
    table.insert(rv, k)
  end
  
  return rv
end
