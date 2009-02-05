QuestHelper_File["director_quest.lua"] = "Development Version"
QuestHelper_Loadtime["director_quest.lua"] = GetTime()

local function GetQuestType(link)
  return tonumber(string.match(link,
    "^|cff%x%x%x%x%x%x|Hquest:(%d+):[%d-]+|h%[[^%]]*%]|h|r$"
  )), tonumber(string.match(link,
    "^|cff%x%x%x%x%x%x|Hquest:%d+:([%d-]+)|h%[[^%]]*%]|h|r$"
  ))
end

local update = true
local function UpdateTrigger()
  QuestHelper:TextOut("updatetrig")
  update = true
end

local active = {}

local objective_parse = {
  item = function (txt) return QuestHelper:convertPattern(QUEST_OBJECTS_FOUND)(txt) end,
  object = function (txt) return QuestHelper:convertPattern(QUEST_OBJECTS_FOUND)(txt) end,  -- why does this even exist
  monster = function (txt) return QuestHelper:convertPattern(QUEST_MONSTERS_KILLED)(txt) end,
  event = function (txt, done) return txt, (done and 1 or 0), 1 end, -- It appears that events are only used for things which can only happen once.
  reputation = function (txt) return QuestHelper:convertPattern(QUEST_FACTION_NEEDED)(txt) end, -- :ughh:
  player = function (txt) return QuestHelper:convertPattern(QUEST_MONSTERS_KILLED)(txt) end, -- We're using monsters here in the hopes that it follows the same pattern. I'd rather not try to find the exact right version of "player" in the locale files, though PLAYER might be it.
}

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
  local target, have, need = objective_parse[typ](title, done)
  --QuestHelper:TextOut(string.format("%s becomes %s/%s/%s", tostring(title), tostring(target), tostring(have), tostring(need)))
  
  if not target then
    -- well, that didn't work
    target, have, need = string.match(title, "^%s*(.-)%s*:%s*(.-)%s*/%s*(.-)%s*$")
    --QuestHelper:TextOut(string.format("%s rebecomes %s/%s/%s", tostring(title), tostring(target), tostring(have), tostring(need)))
  end
  
  if not target then
    target, have, need = string.match(title, "^%s*(.-)%s*$"), (done and 1 or 0), 1
    --QuestHelper:TextOut(string.format("%s rerebecomes %s/%s/%s", tostring(title), tostring(target), tostring(have), tostring(need)))
  end
  
  QuestHelper: Assert(target) -- This will fail repeatedly. Come on. We all know it.
  QuestHelper: Assert(have)
  QuestHelper: Assert(need) -- As will these.
  
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
end

local function UpdateQuests()
  QuestHelper:TextOut("updatedo")
  if update then
  
    local index = 1
    
    local nactive = {}
    
    while true do
      local title, level = GetQuestLogTitle(index)
      if not title then break end
      
      local qlink = GetQuestLink(index)
      if qlink then
        local id = GetQuestType(qlink)
        if id then
          local db = DB_GetItem("quest_metaobjective", id)
          
          if db then
            local lindex = index
            db.desc = title
            db.tracker_desc = MakeQuestTitle(title, level)
            db.tracker_clicked = function () Clicky(lindex) end
            
            local lbcount = GetNumQuestLeaderBoards(index)
            
            local turnin
            
            if db[lbcount + 1] and db[lbcount + 1].loc then
              turnin = db[lbcount + 1]
              nactive[turnin] = true
              if not active[turnin] then
                turnin.tracker_clicked = function () Clicky(lindex) end
                QH_Route_NodeAdd(db[lbcount + 1])
              end
            end
            
            for i = 1, GetNumQuestLeaderBoards(index) do
              local desc, typ, done = GetQuestLogLeaderBoard(i, index)
              if db[i] then db[i].tracker_desc = MakeQuestObjectiveTitle(desc, typ, done) db[i].desc = desc end
              
              if not done then if db[i] and db[i].loc then
                nactive[db[i]] = true
                if not active[db[i]] then
                  db[i].tracker_clicked = function () Clicky(lindex) end
                  QH_Route_NodeAdd(db[i])
                  if turnin then QH_Route_NodeRequires(turnin, db[i]) end
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
        QH_Route_NodeRemove(k)
      end
    end
    
    active = nactive
  end
end

QuestHelper.EventHookRegistrar("UNIT_QUEST_LOG_CHANGED", UpdateTrigger)
QuestHelper.EventHookRegistrar("QUEST_LOG_UPDATE", UpdateQuests)
