QuestHelper_File["collect_upgrade.lua"] = "Development Version"
QuestHelper_Loadtime["collect_upgrade.lua"] = GetTime()

function QH_Collector_Upgrade()
  if QuestHelper_Collector_Version == 1 then
    -- We basically just want to clobber all our old route data, it's not worth storing - it's all good data, it's just that we don't want to preserve relics of the old location system.
    for _, v in pairs(QuestHelper_Collector) do
      v.traveled = nil
    end
    
    QuestHelper_Collector_Version = 2
  end
  
  if QuestHelper_Collector_Version == 2 then
    -- Originally I split the zones based on locale. Later I just split everything based on locale. Discarding old data rather than doing the gymnastics needed to preserve it.
    -- This is turning into a routine. :D
    for _, v in pairs(QuestHelper_Collector) do
      v.zone = nil
    end
    
    QuestHelper_Collector_Version = 3
  end
end
