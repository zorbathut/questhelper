QuestHelper_File["collect_quest.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_quest.lua"] == "Development Version" then debug_output = true end

local GetItemType

local QHCQ

function QH_Collect_Quest_Init(QHCData, API)
  if not QHCData.quest then QHCData.quest = {} end
  QHCQ = QHCData.quest
  
end
