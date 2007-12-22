local ofs = 0.000723339 * (GetScreenHeight()/GetScreenWidth() + 1/3) * 70.4;
local radius = ofs / 1.166666666666667;

local function convertLocation(p)
  local c, x, y = p[1].c, p[3], p[4]
  x, y = x/QuestHelper.continent_scales_x[c], y/QuestHelper.continent_scales_y[c]
  return c, 0, x, y
end

local function convertLocationToScreen(p, c, z)
  return QuestHelper.Astrolabe:TranslateWorldMapPosition(p[1].c, 0, p[3]/QuestHelper.continent_scales_x[p[1].c], p[4]/QuestHelper.continent_scales_y[p[1].c], c, z)
end

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

local function pushPath(list, path, spare_tables, c, z)
  if path then
    pushPath(list, path.p, spare_tables, c, z)
    local t = table.remove(spare_tables)
    if not t then t = {} end
    t[1], t[2] = QuestHelper.Astrolabe:TranslateWorldMapPosition(path.c, 0, path.x/QuestHelper.continent_scales_x[path.c], path.y/QuestHelper.continent_scales_y[path.c], c, z)
    table.insert(list, t)
  end
end

function QuestHelper:GetTexture(parent, r, g, b, a)
  local tex = self.free_textures and table.remove(self.free_textures)
  
  if tex then
    tex:SetParent(parent)
  else
    tex = parent:CreateTexture()
  end
  
  tex:SetTexture(r, g, b, a)
  tex:ClearAllPoints()
  tex:SetTexCoord(0, 1, 0, 1)
  tex:SetVertexColor(1, 1, 1, 1)
  tex:SetDrawLayer("ARTWORK")
  tex:SetBlendMode("BLEND")
  tex:SetWidth(15)
  tex:SetHeight(15)
  tex:Show()
  
  return tex
end

function QuestHelper:GetIconTexture(parent, id)
  local icon = self:GetTexture(parent, "Interface\\AddOns\\QuestHelper\\Art\\Icons.tga")
  
  local w, h = 1/4, 1/4
  local x, y = ((id-1)%4)*w, math.floor((id-1)/4)*h
  
  icon:SetTexCoord(x, x+w, y, y+h)
  
  return icon
end

function QuestHelper:GetDotTexture(parent)
  local icon = self:GetIconTexture(parent, 13)
  icon:SetWidth(5)
  icon:SetHeight(5)
  icon:SetVertexColor(0, 0, 0, 0.35)
  return icon
end

function QuestHelper:GetGlowTexture(parent)
  local tex = self:GetTexture(parent, "Interface\\Addons\\QuestHelper\\Art\\Glow.blp")
  
  local angle = math.random()*6.28318530717958647692528676655900576839433879875021164
  local x, y = math.cos(angle)*0.707106781186547524400844362104849039284835937688474036588339869,
               math.sin(angle)*0.707106781186547524400844362104849039284835937688474036588339869
  
  -- Randomly rotate the texture, so they don't all look the same.
  tex:SetTexCoord(x+0.5, y+0.5, y+0.5, 0.5-x, 0.5-y, x+0.5, 0.5-x, 0.5-y)
  tex:ClearAllPoints()
  
  return tex
end

function QuestHelper:ReleaseTexture(tex)
  tex:Hide()
  if not self.free_textures then self.free_textures = {tex}
  else table.insert(self.free_textures, tex) end
end

