function QuestHelper:BestInsertPosition(array, distance, extra, objective)
  -- array     - Contains the path you want to insert to.
  -- distance  - How long is the path so far?
  -- extra     - How far is it from the player to the first node?
  -- objective - Where are we trying to get to?
  
  -- In addition, objective needs i and j set, for the min and max indexes it can be inserted into.
  
  -- Returns:
  -- index    - The index to insert to
  -- distance - The new length of the path.
  -- extra    - The new distance from the first node to the player?
  -- c,z,x,y  - The location chosen to go to.
  
  if #array == 0 then
    return 1, 0, objective:Distance(self.c, self.z, self.x, self.y)
  end
  
  local best_index, best_extra, bc, bz, bx, by
  
  if objective.i == 1 then
    best_index = 1
    best_extra, bc, bz, bx, by = objective:Distance(self.c, self.z, self.x, self.y)
    best_distance = self:Distance(bc, bz, bx, by, unpack(array[1].pos))+distance
    best_total = best_extra+best_distance
  elseif objective.i == #array+1 then
    best_distance, bc, bz, bx, by = objective:Distance(unpack(array[#array].pos))
    best_distance = best_distance + distance
    return #array+1, best_distance, extra, bc, bz, bx, by
  else
    local a, b = array[objective.i-1].pos, array[objective.i].pos
    best_index = objective.i
    best_extra = extra
    best_distance, bc, bz, bx, by = objective:Distance2(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    best_distance = distance + best_distance - self:Distance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    best_total = best_extra+best_distance
  end
  
  local total = distance+extra
  
  for i = objective.i+1, math.min(#array, objective.j) do
    local a, b = array[i-1].pos, array[i].pos
    local d, c, z, x, y = objective:Distance2(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    d = total + d - self:Distance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    if d < best_distance then
      bc, bz, bx, by = c, z, x, y
      best_distance = d - extra
      best_extra = extra
      best_index = i
    end
  end
  
  if objective.j == #array+1 then
    local d, c, z, x, y = objective:Distance(unpack(array[#array].pos))
    d = total + d
    if d < best_distance then
      return #array+1, d-extra, extra, c, z, x, y
    end
  end
  
  return best_index, best_distance, best_extra, bc, bz, bx, by
end

function QuestHelper:BestInsertPositionSOP(array, distance, extra, objective)
  -- array     - Contains the path you want to insert to.
  -- distance  - How long is the path so far?
  -- extra     - How far is it from the player to the first node?
  -- objective - Where are we trying to get to?
  
  -- In addition, objective needs i and j set, for the min and max indexes it can be inserted into.
  
  -- Returns:
  -- index    - The index to insert to
  -- distance - The new length of the path.
  -- extra    - The new distance from the first node to the player?
  -- c,z,x,y  - The location chosen to go to.
  
  if #array == 0 then
    return 1, 0, objective:Distance(self.c, self.z, self.x, self.y)
  end
  
  local best_index, best_extra, bc, bz, bx, by
  
  if objective.i == 1 then
    best_index = 1
    best_extra, bc, bz, bx, by = objective:Distance(self.c, self.z, self.x, self.y)
    best_distance = self:Distance(bc, bz, bx, by, unpack(array[1].sop))+distance
    best_total = best_extra+best_distance
  elseif objective.i == #array+1 then
    best_distance, bc, bz, bx, by = objective:Distance(unpack(array[#array].sop))
    best_distance = best_distance + distance
    return #array+1, best_distance, extra, bc, bz, bx, by
  else
    local a, b = array[objective.i-1].sop, array[objective.i].sop
    best_index = objective.i
    best_extra = extra
    best_distance, bc, bz, bx, by = objective:Distance2(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    best_distance = distance + best_distance - self:Distance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    best_total = best_extra+best_distance
  end
  
  local total = distance+extra
  
  for i = objective.i+1, math.min(#array, objective.j) do
    local a, b = array[i-1].sop, array[i].sop
    local d, c, z, x, y = objective:Distance2(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    d = total + d - self:Distance(a[1], a[2], a[3], a[4], b[1], b[2], b[3], b[4])
    if d < best_distance then
      bc, bz, bx, by = c, z, x, y
      best_distance = d - extra
      best_extra = extra
      best_index = i
    end
  end
  
  if objective.j == #array+1 then
    local d, c, z, x, y = objective:Distance(unpack(array[#array].sop))
    d = total + d
    if d < best_distance then
      return #array+1, d-extra, extra, c, z, x, y
    end
  end
  
  return best_index, best_distance, best_extra, bc, bz, bx, by
end

local function RouteUpdateRoutine(self)
  local minimap_dodad = self:CreateMipmapDodad()
  local waypoint_icons = {}
  local distance, extra, route, new_route, shuffle, insert, point = 0, 0, self.route, {}, {}, 0, nil
  
  while true do
    self:PlayerPosition()
    
    for i,o in ipairs(route) do
      if not o:Known() then
        -- Objective was probably made to depend on an objective that we don't know about yet.
        -- We add it to both lists, because although we need to remove it, we need it added again when we can.
        -- This creats an inconsistancy, but it'll get fixed in the removal loop before anything has a chance to
        -- explode from it.
        
        -- TODO: I also need to check to make sure the node is still before or after the nodes its
        -- supposed to be before or after.
        
        self.to_remove[o] = true
        self.to_add[o] = true
      end
    end
    
    local original_size = #route
    
    -- Remove any waypoints if needed.
    for obj, _ in pairs(self.to_remove) do
      self.to_remove[obj] = nil
      for i, o in ipairs(route) do
        if o == obj then
          if i == 1 then
            if #route == 1 then
              minimap_dodad:Hide()
            else
              minimap_dodad:SetObjective(route[2])
            end
          end
          table.remove(route, i)
          break
        end
      end
    end
    
    -- Add any waypoints if needed.
    for obj, _ in pairs(self.to_add) do
      if obj:Known() then
        self.to_add[obj] = nil
        
        if #route == 0 then
          extra, obj.pos[1], obj.pos[2], obj.pos[3], obj.pos[4] =
            obj:Distance(self.c, self.z, self.x, self.y)
          
          table.insert(route, obj)
          minimap_dodad:Show()
          minimap_dodad:SetObjective(obj)
        else
          obj.i, obj.j = 1, #route+1
          
          for i, o in ipairs(route) do
            if obj.after[o] then
              obj.i = i+1
            elseif obj.before[o] then
              obj.j = i
            end
          end
          
          insert, distance, extra, obj.pos[1], obj.pos[2], obj.pos[3], obj.pos[4]
           = self:BestInsertPosition(route, distance, extra, obj)
          
          table.insert(route, insert, obj)
          
          if insert == 1 then
            minimap_dodad:SetObjective(obj)
          end
        end
      end
    end
    
    -- If the size changed, update the table we use for shuffling.
    if #route < original_size then
      for i=1,#route do
        shuffle[i] = i
      end
    else
      for i=original_size+1,#route do
        shuffle[i] = i
      end
    end
    
    -- Thats enough work for now, we'll continue next frame.
    coroutine.yield()
    
    if #route > 0 then
      -- Move the points around in the existing path if needed. This will hopefully optimize the path somewhat, and
      -- reposition objectives if we learn that we can't do something the way we thought we could.
      
      -- TODO: Cache distances.
      
      if #route == 1 then
        local o = route[1]
        extra, o.pos[1], o.pos[2], o.pos[3], o.pos[4] = o:Distance(self.c, self.z, self.x, self.y)
        minimap_dodad:SetObjective(o)
        local icon = waypoint_icons[1]
        if not icon then
          icon = self:CreateWorldMapDodad(o, 1)
          waypoint_icons[1] = icon
        else
          icon:SetObjective(o, 1)
        end
        for i = 2,#waypoint_icons do
          waypoint_icons[i]:Hide()
        end
      else
        local d
        for i, o in ipairs(route) do
          if i == 1 then
            local old_d = self:Distance(o.pos[1], o.pos[2], o.pos[3], o.pos[4], unpack(route[2].pos))
            d, o.pos[1], o.pos[2], o.pos[3], o.pos[4] = o:Distance2(self.c, self.z, self.x, self.y, unpack(route[2].pos))
            local new_d = self:Distance(o.pos[1], o.pos[2], o.pos[3], o.pos[4], unpack(route[2].pos))
            distance = distance - old_d + new_d
            extra = d - new_d
            minimap_dodad:SetObjective(o)
          elseif i == #route then
            local old_d = self:Distance(o.pos[1], o.pos[2], o.pos[3], o.pos[4], unpack(route[#route-1].pos))
            d, o.pos[1], o.pos[2], o.pos[3], o.pos[4] = o:Distance(unpack(route[#route-1].pos))
            distance = distance - old_d + d
          else
            local a, b = route[i-1], route[i+1]
            old_d = self:Distance(a.pos[1], a.pos[2], a.pos[3], a.pos[4], unpack(o.pos))+
                    self:Distance(o.pos[1], o.pos[2], o.pos[3], o.pos[4], unpack(b.pos))
            d, o.pos[1], o.pos[2], o.pos[3], o.pos[4] = o:Distance2(a.pos[1], a.pos[2], a.pos[3], a.pos[4], unpack(b.pos))
            distance = distance - old_d + d
          end
          
          local icon = waypoint_icons[i]
          if not icon then
            icon = self:CreateWorldMapDodad(o, i)
            waypoint_icons[i] = icon
          else
            icon:SetObjective(o, i)
          end
        end
        for i = #route+1,#waypoint_icons do
          waypoint_icons[i]:Hide()
        end
      end
      
      coroutine.yield()
      
      local new_distance, new_extra = 0, 0
      extra = self:Distance(self.c, self.z, self.x, self.y, unpack(route[1].pos))
      
      for i=1,#route-1 do
        local r = math.random(i, #route)
        if r ~= i then
          local t = shuffle[i]
          shuffle[i] = shuffle[r]
          shuffle[r] = t
        end
      end
      
      point = route[shuffle[1]]
      new_distance = 0
      new_extra, point.sop[1], point.sop[2], point.sop[3], point.sop[4] = point:Distance(self.c, self.z, self.x, self.y)
      
      table.insert(new_route, point)
      
      for j=2,#route do
        local p = route[shuffle[j]]
        
        if p.before[point] then
          p.i = 1
          p.j = 1
        elseif p.after[point] then
          p.i = 2
          p.j = 2
        else
          p.i = 1
          p.j = 2
        end
      end
      
      for i=2,#route do
        point = route[shuffle[i]]
        
        insert, new_distance, new_extra, point.sop[1], point.sop[2], point.sop[3], point.sop[4]
          = self:BestInsertPositionSOP(new_route, new_distance, new_extra, point)
        
        for j=i+1,#route do
          local p = route[shuffle[j]]
          if p.before[point] then
            p.j = insert
          elseif p.after[point] then
            p.i = insert+1
            p.j = p.j + 1
          elseif p.j > insert then
            p.j = p.j + 1
            if p.i > insert then p.i = p.i + 1 end
          end
        end
        
        table.insert(new_route, insert, point)
        coroutine.yield()
      end
      
      if new_distance+new_extra+0.01 < distance+extra then
        for i, node in ipairs(new_route) do
          table.remove(route)
          local t = node.pos
          node.pos = node.sop
          node.sop = t
        end
        
        self.route = new_route
        new_route = route
        route = self.route
        distance = new_distance
        extra = new_extra
      else
        for i = 1,#route do table.remove(new_route) end
      end
    end
  end
end

QuestHelper.update_route = coroutine.create(RouteUpdateRoutine)
