local StaticData = {}

local function GetQuest(locale, faction, level, name)
  local l = StaticData[locale]
  if not l then
    l = {}
    l.quest = {}
    l.objective = {}
    StaticData[locale] = l
  end
  local a = l.quest[faction]
  if not a then
    a = {}
    l.quest[faction] = a
  end
  local b = a[level]
  if not b then
    b = {}
    a[level] = b
  end
  local q = b[name]
  if not q then
    q = {}
    b[name] = q
    q.finish = {}
  end
  return q
end

local function GetObjective(locale, category, name)
  local l = StaticData[locale]
  if not l then
    l = {}
    l.quest = {}
    l.objective = {}
    StaticData[locale] = l
  end
  local list = l.objective[category]
  if not list then
    list = {}
    l.objective[category] = list
  end
  local obj = list[name]
  if not obj then
    obj = {}
    list[name] = obj
  end
  return obj
end

local function Distance(a, b)
  local x, y = a[3]-b[3], a[4]-b[4]
  return math.sqrt(x*x+y*y)
end

local function TidyPositionList(list)
  local i = 1
  while i ~= #list do
    local nearest, distance = nil, 0
    for j = i+1, #list do
      local d = Distance(list[i], list[j])
      if not nearest or d < distance then
        nearest, distance = j, d
      end
    end
    if nearest and distance < 0.01 then
      local a, b = list[i].pos, list[closest].pos
      a[3] = (a[3]*a[5]+b[3]*b[5])/(a[5]+b[5])
      a[4] = (a[4]*a[5]+b[4]*b[5])/(a[5]+b[5])
      a[5] = a[5]+b[5]
      table.remove(list, nearest)
    else
      i = i + 1
    end
  end
end

local function MergePositionLists(list, add)
  for _, pos in ipairs(add) do
    local c, z, x, y, w = pos[1], pos[2], pos[3], pos[4], pos[5] or 1
    if type(c) == "number" and c > 0 and
       type(z) == "number" and z > 0 and
       type(x) == "number" and x > 0 and y < 1 and
       type(y) == "number" and y > 0 and y < 1 and
       type(w) == "number" and w > 0 then
      local nearest, distance = nil, 0
      for i, pos in ipairs(list) do
        if c == pos[1] and z == pos[2] then
          local d = math.sqrt((x-pos[3])*(x-pos[3])+(y-pos[4])*(y-pos[4]))
          if not nearest or d < distance then
            nearest, distance = i, d
          end
        end
      end
      if nearest and distance < 0.01 then
        pos[3] = (pos[3]*pos[5]+x*w)/(pos[5]+w)
        pos[4] = (pos[4]*pos[5]+x*w)/(pos[5]+w)
        pos[5] = pos[5]+w
      else
        table.insert(list, {c,z,x,y,w})
      end
    end
  end
end

local function AddQuestEnd(quest, npc)
  if not quest.finish then quest.finish = {} end
  quest.finish[npc] = (quest.finish[npc] or 0) + 1
end

local function AddQuestPos(quest, pos)
  if not quest.pos then quest.pos = {} end
  MergePositionLists(quest.pos, pos)
end

local function AddQuest(locale, faction, level, name, data)
  if type(faction) == "string" and (faction == "Horde" or faction == "Alliance")
     and type(level) == "number" and level >= 1 and level <= 100
     and type(name) == "string" and type(data) == "table" then
    
    local q = GetQuest(locale, faction, level, name)
    
    if type(data.finish) == "string" then
      AddQuestEnd(q, data.finish)
    elseif type(data.pos) == "table" then
      AddQuestPos(q, data.pos)
    end
  end
end

local function AddObjective(locale, category, name, objective)
  if type(category) == "string"
     and type(name) == "string"
     and type(objective) == "table" then
    local o = GetObjective(locale, category, name)
    
    if objective.quest == true then o.quest = true end
    
    if type(objective.pos) == "table" then
      if not o.pos then o.pos = {} end
      MergePositionLists(o.pos, objective.pos)
    end
    
    if category == "monster" then
      if type(objective.looted) == "number" and objective.looted > 1 then
        o.looted = (o.looted or 0) + objective.looted
      end
    elseif category == "item" then
      if type(objective.drop) == "table" then
        if not o.drop then o.drop = {} end
        for monster, count in pairs(objective.drop) do
          if type(monster) == "string" and type(count) == "number" then
            o.drop[monster] = (o.drop[monster] or 0) + count
          end
        end
      end
    end
  end
end