function QuestHelper:CreateWorldMapWalker()
  local walker = CreateFrame("Button", nil, WorldMapButton)
  walker:SetWidth(0)
  walker:SetHeight(0)
  walker:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 0, 0)
  walker:Show()
  
  walker.phase = 0.0
  walker.dots = {}
  walker.points = {}
  walker.origin = {}
  walker.frame = self
  walker.spare_tables = {}
  
  function walker:OnUpdate(elapsed)
    local points = self.points
    
    self.phase = self.phase + elapsed * 0.66
    while self.phase > 1 do self.phase = self.phase - 1 end
    
    local w, h = WorldMapDetailFrame:GetWidth(), -WorldMapDetailFrame:GetHeight()
    
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
    
    local last_x, last_y = self.frame.Astrolabe:TranslateWorldMapPosition(self.frame.c, self.frame.z, self.frame.x, self.frame.y, c, z) local remainder = self.phase
    local out = 0
    
    for i, pos in ipairs(points) do
      local new_x, new_y = unpack(pos)
      local x1, y1, x2, y2 = ClampLine(last_x, last_y, new_x, new_y)
      last_x, last_y = new_x, new_y
      
      if x1 then
        local len = math.sqrt((x1-x2)*(x1-x2)*16/9+(y1-y2)*(y1-y2))
        
        if len > 0.0001 then
          local interval = .025/len
          local p = remainder*interval
          
          while p < 1 do
            out = out + 1
            local dot = self.dots[out]
            if not dot then
              dot = QuestHelper:GetDotTexture(self)
              self.dots[out] = dot
            end
            
            dot:ClearAllPoints()
            dot:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", x1*w*(1-p)+x2*w*p, y1*h*(1-p)+y2*h*p)
            
            p = p + interval
          end
          
          remainder = (p-1)/interval
        end
      end
    end
    
    while #self.dots > out do
      QuestHelper:ReleaseTexture(table.remove(self.dots))
    end
    
    self.used_dots = out
  end
  
  function walker:RouteChanged()
    if QuestHelper.Astrolabe.WorldMapVisible then
      local points = self.points
      local cur = self.frame.pos
      local spare_tables = self.spare_tables
      
      while #points > 0 do table.insert(spare_tables, table.remove(points)) end
      
      local travel_time = 0.0
      
      local w, h = WorldMapDetailFrame:GetWidth(), -WorldMapDetailFrame:GetHeight()
      local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
      
      for i, obj in pairs(self.frame.route) do
        local path, d = self.frame:ComputeRoute(cur, obj.pos)
        
        pushPath(points, path, spare_tables, c, z)
        
        travel_time = travel_time + d
        obj.travel_time = travel_time
        
        cur = obj.pos
        
        local t = table.remove(spare_tables)
        if not t then t = {} end
        t[1], t[2] = convertLocationToScreen(cur, c, z)
        
        table.insert(points, t)
      end
    end
  end
  
  walker:SetScript("OnEvent", walker.RouteChanged)
  walker:RegisterEvent("WORLD_MAP_UPDATE")
  
  walker:SetScript("OnUpdate", walker.OnUpdate)
  
  return walker
end

function QuestHelper:GetOverlapObjectives(obj)
  local w, h = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
  local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
  
  local count = 0
  local list = self.overlap_list
  
  if not list then
    list = {}
    self.overlap_list = list
  else
    while next(list) do
      list[next(list)] = nil
    end
  end
  
  local cx, cy = GetCursorPosition()
  
  local es = WorldMapDetailFrame:GetEffectiveScale()
  local ies = 1/es
  
  cx, cy = (cx-WorldMapDetailFrame:GetLeft()*es)*ies, (WorldMapDetailFrame:GetTop()*es-cy)*ies
  
  for i, o in ipairs(self.route) do
    if o == obj then
      list[i] = o
      count = count + 1
    else
      local x, y = o.pos[3], o.pos[4]
      x, y = x / self.continent_scales_x[o.pos[1].c], y / self.continent_scales_y[o.pos[1].c]
      x, y = self.Astrolabe:TranslateWorldMapPosition(o.pos[1].c, 0, x, y, c, z)
      
      if x and y and x > 0 and y > 0 and x < 1 and y < 1 then
        x, y = x*w, y*h
        
        if cx >= x-10 and cy >= y-10 and cx <= x+10 and cy <= y+10 then
          list[i] = o
          count = count + 1
        end
      end
    end
  end
  
  return list, count
end

