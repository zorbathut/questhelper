local function ListUpdated(list, static, compare)
  if not list then return false end
  if not static then return true end
  for _, a in ipairs(list) do
    local found = false
    
    for _, b in ipairs(static) do
      if compare(a, b) then
        found = true
        break
      end
    end
    
    if not found then return true end
  end
  return false
end

local function PositionCompare(a, b)
  return a[1] == b[1] and a[2] == b[2] and
         QuestHelper.Astrolabe:ComputeDistance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4]) < 450
end

local function VendorCompare(a, b)
  return a == b
end

local function PositionListUpdated(list, static)
  return ListUpdated(list, static, PositionCompare)
end

local function VendorListUpdated(list, static)
  return ListUpdated(list, static, VendorCompare)
end

local function DropListUpdated(list, static)
  if not list then return false end
  if not static then return true end
  for name in pairs(list) do
    if not static[name] then return true end
  end
  return false
end

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

local function CompareStaticQuest(info, faction, level, name, hash, data)
  local static = FindStaticQuest(faction, level, name, hash)
  
  if not static then
    if data.finish or data.pos then
      info.new.quest = (info.new.quest or 0) + 1
    end
    return
  end
  
  local updated = false
  
  if data.finish and data.finish ~= static.finish then
    updated = true
  elseif not static.finish and PositionListUpdated(data.pos, static.pos) then
    updated = true
  elseif data.item then
    if static.item then
      for name, item in pairs(data.item) do
        local static_item = static.item[name]
        
        if not static_item then
          updated = true
        elseif item.drop then
          updated = DropListUpdated(item.drop, static_item.drop)
        elseif item.pos and not static_item.drop then
          updated = PositionListUpdated(item.pos, static_item.pos)
        end
      end
    else
      for name, item in pairs(data.item) do
        if not FindStaticObjective("item", name) then
          updated = true
          break
        end
      end
    end
  end
  
  if updated then 
    info.update.quest = (info.update.quest or 0)+1
  end
end

local function CompareStaticObjective(info, cat, name, data)
  if info.quest then
    local static = FindStaticObjective(cat, name)
    if not static then
      if data.pos or data.drop or data.vendor then
        info.new[cat.." objective"] = (info.new[cat.." objective"] or 0)+1
      end
      return
    end
    
    local updated = false
    
    if data.vendor then
      updated = VendorListUpdated(data.vendor, static.vendor)
    elseif data.drop and not static.vendor then
      updated = DropListUpdated(data.drop, static.drop)
    elseif data.pos and not static.vendor and not static.drop then
      updated = PositionListUpdated(data.pos, static.pos)
    end
    
    if updated then
      info.update[cat.." objective"] = (info.update[cat.." objective"] or 0)+1
    end
  end
end

function QuestHelper:Nag()
  local info =
    {
     new = {},
     update = {}
    }
  
  for faction, level_list in pairs(QuestHelper_Quests) do
    for level, name_list in pairs(level_list) do
      for name, data in pairs(name_list) do
        CompareStaticQuest(info, faction, level, name, data.hash, data)
        if data.alt then
          for hash, data in pairs(data.alt) do
            CompareStaticQuest(info, faction, level, name, hash, data)
          end
        end
      end
    end
  end
  
  for cat, name_list in pairs(QuestHelper_Objectives) do
    for name, obj in pairs(name_list) do
      CompareStaticObjective(info, cat, name, obj)
    end
  end
  
  for faction, location_list in pairs(QuestHelper_FlightInstructors) do
    for location, npc in pairs(location_list) do
      local data = QuestHelper_StaticData[self.locale]
      data = data and data.flight_instructors
      data = data and data[faction]
      data = data and data[location]
      
      if not data or data ~= npc then
        info.new["flight instructor"] = (info.new["flight instructor"] or 0)+1
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
