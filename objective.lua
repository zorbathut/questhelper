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
       (self.filter_level and QuestHelper_Pref.filter_level) or
       (self.filter_blocked and QuestHelper_Pref.filter_blocked) then
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
      if not reason or c > rc or (c == rc and r > reason) then
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
      local faction = n.o.faction or n.fb.faction
      if (not faction or faction == self.qh.faction) and n:Known() then
        return true
      end
    end
  end
  
  if self.fb.vendor then
    for i, npc in ipairs(self.fb.vendor) do
      local n = self.qh:GetObjective("monster", npc)
      local faction = n.o.faction or n.fb.faction
      if (not faction or faction == self.qh.faction) and n:Known() then
        return true
      end
    end
  end
  
  if self.o.pos or self.fb.pos then
    return true
  end
  
  if self.o.drop then for monster in pairs(self.o.drop) do
    if self.qh:GetObjective("monster", monster):Known() then
      return true
    end
  end end
  
  if self.fb.drop then for monster in pairs(self.fb.drop) do
    if self.qh:GetObjective("monster", monster):Known() then
      return true
    end
  end end
  
  if self.o.contained then for item in pairs(self.o.contained) do
    if self.qh:GetObjective("item", item):Known() then
      return true
    end
  end end
  
  if self.fb.contained then for item in pairs(self.fb.contained) do
    if self.qh:GetObjective("item", item):Known() then
      return true
    end
  end end
  
  if self.quest then
    local item=self.quest.o.item
    item = item and item[self.obj]
    
    if item then 
      if item.pos then
        return true
      end
      if item.drop then
        for monster in pairs(item.drop) do
          if self.qh:GetObjective("monster", monster):Known() then
            return true
          end
        end
      end
    end
    
    item=self.quest.fb.item
    item = item and item[self.obj]
    if item then 
      if item.pos then
        return true
      end
      if item.drop then
        for monster in pairs(item.drop) do
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
  local high = 0
  
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    high = math.max(high, p[4])
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    high = math.max(high, p[4])
  end end
  
  high = weight/high
  
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    objective:AddLoc(p[1], p[2], p[3], p[4]*high, why)
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    objective:AddLoc(p[1], p[2], p[3], p[4]*high, why)
  end end
end


local function ObjectivePrepareRouting(self)
  self.setup_count = self.setup_count + 1
  if not self.setup then
    assert(not self.d)
    assert(not self.p)
    assert(not self.nm)
    assert(not self.nm2)
    assert(not self.nl)
    
    self.d = QuestHelper:CreateTable()
    self.p = QuestHelper:CreateTable()
    self.nm = QuestHelper:CreateTable()
    self.nm2 = QuestHelper:CreateTable()
    self.nl = QuestHelper:CreateTable()
    self.distance_cache = QuestHelper:CreateTable()
    
    self:AppendPositions(self, 1, nil)
    self:FinishAddLoc()
  end
end

