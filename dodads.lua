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

local function convertNodeToScreen(n, c, z)
  return QuestHelper.Astrolabe:TranslateWorldMapPosition(n.c, 0, n.x/QuestHelper.continent_scales_x[n.c], n.y/QuestHelper.continent_scales_y[n.c], c, z)
end

QuestHelper.map_overlay = CreateFrame("FRAME", nil, WorldMapButton)
QuestHelper.map_overlay:SetFrameLevel(WorldMapButton:GetFrameLevel()+1)
QuestHelper.map_overlay:SetAllPoints()
QuestHelper.map_overlay:SetFrameStrata("FULLSCREEN")

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

local function pushPath(list, path, c, z)
  if path then
    pushPath(list, path.p, c, z)
    local t = QuestHelper:CreateTable()
    t[1], t[2] = QuestHelper.Astrolabe:TranslateWorldMapPosition(path.c, 0, path.x/QuestHelper.continent_scales_x[path.c], path.y/QuestHelper.continent_scales_y[path.c], c, z)
    table.insert(list, t)
  end
end

function QuestHelper:CreateWorldMapWalker()
  local walker = CreateFrame("Button", nil, QuestHelper.map_overlay)
  walker:SetWidth(0)
  walker:SetHeight(0)
  walker:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 0, 0)
  walker:Show()
  
  walker.phase = 0.0
  walker.dots = {}
  walker.points = {}
  walker.origin = {}
  walker.frame = self
  walker.map_dodads = {}
  walker.used_map_dodads = 0
  
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
              dot = QuestHelper:CreateDotTexture(self)
              dot:SetDrawLayer("BACKGROUND")
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
  end
  
  function walker:RouteChanged()
    if self.frame.Astrolabe.WorldMapVisible then
      local points = self.points
      local cur = self.frame.pos
      
      while #points > 0 do self.frame:ReleaseTable(table.remove(points)) end
      
      local travel_time = 0.0
      
      local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
      
      for i, obj in pairs(self.frame.route) do
        local path, d = self.frame:ComputeRoute(cur, obj.pos)
        
        pushPath(points, path, c, z)
        
        travel_time = travel_time + d
        obj.travel_time = travel_time
        
        cur = obj.pos
        
        local t = self.frame:CreateTable()
        t[1], t[2] = convertLocationToScreen(cur, c, z)
        
        table.insert(points, t)
      end
      
      if not self.frame.limbo_node then
        for i = 1, #self.frame.route do
          local dodad = self.map_dodads[i]
          if not dodad then
            self.map_dodads[i] = self.frame:CreateWorldMapDodad(self.frame.route[i], i)
          else
            self.map_dodads[i]:SetObjective(self.frame.route[i], i)
          end
        end
        
        for i = #self.frame.route+1,self.used_map_dodads do
          self.map_dodads[i]:SetObjective(nil, 0)
        end
        
        self.used_map_dodads = #self.frame.route
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
  
  local list = self.overlap_list
  
  if not list then
    list = {}
    self.overlap_list = list
  else
    while table.remove(list) do end
  end
  
  local cx, cy = GetCursorPosition()
  
  local es = WorldMapDetailFrame:GetEffectiveScale()
  local ies = 1/es
  
  cx, cy = (cx-WorldMapDetailFrame:GetLeft()*es)*ies, (WorldMapDetailFrame:GetTop()*es-cy)*ies
  
  local s = 10*QuestHelper_Pref.scale
  
  if self.limbo_node then
    local o = self.limbo_node
    local x, y = o.pos[3], o.pos[4]
    x, y = x / self.continent_scales_x[o.pos[1].c], y / self.continent_scales_y[o.pos[1].c]
    x, y = self.Astrolabe:TranslateWorldMapPosition(o.pos[1].c, 0, x, y, c, z)
    
    if x and y and x > 0 and y > 0 and x < 1 and y < 1 then
      x, y = x*w, y*h
      
      if cx >= x-s and cy >= y-s and cx <= x+s and cy <= y+s then
        table.insert(list, o)
      end
    end
  end
  
  for i, o in ipairs(self.route) do
    if o == obj then
      table.insert(list, o)
    else
      local x, y = o.pos[3], o.pos[4]
      x, y = x / self.continent_scales_x[o.pos[1].c], y / self.continent_scales_y[o.pos[1].c]
      x, y = self.Astrolabe:TranslateWorldMapPosition(o.pos[1].c, 0, x, y, c, z)
      
      if x and y and x > 0 and y > 0 and x < 1 and y < 1 then
        x, y = x*w, y*h
        
        if cx >= x-s and cy >= y-s and cx <= x+s and cy <= y+s then
          table.insert(list, o)
        end
      end
    end
  end
  
  table.sort(list, function(a, b) return (a.travel_time or 0) < (b.travel_time or 0) end)
  
  return list
