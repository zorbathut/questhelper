local ofs = 0.000723339 * (GetScreenHeight()/GetScreenWidth() + 1/3) * 70.4;
local radius = ofs / 1.166666666666667;

local function ClampLine(x1, y1, x2, y2)
  if x1 and y1 and x2 and y2 then
    local x_div, y_div = (x2-x1), (y2-y1)
    local x_0 = y1-x1/x_div*y_div
    local x_1 = y1+(1-x1)/x_div*y_div
    local y_0 = x1-y1/y_div*x_div
    local y_1 = x1+(1-y1)/y_div*x_div
    
    if y1 < 0 then
      x1 = y_0
      y1 = 0
    end
    
    if y2 < 0 then
      x2 = y_0
      y2 = 0
    end
    
    if y1 > 1 then
      x1 = y_1
      y1 = 1
    end
    
    if y2 > 1 then
      x2 = y_1
      y2 = 1
    end
    
    if x1 < 0 then
      y1 = x_0
      x1 = 0
    end
    
    if x2 < 0 then
      y2 = x_0
      x2 = 0
    end
    
    if x1 > 1 then
      y1 = x_1
      x1 = 1
    end
    
    if x2 > 1 then
      y2 = x_1
      x2 = 1
    end
    
    if x1 >= 0 and x2 >= 0 and y1 >= 0 and y2 >= 0 and x1 <= 1 and x2 <= 1 and y1 <= 1 and y2 <= 1 then
      return x1, y1, x2, y2
    end
  end
end

local function pushPath(list, path)
  if path then
    pushPath(list, path.p)
    table.insert(list, path.pos)
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
  walker.used_dots = 0
  walker.points = {}
  walker.origin = {}
  walker.frame = self
  
  function walker:OnUpdate(elapsed)
    local points = self.points
    
    self.phase = self.phase + elapsed
    while self.phase > 1 do self.phase = self.phase - 1 end
    
    local w, h = WorldMapDetailFrame:GetWidth(), -WorldMapDetailFrame:GetHeight()
    
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
    
    local last_x, last_y = self.frame.Astrolabe:TranslateWorldMapPosition(self.frame.c, self.frame.z, self.frame.x, self.frame.y, c, z) local remainder = self.phase
    local out = 0
    
    for i, pos in ipairs(points) do
      local new_x, new_y = self.frame.Astrolabe:TranslateWorldMapPosition(pos[1], pos[2], pos[3], pos[4], c, z)
      local x1, y1, x2, y2 = ClampLine(last_x, last_y, new_x, new_y)
      last_x, last_y = new_x, new_y
      
      if x1 then
        local len = math.sqrt((x1-x2)*(x1-x2)*16/9+(y1-y2)*(y1-y2))
        
        if len > 0.0001 then
          local interval = .03/len
          local p = remainder*interval
          
          while p < 1 do
            out = out + 1
            local dot = self.dots[out]
            if not dot then
              dot = self:CreateTexture()
              dot:SetTexture("Interface\\Minimap\\ObjectIcons")
              dot:SetTexCoord(0.280, 0.35, 0.09, 0.36)
              dot:SetVertexColor(1,0,0,0.5)
              dot:SetWidth(4)
              dot:SetHeight(4)
              self.dots[out] = dot
            end
            dot:ClearAllPoints()
            dot:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", x1*w*(1-p)+x2*w*p, y1*h*(1-p)+y2*h*p)
            dot:Show()
            p = p + interval
          end
          
          remainder = (p-1)/interval
        end
      end
    end
    
    for i = out+1,self.used_dots do
      self.dots[i]:Hide()
    end
    
    self.used_dots = out
  end
  
  function walker:OnEvent()
    local points = self.points
    local cur = self.origin
    
    cur[1], cur[2], cur[3], cur[4] = self.frame.c, self.frame.z, self.frame.x, self.frame.y
    
    while #points > 0 do table.remove(points) end
    
    local travel_time = 0.0
    
    for i, obj in pairs(self.frame.route) do
      local path = self.frame:ComputeRoute(cur[1], cur[2], cur[3], cur[4], unpack(obj.pos))
      if path then
        travel_time = travel_time + path.g + path.e
        pushPath(points, path)
      else
        travel_time = travel_time + (self.frame.Astrolabe:ComputeDistance(cur[1], cur[2], cur[3], cur[4], unpack(obj.pos)) or 0)/7.0
      end
      
      obj.travel_time = travel_time
      
      cur = obj.pos
      table.insert(points, cur)
    end
  end
  
  walker:SetScript("OnEvent", walker.OnEvent)
  walker:RegisterEvent("WORLD_MAP_UPDATE")
  
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
    QuestHelper.tooltip:SetText("|cffffffff("..self.index..")|r "..self.objective:Reason().."\nEstimated travel time: "..QuestHelper:TimeString(self.objective.travel_time or 0))
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
