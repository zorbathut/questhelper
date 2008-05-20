WoWData = {item={},quest={},npc={}} -- The build script will replace this with actual data if it can.

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
    table.remove(average)
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
  
  local x, y = math.floor(a[2]*10000+0.5)/10000-math.floor(b[2]*10000+0.5)/10000,
               math.floor(a[3]*10000+0.5)/10000-math.floor(b[3]*10000+0.5)/10000
  
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


local function TidyContainedList(locale, list)
  local high = 0
  
  for item, count in pairs(list) do
    local item_obj = GetObjective(locale, "item", item)
    if item_obj.opened and item_obj.opened > 0 then
      high = math.max(high, math.max(1, math.floor(count))/math.ceil(item_obj.opened))
    end
  end
  
  for item, count in pairs(list) do
    local item_obj = GetObjective(locale, "item", item)
    count = math.max(1, math.floor(count))
    
    if item_obj.opened and item_obj.opened > 0 and count/math.ceil(item_obj.opened) > high*0.2 then
      list[item] = count
    else
      list[item] = nil
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
        a[2] = (a[2]*a[4]+b[2]*b[4])/(a[4]+b[4])
        a[3] = (a[3]*a[4]+b[3]*b[4])/(a[4]+b[4])
        a[4] = a[4]+b[4]
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
    data[4] = math.pow(data[4], 0.73575888234288) -- Raising it to this number to make huge numbers seem closer together, the positions are probably correct and not some mistake.
    highest = math.max(highest, data[4])
  end
  
  local i = 1 -- Remove anything that doesn't seem very likely.
  while i <= #list do
    if list[i][4] < highest*0.2 then
      table.remove(list, i)
    else
      list[i][4] = math.max(1, math.floor(list[i][4]*100/highest+0.5))
      i = i + 1
    end
  end
  
  for i, j in ipairs(list) do
    j[2] = math.floor(j[2]*10000+0.5)/10000
    j[3] = math.floor(j[3]*10000+0.5)/10000
  end
  
  table.sort(list, function(a, b)
    if a[4] > b[4] then return true end
    if a[4] < b[4] then return false end
    if a[1] < b[1] then return true end
    if a[1] > b[1] then return false end
    if a[2] < b[2] then return true end
    if a[2] > b[2] then return false end
    return a[3] < b[3]
  end)
  
  -- Only use the first 5 positions.
  for i = 6,#list do table.remove(list) end
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
    mass = mass + pos[4]
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
    local index, x, y, w = pos[1], pos[2], pos[3], pos[4]
    if type(index) == "number" and QuestHelper_NameLookup[index] and
       type(w) == "number" and w > 0 then
      local bp, distance = nil, 0
      for i, pos2 in ipairs(list) do
        if index == pos2[1] then
          local d = math.sqrt((x-pos2[2])*(x-pos2[2])+(y-pos2[3])*(y-pos2[3]))
          if not nearest or d < distance then
            bp, distance = pos2, d
          end
        end
      end
      if bp and distance < 0.03 then
        bp[2] = (bp[2]*bp[4]+x*w)/(bp[4]+w)
        bp[3] = (bp[3]*bp[4]+y*w)/(bp[4]+w)
        bp[4] = bp[4]+w
      else
        table.insert(list, {index,x,y,w})
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
  return faction == 1 or faction == 2
end

local function AddQuest(locale, faction, level, name, data)
  if ValidFaction(faction)
     and type(level) == "number" and level >= 1 and level <= 100
     and type(name) == "string" and type(data) == "table" then
    
    local _, _, real_name = string.find(name, "^%["..level.."[^%s]-%]%s?(.+)$")
    
    if real_name then
      -- The Quest Level AddOn mangles level names.
      name = real_name
    end
    
    local q = GetQuest(locale, faction, level, name, type(data.hash) == "number" and data.hash or nil)
    
    if type(data.id) == "number" then
      local wdq = WoWData.quest[data.id]
      if not wdq then
        wdq = {name={},hash={},faction={}}
        WoWData.quest[data.id] = wdq
      end
      wdq.name[locale] = name
      wdq.hash[locale] = data.hash or wdq.hash[locale]
      wdq.level = level
    end
    
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

local function AddFlightRoute(locale, faction, start, destination, hash, value)
  if ValidFaction(faction) and
     type(start) == "string" and
     type(destination) == "string" and
     type(hash) == "number" and
     ((value == true and hash == 0) or (type(value) == "number" and value > 0)) then
    local l = StaticData[locale]
    if not l then
      l = {}
      StaticData[locale] = l
    end
    local faction_list = l.flight_routes
    if not faction_list then
      faction_list = {}
      l.flight_routes = faction_list
    end
    local start_list = faction_list[faction]
    if not start_list then
      start_list = {}
      faction_list[faction] = start_list
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
    if value == true then
      hash_list[hash] = hash_list[hash] or true
    else
      local average = hash_list[hash]
      if type(average) ~= "table" then
        average = CreateAverage()
        hash_list[hash] = average
      end
      AppendToAverage(average, value)
    end
  end