end

local prog_sort_table = {}

function QuestHelper:AppendObjectiveToTooltip(o)
  local theme = self:GetColourTheme()
  
  self.tooltip:AddLine(o:Reason(), unpack(theme.tooltip))
  self.tooltip:GetPrevLines():SetFont("Fonts\\FRIZQT__.TTF", 14)
  
  if o.progress then
    for user, progress in pairs(o.progress) do
      table.insert(prog_sort_table, user)
    end
    
    table.sort(prog_sort_table, function(a, b)
      if o.progress[a][3] < o.progress[b][3] then
        return true
      elseif o.progress[a][3] == o.progress[b][3] then
        return a < b
      end
      return false
    end)
    
    for i, u in ipairs(prog_sort_table) do
      self.tooltip:AddDoubleLine(u.."'s progress:",
                                 self:ProgressString(o.progress[u][1].."/"..o.progress[u][2],
                                 o.progress[u][3]), unpack(theme.tooltip))
      
      self.tooltip:GetPrevLines():SetFont("Fonts\\ARIALN.TTF", 13)
      select(2, self.tooltip:GetPrevLines()):SetFont("Fonts\\ARIALN.TTF", 13)
    end
    
    while table.remove(prog_sort_table) do end
  end
  
  QuestHelper.tooltip:AddDoubleLine("Estimated travel time:", QuestHelper:TimeString(o.travel_time or 0), unpack(theme.tooltip))
  QuestHelper.tooltip:GetPrevLines():SetFont("Fonts\\ARIALN.TTF", 11)
  select(2, QuestHelper.tooltip:GetPrevLines()):SetFont("Fonts\\ARIALN.TTF", 11)
end

