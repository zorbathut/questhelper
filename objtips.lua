QuestHelper_File["objtips.lua"] = "Development Version"

local real_GameTooltipOnShow = GameTooltip:GetScript("OnShow") or QuestHelper.nop

local function addObjectiveObjTip(tooltip, objective, depth, already_touched)
  if depth > 10 then return end -- fuck that, man. Just fuck that.
  already_touched[objective] = true -- YOU CANNOT EAT A PURSE
  
  if objective.watched or objective.progress then
    local depth2 = depth
    
    if objective.quest then
      tooltip:AddLine(("  "):rep(depth2)..QHFormat("TOOLTIP_QUEST", string.match(objective.quest.obj or "", "^%d*/%d*/(.*)$") or "???"), 1, 1, 1)
      
      depth2 = depth2 + 1
    end
    
    if objective.progress then
      QuestHelper:AppendObjectiveProgressToTooltip(objective, tooltip, nil, depth2)
    else
      tooltip:AddLine(("  "):rep(depth2)..QHText("TOOLTIP_WATCHED"), unpack(QuestHelper:GetColourTheme().tooltip))
    end
    
    -- Calling Show again to cause the tooltip's dimensions to be recalculated.
    -- Since the frame should already be shown, the OnShow event shouldn't be called again.
    tooltip:Show()
  end
  
  if objective.used then
    for obj, text in pairs(objective.used) do
      if not already_touched[obj] then -- no infinite loops please
        tooltip:AddLine(("  "):rep(depth)..QHFormat(text, obj.obj), 1, 1, 1)
        addObjectiveObjTip(tooltip, obj, depth+1, already_touched)
      end
    end
  end
  
  already_touched[objective] = nil -- oh why not. just so I can get a screenshot of some poor sap getting a 2^n case
end

local function addObjectiveTip(tooltip, cat, obj)
  local list = QuestHelper.objective_objects[cat]
  if list then
    local objective = list[obj]
    if objective then
      addObjectiveObjTip(tooltip, objective, 0, {})
    end
  end
end

GameTooltip:SetScript("OnShow", function(self, ...)
  if not self then
    -- Some other AddOns hook this function, but don't bother to pass the values they were called with.
    self = GameTooltip
  end
  
  if QuestHelper_Pref.tooltip then
    -- Apparantly, sometimes InventoryOnPar invokes our tooltip function with something that doesn't have GetItem method.
    local monster, item = self.GetUnit and self:GetUnit(), self.GetItem and self:GetItem()
    
    if monster then
      addObjectiveTip(self, "monster", monster)
    end
    
    if item then
      addObjectiveTip(self, "item", item)
    end
  end
  
  return real_GameTooltipOnShow(self, ...)
end)
