function QuestHelper:HashString(text)
  -- Computes an Adler-32 checksum.
  local a, b = 1, 0
  for i=1,string.len(text) do
    a = (a+string.byte(text,i))%65521
    b = (b+a)%65521
  end
  return b*65536+a
end


function QuestHelper:TextOut(text)
  DEFAULT_CHAT_FRAME:AddMessage("|cff65c7ffQuestHelper: |r"..text, 1.0, 0.6, 0.2)
end

function QuestHelper:Error(what)
  DEFAULT_CHAT_FRAME:AddMessage("QuestHelper Error: "..(what or "Unknown").."\n"..debugstack(2), 1,.5,0)
  error("Abort!")
end

function QuestHelper:HighlightText(text)
  return "|cffbbffd6"..text.."|r"
end

function QuestHelper:PlayerPosition()
  local nc, nz, nx, ny = self.Astrolabe:GetCurrentPlayerPosition()
  
  if nz == 0 then
    -- Not sure why this is, but whatever.
    SetMapToCurrentZone()
    nz = GetCurrentMapZone()
    if nz ~= 0 then
      nx, ny = self.Astrolabe:TranslateWorldMapPosition(nc, 0, nx, ny, nc, nz)
    end
  end
  
  self.c, self.z, self.x, self.y = nc or self.c, nz or self.z, nx or self.x, ny or self.y
  
  return self.c, self.z, self.x, self.y
end

function QuestHelper:UnitPosition(unit)
  local c, z, x, y = self.Astrolabe:GetUnitPosition(unit)
  if c then
    if z == 0 then
      SetMapToCurrentZone()
      z = GetCurrentMapZone()
      if z ~= 0 then
        x, y = self.Astrolabe:TranslateWorldMapPosition(nc, 0, x, y, c, z)
      end
    end
    return c, z, x, y
  else
    return self:PlayerPosition()
  end
end

function QuestHelper:LocationString(c, z, x, y)
  return ("[|cffffffff%d,%d,%.3f,%.3f|r]"):format(c, z, x, y)
end

function QuestHelper:Distance(c1, z1, x1, y1, c2, z2, x2, y2)
 --[[
  local wrong = false
  if type(c1) ~= "number" then c1 = type(c1) wrong = true end
  if type(z1) ~= "number" then z1 = type(z1) wrong = true end
  if type(x1) ~= "number" then x1 = type(x1) wrong = true end
  if type(y1) ~= "number" then y1 = type(y1) wrong = true end
  if type(c2) ~= "number" then c2 = type(c2) wrong = true end
  if type(z2) ~= "number" then z2 = type(z2) wrong = true end
  if type(x2) ~= "number" then x2 = type(x2) wrong = true end
  if type(y2) ~= "number" then y2 = type(y2) wrong = true end
  if wrong then
    self:Error("Invalid distance: ["..c1..", "..z1..", "..x1..", "..y1.."]:["..c2..", "..z2..", "..x2..", "..y2.."]")
    return 42
  end
  local d = self.Astrolabe:ComputeDistance(c1, z1, x1, y1, c2, z2, x2, y2)
  if not d then
    self:Error("Can't compute distance: ["..c1..", "..z1..", "..x1..", "..y1.."]:["..c2..", "..z2..", "..x2..", "..y2.."]")
    return 42
  end
  return d
  ]]
  
  -- TODO: Deal with extra-zone travel.
  return self.Astrolabe:ComputeDistance(c1, z1, x1, y1, c2, z2, x2, y2) or 10000
end

function QuestHelper:AppendPosition(list, c, z, x, y, w)
  if not c or (c == 0 and z == 0) or x == 0 or y == 0 then
    return -- This isn't a real position.
  end
  
  local closest, distance = nil, 0
  w = w or 1
  
  for i, p in ipairs(list) do
    if c == p[1] and z == p[2] then
      local d = self.Astrolabe:ComputeDistance(c, z, x, y, p[1], p[2], p[3], p[4])
      if not closest or d < distance then
        closest, distance = i, d
      end
    end
  end
  if closest and distance < 200.0 then
    local p = list[closest]
    p[3] = (p[3]*p[5]+x*w)/(p[5]+w)
    p[4] = (p[4]*p[5]+y*w)/(p[5]+w)
    p[5] = p[5]+w
  else
    table.insert(list, {c, z, x, y, w})
  end
  
  return list
end

function QuestHelper:PositionListDistance(list, c, z, x, y)
  local closest, distance = nil, 0
  for i, p in ipairs(list) do
    local d = self:Distance(c, z, x, y, p[1], p[2], p[3], p[4])
    if not closest or d < distance then
      closest, distance = p, d
    end
  end
  if closest then
    return distance, closest[1], closest[2], closest[3], closest[4]
  end
end

function QuestHelper:PositionListDistance2(list, c1, z1, x1, y1, c2, z2, x2, y2)
  local closest, distance = nil, 0
  for i, p in ipairs(list) do
    local d = self:Distance(c1, z1, x1, y1, p[1], p[2], p[3], p[4])+
              self:Distance(c2, z2, x2, y2, p[1], p[2], p[3], p[4])
    if not closest or d < distance then
      closest, distance = p, d
    end
  end
  if closest then
    return distance, closest[1], closest[2], closest[3], closest[4]
  end
end

function QuestHelper:MergePositions(list1, list2)
  for i, p in ipairs(list2) do
    self:AppendPosition(list1, unpack(p))
  end
end

function QuestHelper:MergeDrops(list1, list2)
  for element, count in pairs(list2) do
    list1[element] = (list1[element] or 0) + count
  end
end
