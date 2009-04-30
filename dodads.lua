QuestHelper_File["dodads.lua"] = "Development Version"
QuestHelper_Loadtime["dodads.lua"] = GetTime()

local ofs = 0.000723339 * (GetScreenHeight()/GetScreenWidth() + 1/3) * 70.4;
local radius = ofs / 1.166666666666667;

-- These conversions are nasty, and this entire section needs a serious cleanup.
local function convertLocation(p)
  local c, x, y = QuestHelper.Astrolabe:FromAbsoluteContinentPosition(p.c, p.x, p.y)
  return c, 0, x, y
end

local function convertLocationToScreen(p, c, z)
  local pc, _, px, py = convertLocation(p)
  local ox, oy = QuestHelper.Astrolabe:TranslateWorldMapPosition(pc, 0, px, py, c, z)
  --QuestHelper:TextOut(string.format("%f/%f/%f to %f/%f/%f to %f/%f %f/%f", p.c, p.x, p.y, pc, px, py, c, z, ox, oy))
  return ox, oy
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

local walker_loc

function QuestHelper:CreateWorldMapWalker()
  local walker = CreateFrame("Button", nil, QuestHelper.map_overlay)
  walker_loc = walker
  walker:SetWidth(0)
  walker:SetHeight(0)
  walker:SetPoint("CENTER", QuestHelper.map_overlay, "TOPLEFT", 0, 0)
  walker:Show()
  
  walker.phase = 0.0
  walker.dots = {}
  walker.points = {}
  walker.origin = {}
  walker.frame = self
  walker.map_dodads = {}
  walker.used_map_dodads = 0
  
  QuestHelper: Assert(self == QuestHelper)
  QuestHelper: Assert(self.Astrolabe)
  
  function walker:OnUpdate(elapsed)
    local out = 0
    
    if QuestHelper_Pref.show_ants then
      local points = self.points
      
      self.phase = self.phase + elapsed * 0.66
      while self.phase > 1 do self.phase = self.phase - 1 end
      
      local w, h = QuestHelper.map_overlay:GetWidth(), -QuestHelper.map_overlay:GetHeight()
      
      local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
      
      local last_x, last_y = self.frame.Astrolabe:TranslateWorldMapPosition(self.frame.c, self.frame.z, self.frame.x, self.frame.y, c, z)
      local remainder = self.phase
      
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
              dot:SetPoint("CENTER", QuestHelper.map_overlay, "TOPLEFT", x1*w*(1-p)+x2*w*p, y1*h*(1-p)+y2*h*p)
              
              p = p + interval
            end
            
            remainder = (p-1)/interval
          end
        end
      end
    end
    
    while #self.dots > out do
      QuestHelper:ReleaseTexture(table.remove(self.dots))
    end
  end
  
  function walker:RouteChanged(route)
    if route then self.route = route end -- we cache it so we can refer to it later when the world map changes
    if not self.route then return end
    
    local dbgstr = string.format("%s %s %s %s", tostring(self), tostring(self.frame), tostring(QuestHelper), tostring(QuestHelper and QuestHelper.Astrolabe))
    QuestHelper: Assert(self.frame == QuestHelper, dbgstr)
    QuestHelper: Assert(QuestHelper.Astrolabe, dbgstr)
    
    if self.frame.Astrolabe.WorldMapVisible then
      local points = self.points
      local cur = self.frame.pos
      
      while #points > 0 do self.frame:ReleaseTable(table.remove(points)) end
      
      local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
      
      -- I'm not quite sure what the point of this is.
      --[[
      if self.frame.target then
        travel_time = math.max(0, self.frame.target_time-time())
        cur = self.frame.target
        local t = self.frame:CreateTable()
        t[1], t[2] = convertLocationToScreen(cur, c, z)
        table.insert(points, t)
      end]]
      
      for i, obj in ipairs(self.route) do
        --QuestHelper:TextOut(string.format("%s", tostring(obj)))
        
        --[[
        local t = QuestHelper:CreateTable()
        t[1], t[2] = convertLocationToScreen(obj.loc, c, z)
        
        table.insert(list, t)]]
        
        -- We're ignoring travel time for now.
        --[[
        travel_time = travel_time + 60
        obj.travel_time = travel_time]]
        if i > 1 then -- skip the start location
          local t = self.frame:CreateTable()
          t[1], t[2] = convertLocationToScreen(obj.loc, c, z)
          
          table.insert(points, t)
          
          --if lotsup then print(obj.ignore, obj.loc.x, obj.loc.y, obj.loc.c) end
        end
        --QuestHelper:TextOut(string.format("%s/%s/%s to %s/%s", tostring(obj.c), tostring(obj.x), tostring(obj.y), tostring(t[1]), tostring(t[2])))
      end
      --lotsup = false
      
      local cur_dodad = 1
      for i = 2, #self.route do -- 2 because we're skipping the player
        if not self.route[i].ignore then
          local dodad = self.map_dodads[cur_dodad]
          if not dodad then
            self.map_dodads[cur_dodad] = self.frame:CreateWorldMapDodad(self.route[i], i == 2)
          else
            self.map_dodads[cur_dodad]:SetObjective(self.route[i], i == 2)
          end
          cur_dodad = cur_dodad + 1
        end
      end

      if cur_dodad <= self.used_map_dodads then for i = cur_dodad,self.used_map_dodads do
        self.map_dodads[i]:SetObjective(nil, false)
      end end

      self.used_map_dodads = cur_dodad - 1
    end
  end
  
  walker:SetScript("OnEvent", function () walker:RouteChanged() end)  -- we do this just to strip the parameters out
  walker:RegisterEvent("WORLD_MAP_UPDATE")
  
  walker:SetScript("OnUpdate", walker.OnUpdate)
  
  return walker
