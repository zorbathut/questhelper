QuestHelper_File["collect.lua"] = "Development Version"

QuestHelper_Collector = {}
QuestHelper_Collector_Version = 1

function QH_Collector_Init()
  local sig = GetAddOnMetadata("QuestHelper", "Version") .. " on " .. GetBuildInfo()
  if not QuestHelper_Collector[sig] then QuestHelper_Collector[sig] = {} end
  local QHCData = QuestHelper_Collector[sig]

  QH_Collect_Achievement_Init(QHCData)
  QH_Collect_Traveled_Init(QHCData)
  
  if not QHCData.servers then QHCData.servers = {} end
  QHCData.servers[GetRealmName()] = (QHCData.servers[GetRealmName()] or 0) + 1 -- I'm not entirely sure why I'm doing this
end
