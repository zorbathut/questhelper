QuestHelper_File["flightpath.lua"] = "Development Version"

local real_TakeTaxiNode = TakeTaxiNode
local real_TaxiNodeOnButtonEnter= TaxiNodeOnButtonEnter

assert(type(real_TakeTaxiNode) == "function")
assert(type(real_TaxiNodeOnButtonEnter) == "function")

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

local function getRoute(id)
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
        
        return origin, dest, path_hash
      end
    end
  end
end

TaxiNodeOnButtonEnter = function(btn)
  real_TaxiNodeOnButtonEnter(btn)
  
  if QuestHelper_Pref.flight_time then
    local index = btn:GetID()
    if TaxiNodeGetType(index) == "REACHABLE" then
      local origin, dest, hash = getRoute(index)
      local eta, estimate = nil, false
      if origin then
        eta = QuestHelper:computeLinkTime(origin, dest, hash, false)
        if not eta then
          eta = QuestHelper.flight_times[origin] and QuestHelper.flight_times[origin][dest]
          estimate = true
        end
      end
      
      if eta then -- Going to replace the tooltip.
        GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(dest, "", 1.0, 1.0, 1.0)
        GameTooltip:AddDoubleLine(QHText("TRAVEL_ESTIMATE"), (estimate and "|cffffffff≈|r " or "")..QHFormat("TRAVEL_ESTIMATE_VALUE", eta))
        local cost = TaxiNodeCost(index)
        if cost > 0 then
          SetTooltipMoney(GameTooltip, cost)
        end
        GameTooltip:Show()
      end
    end
  end
end

TakeTaxiNode = function(id)
  local origin, dest, hash = getRoute(id)
  
  if origin then
    local flight_data = QuestHelper.flight_data
    if not flight_data then
      flight_data = QuestHelper:CreateTable()
      QuestHelper.flight_data = flight_data
    end
    
    flight_data.origin = origin
    flight_data.dest = dest
    flight_data.hash = hash
    flight_data.start_time = nil
    flight_data.end_time = nil
    flight_data.end_time_estimate = nil
  end
  
  real_TakeTaxiNode(id)
end

function QuestHelper:processFlightData(data, interrupted)
  local npc = self:getFlightInstructor(data.dest)
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
  
  local correct = true
  
  if pos[1].c ~= self.c then
    correct = false
  else
    local x, y = self.Astrolabe:TranslateWorldMapPosition(self.c, self.z, self.x, self.y, self.c, 0)
    x = x * self.continent_scales_x[self.c]
    y = y * self.continent_scales_y[self.c]
    local t = (x-pos[3])*(x-pos[3])+(y-pos[4])*(y-pos[4])
    
    --self:TextOut(string.format("(%f,%f) vs (%f,%f) is %f", x, y, pos[3], pos[4], t))
    
    if t > 5*5 then
      correct = false
    end
  end
  
  npc_obj:DoneRouting()
  
  if not correct then
    return true
  end
  
  if data.start_time and data.end_time and data.end_time > data.start_time then
    local routes = QuestHelper_FlightRoutes_Local[self.faction]
    if not routes then
      routes = {}
      QuestHelper_FlightRoutes_Local[self.faction] = routes
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
    
    if interrupted then -- I'm assuming this doesn't depend on the hash, since I really doubt the routing system would let a player go through zone boundaries if it wasn't mandatory
      dest.interrupt_count = (dest.interrupt_count or 0) + 1
    else
      dest.no_interrupt_count = (dest.no_interrupt_count or 0) + 1
    end
  end
  
  return true
end

function QuestHelper:getFlightInstructor(area)
  local fi_table = QuestHelper_FlightInstructors_Local[self.faction]
  if fi_table then
    local npc = fi_table[area]
    if npc then
      return npc
    end
  end
  
  local static = QuestHelper_StaticData[QuestHelper_Locale]
  
  if static then
    fi_table = static.flight_instructors and static.flight_instructors[self.faction]
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

-- Okay, I think I've figured out what this is. Given fi1 and fi2, the standard horrifying "canonical/fallback" stuff that all this code does . . .
-- For each pair of "origin/dest" in tbl, determine if there is a direct path. (If there is, the hash will be 0.)
-- If so, find the flightpath distance and the "walking" distance. Add up walking and flightpath separately, and return the sums.
local function getWalkToFlight(tbl, fi1, fi2)
  local f, w = 0, 0
  
  if tbl then
    for origin, list in pairs(tbl) do
      for dest, hashlist in pairs(list) do
        if type(hashlist[0]) == "number" then
          local npc1, npc2 = (fi1 and fi1[origin]) or (fi2 and fi2[origin]), (fi1 and fi1[dest]) or (fi2 and fi2[dest])
          if npc1 and npc2 then
            local obj1, obj2 = QuestHelper:GetObjective("monster", npc1), QuestHelper:GetObjective("monster", npc2)
            obj1:PrepareRouting({failable = true})
            obj2:PrepareRouting({failable = true})
            
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

