QuestHelper_File["director_quest.lua"] = "Development Version"
QuestHelper_Loadtime["director_quest.lua"] = GetTime()

--[[

Little bit of explanation here.

The db layer dumps things out in DB format. This isn't immediately usable for our routing engine. We convert this to an intermediate "metaobjective" format that the routing engine can use, as well as copying anything that needs to be copied. This also allows us to modify our metaobjective tables as we see fit, rather than doing nasty stuff to keep the original objectives intact.

]]

local function copy(tab)
  local tt = {}
  for _, v in ipairs(tab) do
    table.insert(tt, v)
  end
  return tt
end

local function copy_without_last(tab)
  local tt = {}
  for _, v in ipairs(tab) do
    table.insert(tt, v)
  end
  --table.remove(tt)
  return tt
end

local function AppendObjlinks(target, source, lines, seen)
  if not seen then seen = {} end
  
  QuestHelper: Assert(not seen[source])
  
  if seen[source] then return end
  
  seen[source] = true
  if source.loc then
    for m, v in ipairs(source.loc) do
      QuestHelper: Assert(#source == 0)
      table.insert(target, {loc = v, path_desc = copy_without_last(lines)})
    end
  else
    QuestHelper:TextOut(QuestHelper:StringizeRecursive(source, 2))
    for _, v in ipairs(source) do
      local dbgi = DB_GetItem(v.sourcetype, v.sourceid)
      if v.sourcetype == "monster" then
        table.insert(lines, QHFormat("OBJECTIVE_SLAY", dbgi.name or QHText("OBJECTIVE_UNKNOWN_MONSTER")))
      elseif v.sourcetype == "item" then
        table.insert(lines, QHFormat("OBJECTIVE_ACQUIRE", dbgi.name or QHText("OBJECTIVE_ITEM_UNKNOWN")))
      else
        table.insert(lines, string.format("unknown %s (%s/%s)", tostring(dbgi.name), tostring(v.sourcetype), tostring(v.sourceid)))
      end
      AppendObjlinks(target, dbgi, lines, seen)
      table.remove(lines)
    end
  end
  seen[source] = false
end


local quest_list = {}
local quest_list_used = {}

local function GetQuestMetaobjective(questid)
  if not quest_list[questid] then
    local q = DB_GetItem("quest", questid)
    
    if not q then return end
    
    ite = {} -- we don't want to mutate the existing quest data
    ite.desc = string.format("Quest %s", q.name or "(unknown)")  -- this gets changed later anyway
    
    if q.criteria then for k, c in ipairs(q.criteria) do
      local ttx = {}
      --QuestHelper:TextOut(string.format("critty %d %d", k, c.loc and #c.loc or -1))
      
      AppendObjlinks(ttx, c, {})
      for idx, v in pairs(ttx) do
        v.desc = string.format("Criteria %d", k)
        v.why = ite
        v.cluster = ttx
      end
      
      table.insert(ite, ttx)
    end end
    if q.finish then
      local ttx = {}
      --QuestHelper:TextOut(string.format("finny %d", q.finish.loc and #q.finish.loc or -1))
      for m, v in ipairs(q.finish.loc) do
        table.insert(ttx, {desc = "Turn in quest", why = ite, loc = v, tracker_hidden = true, cluster = ttx})
      end
      table.insert(ite, ttx)
    end
    
    quest_list[questid] = ite
  end
  
  quest_list_used[questid] = quest_list[questid]
  return quest_list[questid]
end


local function GetQuestType(link)
  return tonumber(string.match(link,
    "^|cff%x%x%x%x%x%x|Hquest:(%d+):[%d-]+|h%[[^%]]*%]|h|r$"
  )), tonumber(string.match(link,
    "^|cff%x%x%x%x%x%x|Hquest:%d+:([%d-]+)|h%[[^%]]*%]|h|r$"
  ))
end

local update = true
local function UpdateTrigger()
  update = true
end

local active = {}

-- It's possible that things end up garbage-collected and we end up with different tables than we expect. This is something that the entire system is kind of prone to. The solution's pretty easy - we just have to store them ourselves while we're using them.
local active_db = {}

local objective_parse_table = {
  item = function (txt) return QuestHelper:convertPattern(QUEST_OBJECTS_FOUND)(txt) end,
  object = function (txt) return QuestHelper:convertPattern(QUEST_OBJECTS_FOUND)(txt) end,  -- why does this even exist
  monster = function (txt) return QuestHelper:convertPattern(QUEST_MONSTERS_KILLED)(txt) end,
  event = function (txt, done) return txt, (done and 1 or 0), 1 end, -- It appears that events are only used for things which can only happen once.
  reputation = function (txt) return QuestHelper:convertPattern(QUEST_FACTION_NEEDED)(txt) end, -- :ughh:
  player = function (txt) return QuestHelper:convertPattern(QUEST_MONSTERS_KILLED)(txt) end, -- We're using monsters here in the hopes that it follows the same pattern. I'd rather not try to find the exact right version of "player" in the locale files, though PLAYER might be it.
}

local function objective_parse(typ, txt, done)
  local pt, target, have, need = typ, objective_parse_table[typ](txt, done)
  
  if not target then
    -- well, that didn't work
    target, have, need = string.match(txt, "^%s*(.-)%s*:%s*(.-)%s*/%s*(.-)%s*$")
    pt = "fallback"
    --QuestHelper:TextOut(string.format("%s rebecomes %s/%s/%s", tostring(title), tostring(target), tostring(have), tostring(need)))
  end
  
  if not target then
    target, have, need = string.match(txt, "^%s*(.-)%s*$"), (done and 1 or 0), 1
    --QuestHelper:TextOut(string.format("%s rerebecomes %s/%s/%s", tostring(title), tostring(target), tostring(have), tostring(need)))
  end
  
  QuestHelper: Assert(target) -- This will fail repeatedly. Come on. We all know it.
  QuestHelper: Assert(have)
  QuestHelper: Assert(need) -- As will these.
  
  return pt, target, have, need
end

local function clamp(v)
  if v < 0 then return 0 elseif v > 255 then return 255 else return v end
end

local function colorlerp(position, r1, g1, b1, r2, g2, b2)
  local antip = 1 - position
  return string.format("|cff%02x%02x%02x", clamp((r1 * antip + r2 * position) * 255), clamp((g1 * antip + g2 * position) * 255), clamp((b1 * antip + b2 * position) * 255))
end

-- We're just gonna do the same thing QH originally did - red->yellow->green.
local function difficulty_color(position)
  if position < 0 then position = 0 end
  if position > 1 then position = 1 end
  return (position < 0.5) and colorlerp(position * 2, 1, 0, 0, 1, 1, 0) or colorlerp(position * 2 - 1, 1, 1, 0, 0, 1, 0)
end

local function MakeQuestTitle(title, level)
  local plevel = UnitLevel("player") -- meh, should probably cache this, buuuuut
  local grayd
  
  if plevel >= 60 then
    grayd = 9
  elseif plevel >= 40 then
    grayd = plevel / 5 + 1
  else
    grayd = plevel / 10 + 5
  end
  
  local isgray = (plevel - floor(grayd) >= level)
  
  return string.format("%s[%d] %s", isgray and "|cffb0b0b0" or difficulty_color(((level - plevel) / grayd + 1) / 2), level, title)
end

local function MakeQuestObjectiveTitle(title, typ, done)
  local _, target, have, need = objective_parse(typ, title, done)
  
  local nhave, nneed = tonumber(have), tonumber(need)
  if nhave and nneed then
    have, need = nhave, nneed
    
    local ccode = difficulty_color(have / need)
    
    if need > 1 then target = string.format("%s: %d/%d", target, have, need) end
    return ccode .. target
  else
    return string.format("|cffff0000%s: %s/%s", target, have, need)
  end
end

local function Clicky(index)
  ShowUIPanel(QuestLogFrame)
  QuestLog_SetSelection(index)
  QuestLog_Update()
end

-- Here's the core update function
function UpdateQuests()
  if update then  -- Sometimes (usually) we don't actually update
  
    local index = 1
    
    local nactive = {}
    quest_list_used = {}
    
    -- This begins the main update loop that loops through all of the quests
    while true do
      local title, level = GetQuestLogTitle(index)
      if not title then break end
      
      local qlink = GetQuestLink(index)
      if qlink then -- If we don't have a quest link, it's not really a quest
        local id = GetQuestType(qlink)
        if id then -- If we don't have a *valid* quest link, give up
          local db = GetQuestMetaobjective(id) -- This generates the above-mentioned metaobjective, including doing the database lookup.
          
          if db then  -- If we didn't get a database lookup, then we don't have a metaobjective either. Urgh. abort abort abort
          
            -- The section in here, in other words, is: we have a metaobjective (which may be a new one, or may not be), and we're trying to attach things to our routing engine. Now is where the real work begins! (six conditionals deep)
            local lindex = index
            db.desc = title
            db.tracker_desc = MakeQuestTitle(title, level)
            db.tracker_clicked = function () Clicky(lindex) end
            
            local lbcount = GetNumQuestLeaderBoards(index)
            
            local turnin
            
            -- This is our "quest turnin" objective, which is currently being handled separately for no particularly good reason.
            if db[lbcount + 1] and #db[lbcount + 1] > 0 then
              turnin = db[lbcount + 1]
              nactive[turnin] = true
              if not active[turnin] then
                for k, v in ipairs(turnin) do
                  v.tracker_clicked = function () Clicky(lindex) end
                  
                  v.map_desc = {QHFormat("OBJECTIVE_REASON_TURNIN", title)}
                end
                QH_Route_ClusterAdd(db[lbcount + 1])
              end
            end
            
            -- These are the individual criteria of the quest. Remember that each criteria can be represented by multiple routing objectives.
            for i = 1, GetNumQuestLeaderBoards(index) do
              local desc, typ, done = GetQuestLogLeaderBoard(i, index)
              if db[i] then
                for k, v in ipairs(db[i]) do
                  v.tracker_desc = MakeQuestObjectiveTitle(desc, typ, done)
                  v.desc = desc
                  v.tracker_clicked = function () Clicky(lindex) end
                  
                  v.map_desc = copy(v.path_desc)
                  
                  local pt, pd = objective_parse(typ, desc, done)
                  
                  if pt == "item" or pt == "object" then
                    v.map_desc[1] = QHFormat("OBJECTIVE_REASON", QHText("ACQUIRE_VERB"), pd, title)
                  elseif pt == "monster" then
                    v.map_desc[1] = QHFormat("OBJECTIVE_REASON", QHText("SLAY_VERB"), pd, title)
                  else
                    v.map_desc[1] = QHFormat("OBJECTIVE_REASON_FALLBACK", pd, title)
                  end
                end
              end
              
              -- This is the snatch of code that actually adds it to routing.
              if not done then if db[i] and #db[i] > 0 then
                nactive[db[i]] = true
                if not active[db[i]] then
                  QH_Route_ClusterAdd(db[i])
                  if turnin then QH_Route_ClusterRequires(turnin, db[i]) end
                end
              end end
            end
          end
        end
      end
      index = index + 1
    end
    
    for k, v in pairs(active) do
      if not nactive[k] then
        QH_Route_ClusterRemove(k)
      end
    end
    
    active = nactive
    
    quest_list = quest_list_used
  end
end

QuestHelper.EventHookRegistrar("UNIT_QUEST_LOG_CHANGED", UpdateTrigger)
QuestHelper.EventHookRegistrar("QUEST_LOG_UPDATE", UpdateQuests)
