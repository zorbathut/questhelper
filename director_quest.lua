QuestHelper_File["director_quest.lua"] = "Development Version"
QuestHelper_Loadtime["director_quest.lua"] = GetTime()

--[[

Little bit of explanation here.

The db layer dumps things out in DB format. This isn't immediately usable for our routing engine. We convert this to an intermediate "metaobjective" format that the routing engine can use, as well as copying anything that needs to be copied. This also allows us to modify our metaobjective tables as we see fit, rather than doing nasty stuff to keep the original objectives intact.

It's worth mentioning that, completely accidentally, everything it requests from the DB is deallocated rapidly - it doesn't keep any references to the original DB objects around. This is unintentional, but kind of neat. It's not worth preserving, but it doesn't really have to be "fixed" either.

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
  table.remove(tt)
  return tt
end

local function AppendObjlinks(target, source, tooltips, icon, last_name, map_lines, tooltip_lines, seen)
  if not seen then seen = {} end
  if not map_lines then map_lines = {} end
  if not tooltip_lines then tooltip_lines = {} end
  
  QuestHelper: Assert(not seen[source])
  
  if seen[source] then return end
  
  seen[source] = true
  if source.loc then
    for m, v in ipairs(source.loc) do
      QuestHelper: Assert(#source == 0)
      
      QuestHelper: Assert(target)
      QuestHelper: Assert(QuestHelper_IndexLookup)
      QuestHelper: Assert(QuestHelper_IndexLookup[v.rc], v.rc)
      table.insert(target, {loc = {x = v.x, y = v.y, c = v.c, p = QuestHelper_IndexLookup[v.rc][v.rz]}, path_desc = copy(map_lines), icon_id = icon or 6})
    end
  else
    for _, v in ipairs(source) do
      local dbgi = DB_GetItem(v.sourcetype, v.sourceid)
      local licon
      
      if v.sourcetype == "monster" then
        table.insert(map_lines, QHFormat("OBJECTIVE_SLAY", dbgi.name or QHText("OBJECTIVE_UNKNOWN_MONSTER")))
        table.insert(tooltip_lines, 1, QHFormat("TOOLTIP_SLAY", source.name or "nothing"))
        licon = 1
      elseif v.sourcetype == "item" then
        table.insert(map_lines, QHFormat("OBJECTIVE_ACQUIRE", dbgi.name or QHText("OBJECTIVE_ITEM_UNKNOWN")))
        table.insert(tooltip_lines, 1, QHFormat("TOOLTIP_LOOT", source.name or "nothing"))
        licon = 2
      else
        table.insert(map_lines, string.format("unknown %s (%s/%s)", tostring(dbgi.name), tostring(v.sourcetype), tostring(v.sourceid)))
        table.insert(tooltip_lines, 1, string.format("unknown %s (%s/%s)", tostring(last_name), tostring(v.sourcetype), tostring(v.sourceid)))
        licon = 3
      end
      
      tooltips[string.format("%s@@%s", v.sourcetype, v.sourceid)] = copy_without_last(tooltip_lines)
      
      AppendObjlinks(target, dbgi, tooltips, icon or licon, source.name, map_lines, tooltip_lines, seen)
      table.remove(tooltip_lines, 1)
      table.remove(map_lines)
    end
  end
  seen[source] = false
end


local quest_list = {}
local quest_list_used = {}

local function GetQuestMetaobjective(questid, lbcount)
  if not quest_list[questid] then
    local q = DB_GetItem("quest", questid, true)
    
    if not q then return end
    
    if not lbcount then
      QuestHelper: TextOut("Missing lbcount, guessing wildly")
      if q and q.criteria then
        lbcount = 0
        for k, v in ipairs(q.criteria) do
          lbcount = math.max(lbcount, k)
        end
      else
        lbcount = 0 -- heh
      end
    end
    
    -- just doublechecking here
    if q and q.criteria then for k, v in pairs(q.criteria) do
      QuestHelper: Assert(type(k) ~= "number" or k <= lbcount, string.format("%s %s", lbcount, k))
    end end
    
    ite = {type_quest = {}} -- we don't want to mutate the existing quest data
    ite.desc = string.format("Quest %s", q.name or "(unknown)")  -- this gets changed later anyway
    
    for i = 1, lbcount do
      local ttx = {}
      --QuestHelper:TextOut(string.format("critty %d %d", k, c.loc and #c.loc or -1))
      
      ttx.tooltip = {}
      
      if q and q.criteria and q.criteria[i] then AppendObjlinks(ttx, q.criteria[i], ttx.tooltip) end
      
      if #ttx == 0 then
        table.insert(ttx, {loc = {x = 5000, y = 5000, c = 0, p = 2}, icon_id = 7, type_quest_unknown = true, map_desc = {"Unknown"}})  -- this is Ashenvale, for no particularly good reason
      end
      
      for idx, v in ipairs(ttx) do
        v.desc = string.format("Criteria %d", i)
        v.why = ite
        v.cluster = ttx
        v.type_quest = ite.type_quest
      end
      
      for k, v in pairs(ttx.tooltip) do
        ttx.tooltip[k] = {ttx.tooltip[k], ttx} -- we're gonna be handing out this table to other modules, so this isn't as dumb as it looks
      end
      
      ite[i] = ttx
    end
    
    do
      local ttx = {}
      --QuestHelper:TextOut(string.format("finny %d", q.finish.loc and #q.finish.loc or -1))
      if q and q.finish and q.finish.loc then for m, v in ipairs(q.finish.loc) do
        --print(v.rc, v.rz)
        --print(QuestHelper_IndexLookup[v.rc])
        --print(QuestHelper_IndexLookup[v.rc][v.rz])
        table.insert(ttx, {desc = "Turn in quest", why = ite, loc = {x = v.x, y = v.y, c = v.c, p = QuestHelper_IndexLookup[v.rc][v.rz]}, tracker_hidden = true, cluster = ttx, icon_id = 7, type_quest = ite.type_quest})
      end end
      
      if #ttx == 0 then
        table.insert(ttx, {desc = "Turn in quest", why = ite, loc = {x = 5000, y = 5000, c = 0, p = 2}, tracker_hidden = true, cluster = ttx, icon_id = 7, type_quest = ite.type_quest, type_quest_unknown = true})  -- this is Ashenvale, for no particularly good reason
      end
      
      ite.finish = ttx
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
  
  if tonumber(have) then have = tonumber(have) end
  if tonumber(need) then need = tonumber(need) end

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
  
  return string.format("%s[%d] %s", isgray and "|cffb0b0b0" or difficulty_color(1 - ((level - plevel) / grayd + 1) / 2), level, title)
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

local dontknow  = {
  name = "director_quest_unknown_objective",
  no_exception = true,
  no_disable = true,
  friendly_reason = QHText("UNKNOWN_OBJ"),
}

-- Here's the core update function
function QH_UpdateQuests(force)
  if not DB_Ready() then return end

  if update or force then  -- Sometimes (usually) we don't actually update
    local index = 1
    
    local nactive = {}
    quest_list_used = {}
    
    local unknown = {}
    
    -- This begins the main update loop that loops through all of the quests
    while true do
      local title, level, variety, groupsize, _, _, complete = GetQuestLogTitle(index)
      if not title then break end
      
      local qlink = GetQuestLink(index)
      if qlink then -- If we don't have a quest link, it's not really a quest
        local id = GetQuestType(qlink)
        if id then -- If we don't have a *valid* quest link, give up
          local lbcount = GetNumQuestLeaderBoards(index)
          local db = GetQuestMetaobjective(id, lbcount) -- This generates the above-mentioned metaobjective, including doing the database lookup.
          
          if db then  -- If we didn't get a database lookup, then we don't have a metaobjective either. Urgh. abort abort abort
          
            -- The section in here, in other words, is: we have a metaobjective (which may be a new one, or may not be), and we're trying to attach things to our routing engine. Now is where the real work begins! (six conditionals deep)
            local lindex = index
            db.desc = title
            db.tracker_desc = MakeQuestTitle(title, level)
            db.tracker_clicked = function () Clicky(lindex) end
            
            local watched = IsQuestWatched(index)
            
            db.type_quest.level = level
            db.type_quest.done = (complete == 1)
            db.type_quest.index = index
            db.type_quest.variety = variety
            db.type_quest.groupsize = groupsize
            db.type_quest.title = title
            db.type_quest.objectives = lbcount
            QuestHelper: Assert(db.type_quest.index) -- why is this failing?
            
            local turnin
            local turnin_new
            
            -- This is our "quest turnin" objective, which is currently being handled separately for no particularly good reason.
            if db.finish and #db.finish > 0 then
              turnin = db.finish
              nactive[turnin] = true
              if not active[turnin] then
                turnin_new = true
                for k, v in ipairs(turnin) do
                  v.tracker_clicked = function () Clicky(lindex) end
                  
                  v.map_desc = {QHFormat("OBJECTIVE_REASON_TURNIN", title)}
                end
                QH_Route_ClusterAdd(db.finish)
              end
              QH_Tracker_SetPin(db.finish[1], watched)
              if db.finish[1].type_quest_unknown then table.insert(unknown, db.finish) end
            end
            
            -- These are the individual criteria of the quest. Remember that each criteria can be represented by multiple routing objectives.
            for i = 1, lbcount do
              if db[i] then
                local desc, typ, done = GetQuestLogLeaderBoard(i, index)
                local pt, pd, have, need = objective_parse(typ, desc, done)
                local dline
                if pt == "item" or pt == "object" then
                  dline = QHFormat("OBJECTIVE_REASON", QHText("ACQUIRE_VERB"), pd, title)
                elseif pt == "monster" then
                  dline = QHFormat("OBJECTIVE_REASON", QHText("SLAY_VERB"), pd, title)
                else
                  dline = QHFormat("OBJECTIVE_REASON_FALLBACK", pd, title)
                end
                
                if not db[i].progress then
                  db[i].progress = {}
                end
                
                if type(have) == "number" and type(need) == "number" then
                  db[i].progress[UnitName("player")] = {have, need, have / need}
                else
                  db[i].progress[UnitName("player")] = {have, need, 0}  -- it's only used for the coloring anyway
                end
                
                db[i].desc = QHFormat("TOOLTIP_QUEST", title)
                
                for k, v in ipairs(db[i]) do
                  v.tracker_desc = MakeQuestObjectiveTitle(desc, typ, done)
                  v.desc = desc
                  v.tracker_clicked = function () Clicky(lindex) end
                  
                  v.progress = db[i].progress
                  
                  if v.path_desc then
                    v.map_desc = copy(v.path_desc)
                    v.map_desc[1] = dline
                  else
                    v.map_desc = {dline}
                  end
                end
                
                -- This is the snatch of code that actually adds it to routing.
                if not done and #db[i] > 0 then
                  nactive[db[i]] = true
                  if not active[db[i]] then
                    QH_Route_ClusterAdd(db[i])
                    if db[i].tooltip then QH_Tooltip_Add(db[i].tooltip) end
                    if turnin then QH_Route_ClusterRequires(turnin, db[i]) end
                  end
                  QH_Tracker_SetPin(db[i][1], watched)
                  if db[i][1].type_quest_unknown then table.insert(unknown, db[i]) end
                end
              end
            end
            
            if turnin_new then
              local timidx = 1
              while true do
                local timer = GetQuestIndexForTimer(timidx)
                if not timer then break end
                if timer == index then
                  QH_Route_SetClusterPriority(turnin, -1)
                  break
                end
                timidx = timidx + 1
              end
            end
          end
        end
      end
      index = index + 1
    end
    
    for _, v in ipairs(unknown) do
      QH_Route_IgnoreCluster(v, dontknow)
    end
    
    for k, v in pairs(active) do
      if not nactive[k] then
        if k.tooltip then QH_Tooltip_Remove(k.tooltip) end
        QH_Tracker_Unpin(k[1])
        QH_Route_ClusterRemove(k)
      end
    end
    
    active = nactive
    
    quest_list = quest_list_used
  end
end

QuestHelper.EventHookRegistrar("UNIT_QUEST_LOG_CHANGED", UpdateTrigger)
QuestHelper.EventHookRegistrar("QUEST_LOG_UPDATE", QH_UpdateQuests)

-- We don't return anything here, but I don't think that's actually an issue - those functions don't return anything anyway. Someday I'll regret writing this. Delay because of beql which is a bitch.
QH_AddNotifier(GetTime() + 5, function ()
  local aqw_orig = AddQuestWatch
  AddQuestWatch = function(...)
    aqw_orig(...)
    QH_UpdateQuests(true)
  end
  local rqw_orig = RemoveQuestWatch
  RemoveQuestWatch = function(...)
    rqw_orig(...)
    QH_UpdateQuests(true)
  end
end)
