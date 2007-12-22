
local static_horde_routes = 
  {
   {{1,8,0.505,0.124}, {2,21,0.313,0.303}, 210}, -- Durotar <--> Grom'gol Base Camp
   {{2,21,0.316,0.289}, {2,24,0.621,0.591}, 210}, -- Grom'gol Base Camp <--> Tirisfal Glades
   {{2,24,0.605,0.587}, {1,8,0.509,0.141}, 210}, -- Tirisfal Glades <--> Durotar
   {{2,25,0.549,0.110}, {2,18,0.495,0.148}, 0}, -- Undercity <--> Silvermoon City
  }
local static_alliance_routes = 
  {
   {{2,20,0.639,0.083}, {2,14,0.764,0.512}, 120}, -- Deeprun Tram
   {{2,28,0.044,0.569}, {1,5,0.323,0.441}, 210}, --Menethil Harbor <--> Auberdine
   {{1,18,0.559,0.896}, {1,6,0.305,0.414}, 0}, -- Rut'Theran Village <--> Darnassus
   {{1,9,0.718,0.565}, {2,28,0.047,0.636}, 210} -- Theramore Isle <--> Menethil Harmor
  }

local static_shared_routes = 
  {
   {{1,19,0.638,0.387}, {2,21,0.257,0.730}, 210}, -- Ratchet <--> Booty Bay
   {{2,4,0.87,0.599}, {3,2,0.898,0.502}, 0}, -- Dark Portal
   
   -- More Alliance routes than anything, but without them theres no valid path to these areas for Horde characters.
   {{1,5,0.332,0.398}, {1,18,0.548,0.971}, 210}, -- Auberdine <--> Rut'Theran Village
   {{1,5,0.306,0.409}, {1,3,0.2,0.546}, 210} -- Auberdine <--> Azuremyst Isle
  }

local walkspeed_multiplier = 1/7 -- Every yard walked takes this many seconds.

function QuestHelper:ComputeRoute(c1, z1, x1, y1, c2, z2, x2, y2)
  if z1 > 0 and z2 > 0 then
    local list1, list2 = self.zone_nodes[c1][z1], self.zone_nodes[c2][z2]
    
    x1, y1 = self.Astrolabe:TranslateWorldMapPosition(c1, z1, x1, y1, c1, 0)
    x2, y2 = self.Astrolabe:TranslateWorldMapPosition(c2, z2, x2, y2, c2, 0)
    
    x1 = x1 * self.continent_scales_x[c1]
    y1 = y1 * self.continent_scales_y[c1]
    x2 = x2 * self.continent_scales_x[c2]
    y2 = y2 * self.continent_scales_y[c2]
    
    for i, n in ipairs(list1) do n.g = math.sqrt((x1-n.x)*(x1-n.x)+(y1-n.y)*(y1-n.y)) end
    for i, n in ipairs(list2) do n.e = math.sqrt((x2-n.x)*(x2-n.x)+(y2-n.y)*(y2-n.y)) end
    
    local result =  self.world_graph:MultiSearch(list1, list2, function () return 0 end )
    
    if result and c1 == c2 and z1 == z2 and result.g + result.e >= math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)) then
      return nil
    end
    return result
  end
end

function QuestHelper:CreateGraphNode(pos)
  local node = self.world_graph:CreateNode()
  if not node.pos then node.pos = {} end
  
  node.x, node.y = self.Astrolabe:TranslateWorldMapPosition(pos[1], pos[2], pos[3], pos[4], pos[1], 0)
  node.c = pos[1]
  node.x = node.x * self.continent_scales_x[node.c]
  node.y = node.y * self.continent_scales_y[node.c]
  node.w = 1
  node.pos[1], node.pos[2], node.pos[3], node.pos[4] = pos[1], pos[2], pos[3], pos[4]
  return node
end