function QuestHelper:CreateWorldMapDodad(objective, index)
  local icon = CreateFrame("Button", nil, QuestHelper.map_overlay)
  icon:SetFrameStrata("FULLSCREEN")
  
  function icon:SetTooltip(list)
    QuestHelper.tooltip:SetOwner(self, "ANCHOR_CURSOR")
    QuestHelper.tooltip:ClearLines()
    
    local first = true
    
    for i, o in ipairs(list) do
      if first then
        first = false
      else
        QuestHelper.tooltip:AddLine("|c80ff0000  .  .  .  .  .  .|r")
        QuestHelper.tooltip:GetPrevLines():SetFont("Fonts\\ARIALN.TTF", 8)
      end
      
      QuestHelper:AppendObjectiveToTooltip(o)
    end
    
    QuestHelper.tooltip:Show()
  end
  
  function icon:SetObjective(objective, i)
    self:SetHeight(20*QuestHelper_Pref.scale)
    self:SetWidth(20*QuestHelper_Pref.scale)
    
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
        self.bg = QuestHelper:CreateIconTexture(self, 13)
      else
        self.bg = QuestHelper:CreateIconTexture(self, objective.icon_bg)
      end
      
      self.dot = QuestHelper:CreateIconTexture(self, objective.icon_id)
      
      self.bg:SetDrawLayer("BACKGROUND")
      self.bg:SetAllPoints()
      self.dot:SetPoint("TOPLEFT", self, "TOPLEFT", 3*QuestHelper_Pref.scale, -3*QuestHelper_Pref.scale)
      self.dot:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3*QuestHelper_Pref.scale, 3*QuestHelper_Pref.scale)
      
      QuestHelper.Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self, convertLocation(objective.pos))
    else
      self.objective = nil
      self:Hide()
    end
  end
  
  function icon:SetGlow(list)
    local w, h = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
    local _, x_size, y_size = QuestHelper.Astrolabe:ComputeDistance(c, z, 0.25, 0.25, c, z, 0.75, 0.75)
    
    x_size = math.max(25, 200 / x_size * w)
    y_size = math.max(25, 200 / y_size * h)
    
    local out = 1
    for _, objective in ipairs(list) do 
      if objective.p then for _, list in pairs(objective.p) do
        for _, p in ipairs(list) do
          local x, y = p[3], p[4]
          x, y = x / QuestHelper.continent_scales_x[p[1].c], y / QuestHelper.continent_scales_y[p[1].c]
          x, y = QuestHelper.Astrolabe:TranslateWorldMapPosition(p[1].c, 0, x, y, c, z)
          if x and y and x > 0 and y > 0 and x < 1 and y < 1 then
            if not self.glow_list then
              self.glow_list = QuestHelper:CreateTable()
            end
            
            tex = self.glow_list[out]
            if not tex then
              tex = QuestHelper:CreateGlowTexture(self)
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
        end end
      end
    end
    
    if self.glow_list then
      for i = out,#self.glow_list do
        QuestHelper:ReleaseTexture(table.remove(self.glow_list))
      end
      
      if #self.glow_list == 0 then
        QuestHelper:ReleaseTable(self.glow_list)
        self.glow_list = nil
      end
    end
  end
  
  icon.show_glow = false
  icon.glow_pct = 0.0
  icon.phase = 0.0
  icon.old_count = 0
  
  function icon:OnUpdate(elapsed)
    self.phase = (self.phase + elapsed)%6.283185307179586476925286766559005768394338798750211641949889185
    
    if self.old_count > 0 then
      local list = QuestHelper:GetOverlapObjectives(self.objective)
      if #list ~= self.old_count then
        self:SetTooltip(list)
        self.old_count = #list
        self:SetGlow(list)
      end
    end
    
    if self.show_glow then
      self.glow_pct = math.min(1, self.glow_pct+elapsed*1.5)
    else
      self.glow_pct = math.max(0, self.glow_pct-elapsed*0.5)
      
      if self.glow_pct == 0 then
        if self.glow_list then
          while #self.glow_list > 0 do
            QuestHelper:ReleaseTexture(table.remove(self.glow_list))
          end
          QuestHelper:ReleaseTable(self.glow_list)
          self.glow_list = nil
        end
        
        self:SetScript("OnUpdate", nil)
        return
      end
    end
    
    if self.glow_list then
      local r, g, b = math.sin(self.phase)*0.25+0.75,
                      math.sin(self.phase+2.094395102393195492308428922186335256131446266250070547316629728)*0.25+0.75,
                      math.sin(self.phase+4.188790204786390984616857844372670512262892532500141094633259456)*0.25+0.75
      
      for i, tex in ipairs(self.glow_list) do
        tex:SetVertexColor(r, g, b, self.glow_pct*tex.max_alpha)
      end
    end
  end
  
  function icon:OnEnter()
    local list = QuestHelper:GetOverlapObjectives(self.objective)
    self:SetTooltip(list)
    self.old_count = #list
    
    icon.show_glow = true
    
    self:SetGlow(list)
    
    self:SetScript("OnUpdate", self.OnUpdate)
  end
  
  function icon:OnLeave()
    QuestHelper.tooltip:Hide()
    self.show_glow = false
    self.old_count = 0
  end
  
  function icon:OnEvent(event)
    if self.objective and self.objective.pos then
      QuestHelper.Astrolabe:PlaceIconOnWorldMap(WorldMapDetailFrame, self, convertLocation(self.objective.pos))
    else
      self.objective = nil
      self:Hide()
    end
  end
  
  function icon:OnClick()
    if self.objective then
      local menu = QuestHelper:CreateMenu()
      local list = QuestHelper:GetOverlapObjectives(self.objective)
      local item
      
      if #list > 1 then
        QuestHelper:CreateMenuTitle(menu, "Objectives")
        
        for i, o in ipairs(list) do
          local submenu = QuestHelper:CreateMenu()
          item = QuestHelper:CreateMenuItem(menu, o:Reason(true))
          item:SetSubmenu(submenu)
          item:AddTexture(QuestHelper:CreateIconTexture(item, o.icon_id), true)
          QuestHelper:AddObjectiveOptionsToMenu(o, submenu)
        end
      else
        QuestHelper:CreateMenuTitle(menu, self.objective:Reason(true))
        QuestHelper:AddObjectiveOptionsToMenu(self.objective, menu)
      end
      
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