end

function QuestHelper:GetOverlapObjectives(obj)
  local w, h = self.map_overlay:GetWidth(), self.map_overlay:GetHeight()
  local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
  
  local list = self.overlap_list
  
  if not list then
    list = {}
    self.overlap_list = list
  else
    while table.remove(list) do end
  end
  
  local cx, cy = GetCursorPosition()
  
  local es = QuestHelper.map_overlay:GetEffectiveScale()
  local ies = 1/es
  
  cx, cy = (cx-self.map_overlay:GetLeft()*es)*ies, (self.map_overlay:GetTop()*es-cy)*ies
  
  local s = 10*QuestHelper_Pref.scale
  
  for i, o in ipairs(walker_loc.route) do
    --QuestHelper: Assert(o, string.format("nil dodads pos issue, o %s", tostring(o)))
    --QuestHelper: Assert(o.pos, string.format("nil dodads pos issue, pos %s", QuestHelper:StringizeTable(o)))
    if not o.ignore then
      if o == obj then
        table.insert(list, o)
      else
        local x, y = convertLocationToScreen(o.loc, c, z)
        
        if x and y and x > 0 and y > 0 and x < 1 and y < 1 then
          x, y = x*w, y*h
          
          if cx >= x-s and cy >= y-s and cx <= x+s and cy <= y+s then
            table.insert(list, o)
          end
        end
      end
    end
  end
  
  table.sort(list, function(a, b) return (a.distance or 0) < (b.distance or 0) end)
  
  return list
end

function QuestHelper:AppendObjectiveProgressToTooltip(o, tooltip, font, depth)
  if o.progress then
    local prog_sort_table = {}
  
    local theme = self:GetColourTheme()
    
    local indent = ("  "):rep(depth or 0)
    
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
      tooltip:AddDoubleLine(indent..QHFormat("PEER_PROGRESS", u),
                            self:ProgressString(o.progress[u][1].."/"..o.progress[u][2],
                            o.progress[u][3]), unpack(theme.tooltip))
      
      if font then
        local last, name = tooltip:NumLines(), tooltip:GetName()
        local left, right = _G[name.."TextLeft"..last], _G[name.."TextRight"..last]
        
        left:SetFont(font, 13)
        right:SetFont(font, 13)
      end
    end
    
    while table.remove(prog_sort_table) do end
  end
end

