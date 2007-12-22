QuestHelper_Ver01_Zones =
  {{[1]="Ashenvale",
    [2]="Azshara",
    [3]="Azuremyst Isle",
    [4]="Bloodmyst Isle",
    [5]="Darkshore",
    [6]="Darnassus",
    [7]="Desolace",
    [8]="Durotar",
    [9]="Dustwallow Marsh",
    [10]="Felwood",
    [11]="Feralas",
    [12]="Moonglade",
    [13]="Mulgore",
    [14]="Orgrimmar",
    [15]="Silithus",
    [16]="Stonetalon Mountains",
    [17]="Tanaris",
    [18]="Teldrassil",
    [19]="The Barrens",
    [20]="The Exodar",
    [21]="Thousand Needles",
    [22]="Thunder Bluff",
    [23]="Un'Goro Crater",
    [24]="Winterspring"},
   {[1]="Alterac Mountains",
    [2]="Arathi Highlands",
    [3]="Badlands",
    [4]="Blasted Lands",
    [5]="Burning Steppes",
    [6]="Deadwind Pass",
    [7]="Dun Morogh",
    [8]="Duskwood",
    [9]="Eastern Plaguelands",
    [10]="Elwynn Forest",
    [11]="Eversong Woods",
    [12]="Ghostlands",
    [13]="Hillsbrad Foothills",
    [14]="Ironforge",
    [15]="Loch Modan",
    [16]="Redridge Mountains",
    [17]="Searing Gorge",
    [18]="Silvermoon City",
    [19]="Silverpine Forest",
    [20]="Stormwind City",
    [21]="Stranglethorn Vale",
    [22]="Swamp of Sorrows",
    [23]="The Hinterlands",
    [24]="Tirisfal Glades",
    [25]="Undercity",
    [26]="Western Plaguelands",
    [27]="Westfall",
    [28]="Wetlands"},
   {[1]="Blade's Edge Mountains",
    [2]="Hellfire Peninsula",
    [3]="Nagrand",
    [4]="Netherstorm",
    [5]="Shadowmoon Valley",
    [6]="Shattrath City",
    [7]="Terokkar Forest",
    [8]="Zangarmarsh"}}

function QuestHelper_ValidPosition(c, z, x, y)
  local zd = QuestHelper_Ver01_Zones
  return type(x) == "number" and type(y) == "number" and x > -0.1 and y > -0.1 and x < 1.1 and y < 1.1 and c and zd[c] and z and zd[c][z]
end

function QuestHelper_PrunePositionList(list)
  if type(list) ~= "table" then
    return nil
  end
  
  local i = 1
  while i <= #list do
    if QuestHelper_ValidPosition(unpack(list[i])) and type(list[i][5]) == "number" and list[i][5] >= 1 then
      i = i + 1
    else
      local rem = table.remove(list, i)
    end
  end
  
  return #list > 0 and list or nil
end

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
  
  if data.QuestHelper_SaveVersion == 3 then
    -- We'll go through this and make sure all the position lists are correct.
    for faction, level_list in pairs(data.QuestHelper_Quests) do
      for level, quest_list in pairs(level_list) do
        for quest_name, quest_data in pairs(quest_list) do
          quest_data.pos = QuestHelper_PrunePositionList(quest_data.pos)
          if quest_data.item then for name, data in pairs(quest_data.item) do
            data.pos = QuestHelper_PrunePositionList(data.pos)
          end end
          if quest_data.alt then for hash, data in pairs(quest_data.alt) do
            data.pos = QuestHelper_PrunePositionList(data.pos)
            if data.item then for name, data in pairs(data.item) do
              data.pos = QuestHelper_PrunePositionList(data.pos)
            end end
          end end
        end
      end
    end
    
    for cat, list in pairs(data.QuestHelper_Objectives) do
      for name, data in pairs(list) do
        data.pos = QuestHelper_PrunePositionList(data.pos)
      end
    end
    
    if data.QuestHelper_ZoneTransition then
      for c, z1list in pairs(data.QuestHelper_ZoneTransition) do
        for z1, z2list in pairs(z1list) do
          for z2, poslist in pairs(z2list) do
            z2list[z2] = QuestHelper_PrunePositionList(poslist)
          end
        end
      end
    end
    
    data.QuestHelper_SaveVersion = 4
  end
end
