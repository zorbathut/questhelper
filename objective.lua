local function ObjectiveCouldBeFirst(self)
  if (self.user_ignore == nil and self.auto_ignore) or self.user_ignore then
    return false
  end
  
  for i, j in pairs(self.after) do
    if i.watched then
      return false
    end
  end
  
  return true
end

local function DefaultObjectiveKnown(self)
  if self.user_ignore == nil then
    if (self.filter_zone and QuestHelper_Pref.filter_zone) or
       (self.filter_done and QuestHelper_Pref.filter_done) or
       (self.filter_level and QuestHelper_Pref.filter_level) then
      return false
    end
  elseif self.user_ignore then
    return false
  end
  
  
  for i, j in pairs(self.after) do
    if i.watched and not i:Known() then -- Need to know how to do everything before this objective.
      return false
    end
  end
  
  return true
end

local function ObjectiveReason(self, short)
  local reason, rc = nil, 0
  if self.reasons then
    for r, c in pairs(self.reasons) do
      if c > rc then
        reason, rc = r, c
      end
    end
  end
  
  if not reason then reason = "Do some extremely secret unspecified something." end
  
  if not short and self.pos and self.pos[6] then
    reason = reason .. "\n" .. self.pos[6]
  end
  
  return reason
end

local function DummyObjectiveKnown(self)
  return (self.o.pos or self.fb.pos) and DefaultObjectiveKnown(self)
end

local function ItemKnown(self)
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

local function ObjectiveAppendPositions(self, objective, weight, why)
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    objective:AddLoc(p[1], p[2], p[3], p[4], p[5]*weight, why)
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    objective:AddLoc(p[1], p[2], p[3], p[4], p[5]*weight, why)
  end end
end


local function ObjectivePrepareRouting(self)
  self.setup_count = self.setup_count + 1
  if not self.setup then
    self:AppendPositions(self, 1, nil)
    self:FinishAddLoc()
  end
end