function QuestHelper:AppendObjectiveToTooltip(o)
  local theme = self:GetColourTheme()
  
  QuestHelper: Assert(o.map_desc)
  for _, v in ipairs(o.map_desc) do
    self.tooltip:AddLine(v, unpack(theme.tooltip))
    self.tooltip:GetPrevLines():SetFont(self.font.serif, 14)
  end
  
  if o.map_desc_chain then
    self:AppendObjectiveToTooltip(o.map_desc_chain)
  else
    self:AppendObjectiveProgressToTooltip(o, self.tooltip, QuestHelper.font.sans)
    
    self.tooltip:AddDoubleLine(QHText("TRAVEL_ESTIMATE"), QHFormat("TRAVEL_ESTIMATE_VALUE", o.distance or 0), unpack(theme.tooltip))
    self.tooltip:GetPrevLines():SetFont(self.font.sans, 11)
    select(2, self.tooltip:GetPrevLines()):SetFont(self.font.sans, 11)
  end
end

globx = 0.5
globy = 0.5

function QuestHelper:CreateWorldMapDodad(objective, nxt)
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
        QuestHelper.tooltip:GetPrevLines():SetFont(QuestHelper.font.sans, 8)
      end
      
      QuestHelper:AppendObjectiveToTooltip(o)
    end
    
    QuestHelper.tooltip:Show()
  end
  
  function icon:SetObjective(objective, nxt)
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
      
      if nxt then
        self.bg = QuestHelper:CreateIconTexture(self, 13)
      elseif objective.map_highlight then
        self.bg = QuestHelper:CreateIconTexture(self, 14)
      else
        self.bg = QuestHelper:CreateIconTexture(self, 16)
      end
      
      self.dot = QuestHelper:CreateIconTexture(self, objective.icon_id or 8)
      
      self.bg:SetDrawLayer("BACKGROUND")
      self.bg:SetAllPoints()
      self.dot:SetPoint("TOPLEFT", self, "TOPLEFT", 3*QuestHelper_Pref.scale, -3*QuestHelper_Pref.scale)
      self.dot:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3*QuestHelper_Pref.scale, 3*QuestHelper_Pref.scale)
      
      QuestHelper.Astrolabe:PlaceIconOnWorldMap(QuestHelper.map_overlay, self, convertLocation(objective.loc))
      --QuestHelper.Astrolabe:PlaceIconOnWorldMap(QuestHelper.map_overlay, self, 0, 0, globx, globy)
    else
      self.objective = nil
      self:Hide()
    end
  end
  
  function icon:SetGlow(list)
    local w, h = QuestHelper.map_overlay:GetWidth(), QuestHelper.map_overlay:GetHeight()
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone()
    
    local nodes = {}
    
    for _, v in ipairs(list) do 
      if v.cluster then
        for _, i in ipairs(v.cluster) do
          nodes[i] = true
        end
      else
        nodes[v] = true
      end
    end
    
    
    local out = 1
    for obj, _ in pairs(nodes) do
      local x, y = convertLocationToScreen(obj.loc, c, z)
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
        
        tex:SetPoint("CENTER", QuestHelper.map_overlay, "TOPLEFT", x*w, -y*h)
        tex:SetVertexColor(1,1,1,0)
        tex:SetWidth(h / 4) -- we want it to be a circle
        tex:SetHeight(h / 4)
        tex:Show()
        tex.max_alpha = 1
      end
    end
    
    if self.glow_list then
      while #self.glow_list >= out do
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
      -- You know, these numbers are harmonics of pi. Would SETI detected them, or would they just be seen as noise?
      -- I'd vote for the later.
      --
      -- Pi - circumference over diameter - when was the last time you actually cared about diameters in math?
      -- 
      -- Pretty much everything in computer geometry depends on the pythagorean theorem, which you can use for
      -- circles, spheres, and hyper-spheres, if you use radius.
      -- 
      -- It's even the basis of special relativity, with time being multiplied by c so that you get a distance
      -- that you can use with the spatial dimensions. We're all in agreement that space traveling aliens are
      -- going to know about relativity, right?
      -- 
      -- And if you ever do trig, a full circle would be exactly (circumference over radius) radians instead of
      -- (circumference over diameter)*2 radians.
      -- 
      -- Obviously aliens are much more likely to prefer 6.283185307179586... as constant than our pi.
      --
      -- Important update: I just noticed that large factorials can be approximated using (2*pi*n)^.5*(n/e)^n
      -- There's that 2 times pi thing again.
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
    if self.objective then
      QuestHelper.Astrolabe:PlaceIconOnWorldMap(QuestHelper.map_overlay, self, convertLocation(self.objective.loc))
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
          item = QuestHelper:CreateMenuItem(menu, o.map_desc[1])
          item:SetSubmenu(submenu)
          item:AddTexture(QuestHelper:CreateIconTexture(item, o.icon_id), true)
          QuestHelper:AddObjectiveOptionsToMenu(o, submenu)
        end
      else
        QuestHelper:CreateMenuTitle(menu, self.objective.map_desc[1])
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
  
  icon:SetObjective(objective, nxt)
  return icon