-- Determines the general multiple faster than flying is than walking.
function QuestHelper:computeWalkToFlightMult()
  local l = QuestHelper_FlightRoutes_Local[self.faction]
  local s = QuestHelper_StaticData[self.locale]
  s = s and s.flight_routes
  s = s and s[self.faction]
  
  local fi1 = QuestHelper_FlightInstructors_Local[self.faction]
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
  
  local l = QuestHelper_FlightRoutes_Local[self.faction]
  local s = QuestHelper_StaticData[self.locale]
  s = s and s.flight_routes
  s = s and s[self.faction]
  
  hash = hash or 0
  
  -- Will try to lookup flight time there, failing that, will use the time from there to here.
  local t = getTime(l, origin, dest, hash) or getTime(s, origin, dest, hash) or
            getTime(l, dest, origin, hash) or getTime(s, dest, origin, hash) or fallback
  
  if t == nil then -- Don't have any recored information on this flight time, will estimate based on distances.
    l = QuestHelper_FlightInstructors_Local[self.faction]
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

local moonglade_fp = nil

function QuestHelper:addLinkInfo(data, flight_times)
  if data then
    if select(2, UnitClass("player")) ~= "DRUID" then
      -- As only druids can use the flight point in moonglade, we need to figure out
      -- where it is so we can ignore it.
      
      if not moonglade_fp then
        
        local fi_table = QuestHelper_FlightInstructors_Local[self.faction]
        
        if fi_table then for area, npc in pairs(fi_table) do
          local npc_obj = self:GetObjective("monster", npc)
          npc_obj:PrepareRouting({failable = true})
          local pos = npc_obj:Position()
          if pos and QuestHelper_IndexLookup[pos[1].c][pos[1].z] == 20 and string.find(area, ",") then -- I'm kind of guessing here
            moonglade_fp = area
            npc_obj:DoneRouting()
            break
          end
          npc_obj:DoneRouting()
        end end
        
        if not moonglade_fp then
          fi_table = QuestHelper_StaticData[QuestHelper_Locale]
          fi_table = fi_table and fi_table.flight_instructors and fi_table.flight_instructors[self.faction]
          
          if fi_table then for area, npc in pairs(fi_table) do
            local npc_obj = self:GetObjective("monster", npc)
            npc_obj:PrepareRouting({failable = true})
            local pos = npc_obj:Position()
            if pos and QuestHelper_IndexLookup[pos[1].c][pos[1].z] == 20 and string.find(area, ",") then
              moonglade_fp = area
              npc_obj:DoneRouting()
              break
            end
            npc_obj:DoneRouting()
          end end
        end
        
        if not moonglade_fp then
          -- This will always be unknown for the session, even if you call buildFlightTimes again
          -- but if it's unknown then you won't be able to
          -- get the waypoint this session since you're not a druid
          -- so its all good.
          moonglade_fp = "unknown"
        end
      end
    end
    
    for origin, list in pairs(data) do
      local tbl = flight_times[origin]
      if not tbl then
        tbl = self:CreateTable("flightpath addLinkInfo")
        flight_times[origin] = tbl
      end
      
      for dest, hashs in pairs(list) do
        if origin ~= moonglade_fp and QuestHelper_KnownFlightRoutes[dest] and hashs[0] then
          local tbl2 = tbl[dest]
          if not tbl2 then
            local t = self:computeLinkTime(origin, dest)
            if t then
              tbl2 = self:CreateTable()
              tbl[dest] = tbl2
              tbl2[1] = t
              tbl2[2] = dest
            end
          end
        end
      end
    end
  end
end

local visited = {}

local function getDataTime(ft, origin, dest)
  local str = nil
  local data = ft[origin][dest]
  local t = data[1]
  
  for key in pairs(visited) do visited[key] = nil end
  
  while true do
    local n = data[2]
    
    -- We might be asked about a route that visits the same point multiple times, and
    -- since this is effectively a linked list, we need to check for this to avoid
    -- infinite loops.
    if visited[n] then return end
    visited[n] = true
    
    local temp = QuestHelper:computeLinkTime(origin, n, str and QuestHelper:HashString(str) or 0, false)
    
    if temp then
      t = temp + (n == dest and 0 or ft[n][dest][1])
    end
    
    if n == dest then break end
    str = string.format("%s/%s", str or "", n)
    data = ft[n][dest]
  end
  
  return t