local function ItemAppendPositions(self, objective, weight, why)
  why2 = why and why.."\n" or ""
  
  if self.o.vendor then for i, npc in ipairs(self.o.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    local faction = n.o.faction or n.fb.faction
    if (not faction or faction == self.qh.faction) then
      n:AppendPositions(objective, 1, why2..QHFormat("OBJECTIVE_PURCHASE", npc))
    end
  end end
  
  if self.fb.vendor then for i, npc in ipairs(self.fb.vendor) do
    local n = self.qh:GetObjective("monster", npc)
    local faction = n.o.faction or n.fb.faction
    if (not faction or faction == self.qh.faction) then
      n:AppendPositions(objective, 1, why2..QHFormat("OBJECTIVE_PURCHASE", npc))
    end
  end end
  
  if next(objective.p, nil) then
    -- If we have points from vendors, then always use vendors. I don't want it telling you to killing the
    -- towns people just because you had to talk to them anyway, and it saves walking to the store.
    return
  end
  
  if self.o.drop then for monster, count in pairs(self.o.drop) do
    local m = self.qh:GetObjective("monster", monster)
    m:AppendPositions(objective, m.o.looted and count/m.o.looted or 1, why2..QHFormat("OBJECTIVE_SLAY", monster))
  end end
  
  if self.fb.drop then for monster, count in pairs(self.fb.drop) do
    local m = self.qh:GetObjective("monster", monster)
    m:AppendPositions(objective, m.fb.looted and count/m.fb.looted or 1, why2..QHFormat("OBJECTIVE_SLAY", monster))
  end end
  
  if self.o.contained then for item, count in pairs(self.o.contained) do
    local i = self.qh:GetObjective("item", item)
    i:AppendPositions(objective, i.o.opened and count/i.o.opened or 1, why2..QHFormat("OBJECTIVE_LOOT", item))
  end end
  
  if self.fb.contained then for item, count in pairs(self.fb.contained) do
    local i = self.qh:GetObjective("item", item)
    i:AppendPositions(objective, i.fb.opened and count/i.fb.opened or 1, why2..QHFormat("OBJECTIVE_LOOT", item))
  end end
  
  if self.o.pos then for i, p in ipairs(self.o.pos) do
    objective:AddLoc(p[1], p[2], p[3], p[4], why)
  end end
  
  if self.fb.pos then for i, p in ipairs(self.fb.pos) do
    objective:AddLoc(p[1], p[2], p[3], p[4], why)
  end end
  
  if self.quest then
    local item_list=self.quest.o.item
    if item_list then
      local data = item_list[self.obj]
      if data and data.drop then
        for monster, count in pairs(data.drop) do
          local m = self.qh:GetObjective("monster", monster)
          m:AppendPositions(objective, m.o.looted and count/m.o.looted or 1, why2..QHFormat("OBJECTIVE_SLAY", monster))
        end
      elseif data and data.pos then
        for i, p in ipairs(data.pos) do
          objective:AddLoc(p[1], p[2], p[3], p[4], why)
        end
      end
    end
    
    item_list=self.quest.fb.item
    if item_list then 
      local data = item_list[self.obj]
      if data and data.drop then
        for monster, count in pairs(data.drop) do
          local m = self.qh:GetObjective("monster", monster)
          m:AppendPositions(objective, m.fb.looted and count/m.fb.looted or 1, why2..QHFormat("OBJECTIVE_SLAY", monster))
        end
      elseif data and data.pos then
        for i, p in ipairs(data.pos) do
          objective:AddLoc(p[1], p[2], p[3], p[4], why)
        end
      end
    end
  end
end












---------------













local function AddLoc(self, index, x, y, w, why)
  assert(not self.setup)
  
  if w > 0 then
    local pair = QuestHelper_ZoneLookup[index]
    local c, z = pair[1], pair[2]
    x, y = self.qh.Astrolabe:TranslateWorldMapPosition(c, z, x, y, c, 0)
    
    x = x * self.qh.continent_scales_x[c]
    y = y * self.qh.continent_scales_y[c]
    local list = self.qh.zone_nodes[index]
    
    local points = self.p[list]
    if not points then
      points = QuestHelper:CreateTable()
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
    
    local new = QuestHelper:CreateTable()
    new[1], new[2], new[3], new[4], new[5], new[6], new[7] = list, nil, x, y, w, why, w
    table.insert(points, new)
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
      if pl[i][5] < mx*0.2 then
        QuestHelper:ReleaseTable(pl[i])
        table.remove(pl, i)
      else
        remove_zone = false
        i = i + 1
      end
    end
    if remove_zone then
      QuestHelper:ReleaseTable(self.p[z])
      self.p[z] = nil
    end
  end
  
  local node_map = self.nm
  local node_list = self.nl
  
  for list, pl in pairs(self.p) do
    local dist = self.d[list]
    
    assert(not dist)
    
    if not dist then
      dist = QuestHelper:CreateTable()
      self.d[list] = dist
    end
    
    for i, point in ipairs(pl) do
      point[5] = mx/point[5] -- Will become 1 for the most desired location, and become larger and larger for less desireable locations.
      
      point[2] = QuestHelper:CreateTable()
      
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
          local pair = QuestHelper:CreateTable()
          pair[1], pair[2] = d, point[5]
          dist[i] = pair
          
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
  
  if #node_list == 0 then QuestHelper:Error(self.cat.."/"..self.obj..": zero nodes!") end
  
  assert(not self.setup)
  self.setup = true
  table.insert(self.qh.prepared_objectives, self)
end

local function GetPosition(self)
  assert(self.setup)
  
  return self.location
end

local function ComputeTravelTime(self, pos, nocache)
  assert(self.setup)
  
  local key
  if not nocache then
    if not pos.key then
      pos.key = math.random()..""
    end
    key = pos.key
    if self.distance_cache[key] then
      return unpack(self.distance_cache[key])
    end
  end

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
  if not nocache then
    local new = self.qh:CreateTable()
    new[1], new[2] = d, e
    self.distance_cache[key] = new
  end
  return d, e
end

local function ComputeTravelTime2(self, pos1, pos2, nocache)
  assert(self.setup)
  
  local key
  if not nocache then
    -- We don't want to cache distances involving the player's current position, as that would spam the table
    if not pos1.key then
      pos1.key = math.random()..""
    end
    if not pos2.key then
      pos2.key = math.random()..""
    end
    key = pos1.key..pos2.key
    if self.distance_cache[key] then
      return unpack(self.distance_cache[key])
    end
  end

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
  if not nocache then
    local new = self.qh:CreateTable()
    new[1], new[2], new[3] = d, d2, e
    self.distance_cache[key] = new
  end
  return d, d2, e
end

local function DoneRouting(self)
  assert(self.setup_count > 0)
  assert(self.setup)
  
  if self.setup_count == 1 then
    self.setup_count = 0
    QuestHelper:ReleaseObjectivePathingInfo(self)
    for i, obj in ipairs(self.qh.prepared_objectives) do
      if o == obj then
        table.remove(self.qh.prepared_objectives, i)
        break
      end
    end
  else
    self.setup_count = self.setup_count - 1
  end
end

local next_objective_id = 0

local function ObjectiveShare(self)
  self.want_share = true
end

local function ObjectiveUnshare(self)
  self.want_share = false
end

QuestHelper.default_objective_param =
 {
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
  
  Share=ObjectiveShare, -- Invoke to share this objective with your peers.
  Unshare=ObjectiveUnshare, -- Invoke to stop sharing this objective.
 }

QuestHelper.default_objective_item_param =
 {
  Known = ItemKnown,
  AppendPositions = ItemAppendPositions
 }

for key, value in pairs(QuestHelper.default_objective_param) do
  if not QuestHelper.default_objective_item_param[key] then
    QuestHelper.default_objective_item_param[key] = value
  end
end

QuestHelper.default_objective_meta = { __index = QuestHelper.default_objective_param }
QuestHelper.default_objective_item_meta = { __index = QuestHelper.default_objective_item_param }

function QuestHelper:NewObjectiveObject()
  next_objective_id = next_objective_id+1
  return
   setmetatable({
    qh=self,
    id=next_objective_id,
    
    want_share=false, -- True if we want this objective shared.
    is_sharing=false, -- Set to true if we've told other users about this objective.
    
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
    
    --[[ Will be created as needed.
    d=nil,
    p=nil,
    nm=nil, -- Maps nodes to their nearest zone/list/x/y position.
    nm2=nil, -- Maps nodes to their nears position, but dynamically set in TravelTime2.
    nl=nil, -- List of all the nodes we need to consider.
    location=nil, -- Will be set to the best position for the node.
    pos=nil, -- Zone node list, distance list, x, y, reason.
    sop=nil ]]
   }, QuestHelper.default_objective_meta)
end

function QuestHelper:GetObjective(category, objective)
  local objective_list = self.objective_objects[category]
  
  if not objective_list then
    objective_list = {}
    self.objective_objects[category] = objective_list
  end
  
  local objective_object = objective_list[objective]
  
  if not objective_object then
    if category == "quest" then
      local _, _, level, hash, name = string.find(objective, "^(%d+)/(%d*)/(.*)$")
      if not level then
        _, _, level, name = string.find(objective, "^(%d+)/(.*)$")
        if not level then
          name = objective
        end
      end
      
      if hash == "" then hash = nil end
      objective_object = self:GetQuest(name, tonumber(level), tonumber(hash))
      objective_list[objective] = objective_object
      return objective_object
    end
    
    objective_object = self:NewObjectiveObject()
    
    objective_object.cat = category
    objective_object.obj = objective
    
    if category == "item" then
      setmetatable(objective_object, QuestHelper.default_objective_item_meta)
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
      local i
      local _, _, c, z, x, y = string.find(objective,"^(%d+),(%d+),([%d%.]+),([%d%.]+)$")
      
      if not y then
        _, _, i, x, y = string.find(objective,"^(%d+),([%d%.]+),([%d%.]+)$")
      else
        i = QuestHelper_IndexLookup[c][z]
      end
      
      objective_object.o = {pos={{tonumber(i),tonumber(x),tonumber(y),1}}}
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

function QuestHelper:AppendObjectivePosition(objective, i, x, y, w)
  local pos = objective.o.pos
  if not pos then
    if objective.o.drop or objective.o.contained then
      return -- If it's dropped by a monster, don't record the position we got the item at.
    end
    objective.o.pos = self:AppendPosition({}, i, x, y, w)
  else
    self:AppendPosition(pos, i, x, y, w)
  end
end

function QuestHelper:AppendObjectiveDrop(objective, monster, count)
  local drop = objective.o.drop
  if drop then
    drop[monster] = (drop[monster] or 0)+(count or 1)
  else
    objective.o.drop = {[monster] = count or 1}
    objective.o.pos = nil -- If it's dropped by a monster, then forget the position we found it at.
  end
end

function QuestHelper:AppendItemObjectiveDrop(item_object, item_name, monster_name, count)
  local quest = self:ItemIsForQuest(item_object, item_name)
  if quest and not item_object.o.vendor and not item_object.o.drop and not item_object.o.pos then
    self:AppendQuestDrop(quest, item_name, monster_name, count)
  else
    if not item_object.o.drop and not item_object.o.pos then
      self:PurgeQuestItem(item_object, item_name)
    end
    self:AppendObjectiveDrop(item_object, monster_name, count)
  end
end

function QuestHelper:AppendItemObjectivePosition(item_object, item_name, i, x, y)
  local quest = self:ItemIsForQuest(item_object, item_name)
  if quest and not item_object.o.vendor and not item_object.o.drop and not item_object.o.pos then
    self:AppendQuestPosition(quest, item_name, i, x, y)
  else
    if not item_object.o.vendor and not item_object.o.drop and not item_object.o.contained and not item_object.o.pos then
      -- Just learned that this item doesn't depend on a quest to drop, remove any quest references to it.
      self:PurgeQuestItem(item_object, item_name)
    end
    self:AppendObjectivePosition(item_object, i, x, y)
  end
end

function QuestHelper:AppendItemObjectiveContainer(objective, container_name, count)
  local container = objective.o.contained
  if container then
    container[container_name] = (container[container_name] or 0)+(count or 1)
  else
    objective.o.contained = {[container_name] = count or 1}
    objective.o.pos = nil -- Forget the position.
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
  -- TODO: Needs sanity checking, especially now that dependencies can be assigned by remote users.
  
  
  -- We store the new relationships in objective.swap_[before|after],
  -- creating and copying them from objective.[before|after],
  -- the routing coroutine will check for those, swap them, and release the originals
  -- when it gets to a safe place to do so.
  
  if not (objective.swap_after or objective.after)[needs] then
    if objective.peer then
      for u, l in pairs(objective.peer) do
        -- Make sure other users know that the dependencies for this objective changed.
        objective.peer[u] = math.min(l, 1)
      end
    end
    
    if not objective.swap_after then
      objective.swap_after = self:CreateTable()
      for key,value in pairs(objective.after) do objective.swap_after[key] = value end
    end
    
    if not needs.swap_before then
      needs.swap_before = self:CreateTable()
      for key,value in pairs(needs.before) do needs.swap_before[key] = value end
    end
    
    objective.swap_after[needs] = true
    needs.swap_before[objective] = true
  end
end

function QuestHelper:AddObjectiveOptionsToMenu(obj, menu)
  local submenu = self:CreateMenu()
  
  for i = 1,5 do
    local name = QHText("PRIORITY"..i)
    local item = self:CreateMenuItem(submenu, name)
    local tex
    
    if obj.priority == i then
      tex = self:CreateIconTexture(item, 10)
    elseif obj.real_priority == i then
      tex = self:CreateIconTexture(item, 8)
    else
      tex = self:CreateIconTexture(item, 12)
      tex:SetVertexColor(1, 1, 1, 0)
    end
    
    item:AddTexture(tex, true)
    item:SetFunction(self.SetObjectivePriorityPrompt, self, obj, i)
  end
  
  self:CreateMenuItem(menu, QHText("PRIORITY")):SetSubmenu(submenu)
  
  if self.sharing then
    submenu = self:CreateMenu(QHText("SHARING"))
    local item = self:CreateMenuItem(submenu, QHText("ENABLE"))
    local tex = self:CreateIconTexture(item, 10)
    if not obj.want_share then tex:SetVertexColor(1, 1, 1, 0) end
    item:AddTexture(tex, true)
    item:SetFunction(obj.Share, obj)
    
    local item = self:CreateMenuItem(submenu, QHText("DISABLE"))
    local tex = self:CreateIconTexture(item, 10)
    if obj.want_share then tex:SetVertexColor(1, 1, 1, 0) end
    item:AddTexture(tex, true)
    item:SetFunction(obj.Unshare, obj)
    
    self:CreateMenuItem(menu, QHText("SHARING")):SetSubmenu(submenu)
  end
  
  self:CreateMenuItem(menu, QHText("IGNORE")):SetFunction(self.IgnoreObjective, self, obj)
end

function QuestHelper:IgnoreObjective(objective)
  if self.user_objectives[objective] then
    self:RemoveObjectiveWatch(objective, self.user_objectives[objective])
    self.user_objectives[objective] = nil
  else
    objective.user_ignore = true
  end
  
  --self:ForceRouteUpdate()
end

function QuestHelper:SetObjectivePriority(objective, level)
  level = math.min(5, math.max(1, math.floor((tonumber(level) or 3)+0.5)))
  if level ~= objective.priority then
    objective.priority = level
    if objective.peer then
      for u, l in pairs(objective.peer) do
        -- Peers don't know about this new priority.
        objective.peer[u] = math.min(l, 2)
      end
    end
    --self:ForceRouteUpdate()
  end
end

local function CalcObjectivePriority(obj)
  local priority = obj.priority
  
  for o in pairs(obj.before) do
    if o.watched then
      priority = math.min(priority, CalcObjectivePriority(o))
    end
  end
  
  return priority
end

local function ApplyBlockPriority(obj, level)
  for o in pairs(obj.before) do
    if o.watched then
      ApplyBlockPriority(o, level)
    end
  end
  
  if obj.priority < level then QuestHelper:SetObjectivePriority(obj, level) end
end

function QuestHelper:SetObjectivePriorityPrompt(objective, level)
  self:SetObjectivePriority(objective, level)
  if CalcObjectivePriority(objective) ~= level then
    local menu = self:CreateMenu()
    self:CreateMenuTitle(menu, QHText("IGNORED_PRIORITY_TITLE"))
    self:CreateMenuItem(menu, QHText("IGNORED_PRIORITY_FIX")):SetFunction(ApplyBlockPriority, objective, level)
    self:CreateMenuItem(menu, QHText("IGNORED_PRIORITY_IGNORE")):SetFunction(self.nop)
    menu:ShowAtCursor()
  end
end

function QuestHelper:SetObjectiveProgress(objective, user, have, need)
  if have and need then
    local list = objective.progress
    if not list then
      list = self:CreateTable()
      objective.progress = list
    end
    
    local user_progress = list[user]
    if not user_progress then
      user_progress = self:CreateTable()
      list[user] = user_progress
    end
    
    local pct = 0
    local a, b = tonumber(have), tonumber(need)
    if a and b then
      if b ~= 0 then
        pct = a/b
      elseif a == 0 then
        pct = 1
      end
    elseif a == b then
      pct = 1
    end
    
    user_progress[1], user_progress[2], user_progress[3] = have, need, pct
  else
    if objective.progress then
      if objective.progress[user] then
        self:ReleaseTable(objective.progress[user])
        objective.progress[user] = nil
        
        if not next(objective.progress, nil) then
          self:ReleaseTable(objective.progress)
          objective.progress = nil
        end
      end
    end
  end
end
