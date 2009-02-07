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
  
  QuestHelper:TextOut(string.format("%s %d", group, id))
  
  if group == "quest_metaobjective" then
    local q = DB_GetItem("quest", id)
    if not q then return end
    
    ite = {} -- we don't want to mutate the existing quest data
    ite.desc = string.format("Quest %s", q.name.enUS or "(unknown)")  -- this gets changed later
    ite.based_on = q -- We're storing this for kind of complicated reasons. We're going to be linking directly to the original quest loc tables. If we didn't store this, it could theoretically be garbage-collected. Then, later, if someone tried accessing the quest directly, they'd end up with the quest . . . and a new set of loc tables. Storing this is solely to prevent the garbage collector from collecting it until the quest_metaobjective is gone.
    
    if q.criteria then for k, c in ipairs(q.criteria) do
      local ttx = {}
      --QuestHelper:TextOut(string.format("critty %d %d", k, c.loc and #c.loc or -1))
      if c.loc then for m, v in ipairs(c.loc) do
        table.insert(ttx, {desc = string.format("Criteria %d", k), clusterpart = m, why = ite, loc = v})
      end end
      table.insert(ite, ttx)
    end end
    if q.finish then
      local ttx = {}
      --QuestHelper:TextOut(string.format("finny %d", q.finish.loc and #q.finish.loc or -1))
      for m, v in ipairs(q.finish.loc) do
        table.insert(ttx, {desc = "Turn in quest", clusterpart = m, why = ite, loc = v, tracker_hidden = true})
      end
      table.insert(ite, ttx)
    end
  else
    ite = QuestHelper_Static[group][id]
  end
  DBC_Put(group, id, ite)
  return ite
end
