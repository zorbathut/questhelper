
local static_horde_routes = 
  {
   {{1,8,0.505,0.124}, {2,21,0.313,0.303}, 210}, -- Durotar <--> Grom'gol Base Camp
   {{2,21,0.316,0.289}, {2,24,0.621,0.591}, 210}, -- Grom'gol Base Camp <--> Tirisfal Glades
   {{2,24,0.605,0.587}, {1,8,0.509,0.141}, 210}, -- Tirisfal Glades <--> Durotar
   {{2,25,0.549,0.110}, {2,18,0.495,0.148}, 5}, -- Undercity <--> Silvermoon City
  }
local static_alliance_routes = 
  {
   {{2,20,0.639,0.083}, {2,14,0.764,0.512}, 120}, -- Deeprun Tram
   {{2,28,0.044,0.569}, {1,5,0.323,0.441}, 210}, --Menethil Harbor <--> Auberdine
   {{1,9,0.718,0.565}, {2,28,0.047,0.636}, 210} -- Theramore Isle <--> Menethil Harmor
  }

local static_shared_routes = 
  {
   {{1,19,0.638,0.387}, {2,21,0.257,0.730}, 210}, -- Ratchet <--> Booty Bay
   {{2,4,0.587,0.599}, {3,2,0.898,0.502}, 5}, -- Dark Portal
   {{2,5,0.318,0.503}, {2,17,0.347,0.840}, 130}, -- Burning Steppes <--> Searing Gorge
   
   -- More Alliance routes than anything, but without them theres no valid path to these areas for Horde characters.
   {{1,18,0.559,0.896}, {1,6,0.305,0.414}, 5}, -- Rut'Theran Village <--> Darnassus
   {{1,5,0.332,0.398}, {1,18,0.548,0.971}, 210}, -- Auberdine <--> Rut'Theran Village
   {{1,5,0.306,0.409}, {1,3,0.2,0.546}, 210} -- Auberdine <--> Azuremyst Isle
  }

local static_zone_transitions =
  {
   {3, 1, 4, 0.842, 0.284}, -- Blade's Edge Mountains <--> Netherstorm
   {3, 1, 8, 0.482, 0.996}, -- Blade's Edge Mountains <--> Zangarmarsh
   
   {3, 2, 7, 0.353, 0.901}, -- Hellfire Peninsula <--> Terokkar Forest
   {3, 2, 8, 0.093, 0.519}, -- Hellfire Peninsula <--> Zangarmarsh
   
   {3, 3, 7, 0.800, 0.817}, -- Nagrand <--> Terokkar Forest
   {3, 3, 8, 0.343, 0.159}, -- Nagrand <--> Zangarmarsh
   {3, 3, 8, 0.754, 0.331}, -- Nagrand <--> Zangarmarsh
   
   {3, 5, 7, 0.208, 0.271}, -- Shadowmoon Vally <--> Terokkar Forest
   
   {3, 7, 8, 0.341, 0.098}, -- Terokkar Forest <--> Zangarmarsh
  }

local walkspeed_multiplier = 1/7 -- Every yard walked takes this many seconds.

local cont_heuristic = {} -- Contains a 2D table of heuristics to use for getting from one continent to another.

local function nil_heuristic(a, b)
  return 0
end

QuestHelper.prepared_objectives = {}

local function heuristic(a, b)
  if type(b) ~= "table" then QuestHelper:Error("Boom?!") end
  QuestHelper:TextOut("c="..a.c.." x="..a.x.." y="..a.y.." to c="..b.c.." x="..b.x.." y="..b.y.."  ="..cont_heuristic[a.c][b.c](a, b))
  return cont_heuristic[a.c][b.c](a, b)
end

local function same_cont_heuristic(a, b)
  local x, y = a.x-b.x, a.y-b.y
  return math.sqrt(x*x+y*y)
end


function QuestHelper:ComputeRoute(p1, p2)
  if not p1 or not p2 then QuestHelper:Error("Boom!") end
  local graph = self.world_graph
  
  graph:PrepareSearch()
  
  local l = p2[2]
  local el = p2[1]
  for i, n in ipairs(el) do
    n.e, n.w = l[i], 1
    n.s = 3
  end
  
  l = p1[2]
  for i, n in ipairs(p1[1]) do
    graph:AddRouteStartNode(n, l[i], el)
  end
  
  local e = graph:DoRouteSearch(el)
  
  assert(e)
  
  local d = e.g+e.e
  
  if p1[1] == p2[1] then
    local x, y = p1[3]-p2[3], p1[4]-p2[4]
    local d2 = math.sqrt(x*x+y*y)
    if d2 < d then
      d = d2
      e = nil
    end
  end
  
  return e, d
end

