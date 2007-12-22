local call_count = 0

local map_rpf = 50
local normal_rpf = 20

local function yieldIfNeeded()
  if call_count == QuestHelper.Astrolabe.WorldMapVisible and map_rpf or normal_rpf then
    call_count = 0
    coroutine.yield()
  else
    call_count = call_count + 1
  end
end

function QuestHelper:DumpRoute(route, distance)
  local real_distance = 0
  for i, n in ipairs(route) do
    if i == #route then
      self:TextOut(i..": "..n:Reason())
      self:TextOut(i..": "..self:LocationString(unpack(n.pos)).."\tTotal: "..string.format("%.1f seconds.",real_distance))
    else
      real_distance = real_distance + (n.len or 0)
      self:TextOut(i..": "..n:Reason())
      self:TextOut(i..": "..self:LocationString(unpack(n.pos)).."\tNext: "..string.format("%.1f seconds.", n.len))
    end
  end
  if math.abs(distance,real_distance) > 0.00001 then
    self:TextOut("Distance error: "..string.format("%.2f%%",(real_distance-distance)*100))
  end
end

function QuestHelper:CalcObjectiveIJ(route, obj)
  obj.i, obj.j = 1, #route+1
  
  for i, o in ipairs(route) do
    if obj.after[o] then
      obj.i = i+1
    elseif obj.before[o] then
      obj.j = i
    end
  end
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
    table.insert(array, 1, objective)
    extra, objective.pos = objective:TravelTime(self.pos)
    yieldIfNeeded()
    return 1, 0, extra
  end
  
  local best_index, best_extra, best_total, best_len1, best_len2, bp
  
  if objective.i == 1 then
    best_index = 1
    best_extra, best_len2, bp = objective:TravelTime2(self.pos, array[1].pos)
    best_total = best_extra+distance+best_len2
  elseif objective.i == #array+1 then
    local o = array[#array]
    o.len, objective.pos = objective:TravelTime(array[#array].pos)
    table.insert(array, objective)
    yieldIfNeeded()
    return #array, distance+o.len, extra
  else
    local a = array[objective.i-1]
    best_index = objective.i
    best_len1, best_len2, bp = objective:TravelTime2(a.pos, array[objective.i].pos)
    best_extra = extra
    best_total = distance - a.len + best_len1 + best_len2 + extra
    yieldIfNeeded()
  end
  
  local total = distance+extra
  
  for i = objective.i+1, math.min(#array, objective.j) do
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
  
  if objective.j == #array+1 then
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
    table.insert(array, 1, objective)
    extra, objective.sop = objective:TravelTime(self.pos)
    yieldIfNeeded()
    return 1, 0, extra
  end
  
  local best_index, best_extra, best_total, best_len1, best_len2, bp
  
  if objective.i == 1 then
    best_index = 1
    best_extra, best_len2, bp = objective:TravelTime2(self.pos, array[1].sop)
    best_total = best_extra+distance+best_len2
    yieldIfNeeded()
  elseif objective.i == #array+1 then
    local o = array[#array]
    o.nel, objective.sop = objective:TravelTime(array[#array].sop)
    table.insert(array, objective)
    yieldIfNeeded()
    return #array, distance+o.nel, extra
  else
    local a = array[objective.i-1]
    best_index = objective.i
    best_len1, best_len2, bp = objective:TravelTime2(a.sop, array[objective.i].sop)
    best_extra = extra
    best_total = distance - a.nel + best_len1 + best_len2 + extra
    yieldIfNeeded()
  end
  
  local total = distance+extra
  
  for i = objective.i+1, math.min(#array, objective.j) do
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
  
  if objective.j == #array+1 then
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
  
  while true do
    for i,o in ipairs(route) do
      if not o:Known() then
        -- Objective was probably made to depend on an objective that we don't know about yet.
        -- We add it to both lists, because although we need to remove it, we need it added again when we can.
        -- This creats an inconsistancy, but it'll get fixed in the removal loop before anything has a chance to
        -- explode from it.
        
        self.to_remove[o] = true
        self.to_add[o] = true
      end
    end
    
    local original_size = #route
    
    -- Remove any waypoints if needed.
    while true do
      local obj = next(self.to_remove)
      if not obj then break end
      self.to_remove[obj] = nil
      
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
        
        if #route == 0 then
          insert, distance, extra = self:InsertObjectiveIntoRoute(route, 0, 0, obj)
          insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, 0, 0, obj)
          
          minimap_dodad:SetObjective(obj)
        else
          self:CalcObjectiveIJ(route, obj)
          
          insert, distance, extra = self:InsertObjectiveIntoRoute(route, distance, extra, obj)
          
          if insert == 1 then
            minimap_dodad:SetObjective(obj)
          end
          
          insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, new_distance, new_extra, obj)
        end
      else
        swap_table[obj] = true
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
          
          while #new_route > 0 do
            table.remove(new_route)
          end
          
          point = route[shuffle[1]]
          insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, 0, 0, point)
          
          -- Set up the i/j values for all the other points, based on the first point.
          for i=2,#route do
            local p = route[shuffle[i]]
            if p.before[point] then p.i, p.j = 1, 1
            elseif p.after[point] then p.i, p.j = 2, 2
            else p.i, p.j = 1, 2
            end
          end
          
          -- Insert the rest of the points.
          for i=2,#route do
            point = route[shuffle[i]]
            insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, new_distance, new_extra, point)
            
            for j=i+1,#route do
              local p = route[shuffle[j] ]
              if p.before[point] then p.j = insert
              elseif p.after[point] then p.i, p.j = insert+1, p.j + 1
              elseif p.j > insert then
                p.j = p.j + 1
                if p.i > insert then p.i = p.i + 1 end
              end
            end
          end
        end
        new_local_minima = true
      end
      
      point = route[recheck_pos]
      self.limbo_node = point
      distance, extra = self:RemoveIndexFromRoute(route, distance, extra, recheck_pos)
      self:CalcObjectiveIJ(route, point)
      insert, distance, extra = self:InsertObjectiveIntoRoute(route, distance, extra, point)
      self.limbo_node = nil
      
      if insert == 1 or recheck_pos == 1 then
        minimap_dodad:SetObjective(route[1])
      end
      
      point = new_route[new_recheck_pos]
      local old_distance = new_distance
      new_distance, new_extra = self:RemoveIndexFromRouteSOP(new_route, new_distance, new_extra, new_recheck_pos)
      self:CalcObjectiveIJ(new_route, point)
      insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, new_distance, new_extra, point)
      if new_distance + 0.001 < old_distance then
        new_local_minima = false
      end
      
      recheck_pos = recheck_pos + 1
      new_recheck_pos = new_recheck_pos + 1
    end
    
    if new_distance+new_extra+0.001 < distance+extra then
      for i, node in ipairs(route) do
        node.len = node.nel
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
      
      while #new_route > 0 do
        table.remove(new_route)
      end
      
      point = route[shuffle[1]]
      insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, 0, 0, point)
      
      -- Set up the i/j values for all the other points, based on the first point.
      for i=2,#route do
        local p = route[shuffle[i]]
        if p.before[point] then p.i, p.j = 1, 1
        elseif p.after[point] then p.i, p.j = 2, 2
        else p.i, p.j = 1, 2
        end
      end
      
      -- Insert the rest of the points.
      for i=2,#route do
        point = route[shuffle[i]]
        insert, new_distance, new_extra = self:InsertObjectiveIntoRouteSOP(new_route, new_distance, new_extra, point)
        
        for j=i+1,#route do
          local p = route[shuffle[j] ]
          if p.before[point] then p.j = insert
          elseif p.after[point] then p.i, p.j = insert+1, p.j + 1
          elseif p.j > insert then
            p.j = p.j + 1
            if p.i > insert then p.i = p.i + 1 end
          end
        end
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
