local function HiddenReason(obj)
  local depends
  for i, j in pairs(obj.after) do
    if i.watched and not i:Known() then
      if not depends then
        depends = QHFormat("DEPENDS_ON_SINGLE", i:Reason(true))
      elseif type(depends) == "string" then
        depends = 2
      else
        depends = depends + 1
      end
    end
  end
  
  if depends then
    if type(depends) == "string" then
      return depends, false
    else
      return QHFormat("DEPENDS_ON_COUNT", depends), false
    end
  end
  
  if obj.user_ignore == nil then
    if obj.filter_level and QuestHelper_Pref.filter_level then
      return QHText("FILTERED_LEVEL"), true, "level"
    end
    
    if obj.filter_zone and QuestHelper_Pref.filter_zone then
      return QHText("FILTERED_ZONE"), true, "zone"
    end
    
    if obj.filter_done and QuestHelper_Pref.filter_done then
      return QHText("FILTERED_COMPLETE"), true, "done"
    end
  elseif obj.user_ignore then
    return QHText("FILTERED_USER"), true
  end
  
  return QHText("FILTERED_UNKNOWN"), false
end

function QuestHelper:PopulateHidden(menu)
  local empty = true
  
  for obj in pairs(self.to_add) do
    if not obj:Known() then
      reason, can_show, filter = HiddenReason(obj)
      empty = false
      
      local item = self:CreateMenuItem(menu, obj:Reason(true))
      local menu2 = self:CreateMenu()
      item:SetSubmenu(menu2)
      
      local item2 = self:CreateMenuItem(menu2, reason)
      
      if can_show then
        local menu3 = self:CreateMenu()
        item2:SetSubmenu(menu3)
        local item3 = self:CreateMenuItem(menu3, QHText("HIDDEN_SHOW"))
        item3:SetFunction(function (obj) obj.user_ignore = false end, obj)
        
        if filter then
          item3 = self:CreateMenuItem(menu3, QHFormat("DISABLE_FILTER", QHText("FILTER_"..string.upper(filter))))
          item3:SetFunction(function (filter) QuestHelper_Pref["filter_"..filter] = false end, filter)
        end
        
        -- I'd add an option to adjust the level filter, but I can't tell what value would be required.
      end
    end
  end
  
  if empty then
    self:CreateMenuItem(menu, QHText("HIDDEN_NONE"))
  end
end

function QuestHelper:ShowHidden()
  local menu = self:CreateMenu()
  
  self:CreateMenuTitle(menu, QHText("HIDDEN_TITLE"))
  self:PopulateHidden(menu)
  menu:ShowAtCursor()
end
