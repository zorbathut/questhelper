if GetLocale() ~= "enUS" then
  DEFAULT_CHAT_FRAME:AddMessage("|cffffcc77QuestHelper: |rI'm not ready to support your locale yet. Sorry!", 1.0, 0.6, 0.2)
  return
end

QuestHelper = CreateFrame("Frame", "QuestHelper", UIParent)
QuestHelper.Astrolabe = DongleStub("Astrolabe-0.4")

QuestHelper_SaveVersion = 3
QuestHelper_Locale = GetLocale()
QuestHelper_Quests = {}
QuestHelper_Objectives = {}

QuestHelper.tooltip = CreateFrame("GameTooltip", "QuestHelperTooltip", nil, "GameTooltipTemplate")
QuestHelper.objective_objects = {}
QuestHelper.quest_objects = {}
QuestHelper.locale = GetLocale()
QuestHelper.faction = UnitFactionGroup("player")
QuestHelper.route = {}
QuestHelper.to_add = {}
QuestHelper.to_remove = {}
QuestHelper.quest_log = {}

--[[
local function ObjectiveIsKnown(objective)
  for i, j in pairs(objective.after) do
    if i.watched and not ObjectiveIsKnown(i) then -- Need to know how to do everything before this objective.
      return false
    end
  end
  
  if objective.Known then
    return objective:Known()
  end
  
  -- If returns true if we know where to go to complete the objective.
  if (objective.o.finish and ObjectiveIsKnown(GetObjectiveObject("monster", objective.o.finish))) or
     (objective.fb.finish and objective.fb.finish ~= objective.o.finish
      and ObjectiveIsKnown(GetObjectiveObject("monster", objective.fb.finish))) or
     (objective.o.pos and next(objective.o.pos, nil)) or
     (objective.fb.pos and next(objective.fb.pos, nil)) then
    return true
  end
  
  if objective.o.drop then
    for m, count in pairs(objective.o.drop) do
      if ObjectiveIsKnown(GetObjectiveObject("monster", m)) then
        return true
      end
    end
  end
  
  if objective.fb.drop then
    for m, count in pairs(objective.fb.drop) do
      if ObjectiveIsKnown(GetObjectiveObject("monster", m)) then
        return true
      end
    end
  end
  
  return false
end

local function GetObjectiveDistance(objective, c, z, x, y)
  if objective.o.finish then
    return GetObjectiveDistance(GetObjectiveObject("monster", objective.o.finish), c, z, x, y)
  elseif objective.fb.finish then
    return GetObjectiveDistance(GetObjectiveObject("monster", objective.fb.finish), c, z, x, y, c, z, x, y)
  end
  
  local distance, oc, oz, ox, oy = nil, 0, 0, 0, 0
  
  if objective.Distance then
    return objective:Distance(c, z, x, y)
  end
  
  if objective.o.vendor or objective.fb.vendor then
    local faction = UnitFactionGroup("player")
    
    if objective.o.vendor then
      for i, vendor in pairs(objective.o.vendor) do
        local npc = GetObjectiveObject("monster", vendor)
        if not npc.faction or npc.faction == faction then
          local d, mc, mz, mx, my = GetObjectiveDistance(npc, c, z, x, y)
          if not distance or d and d < distance then
            distance, oc, oz, ox, oy = d, mc, mz, mx, my
          end
        end
      end
    end
    
    if objective.fb.vendor then
      for i, vendor in pairs(objective.fb.vendor) do
        local npc = GetObjectiveObject("monster", vendor)
        if not npc.faction or npc.faction == faction then
          local d, mc, mz, mx, my = GetObjectiveDistance(npc, c, z, x, y)
          if not distance or d and d < distance then
            distance, oc, oz, ox, oy = d, mc, mz, mx, my
          end
        end
      end
    end
    
    if distance then return distance, oc, oz, ox, oy end
  end
  
  if objective.o.drop or objective.fb.drop then
    local score = 0
    
    if objective.o.drop then
      for m, count in pairs(objective.o.drop) do
        local monster = GetObjectiveObject("monster", m)
        local d, mc, mz, mx, my = GetObjectiveDistance(monster, c, z, x, y)
        if d then -- TODO: Check for nil in other places too
          if d < 1 then
            return d, mc, mz, mx, my
          elseif d then
            local s = count/(monster.o.looted or 1)/d
            if s > score then
              score, distance, oc, oz, ox, oy = s, d, mc, mz, mx, my
            end
          end
        end
      end
    end
    
    if objective.fb.drop then
      for m, count in pairs(objective.fb.drop) do
        local monster = GetObjectiveObject("monster", m)
        local d, mc, mz, mx, my = GetObjectiveDistance(monster, c, z, x, y)
        if d then
          if d < 1 then
            return d, mc, mz, mx, my
          elseif d then
            local s = count/(monster.fb.looted or 1)/d
            if s > score then
              score, distance, oc, oz, ox, oy = s, d, mc, mz, mx, my
            end
          end
        end
      end
    end
    
    if distance then return distance, oc, oz, ox, oy end
  end
  
  if objective.o.pos or objective.fb.pos then
    local score = 0
    
    if objective.o.pos then
      for i, pos in ipairs(objective.o.pos) do
        local d = Astrolabe:ComputeDistance(pos[1], pos[2], pos[3], pos[4], c, z, x, y)
        
        if d < 1 then
          return d, pos[1], pos[2], pos[3], pos[4]
        end
        local s = pos[5]/d
        if s > score then
          score, distance, oc, oz, ox, oy = s, d, pos[1], pos[2], pos[3], pos[4]
        end
      end
    end
    
    if objective.fb.pos then
      for i, pos in ipairs(objective.fb.pos) do
        local d = Astrolabe:ComputeDistance(pos[1], pos[2], pos[3], pos[4], c, z, x, y)
        
        if d < 1 then
          return d, pos[1], pos[2], pos[3], pos[4]
        end
        local s = pos[5]/d
        if s > score then
          score, distance, oc, oz, ox, oy = s, d, pos[1], pos[2], pos[3], pos[4]
        end
      end
    end
    
    -- if distance then return distance, oc, oz, ox, oy end
  end
  
  return distance, oc, oz, ox, oy
end

local function GetObjectiveDistance2(objective, c1, z1, x1, y1, c2, z2, x2, y2)
  if objective.o.finish then
    return GetObjectiveDistance2(GetObjectiveObject("monster", objective.o.finish), c1, z1, x1, y1, c2, z2, x2, y2)
  elseif objective.fb.finish then
    return GetObjectiveDistance2(GetObjectiveObject("monster", objective.fb.finish), c1, z1, x1, y1, c2, z2, x2, y2)
  end
  
  if objective.Distance2 then
    return objective:Distance2()
  end
  
  local distance, oc, oz, ox, oy = nil, 0, 0, 0, 0
  
  if objective.o.vendor or objective.fb.vendor then
    local faction = UnitFactionGroup("player")
    
    if objective.o.vendor then
      for i, vendor in pairs(objective.o.vendor) do
        local npc = GetObjectiveObject("monster", vendor)
        if not npc.faction or npc.faction == faction then
          local d, mc, mz, mx, my = GetObjectiveDistance2(npc, c1, z1, x1, y1, c2, z2, x2, y2)
          if not distance or d and d < distance then
            distance, oc, oz, ox, oy = d, mc, mz, mx, my
          end
        end
      end
    end
    
    if objective.fb.vendor then
      for i, vendor in pairs(objective.fb.vendor) do
        local npc = GetObjectiveObject("monster", vendor)
        if not npc.faction or npc.faction == faction then
          local d, mc, mz, mx, my = GetObjectiveDistance2(npc, c1, z1, x1, y1, c2, z2, x2, y2)
          if not distance or d and d < distance then
            distance, oc, oz, ox, oy = d, mc, mz, mx, my
          end
        end
      end
    end
    
    if distance then return distance, oc, oz, ox, oy end
  end
  
  if objective.o.drop or objective.fb.drop then
    local score = 0
    
    if objective.o.drop then
      for m, count in pairs(objective.o.drop) do
        local monster = GetObjectiveObject("monster", m)
        local d, mc, mz, mx, my = GetObjectiveDistance2(monster, c1, z1, x1, y1, c2, z2, x2, y2)
        if d then
          if d < 1 then
            return d, mc, mz, mx, my
          elseif d then
            local s = count/(monster.o.looted or 1)/d
            if s > score then
              score, distance, oc, oz, ox, oy = s, d, mc, mz, mx, my
            end
          end
        end
      end
    end
    
    if objective.fb.drop then
      for m, count in pairs(objective.fb.drop) do
        local monster = GetObjectiveObject("monster", m)
        local d, mc, mz, mx, my = GetObjectiveDistance2(monster, c1, z1, x1, y1, c2, z2, x2, y2)
        if d then
          if d < 1 then
            return d, mc, mz, mx, my
          elseif d then
            local s = count/(monster.fb.looted or 1)/d
            if s > score then
              score, distance, oc, oz, ox, oy = s, d, mc, mz, mx, my
            end
          end
        end
      end
    end
    
    if distance then return distance, oc, oz, ox, oy end
  end
  
  if objective.o.pos or objective.fb.pos then
    local score = 0
    
    if objective.o.pos then
      for i, pos in ipairs(objective.o.pos) do
        local d = Astrolabe:ComputeDistance(c1, z1, x1, y1, pos[1], pos[2], pos[3], pos[4])+
                  Astrolabe:ComputeDistance(pos[1], pos[2], pos[3], pos[4], c2, z2, x2, y2)
        
        if d < 1 then
          return d, pos[1], pos[2], pos[3], pos[4]
        end
        local s = pos[5]/d
        if s > score then
          score, distance, oc, oz, ox, oy = s, d, pos[1], pos[2], pos[3], pos[4]
        end
      end
    end
    
    if objective.fb.pos then
      for i, pos in ipairs(objective.fb.pos) do
        local d = Astrolabe:ComputeDistance(c1, z1, x1, y1, pos[1], pos[2], pos[3], pos[4])+
                  Astrolabe:ComputeDistance(pos[1], pos[2], pos[3], pos[4], c2, z2, x2, y2)
        
        if d < 1 then
          return d, pos[1], pos[2], pos[3], pos[4]
        end
        local s = pos[5]/d
        if s > score then
          score, distance, oc, oz, ox, oy = s, d, pos[1], pos[2], pos[3], pos[4]
        end
      end
    end
    
    -- if distance then return distance, oc, oz, ox, oy end
  end
  
  return distance, oc, oz, ox, oy
end

GetObjectiveReason = function(objective)
  if objective.Reason then
    return objective:Reason()
  end
  
  local text = nil
  if objective.reasons then
    for reason, count in pairs(objective.reasons) do
      if text ~= nil then
        text = text .. "\n" .. reason
      else
        text = reason
      end
    end
  end
  text = text or "I don't know why this waypoint exists."
  
  if objective.o.finish or objective.fb.finish then
    text = text .. "\nTalk to |cffffff77"..(objective.o.finish or objective.fb.finish).."|r."
  elseif objective.o.vendor or objective.fb.vendor then
    local npc_list = {}
    
    if objective.o.vendor then for i, npc in ipairs(objective.o.vendor) do
      npc_list[npc] = 1
    end end
    
    if objective.fb.vendor then for i, npc in ipairs(objective.fb.vendor) do
      npc_list[npc] = 1
    end end
    
    local sort_list = {}
    
    for npc, count in pairs(npc_list) do
      local npc_objective = GetObjectiveObject("monster", npc)
      if ObjectiveIsKnown(npc_objective) then
        npc_list[npc] = GetObjectiveDistance(npc_objective, unpack(objective.pos))
        table.insert(sort_list, npc)
      else
        npc_list[npc] = nil
      end
    end
    
    table.sort(sort_list, function(a, b) return npc_list[a] < npc_list[b] end)
    
    if #sort_list > 0 then
      local count, first = math.min(#sort_list, 3), true
      text = text .. "\nPurchase from "
      for i = 1,count do
        if i ~= count then
          text = text .. " |cffffff77"..sort_list[i].."|r,"
        elseif first then
          text = text .. " |cffffff77"..sort_list[i].."|r."
        else
          text = text .. " or |cffffff77"..sort_list[i].."|r."
        end
        first = false
      end
    else
      text = text .. "\nI'm not sure whom you should purchase this from."
    end
  elseif objective.o.drop or objective.fb.drop then
    -- Going to go through all the monsters we know and suggest the 3 that are most likely to give you what you want.
    local monster_list = {}
    
    if objective.o.drop then for monster, count in pairs(objective.o.drop) do
      monster_list[monster] = count
    end end
    
    if objective.fb.drop then for monster, count in pairs(objective.fb.drop) do
      monster_list[monster] = (monster_list[monster] or 0) + count
    end end
    
    local sort_list = {}
    
    for monster, count in pairs(monster_list) do
      local monster_objective = GetObjectiveObject("monster", monster)
      local looted = (monster_objective.o.looted or 0) + (monster_objective.fb.looted or 0)
      if looted > 0 and ObjectiveIsKnown(monster_objective) then
        local distance = GetObjectiveDistance(monster_objective, unpack(objective.pos))
        if distance < 1 then distance = 1 end
        local score = count / looted / distance
        monster_list[monster] = score
        table.insert(sort_list, monster)
      else
        monster_list[monster] = nil
      end
    end
    
    table.sort(sort_list, function(a, b) return monster_list[a] > monster_list[b] end)
    
    if #sort_list > 0 then
      local count, first = math.min(#sort_list, 3), true
      text = text .. "\nSlay"
      for i = 1,count do
        if i ~= count then
          text = text .. " |cffffff77"..sort_list[i].."|r,"
        elseif first then
          text = text .. " |cffffff77"..sort_list[i].."|r."
        else
          text = text .. " or |cffffff77"..sort_list[i].."|r."
        end
        first = false
      end
    else
      text = text .. "\nI'm not sure what monster you should slay for this."
    end
  end
  return text
end ]]

function QuestHelper:OnEvent(event)
  if event == "VARIABLES_LOADED" then
    QuestHelper_UpgradeDatabase(_G)
  end
  
  if event == "PLAYER_TARGET_CHANGED" then
    if UnitExists("target") and UnitIsVisible("target") and UnitCreatureType("target") ~= "Critter" and not UnitIsPlayer("target") and not UnitPlayerControlled("target") then
      local monster_objective = self:GetObjective("monster", UnitName("target"))
      self:AppendObjectivePosition(monster_objective, self:UnitPosition("target"))
      monster_objective.o.faction = UnitFactionGroup("target")
      
      local level = UnitLevel("target")
      if level and level >= 1 then
        local w = monster_objective.o.levelw or 0
        monster_objective.o.level = ((monster_objective.o.level or 0)*w+level)/(w+1)
        monster_objective.o.levelw = w+1
      end
    end
  end
  
  if event == "LOOT_OPENED" then
    local target = UnitName("target")
    if target and UnitIsDead("target") and UnitCreatureType("target") ~= "Critter" and not UnitIsPlayer("target") and not UnitPlayerControlled("target") then
      local monster_objective = self:GetObjective("monster", target)
      monster_objective.o.looted = (monster_objective.o.looted or 0) + 1
      
      self:AppendObjectivePosition(monster_objective, self:UnitPosition("target"))
      
      for i = 1, GetNumLootItems() do
        local icon, name, number, rarity = GetLootSlotInfo(i)
        if name then
          if number and number >= 1 then
            self:AppendItemObjectiveDrop(self:GetObjective("item", name), name, target, number)
          else
            local total = 0
            local _, _, amount = string.find(name, "(%d+) Copper")
            if amount then total = total + amount end
            _, _, amount = string.find(name, "(%d+) Silver")
            if amount then total = total + amount * 100 end
            _, _, amount = string.find(name, "(%d+) Gold")
            if amount then total = total + amount * 10000 end
            
            if total > 0 then
              self:AppendObjectiveDrop(self:GetObjective("item", "money"), target, total)
            end
          end
        end
      end
    else
      for i = 1, GetNumLootItems() do
        local icon, name, number, rarity = GetLootSlotInfo(i)
        if name and number >= 1 then
          self:AppendItemObjectivePosition(self:GetObjective("item", name), name, self:PlayerPosition())
        end
      end
    end
  end
  
  if event == "QUEST_LOG_UPDATE" then
    self.defered_quest_scan = true
  end
  
  if event == "QUEST_DETAIL" then
    if not self.quest_giver then self.quest_giver = {} end
    self.quest_giver[GetTitleText()] = UnitName("npc")
  end
  
  if event == "QUEST_COMPLETE" or event == "QUEST_PROGRESS" then
    local quest = GetTitleText()
    if quest then
      local level, hash = self:GetQuestLevel(quest)
      if not level or level < 1 then
        self:TextOut("Don't know quest level for ".. quest.."!")
        return
      end
      local q = self:GetQuest(quest, level, hash)
      
      if q.need_hash then
        q.o.hash = hash
      end
      
      local unit = UnitName("npc")
      if unit then
        q.o.finish = unit
        q.o.pos = nil
      elseif not q.o.finish then
        self:AppendObjectivePosition(q, self:PlayerPosition())
      end
    end
  end
  
  if event == "MERCHANT_SHOW" then
    local npc_name = UnitName("npc")
    if npc_name then
      local npc_objective = self:GetObjective("monster", npc_name)
      local index = 1
      while true do
        local item_name = GetMerchantItemInfo(index)
        if item_name then
          index = index + 1
          local item_objective = self:GetObjective("item", item_name)
          if not item_objective.o.vendor then
            item_objective.o.vendor = {npc_name}
          else
            local known = false
            for i, vendor in ipairs(item_objective.o.vendor) do
              if npc_name == vendor then
                known = true
                break
              end
            end
            if not known then
              table.insert(item_objective.o.vendor, npc_name)
            end
          end
        else
          break
        end
      end
    end
  end
end

function QuestHelper:OnUpdate()
  if self.defered_quest_scan then
    self.defered_quest_scan = false
    self:ScanQuestLog()
  end
  if coroutine.status(self.update_route) ~= "dead" then
    local state, err = coroutine.resume(self.update_route, self)
    if not state then self:TextOut("|cffff0000The routing co-routine just exploded|r: |cffffff77"..err.."|r") end
  end
end

QuestHelper:RegisterEvent("PLAYER_TARGET_CHANGED")
QuestHelper:RegisterEvent("LOOT_OPENED")
QuestHelper:RegisterEvent("QUEST_COMPLETE")
QuestHelper:RegisterEvent("QUEST_LOG_UPDATE")
QuestHelper:RegisterEvent("QUEST_PROGRESS")
QuestHelper:RegisterEvent("MERCHANT_SHOW")
QuestHelper:RegisterEvent("VARIABLES_LOADED")
QuestHelper:RegisterEvent("QUEST_DETAIL")

QuestHelper:SetScript("OnEvent", QuestHelper.OnEvent)
QuestHelper:SetScript("OnUpdate", QuestHelper.OnUpdate)
