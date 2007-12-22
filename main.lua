if GetLocale() ~= "enUS" then
  DEFAULT_CHAT_FRAME:AddMessage("|cffffcc77QuestHelper: |rI'm not ready to support your locale yet. Sorry!", 1.0, 0.6, 0.2)
  return
end

local frame = CreateFrame("Frame", "QuestHelper", UIParent)
local Astrolabe = DongleStub("Astrolabe-0.4")

QuestHelper_SaveVersion = 2
QuestHelper_Locale = GetLocale()
QuestHelper_Quests = {}
QuestHelper_Objectives = {}

local QuestHelper_QuestObjects = {}
local QuestHelper_ObjectiveObjects = {}

local tooltip = CreateFrame("GameTooltip", "QuestHelperTooltop", nil, "GameTooltipTemplate")

frame.quest_log = {}
frame.to_add = {}
frame.to_remove = {}
frame.route = {}
frame.route_size = 0
frame.waypoint_icons = {}
frame.defered_quest_scan = false

local ofs = 0.000723339 * (GetScreenHeight()/GetScreenWidth() + 1/3) * 70.4;
local radius = ofs / 1.166666666666667;

local function TextOut(text)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffcc77QuestHelper: |r"..text, 1.0, 0.6, 0.2)
end

local function DebugPosition(c, z, x, y)
  local wrong = false
  if type(c) ~= "number" then c = "?" wrong = true end
  if type(z) ~= "number" then z = "?" wrong = true end
  if type(x) ~= "number" then x = "?" wrong = true end
  if type(y) ~= "number" then y = "?" wrong = true end
  if wrong then
    TextOut("[|cffffffff"..c..", "..z..", "..x..", "..y"|r] isn't a valid position.")
    TextOut(debugstack())
  end
  return "[|cffffffff"..c..", "..z..", "..x..", "..y.."]|r"
end

local function DebugDistance(c1, z1, x1, y1, c2, z2, x2, y2)
  local wrong = false
  if type(c1) ~= "number" then c1 = "?" wrong = true end
  if type(z1) ~= "number" then z1 = "?" wrong = true end
  if type(x1) ~= "number" then x1 = "?" wrong = true end
  if type(y1) ~= "number" then y1 = "?" wrong = true end
  if type(c2) ~= "number" then c2 = "?" wrong = true end
  if type(z2) ~= "number" then z2 = "?" wrong = true end
  if type(x2) ~= "number" then x2 = "?" wrong = true end
  if type(y2) ~= "number" then y2 = "?" wrong = true end
  
  if wrong then
    TextOut("Unknown distance [|cffffffff"..c1..", "..z1..", "..x1..", "..y1.."|r] : [|cffffffff"..c2..", "..z2..", "..x2..", "..y2.."|r].")
    TextOut(debugstack())
    return 0
  end
  
  local d = Astrolabe:ComputeDistance(c1, z1, x1, y1, c2, z2, x2, y2)
  if not d then
    TextOut("Couldn't calculate [|cffffffff"..c1..", "..z1..", "..x1..", "..y1.."|r] : [|cffffffff"..c2..", "..z2..", "..x2..", "..y2.."|r].")
    TextOut(debugstack())
    return 0
  end
  
  return d
end

local GetObjectiveReason = nil -- I'll define this later.

function frame:CalcWorldMapPosition(findex)
  if findex < 0 or findex > self.route_size then
    return nil
  end
  
  local index = math.floor(findex)
  local r = findex-index
  
  local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
  
  local x1, y1, x2, y2
  
  if index == 0 then
    x1, y1 = Astrolabe:TranslateWorldMapPosition(self.c, self.z, self.x, self.y, c, z)
  else
    local p = self.route[index].pos
    x1, y1 = Astrolabe:TranslateWorldMapPosition(p[1], p[2], p[3], p[4], c, z)
  end
  
  if r < 0.000001 then
    return x1, y1
  end
  
  local p = self.route[index+1].pos
  x2, y2 = Astrolabe:TranslateWorldMapPosition(p[1], p[2], p[3], p[4], c, z)
  
  if x1 and x2 then
    return x1*(1-r)+x2*r, y1*(1-r)+y2*r
  end
end

local function CreateWorldMapWalker(frame)
  local walker = CreateFrame("Button", nil, WorldMapButton)
  walker:SetWidth(0)
  walker:SetHeight(0)
  walker:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 0, 0)
  walker:Show()
  
  walker.phase = 0.0
  walker.dots = {}
  for i = 1,10 do
    local dot = walker:CreateTexture()
    dot:SetTexture("Interface\\Minimap\\ObjectIcons")
    dot:SetTexCoord(0.280, 0.35, 0.09, 0.36)
    dot:SetVertexColor(0,0,0)
    dot:SetWidth(4)
    dot:SetHeight(4)
    walker.dots[i] = dot
  end
  
  function walker:OnUpdate(elapsed)
    self.phase = self.phase + elapsed * 0.3
    while self.phase > 1 do self.phase = self.phase - 1 end
    
    local w, h = WorldMapDetailFrame:GetWidth(), -WorldMapDetailFrame:GetHeight()
    
    while #self.dots < frame.route_size do
      local dot = walker:CreateTexture()
      dot:SetTexture("Interface\\Minimap\\ObjectIcons")
      dot:SetTexCoord(0.280, 0.35, 0.09, 0.36)
      dot:SetVertexColor(0,0,0)
      dot:SetWidth(4)
      dot:SetHeight(4)
      table.insert(self.dots, dot)
    end
    
    for i = 1,frame.route_size do
      local dot = self.dots[i]
      local x, y = frame:CalcWorldMapPosition(i+self.phase-1)
      if x and x > 0 and y > 0 and x < 1 and y < 1 then 
          dot:ClearAllPoints()
          dot:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", x*w, y*h)
          dot:Show()
      else
        dot:Hide()
      end
    end
    
    for i = frame.route_size+1,#self.dots do
      self.dots[i]:Hide()
    end
  end
  
  walker:SetScript("OnUpdate", walker.OnUpdate)
end

frame.map_walker = CreateWorldMapWalker(frame)

