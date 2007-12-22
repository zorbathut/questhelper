local function HiddenReason(obj)
  local depends
  for i, j in pairs(obj.after) do
    if i.watched and not i:Known() then
      if not depends then
        depends = "Depends on '"..i:Reason(true).."'."
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
      return "Depends on "..depends.." hidden objectives.", false
    end
  end
  
  if obj.user_ignore == nil then
    if obj.filter_level and QuestHelper_Pref.filter_level then
      return "Filtered due to level.", true
    end
    
    if obj.filter_zone and QuestHelper_Pref.filter_zone then
      return "Filtered due to zone.", true
    end
    
    if obj.filter_done and QuestHelper_Pref.filter_done then
      return "Filtered due to completeness.", true
    end
  elseif obj.user_ignore then
    return "You requested this objective be hidden.", true
  end
  
  return "Don't know how to complete.", false
end

function QuestHelper:ShowHidden()
  local menu = self:CreateMenu()
  
  self:CreateMenuTitle(menu, "Hidden Objectives")
  
  local empty = true
  
  for obj in pairs(self.to_add) do
    if not obj:Known() then
      reason, can_show = HiddenReason(obj)
      empty = false
      
      local item = self:CreateMenuItem(menu, obj:Reason(true))
      local menu2 = self:CreateMenu()
      item:SetSubmenu(menu2)
      
      local item2 = self:CreateMenuItem(menu2, reason)
      
      if can_show then
        local menu3 = self:CreateMenu()
        item2:SetSubmenu(menu3)
        local item3 = self:CreateMenuItem(menu3, "Show.")
        item3:SetFunction(function (obj) obj.user_ignore = false end, obj)
      end
    end
  end
  
  if empty then
    self:CreateMenuItem(menu, "There are no objectives hidden from you.")
  end
  
  menu:ShowAtCursor()
end