end

local function addVendor(list, npc)
  for _, existing in ipairs(list) do
    if existing == npc then
      return
    end
  end
  
  table.insert(list, npc)
end

local function addVendors(list, to_add)
  if not list then list = {} end
  
  for _, npc in ipairs(to_add) do
    if npc ~= "Unknown" then
      addVendor(list, npc)
    end
  end
  
  return list
end

local function AddObjective(locale, category, name, objective)
  if type(category) == "string"
     and type(name) == "string"
     and name ~= "Unknown"
     and type(objective) == "table" then
    local o = GetObjective(locale, category, name)
    
    if objective.quest == true then o.quest = true end
    
    if type(objective.pos) == "table" then
      if not o.pos then o.pos = {} end
      MergePositionLists(o.pos, objective.pos)
    end
    
    if category == "monster" then
      if type(objective.id) == "number" then
        local wdm = WoWData.npc[objective.id]
        if not wdm then
          wdm = {name={}}
          WoWData.npc[objective.id] = wdm
        end
        wdm.name[locale] = name
      end
      
      if type(objective.looted) == "number" and objective.looted >= 1 then
        o.looted = (o.looted or 0) + objective.looted
      end
      if ValidFaction(objective.faction) then
        o.faction = objective.faction
      end
    elseif category == "item" then
      if type(objective.id) == "number" then
        local wdi = WoWData.item[objective.id]
        if not wdi then
          wdi = {name={}}
          WoWData.item[objective.id] = wdi
        end
        wdi.name[locale] = name
      end
      
      if type(objective.opened) == "number" and objective.opened >= 1 then
        o.opened = (o.opened or 0) + objective.opened
      end
      if type(objective.vendor) == "table" then
        o.vendor = addVendors(o.vendor, objective.vendor)
      end
      if type(objective.drop) == "table" then
        if not o.drop then o.drop = {} end
        for monster, count in pairs(objective.drop) do
          if type(monster) == "string" and monster ~= "Unknown" and type(count) == "number" then
            o.drop[monster] = (o.drop[monster] or 0) + count
          end
        end
      end
      if type(objective.contained) == "table" then
        if not o.contained then o.contained = {} end
        for item, count in pairs(objective.contained) do
          if type(item) == "string" and type(count) == "number" then
            o.contained[item] = (o.contained[item] or 0) + count
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
  
  if quest.finish then
    -- This NPC is for a quest. Need to know them.
    GetObjective(locale, "monster", quest.finish).quest = true
  end
  
  return quest.pos == nil and quest.finish == nil and quest.item == nil
end

local function CollapseObjective(locale, objective)
  if not objective.quest then return true end
  objective.quest = nil
  
  if objective.vendor and not next(objective.vendor, nil) then objective.vendor = nil end
  
  if objective.pos and (PositionListMass(objective.pos) >
       ((objective.drop and DropListMass(objective.drop) or 0) +
        (objective.contained and DropListMass(objective.contained) or 0))) then
    objective.drop = nil
    objective.contained = nil
    
    TidyPositionList(objective.pos)
    
    if not next(objective.pos, nil) then
      objective.pos = nil
    end
  else
    objective.pos = nil
    
    if objective.drop and not next(objective.drop) then objective.drop = nil end
    if objective.contained and not next(objective.contained) then objective.contained = nil end
  end
  
  if objective.looted then
    objective.looted = math.max(1, math.ceil(objective.looted))
  end
  
  if objective.opened then
    objective.opened = math.max(1, math.ceil(objective.opened))
  end
  
  if objective.vendor and next(objective.vendor) then
    table.sort(objective.vendor)
  else
    objective.vendor = nil
  end
  
  return objective.drop == nil and objective.contained == nil and objective.pos == nil and objective.vendor == nil
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
    
    if type(data.QuestHelper_FlightRoutes) == "table" then for faction, start_list in pairs(data.QuestHelper_FlightRoutes) do
      if type(start_list) == "table" then for start, destination_list in pairs(start_list) do
        if type(destination_list) == "table" then for destination, hash_list in pairs(destination_list) do
          if type(hash_list) == "table" then for hash, value in pairs(hash_list) do
            AddFlightRoute(locale, faction, start, destination, hash, value)
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

