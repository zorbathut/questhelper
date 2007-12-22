QuestHelper.active_menu = nil
QuestHelper.spare_menus = {}

function QuestHelper:ReleaseMenu(menu)
  menu:Hide()
  
  while #menu.items > 0 do
    local item = table.remove(menu.items)
    self:ReleaseMenuItem(item)
  end
  
  menu.showing = false
  menu.show_phase = 0
  menu.submenu = nil
  menu.active_item = nil
  menu.func = nil
  menu.func_arg = nil
  menu.parent = nil
  menu:SetParent(nil)
  menu:SetScript("OnUpdate", nil)
  
  if self.active_menu == menu then
    self.active_menu = nil
  end
  
  table.insert(self.spare_menus, menu)
end

function QuestHelper:CreateMenu()
  local menu = table.remove(self.spare_menus)
  
  if not menu then
    menu = CreateFrame("Button")
    menu.items = {}
    menu:SetMovable(true)
    menu:SetFrameStrata("TOOLTIP")
  end
  
  menu:SetParent(nil)
  
  function menu:AddItem(item)
    item:SetParent(self)
    item.parent = self
    table.insert(self.items, item)
  end
  
  menu.level = 2
  menu:SetFrameLevel(menu.level)
  
  menu.show_phase = 0
  menu.showing = true
  
  function menu:SetCloseFunction(...)
    self.func_arg = {...}
    self.func = table.remove(self.func_arg, 1)
  end
  
  function menu:OnUpdate(elapsed)
    if self.showing then
      self.show_phase = self.show_phase + elapsed * 5.0
      if self.show_phase > 1 then
        self.show_phase = 1
        self:SetScript("OnUpdate", nil)
      end
    else
      self.show_phase = self.show_phase - elapsed * 3.0
      if self.show_phase < 0 then
        self.show_phase = 0
        self:SetScript("OnUpdate", nil)
        self:Hide()
        if self.func then
          self.func(unpack(self.func_arg))
        end
      end
    end
    
    self:SetAlpha(self.show_phase)
    self:SetScale(self.show_phase*0.7+0.3)
  end
  
  function menu:DoShow()
    self.showing = true
    
    local w, h = 0, 0
    
    for i, c in ipairs(self.items) do
      local cw, ch = c:GetSize()
      w = math.max(w, cw)
      h = h + ch
    end
    
    local y = 0
    
    self:SetWidth(w)
    self:SetHeight(h)
    self:Show()
    self:SetScript("OnUpdate", self.OnUpdate)
    
    for i, c in ipairs(self.items) do
      local cw, ch = c:GetSize()
      c:ClearAllPoints()
      c:SetSize(w, ch)
      c:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -y)
      y = y + ch
    end
    
    if self.parent then
      self.level = self.parent.parent.level + #self.parent.parent.items + 1
      self:SetFrameLevel(self.level)
    end
    
    for i, n in ipairs(self.items) do
      n.level = self.level+i
      n:SetFrameLevel(n.level)
      n:DoShow()
      if n.submenu then for i, n2 in ipairs(n.submenu.items) do
      end end
    end
  end
  
  function menu:ShowAtCursor()
    local x, y = GetCursorPosition()
    
    --self:SetParent(QuestHelper.Astrolabe.WorldMapVisible and WorldMapDetailFrame or UIParent)
    
    self:ClearAllPoints()
    self:DoShow()
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y-self:GetHeight()/2+5)
    
    if QuestHelper.active_menu and QuestHelper.active_menu ~= self then
      QuestHelper.active_menu:DoHide()
    end
    
    QuestHelper.active_menu = self
  end
  
  function menu:DoHide()
    self.showing = false
    self:SetScript("OnUpdate", self.OnUpdate)
    
    if self.active_item then
      self.active_item.highlighting = false
      self.active_item:SetScript("OnUpdate", self.active_item.OnUpdate)
    end
    
    for i, n in ipairs(self.items) do
      n:DoHide()
    end
  end
  
  return menu
end

QuestHelper.spare_menuitems = {}

