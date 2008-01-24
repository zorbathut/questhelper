local StaticData = {}

function CreateAverage()
  return {}
end

function AppendToAverage(average, value)
  table.insert(average, value)
end

function CollapseAverage(average)
  table.sort(average)
  local to_remove = math.floor(#average*0.2)
  for i = 1,to_remove do
    table.remove(average, 1)
    table.remove(average, 1)
  end
  if #average == 0 then 
    return nil
  end
  local sum = 0
  for _, v in pairs(average) do
    sum = sum + v
  end
  return sum/#average
end

function GetQuest(locale, faction, level, name, hash)
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
    q.hash = hash
    q.alt = {}
  end
  
  if hash and hash ~= q.hash then
    if q.alt[hash] then
      return q.alt[hash]
    end
  end
  
  if hash and not q.hash then
    -- If the old quest didn't have a hash, we'll assume this is it. If we're wrong, we'll
    -- hopefully overwrite it with the correct data.
    q.hash = hash
  elseif not hash and q.hash then
    -- If the old quest had a hash, but this one doesn't, we'll return a dummy object
    -- so that we don't overwrite it with the wrong quest data.
    q = {}
  elseif hash ~= q.hash then
    local q2 = {}
    q2.hash = hash
    q.alt[hash] = q2
    q = q2
  end
  
  return q
end

function GetObjective(locale, category, name)
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
  -- Doing this, because the distances are going to be rounded later, and I don't want it to create 
  -- a situation where if you ran TidyPositionList twice, it would have a different result.
  
  local x, y = math.floor(a[3]*10000+0.5)/10000-math.floor(b[3]*10000+0.5)/10000,
               math.floor(a[4]*10000+0.5)/10000-math.floor(b[4]*10000+0.5)/10000
  
  return math.sqrt(x*x+y*y)
end

local function TidyDropList(locale, list)
  local high = 0
  
  for monster, count in pairs(list) do
    local monster_obj = GetObjective(locale, "monster", monster)
    if monster_obj.looted and monster_obj.looted > 0 then
      high = math.max(high, math.max(1, math.floor(count))/math.ceil(monster_obj.looted))
    end
  end
  
  for monster, count in pairs(list) do
    local monster_obj = GetObjective(locale, "monster", monster)
    count = math.max(1, math.floor(count))
    
    if monster_obj.looted and monster_obj.looted > 0 and count/math.ceil(monster_obj.looted) > high*0.2 then
      list[monster] = count
    else
      list[monster] = nil
    end
  end
end

local function TidyPositionList(list, min_distance)
  min_distance = min_distance or 0.03
  while true do
    if #list == 0 then return end
    local changed = false
    local i = 1
    while i <= #list do
      local nearest, distance = nil, 0
      for j = i+1, #list do
        local d = Distance(list[i], list[j])
        if not nearest or d < distance then
          nearest, distance = j, d
        end
      end
      if nearest and distance < min_distance then
        local a, b = list[i], list[nearest]
        a[3] = (a[3]*a[5]+b[3]*b[5])/(a[5]+b[5])
        a[4] = (a[4]*a[5]+b[4]*b[5])/(a[5]+b[5])
        a[5] = a[5]+b[5]
        table.remove(list, nearest)
        changed = true
      else
        i = i + 1
      end
    end
    if not changed then
      -- Because we moved nodes around, we'll check again to make sure we didn't move too close together
      break
    end
  end
  
  local highest = 0
  
  for i, data in ipairs(list) do
    data[5] = math.pow(data[5], 0.73575888234288) -- Raising it to this number to make huge numbers seem closer together, the positions are probably correct and not some mistake.
    highest = math.max(highest, data[5])
  end
  
  local i = 1 -- Remove anything that doesn't seem very likely.
  while i <= #list do
    if list[i][5] < highest*0.2 then
      table.remove(list, i)
    else
      list[i][5] = math.max(1, math.floor(list[i][5]+0.5))
      i = i + 1
    end
  end
  
  for i, j in ipairs(list) do
    j[3] = math.floor(j[3]*10000+0.5)/10000
    j[4] = math.floor(j[4]*10000+0.5)/10000
  end
  
  table.sort(list, function(a, b)
    if a[5] > b[5] then return true end
    if a[5] < b[5] then return false end
    if a[1] < b[1] then return true end
    if a[1] > b[1] then return false end
    if a[2] < b[2] then return true end
    if a[2] > b[2] then return false end
    if a[3] < b[3] then return true end
    if a[3] > b[3] then return false end
    return a[4] < b[4]
  end)
end

local function DropListMass(list)
  local mass = 0
  for item, count in pairs(list) do
    mass = mass + count
  end
  return mass
end

local function PositionListMass(list)
  local mass = 0
  for _, pos in ipairs(list) do
    mass = mass + pos[5]
  end
  return mass
end

local function CollapseDropList(list)
  local result, c = nil, 0
  for item, count in pairs(list) do
    if not result or count > c then
      result, c = item, count
    end
  end
  return result
end

local function MergeDropLists(list, add)
  for item, count in pairs(add) do
    list[item] = (list[item] or 0) + count
  end
end

local function MergePositionLists(list, add)
  for _, pos in ipairs(add) do
    local c, z, x, y, w = pos[1], pos[2], pos[3], pos[4], pos[5] or 1
    if type(c) == "number" and
       QuestHelper_ValidPosition(c, z, x, y) and
       type(w) == "number" and w > 0 then
      local bp, distance = nil, 0
      for i, pos2 in ipairs(list) do
        if c == pos2[1] and z == pos2[2] then
          local d = math.sqrt((x-pos2[3])*(x-pos2[3])+(y-pos2[4])*(y-pos2[4]))
          if not nearest or d < distance then
            bp, distance = pos2, d
          end
        end
      end
      if bp and distance < 0.03 then
        bp[3] = (bp[3]*bp[5]+x*w)/(bp[5]+w)
        bp[4] = (bp[4]*bp[5]+y*w)/(bp[5]+w)
        bp[5] = bp[5]+w
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

local function AddQuestItems(quest, list)
  for item, data in pairs(list) do
    if type(data.drop) == "table" then
      if not quest.item then quest.item = {} end
      if not quest.item[item] then quest.item[item] = {} end
      if not quest.item[item].drop then quest.item[item].drop = {} end
      MergeDropLists(quest.item[item].drop, data.drop)
    elseif type(data.pos) == "table" then
      if not quest.item then quest.item = {} end
      if not quest.item[item] then quest.item[item] = {} end
      if not quest.item[item].pos then quest.item[item].pos = {} end
      MergePositionLists(quest.item[item].pos, data.pos)
    end
  end
end

local function ValidFaction(faction)
  return type(faction) == "string" and (faction == "Horde" or faction == "Alliance")
end

local function AddQuest(locale, faction, level, name, data)
  if ValidFaction(faction)
     and type(level) == "number" and level >= 1 and level <= 100
     and type(name) == "string" and type(data) == "table" then
    
    local _, _, real_name = string.find(name, "^%["..level.."[^%s]-%] (.+)$")
    
    if real_name then
      -- The Quest Level AddOn mangles level names.
      name = real_name
    end
    
    local q = GetQuest(locale, faction, level, name, type(data.hash) == "number" and data.hash or nil)
    
    if type(data.finish) == "string" then
      AddQuestEnd(q, data.finish)
    elseif type(data.pos) == "table" then
      AddQuestPos(q, data.pos)
    end
    
    if type(data.item) == "table" then
      AddQuestItems(q, data.item)
    end
    
    if type(data.hash) == "number" and type(data.alt) == "table" then
      for hash, quest in pairs(data.alt) do
        quest.hash = hash
        AddQuest(locale, faction, level, name, quest)
      end
    end
  end
end

local function AddFlightInstructor(locale, faction, location, npc)
  if ValidFaction(faction) and type(location) == "string" and type(npc) == "string" then
    local l = StaticData[locale]
    if not l then
      l = {}
      StaticData[locale] = l
    end
    local faction_list = l.flight_instructors
    if not faction_list then
      faction_list = {}
      l.flight_instructors = faction_list
    end
    
    local location_list = faction_list[faction]
    if not location_list then
      location_list = {}
      faction_list[faction] = location_list
    end
    location_list[location] = npc
  end
end

local function AddFlightRoute(locale, continent, start, destination, hash, data)
  if type(continent) == "number" and
     type(start) == "string" and
     type(destination) == "string" and
     type(hash) == "number" and
     type(data) == "table" and
     type(data.raw) == "number" and 
     (not data.real or type(data.real) == "number") then
    local l = StaticData[locale]
    if not l then
      l = {}
      StaticData[locale] = l
    end
    local continent_list = l.flight_routes
    if not continent_list then
      continent_list = {}
      l.flight_routes = continent_list
    end
    local start_list = continent_list[continent]
    if not start_list then
      start_list = {}
      continent_list[continent] = start_list
    end
    local end_list = start_list[start]
    if not end_list then
      end_list = {}
      start_list[start] = end_list
    end
    local hash_list = end_list[destination]
    if not hash_list then
      hash_list = {}
      end_list[destination] = hash_list
    end
    local route_data = hash_list[hash]
    if not route_data then
      route_data = {}
      hash_list[hash] = route_data
    end
    route_data.raw = route_data.raw or data.raw
    if data.real then
      if not route_data.real then
        route_data.real = CreateAverage()
      end
      AppendToAverage(route_data.real, data.real)
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
      if type(objective.looted) == "number" and objective.looted >= 1 then
        o.looted = (o.looted or 0) + objective.looted
      end
      if type(objective.faction) == "string" then
        if ValidFaction(objective.faction) then
          o.faction = objective.faction
        end
      end
    elseif category == "item" then
      if type(objective.vendor) == "table" then
        if not o.vendor then o.vendor = {} end
        
        for _, v1 in ipairs(objective.vendor) do
          local known = false
          for _, v2 in ipairs(o.vendor) do
            if v1 == v2 then
              known = true
              break
            end
          end
          
          if not known then table.insert(o.vendor, v1) end
        end
      end
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

local function CollapseQuest(locale, quest)
  local name_score = quest.finish and DropListMass(quest.finish) or 0
  local pos_score = quest.pos and PositionListMass(quest.pos)*0.25 or 0
  
  if name_score > pos_score then
    quest.finish = CollapseDropList(quest.finish)
    quest.pos = nil
  else
    quest.finish = nil
    if quest.pos then
      TidyPositionList(quest.pos)
    end
  end
  
  if quest.item and not next(quest.item) then
    quest.item = nil
  end
  
  return quest.pos == nil and quest.finish == nil and quest.item == nil
end

local function CollapseObjective(locale, objective)
  if not objective.quest then return true end
  objective.quest = nil
  
  if objective.drop and not next(objective.drop, nil) then objective.drop = nil end
  if objective.pos and #objective.pos == 0 then objective.pos = nil end
  if objective.vendor and not next(objective.vendor, nil) then objective.vendor = nil end
  
  if objective.drop then
    -- Can't call TidyDropList, it might create new Objectives that will get missed. We'll have called it before hand.
    
    if not next(objective.drop) or (objective.pos and PositionListMass(objective.pos) > DropListMass(objective.drop)) then
      objective.drop = nil
      if objective.pos then
        TidyPositionList(objective.pos)
        if not next(objective.pos, nil) then
          objective.pos = nil
        end
      end
    else
      objective.pos = nil
    end
  elseif objective.pos then
    TidyPositionList(objective.pos)
    if not next(objective.pos, nil) then
      objective.pos = nil
    end
  end
  
  if objective.looted then
    objective.looted = math.max(1, math.ceil(objective.looted))
  end
  
  if not objective.vendor or not next(objective.vendor) then
    objective.vendor = nil
  else
    table.sort(objective.vendor)
  end
  
  return objective.drop == nil and objective.pos == nil and objective.vendor == nil
end

local function CollapseFlightRoute(data)
  data.real = data.real and CollapseAverage(data.real)
  if data.real then
    data.real = math.floor(data.real*10+0.5)/10
    return false
  end
  return true
end

local function AddInputData(data)
  if data.QuestHelper_StaticData then
    -- Importing a static data file.
    local static = data.QuestHelper_StaticData
    data.QuestHelper_StaticData = nil
    
    for locale, info in pairs(static) do
      data.QuestHelper_Locale = locale
      data.QuestHelper_Quests = info.quest
      data.QuestHelper_Objectives = info.objective
      data.QuestHelper_FlightRoutes = info.flight_routes
      data.QuestHelper_FlightInstructors = info.flight_instructors
      
      for cat, list in pairs(data.QuestHelper_Objectives) do
        for name, info in pairs(list) do
          info.quest = true
        end
      end
      
      AddInputData(data)
    end
    
    return
  end
  
  QuestHelper_UpgradeDatabase(data)
  
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
    
    if type(data.QuestHelper_FlightInstructors) == "table" then for faction, list in pairs(data.QuestHelper_FlightInstructors) do
      if type(list) == "table" then for location, npc in pairs(list) do
        AddFlightInstructor(locale, faction, location, npc)
      end end
    end end
    
    if type(data.QuestHelper_FlightRoutes) == "table" then for continent, start_list in pairs(data.QuestHelper_FlightRoutes) do
      if type(start_list) == "table" then for start, destination_list in pairs(start_list) do
        if type(destination_list) == "table" then for destination, route_list in pairs(destination_list) do
          if type(route_list) == "table" then for hash, data in pairs(route_list) do
            AddFlightRoute(locale, continent, start, destination, hash, data)
          end end
        end end
      end end
    end end
  end
end

local function QuestItemsAreSimilar(item, quest_list)
  -- TODO: Write this function. Should make sure all the quests get item from the same place.
  return #quest_list <= 1
end

local function RemoveQuestByData(data)
  for locale, l in pairs(StaticData) do
    for faction, levels in pairs(l.quest) do
      for level, quest_list in pairs(levels) do
        for quest, quest_data in pairs(quest_list) do
          if data == quest_data then
            if quest_data.alt then
              local alt = quest_data.alt
              local hash = next(alt, nil)
              local quest_data2 = alt[hash]
              alt[hash] = nil
              quest_list[quest] = quest_data2
              if next(alt, nil) then
                quest_data2.alt = alt
                quest_data2.hash = hash
              end
            else
              quest_list[quest] = nil
            end
          elseif quest_data.alt then
            for hash, quest_data2 in pairs(quest_data.alt) do
              if data == quest_data2 then
                quest_data.alt[hash] = nil
                break
              end
            end
            if not next(quest_data.alt) then
              quest_data.alt = nil
              quest_data.hash = nil
            end
          end
        end
        if not next(levels[level], nil) then levels[level] = nil end
      end
      if not next(l.quest[faction], nil) then l.quest[faction] = nil end
    end
  end
end

function CompileInputFile(filename)
  local data_loader = loadfile(filename)
  if data_loader then
    local data = {}
    setfenv(data_loader, data)
    data_loader()
    AddInputData(data)
  else
    print("'"..filename.."' couldn't be loaded!")
  end
end

function CompileFinish()
  for locale, l in pairs(StaticData) do
    local quest_item_mass = {}
    local quest_item_quests = {}
    
    local function WatchQuestItems(quest)
      if quest.finish then GetObjective(locale, "monster", quest.finish).quest = true end
      
      if quest.item then
        for item, data in pairs(quest.item) do
          quest_item_mass[item] = (quest_item_mass[item] or 0)+
                                  (data.drop and DropListMass(data.drop) or 0)+
                                  (data.pos and PositionListMass(data.pos) or 0)
          
          quest_item_quests[item] = quest_item_quests[item] or {}
          table.insert(quest_item_quests[item], quest)
        end
      end
    end
    
    for faction, levels in pairs(l.quest) do
      local delete_faction = true
      for level, quest_list in pairs(levels) do
        local delete_level = true
        for quest, quest_data in pairs(quest_list) do
          if quest_data.alt then
            for hash, quest_data2 in pairs(quest_data.alt) do
              if CollapseQuest(locale, quest_data2) then
                quest_data.alt[hash] = nil
              else
                quest_data2.hash = nil
                WatchQuestItems(quest_data2)
              end
            end
            
            if not next(quest_data.alt, nil) then
              quest_data.alt = nil
              quest_data.hash = nil
            end
          end
          
          if CollapseQuest(locale, quest_data) then
            if quest_data.alt then
              local alt = quest_data.alt
              local hash = next(alt, nil)
              local quest_data2 = alt[hash]
              alt[hash] = nil
              quest_list[quest] = quest_data2
              if next(alt, nil) then
                quest_data2.alt = alt
                quest_data2.hash = hash
              end
              
              delete_level = false
            else
              quest_list[quest] = nil
            end
          else
            WatchQuestItems(quest_data)
            delete_level = false
          end
        end
        
        if delete_level then levels[level] = nil else delete_faction = false end
      end
      if delete_faction then l.quest[faction] = nil end
    end
    
    if l.flight_instructors then for faction, list in pairs(l.flight_instructors) do
      for area, npc in pairs(list) do
        -- Need to remember the flight instructors, for use in routing.
        GetObjective(locale, "monster", npc).quest = true
      end
    end end
    
    for item, quest_list in pairs(quest_item_quests) do
      -- If all the items are similar, then we don't want quest item entries for them,
      -- we want to use the gobal item objective instead.
      if QuestItemsAreSimilar(item, quest_list) then
        quest_item_mass[item] = 0
      end
    end
    
    -- Will go through the items and either delete them, or merge the quest items into them, and then
    -- mark the relevent monsters as being quest objectives.
    if l.objective["item"] then 
      for name, objective in pairs(l.objective["item"]) do
        -- If this is a quest item, mark anything that drops it as being a quest monster.
        local quest_mass = quest_item_mass[name] or 0
        
        if objective.vendor and next(objective.vendor, nil) then
          quest_mass = 0 -- If the item can be bought, then it shouldn't be quest specific.
        end
        
        local item_mass = (objective.pos and PositionListMass(objective.pos) or 0)+
                          (objective.drop and DropListMass(objective.drop) or 0)
        
        if quest_mass > item_mass then
          -- Delete this item, we'll deal with the the quests using the items after.
          l.objective["item"][name] = nil
        else
          if quest_item_quests[name] then
            for i, quest_data in pairs(quest_item_quests[name]) do
              local quest_item = quest_data.item and quest_data.item[name]
              if quest_item then
                if quest_item.drop then
                  if not objective.drop then objective.drop = {} end
                  MergeDropLists(objective.drop, quest_item.drop)
                end
                
                if quest_item.pos then
                  if not objective.pos then objective.pos = {} end
                  MergePositionLists(objective.pos, quest_item.pos)
                end
                
                quest_data.item[name] = nil
                if not next(quest_data.item, nil) then
                  quest_data.item = nil
                  
                  if not quest_data.finish and not quest_data.pos then
                    RemoveQuestByData(quest_data)
                  end
                end
              end
            end
            
            quest_item_quests[name] = nil
            objective.quest = true
          end
          
          if objective.quest then
            if objective.drop then
              TidyDropList(locale, objective.drop)
              for monster, count in pairs(objective.drop) do
                GetObjective(locale, "monster", monster).quest = true
              end
            end
            
            if objective.vendor then
              for i, npc in ipairs(objective.vendor) do
                GetObjective(locale, "monster", npc).quest = true
              end
            end
          end
        end
      end
    end
    
    -- For any quest items that didn't get handled above, we'll clean them up and leave them be.
    for item, quest_list in pairs(quest_item_quests) do
      for _, quest_data in ipairs(quest_list) do
        -- Item should already exist in quest, not going to check.
        local item_data = quest_data.item[item]
        
        local pos_mass = 0
        if item_data.pos then
          pos_mass = PositionListMass(item_data.pos)
          TidyPositionList(item_data.pos)
        end
        
        local drop_mass = 0
        if item_data.drop then
          drop_mass = DropListMass(item_data.drop)
          TidyDropList(locale, item_data.drop)
        end
        
        if drop_mass > pos_mass then
          item_data.pos = nil
          if item_data.drop then
            for monster, count in pairs(item_data.drop) do
              GetObjective(locale, "monster", monster).quest = true
            end
          end
        else
          item_data.drop = nil
        end
        
        if not item_data.pos and not item_data.drop then
          quest_data.item[item] = nil
          if not next(quest_data.item, nil) then
            quest_data.item = nil
            
            if not quest_data.finish and not quest_data.pos then
              RemoveQuestByData(quest_data)
            end
          end
        end
      end
    end
    
    for category, objectives in pairs(l.objective) do
      local delete_category = true
      for name, objective in pairs(objectives) do
        if CollapseObjective(locale, objective) then
          objectives[name] = nil
        else
          delete_category = false
        end
      end
      if delete_category then l.objective[category] = nil end
    end
    
    if l.flight_routes then
      for cont, start_list in pairs(l.flight_routes) do
        local delete_cont = true
        for start, dest_list in pairs(start_list) do
          local delete_start = true
          for dest, hash_list in pairs(dest_list) do
            local delete_dest = true
            for hash, data in pairs(hash_list) do
              if CollapseFlightRoute(data) then
                hash_list[hash] = nil
              else
                delete_dest = false
              end
            end
            if delete_dest then
              dest_list[dest] = nil
            else
              delete_start = false
            end
          end
          if delete_start then
            start_list[start] = nil
          else
            delete_cont = false
          end
        end
        if delete_cont then
          l.flight_routes[cont] = nil
        end
      end
    end
  end
  
  local old_data = StaticData
  StaticData = {}
  return old_data
end