function handleTranslations()
  for locale, l in pairs(StaticData) do
    if l.objective then
      local item_map = {}
      local monster_map = {}
      local quest_map = {}
      
      for id, data in pairs(WoWData.item) do
        if data.name[locale] then
          item_map[data.name[locale]] = id
        end
      end
      
      for id, data in pairs(WoWData.npc) do
        if data.name[locale] then
          monster_map[data.name[locale]] = id
        end
      end
      
      for id, data in pairs(WoWData.quest) do
        if data.name[locale] then
          quest_map[data.level.."/"..data.hash[locale].."/"..data.name[locale]] = id
        end
      end
      
      local function item2dat(data, item)
        if not item then item = {} end
        
        item.quest = item.quest or data.quest
        
        if data.opened then
          item.opened = (item.opened or 0) + data.opened
          data.opened = nil
        end
        
        if data.pos then
          if not item.pos then
            item.pos = data.pos
          else
            MergePositionLists(item.pos, data.pos)
          end
          
          data.pos = nil
        end
        
        if data.vendor then
          if not item.vendor then
            item.vendor = {}
          end
          
          for i, npc in ipairs(data.vendor) do
            local id = monster_map[npc]
            if id then
              addVendor(item.vendor, id)
            end
          end
        end
        
        if data.drop then
          if not item.drop then
            item.drop = {}
          end
          
          for name, count in pairs(data.drop) do
            local id = monster_map[name]
            if id then
              item.drop[id] = (item.drop[id] or 0) + count
              data.drop[name] = nil
            end
          end
        end
        
        if data.contained then
          if not item.contained then
            item.contained = {}
          end
          
          for name, count in pairs(data.contained) do
            local id = item_map[name]
            if id then
              item.contained[id] = (item.contained[id] or 0) + count
              data.contained[name] = nil
            end
          end
        end
        
        return item
      end
      
      if l.objective.item then for name, data in pairs(l.objective.item) do
        local id = item_map[name]
        if id then
          item2dat(data, WoWData.item[id])
          local item = WoWData.item[id]
        end
      end end
      
      if l.objective.monster then for name, data in pairs(l.objective.monster) do
        local id = monster_map[name]
        if id then
          local npc = WoWData.npc[id]
          
          npc.quest = npc.quest or data.quest
          npc.faction = npc.faction or data.faction
          
          if data.looted then
            npc.looted = (npc.looted or 0) + data.looted
            data.looted = nil
          end
          
          if data.pos then
            if not npc.pos then
              npc.pos = data.pos
            else
              MergePositionLists(npc.pos, data.pos)
            end
            
            data.pos = nil
          end
        end
      end end
      
      local function q2static(faction, name, data)
        local id = quest_map[name]
        if id then
          local quest = WoWData.quest[id]
          quest.faction[faction] = true
          
          print("Copying Quest", faction, name)
          
          if data.finish and next(data.finish) then
            quest.finish = monster_map[CollapseDropList(data.finish)] or quest.finish
          end
          
          if data.item then
            quest.item = quest.item or {}
            
            for name, idata in pairs(data.item) do
              local id = item_map[name]
              if id then
                quest.item[id] = item2dat(idata, quest.item[id])
              end
            end
          end
        end
      end
      
      if l.quest then for faction, fqlist in pairs(l.quest) do
        for level, qlist in pairs(fqlist) do
          for name, qdata in pairs(qlist) do
            if qdata.hash then
              q2static(faction, level.."/"..qdata.hash.."/"..name, qdata)
            end
            
            if qdata.alt then for hash, qdata2 in pairs(qdata.alt) do
              q2static(faction, level.."/"..hash.."/"..name, qdata2)
            end end
          end
        end
      end end
    end
  end
  
  for id, item in pairs(WoWData.item) do
    for locale, name in pairs(item.name) do
      print("Adding item ", locale, name)
      local data = GetObjective(locale, "item", name)
      
      data.quest = data.quest or item.quest
      
      if item.opened then
        data.opened = item.opened
      end
      
      if item.pos then
        data.pos = data.pos or {}
        MergePositionLists(data.pos, item.pos)
      end
      
      if item.vendor then
        data.vendor = data.vendor or {}
        
        for i, id in ipairs(item.vendor) do
          local name = WoWData.npc[id] and WoWData.npc[id].name[locale]
          if name then
            addVendor(data.vendor, name)
          end
        end
      end
      
      if item.drop then
        data.drop = data.drop or {}
        for id, count in pairs(item.drop) do
          local name = WoWData.npc[id] and WoWData.npc[id].name[locale]
          if name then
            data.drop[name] = (data.drop[name] or 0) + count
          end
        end
      end
      
      if item.contained then
        data.contained = data.contained or {}
        for id, count in pairs(item.contained) do
          local name = WoWData.item[id] and WoWData.item[id].name[locale]
          if name then
            data.contained[name] = (data.contained[name] or 0) + count
          end
        end
      end
    end
  end
  
  for id, npc in pairs(WoWData.npc) do
    for locale, name in pairs(npc.name) do
      print("Adding NPC ", locale, name)
      local data = GetObjective(locale, "monster", name)
      
      data.quest = data.quest or npc.quest
      data.faction = data.faction or npc.faction
      
      if npc.looted then
        data.looted = npc.looted
      end
      
      if npc.pos then
        data.pos = data.pos or {}
        MergePositionLists(data.pos, npc.pos)
      end
    end
  end
  
  for id, quest in pairs(WoWData.quest) do
    for faction in pairs(quest.faction) do
      for locale, name in pairs(quest.name) do
        print("Adding Quest ", locale, faction, quest.level, quest.hash[locale], name)
        local data = GetQuest(locale, faction, quest.level, name, quest.hash[locale])
        
        if quest.finish then
          local fname = WoWData.npc[quest.finish] and WoWData.npc[quest.finish].name[locale]
          if fname then
            data.finish = {[fname] = 1}
          end
        end
        
        if quest.item then
          for id, item in pairs(quest.item) do
            local iname = WoWData.item[id] and WoWData.item[id].name[locale]
            if iname then
              local qdata = data
              
              if not qdata.item then qdata.item = {} end
              local data = qdata.item[iname] or {}
              qdata.item[iname] = data
              
              if item.pos then
                data.pos = data.pos or {}
                MergePositionLists(data.pos, item.pos)
              end
              
              if item.drop then
                data.drop = data.drop or {}
                for id, count in pairs(item.drop) do
                  local name = WoWData.npc[id] and WoWData.npc[id].name[locale]
                  if name then
                    data.drop[name] = (data.drop[name] or 0) + count
                  end
                end
              end
              
              if item.contained then
                data.contained = data.contained or {}
                for id, count in pairs(item.contained) do
                  local name = WoWData.item[id] and WoWData.item[id].name[locale]
                  if name then
                    data.contained[name] = (data.contained[name] or 0) + count
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  
  -- TODO: quests.
