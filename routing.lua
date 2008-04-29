local call_count = 0

local map_rpf = 25
local normal_rpf = 10

local function yieldIfNeeded()
  -- Make sure we yield every so often.
  if QuestHelper_Pref.hide then
    -- When QuestHelper is hidden, the routing becomes a background task
    coroutine.yield()
  elseif call_count <= 0 then
    call_count = call_count + (QuestHelper.Astrolabe.WorldMapVisible and map_rpf or normal_rpf) * QuestHelper_Pref.perf_scale
    coroutine.yield()
  else
    call_count = call_count - 1
  end
end

local function CalcObjectivePriority(obj)
  local priority = obj.priority
  
  for o in pairs(obj.before) do
    if o.watched then
      priority = math.min(priority, CalcObjectivePriority(o))
    end
  end
  
  obj.real_priority = priority
  return priority
end

function CalcObjectiveIJ(route, obj)
  local i = 1
  
  for p, o in ipairs(route) do
    if obj.real_priority > o.real_priority or obj.after[o] then
      i = p+1
    elseif obj.real_priority < o.real_priority or obj.before[o] then
      return i, p
    end
  end
  
  return i, #route+1
end

function QuestHelper:RemoveIndexFromRoute(array, distance, extra, index)
  if #array == 1 then
    distance = 0
    extra = 0
    table.remove(array, 1)
  elseif index == 1 then
    distance = distance - array[1].len
    extra = self:ComputeTravelTime(self.pos, array[2].pos)
    table.remove(array, 1)
    yieldIfNeeded()
  elseif index == #array then
    distance = distance - array[index-1].len
    table.remove(array, index)
  else
    local a, b = array[index-1], table.remove(array, index)
    distance = distance - a.len - b.len
    a.len = self:ComputeTravelTime(a.pos, array[index].pos)
    distance = distance + a.len
    yieldIfNeeded()
  end
  
  return distance, extra
end

