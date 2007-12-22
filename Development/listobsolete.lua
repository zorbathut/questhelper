local function ProcessObjective(category, name, objective, result)
  local istring = "obj."..category.."."..name
  
  if category ~= "item" then
    local seen = 0
    if objective.pos then for i, pos in pairs(objective.pos) do
      seen = seen + pos[5]
    end end
    
    result[istring..".seen"] = (result[istring..".seen"] or 0) + seen
  end
  
  if objective.vendor then
    result[istring..".vend"] = (result[istring..".vend"] or 0) + #objective.vendor
  end
  
  if objective.drop then for monster, count in pairs(objective.drop) do
    result[istring] = (result[istring] or 0) + count
  end end
end

local function ProcessQuest(faction, level, name, quest, result)
  local qstring = "quest."..faction.."."..level.."."..name
  result[qstring] = (result[qstring] or 0)+((quest.finish or quest.pos) and 1 or 0)
  
  if quest.item then for item_name, data in pairs(quest.item) do
    ProcessObjective("item", item_name, data, result)
  end end
  
  if quest.alt then for _, quest2 in pairs(quest.alt) do
    ProcessQuest(faction, level, name, quest2, result)
  end end
end


local function LoadFile(file)
  local data = loadfile(file)
  local result = {}
  if data then
    local loaded = {}
    setfenv(data, loaded)
    data()
    
    if type(loaded.QuestHelper_Quests) == "table" then for faction, levels in pairs(loaded.QuestHelper_Quests) do
      if type(levels) == "table" then for level, quest_list in pairs(levels) do
        if type(quest_list) == "table" then for name, quest in pairs(quest_list) do
          ProcessQuest(faction, level, name, quest, result)
        end end
      end end
    end end
    
    if type(loaded.QuestHelper_Objectives) == "table" then for category, objectives in pairs(loaded.QuestHelper_Objectives) do
      if type(objectives) == "table" then for name, objective in pairs(objectives) do
        ProcessObjective(category, name, objective, result)
      end end
    end end
  end
  
  return result
end

local function ObsoletedBy(data1, data2)
  for key, value in pairs(data1) do
    local value2 = data2[key]
    if value2 == nil or value2 < value then
      return false
    end
  end
  return true
end

local i = 1
while i < #arg do
  local removed = false
  
  i_data = LoadFile(arg[i])
  
  local j = i+1
  while j <= #arg do
    j_data = LoadFile(arg[j])
    
    if ObsoletedBy(i_data, j_data) then
      removed = true
      break
    elseif ObsoletedBy(j_data, i_data) then
      print(table.remove(arg, j))
    else
      j = j + 1
    end
  end
  
  if removed then
    print(table.remove(arg, i))
  else
    i = i + 1
  end
end