local function ItemAppendPositions(self, objective, weight, why)
  why2 = why and why.."\n" or ""
  
  if self.o.vendor then for i, npc in ipairs(self.o.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    if (not n.o.faction or n.o.faction == self.qh.faction) and
       (not n.fb.faction or n.fb.faction == self.qh.faction) then
      
      n:AppendPositions(objective, 1, why2.."Purchase from "..self.qh:HighlightText(npc)..".")
    end
  end end
  
  if self.fb.vendor then for i, npc in ipairs(self.fb.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    if (not n.o.faction or n.o.faction == self.qh.faction) and
       (not n.fb.faction or n.fb.faction == self.qh.faction) then
      
      n:AppendPositions(objective, 1, why2.."Purchase from "..self.qh:HighlightText(npc)..".")
    end
  end end
  
  if next(self.p, nil) then
    -- If we have points from vendors, then always use vendors. I don't want it telling you to killing the
    -- towns people just because you had to talk to them anyway, and it saves walking to the store.
    return
  end
  
  if self.o.drop then for monster, count in pairs(self.o.drop) do
    local m = self.qh:GetObjective("monster", monster)
    m:AppendPositions(objective, m.o.looted and count/m.o.looted or 1, why2.."Slay "..self.qh:HighlightText(monster)..".")
  end end
  
  if self.fb.drop then for monster, count in pairs(self.fb.drop) do
    local m = self.qh:GetObjective("monster", monster)
    m:AppendPositions(self, m.fb.looted and count/m.fb.looted or 1, why2.."Slay "..self.qh:HighlightText(monster)..".")
  end end
  
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    objective:AddLoc(p[1], p[2], p[3], p[4], p[5], why)
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    objective:AddLoc(p[1], p[2], p[3], p[4], p[5], why)
  end end
  
  if self.quest then
    local item_list=self.quest.o.item
    if item_list then
      local data = item_list[self.item]
      if data and data.drop then
        for monster, count in pairs(data.drop) do
          local m = self.qh:GetObjective("monster", monster)
          m:AppendPositions(objective, m.o.looted and count/m.o.looted or 1, why2.."Slay "..self.qh:HighlightText(monster)..".")
        end
      elseif data and data.pos then
        for i, p in ipairs(data.pos) do
          objective:AddLoc(p[1], p[2], p[3], p[4], p[5], why)
        end
      end
    end
    
    item_list=self.quest.fb.item
    if item_list then 
      local data = item_list[self.item]
      if data and data.drop then
        for monster, count in pairs(data.drop) do
          local m = self.qh:GetObjective("monster", monster)
          m:AppendPositions(objective, m.fb.looted and count/m.fb.looted or 1, why2.."Slay "..self.qh:HighlightText(monster)..".")
        end
      elseif data and data.pos then
        for i, p in ipairs(data.pos) do
          objective:AddLoc(p[1], p[2], p[3], p[4], p[5], why)
        end
      end
    end
  end
end












---------------













local function AddLoc(self, c, z, x, y, w, why)
  assert(not self.setup)
  
  if w > 0 then
    x, y = self.qh.Astrolabe:TranslateWorldMapPosition(c, z, x, y, c, 0)
    
    x = x * self.qh.continent_scales_x[c]
    y = y * self.qh.continent_scales_y[c]
    local list = self.qh.zone_nodes[c][z]
    
    local points = self.p[list]
    if not points then
      points = {}
      self.p[list] = points
    end
    
    for i, p in pairs(points) do
      local u, v = x-p[3], y-p[4]
      if u*u+v*v < 25 then -- Combine points within a threshold of 5 seconds travel time.
        p[3] = (p[3]*p[5]+x*w)/(p[5]+w)
        p[4] = (p[4]*p[5]+y*w)/(p[5]+w)
        p[5] = p[5]+w
        if w > p[7] then
          p[6], p[7] = why, w
        end
        return
      end
    end
    
    table.insert(points, {list, nil, x, y, w, why, w})
  end
end

local function FinishAddLoc(self)
  local mx = 0
  
  for z, pl in pairs(self.p) do
    for i, p in ipairs(pl) do
      if p[5] > mx then
        self.location = p
        mx = p[5]
      end
    end
  end
  
  -- Remove probably useless locations.
  for z, pl in pairs(self.p) do
    local remove_zone = true
    local i = 1
    while i <= #pl do
      if pl[i][5] < mx*0.25 then
        table.remove(pl, i)
      else
        remove_zone = false
        i = i + 1
      end
    end
    if remove_zone then
      self.p[z] = nil
    end
  end
  
  local node_map = self.nm
  local node_list = self.nl
  
  for list, pl in pairs(self.p) do
    local dist = self.d[list]
    
    assert(not dist)
    
    if not dist then
      dist = {}
      self.d[list] = dist
    end
    
    for i, point in ipairs(pl) do
      point[5] = mx/point[5] -- Will become 1 for the most desired location, and become larger and larger for less desireable locations.
      
      point[2] = {}
      
      for i, node in ipairs(list) do
        local u, v = point[3]-node.x, point[4]-node.y
        local d = math.sqrt(u*u+v*v)
        
        point[2][i] = d
        
        if dist[i] then
          if d*point[5] < dist[i][1]*dist[i][2] then
            dist[i][1], dist[i][2] = d, point[5]
            node_map[node] = point
          end
        else
          dist[i] = {d,point[5]}
          
          if not node_map[node] then
            table.insert(node_list, node)
            node_map[node] = point
          else
            u, v = node_map[node][3]-node.x, node_map[node][4]-node.y
            
            if dist[i][1]*dist[i][2] < math.sqrt(u*u+v*v)*node_map[node][5] then
              node_map[node] = point
            end
          end
        end
      end
    end
  end
  
  if #node_list == 0 then QuestHelper:Error("Boom!") end
  
  assert(not self.setup)
  self.setup = true
  table.insert(self.qh.prepared_objectives, self)
end

local function GetPosition(self)
  assert(self.setup)
  
  return self.location
end

local function ComputeTravelTime(self, pos)
  assert(self.setup)
  
  local graph = self.qh.world_graph
  local nl = self.nl
  
  graph:PrepareSearch()
  
  for z, l in pairs(self.d) do
    for i, n in ipairs(z) do
      if n.s == 0 then
        n.e, n.w = unpack(l[i])
        n.s = 3
      elseif n.e * n.w < l[i][1]*l[i][2] then
        n.e, n.w = unpack(l[i])
      end
    end
  end
  
  
  local d = pos[2]
  for i, n in ipairs(pos[1]) do
    graph:AddStartNode(n, d[i], nl)
  end
  
  local e = graph:DoSearch(nl)
  
  d = e.g+e.e
  e = self.nm[e]
  
  local l = self.p[pos[1]]
  if l then
    local x, y = pos[3], pos[4]
    local score = d*e[5]
    
    for i, n in ipairs(l) do
      local u, v = x-n[3], y-n[4]
      local d2 = math.sqrt(u*u+v*v)
      local s = d2*n[5]
      if s < score then
        d, e, score = d2, n, s
      end
    end
  end
  
  assert(e)
  return d, e
end

local function ComputeTravelTime2(self, pos1, pos2)
  assert(self.setup)
  
  local graph = self.qh.world_graph
  local nl = self.nl
  
  graph:PrepareSearch()
  
  for z, l in pairs(self.d) do
    for i, n in ipairs(z) do
      if n.s == 0 then
        n.e, n.w = unpack(l[i])
        n.s = 3
      elseif n.e * n.w < l[i][1]*l[i][2] then
        n.e, n.w = unpack(l[i])
      end
    end
  end
  
  local d = pos1[2]
  for i, n in ipairs(pos1[1]) do
    graph:AddStartNode(n, d[i], nl)
  end
  
  graph:DoFullSearch(nl)
  
  graph:PrepareSearch()
  
  -- Now, we need to figure out how long it takes to get to each node.
  for z, point_list in pairs(self.p) do
    if z == pos1[1] then
      -- Will also consider min distance.
      local x, y = pos1[3], pos1[4]
      
      for i, p in ipairs(point_list) do
        local a, b = p[3]-x, p[4]-y
        local u, v = p[3], p[4]
        local d = math.sqrt(a*a+b*b)
        local w = p[5]
        local score = d*w
        for i, n in ipairs(z) do
          a, b = n.x-u, n.y-v
          local bleh = math.sqrt(a*a+b*b)+n.g
          local s = bleh*w
          if s < score then
            d, score = bleh, d
          end
        end
        p[7] = d
      end
    else
      for i, p in ipairs(point_list) do
        local x, y = p[3], p[4]
        local w = p[5]
        local d
        local score
        
        for i, n in ipairs(z) do
          local a, b = n.x-x, n.y-y
          local d2 = math.sqrt(a*a+b*b)+n.g
          local s = d2*w
          if not score or s < score then
            d, score = d2, s
          end
        end
        p[7] = d
      end
    end
  end
  
  d = pos2[2]
  
  for i, n in ipairs(pos2[1]) do
    n.e = d[i]
    n.s = 3
  end
  
  local el = pos2[1]
  local nm = self.nm2
  
  for z, l in pairs(self.d) do
    for i, n in ipairs(z) do
      local x, y = n.x, n.y
      local bp
      local bg
      local bs
      for i, p in ipairs(self.p[z]) do
        local a, b = x-p[3], y-p[4]
        d = p[7]+math.sqrt(a*a+b*b)
        s = d*p[5]
        if not bs or s < bs then
          bg, bp, bs = d, p, s
        end
      end
      
      nm[n] = bp
      -- Using score instead of distance, because we want nodes we're not really interested in to be less likely to get chosen.
      graph:AddStartNode(n, bs, el)
    end
  end
  
  local e = graph:DoSearch(pos2[1])
  
  d = nm[e.p][7]
  local d2 = e.g+e.e-e.p.g+(e.p.g/nm[e.p][5]-nm[e.p][7])
  
  e = nm[e.p]
  local total = (d+d2)*e[5]
  
  if self.p[el] then
    local x, y = pos2[3], pos2[4]
    for i, p in ipairs(self.p[el]) do
      local a, b = x-p[3], y-p[4]
      local c = math.sqrt(a*a+b*b)
      local t = (p[7]+c)*p[5]
      if t < total then
        total, d, d2, e = t, p[7], c, p
      end
    end
  end
  
  assert(e)
  return d, d2, e
end

local function DoneRouting(self)
  assert(self.setup_count > 0)
  assert(self.setup)
  
  self.setup_count = self.setup_count - 1
end

function QuestHelper:NewObjectiveObject()
  return
   {
    qh=self,
    
    CouldBeFirst=ObjectiveCouldBeFirst,
    
    DefaultKnown=DefaultObjectiveKnown,
    Known=DummyObjectiveKnown,
    Reason=ObjectiveReason,
    
    AppendPositions=ObjectiveAppendPositions,
    PrepareRouting=ObjectivePrepareRouting,
    AddLoc=AddLoc,
    FinishAddLoc=FinishAddLoc,
    DoneRouting=DoneRouting,
    
    Position=GetPosition,
    TravelTime=ComputeTravelTime,
    TravelTime2=ComputeTravelTime2,
    
    user_ignore=nil, -- When nil, will use filters. Will ignore, when true, always show (if known).
    
    priority=3, -- A hint as to what priority the quest should have. Should be 1, 2, 3, 4, or 5.
    real_priority=3, -- This will be set to the priority routing actually decided to assign it.
    
    setup_count=0,
    
    icon_id=12,
    icon_bg=14,
    
    match_zone=false,
    match_level=false,
    match_done=false,
    
    before={}, -- List of objectives that this objective must appear before.
    after={}, -- List of objectives that this objective must appear after.
    
    -- Routing related junk.
    d={},
    p={},
    nm={}, -- Maps nodes to their nearest zone/list/x/y position.
    nm2={}, -- Maps nodes to their nears position, but dynamically set in TravelTime2.
    nl={}, -- List of all the nodes we need to consider.
    location={nil,nil,0,0,nil}, -- Will be set to the best position for the node.
    pos={nil,nil,0,0,nil}, -- Zone node list, distance list, x, y, reason.
    sop={nil,nil,0,0,nil}
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
      objective_object.Known = ItemKnown
      objective_object.AppendPositions = ItemAppendPositions
      objective_object.icon_id = 2
    elseif category == "monster" then
      objective_object.icon_id = 1
    elseif category == "object" then
      objective_object.icon_id = 3
    elseif category == "event" then
      objective_object.icon_id = 4
    elseif category == "loc" then
      objective_object.icon_id = 6
    elseif category == "reputation" then
      objective_object.icon_id = 5
    else
      self:TextOut("FIXME: Objective type '"..category.."' for objective '"..objective.."' isn't explicitly supported yet; hopefully the dummy handler will do something sensible.")
    end
    
    objective_list[objective] = objective_object
    
    if category == "loc" then
      -- Loc is special, we don't store it, and construct it from the string.
      -- Don't have any error checking here, will assume it's correct.
      local _, _, c, z, x, y = string.find(objective,"^(%d+),(%d+),([%d%.]+),([%d%.]+)$")
      objective_object.o = {pos={{tonumber(c),tonumber(z),tonumber(x),tonumber(y),1}}}
      objective_object.fb = {}
    else
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
      local l = QuestHelper_StaticData[self.locale]
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

QuestHelper.priority_names = {"Highest", "High", "Normal", "Low", "Lowest"}

function QuestHelper:AddObjectiveOptionsToMenu(obj, menu)
  local submenu = self:CreateMenu()
  
  for i, name in ipairs(self.priority_names) do
    local item = self:CreateMenuItem(submenu, name)
    local tex
    
    if obj.priority == i then
      tex = self:GetIconTexture(item, 10)
    elseif obj.real_priority == i then
      tex = self:GetIconTexture(item, 8)
    else
      tex = self:GetIconTexture(item, 12)
      tex:SetVertexColor(1, 1, 1, 0)
    end
    
    item:AddTexture(tex, true)
    item:SetFunction(
      function (obj, pri)
        obj.priority = i
        QuestHelper:ForceRouteUpdate()
      end, obj, i)
  end
  
  self:CreateMenuItem(menu, "Priority"):SetSubmenu(submenu)
  
  self:CreateMenuItem(menu, "Ignore"):SetFunction(
    function (obj)
      obj.user_ignore = true
      QuestHelper:ForceRouteUpdate()
    end, obj)
end