function QuestHelper:ReleaseMenuItem(item)
  item:Hide()
  
  while #item.children > 0 do
    local child = table.remove(item.children)
    if child ~= item.text then self:ReleaseTexture(child) end
  end
  
  if item.submenu then
    self:ReleaseMenu(item.submenu)
    item.submenu = nil
  end
  
  item.showing = false
  item.show_phase = 0
  item.highlighting = false
  item.highlight_phase = 0
  item:SetScript("OnUpdate", nil)
  item.func = nil
  item.func_arg = nil
  item.parent = nil
  item:SetParent(nil)
  
  for i, o in ipairs(self.spare_menuitems) do
    assert(o ~= item)
  end
  
  table.insert(self.spare_menuitems, item)
end

function QuestHelper:CreateMenuItem(menu, text)
  local item = table.remove(self.spare_menuitems)
  
  if not item then
    item = CreateFrame("Button", nil, menu)
    item.children = {}
    item.text = item:CreateFontString()
    item.text:SetDrawLayer("OVERLAY")
    item.background = item:CreateTexture()
    item.background:SetPoint("TOPRIGHT", item, "TOPRIGHT")
    item.background:SetPoint("BOTTOMLEFT", item, "BOTTOMLEFT")
    item.background:SetDrawLayer("BACKGROUND")
  end
  
  table.insert(item.children, item.text)
  
  item.showing = true
  item.highlighting = false
  item.show_phase = 0
  item.highlight_phase = 0
  
  function item:AddTexture(tex, before)
    if before then
      table.insert(self.children, 1, tex)
    else
      table.insert(self.children, tex)
    end
  end
  
  function item:DoShow()
    self.showing = true
    self:SetScript("OnUpdate", self.OnUpdate)
    self:Show()
  end
  
  function item:DoHide()
    if self.submenu then
      self.submenu:DoHide()
    end
    
    self.showing = false
    self:SetScript("OnUpdate", self.OnUpdate)
  end
  
  function item:OnUpdate(elapsed)
    local done_update = true
    
    if self.highlighting then
      self.highlight_phase = self.highlight_phase + elapsed * 3.0
      if self.highlight_phase > 1 then
        self.highlight_phase = 1
      else
        done_update = false
      end
    else
      self.highlight_phase = self.highlight_phase - elapsed
      if self.highlight_phase < 0 then
        self.highlight_phase = 0
      else
        done_update = false
      end
    end
    
    if self.showing then
      self.show_phase = self.show_phase + elapsed * 5.0
      if self.show_phase > 1 then
        self.show_phase = 1
      else
        done_update = false
      end
    else
      self.show_phase = self.show_phase - elapsed * 5.0
      if self.show_phase < 0 then
        self.show_phase = 0
        self.highlight_phase = 0
        self:Hide()
        done_update = true
      else
        done_update = false
      end
    end
    
    self:Shade(self.show_phase, self.highlight_phase)
    
    if done_update then
      self:SetScript("OnUpdate", nil)
    end
  end
  
  function item:Shade(s, h)
    local ih = 1-h
    
    self.text:SetTextColor(ih, ih, ih, 1)
    item.text:SetShadowColor(h, h, h, ih)
    item.text:SetShadowOffset(1, -1)
    self.background:SetTexture(h*0.5+.1, h*0.7+.1, h+.1, h*0.2+0.4)
    self:SetAlpha(s)
  end
  
  function item:SetFunction(...)
    self.func_arg = {...}
    self.func = table.remove(self.func_arg, 1)
  end
  
  function item:SetSubmenu(menu)
    assert(not self.submenu)
    if menu then
      menu:SetParent(self)
      menu.parent = self
      self.submenu = menu
      self:AddTexture(QuestHelper:GetIconTexture(self, 9))
    end
  end
  
  function item:OnEnter()
    self.highlighting = true
    self:SetScript("OnUpdate", self.OnUpdate)
    
    if self.parent.active_item and self.parent.active_item ~= self then
      self.parent.active_item.highlighting = false
      self.parent.active_item:SetScript("OnUpdate", self.parent.active_item.OnUpdate)
    end
    
    self.parent.active_item = self
    
    if self.parent.submenu and self.parent.submenu ~= self.submenu then
      self.parent.submenu:DoHide()
      self.parent.submenu = nil
    end
    
    if self.submenu then
      self.parent.submenu = self.submenu
      self.submenu:ClearAllPoints()
      
      local v, h1, h2 = "TOP", "LEFT", "RIGHT"
      
      self.submenu:DoShow()
      
      if self:GetRight()+self.submenu:GetWidth() > UIParent:GetRight()*UIParent:GetScale() then
        h1, h2 = h2, h1
      end
      
      if self:GetBottom()-self.submenu:GetHeight() < 0 then
        v = "BOTTOM"
      end
      
      self.submenu:SetPoint(v..h1, self, v..h2)
      self.submenu:DoShow()
    end
  end
  
  --function item:OnLeave()
  --  self.highlighting = false
  --  self:SetScript("OnUpdate", self.OnUpdate)
  --end
  
  function item:GetSize()
    local w, h = 0, 0
    
    for i, f in ipairs(self.children) do
      w = w + f:GetWidth()
      h = math.max(h, f:GetHeight())
    end
    
    self.needed_width = w
    
    return w, h
  end
  
  function item:SetSize(w, h)
    self:SetWidth(w)
    self:SetHeight(h)
    
    local x, spacing = 0, 0
    
    if #self.children > 1 then
      spacing = (w-self.needed_width)/(#self.children-1)
    end
    
    for i, f in ipairs(self.children) do
      f:ClearAllPoints()
      f:SetPoint("TOPLEFT", self, "TOPLEFT", x, -(h-f:GetHeight())*0.5)
      x = x + f:GetWidth() + spacing
    end
  end
  
  item:SetScript("OnEnter", item.OnEnter)
  --item:SetScript("OnLeave", item.OnLeave)
  
  menu:AddItem(item)
  
  function item:OnClick(btn)
    if btn == "RightButton" then
      local parent = self.parent
      while parent.parent do
        parent = parent.parent
      end
      parent:DoHide()
    elseif btn == "LeftButton" and self.func then
      self.func(unpack(self.func_arg))
      local parent = self.parent
      while parent.parent do
        parent = parent.parent
      end
      parent:DoHide()
    end
  end
  
  item:RegisterForClicks("LeftButtonUp", "RightButtonDown")
  item:SetScript("OnClick", item.OnClick)
  
  item.text:SetFont("Fonts\\ARIALN.TTF", 15)
  item.text:ClearAllPoints()
  item.text:SetJustifyH("LEFT")
  item.text:SetJustifyV("MIDDLE")
  item.text:SetWidth(0)
  item.text:SetHeight(0)
  item.text:SetText(text)
  item.text:SetWidth(math.min(250, item.text:GetWidth()+15))
  item.text:SetHeight(item.text:GetHeight()+5)
  
  return item
end

function QuestHelper:CreateMenuTitle(menu, title)
  local item = QuestHelper:CreateMenuItem(menu, title)
  
  local f1, f2 = QuestHelper:GetTexture(item, "Interface\\AddOns\\QuestHelper\\Art\\Fluff.blp"),
                 QuestHelper:GetTexture(item, "Interface\\AddOns\\QuestHelper\\Art\\Fluff.blp")
  
  f1:SetTexCoord(0, 1, 0, .5)
  f1:SetWidth(20)
  f1:SetHeight(10)
  f2:SetTexCoord(0, 1, .5, 1)
  f2:SetWidth(20)
  f2:SetHeight(10)
  
  item:AddTexture(f1, true)
  item:AddTexture(f2, false)
  
  function item:OnDragStart()
    local parent = self.parent
    
    while parent.parent do
      parent = parent.parent
    end
    
    parent:StartMoving()
  end
  
  function item:OnDragStop()
    local parent = self.parent
    
    while parent.parent do
      parent = parent.parent
    end
    
    parent:StopMovingOrSizing()
  end
  
  function item:Shade(s, h)
    self.text:SetTextColor(1, 1, 1, 1)
    self.background:SetTexture(h*0.1, 0.2+h*0.2, 0.6+h*0.4, h*0.2+0.6)
    self:SetAlpha(s)
  end
  
  function item:OnClick()
    local parent = self.parent
    
    while parent.parent do
      parent = parent.parent
    end
    
    parent:DoHide()
  end
  
  item:RegisterForClicks("RightButtonDown")
  item:SetScript("OnClick", item.OnClick)
  item:SetScript("OnDragStart", item.OnDragStart)
  item:SetScript("OnDragStop", item.OnDragStop)
  item:RegisterForDrag("LeftButton")
  
  item.text:SetFont("Fonts\\MORPHEUS.TTF", 13)
  item.text:ClearAllPoints()
  item.text:SetWidth(0)
  item.text:SetHeight(0)
  item.text:SetWidth(math.min(250, item.text:GetWidth()+15))
  item.text:SetHeight(item.text:GetHeight()+5)
end

