QuestHelper_File["routing.lua"] = "Development Version"

local work_done = 0
local route_pass = 0
local coroutine_running = false

function QuestHelper:yieldIfNeeded(work)
  if coroutine_running then
    -- Under normal circemstances, this will need to be called an average of 10 times
    -- for every unit of work done.
    
    -- I consider a call to TravelTime2 to be worth one unit of work.
    -- I consider TravelTime to be worth .5 units.
    -- I consider ComputeTravelTime to be worth .3 units of work.
    
    -- That's just as a rough guide, they depend greatly on where the positions are,
    -- and I'm happy enough to just fudge it.
    
    work_done = work_done + work
                  / QuestHelper_Pref.perf_scale -- Scale work done by global preference.
                  * (QuestHelper_Pref.hide and 5 or 1) -- If hidden, work is overvalued.
                  * ((route_pass > 0) and 0.02 or .1) -- average 50 calls per work unit if forced, 10 calls per unit otherwise.
    
    -- If lots of work is done, we will yeild multiple times in succession
    -- to maintain the average.
    while work_done >= 1 do
      work_done = work_done - 1
      coroutine.yield()
    end
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

local Route = {}
Route.__index = Route

--[[function Route:sanity()
  local len = #self
  local distance = 0
  
  for i = 1,len-1 do
    distance = distance + self[i].len
  end
  
  assert(math.abs(self.distance-distance) < 0.000000001, "Distance error: "..(self.distance-distance))
  
  for i = 1,len do
    assert(self.index[self[i].obj] == i, i.."/"..#self..": Bad index")
    assert(self[i].pos == self[i].obj.position, i.."/"..#self..": Bad location")
  end
  
  for obj, i in pairs(self.index) do
    assert(self[i].obj == obj, "Extra index.")
  end
  
  for i = 1,len-1 do
    assert(math.abs(self[i].len - QuestHelper:ComputeTravelTime(self[i].pos, self[i+1].pos)) < 0.000001, i.."/"..#self..": Bad length")
  end
end--]]

function Route:findObjectiveRange(obj)
  local i = 1
  
  for p, info in ipairs(self) do
    local o = info.obj
    if obj.real_priority > o.real_priority or obj.after[o] then
      i = p+1
    elseif obj.real_priority < o.real_priority or obj.before[o] then
      return i, p
    end
  end
  
  return i, #self+1
end

function Route:addObjective(obj)
  --self:sanity()
  
  local indexes = self.index
  local len = #self
  local info = QuestHelper:CreateTable()
  assert(not indexes[obj])
  
  info.obj = obj
  
  if len == 0 then
    self[1] = info
    indexes[obj] = 1
    info.pos = obj.location
    return 1
  end
  
  local player_pos = QuestHelper.pos
  local pos = obj.location
  local c, x, y = pos[1].c, pos[3], pos[4]
  
  local mn, mx = self:findObjectiveRange(obj)
  local index, distsqr
  
  for i = mn, math.min(mx, len) do
    local p = self[i].pos
    if c == p[1].c then
      local u, v = p[3]-x, p[4]-y
      local d2 = u*u+v*v
      if not index or d2 < distsqr then
        index, distsqr = i, d2
      end
    end
  end
  
  if not index then
    -- No nodes with the same continent already.
    -- If the same continent as the player, add to start of list, otherwise add to end of the list.
    index = c == player_pos[1].c and mn or mx
  end
  
  -- The next question, do I insert at that point, or do I insert after it?
  if index ~= mx and index <= len then
    local p1 = self[index].pos
    
    if p1[1].c == c then
      local p0
      
      if index == 1 then
        p0 = player_pos
      else
        p0 = self[index-1].pos
      end
      
      local oldstart, newstart
      
      if p0[1].c == c then
        local u, v = p0[3]-x, p0[4]-y
        newstart = math.sqrt(u*u+v*v)
        u, v = p0[3]-p1[3], p0[4]-p1[4]
        oldstart = math.sqrt(u*u+v*v)
      else
        newstart = 0
        oldstart = 0
      end
      
      local p2
      if index ~= len then
        p2 = self[index+1].pos
      end
      
      local oldend, newend
      if p2 and p2[1].c == c then
        local u, v = p2[3]-x, p2[4]-y
        newend = math.sqrt(u*u+v*v)
        u, v = p2[3]-p1[3], p2[4]-p1[4]
        oldend = math.sqrt(u*u+v*v)
      else
        newend = 0
        oldend = 0
      end
      
      if oldstart+newend < newstart+oldend then
        index = index + 1
      end
      
    end
  end
  
  QuestHelper:yieldIfNeeded((mn-mx+3)*0.05) -- The above checks don't require much effort.
  
  if index > len then
    local pos = obj.location
    info.pos = pos
    local previnfo = self[index-1]
    assert(previnfo)
    local d
    d, previnfo.pos = previnfo.obj:TravelTime(pos)
    previnfo.len = d
    self.distance = self.distance + d
    QuestHelper:yieldIfNeeded(0.5)
  else
    local d1, d2
    
    if index == 1 then
      d1, d2, info.pos = obj:TravelTime2(QuestHelper.pos, self[index].pos)
      info.len = d2
      self.distance = self.distance + d2
    else
      local previnfo = self[index-1]
      d1, d2, info.pos = obj:TravelTime2(previnfo.pos, self[index].pos)
      info.len = d2
      self.distance = self.distance + (d1 - previnfo.len + d2)
      previnfo.len = d1
    end
    
    QuestHelper:yieldIfNeeded(1)
  end
  
  -- Finally, insert the objective.
  table.insert(self, index, info)
  indexes[obj] = index
  
  -- Fix indexes of shifted elements.
  for i = index+1,#self do
    local obj = self[i].obj
    assert(indexes[obj] == i-1)
    indexes[obj] = i
  end
  
  --self:sanity()
  
  return index
end

function Route:removeObjective(obj)
  --self:sanity()
  
  local indexes = self.index
  local index = indexes[obj]
  
  assert(index)
  local info = self[index]
  assert(info.obj == obj)
  
  if index == #self then
    if index ~= 1 then
      self.distance = self.distance - self[index-1].len
      self[index-1].len = nil
    else
    end
  elseif index == 1 then
    self.distance = self.distance - info.len
  else
    local info1 = self[index-1]
    local d
    d, info1.pos = info1.obj:TravelTime(self[index+1].pos, true)
    self.distance = self.distance + (d - info1.len - info.len)
    info1.len = d
    QuestHelper:yieldIfNeeded(.5)
  end
  
  QuestHelper:ReleaseTable(info)
  indexes[obj] = nil
  table.remove(self, index)
  
  if index ~= 1 then
    local info1 = self[index-1]
    
    if index <= #self then
      local len
    else
    end
  end
  
  for i = index,#self do
    -- Fix indexes of shifted elements.
    local obj = self[i].obj
    indexes[obj] = indexes[obj]-1
  end
  
  --self:sanity()
  
  return index
end

local seen = {}
function Route:breed(route_map)
  local indexes = self.index
  
  local p1, p2 = nil
  local f1, f2 = nil
  
  for r in pairs(route_map) do
    local f = r.fitness*math.random()
    if not p1 then
      p1, f1 = r, f
    elseif not p2 then
      if f > f1 then
        p2, f2 = r, f
      else
        p1, f1, p2, f2 = r, f, p1, f1
      end
    elseif f > f2 then
      p1, f1, p2, f2 = p2, f2, r, f
    elseif f > f1 then
      p1, f1 = r, f
    end
  end
  
  if math.random() > 0.5 then
    p1, p2 = p2, p1
  end
  
  local len = #self
  assert(len > 1)
  
  local i = math.random(1,len)
  local j = i+math.floor((len-2)*(math.random()*.5+.4))
  
  if j > len then j = j - len end
  
  local input = i+math.floor(0.5+math.random()^2*len-math.random()^2*len)
  
  if input < 1 then
    input = input + len
  elseif input > len then
    input = input - len
  end
  
  if i > j then
    -- Keeping edges.
    for p = i,len do
      local info = p1[p]
      local obj = info.obj
      assert(not seen[obj])
      
      seen[obj] = info.pos
      indexes[obj] = p
    end
    
    for p = 1,j do
      local info = p1[p]
      local obj = info.obj
      assert(not seen[obj])
      
      seen[obj] = info.pos
      indexes[obj] = p
    end
    
    for p = j+1,i-1 do
      if input > len then input = 1 end
      local info = p2[input]
      local obj = info.obj
      
      while seen[obj] do
        input = input + 1
        if input > len then input = 1 end
        info = p2[input]
        obj = info.obj
      end
      
      seen[obj] = info.pos
      indexes[obj] = p
      input = input + 1
    end
  else
    -- Keeping center
    for p = i,j do
      local info = p1[p]
      local obj = info.obj
      seen[obj] = info.pos
      indexes[obj] = p
    end
    
    for p = 1,i-1 do
      if input > len then input = 1 end
      local info = p2[input]
      local obj = info.obj
      
      while seen[obj] do
        input = input + 1
        if input > len then input = 1 end
        info = p2[input]
        obj = info.obj
      end
      
      seen[obj] = info.pos
      indexes[obj] = p
      input = input + 1
    end
    
    for p = j+1,len do
      if input > len then input = 1 end
      local info = p2[input]
      local obj = info.obj
      
      while seen[obj] do
        input = input + 1
        if input > len then input = 1 end
        info = p2[input]
        obj = info.obj
      end
      
      seen[obj] = info.pos
      indexes[obj] = p
      input = input + 1
    end
  end
  
  for obj, index in pairs(indexes) do
    local info = self[index]
    info.obj = obj
    info.pos = seen[obj]
    seen[obj] = nil
  end
  
  local i = 1
  while i <= #self do
    -- Make sure all the objectives have valid positions in the list.
    local info = self[i]
    local mn, mx = self:findObjectiveRange(info.obj)
    if i < mn then
      table.insert(self, mn, info)
      table.remove(self, i)
    elseif i > mx then
      table.remove(self, i)
      table.insert(self, mx, info)
    else
      i = i + 1
    end
  end
  
  local distance = 0
  local next_info = self[2]
  local prev_info = self[1]
  local next_pos = next_info.pos
  local prev_pos = QuestHelper.pos
  
  QuestHelper:yieldIfNeeded(len*0.02)
  
  prev_info.len, prev_pos = select(2, prev_info.obj:TravelTime2(QuestHelper.pos, next_pos, false))
  QuestHelper:yieldIfNeeded(1)
  
  prev_info.pos = prev_pos
  
  indexes[self[1].obj] = 1
  indexes[self[len].obj] = len
  
  for i = 2, len-1 do
    local d1, d2
    local info = next_info
    local pos = next_pos
    next_info = self[i+1]
    next_pos = next_info.pos
    
    indexes[info.obj] = i
    
    d1, d2, pos = info.obj:TravelTime2(prev_pos, next_pos, true)
    QuestHelper:yieldIfNeeded(1)
    
    prev_info.len = d1
    info.len = d2
    prev_info = info
    prev_pos = pos
    info.pos = pos
    distance = distance + d1
  end
  
  self.distance = distance + prev_info.len
  
  --self:sanity()
end

function Route:pathResetBegin()
  for i, info in ipairs(self) do
    local pos = info.pos
    info[1], info[2], info[3] = pos[1].c, pos[3], pos[4]
  end
end

function Route:pathResetEnd()
  for i, info in ipairs(self) do
    -- Try to find a new position for this objective, near where we had it originally.
    local p, d = nil, 0
    
    local a, b, c = info[1], info[2], info[3]
    
    for z, pl in pairs(info.obj.p) do
      for i, point in ipairs(pl) do
        if a == point[1].c then
          local x, y = b-point[3], c-point[4]
          local d2 = x*x+y*y
          if not p or d2 < d then
            p, d = point, d2
          end
        end
      end
    end
    
    -- Assuming that there will still be positions on the same continents as before, i.e., locations are only added and not removed.
    assert(p)
    
    info.pos = p
  end
end

local function RouteUpdateRoutine(self)
  local map_walker = self:CreateWorldMapWalker()
  local minimap_dodad = self:CreateMipmapDodad()
  self.minimap_dodad = minimap_dodad
  
  local add_swap = {}
  local route = self.route
  local to_add, to_remove = self.to_add, self.to_remove
  
  local routes = {}
  
  for i = 1,15 do -- Create some empty routes to use for our population.
    routes[setmetatable({index={},distance=0}, Route)] = true
  end
  
  -- All the routes are the same right now, so it doesn't matter which we're considering the best.
  local best_route = next(routes)
  
  local recheck_position = 0
  
  while true do
    local changed = false
    
    if #route > 0 then
      recheck_position = recheck_position + 1
      if recheck_position > #route then recheck_position = 1 end
      local o = route[recheck_position]
      
      o.filter_zone = o.location[1] ~= self.pos[1]
      
      if not o:Known() then
        -- Objective was probably made to depend on an objective that we don't know about yet.
        -- We add it to both lists, because although we need to remove it, we need it added again when we can.
        -- This creates an inconsistancy, but it'll get fixed in the removal loop before anything has a chance to
        -- explode from it.
        
        to_remove[o] = true
        to_add[o] = true
      else
        if o.swap_before then
          self:ReleaseTable(o.before)
          o.before = o.swap_before
          o.swap_before = nil
        end
        
        if o.swap_after then
          self:ReleaseTable(o.after)
          o.after = o.swap_after
          o.swap_after = nil
        end
        
        if o.is_sharing ~= o.want_share then
          o.is_sharing = o.want_share
          
          if o.want_share then
            self:DoShareObjective(o)
          else
            self:DoUnshareObjective(o)
          end
        end
        
        CalcObjectivePriority(o)
        
        local mn, mx = best_route:findObjectiveRange(o)
        local old_index = best_route.index[o]
        if old_index < mn or old_index > mx then
          -- Make sure the objective in best_route is still in a valid position.
          -- Won't worry about other routes, they should forced into valid configurations by breeding.
          
          best_route:removeObjective(o)
          local new_index = best_route:addObjective(o)
          
          if old_index > new_index then
            old_index, new_index = new_index, old_index
          end
          
          for i = old_index, new_index do
            local info = best_route[i]
            local obj = info.obj
            obj.pos = info.pos
            route[i] = obj
          end
          
          if old_index == 1 then
            minimap_dodad:SetObjective(route[1])
          end
          
          changed = true
        end
      end
    end
    
    -- Remove any waypoints if needed.
    while true do
      local obj = next(to_remove)
      if not obj then break end
      to_remove[obj] = nil
      
      if obj.is_sharing then
        obj.is_sharing = false
        self:DoUnshareObjective(obj)
      end
      
      for r in pairs(routes) do
        if r == best_route then
          local index = r:removeObjective(obj)
          table.remove(route, index)
          if index == 1 then
            minimap_dodad:SetObjective(route[1])
          end
        else
          r:removeObjective(obj)
        end
      end
      
      obj:DoneRouting()
      changed = true
    end
    
    -- Add any waypoints if needed
    while true do
      local obj = next(to_add)
      if not obj then break end
      to_add[obj] = nil
      
      if obj:Known() then
        obj:PrepareRouting()
        
        obj.filter_zone = obj.location[1] ~= self.pos[1]
        
        if obj.filter_zone and QuestHelper_Pref.filter_zone then
          -- Not going to add it, wrong zone.
          obj:DoneRouting()
          add_swap[obj] = true
        else
          if not obj.is_sharing and obj.want_share then
            obj.is_sharing = true
            self:DoShareObjective(obj)
          end
          
          CalcObjectivePriority(obj)
          
          for r in pairs(routes) do
            if r == best_route then
              local index = r:addObjective(obj)
              obj.pos = r[index].pos
              table.insert(route, index, obj)
              if index == 1 then
                minimap_dodad:SetObjective(route[1])
              end
            else
              r:addObjective(obj)
            end
          end
          
          changed = true
        end
      else
        add_swap[obj] = true
      end
    end
    
    for obj in pairs(add_swap) do
      -- If one of the objectives we were considering adding was removed, it would be in both lists.
      -- That would be bad. We can't remove it because we haven't actually added it yet, so
      -- handle that special case here.
      if to_remove[obj] then
        to_remove[obj] = nil
        to_add[obj] = nil
        add_swap[obj] = nil
      end
    end
    
    to_add, add_swap = add_swap, to_add
    self.to_add = to_add
    
    if #best_route > 1 then
      -- If there is 2 or more objectives, randomly combine routes to (hopefully) create something better than we had before.
      local best, max_fitness
      local pos = self.pos
      
      for r in pairs(routes) do
        local fit = 1/(self:ComputeTravelTime(pos, r[1].pos)+r.distance)
        r.fitness = fit
        if not best or fit > max_fitness then
          best, max_fitness = r, fit
        end
        self:yieldIfNeeded(.3)
      end
      
      local to_breed, score
      
      for r in pairs(routes) do
        if r ~= best then
          local s = math.random()*r.fitness
          if not to_breed or s < score then
            to_breed, score = r, s
          end
        end
      end
      
      to_breed:breed(routes)
      
      if 1/(self:ComputeTravelTime(pos, to_breed[1].pos)+to_breed.distance) > max_fitness then
        best = to_breed
      end
      
      self:yieldIfNeeded(.3)
      
      if best ~= best_route then
        best_route = best
        
        for i, info in ipairs(best) do
          local obj = info.obj
          obj.pos = info.pos
          route[i] = obj
        end
        
        changed = true
      end
    end
    
    if self.defered_flight_times then
      self:buildFlightTimes()
      self.defered_flight_times = false
      assert(self.defered_graph_reset)
    end
    
    if self.defered_graph_reset then
      for r in pairs(routes) do
        r:pathResetBegin()
      end
      
      self:yieldIfNeeded(10)
      self.graph_in_limbo = true
      self:ResetPathing()
      self.graph_in_limbo = false
      self.defered_graph_reset = false
      
      for r in pairs(routes) do
        r:pathResetEnd()
      end
      
      for i, info in ipairs(best_route) do
        local obj = info.obj
        obj.pos = info.pos
        route[i] = obj
      end
      
      self:yieldIfNeeded(9)
    end
    
    if changed then
      map_walker:RouteChanged()
    end
    
    assert(#route == #best_route)
    
    if route_pass > 0 then
      route_pass = route_pass - 1
    end
    
    self:yieldIfNeeded(1)
  end
end

local update_route = coroutine.create(RouteUpdateRoutine)

function QuestHelper:RunCoroutine()
  if coroutine.status(update_route) ~= "dead" then
    coroutine_running = true
    local state, err = coroutine.resume(update_route, self)
    coroutine_running = false
    if not state then
      self:TextOut("|cffff0000The routing co-routine just exploded|r: |cffffff77"..tostring(err).."|r")
    end
  end
end

function QuestHelper:ForceRouteUpdate(passes)
  route_pass = math.max(2, passes or 1)
end
