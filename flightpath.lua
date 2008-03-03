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
        
        if routes == 1 then
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
      end
    end
  end
  
  real_TakeTaxiNode(id)
end

function QuestHelper:TaxiMapOpened()
  local links = QuestHelper_FlightLinks[self.faction]
  if not links then
    links = {}
    QuestHelper_FlightLinks[self.faction] = links
  end
  
  for i = 1,NumTaxiNodes() do
    if GetNumRoutes(i) == 0 then -- Zero hops from this location, must be where we are.
      local origin = TaxiNodeName(i)
      
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
            
            t1[n2] = true
            t2[n1] = true
          end
        end
      end
      
      EndNameLookup()
    end
  end
end