function QuestHelper:CreateWorldMapDodad(objective, index)
  local icon = CreateFrame("Button", nil, WorldMapButton)
  icon:SetHeight(20)
  icon:SetWidth(20)
  
  icon:SetFrameStrata("FULLSCREEN_DIALOG")
  
  function icon:SetObjective(objective, i)
    if self.dot then
      QuestHelper:ReleaseTexture(self.dot)
      self.dot = nil
    end
    
    if self.bg then
      QuestHelper:ReleaseTexture(self.bg)
      self.bg = nil
    end
    
    if objective then
      self.objective = objective
      self.index = i
      
      if i == 1 then
        self.bg = QuestHelper:GetIconTexture(self, 13)
      else
        self.bg = QuestHelper:GetIconTexture(self, objective.icon_bg)
      end
      
      self.dot = QuestHelper:GetIconTexture(self, objective.icon_id)
      
      self.bg:SetDrawLayer("BACKGROUND")
      self.bg:SetAllPoints()
      self.dot:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
      self.dot:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
      
      QuestHelper.Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self, convertLocation(objective.pos))
    else
      self.objective = nil
      self:Hide()
    end
  end
  
  icon.show_glow = false
  icon.glow_pct = 0.0
  icon.glow_list = {}
  icon.phase = 0.0
  
  function icon:OnUpdate(elapsed)
    self.phase = (self.phase + elapsed)%6.283185307179586476925286766559005768394338798750211641949889185
    
    if self.show_glow then
      self.glow_pct = math.min(1, self.glow_pct+elapsed*1.5)
    else
      self.glow_pct = math.max(0, self.glow_pct-elapsed*0.5)
      
      if self.glow_pct == 0 then
        while #self.glow_list > 0 do
          QuestHelper:ReleaseTexture(table.remove(self.glow_list))
        end
        self:SetScript("OnUpdate", nil)
        return
      end
    end
    
    local r, g, b = math.sin(self.phase)*0.25+0.75,
                    math.sin(self.phase+2.094395102393195492308428922186335256131446266250070547316629728)*0.25+0.75,
                    math.sin(self.phase+4.188790204786390984616857844372670512262892532500141094633259456)*0.25+0.75
    
    for i, tex in ipairs(self.glow_list) do
      tex:SetVertexColor(r, g, b, self.glow_pct*tex.max_alpha)
    end
  end
  
  function icon:OnEnter()
    QuestHelper.tooltip:SetOwner(self, "ANCHOR_CURSOR")
    QuestHelper.tooltip:ClearLines()
    
    local first = true
    
    local list = QuestHelper:GetOverlapObjectives(self.objective)
    
    for i, o in pairs(list) do
      if first then
        first = false
      else
        QuestHelper.tooltip:AddLine("|c80ff0000  .  .  .  .  .  .|r")
        QuestHelper.tooltip:GetPrevLines():SetFont("Fonts\\ARIALN.TTF", 8)
      end
      
      QuestHelper.tooltip:AddLine(o:Reason())
      QuestHelper.tooltip:GetPrevLines():SetFont("Fonts\\FRIZQT__.TTF", 14)
      QuestHelper.tooltip:AddDoubleLine("Estimated travel time: ", QuestHelper:TimeString(o.travel_time or 0))
      QuestHelper.tooltip:GetPrevLines():SetFont("Fonts\\ARIALN.TTF", 11)
      select(2, QuestHelper.tooltip:GetPrevLines()):SetFont("Fonts\\ARIALN.TTF", 11)
    end
    
    --QuestHelper.tooltip:SetText(text)
    QuestHelper.tooltip:Show()
    
    icon.show_glow = true
    
    local out = 1
    
    local w, h = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
    local _, x_size, y_size = QuestHelper.Astrolabe:ComputeDistance(c, z, 0.25, 0.25, c, z, 0.75, 0.75)
    
    x_size = math.max(25, 200 / x_size * w)
    y_size = math.max(25, 200 / y_size * h)
    
    
    
    for _, list in pairs(self.objective.p) do
      for _, p in ipairs(list) do
        local x, y = p[3], p[4]
        x, y = x / QuestHelper.continent_scales_x[p[1].c], y / QuestHelper.continent_scales_y[p[1].c]
        x, y = QuestHelper.Astrolabe:TranslateWorldMapPosition(p[1].c, 0, x, y, c, z)
        if x and y and x > 0 and y > 0 and x < 1 and y < 1 then
          tex = self.glow_list[out]
          if not tex then
            tex = QuestHelper:GetGlowTexture(self)
            table.insert(self.glow_list, tex)
          end
          out = out + 1
          
          tex:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", x*w, -y*h)
          tex:SetVertexColor(1,1,1,0)
          tex:SetWidth(x_size)
          tex:SetHeight(y_size)
          tex:Show()
          tex.max_alpha = 1/p[5]
        end
      end
    end
    
    for i = out,#self.glow_list do
      QuestHelper:ReleaseTexture(table.remove(self.glow_list))
    end
    
    self:SetScript("OnUpdate", self.OnUpdate)
  end
  
  function icon:OnLeave()
    QuestHelper.tooltip:Hide()
    self.show_glow = false
  end
  
  function icon:OnEvent(event)
    if self.objective then
      QuestHelper.Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self, convertLocation(self.objective.pos))
    else
      self:Hide()
    end
  end
  
  function icon:OnClick()
    if self.objective then
      local menu = QuestHelper:CreateMenu()
      local list, count = QuestHelper:GetOverlapObjectives(self.objective)
      local item
      
      if count > 1 then
        QuestHelper:CreateMenuTitle(menu, "Objectives")
        
        for i, o in pairs(list) do
          local submenu = QuestHelper:CreateMenu()
          item = QuestHelper:CreateMenuItem(menu, o:Reason(true))
          item:SetSubmenu(submenu)
          item:AddTexture(QuestHelper:GetIconTexture(item, o.icon_id), true)
          
          if QuestHelper.first_objective == o then
            item = QuestHelper:CreateMenuItem(submenu, "Place this objective for me.")
            item:SetFunction(function (obj) if QuestHelper.first_objective == obj then QuestHelper.first_objective = nil QuestHelper:ForceRouteUpdate() end end, o)
          elseif o:CouldBeFirst() then
            item = QuestHelper:CreateMenuItem(submenu, "Force this objective to be first.")
            item:SetFunction(function (obj) QuestHelper.first_objective = obj QuestHelper:ForceRouteUpdate() end, o)
          end
          
          item = QuestHelper:CreateMenuItem(submenu, "Ignore this objective.")
          item:SetFunction(function (obj) obj.user_ignore = true QuestHelper:ForceRouteUpdate() end, o)
        end
      else
        QuestHelper:CreateMenuTitle(menu, self.objective:Reason(true))
        
        if QuestHelper.first_objective == self.objective then
          item = QuestHelper:CreateMenuItem(menu, "Place this objective for me.")
          item:SetFunction(function (obj) if QuestHelper.first_objective == obj then QuestHelper.first_objective = nil QuestHelper:ForceRouteUpdate() end end, self.objective)
        elseif self.objective:CouldBeFirst() then
          item = QuestHelper:CreateMenuItem(menu, "Force this objective to be first.")
          item:SetFunction(function (obj) QuestHelper.first_objective = obj QuestHelper:ForceRouteUpdate() end, self.objective)
        end
        
        item = QuestHelper:CreateMenuItem(menu, "Ignore this objective.")
        item:SetFunction(function (obj) obj.user_ignore = true QuestHelper:ForceRouteUpdate() end, self.objective)
      end
      
      menu:SetCloseFunction(QuestHelper.ReleaseMenu, QuestHelper, menu)
      menu:ShowAtCursor()
    end
  end
  
  icon:SetScript("OnClick", icon.OnClick)
  icon:SetScript("OnEnter", icon.OnEnter)
  icon:SetScript("OnLeave", icon.OnLeave)
  icon:SetScript("OnEvent", icon.OnEvent)
  
  icon:RegisterForClicks("RightButtonUp")
  
  icon:RegisterEvent("WORLD_MAP_UPDATE")
  
  icon:SetObjective(objective, index)
  return icon
