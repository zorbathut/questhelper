--[[
   mapbutton.lua

   This module contains code to place a button on the Map Frame, and provides the
   functionality of that button.

   Currently Functionality:
   - Left click on button is equivalent to /qh hide
   - Right-click on button shows Settings menu
   - Button has tooltip to that effect
   - Button serves as hook to detect when map is hidden, in order to hide active menus (if any).

   History:
      4-20-2008     Nesher      Created
      4-24-2008     Smariot     Added right-click menu
      4-24-2008     Nesher      Localized settings menu.  Added hook to hide menus when World Map is hidden.
--]]

-------------------------------------------------------------------------------------
-- Display a Settings menu.  Used from the map button's right-click, and from /qh settings.
function QuestHelper:DoSettingsMenu()
    local menu = QuestHelper:CreateMenu()
    self:CreateMenuTitle(menu, QHText("MENU_SETTINGS"))
    
    -- Flight Timer
    self:CreateMenuItem(menu, QHFormat("MENU_FLIGHT_TIMER", QuestHelper_Pref.flight_time and QHText("MENU_DISABLE") or QHText("MENU_ENABLE")))
                    :SetFunction(self.ToggleFlightTimes, self)
    
    -- Ant Trails
    self:CreateMenuItem(menu, QHFormat("MENU_ANT_TRAILS", QuestHelper_Pref.show_ants and QHText("MENU_DISABLE") or QHText("MENU_ENABLE")))
                    :SetFunction(self.ToggleAnts, self)
    
    -- Cartographer Waypoints
    if Cartographer_Waypoints then
      self:CreateMenuItem(menu, QHFormat("MENU_WAYPOINT_ARROW", QuestHelper_Pref.cart_wp and QHText("MENU_DISABLE") or QHText("MENU_ENABLE")))
                    :SetFunction(self.ToggleCartWP, self)
    end
    
    -- Icon Scale
    local submenu = self:CreateMenu()
    for pct = 50,120,10 do
      local item = self:CreateMenuItem(submenu, pct.."%")
      local tex = self:CreateIconTexture(item, 10)
      item:SetFunction(self.SetIconScale, QuestHelper, pct.."%")
      item:AddTexture(tex, true)
      tex:SetVertexColor(1, 1, 1, QuestHelper_Pref.scale == pct*0.01 and 1 or 0)
    end
    self:CreateMenuItem(menu, QHText("MENU_ICON_SCALE")):SetSubmenu(submenu)
    
    -- Hidden Objectives
    submenu = self:CreateMenu()
    self:PopulateHidden(submenu)
    self:CreateMenuItem(menu, QHText("HIDDEN_TITLE")):SetSubmenu(submenu)
    
    -- Filters
    submenu = self:CreateMenu()
    self:CreateMenuItem(submenu, QHFormat("MENU_ZONE_FILTER", QuestHelper_Pref.filter_zone and QHText("MENU_DISABLE") or QHText("MENU_ENABLE")))
                    :SetFunction(self.Filter, self, "ZONE")
    self:CreateMenuItem(submenu, QHFormat("MENU_DONE_FILTER", QuestHelper_Pref.filter_done and QHText("MENU_DISABLE") or QHText("MENU_ENABLE")))
                    :SetFunction(self.Filter, self, "DONE")
    self:CreateMenuItem(submenu, QHFormat("MENU_LEVEL_FILTER", QuestHelper_Pref.filter_level and QHText("MENU_DISABLE") or QHText("MENU_ENABLE")))
                    :SetFunction(self.Filter, self, "LEVEL")
    local submenu2 = self:CreateMenu()
    self:CreateMenuItem(submenu, QHText("MENU_LEVEL_OFFSET")):SetSubmenu(submenu2)

    for offset = -5,5 do
      local menu = self:CreateMenuItem(submenu2, (offset > 0 and "+" or "")..offset)
      menu:SetFunction(self.LevelOffset, self, offset)
      local tex = self:CreateIconTexture(item, 10)
      menu:AddTexture(tex, true)
      tex:SetVertexColor(1, 1, 1, QuestHelper_Pref.level == offset and 1 or 0)
    end
    self:CreateMenuItem(menu, QHText("MENU_FILTERS")):SetSubmenu(submenu)
    
    -- Locale
    submenu = self:CreateMenu()
    for loc, tbl in pairs(QuestHelper_Translations) do
      local item = self:CreateMenuItem(submenu, (tbl.LOCALE_NAME or "???").." ["..loc.."]")
      local tex = self:CreateIconTexture(item, 10)
      item:SetFunction(self.SetLocale, self, loc)
      item:AddTexture(tex, true)
      tex:SetVertexColor(1, 1, 1, QuestHelper_Pref.locale == loc and 1 or 0)
    end
    self:CreateMenuItem(menu, QHText("MENU_LOCALE")):SetSubmenu(submenu)
    
    menu:ShowAtCursor()