function QuestHelper:ComputeTravelTime(p1, p2)
  if not p1 or not p2 then QuestHelper:Error("Boom!") end
  local graph = self.world_graph
  
  graph:PrepareSearch()
  
  
  local l = p2[2]
  local el = p2[1]
  for i, n in ipairs(el) do
    n.e, n.w = l[i], 1
    assert(n.e)
    n.s = 3
  end
  
  l = p1[2]
  for i, n in ipairs(p1[1]) do
    graph:AddStartNode(n, l[i], el)
  end
  
  local e = graph:DoSearch(el)
  
  assert(e)
  
  local d = e.g+e.e
  
  if p1[1] == p2[1] then
    local x, y = p1[3]-p2[3], p1[4]-p2[4]
    d = math.min(d, math.sqrt(x*x+y*y))
  end
  
  return d
end

function QuestHelper:CreateGraphNode(c, x, y)
  local node = self.world_graph:CreateNode()
  
  if y then
    node.c = c
    node.x = x
    node.y = y
    node.name = nil
  else
    node.c = c[1]
    node.x, node.y = self.Astrolabe:TranslateWorldMapPosition(c[1], c[2], c[3], c[4], c[1], 0)
    node.x = node.x * self.continent_scales_x[node.c]
    node.y = node.y * self.continent_scales_y[node.c]
    node.name = select(c[2], GetMapZones(c[1]))
  end
  
  node.w = 1
  return node
end

function QuestHelper:CreateAndAddZoneNode(z, c, x, y)
  local node = self:CreateGraphNode(c, x, y)
  
  local closest, travel_time = nil, 0
  
  for i, n in ipairs(z) do
    local t = math.sqrt((n.x-node.x)*(n.x-node.x)+(n.y-node.y)*(n.y-node.y))
    if not closest or t < travel_time then
      closest, travel_time = n, t
    end
  end
  
  if closest and travel_time < 10 then
    closest.x = (closest.x * closest.w + node.x)/(closest.w+1)
    closest.y = (closest.y * closest.w + node.y)/(closest.w+1)
    closest.w = closest.w + 1
    self.world_graph:DestroyNode(node)
    return closest
  else
    table.insert(z, node)
    return node
  end
end

function QuestHelper:CreateAndAddStaticNodePair(data)
  local node1, node2 = self:CreateAndAddZoneNode(self.zone_nodes[data[1][1]][data[1][2]], data[1]),
                       self:CreateAndAddZoneNode(self.zone_nodes[data[2][1]][data[2][2]], data[2])
  
  node1.name = "route to "..select(data[2][2], GetMapZones(data[2][1]))
  node2.name = "route to "..select(data[1][2], GetMapZones(data[1][1]))
  
  node1:Link(node2, data[3])
  node2:Link(node1, data[3])
  
  return node1, node2
end

local function nodeLeavesContinent(node, c)
  if node.c == c then
    for n, d in pairs(node.n) do
      if n.c ~= c then
        return true
      end
    end
  end
  return false
end

local function isGoodPath(start_node, end_node, i, j)
  -- Checks to make sure a path doesn't leave the continent only to reenter it.
  while true do
    if end_node.p then
      if end_node.c == i then
        return false
      end
      end_node = end_node.p
      if end_node.c == j then
        return false
      end
    else
      return end_node == start_node
    end
  end
end

function QuestHelper:CreateAndAddTransitionNode(z1, z2, pos)
  local node = self:CreateGraphNode(pos)
  
  local closest, travel_time = nil, 0
  
  for i, n in ipairs(z1) do
    local t = math.sqrt((n.x-node.x)*(n.x-node.x)+(n.y-node.y)*(n.y-node.y))
    if not closest or t < travel_time then
      closest, travel_time = n, t
    end
  end
  
  if z1 ~= z2 then
    for i, n in ipairs(z2) do
      local t = math.sqrt((n.x-node.x)*(n.x-node.x)+(n.y-node.y)*(n.y-node.y))
      if not closest or t < travel_time then
        closest, travel_time = n, t
      end
    end
  end
  
  if closest and travel_time < 10 then
    --QuestHelper:TextOut("Node already exists at "..closest.x..", "..closest.y..", name="..(closest.name or "nil"))
    closest.x = (closest.x * closest.w + node.x)/(closest.w+1)
    closest.y = (closest.y * closest.w + node.y)/(closest.w+1)
    closest.w = closest.w + 1
    local z1_has, z2_has = false, false
    
    -- Just because the node already exists, doesn't mean its already in both lists!
    
    for i, n in ipairs(z1) do
      if n == closest then
        z1_has = true
        break
      end
    end
    
    if z1 ~= z2 then
      for i, n in ipairs(z2) do
        if n == closest then
          z2_has = true
          break
        end
      end
    else
      z2_has = true
    end
    
    if not z1_has then table.insert(z1, closest) end
    if not z2_has then table.insert(z2, closest) end
    
    self.world_graph:DestroyNode(node)
    return closest
  else
    table.insert(z1, node)
    if z1 ~= z2 then table.insert(z2, node) end
    return node
  end