local function QH_CartographerWaypoint_Cancel(self)
  self.task = nil
  
  if QuestHelper.cartographer_wp == self then
    QuestHelper.cartographer_wp = nil
  end
  
  Waypoint.Cancel(self)
end

local function QH_CartographerWaypoint_ToString(self)
  return self.task
end

function QuestHelper:CreateMipmapDodad()
  local icon = CreateFrame("Button", nil, Minimap)
  icon:Hide()
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
  
  icon.bg = QuestHelper:CreateIconTexture(icon, 16)
  icon.bg:SetDrawLayer("BACKGROUND")
  icon.bg:SetAllPoints()
  
  function icon:NextObjective()
    if QuestHelper.limbo_node then
      -- If an objective is in limbo, don't try to figure out the next objective, because the node in limbo isn't it.
      return self.objective.pos and self.objective or nil
    end
    
    for i, o in ipairs(QuestHelper.route) do
      if not QuestHelper.to_remove[o] and o.pos then
        return o
      end
    end
    
    return nil
  end
  
  function icon:OnUpdate(elapsed)
    if self.objective then
      if not self.objective.pos then
        self.objective = self:NextObjective()
        if not self.objective then
          self:Hide()
          return
        end
      end
      
      self:Show()
      
      if self.recalc_timeout == 0 then
        self.recalc_timeout = 50
        
        self.objective = self:NextObjective()
        
        if not self.objective then
          self:Hide()
          return
        end
        
        local path, travel_time = QuestHelper:ComputeRoute(QuestHelper.pos, self.objective.pos)
        local t = self.target
        local id = self.objective.icon_id
        t[1], t[2], t[3], t[4] = convertLocation(self.objective.pos)
        t[5] = nil
        
        self.objective.travel_time = travel_time
        
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
          self.dot = QuestHelper:CreateIconTexture(self, self.icon_id)
          self.dot:SetPoint("TOPLEFT", icon, "TOPLEFT", 2, -2)
          self.dot:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
        end
        
        if QuestHelper_Pref.cart_wp and Cartographer_Waypoints and Waypoint then
          local x, y = QuestHelper.Astrolabe:TranslateWorldMapPosition(t[1], t[2], t[3], t[4], t[1], QuestHelper.z)
          local z = select(QuestHelper.z, GetMapZones(t[1]))
          
          if QuestHelper.cartographer_wp and (QuestHelper.cartographer_wp.x ~= x or QuestHelper.cartographer_wp.y ~= y or QuestHelper.cartographer_wp.Zone ~= z) then
            QuestHelper.cartographer_wp:Cancel()
            QuestHelper.cartographer_wp = nil
          end
          
          local owp = QuestHelper.old_cartographer_wp_data
          if not owp then
            owp = QuestHelper:CreateTable()
            QuestHelper.old_cartographer_wp_data = owp
          end
          
          if not QuestHelper.cartographer_wp and (not owp or owp.x ~= x or owp.y ~= y or owp.z ~= z) then
            local wp = Waypoint:new()
            wp.Cancel = QH_CartographerWaypoint_Cancel
            wp.ToString = QH_CartographerWaypoint_ToString
            
            wp.x, wp.y, wp.Zone, wp.task = x, y, z, t[5] and ("Visit "..QuestHelper:HighlightText(t[5]).." en route to:\n"..self.objective:Reason(true)) or self.objective:Reason(true)
            owp.x, owp.y, owp.z = wp.x, wp.y, wp.Zone
            Cartographer_Waypoints:AddWaypoint(wp)
            QuestHelper.cartographer_wp = wp
          end
        elseif QuestHelper.cartographer_wp then
          QuestHelper.cartographer_wp:Cancel()
          QuestHelper.cartographer_wp = nil
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
    self:SetHeight(20*QuestHelper_Pref.scale)
    self:SetWidth(20*QuestHelper_Pref.scale)
    
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
      QuestHelper.tooltip:SetOwner(self, "ANCHOR_CURSOR")
      QuestHelper.tooltip:ClearLines()
      
      if self.target[5] then
        QuestHelper.tooltip:AddLine("Visit "..QuestHelper:HighlightText(self.target[5]).." en route to objective:", unpack(QuestHelper:GetColourTheme().tooltip))
        QuestHelper.tooltip:GetPrevLines():SetFont("Fonts\\FRIZQT__.TTF", 14)
      end
      
      QuestHelper:AppendObjectiveToTooltip(self.objective)
      QuestHelper.tooltip:Show()
    end
  end
  
  function icon:OnLeave()
    QuestHelper.tooltip:Hide()
  end
  
  function icon:OnClick()
    if self.objective then
      local menu = QuestHelper:CreateMenu()
      QuestHelper:CreateMenuTitle(menu, self.objective:Reason(true))
      QuestHelper:AddObjectiveOptionsToMenu(self.objective, menu)
      menu:ShowAtCursor()
    end
  end
  
  function icon:OnEvent()
    if self.objective and self.objective.pos then
      self:Show()
    else
      self:Hide()
    end
  end
  
  icon:SetScript("OnUpdate", icon.OnUpdate)
  icon:SetScript("OnEnter", icon.OnEnter)
  icon:SetScript("OnLeave", icon.OnLeave)
  icon:SetScript("OnEvent", icon.OnEvent)
  icon:SetScript("OnClick", icon.OnClick)
  
  icon:RegisterForClicks("RightButtonUp")
  icon:RegisterEvent("PLAYER_ENTERING_WORLD")
  
  return icon
