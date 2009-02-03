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

local function UpdateQuests()
  QuestHelper:TextOut("updatedo")
  if update then
  
    local index = 1
    
    local nactive = {}
    
    while true do
      if not GetQuestLogTitle(index) then break end
      
      local qlink = GetQuestLink(index)
      if qlink then
        local id = GetQuestType(qlink)
        if id then
          local db = DB_GetItem("quest_metaobjective", id)
          
          if db then
            local lbcount = GetNumQuestLeaderBoards(index)
            for i = 1, GetNumQuestLeaderBoards(index) do
              local desc, _, done = GetQuestLogLeaderBoard(i, index)
              if db[i] then db[i].desc = desc end
              
              if not done then if db[i] and db[i].loc then
                nactive[db[i]] = true
                if not active[db[i]] then
                  QH_Route_NodeAdd(db[i])
                end
              end end
            end
            
            if db[lbcount + 1] and db[lbcount + 1].loc then
              nactive[db[lbcount + 1]] = true
              if not active[db[lbcount + 1]] then
                QH_Route_NodeAdd(db[lbcount + 1])
              end
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
