QuestHelper_File["collect_quest.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_quest.lua"] == "Development Version" then debug_output = true end

local GetQuestType
local GetItemType

local QHCQ

local deebey

function RegisterQuestData(category, location, GetQuestLogWhateverInfo)
  local index = 1
  local localspot
  while true do
    local ilink = GetQuestLogItemLink(category, index)
    if not ilink then break end
    
    if not localspot then if not location["items_" .. category] then location["items_" .. category] = {} end localspot = location["items_" .. category] end
    
    local name, tex, num, qual, usa = GetQuestLogWhateverInfo(index)
    localspot[GetItemType(ilink)] = num
    
    --QuestHelper:TextOut(string.format("%s:%d - %d %s %s", category, index, num, tostring(ilink), tostring(name)))
    
    index = index + 1
  end
end

function ScanQuests() -- make it local once we've debugged it
  local _, qcount = GetNumQuestLogEntries()
  
  QuestHelper:TextOut(tostring(qcount))
  
  local selected
  
  for i = 1, qcount * 2 do  -- Naturally, there doesn't seem to be a way to get *only quests* garblgraarangerfury
    local qlink = GetQuestLink(i)
    if qlink then
      local id, level = GetQuestType(qlink)
      
      --QuestHelper:TextOut(string.format("%s - %d %d", qlink, id, level))
      
      --if not QHCQ[id] then
      if true then
        if not selected then selected = GetQuestLogSelection() end
        SelectQuestLogEntry(i)
        
        QHCQ[id] = {}
        QHCQ[id].level = level
        
        RegisterQuestData("reward", QHCQ[id], GetQuestLogRewardInfo)
        RegisterQuestData("choice", QHCQ[id], GetQuestLogChoiceInfo)
      end
    end
  end
  
  if selected then SelectQuestLogEntry(selected) end  -- abort abort bzzt bzzt bzzt awoooooooga
end

function QH_Collect_Quest_Init(QHCData, API)
  if not QHCData.quest then QHCData.quest = {} end
  QHCQ = QHCData.quest
  
  GetQuestType = API.Utility_GetQuestType
  GetItemType = API.Utility_GetItemType
  QuestHelper: Assert(GetQuestType)
  QuestHelper: Assert(GetItemType)
  
  deebey = ScanQuests()
end