end

function QuestHelper:buildFlightTimes()
  self.flight_scalar = self:computeWalkToFlightMult()
  
  local flight_times = self.flight_times
  if not flight_times then
    flight_times = self:CreateTable()
    self.flight_times = flight_times
  end
  
  for key, list in pairs(flight_times) do
    self:ReleaseTable(list)
    flight_times[key] = nil
  end
  
  local l = QuestHelper_FlightRoutes_Local[self.faction]
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
        if flight_times[dest] then for dest2, data2 in pairs(flight_times[dest]) do
          if dest2 ~= origin then
            local dat = list[dest2]
            
            if not dat then
              dat = self:CreateTable()
              dat[1], dat[2] = data[1]+data2[1], dest
              list[dest2] = dat
              dat[1] = getDataTime(flight_times, origin, dest2)
              
              if not dat[1] then
                self:ReleaseTable(dat)
                list[dest2] = nil
              else
                cont = true
              end
            else
              local o1, o2 = dat[1], dat[2] -- Temporarly replace old data for the sake of looking up its time.
              if o2 ~= dest then
                dat[1], dat[2] = data[1]+data2[1], dest
                local t2 = getDataTime(flight_times, origin, dest2)
                
                if t2 and t2 < o1 then
                  dat[1] = t2
                  cont = true
                else
                  dat[1], dat[2] = o1, o2
                end
              end
            end
          end
        end end
        self:yieldIfNeeded()
      end
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
  local routes = QuestHelper_FlightRoutes_Local[self.faction]
  
  if not routes then
    routes = {}
    QuestHelper_FlightRoutes_Local[self.faction] = routes
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
    local npc = UnitName("npc")
    
    if npc then
      -- Record who the flight instructor for this location is.
      local fi_table = QuestHelper_FlightInstructors_Local[self.faction]
      if not fi_table then
        fi_table = {}
        QuestHelper_FlightInstructors_Local[self.faction] = fi_table
      end
      
      fi_table[origin] = npc
    end
    
    if not self.flight_times[origin] then
      -- If this is true, then we probably either didn't who the flight instructor here was,
      -- or did know but didn't know where.
      -- As we should now know, the flight times should be updated.
      altered = true
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
    self.defered_flight_times = true
    --self:buildFlightTimes()
  end
end

local elapsed = 0
local function flight_updater(frame, delta)
  elapsed = elapsed + delta
  if elapsed > 1 then
    elapsed = elapsed - 1
    local data = QuestHelper.flight_data
    if data then
      frame:SetText(string.format("%s: %s", QuestHelper:HighlightText(select(3, string.find(data.dest, "^(.-),")) or data.dest),
                                            QuestHelper:TimeString(math.max(0, data.end_time_estimate-time()))))
    else
      frame:Hide()
      frame:SetScript("OnUpdate", nil)
    end
  end
end

function QuestHelper:flightBegan()
  if self.flight_data and not self.flight_data.start_time then
    self.flight_data.start_time = GetTime()
    local origin, dest = self.flight_data.origin, self.flight_data.dest
    local eta = self:computeLinkTime(origin, dest, self.flight_data.hash,
                                     self.flight_times[origin] and self.flight_times[origin][dest]) or 0
    
    local npc = self:getFlightInstructor(self.flight_data.dest) -- Will inform QuestHelper that we're going to be at this NPC in whenever.
    if npc then
      local npc_obj = self:GetObjective("monster", npc)
      npc_obj:PrepareRouting()
      local pos = npc_obj:Position()
      if pos then
        local c, z = pos[1].c, pos[1].z
        local x, y = self.Astrolabe:TranslateWorldMapPosition(c, 0,
                                                              pos[3]/self.continent_scales_x[c],
                                                              pos[4]/self.continent_scales_y[c], c, z)
        
        self:SetTargetLocation(QuestHelper_IndexLookup[c][z], x, y, eta)
        
      end
      npc_obj:DoneRouting()
    end
    
    if QuestHelper_Pref.flight_time then
      self.flight_data.end_time_estimate = time()+eta
      self:PerformCustomSearch(flight_updater) -- Reusing the search status indicator to display ETA for flight.
    end
  end
end

function QuestHelper:flightEnded(interrupted)
  local flight_data = self.flight_data
  if flight_data and not flight_data.end_time then
    flight_data.end_time = GetTime()
    
    if self:processFlightData(flight_data, interrupted) then
      self:ReleaseTable(flight_data)
      self.flight_data = nil
    end
    
    self:UnsetTargetLocation()
    self:StopCustomSearch()
  end
end
