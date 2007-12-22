function QuestHelper_UpgradeDatabase(data)
  if data.QuestHelper_SaveVersion == 1 then
    
    -- Reputation objectives weren't parsed correctly before.
    if data.QuestHelper_Objectives["reputation"] then
      for faction, objective in pairs(data.QuestHelper_Objectives["reputation"]) do
        local real_faction = string.find(faction, "%s*(.+)%s*:%s*") or faction
        if faction ~= real_faction then
          data.QuestHelper_Objectives["reputation"][real_faction] = data.QuestHelper_Objectives["reputation"][faction]
          data.QuestHelper_Objectives["reputation"][faction] = nil
        end
      end
    end
    
    -- Items that wern't in the local cache when I read the quest log ended up with empty names.
    if data.QuestHelper_Objectives["item"] then
      data.QuestHelper_Objectives["item"][" "] = nil
    end
    
    data.QuestHelper_SaveVersion = 2
  end
  
  if data.QuestHelper_SaveVersion == 2 then
    
    -- The hashes for the quests were wrong. Damnit!
    for faction, level_list in pairs(data.QuestHelper_Quests) do
      for level, quest_list in pairs(level_list) do
        for quest_name, quest_data in pairs(quest_list) do
          quest_data.hash = nil
          quest_data.alt = nil
        end
      end
    end
    
    -- None of the information I collected about quest items previously can be trusted.
    -- I also didn't properly mark quest items as such, so I'll have to remove the information for non
    -- quest items also.
    
    if data.QuestHelper_Objectives["item"] then
      for item, item_data in pairs(data.QuestHelper_Objectives["item"]) do
        -- I'll remerge the bad data later if I find out its not used solely for quests.
        item_data.bad_pos = item_data.bad_pos or item_data.pos
        item_data.bad_drop = item_data.bad_drop or item_data.drop
        item_data.pos = nil
        item_data.drop = nil
        
        -- In the future i'll delete the bad_x data.
        -- When I do, either just delete it, or of all the monsters or positions match the monsters and positions of the
        -- quest, merge them into that.
      end
    end
    
    data.QuestHelper_SaveVersion = 3
  end
end