local function CollapseQuest(quest)
  local best_name, name_score = nil, 0
  
  if quest.finish then
    for name, weight in pairs(quest.finish) do
      if not best_name or weight > name_score then
        best_name, name_score = name, weight
      end
    end
  end
  
  local pos_score = 0
  
  if quest.pos then
    for i, pos in ipairs(quest.pos) do
      pos_score = pos_score + pos[5]
    end
  end
  
  if name_score < 0 and pos_score < 1 then
    return false
  end
  
  if name_score > pos_score then
    quest.finish = best_name
    quest.pos = nil
  else
    quest.finish = nil
    if quest.pos then TidyPositionList(quest.pos) end
  end
  
  return quest.pos == nil and quest.finish == nil
end

local function CollapseObjective(objective)
  if not objective.quest then return true end
  objective.quest = nil
  
  if objective.drop and not next(objective.drop, nil) then objective.drop = nil end
  if objective.pos and not next(objective.pos, nil) then objective.pos = nil end
  
  if objective.drop then
    -- Don't need both.
    objective.pos = nil
  end
  
  if objective.pos then TidyPositionList(objective.pos) end
  
  return objective.drop == nil and objective.pos == nil
end

function NewData()
  if type(data.QuestHelper_Locale) == "string" then
    local locale = data.QuestHelper_Locale
    if type(data.QuestHelper_Quests) == "table" then for faction, levels in pairs(data.QuestHelper_Quests) do
      if type(levels) == "table" then for level, quest_list in pairs(levels) do
        if type(quest_list) == "table" then for quest_name, quest_data in pairs(quest_list) do
          AddQuest(locale, faction, level, quest_name, quest_data)
        end end
      end end
    end end
    
    if type(data.QuestHelper_Objectives) == "table" then for category, objectives in pairs(data.QuestHelper_Objectives) do
      if type(objectives) == "table" then for name, objective in pairs(objectives) do
        AddObjective(locale, category, name, objective)
      end end
    end end
  end
end

local function isArray(obj)
  local c = 0
  for i, j in pairs(obj) do c = c + 1 end
  return c == #obj
end

local function Dump(variable, depth, seen)
  if type(variable) == "string" then
    return ("%q"):format(variable)
  elseif type(variable) == "number" then
    return variable + 0
  elseif type(variable) == "nil" then
    return "nil"
  elseif type(variable) == "boolean" then
    return variable and "true" or "false"
  elseif type(variable) == "table" then
    if not seen then seen = {} end
    if seen[variable] then
      -- return "nil --[[ TABLE CONTAINS ITSELF! ]]"
    end
    seen[variable] = true
    if not depth then depth = 1 end
    local text = "{"
    
    if isArray(variable) then
      for i, j in ipairs(variable) do
        text = text..Dump(j, depth+1, seen)
        if next(variable,i) then
          text = text..","..(type(variable[i+1])=="table"and"\n"..("  "):rep(depth) or " ")
        else
          return text.."}"
        end
      end
    else
      for i, j in pairs(variable) do
        local a = Dump(i, depth+1, seen)
        local b = Dump(j, depth+1, seen)
        
        text = text.."["..Dump(i, depth+1, seen).. "]="..
               (type(j)=="table"and"\n"..("  "):rep(depth+1) or "")..Dump(j, depth+1, seen)
        
        if next(variable,i) then
          text = text..",\n"..("  "):rep(depth)
        end
      end
    end
    seen[variable] = nil
    return text.."}"
  else
    return "nil --[[ UNHANDLED TYPE: '"..type(variable).."' ]]"
  end
end

function Finished()
  for locale, l in pairs(StaticData) do
    for faction, levels in pairs(l.quest) do
      local delete_faction = true
      for level, quest_list in pairs(levels) do
        local delete_level = true
        for quest, quest_data in pairs(quest_list) do
          if CollapseQuest(quest_data) then
            quest_list[quest] = nil
          else
            if quest_data.finish then
              GetObjective(locale, "monster", quest_data.finish).quest = true
            end
            delete_level = false
          end
        end
        
        if delete_level then levels[level] = nil else delete_faction = false end
      end
      if delete_faction then l.quest[faction] = nil end
    end
    
    if l.objective["item"] then 
      for name, objective in pairs(l.objective["item"]) do
        -- If this is a quest item, mark anything that drops it as being a quest monster.
        if objective.quest and objective.drop then
          for monster, count in pairs(objective.drop) do
            GetObjective(locale, "monster", monster).quest = true
          end
        end
      end
    end
    
    for category, objectives in pairs(l.objective) do
      local delete_category = true
      for name, objective in pairs(objectives) do
        if CollapseObjective(objective) then
          objectives[name] = nil
        else
          delete_category = false
        end
      end
      if delete_category then l.objective[category] = nil end
    end
  end
  
  print("QuestHelper_StaticData="..Dump(StaticData))
  print("\n-- END OF FILE --\n")
end
