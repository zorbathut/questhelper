local function FindStaticQuest(faction, level, name, hash)
  local data = QuestHelper_StaticData[QuestHelper.locale]
  data = data and data.quest
  data = data and data[faction]
  data = data and data[level]
  data = data and data[name]
  if data and data.hash and data.hash ~= hash then
    data = data.alt and data.alt[hash]
  end
  return data
end

local function FindStaticObjective(cat, name)
  local data = QuestHelper_StaticData[QuestHelper.locale]
  data = data and data.objective
  data = data and data[cat]
  return data and data[name]
end

local function ListUpdated(list, static, compare, weight)
  if not list then return false end
  if not static then return true end
  
  local high = 0
  
  for _, b in ipairs(static) do
    high = math.max(high, weight(b))
  end
  
  for _, a in ipairs(list) do
    local found = false
    
    for _, b in ipairs(static) do
      if weight(a) < high*0.2 or compare(a, b) then
        found = true
        break
      end
    end
    
    if not found then return true end
  end
  return false
end

local function PositionWeight(a)
  return a[5]
end

local function PositionCompare(a, b)
  return a[1] == b[1] and a[2] == b[2] and
         (a[3]-b[3])*(a[3]-b[3])+(a[4]-b[4])*(a[4]-b[4]) < 0.05*0.05
end

local function VendorCompare(a, b)
  return a == b
end

local function VendorWeight(a)
  return 1
end

local function PositionListUpdated(list, static)
  return ListUpdated(list, static, PositionCompare, PositionWeight)
end

local function VendorListUpdated(list, static)
  return ListUpdated(list, static, VendorCompare, VendorWeight)
end

local function DropListUpdated(list, static)
  if not list then return false end
  if not static then return next(list, nil) ~= nil end
  local high = 0
  
  for name in pairs(list) do
    local monster_obj = FindStaticObjective("monster", name)
    if monster_obj and monster_obj.looted and monster_obj.looted > 0 then 
      high = math.max(high, (static[name] or 0)/monster_obj.looted)
    end
  end
  
  for name, v in pairs(list) do
    local monster_obj1 = QuestHelper:GetObjective("monster", name)
    local monster_obj2 = FindStaticObjective("monster", name)
    
    local looted = math.ceil((monster_obj1.looted or 0)+((monster_obj2 and monster_obj2.looted) or 0))
    if looted > 0 then
      v = math.max(1, math.floor(v))/looted
      if v > high*0.2 and not static[name] then return true end
    end
  end
  return false
end

local function DropListMass(list)
  if not list then return 0 end
  local mass = 0
  for item, count in pairs(list) do
    mass = mass + count
  end
  return mass
end

local function PositionListMass(list)
  if not list then return 0 end
  local mass = 0
  for _, pos in ipairs(list) do
    mass = mass + pos[5]
  end
  return mass
end

local function CompareStaticQuest(info, faction, level, name, hash, data, verbose)
  local static = FindStaticQuest(faction, level, name, hash)
  
  if not static then
    if data.finish or data.pos then
      if verbose then QuestHelper:TextOut("Quest "..QuestHelper:HighlightText(name).." was missing.") end
      info.new.quest = (info.new.quest or 0) + 1
    end
    return
  end
  
  local updated = false
  
  if data.finish and data.finish ~= static.finish then
    if verbose then QuestHelper:TextOut("Quest "..QuestHelper:HighlightText(name).." was missing finish NPC "..QuestHelper:HighlightText(data.finish)..".") end
    updated = true
  elseif not static.finish and PositionListUpdated(data.pos, static.pos) then
    if verbose then QuestHelper:TextOut("Quest "..QuestHelper:HighlightText(name).." was missing finish location.") end
    updated = true
  elseif data.item then
    for item_name, item in pairs(data.item) do
      local static_item = (static.item and static.item[item_name]) or FindStaticObjective("item", item_name)
      
      if not static_item then
        if verbose then QuestHelper:TextOut("Quest "..QuestHelper:HighlightText(name).." was missing item "..QuestHelper:HighlightText(item_name)..".") end
        updated = true
        break
      elseif item.drop then
        if DropListUpdated(item.drop, static_item.drop) then
          if DropListMass(item.drop) > PositionListMass(static_item.pos) then
            if verbose then QuestHelper:TextOut("Quest "..QuestHelper:HighlightText(name).." was missing drop for item "..QuestHelper:HighlightText(item_name)..".") end
            updated = true
            break
          end
        end
      elseif item.pos and not static_item.drop and PositionListUpdated(item.pos, static_item.pos) then
        if verbose then QuestHelper:TextOut("Quest "..QuestHelper:HighlightText(name).." was missing position for item "..QuestHelper:HighlightText(item_name)..".") end
        updated = true
        break
      end
    end
  end
  
  if updated then 
    info.update.quest = (info.update.quest or 0)+1
  end