function QuestHelper:InsertObjectiveIntoRoute(array, distance, extra, objective)
  -- array     - Contains the path you want to insert into.
  -- distance  - How long is the path so far?
  -- extra     - How far is it from the player to the first node?
  -- objective - Where are we trying to get to?
  
  -- In addition, objective needs i and j set, for the min and max indexes it can be inserted into.
  
  -- Returns:
  -- index    - The index to inserted into.
  -- distance - The new length of the path.
  -- extra    - The new distance from the first node to the player.
  
  if #array == 0 then
    extra, objective.pos = objective:TravelTime(self.pos, --[[nocache=]]true)
    yieldIfNeeded()
    table.insert(array, 1, objective)
    return 1, 0, extra
  end
  
  local best_index, best_extra, best_total, best_len1, best_len2, bp
  
  local low, high = CalcObjectiveIJ(array, objective)
  
  if low == 1 then
    best_index = 1
    best_extra, best_len2, bp = objective:TravelTime2(self.pos, array[1].pos, --[[nocache=]]true)
    best_total = best_extra+distance+best_len2
  elseif low == #array+1 then
    local o = array[#array]
    o.len, objective.pos = objective:TravelTime(array[#array].pos)
    yieldIfNeeded()
    table.insert(array, objective)
    return #array, distance+o.len, extra
  else
    local a = array[low-1]
    best_index = low
    best_len1, best_len2, bp = objective:TravelTime2(a.pos, array[low].pos)
    best_extra = extra
    best_total = distance - a.len + best_len1 + best_len2 + extra
    yieldIfNeeded()
  end
  
  local total = distance+extra
  
  for i = low+1, math.min(#array, high) do
    local a = array[i-1]
    local l1, l2, p = objective:TravelTime2(a.pos, array[i].pos)
    local d = total - a.len + l1 + l2
    if d < best_total then
      bp = p
      best_len1 = l1
      best_len2 = l2
      best_extra = extra
      best_total = d
      best_index = i
    end
    yieldIfNeeded()
  end
  
  if high == #array+1 then
    local l1, p = objective:TravelTime(array[#array].pos)
    yieldIfNeeded()
    local d = total + l1
    if d < best_total then
      objective.pos = p
      array[#array].len = l1
      table.insert(array, objective)
      return #array, d-extra, extra
    end
  end
  
  assert(bp)
  objective.pos = bp
  if best_index > 1 then array[best_index-1].len = best_len1 end
  objective.len = best_len2
  table.insert(array, best_index, objective)
  return best_index, best_total-best_extra, best_extra
end


function QuestHelper:RemoveIndexFromRouteSOP(array, distance, extra, index)
  if #array == 1 then
    distance = 0
    extra = 0
    table.remove(array, 1)
  elseif index == 1 then
    distance = distance - array[1].nel
    extra = self:ComputeTravelTime(self.pos, array[2].sop)
    table.remove(array, 1)
    yieldIfNeeded()
  elseif index == #array then
    distance = distance - array[index-1].nel
    table.remove(array, index)
  else
    local a, b = array[index-1], table.remove(array, index)
    distance = distance - a.nel - b.nel
    a.nel = self:ComputeTravelTime(a.sop, array[index].sop)
    distance = distance + a.nel
    yieldIfNeeded()
  end
  
  return distance, extra
end

function QuestHelper:InsertObjectiveIntoRouteSOP(array, distance, extra, objective)
  -- array     - Contains the path you want to insert into.
  -- distance  - How long is the path so far?
  -- extra     - How far is it from the player to the first node?
  -- objective - Where are we trying to get to?
  
  -- In addition, objective needs i and j set, for the min and max indexes it can be inserted into.
  
  -- Returns:
  -- index    - The index to inserted into.
  -- distance - The new length of the path.
  -- extra    - The new distance from the first node to the player.
  
  if #array == 0 then
    extra, objective.sop = objective:TravelTime(self.pos, --[[nocache=]]true)
    yieldIfNeeded()
    table.insert(array, 1, objective)
    return 1, 0, extra
  end
  
  local best_index, best_extra, best_total, best_len1, best_len2, bp
  
  local low, high = CalcObjectiveIJ(array, objective)
  
  if low == 1 then
    best_index = 1
    best_extra, best_len2, bp = objective:TravelTime2(self.pos, array[1].sop, --[[nocache=]]true)
    best_total = best_extra+distance+best_len2
    yieldIfNeeded()
  elseif low == #array+1 then
    local o = array[#array]
    o.nel, objective.sop = objective:TravelTime(array[#array].sop)
    yieldIfNeeded()
    table.insert(array, objective)
    return #array, distance+o.nel, extra
  else
    local a = array[low-1]
    best_index = low
    best_len1, best_len2, bp = objective:TravelTime2(a.sop, array[low].sop)
    best_extra = extra
    best_total = distance - a.nel + best_len1 + best_len2 + extra
    yieldIfNeeded()
  end
  
  local total = distance+extra
  
  for i = low+1, math.min(#array, high) do
    local a = array[i-1]
    local l1, l2, p = objective:TravelTime2(a.sop, array[i].sop)
    local d = total - a.nel + l1 + l2
    if d < best_total then
      bp = p
      best_len1 = l1
      best_len2 = l2
      best_extra = extra
      best_total = d
      best_index = i
    end
    yieldIfNeeded()
  end
  
  if high == #array+1 then
    local l1, p = objective:TravelTime(array[#array].sop)
    yieldIfNeeded()
    local d = total + l1
    if d < best_total then
      objective.sop = p
      array[#array].nel = l1
      table.insert(array, objective)
      return #array, d-extra, extra
    end
  end
  
  assert(bp)
  objective.sop = bp
  if best_index > 1 then array[best_index-1].nel = best_len1 end
  objective.nel = best_len2
  table.insert(array, best_index, objective)
  return best_index, best_total-best_extra, best_extra
end

local route_pass = 0
local map_walker

local function RouteUpdateRoutine(self)
  map_walker = self:CreateWorldMapWalker()
  local minimap_dodad = self:CreateMipmapDodad()
  local swap_table = {}
  local distance, extra, route, new_distance, new_extra, new_route, shuffle, insert, point = 0, 0, self.route, 0, 0, {}, {}, 0, nil
  local recheck_pos, new_recheck_pos, new_local_minima = 1, 99999, true
  
  self.minimap_dodad = minimap_dodad
  
  while true do
    for i,o in ipairs(route) do
      o.filter_zone = o.location[1] ~= self.pos[1]
      
      if not o:Known() then
        -- Objective was probably made to depend on an objective that we don't know about yet.
        -- We add it to both lists, because although we need to remove it, we need it added again when we can.
        -- This creats an inconsistancy, but it'll get fixed in the removal loop before anything has a chance to
        -- explode from it.
        
        self.to_remove[o] = true
        self.to_add[o] = true
      else
        CalcObjectivePriority(o)
        
        if o.is_sharing ~= o.want_share then
          o.is_sharing = o.want_share
          
          if o.want_share then
            self:DoShareObjective(o)
          else
            self:DoUnshareObjective(o)
          end
        end
      end
    end
    
    local original_size = #route
    
    -- Remove any waypoints if needed.
    while true do
      local obj = next(self.to_remove)
      if not obj then break end
      self.to_remove[obj] = nil
      
      if obj.is_sharing then
        obj.is_sharing = false
        self:DoUnshareObjective(obj)
      end
      
      self:ReleaseTeleportInfo(obj.tele_pos)
      self:ReleaseTeleportInfo(obj.tele_sop)
      obj.tele_pos, obj.tele_sop = nil, nil
      
      for i, o in ipairs(route) do
        if o == obj then
          if i == 1 then
            if #route == 1 then
              minimap_dodad:SetObjective(nil)
            else
              minimap_dodad:SetObjective(route[2])
            end
          end
          
          if recheck_pos > i then recheck_pos = recheck_pos - 1 end
          
          distance, extra = self:RemoveIndexFromRoute(route, distance, extra, i)
          break
        end
      end
      
      for i, o in ipairs(new_route) do
        if o == obj then
          if new_recheck_pos > i then new_recheck_pos = new_recheck_pos - 1 end
          new_distance, new_extra = self:RemoveIndexFromRouteSOP(new_route, new_distance, new_extra, i)
          break
        end
      end
      
      obj:DoneRouting()
    end
    
    while true do
      local obj = next(self.to_add)
      if not obj then break end
      self.to_add[obj] = nil
      
      if obj:Known() then
        obj:PrepareRouting()
        
        obj.filter_zone = obj.location[1] ~= self.pos[1]
        
        if obj.filter_zone and QuestHelper_Pref.filter_zone then
          -- Not going to add it, wrong zone.
          obj:DoneRouting()
          swap_table[obj] = true
        else
          obj.tele_pos = self:CreateTeleportInfo()
          obj.tele_sop = self:CreateTeleportInfo()
          
          if not obj.is_sharing and obj.want_share then
            obj.is_sharing = true
            self:DoShareObjective(obj)
          end
          
          CalcObjectivePriority(obj)
          
          if #route == 0 then
            insert, distance, extra = self:InsertObjectiveIntoRoute(route, 0, 0, obj)
            insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, 0, 0, obj)
            
            minimap_dodad:SetObjective(obj)
          else
            insert, distance, extra = self:InsertObjectiveIntoRoute(route, distance, extra, obj)
            
            if insert == 1 then
              minimap_dodad:SetObjective(obj)
            end
            
            insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, new_distance, new_extra, obj)
          end
        end
      else
        swap_table[obj] = true
      end
    end
    
    for obj in pairs(swap_table) do
      -- If one of the objectives we were considering adding was removed, it would be in both lists.
      -- That would be bad. We can't remove it because we haven't actually added it yet, so
      -- handle that special case here.
      if self.to_remove[obj] then
        self.to_remove[obj] = nil
        self.to_add[obj] = nil
      end
    end
    
    self.to_add, swap_table = swap_table, self.to_add
    
    -- If size decreased, all the old indexes need to be reset.
    if #route < original_size then
      for i=1,#route do
        shuffle[i] = i
      end
    end
    
    -- Append new indexes to shuffle.
    for i=original_size+1,#route do
      shuffle[i] = i
    end
    
    if #route > 0 then
      if recheck_pos > #route then recheck_pos = 1 end
      if new_recheck_pos > #route then
        new_recheck_pos = 1
        if new_local_minima then
          -- Start try something new, we can't seem to get what we have to be any better.
          
          for i=1,#route-1 do -- Shuffling the order we'll add the nodes in.
            local r = math.random(i, #route)
            if r ~= i then
              shuffle[i], shuffle[r] = shuffle[r], shuffle[i]
            end
          end
          
          for i = #new_route, 1, -1 do new_route[i] = nil end
          
          point = route[shuffle[1]]
          insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, 0, 0, point)
          
          -- Insert the rest of the points.
          for i=2,#route do
            point = route[shuffle[i]]
            
            insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, new_distance, new_extra, point)
          end
        end
        new_local_minima = true
      end
      
      point = route[recheck_pos]
      self.limbo_node = point
      distance, extra = self:RemoveIndexFromRoute(route, distance, extra, recheck_pos)
      insert, distance, extra = self:InsertObjectiveIntoRoute(route, distance, extra, point)
      self.limbo_node = nil
      
      if insert == 1 or recheck_pos == 1 then
        minimap_dodad:SetObjective(route[1])
      end
      
      point = new_route[new_recheck_pos]
      new_distance, new_extra = self:RemoveIndexFromRouteSOP(new_route, new_distance, new_extra, new_recheck_pos)
      insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, new_distance, new_extra, point)
      if insert ~= new_recheck_pos then
        new_local_minima = false
      end
      
      recheck_pos = recheck_pos + 1
      new_recheck_pos = new_recheck_pos + 1
    end
    
    if new_distance+new_extra+0.001 < distance+extra then
      for i, node in ipairs(route) do
        node.len = node.nel
        node.tele_pos, node.tele_sop = node.tele_sop, node.tele_pos
        node.pos, node.sop = node.sop, node.pos
      end
      
      route, new_route = new_route, route
      distance, new_distance = new_distance, distance
      extra, new_extra = new_extra, extra
      
      self.route = route
      
      minimap_dodad:SetObjective(route[1])
      
      for i=1,#route-1 do -- Shuffling the order we'll add the nodes in.
        local r = math.random(i, #route)
        if r ~= i then
          shuffle[i], shuffle[r] = shuffle[r], shuffle[i]
        end
      end
      
      for i = #new_route, 1, -1 do new_route[i] = nil end
      
      point = route[shuffle[1]]
      insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, 0, 0, point)
      
      -- Insert the rest of the points.
      for i=2,#route do
        point = route[shuffle[i]]
        insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, new_distance, new_extra, point)
      end
      
      recheck_pos = new_recheck_pos
      new_recheck_pos = 1
      new_local_minima = true
    end
    
    -- Thats enough work for now, we'll continue next frame.
    if route_pass > 0 then
      route_pass = route_pass - 1
    end
    
    map_walker:RouteChanged()
    
    call_count = 0
    
    self:SetupTeleportInfo(self.teleport_info)
    
    if self.defered_graph_reset then
      self:ResetPathing()
      self.defered_graph_reset = false
    end
    
    coroutine.yield()
  end
end

function QuestHelper:ForceRouteUpdate(passes)
  route_pass = math.max(2, passes or 0)
  
  while route_pass ~= 0 do
    if coroutine.status(self.update_route) == "dead" then
      break
    end
    
    local state, err = coroutine.resume(self.update_route, self)
    if not state then
      self:TextOut("|cffff0000The routing co-routine just exploded|r: |cffffff77"..err.."|r")
      break
    end
  end
end

QuestHelper.update_route = coroutine.create(RouteUpdateRoutine)