function QuestHelper:CreateAndAddZoneNode(z, pos)
  local node = self:CreateGraphNode(pos)
  
  local closest, travel_time = nil, 0
  
  for i, n in ipairs(z) do
    local t = math.sqrt((n.x-node.x)*(n.x-node.x)+(n.y-node.y)*(n.y-node.y))
    if not closest or t < travel_time then
      closest, travel_time = n, t
    end
  end
  
  if closest and travel_time < 30 then
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
  
  node1:Link(node2, data[3])
  node2:Link(node1, data[3])
  
  return node1, node2
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
  
  for i, n in ipairs(z1) do
    local t = math.sqrt((n.x-node.x)*(n.x-node.x)+(n.y-node.y)*(n.y-node.y))
    if not closest or t < travel_time then
      closest, travel_time = n, t
    end
  end
  if closest and travel_time < 30 then
    closest.x = (closest.x * closest.w + node.x)/(closest.w+1)
    closest.y = (closest.y * closest.w + node.y)/(closest.w+1)
    closest.w = closest.w + 1
    self.world_graph:DestroyNode(node)
    return closest
  else
    table.insert(z1, node)
    table.insert(z2, node)
    return node
  end
end

function QuestHelper:ResetPathing()
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
    local cont = zone_nodes[c]
    if not cont then cont = {} zone_nodes[c] = cont end
    local z = 1
    while select(z,GetMapZones(c)) do
      local zone = cont[z]
      if not zone then
        zone = {}
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
  
  
  for c, zone_list in pairs(QuestHelper_ZoneTransition) do
    for start, end_list in pairs(zone_list) do
      for dest, pos_list in pairs(end_list) do
        for i, pos in ipairs(pos_list) do
          self:CreateAndAddTransitionNode(zone_nodes[c][start], zone_nodes[c][dest], pos)
        end
      end
    end
  end
  
  for c, zone_list in pairs(QuestHelper_StaticData[self.locale].zone_transition) do
    for start, end_list in pairs(zone_list) do
      for dest, pos_list in pairs(end_list) do
        for i, pos in ipairs(pos_list) do
          self:CreateAndAddTransitionNode(zone_nodes[c][start], zone_nodes[c][dest], pos)
        end
      end
    end
  end
  
  -- Go through the flight masters and add nodes for them as well.
  if QuestHelper_FlightInstructors[self.faction] then
    for start, npc in pairs(QuestHelper_FlightInstructors[self.faction]) do
      local npc_objective = self:GetObjective("monster", npc)
      if (npc_objective.o.faction and npc_objective.o.faction == self.faction) or
         (npc_objective.fb.faction and npc_objective.fb.faction == self.faction) then
        local _
        
        if not flight_master_nodes[start] then
          -- The current node is invalid, but if we did have one, it means the objective already had
          -- a valid position assigned to it at some point, so we won't do it again.
          _, npc_objective.pos[1], npc_objective.pos[2], npc_objective.pos[3], npc_objective.pos[4] =
            npc_objective:Distance(self.c, self.z, self.x, self.y)
        end
        
        flight_master_nodes[start] = self:CreateAndAddZoneNode(zone_nodes[npc_objective.pos[1]][npc_objective.pos[2]], npc_objective.pos)
      end
    end
  end
  
  if QuestHelper_StaticData[self.locale].flight_instructors[self.faction] then
    for start, npc in pairs(QuestHelper_StaticData[self.locale].flight_instructors[self.faction]) do
      local npc_objective = self:GetObjective("monster", npc)
      if (npc_objective.o.faction and npc_objective.o.faction == self.faction) or
         (npc_objective.fb.faction and npc_objective.fb.faction == self.faction) then
        local _
        
        if not flight_master_nodes[start] then
          -- The current node is invalid, but if we did have one, it means the objective already had
          -- a valid position assigned to it at some point, so we won't do it again.
          _, npc_objective.pos[1], npc_objective.pos[2], npc_objective.pos[3], npc_objective.pos[4] =
            npc_objective:Distance(self.c, self.z, self.x, self.y)
        end
        
        flight_master_nodes[start] = self:CreateAndAddZoneNode(zone_nodes[npc_objective.pos[1]][npc_objective.pos[2]], npc_objective.pos)
      end
    end
  end
  
  function heuristic(a, b)
    local x = a.x-b.x
    local y = a.y-b.y
    return math.sqrt(x*x+y*y)
  end
  
  -- Will go through each zone and link all the nodes we have so far with every other node.
  for c=1,3 do
    local z = 1
    while select(z,GetMapZones(c)) do
      local list = zone_nodes[c][z]
      for i = 1,#list-1 do
        for j = i+1,#list do
          list[i]:Link(list[j], heuristic(list[i], list[j]))
          list[j]:Link(list[i], heuristic(list[j], list[i]))
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
  
  -- And if all went according to plan, we now have a graph we can follow to get from anywhere to anywhere.
end