end

local function CompareStaticObjective(info, cat, name, data, verbose)
  if info.quest then
    local static = FindStaticObjective(cat, name)
    if not static then
      if data.pos or data.drop or data.vendor then
        if verbose then QuestHelper:TextOut(string.gsub(cat, "^(.)", string.upper).." "..QuestHelper:HighlightText(name).." was missing.") end
        info.new[cat.." objective"] = (info.new[cat.." objective"] or 0)+1
      end
      return
    end
    
    local updated = false
    
    if data.vendor then
      updated = VendorListUpdated(data.vendor, static.vendor)
      if updated and verbose then QuestHelper:TextOut(string.gsub(cat, "^(.)", string.upper).." "..QuestHelper:HighlightText(name).." was missing vendor.") end
    elseif data.drop and not static.vendor then
      updated = DropListUpdated(data.drop, static.drop) and DropListMass(data.drop) > PositionListMass(static.pos)
      if updated and verbose then QuestHelper:TextOut(string.gsub(cat, "^(.)", string.upper).." "..QuestHelper:HighlightText(name).." was missing monster drop.") end
    elseif data.pos and not static.vendor and not static.drop then
      if updated and verbose then QuestHelper:TextOut(Qstring.gsub(cat, "^(.)", string.upper).." "..QuestHelper:HighlightText(name).." was missing position.") end
      updated = PositionListUpdated(data.pos, static.pos)
    end
    
    if updated then
      info.update[cat.." objective"] = (info.update[cat.." objective"] or 0)+1
    end
  end
end

function QuestHelper:Nag(verbose)
  if verbose == "verbose" then
    verbose = true
  else
    if verbose and verbose ~= "" then
      self:TextOut("Expect no arguments or 'verbose'.")
    end
    verbose = false
  end
  
  local info =
    {
     new = {},
     update = {}
    }
  
  for faction, level_list in pairs(QuestHelper_Quests) do
    for level, name_list in pairs(level_list) do
      for name, data in pairs(name_list) do
        CompareStaticQuest(info, faction, level, name, data.hash, data, verbose)
        if data.alt then
          for hash, data in pairs(data.alt) do
            CompareStaticQuest(info, faction, level, name, hash, data, verbose)
          end
        end
      end
    end
  end
  
  for cat, name_list in pairs(QuestHelper_Objectives) do
    for name, obj in pairs(name_list) do
      CompareStaticObjective(info, cat, name, obj, verbose)
    end
  end
  
  for faction, location_list in pairs(QuestHelper_FlightInstructors) do
    for location, npc in pairs(location_list) do
      local data = QuestHelper_StaticData[self.locale]
      data = data and data.flight_instructors
      data = data and data[faction]
      data = data and data[location]
      
      if not data or data ~= npc then
        if verbose then self:TextOut(QuestHelper:HighlightText(faction).." flight master "..QuestHelper:HighlightText(npc).." was missing.") end
        info.new["flight master"] = (info.new["flight master"] or 0)+1
      end
    end
  end
  
  for cont, start_list in pairs(QuestHelper_FlightRoutes) do
    for start, dest_list in pairs(start_list) do
      for dest, hash_list in pairs(dest_list) do
        for hash, data in pairs(hash_list) do
          if data.real then
            local static = QuestHelper_StaticData[self.locale]
            static = static and static.flight_routes
            static = static and static[cont]
            static = static and static[start]
            static = static and static[dest]
            static = static and static[hash]
            static = static and static.real
            if not static then
              if verbose then self:TextOut("Flight time from "..QuestHelper:HighlightText((select(3, string.find(start, "^(.*),")) or start)).." to "..QuestHelper:HighlightText((select(3, string.find(dest, "^(.*),")) or dest)).." was missing.") end
              info.new["flight route"] = (info.new["flight route"] or 0)+1
            end
          end
        end
      end
    end
  end
  
  local total = 0
  
  for what, count in pairs(info.new) do
    total = total + count
    local count2 = info.update[what]
    if count2 then
      total = total + count2
      self:TextOut("You have information on "..self:HighlightText(count).." new and "..self:HighlightText(count2).." updated "..self:HighlightText(what.."s")..".")
    else
      self:TextOut("You have new information on "..self:HighlightText(count.." "..what..(count==1 and "" or "s"))..".")
    end
  end
  
  for what, count in pairs(info.update) do
    if not info.new[what] then
      total = total + count
      self:TextOut("You have additional information on "..self:HighlightText(count.." "..what..(count==1 and "" or "s"))..".")
    end
  end
  
  if total == 0 then
    self:TextOut("You don't have any information not already in the static database.")
  else
    self:TextOut("You might consider sharing your data so that others may benefit.")
  end
end
