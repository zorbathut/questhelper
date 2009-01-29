QuestHelper_File["director_quest.lua"] = "Development Version"
QuestHelper_Loadtime["director_quest.lua"] = GetTime()

local function GetQuestType(link)
  return tonumber(string.match(link,
    "^|cff%x%x%x%x%x%x|Hquest:(%d+):[%d-]+|h%[[^%]]*%]|h|r$"
  )), tonumber(string.match(link,
    "^|cff%x%x%x%x%x%x|Hquest:%d+:([%d-]+)|h%[[^%]]*%]|h|r$"
  ))
end

local active = {}

function refresh_quest()  
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
          nactive[id] = true
          
          if not active[id] then
            QuestHelper:TextOut(tostring(id))
            local qdat = QuestHelper_Static.quest[id]
            for k, v in ipairs(db) do if v.loc then Public_NodeAdd(v) end end
          end
        end
      end
    end
    index = index + 1
  end
  
  for k, v in pairs(active) do
    if not nactive[k] then
      local db = DB_GetItem("quest", k)
      
      for k, v in ipairs(db) do if v.loc then Public_NodeRemove(v) end end
    end
  end
  
  active = nactive
end
