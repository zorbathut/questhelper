QuestHelper_File["objtips.lua"] = "Development Version"

local real_GameTooltipOnShow = GameTooltip:GetScript("OnShow") or QuestHelper.nop

local function addObjectiveObjTip(objective, gap)
  if objective.watched or objective.progress then
    if gap then
      GameTooltip:AddLine(" ") -- Add a gap between what we're adding and what's already there.
    end
    
    if objective.quest then
      GameTooltip:AddLine(QHFormat("TOOLTIP_QUEST", string.match(objective.quest.obj or "", "^%d*/%d*/(.*)$") or "???"), 1, 1, 1)
    end
    
    if objective.progress then
      QuestHelper:AppendObjectiveProgressToTooltip(objective, GameTooltip)
    else
      GameTooltip:AddLine(QHText("TOOLTIP_WATCHED"), unpack(QuestHelper:GetColourTheme().tooltip))
    end
    
    -- Calling Show again to cause the tooltip's dimensions to be recalculated.
    -- Since the frame should already be shown, the OnShow event shouldn't be called again.
    GameTooltip:Show()
  end
  
  if objective.used then
    for obj, text in pairs(objective.used) do
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(QHFormat(text, obj.obj), 1, 1, 1)
      addObjectiveObjTip(obj, false)
    end
  end
end

local function addObjectiveTip(cat, obj)
  local list = QuestHelper.objective_objects[cat]
  if list then
    local objective = list[obj]
    if objective then
      addObjectiveObjTip(objective, true)
    end
  end
end

GameTooltip:SetScript("OnShow", function(self, ...)
  if not self then
    -- Some other AddOns hook this function, but don't bother to pass the values they were called with.
    self = GameTooltip
  end
  
  if QuestHelper_Pref.tooltip then
    local monster, item = self:GetUnit(), self:GetItem()
    
    if monster then
      addObjectiveTip("monster", monster)
    end
    
    if item then
      addObjectiveTip("item", item)
    end
  end
  
  return real_GameTooltipOnShow(self, ...)
end)