local function CreateWorldMapDodad(objective, index)
  local icon = CreateFrame("Button", nil, WorldMapButton)
  icon:SetHeight(12)
  icon:SetWidth(12)
  
  icon.dot = icon:CreateTexture()
  icon.dot:SetTexture("Interface\\Minimap\\ObjectIcons")
  icon.dot:SetAllPoints()
  icon.dot:Show()
  
  icon:SetFrameStrata("FULLSCREEN_DIALOG")
  
  function icon:SetObjective(objective, i)
    self.objective = objective
    self.index = i
    
    if i == 1 then
      self.dot:SetTexCoord(0.404, 0.475, 0.12, 0.375)
    else
      self.dot:SetTexCoord(0.280, 0.35, 0.09, 0.36)
    end
    
    Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self, unpack(objective.pos))
  end
  
  function icon:OnEnter()
    if not tooltip:IsShown() then
      tooltip:Show()
      tooltip:SetOwner(self, "ANCHOR_CURSOR")
      tooltip:SetText("|cffffffff("..self.index..")|r "..GetObjectiveReason(self.objective))
      self.own_tooltip = true
    end
  end
  
  function icon:OnLeave()
    if self.own_tooltip then
      tooltip:Hide()
      self.own_tooltip = false
    end
  end
  
  function icon:OnEvent(event)
    Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self, unpack(self.objective.pos))
  end
  
  icon:SetScript("OnEnter", icon.OnEnter)
  icon:SetScript("OnLeave", icon.OnLeave)
  icon:SetScript("OnEvent", icon.OnEvent)
  icon:RegisterEvent("WORLD_MAP_UPDATE")
  
  icon:SetObjective(objective, index)
  return icon
end

local function CreateMipmapDodad()
  local icon = CreateFrame("Button", nil, Minimap)
  icon:SetHeight(10)
  icon:SetWidth(10)
  
  icon.dot = icon:CreateTexture()
  icon.dot:SetTexture("Interface\\Minimap\\ObjectIcons")
  --icon.dot:SetTexCoord(0.375, 0.5, 0.0, 0.5)
  icon.dot:SetTexCoord(0.404, 0.471, 0.12, 0.375)
  
  -- If you're reading this and you know why this doesn't work, please tell me.
  --icon.dot:SetTexture("Interface\\AddOns\\QuestHelper\\dot.tga")
  --icon.dot:SetTexCoord(0, 1, 0, 1)
  
  icon.dot:SetAllPoints()
  
  icon.arrow = CreateFrame("Model", nil, icon)
  icon.arrow:SetHeight(140.8)
  icon.arrow:SetWidth(140.8)
  icon.arrow:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
  icon.arrow:SetModel("Interface\\Minimap\\Rotating-MinimapArrow.mdx")
  
  icon.phase = 0
  
  icon.arrow.parent = icon
  icon.arrow:SetScript("OnUpdate", MinimapIcon_UpdateArrow)
  icon.arrow:Hide()
  
  function icon:OnUpdate(elapsed)
    local edge = Astrolabe:IsIconOnEdge(self)
    local dot = self.dot:IsShown()
     
    if edge and dot then
      self.arrow:Show()
      self.dot:Hide()
    elseif not edge and not dot then
      self.dot:Show()
      self.arrow:Hide()
    end
    
    if edge then
      local angle = Astrolabe:GetDirectionToIcon(self)
      if GetCVar("rotateMinimap") == "1" then
        angle = angle + MiniMapCompassRing:GetFacing()
      end
      
      self.arrow:SetFacing(angle)
      self.arrow:SetPosition(ofs * (137 / 140) - radius * math.sin(angle),
                             ofs               + radius * math.cos(angle), 0);
      
      if self.phase > 6.283185307179586476925 then
        self.phase = self.phase-6.283185307179586476925+elapsed*3.5
      else
        self.phase = self.phase+elapsed*3.5
      end
      self.arrow:SetModelScale(0.600000023841879+0.1*math.sin(self.phase))
    end
  end
  
  function icon:SetObjective(objective)
    self.objective = objective
    Astrolabe:PlaceIconOnMinimap(self, unpack(objective.pos))
  end
  
  function icon:OnEnter()
    if not tooltip:IsShown() then
      tooltip:Show()
      tooltip:SetOwner(self, "ANCHOR_CURSOR")
      tooltip:SetText(GetObjectiveReason(self.objective))
      self.own_tooltip = true
    end
  end
  
  function icon:OnLeave()
    if self.own_tooltip then
      tooltip:Hide()
      self.own_tooltip = false
    end
  end
  
  function icon:SetTooltip(message)
    self.message = message
    if self.tooltip:IsShown() then
      self.tooltip:SetText(self.message)
    end
  end
  
  icon:SetScript("OnUpdate", icon.OnUpdate)
  icon:SetScript("OnEnter", icon.OnEnter)
  icon:SetScript("OnLeave", icon.OnLeave)
  
  return icon
end

frame.minimap_dodad = CreateMipmapDodad()

frame.c, frame.z, frame.x, frame.y = 0, 0, 0, 0
function frame:GetBestKnownPlayerPosition()
  local nc, nz, nx, ny = Astrolabe:GetCurrentPlayerPosition()
  if not nz or nz == 0 then
    SetMapToCurrentZone()
    nz = GetCurrentMapZone()
    if nz ~= 0 then
      nx, ny = Astrolabe:TranslateWorldMapPosition(nc, 0, nx, ny, nc, nz)
    end
  end
  self.c, self.z, self.x, self.y = nc or self.c, nz or self.z, nx or self.x, ny or self.y
  return self.c, self.z, self.x, self.y
end

function frame:GetBestKnownUnitPosition(unit)
  if GetCurrentMapZone() == 0 then SetMapToCurrentZone() end
  local c, z, x, y = Astrolabe:GetUnitPosition(unit)
  if c then
    if z == 0 then
      SetMapToCurrentZone()
      z = GetCurrentMapZone()
      if z ~= 0 then
        x, y = Astrolabe:TranslateWorldMapPosition(nc, 0, x, y, c, z)
      end
    end
    return c, z, x, y
  else
    return self:GetBestKnownPlayerPosition()
  end
end

local function HashString(text)
  -- This the Adler-32 checksum.
  local a, b = 1, 0
  for i=1,string.len(text) do
    a = (a+string.byte(text,i))%65521
    b = (b+a)%65521
  end
  return b*65536+a
end

local function NewEmptyObjectiveObject()
  return {before={},after={},pos={0,0,0,0},sop={0,0,0,0}}
end