end

function QuestHelper:CreateMipmapDodad()
  local icon = CreateFrame("Button", nil, Minimap)
  icon:Hide()
  icon:SetHeight(20)
  icon:SetWidth(20)
  
  icon.recalc_timeout = 0
  
  icon.arrow = CreateFrame("Model", nil, icon)
  icon.arrow:SetHeight(140.8)
  icon.arrow:SetWidth(140.8)
  icon.arrow:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
  icon.arrow:SetModel("Interface\\Minimap\\Rotating-MinimapArrow.mdx")
  icon.arrow:Hide()
  
  icon.phase = 0
  icon.target = {0, 0, 0, 0}
  icon.icon_id = 7
  
  icon.bg = QuestHelper:GetIconTexture(icon, 16)
  icon.bg:SetDrawLayer("BACKGROUND")
  icon.bg:SetAllPoints()
  
  function icon:NextObjective()
    if not QuestHelper.route_sane then
      return self.objective
    end
    
    for i, o in ipairs(QuestHelper.route) do
      if not QuestHelper.to_remove[o] then
        return o
      end
    end
  end
  
  function icon:OnUpdate(elapsed)
    if self.objective then
      self:Show()
      
      if self.recalc_timeout == 0 then
        self.recalc_timeout = 50
        
        self.objective = self:NextObjective()
        
        if not self.objective then
          self:Hide()
          return
        end
        
        local path = QuestHelper:ComputeRoute(QuestHelper.pos, self.objective.pos)
        local t = self.target
        local id = self.objective.icon_id
        t[1], t[2], t[3], t[4] = convertLocation(self.objective.pos)
        t[5] = nil
        while path do
          if path.g > 10.0 then
            id = 8
            t[1] = path.c
            t[2] = 0
            t[3] = path.x / QuestHelper.continent_scales_x[path.c]
            t[4] = path.y / QuestHelper.continent_scales_y[path.c]
            t[5] = path.name or "waypoint"
          end
          path = path.p
        end
        
        if not self.dot or id ~= self.icon_id then
          self.icon_id = id
          if self.dot then QuestHelper:ReleaseTexture(self.dot) end
          self.dot = QuestHelper:GetIconTexture(self, self.icon_id)
          self.dot:SetPoint("TOPLEFT", icon, "TOPLEFT", 2, -2)
          self.dot:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
        end
        
        QuestHelper.Astrolabe:PlaceIconOnMinimap(self, unpack(self.target))
      else
        self.recalc_timeout = self.recalc_timeout - 1
      end
      
      local edge = QuestHelper.Astrolabe:IsIconOnEdge(self)
      
      if edge then
        self.arrow:Show()
        self.dot:Hide()
        self.bg:Hide()
      else
        self.arrow:Hide()
        self.dot:Show()
        self.bg:Show()
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
    else
      self:Hide()
    end
  end
  
  function icon:SetObjective(objective)
    if objective ~= self.objective then
      if objective then
        self:Show()
      else
        self:Hide()
      end
      
      self.objective = objective
      self.recalc_timeout = 0
    end
  end
  
  function icon:OnEnter()
    if self.objective then
      QuestHelper.tooltip:Show()
      QuestHelper.tooltip:SetOwner(self, "ANCHOR_CURSOR")
      if self.target[5] then
        QuestHelper.tooltip:SetText("Visit "..QuestHelper:HighlightText(self.target[5]).." en route to objective:\n"..self.objective:Reason())
      else
        QuestHelper.tooltip:SetText(self.objective:Reason())
      end
    end
  end
  
  function icon:OnLeave()
    QuestHelper.tooltip:Hide()
  end
  
  function icon:OnEvent()
    if self.objective then
      self:Show()
    else
      self:Hide()
    end
  end
  
  icon:SetScript("OnUpdate", icon.OnUpdate)
  icon:SetScript("OnEnter", icon.OnEnter)
  icon:SetScript("OnLeave", icon.OnLeave)
  icon:SetScript("OnEvent", icon.OnEvent)
  
  icon:RegisterEvent("PLAYER_ENTERING_WORLD")
  
  return icon
