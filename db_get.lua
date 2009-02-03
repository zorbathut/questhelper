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

function DB_GetItem(group, id)
  local ite = DBC_Get(group, id)
  if ite then return ite end
  
  if group == "quest_metaobjective" then
    local q = QuestHelper_Static["quest"][id]
    if not q then return end
    
    ite = {} -- we don't want to mutate the existing quest data
    ite.desc = string.format("Quest %s", q.name or "(unknown)")  -- this gets changed later
    
    if q.criteria then for k, v in ipairs(q.criteria) do
      table.insert(ite, {desc = string.format("Criteria %d", k), why = ite, loc = v.loc})
    end end
    if q.finish then
      table.insert(ite, {desc = "Turn in quest", why = ite, loc = q.finish.loc, tracker_hidden = true})
    end
  else
    ite = QuestHelper_Static[group][id]
  end
  DBC_Put(group, id, ite)
  return ite
end