local function GetQuestObject(name, level, hash)
  local bracket = QuestHelper_QuestObjects[level]
  if not bracket then
    bracket = {}
    QuestHelper_QuestObjects[level] = bracket
  end
  local bracker2 = bracket[name]
  if not bracket2 then
    bracket2 = {}
    bracket[name] = bracket2
  end
  
  local quest_object = bracket2[hash]
  if not quest_object then
    quest_object = NewEmptyObjectiveObject()
    bracket2[hash] = quest_object
    
    local faction = UnitFactionGroup("player")
    local fbracket = QuestHelper_Quests[faction]
    if not fbracket then
      fbracket = {}
      QuestHelper_Quests[faction] = fbracket
    end
    bracket = fbracket[level]
    if not bracket then
      bracket = {}
      fbracket[level] = bracket
    end
    quest_object.o = bracket[name]
    if not quest_object.o then
      quest_object.o = {hash=hash}
      bracket[name] = quest_object.o
    end
    local l = QuestHelper_StaticData[GetLocale()]
    if l then
      fbracket = l.quest[faction]
      if fbracket then
        bracket = fbracket[level]
        if bracket then
          quest_object.fb = bracket[name]
        end
      end
    end
    if not quest_object.fb then
      quest_object.fb = {}
    end
    
    if quest_object.o.hash and quest_object.o.hash ~= hash then
      if not quest_object.o.alt then quest_object.o.alt = {} end
      local real_quest_data = quest_object.o.alt[hash]
      if not real_quest_data then
        real_quest_data = {hash=hash}
        quest_object.o.alt[hash] = real_quest_data
      end
      quest_object.o = real_quest_data
    elseif not quest_object.o.hash then
      -- Not setting the hash now, as we might not actually have the correct quest loaded.
      -- When we can verify our data is correct, we'll assign a value.
      quest_object.need_hash = true
    end
    
    if quest_object.fb.hash and quest_object.fb.hash ~= hash then
      quest_object.fb = quest_object.fb.alt and quest_object.fb.alt[hash]
      if not quest_object.fb then
        quest_object.fb = {}
      end
    end
    
    -- TODO: If we have some other source of information (like LightHeaded) add its data to quest_object.fb
    
  end
  
  return quest_object
end

local function GetObjectiveObject(category, objective)
  local objective_list = QuestHelper_ObjectiveObjects[category]
  if not objective_list then
    objective_list = {}
    QuestHelper_ObjectiveObjects[category] = objective_list
  end
  
  local objective_object = objective_list[objective]
  if not objective_object then
    objective_object = NewEmptyObjectiveObject()
    objective_list[objective] = objective_object
    objective_list = QuestHelper_Objectives[category]
    if not objective_list then
      objective_list = {}
      QuestHelper_Objectives[category] = objective_list
    end
    objective_object.o = objective_list[objective]
    if not objective_object.o then
      objective_object.o = {}
      objective_list[objective] = objective_object.o
    end
    local l = QuestHelper_StaticData[GetLocale()]
    if l then
      objective_list = l.objective[category]
      if objective_list then
        objective_object.fb = objective_list[objective]
      end
    end
    if not objective_object.fb then
      objective_object.fb = {}
    end
    
    -- TODO: If we have some other source of information (like LightHeaded) add its data to objective_object.fb
    
  end
  
  return objective_object
end

local function ObjectiveIsKnown(objective)
  for i, j in pairs(objective.after) do
    if i.watched and not ObjectiveIsKnown(i) then -- Need to know how to do everything before this objective.
      return false
    end
  end
  
  -- If returns true if we know where to go to complete the objective.
  if (objective.o.finish and ObjectiveIsKnown(GetObjectiveObject("monster", objective.o.finish))) or
     (objective.fb.finish and objective.fb.finish ~= objective.o.finish
      and ObjectiveIsKnown(GetObjectiveObject("monster", objective.fb.finish))) or
     (objective.o.pos and next(objective.o.pos, nil)) or
     (objective.fb.pos and next(objective.fb.pos, nil)) then
    return true
  end
  
  if objective.o.drop then
    for m, count in pairs(objective.o.drop) do
      if ObjectiveIsKnown(GetObjectiveObject("monster", m)) then
        return true
      end
    end
  end
  
  if objective.fb.drop then
    for m, count in pairs(objective.fb.drop) do
      if ObjectiveIsKnown(GetObjectiveObject("monster", m)) then
        return true
      end
    end
  end
  
  return false
end

local function GetObjectiveDistance(objective, c, z, x, y)
  if objective.o.finish then
    return GetObjectiveDistance(GetObjectiveObject("monster", objective.o.finish), c, z, x, y)
  elseif objective.fb.finish then
    return GetObjectiveDistance(GetObjectiveObject("monster", objective.fb.finish), c, z, x, y, c, z, x, y)
  end
  
  local distance, oc, oz, ox, oy = nil, 0, 0, 0, 0
  
  if objective.o.vendor or objective.fb.vendor then
    local faction = UnitFactionGroup("player")
    
    if objective.o.vendor then
      for i, vendor in pairs(objective.o.vendor) do
        local npc = GetObjectiveObject("monster", vendor)
        if not npc.faction or npc.faction == faction then
          local d, mc, mz, mx, my = GetObjectiveDistance(npc, c, z, x, y)
          if not distance or d and d < distance then
            distance, oc, oz, ox, oy = d, mc, mz, mx, my
          end
        end
      end
    end
    
    if objective.fb.vendor then
      for i, vendor in pairs(objective.fb.vendor) do
        local npc = GetObjectiveObject("monster", vendor)
        if not npc.faction or npc.faction == faction then
          local d, mc, mz, mx, my = GetObjectiveDistance(npc, c, z, x, y)
          if not distance or d and d < distance then
            distance, oc, oz, ox, oy = d, mc, mz, mx, my
          end
        end
      end
    end
    
    if distance then return distance, oc, oz, ox, oy end
  end
  
  if objective.o.drop or objective.fb.drop then
    local score = 0
    
    if objective.o.drop then
      for m, count in pairs(objective.o.drop) do
        local monster = GetObjectiveObject("monster", m)
        local d, mc, mz, mx, my = GetObjectiveDistance(monster, c, z, x, y)
        if d then -- TODO: Check for nil in other places too
          if d < 1 then
            return d, mc, mz, mx, my
          elseif d then
            local s = count/(monster.o.looted or 1)/d
            if s > score then
              score, distance, oc, oz, ox, oy = s, d, mc, mz, mx, my
            end
          end
        end
      end
    end
    
    if objective.fb.drop then
      for m, count in pairs(objective.fb.drop) do
        local monster = GetObjectiveObject("monster", m)
        local d, mc, mz, mx, my = GetObjectiveDistance(monster, c, z, x, y)
        if d then
          if d < 1 then
            return d, mc, mz, mx, my
          elseif d then
            local s = count/(monster.fb.looted or 1)/d
            if s > score then
              score, distance, oc, oz, ox, oy = s, d, mc, mz, mx, my
            end
          end
        end
      end
    end
    
    if distance then return distance, oc, oz, ox, oy end
  end
  
  if objective.o.pos or objective.fb.pos then
    local score = 0
    
    if objective.o.pos then
      for i, pos in ipairs(objective.o.pos) do
        local d = Astrolabe:ComputeDistance(pos[1], pos[2], pos[3], pos[4], c, z, x, y)
        
        if d < 1 then
          return d, pos[1], pos[2], pos[3], pos[4]
        end
        local s = pos[5]/d
        if s > score then
          score, distance, oc, oz, ox, oy = s, d, pos[1], pos[2], pos[3], pos[4]
        end
      end
    end
    
    if objective.fb.pos then
      for i, pos in ipairs(objective.fb.pos) do
        local d = Astrolabe:ComputeDistance(pos[1], pos[2], pos[3], pos[4], c, z, x, y)
        
        if d < 1 then
          return d, pos[1], pos[2], pos[3], pos[4]
        end
        local s = pos[5]/d
        if s > score then
          score, distance, oc, oz, ox, oy = s, d, pos[1], pos[2], pos[3], pos[4]
        end
      end
    end
    
    -- if distance then return distance, oc, oz, ox, oy end
  end
  
  return distance, oc, oz, ox, oy
