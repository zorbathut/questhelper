local StaticData = {}

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
    q.finish = {}
    q.hash = hash
    q.alt = {}
  end
  if q.hash ~= hash then
    if q.alt[hash] then
      q = q.alt[hash]
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
    q.finish = {}
    q.alt = {}
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
  local x, y = a[3]-b[3], a[4]-b[4]
  return math.sqrt(x*x+y*y)
end

local function TidyPositionList(list, min_distance)
  min_distance = min_distance or 0.05
  while true do
    if #list == 0 then return end
    local changed = false
    local i = 1
    while i < #list do
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
  for i, j in ipairs(list) do
    j[3] = math.floor(j[3]*10000+0.5)/10000
    j[4] = math.floor(j[4]*10000+0.5)/10000
  end
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
    if count > c then
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
      local nearest, distance = nil, 0
      for i, pos in ipairs(list) do
        if c == pos[1] and z == pos[2] then
          local d = math.sqrt((x-pos[3])*(x-pos[3])+(y-pos[4])*(y-pos[4]))
          if not nearest or d < distance then
            nearest, distance = i, d
          end
        end
      end
      if nearest and distance < 0.05 then
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
    
    local _, _, real_name = string.find(name, "^%["..level..".?%] (.+)$")
    
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
    route_data.real = route_data.real or data.real
  end
end

--[[local function AddZoneTransition(locale, continent, zone1, zone2, pos_list)
  if type(continent) == "number" and
     type(zone1) == "number" and
     type(zone2) == "number" and
     zone1 < zone2 and
     type(pos_list) == "table" then
    -- TODO: Doesn't need to be one per locale, is only numbers. Me thinks.
    
    local l = StaticData[locale]
    if not l then
      l = {}
      StaticData[locale] = l
    end
    local continent_list = l.zone_transition
    if not continent_list then
      continent_list = {}
      l.zone_transition = continent_list
    end
    local zone1_list = continent_list[continent]
    if not zone1_list then
      zone1_list = {}
      continent_list[continent] = zone1_list
    end
    local zone2_list = zone1_list[zone1]
    if not zone2_list then
      zone2_list = {}
      zone1_list[zone1] = zone2_list
    end
    local position_list = zone2_list[zone2]
    if not position_list then
      position_list = {}
      zone2_list[zone2] = position_list
    end
    MergePositionLists(position_list, pos_list)
  end
end]]

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
      if type(objective.faction) == "string" then
        -- TODO: Sanity checking for faction.
        o.faction = objective.faction
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

local function CollapseQuest(quest)
  local name_score = quest.finish and DropListMass(quest.finish) or 0
  local pos_score = quest.pos and PositionListMass(quest.pos) or 0
  
  if name_score > pos_score then
    quest.finish = CollapseDropList(quest.finish)
    quest.pos = nil
  else
    quest.finish = nil
    if quest.pos then
      TidyPositionList(quest.pos)
    end
  end
  
  if quest.item then
    for name, data in pairs(quest.item) do
      local drop_score = data.drop and DropListMass(data.drop) or 0
      local pos_score = data.pos and PositionListMass(data.pos) or 0
      if drop_score > pos_score then
        data.pos = nil
      elseif pos_score > 0 then
        data.drop = nil
        TidyPositionList(data.pos)
      else
        quest.item[name] = nil
      end
    end
    if not next(quest.item, nil) then
      quest.item = nil
    end
  end
  
  if quest.alt then
    for hash, q2 in pairs(quest.alt) do
      if CollapseQuest(q2) then
        quest.alt[hash] = nil
      else
        quest.hash = nil
      end
    end
    if not next(quest.alt, nil) then
      quest.alt = nil
    end
  end
  
  return quest.pos == nil and quest.finish == nil
end

local function CollapseObjective(objective)
  -- if not objective.quest then return true end
  objective.quest = nil
  
  if objective.drop and not next(objective.drop, nil) then objective.drop = nil end
  if objective.pos and not next(objective.pos, nil) then objective.pos = nil end
  if objective.vendor and not next(objective.vendor, nil) then objective.vendor = nil end
  
  if objective.drop then
    -- Don't need both.
    objective.pos = nil
  end
  
  if objective.pos then TidyPositionList(objective.pos) end
  
  return objective.drop == nil and objective.pos == nil
end

function NewData()
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
    
    --if type(data.QuestHelper_ZoneTransition) == "table" then for continent, zone1_list in pairs(data.QuestHelper_ZoneTransition) do
    --  if type(zone1_list) == "table" then for zone1, zone2_list in pairs(zone1_list) do
    --    if type(zone2_list) == "table" then for zone2, pos_list in pairs(zone2_list) do
    --      AddZoneTransition(locale, continent, zone1, zone2, pos_list)
    --    end end
    --  end end
    --end end
  end