end

--[[function QuestHelper:CreateWorldGraphWalker()
  local walker = CreateFrame("Button", nil, WorldMapButton)
  walker:SetWidth(0)
  walker:SetHeight(0)
  walker:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 0, 0)
  walker:Show()
  
  walker.phase = 0.0
  walker.nodes = {}
  walker.used_nodes = 0
  walker.frame = self
  
  QuestHelper_Dump = {}
  
  for c, z1list in pairs(QuestHelper_ZoneTransition) do
    for z1, z2list in pairs(z1list) do
      for z2, poslist in pairs(z2list) do
        for i, pos in ipairs(poslist) do
          table.insert(QuestHelper_Dump, string.format("{%d, %d, %d, %.3f, %.3f}, -- %s <--> %s", c, z1, z2, pos[3], pos[4], select(z1, GetMapZones(c)), select(z2, GetMapZones(c))))
        end
      end
    end
  end
  
  function walker:OnUpdate(elapsed)
    local w, h = WorldMapDetailFrame:GetWidth(), -WorldMapDetailFrame:GetHeight()
    local pc, pz = GetCurrentMapContinent(), GetCurrentMapZone()
    
    --QuestHelper_ZoneTransition = QuestHelper_StaticData.enUS.zone_transition
    
    local count = 0
    for c, z1list in pairs(QuestHelper_ZoneTransition) do
      for z1, z2list in pairs(z1list) do
        for z2, poslist in pairs(z2list) do
          for i, pos in ipairs(poslist) do
            count = count + 1
            
            local node = self.nodes[count]
            if not node then
              node = CreateFrame("Button", nil, WorldMapButton)
              node:SetFrameStrata("FULLSCREEN_DIALOG")
              node:SetWidth(10)
              node:SetHeight(10)
              
              node.dot = node:CreateTexture()
              node.dot:SetTexture("Interface\\Minimap\\ObjectIcons")
              node.dot:SetTexCoord(0.280, 0.35, 0.09, 0.36)
              node.dot:SetVertexColor(0,0,0,1)
              node.dot:SetAllPoints()
              node.dot:Show()
              
              node:SetScript("OnEnter", function (self) QuestHelper.tooltip:Show()
              QuestHelper.tooltip:SetOwner(self, "ANCHOR_CURSOR")
              QuestHelper.tooltip:SetText(self.text) end)
              node:SetScript("OnLeave", function (self) QuestHelper.tooltip:Hide() end)
              
              function node:OnClick()
                local menu = QuestHelper:CreateMenu()
                QuestHelper:CreateMenuTitle(menu, "Delete node: "..self.text)
                
                local item
                
                item = QuestHelper:CreateMenuItem(menu, "Yes.")
                item:SetFunction(function (c, z1, z2, i) QuestHelper:TextOut(string.format("Asked to delete %d,%d,%d,%d", c, z1, z2, i)) table.remove(QuestHelper_ZoneTransition[c][z1][z2], i) end, self.c, self.z1, self.z2, self.i)
                
                item = QuestHelper:CreateMenuItem(menu, "No, WTF?! NO!")
                item:SetFunction(function () end)
                
                menu:SetCloseFunction(QuestHelper.ReleaseMenu, QuestHelper, menu)
                menu:ShowAtCursor()
              end
              
              node:SetScript("OnClick", node.OnClick)
              node:RegisterForClicks("RightButtonUp")
              
              self.nodes[count] = node
            end 
            
            node.c, node.z1, node.z2, node.i = c, z1, z2, i
            
            node:ClearAllPoints()
            
            local x, y = self.frame.Astrolabe:TranslateWorldMapPosition(pos[1], pos[2], pos[3], pos[4], pc, pz)
            
            if x and y then
              node:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", x*w, y*h)
              node:Show()
              node.text = select(z1, GetMapZones(c)).." to "..select(z2, GetMapZones(c))
            else
              node:Hide()
            end
          end
        end
      end
    end
    
    for i = count+1,self.used_nodes do
      self.nodes[i]:Hide()
    end
    
    self.used_nodes = #self.frame.world_graph.nodes
  end
  
  walker:RegisterEvent("WORLD_MAP_UPDATE")
  
  walker:SetScript("OnUpdate", walker.OnUpdate)
end]]
