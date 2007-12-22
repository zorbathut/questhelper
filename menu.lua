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
  menu.auto_release = nil
  menu:SetParent(nil)
  menu:ClearAllPoints()
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
    item:ClearAllPoints()
    item:SetParent(self)
    item:SetPoint("TOPLEFT", self, "TOPLEFT")
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
        if self.auto_release then
          QuestHelper:ReleaseMenu(self)
          return
        end
      end
    end
    
    self:SetAlpha(self.show_phase)
    self:SetScale(self.show_phase*0.7+0.3)
  end
  
  function menu:DoShow()
    self.showing = true
    
    local w, h = 0, 0
    
    self:SetScale(1)
    
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
    end
  end
  
  function menu:ShowAtCursor(auto_release)
    auto_release = auto_release == nil and true or auto_release
    self.auto_release = auto_release
    
    local x, y = GetCursorPosition()
    
    --self:SetParent(QuestHelper.Astrolabe.WorldMapVisible and WorldMapDetailFrame or UIParent)
    
    self:ClearAllPoints()
    self:DoShow()
    self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", math.max(0, math.min(x-self:GetWidth()/2, UIParent:GetRight()*UIParent:GetScale()-self:GetWidth())), y+5)
    
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
  
  while #item.lchildren > 0 do
    local child = table.remove(item.lchildren)
    self:ReleaseTexture(child)
  end
  
  while #item.rchildren > 0 do
    local child = table.remove(item.rchildren)
    self:ReleaseTexture(child)
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
  item:ClearAllPoints()
  
  for i, o in ipairs(self.spare_menuitems) do
    assert(o ~= item)
  end
  
  table.insert(self.spare_menuitems, item)
end

function QuestHelper:CreateMenuItem(menu, text)
  local item = table.remove(self.spare_menuitems)
  
  if not item then
    item = CreateFrame("Button", nil, menu)
    item.lchildren = {}
    item.rchildren = {}
    item.text = item:CreateFontString()
    item.text:SetDrawLayer("OVERLAY")
    item.background = item:CreateTexture()
    item.background:SetPoint("TOPRIGHT", item, "TOPRIGHT")
    item.background:SetPoint("BOTTOMLEFT", item, "BOTTOMLEFT")
    item.background:SetTexture(1, 1, 1)
    item.background:SetDrawLayer("BACKGROUND")
    
    --item.tbg = item:CreateTexture()
    --item.tbg:SetPoint("TOPRIGHT", item.text, "TOPRIGHT")
    --item.tbg:SetPoint("BOTTOMLEFT", item.text, "BOTTOMLEFT")
    --item.tbg:SetTexture(1,0,1,0.5)
  end
  
  item.showing = true
  item.highlighting = false
  item.show_phase = 0
  item.highlight_phase = 0
  
  function item:AddTexture(tex, before)
    tex:ClearAllPoints()
    
    -- Not really going to use this position, just want it anchored to our invisible selves so that it too will be invisible.
    tex:SetPoint("TOPLEFT", menu, "TOPLEFT")
    
    if before then
      table.insert(self.lchildren, 1, tex)
    else
      table.insert(self.rchildren, tex)
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
    self.background:SetVertexColor(h*0.5+.1, h*0.7+.1, h+.1, h*0.2+0.4)
    self:SetAlpha(s)
  end
  
  function item:SetFunction(...)
    self.func_arg = {...}
    self.func = table.remove(self.func_arg, 1)
  end
  
  function item:SetSubmenu(menu)
    assert(not self.submenu)
    if menu then
      menu:ClearAllPoints()
      menu:SetParent(self)
      menu:SetPoint("TOPLEFT", self, "TOPLEFT")
      menu.parent = self
      self.submenu = menu
      self:AddTexture(QuestHelper:GetIconTexture(self, 9))
      menu:DoHide()
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
  
  function item:GetSize()
    self:SetScale(1)
    self.text:ClearAllPoints()
    self.text:SetWidth(0)
    
    self.text_w = self.text:GetWidth()
    if self.text_w >= 320 then
      self.text:SetWidth(320)
      self.text_h = self.text:GetHeight()
      local mn, mx = 100, 321
      while mn ~= mx do
        local w = math.floor((mn+mx)*0.5)
        self.text:SetWidth(w-1)
        if self.text:GetHeight() <= self.text_h then
          mx = w
        else
          mn = w+1
        end
      end
      
      self.text:SetWidth(mn)
      self.text_w = mn+1
    else
      self.text_h = self.text:GetHeight()
    end
    
    local w, h = self.text_w+4, self.text_h+4
    
    for i, f in ipairs(self.lchildren) do
      w = w + f:GetWidth() + 4
      h = math.max(h, f:GetHeight() + 4)
    end
    
    for i, f in ipairs(self.rchildren) do
      w = w + f:GetWidth() + 4
      h = math.max(h, f:GetHeight() + 4)
    end
    
    self.needed_width = w
    
    return w, h
  end
  
  function item:SetSize(w, h)
    self:SetWidth(w)
    self:SetHeight(h)
    
    local x = 0
    
    for i, f in ipairs(self.lchildren) do
      local cw, ch = f:GetWidth(), f:GetHeight()
      
      f:ClearAllPoints()
      f:SetPoint("TOPLEFT", self, "TOPLEFT", x+2, -(h-ch)*0.5)
      x = x + cw + 4
    end
    
    local x1 = x
    x = w
    
    for i, f in ipairs(self.rchildren) do
      local cw, ch = f:GetWidth(), f:GetHeight()
      f:ClearAllPoints()
      x = x - cw - 4
      f:SetPoint("TOPLEFT", self, "TOPLEFT", x+2, -(h-ch)*0.5)
    end
    
    self.text:ClearAllPoints()
    self.text:SetPoint("TOPLEFT", self, "TOPLEFT", x1+((x-x1)-self.text_w)*0.5, -(h-self.text_h)*0.5)
  end
  
  item:SetScript("OnEnter", item.OnEnter)
  
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
  item.text:SetJustifyH("CENTER")
  item.text:SetJustifyV("MIDDLE")
  item.text:SetText(text)
  item.text:ClearAllPoints()
  
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
    self.background:SetVertexColor(h*0.1, 0.2+h*0.2, 0.6+h*0.4, h*0.2+0.6)
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
end
