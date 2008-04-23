--[[
   mapbutton.lua

   This module contains code to place a button on the Map Frame, and provides the
   functionality of that button.

   Currently Functionality:
   - Left click on button is equivalent to /qh hide
   - Button has tooltip to that effect

   History:
      4-20-2008     Created     Nesher
--]]

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
    QuestHelper.tooltip:Show()
end

-------------------------------------------------------------------------------------
-- Set up the Map Button
function QuestHelper_InitMapButton()
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

    -- Add event handlers to provide Tooltip
    button:SetScript("OnEnter", QuestHelperWorldMapButton_OnEnter)
    button:SetScript("OnLeave", function(this)
        QuestHelper.tooltip:Hide()
    end)

    -- Add Click handler
    button:SetScript("OnClick", QuestHelperWorldMapButton_OnClick)

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
    QuestHelper.MapButton = button
end