end

local function GetObjectiveDistance2(objective, c1, z1, x1, y1, c2, z2, x2, y2)
  if objective.o.finish then
    return GetObjectiveDistance2(GetObjectiveObject("monster", objective.o.finish), c1, z1, x1, y1, c2, z2, x2, y2)
  elseif objective.fb.finish then
    return GetObjectiveDistance2(GetObjectiveObject("monster", objective.fb.finish), c1, z1, x1, y1, c2, z2, x2, y2)
  end
  
  local distance, oc, oz, ox, oy = nil, 0, 0, 0, 0
  
  if objective.o.vendor or objective.fb.vendor then
    local faction = UnitFactionGroup("player")
    
    if objective.o.vendor then
      for i, vendor in pairs(objective.o.vendor) do
        local npc = GetObjectiveObject("monster", vendor)
        if not npc.faction or npc.faction == faction then
          local d, mc, mz, mx, my = GetObjectiveDistance2(npc, c1, z1, x1, y1, c2, z2, x2, y2)
          if not distance or d and d < distance then
            distance, oc, oz, ox, oy = d, mc, mz, mx, my
          end
        end
      end
    end
    
    if objective.fb.vendor then
      for i, vendor in pairs(objective.fb.vendor) do
        local npc = GetObjectiveObject("monster", vendor)
        if not npc.faction or npc.faction == faction then
          local d, mc, mz, mx, my = GetObjectiveDistance2(npc, c1, z1, x1, y1, c2, z2, x2, y2)
          if not distance or d and d < distance then
            distance, oc, oz, ox, oy = d, mc, mz, mx, my
          end
        end
      end
    end
    
    if distance then return distance, oc, oz, ox, oy end
  end
  
  if objective.o.drop or objective.fb.drop then
    local score = 0
    
    if objective.o.drop then
      for m, count in pairs(objective.o.drop) do
        local monster = GetObjectiveObject("monster", m)
        local d, mc, mz, mx, my = GetObjectiveDistance2(monster, c1, z1, x1, y1, c2, z2, x2, y2)
        if d then
          if d < 1 then
            return d, mc, mz, mx, my
          elseif d then
            local s = count/(monster.o.looted or 1)/d
            if s > score then
              score, distance, oc, oz, ox, oy = s, d, mc, mz, mx, my
            end
          end
        end
      end
    end
    
    if objective.fb.drop then
      for m, count in pairs(objective.fb.drop) do
        local monster = GetObjectiveObject("monster", m)
        local d, mc, mz, mx, my = GetObjectiveDistance2(monster, c1, z1, x1, y1, c2, z2, x2, y2)
        if d then
          if d < 1 then
            return d, mc, mz, mx, my
          elseif d then
            local s = count/(monster.fb.looted or 1)/d
            if s > score then
              score, distance, oc, oz, ox, oy = s, d, mc, mz, mx, my
            end
          end
        end
      end
    end
    
    if distance then return distance, oc, oz, ox, oy end
  end
  
  if objective.o.pos or objective.fb.pos then
    local score = 0
    
    if objective.o.pos then
      for i, pos in ipairs(objective.o.pos) do
        local d = Astrolabe:ComputeDistance(c1, z1, x1, y1, pos[1], pos[2], pos[3], pos[4])+
                  Astrolabe:ComputeDistance(pos[1], pos[2], pos[3], pos[4], c2, z2, x2, y2)
        
        if d < 1 then
          return d, pos[1], pos[2], pos[3], pos[4]
        end
        local s = pos[5]/d
        if s > score then
          score, distance, oc, oz, ox, oy = s, d, pos[1], pos[2], pos[3], pos[4]
        end
      end
    end
    
    if objective.fb.pos then
      for i, pos in ipairs(objective.fb.pos) do
        local d = Astrolabe:ComputeDistance(c1, z1, x1, y1, pos[1], pos[2], pos[3], pos[4])+
                  Astrolabe:ComputeDistance(pos[1], pos[2], pos[3], pos[4], c2, z2, x2, y2)
        
        if d < 1 then
          return d, pos[1], pos[2], pos[3], pos[4]
        end
        local s = pos[5]/d
        if s > score then
          score, distance, oc, oz, ox, oy = s, d, pos[1], pos[2], pos[3], pos[4]
        end
      end
    end
    
    -- if distance then return distance, oc, oz, ox, oy end
  end
  
  return distance, oc, oz, ox, oy
end

