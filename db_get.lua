QuestHelper_File["db_get.lua"] = "Development Version"
QuestHelper_Loadtime["db_get.lua"] = GetTime()

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
  local ite = DBC_Get(group, id)
  if ite then return ite end
  
  QuestHelper:TextOut(string.format("%s %d", group, id))
  
  ite = QuestHelper_Static[group][id]
  
  mark(ite, ite)
  
  DBC_Put(group, id, ite)
  return ite
end