end

-------------------------------------------------------------------------------------
-- Handle clicks on the button
function QuestHelperWorldMapButton_OnClick(self, clicked)

  -- Left button toggles whether QuestHelper is displayed (and hence active)
  if clicked == "LeftButton" then
    QuestHelper:ToggleHide()

    -- Refresh the tooltip to match.  Presumably it's showing - how else could the button get clicked?
    -- Note: if I'm wrong about my assumption, this could leave the tooltip stranded until user mouses
    -- back over the button, but I don't think that's too serious.
    QuestHelperWorldMapButton_OnEnter(self)
  elseif clicked == "RightButton" and not QuestHelper_Pref.hide then
    QuestHelper:DoSettingsMenu()
  end
end

-------------------------------------------------------------------------------------
-- Display or update the tooltip
function QuestHelperWorldMapButton_OnEnter(self)
    local theme = QuestHelper:GetColourTheme()

    QuestHelper.tooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", self:GetWidth(), -5)
    QuestHelper.tooltip:ClearLines()
    QuestHelper.tooltip:AddLine(QHFormat("QH_BUTTON_TOOLTIP1", QHText(QuestHelper_Pref.hide and "QH_BUTTON_SHOW" or "QH_BUTTON_HIDE")),
                                unpack(theme.tooltip))
    QuestHelper.tooltip:GetPrevLines():SetFont(QuestHelper.font.serif, 12)
    if not QuestHelper_Pref.hide then
        -- Add the settings menu tooltip when it's available
        QuestHelper.tooltip:AddLine(QHText("QH_BUTTON_TOOLTIP2"), unpack(theme.tooltip))
        QuestHelper.tooltip:GetPrevLines():SetFont(QuestHelper.font.serif, 12)
    end
    QuestHelper.tooltip:Show()
end

-------------------------------------------------------------------------------------
-- Handle when the world map gets hidden: hide the active menu if any.
function QuestHelper_WorldMapHidden()
  if QuestHelper.active_menu then
    QuestHelper.active_menu:DoHide()
    if QuestHelper.active_menu.auto_release then
      QuestHelper.active_menu = nil
    end
  end
end


-------------------------------------------------------------------------------------
-- Set up the Map Button
function QuestHelper:InitMapButton()

  if not self.MapButton then
    -- Create the button
    local button = CreateFrame("Button", "QuestHelperWorldMapButton", WorldMapFrame, "UIPanelButtonTemplate")

    -- Set up the button
    button:SetText(QHText("QH_BUTTON_TEXT"))
    local width = button:GetTextWidth() + 30
    if width < 110 then
        width = 110
    end
    button:SetWidth(width)
    button:SetHeight(22)
    
    -- Desaturate the button texture if QuestHelper is disabled.
    -- This line is also in QuestHelper:ToggleHide
    button:GetNormalTexture():SetDesaturated(QuestHelper_Pref.hide)
    
    -- Add event handlers to provide Tooltip
    button:SetScript("OnEnter", QuestHelperWorldMapButton_OnEnter)
    button:SetScript("OnLeave", function(this)
        QuestHelper.tooltip:Hide()
    end)

    -- Add Click handler
    button:SetScript("OnClick", QuestHelperWorldMapButton_OnClick)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Add Hide handler, so we can dismiss any menus when map is closed
    button:SetScript("OnHide", QuestHelper_WorldMapHidden)

    -- Position it on the World Map frame
--~     if Cartographer then
--~         -- If Cartographer is in use, coordinate with their buttons.
            -- Trouble is, this makes Cartographer's buttons conflict with the Zone Map dropdown.
            -- Re-enable this if Cartographer ever learns to work with the Zone Map dropdown.
--~         Cartographer:AddMapButton(button, 3)
--~     else
        -- Otherwise, just put it in the upper right corner
        button:SetPoint("RIGHT", WorldMapPositioningGuide, "RIGHT", -20, 0)
        button:SetPoint("BOTTOM", WorldMapZoomOutButton, "BOTTOM", 0, 0)
--    end

    -- Save the button so we can reference it later if need be
    self.MapButton = button
  else
    -- User must be toggling the button.  We've already got it, so just show it.
    self.MapButton:Show()
  end
end

----------------------------------------------------------------------------------
-- Hide the map button
function QuestHelper:HideMapButton()
  if self.MapButton then
    self.MapButton:Hide()
  end
end
