local real_TakeTaxiNode = TakeTaxiNode

assert(type(real_TakeTaxiNode) == "function")

local function LookupName(x, y)
  local best, d2
  for i = 1,NumTaxiNodes() do
    local u, v = TaxiNodePosition(i)
    u = u - x
    v = v - y
    u = u*u+v*v
    if not best or u < d2 then
      best, d2 = TaxiNodeName(i), u
    end
  end
  
  return best
end

TakeTaxiNode = function(id)
  for i = 1,NumTaxiNodes() do
    if GetNumRoutes(i) == 0 then
      local routes = GetNumRoutes(id)
      if routes and routes > 0 and routes < 100 then
        local origin, dest = TaxiNodeName(i), TaxiNodeName(id)
        local path_hash = 0
        
        if routes > 1 then
          local path_str = ""
          
          for j = 1,routes-1 do
            path_str = string.format("%s/%s", path_str, LookupName(TaxiGetDestX(id, j), TaxiGetDestY(id, j)))
          end
          
          path_hash = QuestHelper:HashString(path_str)
        end
        
        local flight_data = QuestHelper.flight_data
        
        if not flight_data then
          flight_data = QuestHelper:CreateTable()
          QuestHelper.flight_data = flight_data
        end
        
        flight_data.origin = origin
        flight_data.dest = dest
        flight_data.hash = path_hash
        
        QuestHelper:TextOut("!!! Expect flight time to be: "..QuestHelper:TimeString(QuestHelper.flight_times[origin][dest]))
      end
    end
  end
  
  real_TakeTaxiNode(id)
end

function QuestHelper:processFlightData(data)
  local npc = QuestHelper:getFlightInstructor(data.dest)
  if not npc then
    self:TextOut(QHText("TALK_TO_FLIGHT_MASTER"))
    return false
  end
  
  local npc_obj = self:GetObjective("monster", npc)
  npc_obj:PrepareRouting()
  
  local pos = npc_obj:Position()
  if not pos then
    -- Don't know te location of the flight instructor.
    self:TextOut(QHText("TALK_TO_FLIGHT_MASTER"))
    npc_obj:DoneRouting()
    return false
  end
  
  if pos[1] ~= self.pos[1] or (self.pos[3]-pos[3])*(self.pos[3]-pos[3])+(self.pos[4]-pos[4])*(self.pos[4]-pos[4]) > 5*5 then
    -- The player doesn't seem to be within 5 seconds walking distance of the destination's flight master.
    self:TextOut("!!! You're not where you're supposed to be.")
    npc_obj:DoneRouting()
    return true
  end
  
  npc_obj:DoneRouting()
  
  if data.start_time and data.end_time and data.end_time > data.start_time then
    local routes = QuestHelper_FlightRoutes[self.faction]
    if not routes then
      routes = {}
      QuestHelper_FlightRoutes[self.faction] = routes
    end
    
    local origin = routes[data.origin]
    if not origin then
      origin = {}
      routes[data.origin] = origin
    end
    
    local dest = origin[data.dest]
    if not dest then
      dest = {}
      origin[data.dest] = dest
    end
    
    dest[data.hash] = data.end_time - data.start_time
    self:TextOut("!!! Flew from "..data.origin.." to "..data.dest.." in "..self:TimeString(dest[data.hash]))
  end
  
  return true
end

function QuestHelper:getFlightInstructor(area)
  local fi_table = QuestHelper_FlightInstructors[self.faction]
  if fi_table then
    local npc = fi_table[area]
    if npc then
      return npc
    end
  end
  
  local static = QuestHelper_StaticData[QuestHelper_Locale]
  
  if static then
    fi_table = static.flight_instructor and static.flight_instructor[self.faction]
    if fi_table then
      return fi_table[area]
    end
  end
end

local function getTime(tbl, orig, dest, hash)
  tbl = tbl and tbl[orig]
  tbl = tbl and tbl[dest]
  return tbl and tbl[hash] ~= true and tbl[hash]
end

local function getWalkToFlight(tbl, fi1, fi2)
  local f, w = 0, 0
  
  if tbl then
    for origin, list in pairs(tbl) do
      for dest, hashlist in pairs(list) do
        if type(hashlist[0]) == "number" then
          local npc1, npc2 = fi1[origin] or fi2[origin], fi1[dest] or fi2[dest]
          if npc1 and npc2 then
            local obj1, obj2 = QuestHelper:GetObjective("monster", npc1), QuestHelper:GetObjective("monster", npc2)
            obj1:PrepareRouting()
            obj2:PrepareRouting()
            
            local pos1, pos2 = obj1:Position(), obj2:Position()
            
            if pos1 and pos2 then
              local x, y = pos1[3]-pos2[3], pos1[4]-pos2[4]
              w = w + math.sqrt(x*x+y*y)
              f = f + hashlist[0]
            end
            
            obj2:DoneRouting()
            obj1:DoneRouting()
          end
        end
      end
    end
  end
  
  return f, w