end

local function isArray(obj)
  local c = 0
  for i, j in pairs(obj) do c = c + 1 end
  return c == #obj
end

local function isSafeString(obj)
  return type(obj) == "string" and string.len(obj) > 0 and not string.find(obj, "[^%a]")
end

local function Dump(buffer, variable, depth, seen)
  if type(variable) == "string" then
    return buffer:add(("%q"):format(variable))
  elseif type(variable) == "number" then
    return buffer:add(tostring(variable+0))
  elseif type(variable) == "nil" then
    return buffer:add("nil")
  elseif type(variable) == "boolean" then
    return buffer:add(variable and "true" or "false")
  elseif type(variable) == "table" then
    if not seen then
      seen = {}
    elseif seen[variable] then
      -- return "nil --[[ TABLE CONTAINS ITSELF! ]]"
    end
    seen[variable] = true
    if not depth then depth = 1 end
    buffer:add("{")
    
    if isArray(variable) then
      for i, j in ipairs(variable) do
        Dump(buffer, j, depth+1, seen)
        if next(variable,i) then
          buffer:add(","..(type(variable[i+1])=="table"and"\n"..("  "):rep(depth) or " "))
        end
      end
    else
      for i, j in pairs(variable) do
        if isSafeString(i) then
          buffer:add(i.."=")
        else
          buffer:add("[")
          Dump(buffer, i, depth+1, seen)
          buffer:add("]=")
        end
        
        buffer:add((type(j)=="table"and"\n"..("  "):rep(depth+1) or ""))
        
        Dump(buffer, j, depth+1, seen)
        
        if next(variable,i) then
          buffer:add(",\n"..("  "):rep(depth))
        end
      end
    end
    buffer:add("}")
    seen[variable] = nil
  else
    return buffer:add("nil --[[ UNHANDLED TYPE: '"..type(variable).."' ]]")
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
            if quest_data.item then
              for item, data in pairs(quest_data.item) do
                item_data = GetObjective(locale, "item", item)
                item_data.quest = true
                
                local item_score = (item_data.drop and DropListMass(item_data.drop) or 0)+
                                   (item_data.pos and PositionListMass(item_data.pos) or 0)
                
                local quest_score = (data.drop and DropListMass(data.drop) or 0)+
                                    (data.pos and PositionListMass(data.pos) or 0)
                
                if item_score > quest_score then
                  if item_data.drop or data.drop then
                    if data.drop then
                      if not item_data.drop then item_data.drop = {} end
                      MergeDropLists(item_data.drop, data.drop)
                      item_data.pos = nil
                    end
                  elseif item_data.pos or data.pos then
                    if data.pos then
                      if not item_data.pos then item_data.pos = {} end
                      MergePositionLists(item_data.pos, data.pos)
                    end
                  end
                  
                  quest_data.item[item] = nil
                else
                   item_data.drop = nil
                   item_data.pos = nil
                   
                   if data.drop then
                    for monster, count in pairs(data.drop) do
                      GetObjective(locale, "monster", monster).quest = true
                    end
                  end
                end
              end
              
              if not next(quest_data.item, nil) then
                quest_data.item = nil
              end
            end
            delete_level = false
          end
        end
        
        if delete_level then levels[level] = nil else delete_faction = false end
      end
      if delete_faction then l.quest[faction] = nil end
    end
    
    if l.objective["item"] then 
      for name, objective in pairs(l.objective["item"]) do if objective.quest then
        -- If this is a quest item, mark anything that drops it as being a quest monster.
        if objective.drop then
          for monster, count in pairs(objective.drop) do
            GetObjective(locale, "monster", monster).quest = true
          end
        end
        if objective.vendor then
          for i, npc in ipairs(objective.vendor) do
            GetObjective(locale, "monster", npc).quest = true
          end
        end
      end end
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
    
    --if l.zone_transition then for continent, zone1_list in pairs(l.zone_transition) do
    --  for zone1, zone2_list in pairs(zone1_list) do
    --    for zone2, pos_list in pairs(zone2_list) do
    --      TidyPositionList(pos_list, 0.35)
    --    end
    --  end
    --end end
  end
  
  local buffer =
   {
    add=function(self, text)
      table.insert(self, text)
      for i=#self-1, 1, -1 do
        if string.len(self[i]) > string.len(self[i+1]) then break end
        self[i] = self[i]..table.remove(self,i+1)
      end
    end,
    dump = function(self)
      for i=#self-1, 1, -1 do
        self[i] = self[i]..table.remove(self)
      end
      return self[1]
    end
   }
  
  Dump(buffer, StaticData)
  
  print("QuestHelper_StaticData="..buffer:dump())
  print("\n-- END OF FILE --\n")
end