end

local callbacks = {}
local last_c, last_z, last_x, last_y, last_desc

function QuestHelper:AddWaypointCallback(func, ...)
  local cb = self:CreateTable()
  callbacks[cb] = true
  local len = select("#", ...)
  cb.len = len
  cb.func = func
  for i = 1,len do cb[i] = select(i, ...) end
  cb[len+1] = last_c
  cb[len+2] = last_z
  cb[len+3] = last_x
  cb[len+4] = last_y
  cb[len+5] = last_desc
  
  if last_c then
    func(unpack(cb, 1, len+5))
  end
  
  return cb
end

function QuestHelper:RemoveWaypointCallback(cb)
  callbacks[cb] = nil
  self:ReleaseTable(cb)
end

function QuestHelper:InvokeWaypointCallbacks(c, z, x, y, desc)
  QuestHelper: Assert(not c or type(c) == "number")
  QuestHelper: Assert(not z or type(z) == "number")
  QuestHelper: Assert(not x or type(x) == "number")
  QuestHelper: Assert(not y or type(y) == "number")
  if c ~= last_c or z ~= last_z or x ~= last_x or y ~= last_y or desc ~= last_desc then
    last_c, last_z, last_x, last_y, last_desc = c, z, x, y, desc
    for cb in pairs(callbacks) do
      local len = cb.len
      cb[len+1] = c
      cb[len+2] = z
      cb[len+3] = x
      cb[len+4] = y
      cb[len+5] = desc
      cb.func(unpack(cb, 1, len+5))
    end
  end
end

