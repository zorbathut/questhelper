local viewer

local function viewer_mousewheel(self, dir)
  local range = self.scrollframe:GetVerticalScrollRange()
  local pos = math.max(0, math.min(range, self.scrollframe:GetVerticalScroll()-dir*25))
  self.scrollframe:SetVerticalScroll(pos)
  self.scrollbutton:SetPoint("TOP", self, "TOP", 0, -(pos/range*(self:GetHeight()-32)+8))
end

local function viewer_mousedown(self)
  self.text:SetText("")
  self:Hide()
end

local function scrollbutton_scrolling(self)
  local vtop, vbottom = viewer:GetTop()-8, viewer:GetBottom()+24
  local top = math.max(vbottom, math.min(vtop, select(2, GetCursorPosition()) - self.mouse_base + self.base))
  viewer.scrollframe:SetVerticalScroll((vtop-top)/(vtop-vbottom)*viewer.scrollframe:GetVerticalScrollRange())
  self:SetPoint("TOP", viewer, "TOP", 0, top-viewer:GetTop())
end

local function scrollbutton_mousedown(self, btn)
  if btn == "LeftButton" then
    self.base = self:GetTop()
    self.mouse_base = select(2, GetCursorPosition())
    self:SetScript("OnUpdate", scrollbutton_scrolling)
  end
end

local function scrollbutton_mouseup(self, btn)
  if btn == "LeftButton" then
    self:SetScript("OnUpdate", nil)
  end
end

function QuestHelper:ShowText(text, title)
  if not viewer then
    viewer = CreateFrame("Frame", "QuestHelperTextViewer", nil) -- With no parent, this will always be visible.
    viewer:SetPoint("CENTER", UIParent)
    viewer:EnableMouseWheel(true)
    viewer:EnableMouse(true)
    viewer:SetScript("OnMouseWheel", viewer_mousewheel)
    viewer:SetScript("OnMouseDown", viewer_mousedown)
    
    viewer.title = viewer:CreateFontString()
    viewer.title:SetFont(self.font.serif, 14)
    viewer.title:SetPoint("TOPLEFT", viewer, 8, -8)
    viewer.title:SetPoint("RIGHT", viewer, -8, 0)
    
    viewer:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      edgeSize = 16,
      tile = true,
      tileSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 }})
    viewer:SetBackdropColor(0, 0, 0, 0.65)
    viewer:SetBackdropBorderColor(1, 1, 1, 0.7)
    
    viewer.scrollframe = CreateFrame("ScrollFrame", "QuestHelperTextViewer_ScrollFrame", viewer)
    viewer.scrollframe:SetPoint("LEFT", viewer, "LEFT", 8, 0)
    viewer.scrollframe:SetPoint("TOP", viewer.title, "BOTTOM", 0, -4)
    
    viewer.frame = CreateFrame("Frame", "QuestHelperTextViewer_Frame", viewer.scrollframe)
    viewer.scrollframe:SetScrollChild(viewer.frame)
    
    viewer.text = viewer.frame:CreateFontString()
    viewer.text:SetFont(self.font.sans, 12)
    viewer.text:SetJustifyH("LEFT")
    viewer.text:SetPoint("TOPLEFT", viewer.frame)
    
    viewer.scrollbutton = CreateFrame("Frame", "QuestHelperTextViewer_ScrollButton", viewer)
    viewer.scrollbutton:SetWidth(16)
    viewer.scrollbutton:SetHeight(16)
    viewer.scrollbutton:SetPoint("TOPRIGHT", viewer, "TOPRIGHT", -8, -8)
    viewer.scrollbutton.texture = self:CreateIconTexture(viewer.scrollbutton, 26)
    viewer.scrollbutton.texture:SetAllPoints()
    viewer.scrollbutton:EnableMouse(true)
    viewer.scrollbutton:SetScript("OnMouseDown", scrollbutton_mousedown)
    viewer.scrollbutton:SetScript("OnMouseUp", scrollbutton_mouseup)
  end
  
  viewer:Show()
  viewer.title:SetText(title or "QuestHelper")
  viewer.text:SetText(text or "No text.")
  viewer.scrollframe:SetVerticalScroll(0)
  
  local w = math.min(600, math.max(100, viewer.text:GetStringWidth()))
  viewer.text:SetWidth(w)
  viewer:SetWidth(w+16)
  viewer.scrollframe:SetWidth(w)
  viewer.frame:SetWidth(w)
  
  local h = math.max(10, viewer.text:GetHeight())
  local title_h = viewer.title:GetHeight()
  
  if h > 400 then
    viewer.frame:SetHeight(400)
    viewer.scrollframe:SetHeight(400)
    viewer:SetHeight(420+title_h)
    viewer:SetWidth(w+32)
    viewer.scrollbutton:Show()
  else
    viewer.frame:SetHeight(h)
    viewer.scrollframe:SetHeight(h)
    viewer:SetHeight(h+20+title_h)
    viewer.scrollbutton:Hide()
  end
  
  
end
