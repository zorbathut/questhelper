local function DefaultObjectiveKnown(self)
  for i, j in pairs(self.after) do
    if i.watched and not i:Known() then -- Need to know how to do everything before this objective.
      return false
    end
  end
  return true
end

local function DefaultObjectiveReason(self)
  local text = nil
  if self.reasons then
    for reason, count in pairs(self.reasons) do
      if text ~= nil then
        text = text .. "\n" .. reason
      else
        text = reason
      end
      if count > 1 then
        text = text .. "(x" .. count .. ")"
      end
    end
  end
  return text or "I don't know why this waypoint exists."
end

local function DummyObjectiveDistance(self, c, z, x, y)
  if self.o.pos then
    return self.qh:PositionListDistance(self.o.pos, c, z, x, y)
  elseif self.fb.pos then
    return self.qh:PositionListDistance(self.fb.pos, c, z, x, y)
  end
end

local function DummyObjectiveDistance2(self, c1, z1, x1, y1, c2, z2, x2, y2)
  if self.o.pos then
    return self.qh:PositionListDistance2(self.o.pos, c1, z1, x1, y1, c2, z2, x2, y2)
  elseif self.fb.pos then
    return self.qh:PositionListDistance2(self.fb.pos, c1, z1, x1, y1, c2, z2, x2, y2)
  end
end

local function DummyObjectiveKnown(self)
  return (self.o.pos or self.fb.pos) and DefaultObjectiveKnown(self)
end