end

function QuestHelper:ResetPathing()
  -- Objectives may include cached information that depends on the world graph.
  for o in pairs(self.prepared_objectives) do
    o:DoneRouting()
  end
  
  self.world_graph:SetHeuristic(nil_heuristic)
  
  local zone_nodes = self.zone_nodes
  if not zone_nodes then
    zone_nodes = {}
    self.zone_nodes = zone_nodes
  end
  
  local flight_master_nodes = self.flight_master_nodes
  if not flight_master_nodes then
    flight_master_nodes = {}
    self.flight_master_nodes = flight_master_nodes
  end
  
  self.world_graph:Reset()
  
  local continent_scales_x, continent_scales_y = self.continent_scales_x, self.continent_scales_y
  if not continent_scales_x then
    continent_scales_x = {}
    continent_scales_y = {}
    self.continent_scales_x = continent_scales_x
    self.continent_scales_y = continent_scales_y
  end
  
  for c=1,3 do
    if not continent_scales_x[c] then
      local _, x, y = self.Astrolabe:ComputeDistance(c, 0, 0.25, 0.25, c, 0, 0.75, 0.75)
      
      continent_scales_x[c] = x*walkspeed_multiplier*2
      continent_scales_y[c] = y*walkspeed_multiplier*2
    end
    
    if not cont_heuristic[c] then
      cont_heuristic[c] = {}
    end
    
    local cont = zone_nodes[c]
    if not cont then cont = {} zone_nodes[c] = cont end
    local z = 1
    while select(z,GetMapZones(c)) do
      local zone = cont[z]
      if not zone then
        zone = {c=c,z=z}
        cont[z] = zone
      else
        while #zone > 0 do
          table.remove(zone)
        end
      end
      z = z + 1
    end
  end
  
  -- Buggy locations I need to deal with:
  -- * Detects a zone change on the Grom'gol Base Camp/Tirisfal Glades zeppelin route.
  -- * That portal between 
  
  if self.faction == "Alliance" then
    for i, data in ipairs(static_alliance_routes) do
      self:CreateAndAddStaticNodePair(data)
    end
  elseif self.faction == "Horde" then
    for i, data in ipairs(static_horde_routes) do
      self:CreateAndAddStaticNodePair(data)
    end
  end
  
  for i, data in ipairs(static_shared_routes) do
    self:CreateAndAddStaticNodePair(data)
  end
  
  for i, data in pairs(static_zone_transitions) do
    self:CreateAndAddTransitionNode(zone_nodes[data[1]][data[2]],
                                    zone_nodes[data[1]][data[3]],
                                    {data[1], data[2], data[4], data[5]}).name = select(data[2],GetMapZones(data[1])).."/"..select(data[3],GetMapZones(data[1])).." border"
  end
  
  for c, zone_list in pairs(QuestHelper_ZoneTransition) do
    for start, end_list in pairs(zone_list) do
      for dest, pos_list in pairs(end_list) do
        for i, pos in ipairs(pos_list) do
          self:CreateAndAddTransitionNode(zone_nodes[c][start], zone_nodes[c][dest], pos).name = select(start,GetMapZones(c)).."/"..select(dest,GetMapZones(c)).." border"
        end
      end
    end
  end
  
  for c, zone_list in pairs(QuestHelper_StaticData[self.locale].zone_transition) do
    for start, end_list in pairs(zone_list) do
      for dest, pos_list in pairs(end_list) do
        for i, pos in ipairs(pos_list) do
          self:CreateAndAddTransitionNode(zone_nodes[c][start], zone_nodes[c][dest], pos).name = select(start,GetMapZones(c)).."/"..select(dest,GetMapZones(c)).." border"
        end
      end
    end
  end
  
  for name in pairs(flight_master_nodes) do
    flight_master_nodes[name] = nil
  end
  
  -- Go through the flight masters and add nodes for them as well.
  if QuestHelper_FlightInstructors[self.faction] then
    for start, npc in pairs(QuestHelper_FlightInstructors[self.faction]) do
      if not flight_master_nodes[start] then
        local npc_objective = self:GetObjective("monster", npc)
        if npc_objective:Known() and
           ((npc_objective.o.faction and npc_objective.o.faction == self.faction) or
            (npc_objective.fb.faction and npc_objective.fb.faction == self.faction)) then
          
          npc_objective:PrepareRouting()
          local p = npc_objective:Position()
          
          if p then
            flight_master_nodes[start] = self:CreateAndAddZoneNode(p[1], p[1].c, p[3], p[4])
            local _, _, area = string.find(start, "^(.*),")
            if area then
              flight_master_nodes[start].name = area.." flight point"
            else
              flight_master_nodes[start].name = start.." flight point"
            end
          end
          
          -- Because the nodes aren't linked together yet, we need to remove this objective. Trying to use the
          -- objective in pathfinding at this point would be bad.
          npc_objective:DoneRouting()
        end
      end
    end
  end
  
  if QuestHelper_StaticData[self.locale].flight_instructors[self.faction] then
    for start, npc in pairs(QuestHelper_StaticData[self.locale].flight_instructors[self.faction]) do
      if not flight_master_nodes[start] then
        local npc_objective = self:GetObjective("monster", npc)
        if npc_objective:Known() and
           ((npc_objective.o.faction and npc_objective.o.faction == self.faction) or
            (npc_objective.fb.faction and npc_objective.fb.faction == self.faction)) then
          
          npc_objective:PrepareRouting()
          local p = npc_objective:Position()
          
          if p then
            flight_master_nodes[start] = self:CreateAndAddZoneNode(p[1], p[1].c, p[3], p[4])
            local _, _, area = string.find(start, "^(.*),")
            if area then
              flight_master_nodes[start].name = area.." flight point"
            else
              flight_master_nodes[start].name = start.." flight point"
            end
          end
          
          -- Because the nodes aren't linked together yet, we need to remove this objective. Trying to use the
          -- objective in pathfinding at this point would be bad.
          npc_objective:DoneRouting()
        end
      end
    end
  end
  
  -- Will go through each zone and link all the nodes we have so far with every other node.
  for c=1,3 do
    local z = 1
    while select(z,GetMapZones(c)) do
      local list = zone_nodes[c][z]
      for i = 1,#list-1 do
        for j = i+1,#list do
          list[i]:Link(list[j], same_cont_heuristic(list[i], list[j]))
          list[j]:Link(list[i], same_cont_heuristic(list[j], list[i]))
        end
      end
      z = z + 1
    end
  end
  
  -- Add the player's know flight routes.
  for c, start_list in pairs(QuestHelper_KnownFlightRoutes) do
    for start, end_list in pairs(start_list) do
      for dest, hash in pairs(end_list) do
        local a, b = flight_master_nodes[start], flight_master_nodes[dest]
        if a and b then
          a:Link(b, self:GetFlightTime(c, start, dest))
        end
      end
    end
  end
  
  -- TODO: Create a heuristic for this.
  
  for i = 1,3 do
    for j = 1,3 do
      if i == j then
        cont_heuristic[i][j] = same_cont_heuristic
      else
        local nodes = {}
        
        local index = 1
        local code1 = ""
        local code2 = ""
        local single = true
        
        for _, start_node in ipairs(self.world_graph.nodes) do
          if nodeLeavesContinent(start_node, i) then
            for _, end_node in ipairs(self.world_graph.nodes) do
              if nodeLeavesContinent(end_node, j) then
                if self.world_graph:Search(start_node, end_node) then
                  if isGoodPath(start_node, end_node, i, j) then
                    if not nodes[start_node] then
                      nodes[start_node] = "n"..index
                      code1 = code1.."local "..nodes[start_node].."=math.sqrt(a.x*a.x+a.y*a.y-a.x*("..(2*start_node.x)..")-a.y*("..(2*start_node.y)..")+("..(start_node.x*start_node.x+start_node.y*start_node.y).."))\n"
                      index = index + 1
                    end
                    if not nodes[end_node] then
                      nodes[end_node] = "n"..index
                      code1 = code1.."local "..nodes[end_node].."=math.sqrt(b.x*b.x+b.y*b.y-b.x*("..(2*end_node.x)..")-b.y*("..(2*end_node.y)..")+("..(end_node.x*end_node.x+end_node.y*end_node.y).."))\n"
                      index = index + 1
                    end
                    if code2 ~=  "" then code2 = code2 .. ", " single = false end
                    code2 = code2 .. nodes[start_node] .. "+"..nodes[end_node] .. "+"..(end_node.g)
                  end
                end
              end
            end
          end
        end
        
        cont_heuristic[i][j] = loadstring("local a,b = ...\n"..code1.."return "..(single and code2 or ("math.min("..code2..")")))
      end
    end
  end
  
  self.world_graph:SanityCheck()
  
  -- TODO: heuristic returns NaNs, fix this.
  --self.world_graph:SetHeuristic(heuristic)
  
  -- Route objectives are expected to be routable.
  for i, obj in ipairs(self.route) do
    obj:PrepareRouting()
  end
  
  -- And if all went according to plan, we now have a graph we can follow to get from anywhere to anywhere.
  
end
