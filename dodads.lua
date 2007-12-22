local ofs = 0.000723339 * (GetScreenHeight()/GetScreenWidth() + 1/3) * 70.4;
local radius = ofs / 1.166666666666667;

function QuestHelper:CalcWorldMapPosition(findex)
  if findex < 0 or findex > #self.route then
    return nil
  end
  
  local index = math.floor(findex)
  local r = findex-index
  
  local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
  
  local x1, y1, x2, y2
  
  if index == 0 then
    x1, y1 = self.Astrolabe:TranslateWorldMapPosition(self.c, self.z, self.x, self.y, c, z)
  else
    local p = self.route[index].pos
    x1, y1 = self.Astrolabe:TranslateWorldMapPosition(p[1], p[2], p[3], p[4], c, z)
  end
  
  if r < 0.000001 then
    return x1, y1
  end
  
  local p = self.route[index+1].pos
  x2, y2 = self.Astrolabe:TranslateWorldMapPosition(p[1], p[2], p[3], p[4], c, z)
  
  if x1 and x2 then
    return x1*(1-r)+x2*r, y1*(1-r)+y2*r
  end
end

function QuestHelper:CreateWorldMapWalker()
  local walker = CreateFrame("Button", nil, WorldMapButton)
  walker:SetWidth(0)
  walker:SetHeight(0)
  walker:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 0, 0)
  walker:Show()
  
  walker.phase = 0.0
  walker.dots = {}
  walker.frame = self
  
  function walker:OnUpdate(elapsed)
    self.phase = self.phase + elapsed
    while self.phase > 1 do self.phase = self.phase - 1 end
    
    local w, h = WorldMapDetailFrame:GetWidth(), -WorldMapDetailFrame:GetHeight()
    
    for i = 1,#self.frame.route*4+1 do
      local dot = self.dots[i]
      if not dot then
        dot = self:CreateTexture()
        dot:SetTexture("Interface\\Minimap\\ObjectIcons")
        dot:SetTexCoord(0.280, 0.35, 0.09, 0.36)
        dot:SetVertexColor(1,0,0,0.5)
        dot:SetWidth(4)
        dot:SetHeight(4)
        self.dots[i] = dot
      end
      local x, y = self.frame:CalcWorldMapPosition((i-1)/4+self.phase/4)
      if x and x > 0 and y > 0 and x < 1 and y < 1 then 
          dot:ClearAllPoints()
          dot:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", x*w, y*h)
          dot:Show()
      else
        dot:Hide()
      end
    end
    
    for i = #self.dots,#self.frame.route*4+1 do
      self.dots[i]:Hide()
    end
  end
  
  walker:SetScript("OnUpdate", walker.OnUpdate)
end

QuestHelper.map_walker = QuestHelper:CreateWorldMapWalker()

function QuestHelper:CreateWorldMapDodad(objective, index)
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
    
    QuestHelper.Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self, unpack(objective.pos))
  end
  
  function icon:OnEnter()
    QuestHelper.tooltip:Show()
    QuestHelper.tooltip:SetOwner(self, "ANCHOR_CURSOR")
    QuestHelper.tooltip:SetText("|cffffffff("..self.index..")|r "..self.objective:Reason())
  end
  
  function icon:OnLeave()
    QuestHelper.tooltip:Hide()
  end
  
  function icon:OnEvent(event)
    QuestHelper.Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self, unpack(self.objective.pos))
  end
  
  icon:SetScript("OnEnter", icon.OnEnter)
  icon:SetScript("OnLeave", icon.OnLeave)
  icon:SetScript("OnEvent", icon.OnEvent)
  icon:RegisterEvent("WORLD_MAP_UPDATE")
  
  icon:SetObjective(objective, index)
  return icon
end

function QuestHelper:CreateMipmapDodad()
  local icon = CreateFrame("Button", nil, Minimap)
  icon:Hide()
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
  icon.arrow:Hide()
  
  icon.phase = 0
  
  function icon:OnUpdate(elapsed)
    local edge = QuestHelper.Astrolabe:IsIconOnEdge(self)
    local dot = self.dot:IsShown()
     
    if edge and dot then
      self.arrow:Show()
      self.dot:Hide()
    elseif not edge and not dot then
      self.dot:Show()
      self.arrow:Hide()
    end
    
    if edge then
      local angle = QuestHelper.Astrolabe:GetDirectionToIcon(self)
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
    QuestHelper.Astrolabe:PlaceIconOnMinimap(self, unpack(objective.pos))
  end
  
  function icon:OnEnter()
    QuestHelper.tooltip:Show()
    QuestHelper.tooltip:SetOwner(self, "ANCHOR_CURSOR")
    QuestHelper.tooltip:SetText(self.objective:Reason())
  end
  
  function icon:OnLeave()
    QuestHelper.tooltip:Hide()
  end
  
  icon:SetScript("OnUpdate", icon.OnUpdate)
  icon:SetScript("OnEnter", icon.OnEnter)
  icon:SetScript("OnLeave", icon.OnLeave)
  
  return icon
end
