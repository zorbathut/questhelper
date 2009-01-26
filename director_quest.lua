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
      
      if id and QuestHelper_Static.quest[id] then
        nactive[id] = true
        
        if not active[id] then
          local qdat = QuestHelper_Static.quest[id]
          if qdat.finish then Public_NodeAdd(qdat.finish.loc) end
          if qdat.criteria then for k, v in pairs(qdat.criteria) do Public_NodeAdd(v.loc) end end
        end
      end
    end
    index = index + 1
  end
  
  for k, v in pairs(active) do
    if not nactive[k] then
      local qdat = QuestHelper_Static.quest[k]
      
      if qdat.finish then Public_NodeRemove(qdat.finish.loc) end
      if qdat.criteria then for k, v in pairs(qdat.criteria) do Public_NodeRemove(v.loc) end end
    end
  end
  
  active = nactive
end