end

function CompileFinish()
  handleTranslations()
  
  for locale, l in pairs(StaticData) do
    local quest_item_mass = {}
    local quest_item_quests = {}
    
    local function WatchQuestItems(quest)
      if quest.finish then GetObjective(locale, "monster", quest.finish).quest = true end
      
      if quest.item then
        for item, data in pairs(quest.item) do
          quest_item_mass[item] = (quest_item_mass[item] or 0)+
                                  (data.drop and DropListMass(data.drop) or 0)+
                                  (data.contained and DropListMass(data.contained) or 0)+
                                  (data.pos and PositionListMass(data.pos) or 0)
          
          quest_item_quests[item] = quest_item_quests[item] or {}
          table.insert(quest_item_quests[item], quest)
        end
      end
    end
    
    print("Processing quests ", locale)
    
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
    
    print("Processing quest items ", locale)
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
                          (objective.drop and DropListMass(objective.drop) or 0)+
                          (objective.contained and DropListMass(objective.contained) or 0)
        
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
                
                if quest_item.contained then
                  if not objective.contained then objective.contained = {} end
                  MergeDropLists(objective.contained, quest_item.contained)
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
            
            if objective.contained then
              TidyContainedList(locale, objective.contained)
              for item, count in pairs(objective.contained) do
                GetObjective(locale, "item", item).quest = true
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
        
        local contained_mass = 0
        if item_data.contained then
          contained_mass = DropListMass(item_data.contained)
          TidyContainedList(locale, item_data.contained)
        end
        
        if drop_mass+contained_mass > pos_mass then
          item_data.pos = nil
          if item_data.drop then
            for monster, count in pairs(item_data.drop) do
              GetObjective(locale, "monster", monster).quest = true
            end
          end
          
          if item_data.contained then
            for item, count in pairs(item_data.contained) do
              GetObjective(locale, "item", item).quest = true
            end
          end
        else
          item_data.drop = nil
          item_data.contained = nil
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
    
    print("Processing objectives ", locale)
    
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
      for faction, start_list in pairs(l.flight_routes) do
        local delete_faction = true
        for start, dest_list in pairs(start_list) do
          local delete_start = true
          for dest, hash_list in pairs(dest_list) do
            local delete_dest = true
            for hash, value in pairs(hash_list) do
              if type(value) == "table" then
                hash_list[hash] = CollapseAverage(value)
                delete_dest = false
              elseif value == true and hash == 0 then
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
            delete_faction = false
          end
        end
        if delete_faction then
          l.flight_routes[faction] = nil
        end
      end
    end
  end
  
  local old_data = StaticData
  StaticData = {}
  return old_data
end