end

function QuestHelper:computeWalkToFlightMult()
  local l = QuestHelper_FlightRoutes[self.faction]
  local s = QuestHelper_StaticData[self.locale]
  s = s and s.flight_route
  s = s and s[self.faction]
  
  local fi1 = QuestHelper_FlightInstructors[self.faction]
  local fi2 = QuestHelper_StaticData[self.locale]
  fi2 = fi2 and fi2.flight_instructors
  fi2 = fi2 and fi2[self.faction]
  
  local f1, w1 = getWalkToFlight(l, fi1, fi2)
  local f2, w2 = getWalkToFlight(s, fi1, fi2)
  return (f1+f2+0.032876)/(w1+w2+0.1)
end

function QuestHelper:computeLinkTime(origin, dest, hash, fallback)
  -- Only works for directly connected flight points.
  
  if origin == dest then
    return 0
  end
  
  local l = QuestHelper_FlightRoutes[self.faction]
  local s = QuestHelper_StaticData[self.locale]
  s = s and s.flight_route
  s = s and s[self.faction]
  
  hash = hash or 0
  
  -- Will try to lookup flight time there, failing that, will use the time from there to here.
  local t = getTime(l, origin, dest, hash) or getTime(s, origin, dest, hash) or
            getTime(l, dest, origin, hash) or getTime(s, dest, origin, hash) or fallback
  
  if not t then -- Don't have any recored information on this flight time, will estimate based on distances.
    l = QuestHelper_FlightInstructors[self.faction]
    s = QuestHelper_StaticData[self.locale]
    s = s and s.flight_instructors
    s = s and s[self.faction]
    local npc1, npc2 = (l and l[origin]) or (s and s[origin]),
                       (l and l[dest]) or (s and s[dest])
    
    if npc1 and npc2 then
      local obj1, obj2 = self:GetObjective("monster", npc1), self:GetObjective("monster", npc2)
      obj1:PrepareRouting()
      obj2:PrepareRouting()
      
      local pos1, pos2 = obj1:Position(), obj2:Position()
      
      if pos1 and pos2 then
        local x, y = pos1[3]-pos2[3], pos1[4]-pos2[4]
        
        t = math.sqrt(x*x+y*y)*self.flight_scalar
      end
      
      obj2:DoneRouting()
      obj1:DoneRouting()
    end
  end
  
  return t
end

function QuestHelper:addLinkInfo(data, flight_times)
  if data then
    for origin, list in pairs(data) do
      local tbl = flight_times[origin]
      if not tbl then
        tbl = self:CreateTable()
        flight_times[origin] = tbl
      end
      
      for dest, hashs in pairs(list) do
        if QuestHelper_KnownFlightRoutes[dest] and hashs[0] then
          local tbl2 = tbl[dest]
          if not tbl2 then
            tbl2 = self:CreateTable()
            tbl[dest] = tbl2
            tbl2[1] = self:computeLinkTime(origin, dest)
          end
        end
      end
    end
  end
end

function QuestHelper:buildFlightTimes()
  self.flight_scalar = self:computeWalkToFlightMult()
  self:TextOut("Scalar: "..self.flight_scalar)
  
  local flight_times = self.flight_times
  if not flight_times then
    flight_times = self:CreateTable()
    self.flight_times = flight_times
  end
  
  for key, list in pairs(flight_times) do
    self:ReleaseTable(list)
    flight_times[key] = nil
  end
  
  local l = QuestHelper_FlightRoutes[self.faction]
  local s = QuestHelper_StaticData[self.locale]
  s = s and s.flight_routes
  s = s and s[self.faction]
  
  self:addLinkInfo(l, flight_times)
  self:addLinkInfo(s, flight_times)
  
  local cont = true
  while cont do
    cont = false
    local origin = nil
    while true do
      origin = next(flight_times, origin)
      if not origin then break end
      local list = flight_times[origin]
      
      for dest, data in pairs(list) do
        local t = data[1]
        for dest2, data2 in pairs(flight_times[dest]) do
          if dest2 ~= origin then
            local t2 = t+data2[1]
            local dat = list[dest2]
            if not dat then
              dat = self:CreateTable()
              dat[1], dat[2] = t2, dest
              list[dest2] = dat
              cont = true
            elseif t2 < dat[1] then
              dat[1], dat[2] = t2, dest
              cont = true
            end
          end
        end
      end
    end
  end
  
  -- Attempt to lookup the exact flight times.
  for orig, list in pairs(flight_times) do
    for dest, data in pairs(list) do
      local str
      
      while data[2] do
        str = string.format("%s/%s", str or "", data[2])
        data = flight_times[data[2]][dest]
      end
      
      data[1] = self:computeLinkTime(orig, dest, str and self:HashString(str) or 0, data[1])
    end
  end
  
  -- Replace the tables with simple times.
  for orig, list in pairs(flight_times) do
    for dest, data in pairs(list) do
      local t = data[1]
      self:ReleaseTable(data)
      list[dest] = t
    end
  end
