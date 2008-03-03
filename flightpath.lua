local real_TakeTaxiNode = TakeTaxiNode

assert(type(real_TakeTaxiNode) == "function")



local name_table = nil

local function BeginNameLookup()
  assert(not name_table)
  name_table = QuestHelper:CreateTable()
  for i = 1,NumTaxiNodes() do
    local x, y = TaxiNodePosition(i)
    name_table[math.floor(x*500)+math.floor(y*500)*500] = TaxiNodeName(i)
  end
end

local function LookupName(x, y)
  return name_table[math.floor(x*500)+math.floor(y*500)*500]
end

local function EndNameLookup()
  QuestHelper:ReleaseTable(name_table)
  name_table = nil
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
          
          BeginNameLookup()
          
          for j = 1,routes-1 do
            path_str = string.format("%s/%s", path_str, LookupName(TaxiGetDestX(id, j), TaxiGetDestY(id, j)))
          end
          
          EndNameLookup()
          
          path_hash = QuestHelper:HashString(path_str)
        end
        
        -- TODO: Use this data for something.
        QuestHelper:TextOut("Flying from "..origin.." to "..dest..", #"..path_hash)
        
        local flight_data = QuestHelper.flight_data
        
        if not flight_data then
          flight_data = QuestHelper:CreateTable()
          QuestHelper.flight_data = flight_data
        end
        
        flight_data.origin = origin
        flight_data.dest = dest
        flight_data.hash = path_hash
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
    self:TextOut("!!! Flew from "..data.origin.." to "..data.dest.." in "..dest[data.hash].." seconds.")
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

function QuestHelper:taxiMapOpened()
  local links = QuestHelper_FlightLinks[self.faction]
  if not links then
    links = {}
    QuestHelper_FlightLinks[self.faction] = links
  end
  
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
    
    BeginNameLookup()
    
    for j = 1,NumTaxiNodes() do
      local routes = GetNumRoutes(j)
      if routes and i ~= j and routes > 0 and routes < 100 then
        for k = 1,routes do
          local n1, n2 = LookupName(TaxiGetSrcX(j, k), TaxiGetSrcY(j, k)), LookupName(TaxiGetDestX(j, k), TaxiGetDestY(j, k))
          assert(n1 and n2 and n1 ~= n2)
          local t1, t2 = links[n1], links[n2]
          
          if not t1 then
            t1 = {}
            links[n1] = t1
          end
          
          if not t2 then
            t2 = {}
            links[n2] = t2
          end
          
          -- TODO: if we didn't already know about this linkage and its not in the static data, we should set altered to true.
          t1[n2] = true
          t2[n1] = true
        end
      end
    end
    
    EndNameLookup()
  end
  
  if altered then
    self:TextOut(QHText("ROUTES_CHANGED"))
    self:TextOut(QHText("WILL_RESET_PATH"))
    self.defered_graph_reset = true
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