--[[ Small parts of the arrow rendering code are thanks to Tomtom, with the following license:

-------------------------------------------------------------------------
  Copyright (c) 2006-2007, James N. Whitehead II
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * The name or alias of the copyright holder may not be used to endorse 
        or promote products derived from this software without specific prior
        written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]

function QuestHelper:CreateMipmapDodad()
  local icon = CreateFrame("Button", nil, Minimap)
  icon:Hide()
  icon.recalc_timeout = 0
  
  icon.arrow = icon:CreateTexture("BACKGROUND")
  icon.arrow:SetHeight(40)
  icon.arrow:SetWidth(40)
  icon.arrow:SetPoint("CENTER", 0, 0)
  icon.arrow:SetTexture("Interface\\AddOns\\QuestHelper\\MinimapArrow")
  icon.arrow:Hide()
  
  icon.phase = 0
  icon.target = {0, 0, 0, 0}
  
  icon.bg = QuestHelper:CreateIconTexture(icon, 16)
  icon.bg:SetDrawLayer("BACKGROUND")
  icon.bg:SetAllPoints()
  
  function icon:OnUpdate(elapsed)
    if self.obj and not QuestHelper.InBrokenInstance then
      self:Show() -- really only triggers if the non-broken-instance code is being poked
      
      -- Deal with waypoint callbacks
      if QuestHelper_Pref.hide or UnitIsDeadOrGhost("player") then
        QuestHelper:InvokeWaypointCallbacks()
      else
        local c, z = QuestHelper.collect_rc or 0, QuestHelper.collect_rz or 0
        local x, y = convertLocationToScreen(self.obj.loc, c, z)
        --QuestHelper:TextOut(string.format("internal: %f %f %f %f or %f %f %f", c, z, x, y, self.obj.loc.c, self.obj.loc.x, self.obj.loc.y))
        
        local textdesc
        if self.obj.map_desc_chain then
          -- the first line will just be an "enroute" line
          textdesc = self.obj.map_desc[1] .. "\n" .. self.obj.map_desc_chain.map_desc[1]
        else
          textdesc = self.obj.map_desc[1]
        end
        
        QuestHelper: Assert(not c or type(c) == "number")
        QuestHelper: Assert(not z or type(z) == "number")
        QuestHelper:InvokeWaypointCallbacks(c, z, x, y, textdesc)
        
        --[=[
        if QuestHelper.c == t[1] then
          -- Translate the position to the zone the player is standing in.
          local c, z = QuestHelper.c, QuestHelper.z
          local x, y = QuestHelper.Astrolabe:TranslateWorldMapPosition(t[1], t[2], t[3], t[4], c, z)
          QuestHelper:InvokeWaypointCallbacks(c, z, x, y, reason)
        else
          -- Try to find the nearest zone on the continent the objective is in.
          local index, distsqr, x, y
          for z, i in pairs(QuestHelper_IndexLookup[t[1]]) do
            local _x, _y = QuestHelper.Astrolabe:TranslateWorldMapPosition(t[1], t[2], t[3], t[4], t[1], z)
            local d = (_x-0.5)*(_x-0.5)+(_y-0.5)*(_y-0.5)
            if not index or d < distsqr then
              index, distsqr, x, y = i, d, _x, _y
            end
          end
          local c, z = QuestHelper_IndexLookup[index]
          QuestHelper:InvokeWaypointCallbacks(c, z, x, y, reason)
        end]=]
      end
      
      if not QuestHelper_Pref.hide and QuestHelper.Astrolabe:PlaceIconOnMinimap(self, convertLocation(self.obj.loc)) ~= -1 then
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
            angle = angle + QuestHelper.Astrolabe:GetFacing()
          end
          
          if elapsed then
            if self.phase > 6.283185307179586476925 then
              self.phase = self.phase-6.283185307179586476925+elapsed*3.5
            else
              self.phase = self.phase+elapsed*3.5
            end
          end
          
          local scale = 1.0 + 0.1 * math.sin(self.phase)
        
          local x, y = scale * math.sin(angle + 3.14159 * 0.75) * math.sqrt(0.5), scale * math.cos(angle + 3.14159 * 0.75) * math.sqrt(0.5)
          self.arrow:SetTexCoord(0.5 - x, 0.5 + y, 0.5 + y, 0.5 + x, 0.5 - y, 0.5 - x, 0.5 + x, 0.5 - y)
        end
      else
        self:Hide()
      end
    else
      self:Hide()
    end
  end
  
  function icon:SetObjective(obj)
    self:SetHeight(20*QuestHelper_Pref.scale)
    self:SetWidth(20*QuestHelper_Pref.scale)
    
    if obj ~= self.obj then
      self.obj = obj
      if obj and not QuestHelper_Pref.hide then
        self:Show()
      else
        QuestHelper:InvokeWaypointCallbacks()
        self:Hide()
        return
      end
      
      self.recalc_timeout = 0
      
      if self.dot then QuestHelper:ReleaseTexture(self.dot) self.dot = nil end
      
      if not self.dot then
        self.dot = QuestHelper:CreateIconTexture(self, self.obj.icon_id or 8)
        self.dot:SetPoint("TOPLEFT", icon, "TOPLEFT", 2, -2)
        self.dot:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
      end
      
      self:OnUpdate()
    end
  end
  
  function icon:OnEnter()
    if self.obj then
      QuestHelper.tooltip:SetOwner(self, "ANCHOR_CURSOR")
      QuestHelper.tooltip:ClearLines()
      
      --[[if self.target[5] then
        QuestHelper.tooltip:AddLine(QHFormat("WAYPOINT_REASON", self.target[5]), unpack(QuestHelper:GetColourTheme().tooltip))
        QuestHelper.tooltip:GetPrevLines():SetFont(QuestHelper.font.serif, 14)
      end]]
      
      QuestHelper:AppendObjectiveToTooltip(self.obj)
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
      QuestHelper:AddObjectiveOptionsToMenu(self.obj, menu)
      menu:ShowAtCursor()
    end
  end
  
  function icon:OnEvent()
    if self.obj then
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