local function ItemObjectiveDistance(self, c, z, x, y)
  -- I now declare myself the master of excess code duplication.
  -- Too bad I can't even try to pretend that's something to be proud of. :(
  
  local distance, score, bc, bz, bx, by = nil, nil, 0, 0, 0, 0
  
  if self.o.vendor then for i, npc in ipairs(self.o.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    if (not n.o.faction or n.o.faction == self.qh.faction) and
       (not n.fb.faction or n.fb.faction == self.qh.faction) then
      local d, nc, nz, nx, ny = n:Distance(c, z, x, y)
      if not score or d < score then
        distance, score, bc, bz, bx, by = d, d, nc, nz, nx, ny
      end
    end
  end end
  
  if self.fb.vendor then for i, npc in ipairs(self.fb.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    if (not n.o.faction or n.o.faction == self.qh.faction) and
       (not n.fb.faction or n.fb.faction == self.qh.faction) then
      local d, nc, nz, nx, ny = n:Distance(c, z, x, y)
      if not score or d < score then
        distance, score, bc, bz, bx, by = d, d, nc, nz, nx, ny
      end
    end
  end end
  
  if self.o.drop then for monster, count in pairs(self.o.drop) do
    local m = self.qh:GetObjective("monster", monster)
    local d, nc, nz, nx, ny = m:Distance(c, z, x, y)
    if d then
      local s = d/count*(m.o.looted or 1)
      if not score or s < score then
        distance, score, bc, bz, bx, by = d, s, nc, nz, nx, ny
      end
    end
  end end
  
  if self.fb.drop then for monster, count in pairs(self.fb.drop) do
    local m = self.qh:GetObjective("monster", monster)
    local d, nc, nz, nx, ny = m:Distance(c, z, x, y)
    if d then
      local s = d/count*(m.fb.looted or 1)
      if not score or s < score then
        distance, score, bc, bz, bx, by = d, s, nc, nz, nx, ny
      end
    end
  end end
  
  if distance then return distance, bc, bz, bx, by end
  
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    local d = self.qh:Distance(c, z, x, y, p[1], p[2], p[3], p[4])
    -- Pretend upto 3x distance for a monster we've only seen once, approaching the actual distance the more we've seen.
    local s = d + d*2/p[5]
    if not score or s < score then
      distance, score, bc, bz, bx, by = d, s, p[1], p[2], p[3], p[4]
    end
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    local d = self.qh:Distance(c, z, x, y, p[1], p[2], p[3], p[4])
    local s = d + d*2/p[5]
    if not score or s < score then
      distance, score, bc, bz, bx, by = d, s, p[1], p[2], p[3], p[4]
    end
  end end
  
  if self.quest then
    local item_list=self.quest.o.item
    if item_list then 
      local data = item_list[self.item]
      if data.drop then
        for monster, count in pairs(data.drop) do
          local m = self.qh:GetObjective("monster", monster)
          local d, nc, nz, nx, ny = m:Distance(c, z, x, y)
          if d then
            local s = d/count*(m.o.looted or 1)
            if not score or s < score then
              distance, score, bc, bz, bx, by = d, s, nc, nz, nx, ny
            end
          end
        end
      elseif data.pos then
        for i, p in ipairs(data.pos) do
          local d = self.qh:Distance(c, z, x, y, p[1], p[2], p[3], p[4])
          local s = d + d*2/p[5]
          if not score or s < score then
            distance, score, bc, bz, bx, by = d, s, p[1], p[2], p[3], p[4]
          end
        end
      end
    end
    
    item_list=self.quest.fb.item
    if item_list then 
      local data = item_list[self.item]
      if data.drop then
        for monster, count in pairs(data.drop) do
          local m = self.qh:GetObjective("monster", monster)
          local d, nc, nz, nx, ny = m:Distance(c, z, x, y)
          if d then
            local s = d/count*(m.fb.looted or 1)
            if not score or s < score then
              distance, score, bc, bz, bx, by = d, s, nc, nz, nx, ny
            end
          end
        end
      elseif data.pos then
        for i, p in ipairs(data.pos) do
          local d = self.qh:Distance(c, z, x, y, p[1], p[2], p[3], p[4])
          local s = d + d*2/p[5]
          if not score or s < score then
            distance, score, bc, bz, bx, by = d, s, p[1], p[2], p[3], p[4]
          end
        end
      end
    end
  end
  
  return distance, bc, bz, bx, by
end

local function ItemObjectiveDistance2(self, c1, z1, x1, y1, c2, z2, x2, y2)
  -- TODO: Going to return 2 distances later.
  
  local bd1, bd2, score, bc, bz, bx, by = 0, 0, nil, nil, 0, 0, 0, 0
  
  if self.o.vendor then for i, npc in ipairs(self.o.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    if (not n.o.faction or n.o.faction == self.qh.faction) and
       (not n.fb.faction or n.fb.faction == self.qh.faction) then
      local d1, d2, nc, nz, nx, ny = n:Distance2(c1, z1, x1, y1, c2, z2, x2, y2)
      local t = d1+d2
      if not score or t < score then
        bd1, bd2, score, bc, bz, bx, by = d1, d2, t, nc, nz, nx, ny
      end
    end
  end end
  
  if self.fb.vendor then for i, npc in ipairs(self.fb.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    if (not n.o.faction or n.o.faction == self.qh.faction) and
       (not n.fb.faction or n.fb.faction == self.qh.faction) then
      local d1, d2, nc, nz, nx, ny = n:Distance2(c1, z1, x1, y1, c2, z2, x2, y2)
      local t = d1+d2
      if not score or t < score then
        bd1, bd2, score, bc, bz, bx, by = d1, d2, t, nc, nz, nx, ny
      end
    end
  end end
  
  if self.o.drop then for monster, count in pairs(self.o.drop) do
    local m = self.qh:GetObjective("monster", monster)
    local d1, d2, nc, nz, nx, ny = m:Distance2(c1, z1, x1, y1, c2, z2, x2, y2)
    if d1 then
      local s = (d1+d2)/count*(m.o.looted or 1)
      if not score or s < score then
        bd1, bd2, score, bc, bz, bx, by = d1, d2, s, nc, nz, nx, ny
      end
    end
  end end
  
  if self.fb.drop then for monster, count in pairs(self.fb.drop) do
    local m = self.qh:GetObjective("monster", monster)
    local d1, d2, nc, nz, nx, ny = m:Distance2(c1, z1, x1, y1, c2, z2, x2, y2)
    if d1 then
      local s = (d1+d2)/count*(m.fb.looted or 1)
      if not score or s < score then
        bd1, bd2, score, bc, bz, bx, by = d1, d2, s, nc, nz, nx, ny
      end
    end
  end end
  
  if score then return bd1, bd2, bc, bz, bx, by end
  
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    local d1 = self.qh:Distance(c1, z1, x1, y1, p[1], p[2], p[3], p[4])
    local d2 = self.qh:Distance(c2, z2, x2, y2, p[1], p[2], p[3], p[4])
    -- Pretend upto 3x distance for a monster we've only seen once, approaching the actual distance the more we've seen.
    local s = d1+d2+(d1+d2)*2/p[5]
    if not score or s < score then
      bd1, bd2, score, bc, bz, bx, by = d1, d2, s, p[1], p[2], p[3], p[4]
    end
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    local d1 = self.qh:Distance(c1, z1, x1, y1, p[1], p[2], p[3], p[4])
    local d2 = self.qh:Distance(c2, z2, x2, y2, p[1], p[2], p[3], p[4])
    local s = d1+d2+(d1+d2)*2/p[5]
    if not score or s < score then
      bd1, bd2, bc, bz, bx, by = d1, d2, s, p[1], p[2], p[3], p[4]
    end
  end end
  
  if self.quest then
    local item_list=self.quest.o.item
    if item_list then 
      local data = item_list[self.item]
      if data.drop then
        for monster, count in pairs(data.drop) do
          local m = self.qh:GetObjective("monster", monster)
          local d1, d2, nc, nz, nx, ny = m:Distance2(c1, z1, x1, y1, c2, z2, x2, y2)
          if d1 then
            local s = (d1+d2)/count*(m.o.looted or 1)
            if not score or s < score then
              bd1, bd2, score, bc, bz, bx, by = d1, d2, s, nc, nz, nx, ny
            end
          end
        end
      elseif data.pos then
        for i, p in ipairs(data.pos) do
          local d1 = self.qh:Distance(c1, z1, x1, y1, p[1], p[2], p[3], p[4])
          local d2 = self.qh:Distance(c2, z2, x2, y2, p[1], p[2], p[3], p[4])
          local s = d1+d2+(d1+d2)*2/p[5]
          if not score or s < score then
            bd1, bd2, score, bc, bz, bx, by = d1, d2, s, p[1], p[2], p[3], p[4]
          end
        end
      end
    end
    
    item_list=self.quest.fb.item
    if item_list then 
      local data = item_list[self.item]
      if data.drop then
        for monster, count in pairs(data.drop) do
          local m = self.qh:GetObjective("monster", monster)
          local d1, d2, nc, nz, nx, ny = m:Distance2(c1, z1, x1, y1, c2, z2, x2, y2)
          if d1 then
            local s = (d1+d2)/count*(m.fb.looted or 1)
            if not score or s < score then
              bd1, bd2, score, bc, bz, bx, by = d1, d2, s, nc, nz, nx, ny
            end
          end
        end
      elseif data.pos then
        for i, p in ipairs(data.pos) do
          local d1 = self.qh:Distance(c1, z1, x1, y1, p[1], p[2], p[3], p[4])
          local d2 = self.qh:Distance(c2, z2, x2, y2, p[1], p[2], p[3], p[4])
          local s = d1+d2+(d1+d2)*2/p[5]
          if not score or s < score then
            bd1, bd2, score, bc, bz, bx, by = d1, d2, s, p[1], p[2], p[3], p[4]
          end
        end
      end
    end
  end
  
  return bd1, bd2, bc, bz, bx, by
end

local function ItemObjectiveKnown(self)
  if not DefaultObjectiveKnown(self) then return false end
  
  if self.o.vendor then
    for i, npc in ipairs(self.o.vendor) do
      local n = self.qh:GetObjective("monster", npc)
      if (not n.o.faction or n.o.faction == self.qh.faction) and n:Known() then
        return true
      end
    end
  end
  
  if self.fb.vendor then
    for i, npc in ipairs(self.fb.vendor) do
      local n = self.qh:GetObjective("monster", npc)
      if (not n.fb.faction or n.fb.faction == self.qh.faction) and n:Known() then
        return true
      end
    end
  end
  
  if self.o.drop or self.fb.drop or self.o.pos or self.fb.pos then
    return true
  end
  
  if self.quest then
    local item=self.quest.o.item
    item = item and item[self.item]
    
    if item then 
      if item.pos then
        return true
      end
      if item.drop then
        for monster, count in pairs(item.drop) do
          if self.qh:GetObjective("monster", monster):Known() then
            return true
          end
        end
      end
    end
    
    item=self.quest.fb.item
    item = item and item[self.item]
    if item then 
      if item.pos then
        return true
      end
      if item.drop then
        for monster, count in pairs(item.drop) do
          if self.qh:GetObjective("monster", monster):Known() then
            return true
          end
        end
      end
    end
  end
  
  return false
end

local function ItemObjectiveReason(self)
  local c, z, x, y = unpack(self.pos)
  local reason, score = nil, nil
  
  if self.o.vendor then for i, npc in ipairs(self.o.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    if (not n.o.faction or n.o.faction == self.qh.faction) and
       (not n.fb.faction or n.fb.faction == self.qh.faction) then
      local d = n:Distance(c, z, x, y)
      if not score or d < score then
        reason = "Purchase from "..self.qh:HighlightText(npc).."."
        score = d
      end
    end
  end end
  
  if self.o.vendor then for i, npc in ipairs(self.fb.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    if (not n.o.faction or n.o.faction == self.qh.faction) and
       (not n.fb.faction or n.fb.faction == self.qh.faction) then
      local d = n:Distance(c, z, x, y)
      if not score or d < score then
        reason = "Purchase from "..self.qh:HighlightText(npc).."."
        score = d
      end
    end
  end end
  
  if self.o.drop then for monster, count in pairs(self.o.drop) do
    local m = self.qh:GetObjective("monster", monster)
    local d = m:Distance(c, z, x, y)
    if d then
      local s = d/count*(m.o.looted or 1)
      if not score or s < score then
        reason = "Slay monster "..self.qh:HighlightText(monster).."."
        score = s
      end
    end
  end end
  
  if self.fb.drop then for monster, count in pairs(self.fb.drop) do
    local m = self.qh:GetObjective("monster", monster)
    local d = m:Distance(c, z, x, y)
    if d then
      local s = d/count*(m.fb.looted or 1)
      if not score or s < score then
        reason = "Slay monster "..self.qh:HighlightText(monster).."."
        score = s
      end
    end
  end end
  
  if not reason and self.quest then
    local item_list=self.quest.o.item
    if item_list then 
      local monster_list = item_list[self.item]
      if monster_list then for monster, count in pairs(monster_list) do
        local m = self.qh:GetObjective("monster", monster)
        local d = m:Distance(c, z, x, y)
        if d then
          local s = d/count*m.o.looted
          if not score or s < score then
            reason = "Slay monster "..self.qh:HighlightText(monster).."."
            score = s
          end
        end
      end end
    end
    
    item_list=self.quest.fb.item
    if item_list then 
      local monster_list = item_list[self.item]
      if monster_list then for monster, count in pairs(monster_list) do
        local m = self.qh:GetObjective("monster", monster)
        local d = m:Distance(c, z, x, y)
        if d then
          local s = d/count*m.fb.looted
          if not score or s < score then
            reason = "Slay monster "..self.qh:HighlightText(monster).."."
            score = s
          end
        end
      end end
    end
  end
  
  if reason then
    return DefaultObjectiveReason(self).."\n"..reason
  else
    return DefaultObjectiveReason(self)
  end
end

local function MonsterObjectiveDistance(self, c, z, x, y)
  local distance, score, bc, bz, bx, by = nil, nil
  
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    local d = self.qh:Distance(c, z, x, y, p[1], p[2], p[3], p[4])
    local s = d + d*2/p[5]
    if not score or s < score then
      distance, score, bc, bz, bx, by = d, s, p[1], p[2], p[3], p[4]
    end
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    local d = self.qh:Distance(c, z, x, y, p[1], p[2], p[3], p[4])
    local s = d + d*2/p[5]
    if not score or s < score then
      distance, score, bc, bz, bx, by = d, s, p[1], p[2], p[3], p[4]
    end
  end end
  
  return distance, bc, bz, bx, by
end

local function MonsterObjectiveDistance2(self, c1, z1, x1, y1, c2, z2, x2, y2)
  local bd1, bd2, score, bc, bz, bx, by = nil, nil, nil
  
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    local d1 = self.qh:Distance(c1, z1, x1, y1, p[1], p[2], p[3], p[4])
    local d2 = self.qh:Distance(c2, z2, x2, y2, p[1], p[2], p[3], p[4])
    local s = d1+d2+(d1+d2)*2/p[5]
    if not score or s < score then
      bd1, bd2, score, bc, bz, bx, by = d1, d2, s, p[1], p[2], p[3], p[4]
    end
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    local d1 = self.qh:Distance(c1, z1, x1, y1, p[1], p[2], p[3], p[4])
    local d2 = self.qh:Distance(c2, z2, x2, y2, p[1], p[2], p[3], p[4])
    local s = d1+d2+(d1+d2)*2/p[5]
    if not score or s < score then
      bd1, bd2, score, bc, bz, bx, by = d1, d2, s, p[1], p[2], p[3], p[4]
    end
  end end
  
  return bd1, bd2, bc, bz, bx, by
end

local function MonsterObjectiveKnown(self)
  return (self.o.pos or self.fb.pos) and DefaultObjectiveKnown(self)
end

function QuestHelper:NewObjectiveObject()
  return
   {
    qh=self,
    Distance=DummyObjectiveDistance,
    Distance2=DummyObjectiveDistance2,
    DefaultKnown=DefaultObjectiveKnown,
    Known=DummyObjectiveKnown,
    DefaultReason=DefaultObjectiveReason,
    Reason=DefaultObjectiveReason,
    before={},
    after={},
    pos={0,0,0,0},
    sop={0,0,0,0}
   }
end

function QuestHelper:GetObjective(category, objective)
  local objective_list = self.objective_objects[category]
  
  if not objective_list then
    objective_list = {}
    self.objective_objects[category] = objective_list
  end
  
  local objective_object = objective_list[objective]
  
  if not objective_object then
    objective_object = self:NewObjectiveObject()
    
    if category == "item" then
      objective_object.Distance = ItemObjectiveDistance
      objective_object.Distance2 = ItemObjectiveDistance2
      objective_object.Known = ItemObjectiveKnown
      objective_object.Reason = ItemObjectiveReason
    elseif category == "monster" then
      objective_object.Distance = MonsterObjectiveDistance
      objective_object.Distance2 = MonsterObjectiveDistance2
      objective_object.Known = MonsterObjectiveKnown
    else
      self:TextOut("FIXME: Objective type '"..category.."' for objective '"..objective.."' isn't explicitly supported yet; hopefully the dummy handler will do something sensible.")
    end
    
    objective_list[objective] = objective_object
    objective_list = QuestHelper_Objectives[category]
    if not objective_list then
      objective_list = {}
      QuestHelper_Objectives[category] = objective_list
    end
    objective_object.o = objective_list[objective]
    if not objective_object.o then
      objective_object.o = {}
      objective_list[objective] = objective_object.o
    end
    local l = QuestHelper_StaticData[GetLocale()]
    if l then
      objective_list = l.objective[category]
      if objective_list then
        objective_object.fb = objective_list[objective]
      end
    end
    if not objective_object.fb then
      objective_object.fb = {}
    end
    
    -- TODO: If we have some other source of information (like LightHeaded) add its data to objective_object.fb
    
  end
  
  return objective_object
end

function QuestHelper:AppendObjectivePosition(objective, c, z, x, y, w)
  local pos = objective.o.pos
  if not pos then
    if objective.o.drop then
      return -- If it's dropped by a monster, don't record the position we got the item at.
    end
    objective.o.pos = self:AppendPosition({}, c, z, x, y, w)
  else
    self:AppendPosition(pos, c, z, x, y, w)
  end
end

function QuestHelper:AppendObjectiveDrop(objective, monster, count)
  local drop = objective.o.drop
  if drop then
    drop[monster] = (drop[monster] or 0)+(count or 1)
  else
    drop = {[monster] = count or 1}
    objective.o.pos = nil -- If it's dropped by a monster, then forget the position we found it at.
  end
end

function QuestHelper:AppendItemObjectiveDrop(item_object, item_name, monster_name, count)
  local quest = self:ItemIsForQuest(item_object, item_name)
  if quest then
    self:AppendQuestDrop(quest, item_name, monster_name, count)
  else
    if not item_object.o.drop and not item_object.pos then
      self:PurgeQuestItem(item_object, item_name)
    end
    self:AppendObjectiveDrop(item_object, monster_name, count)
  end
end

function QuestHelper:AppendItemObjectivePosition(item_object, item_name, c, z, x, y)
  local quest = self:ItemIsForQuest(item_object, item_name)
  if quest then
    self:AppendQuestPosition(quest, item_name, c, z, x, y)
  else
    if not item_object.o.drop and not item_object.pos then
      -- Just learned that this item doesn't depend on a quest to drop, remove any quest references to it.
      self:PurgeQuestItem(item_object, item_name)
    end
    self:AppendObjectivePosition(item_object, c, z, x, y)
  end
end

function QuestHelper:AddObjectiveWatch(objective, reason)
  if not objective.reasons then
    objective.reasons = {}
  end
  
  if not next(objective.reasons, nil) then
    objective.watched = true
    if self.to_remove[objective] then
      self.to_remove[objective] = nil
    else
      self.to_add[objective] = true
    end
  end
  
  objective.reasons[reason] = (objective.reasons[reason] or 0) + 1
end

function QuestHelper:RemoveObjectiveWatch(objective, reason)
  if objective.reasons[reason] == 1 then
    objective.reasons[reason] = nil
    if not next(objective.reasons, nil) then
      objective.watched = false
      if self.to_add[objective] then
        self.to_add[objective] = nil
      else
        self.to_remove[objective] = true
      end
    end
  else
    objective.reasons[reason] = objective.reasons[reason] - 1
  end
end

function QuestHelper:ObjectiveObjectDependsOn(objective, needs)
  assert(objective ~= needs) -- If this was true, ObjectiveIsKnown would get in an infinite loop.
  objective.after[needs] = true
  needs.before[objective] = true
end