end

function QuestHelper:CreateWorldGraphWalker()
  local walker = CreateFrame("Button", nil, QuestHelper.map_overlay)
  walker:SetWidth(0)
  walker:SetHeight(0)
  walker:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 0, 0)
  walker:Show()
  
  walker.phase = 0.0
  walker.dots = {}
  walker.points = {}
  walker.origin = {}
  walker.frame = self
  
  function walker:OnUpdate(elapsed)
    local points = self.points
    
    self.phase = (self.phase + elapsed * 0.66)%1
    
    local w, h = WorldMapDetailFrame:GetWidth(), -WorldMapDetailFrame:GetHeight()
    local remainder, out = self.phase, 0
    
    for i, line in ipairs(points) do
      local x1, y1, x2, y2 = ClampLine(unpack(line))
      
      if x1 then
        local len = math.sqrt((x1-x2)*(x1-x2)*16/9+(y1-y2)*(y1-y2))
        
        if len > 0.0001 then
          local interval = .06/len
          local p = remainder*interval
          
          while p < 1 do
            out = out + 1
            local dot = self.dots[out]
            if not dot then
              dot = QuestHelper:CreateDotTexture(self)
              dot:SetDrawLayer("BACKGROUND")
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
  end
  
  function walker:GraphChanged()
    if self.frame.Astrolabe.WorldMapVisible then
      local points = self.points
      local cur = self.frame.pos
      
      while #points > 0 do self.frame:ReleaseTable(table.remove(points)) end
      
      local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
      
      for i, node in ipairs(self.frame.world_graph.nodes) do
        local x1, y1 = convertNodeToScreen(node, c, z)
        for dest in pairs(node.n) do
          local t = self.frame:CreateTable()
          t[1], t[2], t[3], t[4] = ClampLine(x1, y1, convertNodeToScreen(dest, c, z))
          if t[1] and t[2] and t[3] and t[4] then
            table.insert(points, t)
          else
            self.frame:ReleaseTable(t)
          end
        end
      end
    end
  end
  
  walker:SetScript("OnEvent", walker.GraphChanged)
  walker:RegisterEvent("WORLD_MAP_UPDATE")
  
  walker:SetScript("OnUpdate", walker.OnUpdate)
  
  return walker
end