function frame:BestInsertPosition(array, size, distance, extra, objective)
  -- array     - Contains the path you want to insert to.
  -- size      - How many elements are in array. (We don't removed the extras.) Array must not be empty, we don't check for that.
  -- distance  - How long is the path so far?
  -- extra     - How far is it from the player to the first node?
  -- objective - Where are we trying to get to?
  
  -- In addition, objective needs i and j set, for the min and max indexes it can be inserted into.
  
  -- Returns:
  -- index    - The index to insert to
  -- distance - The new length of the path.
  -- extra    - The new distance from the first node to the player?
  -- c,z,x,y  - The location chosen to go to.
  
  if size == 0 then
    return 1, 0, GetObjectiveDistance(objective, self.c, self.z, self.x, self.y)
  end
  
  local best_index, best_extra, bc, bz, bx, by
  
  if objective.i == 1 then
    best_index = 1
    best_extra, bc, bz, bx, by = GetObjectiveDistance(objective, self.c, self.z, self.x, self.y)
    best_distance = Astrolabe:ComputeDistance(bc, bz, bx, by, unpack(array[1].pos))+distance
    best_total = best_extra+best_distance
  elseif objective.i == size+1 then
    best_distance, bc, bz, bx, by = GetObjectiveDistance(objective, unpack(array[size].pos))
    best_distance = best_distance + distance
    return size+1, best_distance, extra, bc, bz, bx, by
  else
    local a, b = array[objective.i-1].pos, array[objective.i].pos
    best_index = objective.i
    best_extra = extra
    best_distance, bc, bz, bx, by = GetObjectiveDistance2(objective, a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    best_distance = distance + best_distance - Astrolabe:ComputeDistance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    best_total = best_extra+best_distance
  end
  
  local total = distance+extra
  
  for i = objective.i+1, math.min(size, objective.j) do
    local a, b = array[i-1].pos, array[i].pos
    local d, c, z, x, y = GetObjectiveDistance2(objective, a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    d = total + d - Astrolabe:ComputeDistance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    if d < best_distance then
      bc, bz, bx, by = c, z, x, y
      best_distance = d - extra
      best_extra = extra
      best_index = i
    end
  end
  
  if objective.j == size+1 then
    local d, c, z, x, y = GetObjectiveDistance(objective, unpack(array[size].pos))
    d = total + d
    if d < best_distance then
      return size+1, d-extra, extra, c, z, x, y
    end
  end
  
  return best_index, best_distance, best_extra, bc, bz, bx, by
end

function frame:BestInsertPositionSOP(array, size, distance, extra, objective)
  -- Same as before, but uses objective.sop instead of objective.pos
  
  --TextOut(objective.i.." to "..objective.j)
  assert(size ~= 0)
  assert(objective.i >= 1)
  assert(objective.i <= objective.j)
  assert(objective.j <= size+1)
  
  if size == 0 then
    return 1, 0, GetObjectiveDistance(objective, self.c, self.z, self.x, self.y)
  end
  
  local best_index, best_extra, bc, bz, bx, by
  
  if objective.i == 1 then
    best_index = 1
    best_extra, bc, bz, bx, by = GetObjectiveDistance(objective, self.c, self.z, self.x, self.y)
    best_distance = Astrolabe:ComputeDistance(bc, bz, bx, by, unpack(array[1].sop))+distance
    best_total = best_extra+best_distance
  elseif objective.i == size+1 then
    best_distance, bc, bz, bx, by = GetObjectiveDistance(objective, unpack(array[size].sop))
    best_distance = best_distance + distance
    return size+1, best_distance, extra, bc, bz, bx, by
  else
    local a, b = array[objective.i-1].sop, array[objective.i].sop
    best_index = objective.i
    best_extra = extra
    best_distance, bc, bz, bx, by = GetObjectiveDistance2(objective, a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    best_distance = distance + best_distance - Astrolabe:ComputeDistance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    best_total = best_extra+best_distance
  end
  
  local total = distance+extra
  
  for i = objective.i+1, math.min(size, objective.j) do
    local a, b = array[i-1].sop, array[i].sop
    local d, c, z, x, y = GetObjectiveDistance2(objective, a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    d = total + d - Astrolabe:ComputeDistance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    if d < best_distance then
      bc, bz, bx, by = c, z, x, y
      best_distance = d - extra
      best_extra = extra
      best_index = i
    end
  end
  
  if objective.j == size+1 then
    local d, c, z, x, y = GetObjectiveDistance(objective, unpack(array[size].sop))
    d = total + d
    if d < best_distance then
      return size+1, d-extra, extra, c, z, x, y
    end
  end
  
  return best_index, best_distance, best_extra, bc, bz, bx, by
end

GetObjectiveReason = function(objective)
  local text = nil
  if objective.reasons then
    for reason, count in pairs(objective.reasons) do
      if text ~= nil then
        text = text .. "\n" .. reason
      else
        text = reason
      end
    end
  end
  text = text or "I don't know why this waypoint exists."
  
  if objective.o.finish or objective.fb.finish then
    text = text .. "\nTalk to |cffffff77"..(objective.o.finish or objective.fb.finish).."|r."
  elseif objective.o.vendor or objective.fb.vendor then
    local npc_list = {}
    
    if objective.o.vendor then for i, npc in ipairs(objective.o.vendor) do
      npc_list[npc] = 1
    end end
    
    if objective.fb.vendor then for i, npc in ipairs(objective.fb.vendor) do
      npc_list[npc] = 1
    end end
    
    local sort_list = {}
    
    for npc, count in pairs(npc_list) do
      local npc_objective = GetObjectiveObject("monster", npc)
      if ObjectiveIsKnown(npc_objective) then
        npc_list[npc] = GetObjectiveDistance(npc_objective, unpack(objective.pos))
        table.insert(sort_list, npc)
      else
        npc_list[npc] = nil
      end
    end
    
    table.sort(sort_list, function(a, b) return npc_list[a] < npc_list[b] end)
    
    if #sort_list > 0 then
      local count, first = math.min(#sort_list, 3), true
      text = text .. "\nPurchase from "
      for i = 1,count do
        if i ~= count then
          text = text .. " |cffffff77"..sort_list[i].."|r,"
        elseif first then
          text = text .. " |cffffff77"..sort_list[i].."|r."
        else
          text = text .. " or |cffffff77"..sort_list[i].."|r."
        end
        first = false
      end
    else
      text = text .. "\nI'm not sure whom you should purchase this from."
    end
  elseif objective.o.drop or objective.fb.drop then
    -- Going to go through all the monsters we know and suggest the 3 that are most likely to give you what you want.
    local monster_list = {}
    
    if objective.o.drop then for monster, count in pairs(objective.o.drop) do
      monster_list[monster] = count
    end end
    
    if objective.fb.drop then for monster, count in pairs(objective.fb.drop) do
      monster_list[monster] = (monster_list[monster] or 0) + count
    end end
    
    local sort_list = {}
    
    for monster, count in pairs(monster_list) do
      local monster_objective = GetObjectiveObject("monster", monster)
      local looted = (monster_objective.o.looted or 0) + (monster_objective.fb.looted or 0)
      if looted > 0 and ObjectiveIsKnown(monster_objective) then
        local distance = GetObjectiveDistance(monster_objective, unpack(objective.pos))
        if distance < 1 then distance = 1 end
        local score = count / looted / distance
        monster_list[monster] = score
        table.insert(sort_list, monster)
      else
        monster_list[monster] = nil
      end
    end
    
    table.sort(sort_list, function(a, b) return monster_list[a] > monster_list[b] end)
    
    if #sort_list > 0 then
      local count, first = math.min(#sort_list, 3), true
      text = text .. "\nSlay"
      for i = 1,count do
        if i ~= count then
          text = text .. " |cffffff77"..sort_list[i].."|r,"
        elseif first then
          text = text .. " |cffffff77"..sort_list[i].."|r."
        else
          text = text .. " or |cffffff77"..sort_list[i].."|r."
        end
        first = false
      end
    else
      text = text .. "\nI'm not sure what monster you should slay for this."
    end
  end
  return text
end

function frame:AddObjectiveWatch(objective, reason)
  if not objective.reasons then
    objective.reasons = {}
  end
  
  if not next(objective.reasons, nil) then
    objective.watched = true
    if self.to_remove[objective] then
      self.to_remove[objective] = nil
    else
      self.to_add[objective] = true
    end
  end
  
  objective.reasons[reason] = (objective.reasons[reason] or 0) + 1
end

function frame:RemoveObjectiveWatch(objective, reason)
  if objective.reasons[reason] == 1 then
    objective.reasons[reason] = nil
    if not next(objective.reasons, nil) then
      objective.watched = false
      if self.to_add[objective] then
        self.to_add[objective] = nil
      else
        self.to_remove[objective] = true
      end
    end
  else
    objective.reasons[reason] = objective.reasons[reason] - 1
  end
end

local function AppendObjectivePosition(objective, c, z, x, y)
  if not c or (c == 0 and z == 0) or x == 0 or y == 0 then
    return -- This isn't a real position.
  end
  
  if objective.o.drop then
    return -- If we know it comes from a monster, then don't record a location for it.
  end
  
  if not objective.o.pos then
    -- Never recorded a position before, create a new table and return.
    objective.o.pos = {{c, z, x, y, 1}}
    return
  end
  
  local closest, distance = nil, 0
  for i, pos in ipairs(objective.o.pos) do
    if c == pos[1] and z == pos[2] then
      local d = Astrolabe:ComputeDistance(c, z, x, y, pos[1], pos[2], pos[3], pos[4])
      if not closest or d < distance then
        closest = i
        distance = d
      end
    end
  end
  if closest and distance < 200.0 then
    local pos = objective.o.pos[closest]
    pos[3] = (pos[3]*pos[5]+x)/(pos[5]+1)
    pos[4] = (pos[4]*pos[5]+y)/(pos[5]+1)
    pos[5] = pos[5]+1
  else
    table.insert(objective.o.pos, {c, z, x, y, 1})
  end
end

local function AppendObjectiveDrop(objective, monster, count)
  if not count then count = 1 end
  if objective.o.pos then
    objective.o.pos = nil -- Don't record positions of things that come from monsters. We'll use the monster positions instead.
  end
  if not objective.o.drop then
    objective.o.drop = {[monster] = count}
  else
    objective.o.drop[monster] = (objective.o.drop[monster] or 0) + count
  end
end

local function GetObjective(quest, objective)
  local text, category, done = GetQuestLogLeaderBoard(objective, quest)
  local _, _, wanted, have, need = string.find(text, "%s*(.+)%s*:%s*(.+)%s*/%s*(.+)%s*")
  if not need then
    have = 0
    need = 1
  end
  if done then
    have = need
  end
  if category == "monster" then
    local start = string.find(wanted, "%sslain$", -6)
    if start then
      wanted = string.sub(wanted, 1, start-1)
    end
  end
  return category, wanted or text, tonumber(have) or have, tonumber(need) or need
end

local function GetQuestLevel(quest)
  local index = 1
  while true do
    local title, level = GetQuestLogTitle(index)
    if not title then return 0 end
    if title == quest then
      SelectQuestLogEntry(index)
      return level, HashString(GetQuestLogQuestText())
    end
    index = index + 1
  end
end

local function ObjectiveObjectDependsOn(objective, needs)
  assert(objective ~= needs) -- If this was true, ObjectiveIsKnown would get in an infinite loop.
  objective.after[needs] = true
  needs.before[objective] = true
end

function frame:ScanQuestLog()
  local quests = self.quest_log
  
  for i, quest in pairs(quests) do
    -- Will set this to false if the player still has it.
    quest.removed = true
  end
  
  local index = 1
  while true do
    local title, level, qtype, players, header, collapsed, status, daily = GetQuestLogTitle(index)
    
    if not title then break end
    
    if not header then
      SelectQuestLogEntry(index)
      local hash = HashString(GetQuestLogQuestText())
      local quest = GetQuestObject(title, level, hash)
      local lq = quests[quest]
      local is_new = false
      
      if not lq then
        lq = {}
        
        quests[quest] = lq
        
        -- Can't add the objective here, if we don't have it depend on the objectives
        -- first it'll get added and possibly not be doable.
        -- We'll add it after the objectives are determined.
        is_new = true
      end
      
      lq.removed = false
      
      if GetNumQuestLeaderBoards(index) > 0 then
        if not lq.goal then lq.goal = {} end
        for objective = 1, GetNumQuestLeaderBoards(index) do
          local lo = lq.goal[objective]
          if not lo then lo = {} lq.goal[objective] = lo end
          local category, wanted, have, need = GetObjective(index, objective)
          
          if wanted == " " then
            defered_quest_scan = true
          elseif not lo.objective then
            -- objective is new.
            lo.objective = GetObjectiveObject(category, wanted)
            lo.objective.quest = true -- If I ever decide to prune the DB, I'll have the stuff actually used in quests marked.
            ObjectiveObjectDependsOn(quest, lo.objective)
            
            -- TODO: Possible bug: Sometimes 'wanted' ends up being a space. Yet when I reload, its the correct value.
            -- Maybe an item isn't in the local cache and I should try again later after its loaded?
            
            if category == "monster" then
              lo.reason = "Slay |cffffff77"..wanted.."|r for quest |cffffff77"..title.."|r."
            elseif category == "item" then
              lo.reason = "Acquire |cffffff77"..wanted.."|r for quest |cffffff77"..title.."|r."
            else
              lo.reason = "Complete objective |cffffff77"..wanted.."|r for quest |cffffff77"..title.."|r."
            end
            
            lo.have = have
            lo.need = need
            if have ~= need then -- If the objective isn't complete, watch it.
              self:AddObjectiveWatch(lo.objective, lo.reason)
            end
          elseif lo.have ~= have then
            if type(lo.have) == "string" or lo.have > have then
              AppendObjectivePosition(lo.objective, self:GetBestKnownPlayerPosition())
            end
            
            if lo.have == need then -- The objective was done, but now its not.
              self:AddObjectiveWatch(lo.objective, lo.reason)
            elseif have == need then -- The objective is now finished.
              self:RemoveObjectiveWatch(lo.objective, lo.reason)
            end
            lo.have = have
          end
        end
      else
        quest.goal = nil
      end
      
      if is_new then
        lq.reason = "Turn in quest |cffffff77"..title.."|r."
        self:AddObjectiveWatch(quest, lq.reason)
      end
    end
    index = index + 1
  end
  
  for quest, lq in pairs(quests) do
    if lq.removed then
      if lq.goal then
        for i, lo in ipairs(lq.goal) do
          if lo.have ~= lo.need then
            self:RemoveObjectiveWatch(lo.objective, lo.reason)
          end
        end
      end
      self:RemoveObjectiveWatch(quest, lq.reason)
      quests[quest] = nil
    end
  end
end

function frame:OnEvent(event)
  -- TextOut(event..":"..(arg1 or "nil").."|"..(arg2 or "nil").."|"..(arg3 or "nil").."|"..(arg4 or "nil"))
  
  if event == "VARIABLES_LOADED" then
    QuestHelper_UpgradeDatabase(_G)
  end
  
  if event == "PLAYER_TARGET_CHANGED" then
    if UnitExists("target") and UnitIsVisible("target") and UnitCreatureType("target") ~= "Critter" and not UnitIsPlayer("target") and not UnitPlayerControlled("target") then
      local monster_objective = GetObjectiveObject("monster", UnitName("target"))
      AppendObjectivePosition(monster_objective, self:GetBestKnownUnitPosition("target"))
      monster_objective.o.faction = UnitFactionGroup("target")
      
      local level = UnitLevel("target")
      if level and level >= 1 then
        local w = monster_objective.o.levelw or 0
        monster_objective.o.level = ((monster_objective.o.level or 0)*w+level)/(w+1)
        monster_objective.o.levelw = w+1
      end
    end
  end
  
  if event == "LOOT_OPENED" then
    local target = UnitName("target")
    if target and UnitIsDead("target") and UnitCreatureType("target") ~= "Critter" and not UnitIsPlayer("target") and not UnitPlayerControlled("target") then
      local monster_objective = GetObjectiveObject("monster", target)
      monster_objective.o.looted = (monster_objective.o.looted or 0) + 1
      
      AppendObjectivePosition(monster_objective, self:GetBestKnownUnitPosition("target"))
      
      for i = 1, GetNumLootItems() do
        local icon, name, number, rarity = GetLootSlotInfo(i)
        if name then
          if number and number >= 1 then
            AppendObjectiveDrop(GetObjectiveObject("item", name), target, number)
          else
            local total = 0
            local _, _, amount = string.find(name, "(%d+) Copper")
            if amount then total = total + amount end
            _, _, amount = string.find(name, "(%d+) Silver")
            if amount then total = total + amount * 100 end
            _, _, amount = string.find(name, "(%d+) Gold")
            if amount then total = total + amount * 10000 end
            
            if total > 0 then
              AppendObjectiveDrop(GetObjectiveObject("item", "money"), target, total)
            end
          end
        end
      end
    else
      for i = 1, GetNumLootItems() do
        local icon, name, number, rarity = GetLootSlotInfo(i)
        if name and number >= 1 then
            AppendObjectivePosition(GetObjectiveObject("item", name), self:GetBestKnownPlayerPosition())
        end
      end
    end
  end
  
  if event == "QUEST_LOG_UPDATE" then
    self.defered_quest_scan = true
  end
  
  if event == "QUEST_COMPLETE" or event == "QUEST_PROGRESS" then
    local quest = GetTitleText()
    if quest then
      local level, hash = GetQuestLevel(quest)
      if not level or level < 1 then
        TextOut("Don't know quest level for ".. quest.."!")
        return
      end
      local q = GetQuestObject(quest, level, hash)
      
      if q.need_hash then
        q.o.hash = hash
      end
      
      local unit = UnitName("npc")
      if unit then
        q.o.finish = unit
        q.o.pos = nil
      elseif not q.o.finish then
        AppendObjectivePosition(q, self:GetBestKnownPlayerPosition())
      end
    end
  end
  
  if event == "MERCHANT_SHOW" then
    local npc_name = UnitName("npc")
    if npc_name then
      local npc_objective = GetObjectiveObject("monster", npc_name)
      local index = 1
      while true do
        local item_name = GetMerchantItemInfo(index)
        if item_name then
          index = index + 1
          local item_objective = GetObjectiveObject("item", item_name)
          if not item_objective.o.vendor then
            item_objective.o.vendor = {npc_name}
          else
            local known = false
            for i, vendor in ipairs(item_objective.o.vendor) do
              if npc_name == vendor then
                known = true
                break
              end
            end
            if not known then
              table.insert(item_objective.o.vendor, npc_name)
            end
          end
        else
          break
        end
      end
    end
  end
end

local function RouteUpdateRoutine(frame)
  local size, distance, extra, route, new_route, shuffle, insert, point = frame.route_size, 0, 0, frame.route, {}, {}, 0, nil
  
  while true do
    frame:GetBestKnownPlayerPosition()
    
    for i = 1,size do
      local o = route[i]
      if not ObjectiveIsKnown(o) then
        -- Objective was probably made to depend on an objective that we don't know about yet.
        -- We add it to both lists, because although we need to remove it, we need it added again when we can.
        -- This creats an inconsistancy, but it'll get fixed in the removal loop before anything has a chance to
        -- explode from it.
        
        -- TODO: I also need to check to make sure the node is still before or after the nodes its
        -- supposed to be before or after.
        
        frame.to_remove[o] = true
        frame.to_add[o] = true
      end
    end
    
    -- Remove any waypoints if needed.
    for objective, _ in pairs(frame.to_remove) do
      frame.to_remove[objective] = nil
      for i = 1, size do
        if route[i] == objective then
          if i == 1 then
            if size == 1 then
              frame.minimap_dodad:Hide()
            else
              frame.minimap_dodad:SetObjective(route[2])
            end
          end
          table.remove(route, i)
          size = size - 1
          break
        end
      end
      changed = true
    end
    
    -- Add any waypoints if needed.
    for objective, _ in pairs(frame.to_add) do
      if ObjectiveIsKnown(objective) then
        frame.to_add[objective] = nil
        
        if size == 0 then
          extra, objective.pos[1], objective.pos[2], objective.pos[3], objective.pos[4] =
            GetObjectiveDistance(objective, frame.c, frame.z, frame.x, frame.y)
          
          table.insert(route, objective)
          size = 1
          frame.minimap_dodad:Show()
          frame.minimap_dodad:SetObjective(objective)
        else
          objective.i, objective.j = 1, size+1
          
          for i = 1,size do
            if objective.after[route[i]] then
              objective.i = i+1
            elseif objective.before[route[i]] then
              objective.j = i
            end
          end
          
          insert, distance, extra, objective.pos[1], objective.pos[2], objective.pos[3], objective.pos[4]
           = frame:BestInsertPosition(route, size, distance, extra, objective)
          
          table.insert(route, insert, objective)
          size = size + 1
          
          if insert == 1 then
            frame.minimap_dodad:SetObjective(objective)
          end
        end
        changed = true
      end
    end
    
    -- If the size changed, update the table we use for shuffling.
    if size < frame.route_size then
      for i=1,size do
        shuffle[i] = i
      end
      frame.route_size = size
    else
      for i=frame.route_size+1,size do
        shuffle[i] = i
      end
      frame.route_size = size
    end
    
    -- Thats enough work for now, we'll continue next frame.
    coroutine.yield()
    
    if size > 0 then
      -- Move the points around in the existing path if needed. This will hopefully optimize the path somewhat, and
      -- reposition objectives if we learn that we can't do something the way we thought we could.
      
      if size == 1 then
        local o = route[1]
        extra, o.pos[1], o.pos[2], o.pos[3], o.pos[4] = GetObjectiveDistance(o, frame.c, frame.z, frame.x, frame.y, unpack(o.pos)) 
        frame.minimap_dodad:SetObjective(o)
        local icon = frame.waypoint_icons[1]
        if not icon then
          icon = CreateWorldMapDodad(o, 1)
          frame.waypoint_icons[1] = icon
        else
          icon:SetObjective(o, 1)
        end
        for i = 2,#frame.waypoint_icons do
          frame.waypoint_icons[i]:Hide()
        end
      else
        local d
        for i = 1,size do
          local o = route[i]
          
          if i == 1 then
            local old_d = Astrolabe:ComputeDistance(o.pos[1], o.pos[2], o.pos[3], o.pos[4], unpack(route[i+1].pos))
            d, o.pos[1], o.pos[2], o.pos[3], o.pos[4] = GetObjectiveDistance2(o, frame.c, frame.z, frame.x, frame.y, unpack(route[i+1].pos))
            local new_d = Astrolabe:ComputeDistance(o.pos[1], o.pos[2], o.pos[3], o.pos[4], unpack(route[i+1].pos))
            distance = distance - old_d + new_d
            extra = d - new_d
            frame.minimap_dodad:SetObjective(o)
          elseif i == size then
            local old_d = Astrolabe:ComputeDistance(o.pos[1], o.pos[2], o.pos[3], o.pos[4], unpack(route[size].pos))
            d, o.pos[1], o.pos[2], o.pos[3], o.pos[4] = GetObjectiveDistance(o, unpack(route[size].pos))
            distance = distance - old_d + d
          else
            local a, b = route[i-1], route[i+1]
            old_d = Astrolabe:ComputeDistance(a.pos[1], a.pos[2], a.pos[3], a.pos[4], unpack(o.pos))+
                          Astrolabe:ComputeDistance(o.pos[1], o.pos[2], o.pos[3], o.pos[4], unpack(b.pos))
            d, o.pos[1], o.pos[2], o.pos[3], o.pos[4] = GetObjectiveDistance2(o, a.pos[1], a.pos[2], a.pos[3], a.pos[4], unpack(b.pos))
            distance = distance - old_d + d
          end
          
          local icon = frame.waypoint_icons[i]
          if not icon then
            icon = CreateWorldMapDodad(o, i)
            frame.waypoint_icons[i] = icon
          else
            icon:SetObjective(o, i)
          end
        end
        for i = size+1,#frame.waypoint_icons do
          frame.waypoint_icons[i]:Hide()
        end
      end
      
      coroutine.yield()
      
      local new_distance, new_extra = 0, 0
      extra = Astrolabe:ComputeDistance(frame.c, frame.z, frame.x, frame.y, unpack(route[1].pos))
      
      for i=1,size-1 do
        local r = math.random(i, size)
        if r ~= i then
          local t = shuffle[i]
          shuffle[i] = shuffle[r]
          shuffle[r] = t
        end
      end
      
      point = route[shuffle[1]]
      new_distance = 0
      new_extra, point.sop[1], point.sop[2], point.sop[3], point.sop[4] = GetObjectiveDistance(point, frame.c, frame.z, frame.x, frame.y)
      
      table.insert(new_route, point)
      
      for j=2,size do
        local p = route[shuffle[j]]
        
        if p.before[point] then
          p.i = 1
          p.j = 1
        elseif p.after[point] then
          p.i = 2
          p.j = 2
        else
          p.i = 1
          p.j = 2
        end
      end
      
      for i=2,size do
        point = route[shuffle[i]]
        
        insert, new_distance, new_extra, point.sop[1], point.sop[2], point.sop[3], point.sop[4]
          = frame:BestInsertPositionSOP(new_route, i-1, new_distance, new_extra, point)
        
        for j=i+1,size do
          local p = route[shuffle[j]]
          if p.before[point] then
            p.j = insert
          elseif p.after[point] then
            p.i = insert+1
            p.j = p.j + 1
          elseif p.j > insert then
            p.j = p.j + 1
            if p.i > insert then p.i = p.i + 1 end
          end
        end
        
        table.insert(new_route, insert, point)
        coroutine.yield()
      end
      
      if new_distance+new_extra+0.01 < distance+extra then
        for i, node in ipairs(new_route) do
          table.remove(route)
          local t = node.pos
          node.pos = node.sop
          node.sop = t
        end
        
        frame.route = new_route
        new_route = route
        route = frame.route
        distance = new_distance
        extra = new_extra
      else
        for i = 1,size do table.remove(new_route) end
      end
    end
  end
end

frame.update_route = coroutine.create(RouteUpdateRoutine)

function frame:OnUpdate()
  if self.defered_quest_scan then
    self.defered_quest_scan = false
    self:ScanQuestLog()
  end
  if coroutine.status(self.update_route) ~= "dead" then
    local state, err = coroutine.resume(self.update_route, self)
    if not state then TextOut("|cffff0000The routing co-routine just exploded|r: |cffffff77"..err.."|r") end
  end
end

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("LOOT_OPENED")
frame:RegisterEvent("QUEST_COMPLETE")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("VARIABLES_LOADED")

frame:SetScript("OnEvent", frame.OnEvent)
frame:SetScript("OnUpdate", frame.OnUpdate)