end

function QuestHelper:taxiMapOpened()
  local routes = QuestHelper_FlightRoutes[self.faction]
  
  if not routes then
    routes = {}
    QuestHelper_FlightRoutes[self.faction] = routes
  end
  
  local sroutes = QuestHelper_StaticData[self.locale]
  sroutes = sroutes and sroutes.flight_routes
  sroutes = sroutes and sroutes[self.faction]
  
  local origin, altered = nil, false
  
  for i = 1,NumTaxiNodes() do
    local name = TaxiNodeName(i)
    if not QuestHelper_KnownFlightRoutes[name] then
      QuestHelper_KnownFlightRoutes[name] = true
      altered = true
    end
    
    if GetNumRoutes(i) == 0 then -- Zero hops from this location, must be where we are.
      origin = name
    end
  end
  
  if origin then
    if not QuestHelper_KnownFlightRoutes[origin] then
      -- Player didn't previously have this flight point, will need to recalculate pathing data to account for it.
      QuestHelper_KnownFlightRoutes[origin] = true
      self:TextOut(QHText("ROUTES_CHANGED"))
      self:TextOut(QHText("WILL_RESET_PATH"))
      self.defered_graph_reset = true
    end
    
    local npc = UnitName("npc")
    
    if npc then
      -- Record who the flight instructor for this location is.
      local fi_table = QuestHelper_FlightInstructors[self.faction]
      if not fi_table then
        fi_table = {}
        QuestHelper_FlightInstructors[self.faction] = fi_table
      end
      
      fi_table[origin] = npc
    end
    
    if self.flight_data and self:processFlightData(self.flight_data) then
      self:TextOut(QHText("TALK_TO_FLIGHT_MASTER_COMPLETE"))
      self:ReleaseTable(self.flight_data)
      self.flight_data = nil
    end
    
    for j = 1,NumTaxiNodes() do
      local node_count = GetNumRoutes(j)
      if node_count and i ~= j and node_count > 0 and node_count < 100 then
        for k = 1,node_count do
          local n1, n2 = LookupName(TaxiGetSrcX(j, k), TaxiGetSrcY(j, k)), LookupName(TaxiGetDestX(j, k), TaxiGetDestY(j, k))
          
          assert(n1 and n2 and n1 ~= n2)
          
          local dest1, dest2 = routes[n1], routes[n2]
          
          if not dest1 then
            dest1 = {}
            routes[n1] = dest1
          end
          
          if not dest2 then
            dest2 = {}
            routes[n2] = dest2
          end
          
          local hash1, hash2 = dest1[n2], dest2[n1]
          
          if not hash1 then
            hash1 = {}
            dest1[n2] = hash1
          end
          
          if not hash2 then
            hash2 = {}
            dest2[n1] = hash2
          end
          
          if not hash1[0] then
            if not (slinks and slinks[n1] and slinks[n1][n2] and slinks[n1][n2][0]) then
              -- hadn't been considering this link in pathing.
              altered = true
            end
            hash1[0] = true
          end
          
          if not hash2[0] then
            if not (slinks and slinks[n2] and slinks[n2][n1] and slinks[n2][n1][0]) then
              -- hadn't been considering this link in pathing.
              altered = true
            end
            hash2[0] = true
          end
        end
      end
    end
  end
  
  if altered then
    self:TextOut(QHText("ROUTES_CHANGED"))
    self:TextOut(QHText("WILL_RESET_PATH"))
    self.defered_graph_reset = true
    self:buildFlightTimes()
  end
end

function QuestHelper:flightBegan()
  if self.flight_data then
    self.flight_data.start_time = GetTime()
  end
end

function QuestHelper:flightEnded()
  local flight_data = self.flight_data
  if flight_data then
    flight_data.end_time = flight_data.end_time or GetTime()
    
    if self:processFlightData(flight_data) then
      self:ReleaseTable(flight_data)
      self.flight_data = nil
    end
  end
end
