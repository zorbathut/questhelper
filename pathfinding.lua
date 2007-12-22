local IRONFORGE_PORTAL = {2,14,0.255,0.084, "Ironforge portal site"}
local STORMWIND_CITY_PORTAL = {2,20,0.387,0.802, "Stormwind City portal site"}
local DARNASSUS_PORTAL = {1,6,0.397,0.824, "Darnassus portal site"}
local EXODAR_PORTAL = {1,20,0.476,0.598, "Exodar portal site"}

local SHATTRATH_CITY_PORTAL = {3,6,0.530,0.492, "Shattrath City portal site"}
local MOONGLADE_PORTAL = {1,12,0.563,0.320, "Moonglade portal site"}

local SILVERMOON_CITY_PORTAL = {2,18,0.583,0.192, "Silvermoon City portal site"}
local UNDERCITY_PORTAL = {2,25,0.846,0.163, "Undercity portal site"}
local ORGRIMMAR_PORTAL = {1,14,0.386,0.859, "Orgrimmar portal site"}
local THUNDER_BLUFF_PORTAL = {1,22,0.222,0.168, "Thunder Bluff portal site"}

local static_horde_routes = 
  {
   {{1,8,0.505,0.124}, {2,21,0.313,0.303}, 210}, -- Durotar <--> Grom'gol Base Camp
   {{2,21,0.316,0.289}, {2,24,0.621,0.591}, 210}, -- Grom'gol Base Camp <--> Tirisfal Glades
   {{2,24,0.605,0.587}, {1,8,0.509,0.141}, 210}, -- Tirisfal Glades <--> Durotar
   {{2,25,0.549,0.110}, {2,18,0.495,0.148}, 5}, -- Undercity <--> Silvermoon City
   
   {{3,6,0.592,0.483}, SILVERMOON_CITY_PORTAL, 5, true, nil, "SILVERMOON_CITY_PORTAL"}, -- Shattrath City <--> Silvermoon City
   {{3,6,0.528,0.531}, THUNDER_BLUFF_PORTAL, 5, true, nil, "THUNDER_BLUFF_PORTAL"}, -- Shattrath City <--> Thunder Bluff
   {{3,6,0.522,0.529}, ORGRIMMAR_PORTAL, 5, true, nil, "ORGRIMMAR_PORTAL"}, -- Shattrath City <--> Orgrimmar
   {{3,6,0.517,0.525}, UNDERCITY_PORTAL, 5, true, nil, "UNDERCITY_PORTAL"} -- Shattrath City <--> Undercity
  }

local static_alliance_routes = 
  {
   {{2,20,0.639,0.083}, {2,14,0.764,0.512}, 120}, -- Deeprun Tram
   {{2,28,0.044,0.569}, {1,5,0.323,0.441}, 210}, --Menethil Harbor <--> Auberdine
   {{1,9,0.718,0.565}, {2,28,0.047,0.636}, 210}, -- Theramore Isle <--> Menethil Harmor
   
   {{3,6,0.558,0.366}, STORMWIND_CITY_PORTAL, 5, true, nil, "STORMWIND_CITY_PORTAL"}, -- Shattrath City <--> Stormwind City
   {{3,6,0.563,0.370}, IRONFORGE_PORTAL, 5, true, nil, "IRONFORGE_PORTAL"}, -- Shattrath City <--> Ironforge
   {{3,6,0.552,0.364}, DARNASSUS_PORTAL, 5, true, nil, "DARNASSUS_PORTAL"}, -- Shattrath City <--> Darnassus
   {{3,6,0.596,0.467}, EXODAR_PORTAL, 5, true, nil, "EXODAR_PORTAL"} -- Shattrath City <--> Exodar
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
   {1, 1, 19, 0.687, 0.872}, -- Ashenvale <--> The Barrens
   {1, 1, 16, 0.423, 0.711}, -- Ashenvale <--> Stonetalon Mountains
   {1, 1, 2, 0.954, 0.484}, -- Ashenvale <--> Azshara
   {1, 1, 5, 0.289, 0.144}, -- Ashenvale <--> Darkshore
   {1, 1, 10, 0.557, 0.290}, -- Ashenvale <--> Felwood
   {1, 6, 18, 0.894, 0.358}, -- Darnassus <--> Teldrassil
   {1, 13, 19, 0.697, 0.604}, -- Mulgore <--> The Barrens
   {1, 13, 22, 0.376, 0.330}, -- Mulgore <--> Thunder Bluff
   {1, 3, 20, 0.247, 0.494}, -- Azuremyst Isle <--> The Exodar
   {1, 3, 20, 0.369, 0.469}, -- Azuremyst Isle <--> The Exodar
   {1, 3, 4, 0.420, 0.013}, -- Azuremyst Isle <--> Bloodmyst Isle
   {1, 7, 16, 0.539, 0.032}, -- Desolace <--> Stonetalon Mountains
   {1, 7, 11, 0.428, 0.976}, -- Desolace <--> Feralas
   {1, 15, 23, 0.865, 0.115}, -- Silithus <--> Un'Goro Crater
   {1, 8, 19, 0.341, 0.424}, -- Durotar <--> The Barrens
   {1, 8, 14, 0.455, 0.121}, -- Durotar <--> Orgrimmar
   {1, 17, 23, 0.269, 0.516}, -- Tanaris <--> Un'Goro Crater
   {1, 17, 21, 0.512, 0.210}, -- Tanaris <--> Thousand Needles
   {1, 9, 19, 0.287, 0.472}, -- Dustwallow Marsh <--> The Barrens
   {1, 9, 19, 0.563, 0.077}, -- Dustwallow Marsh <--> The Barrens
   {1, 19, 21, 0.442, 0.915}, -- The Barrens <--> Thousand Needles
   {1, 10, 24, 0.685, 0.060}, -- Felwood <--> Winterspring
   {1, 10, 12, 0.669, -0.063}, -- Felwood <--> Moonglade
   {1, 14, 19, 0.118, 0.690}, -- Orgrimmar <--> The Barrens
   {1, 11, 21, 0.899, 0.460}, -- Feralas <--> Thousand Needles
   {1, 16, 19, 0.836, 0.973}, -- Stonetalon Mountains <--> The Barrens
   {2, 1, 13, 0.521, 0.700}, -- Alterac Mountains <--> Hillsbrad Foothills
   {2, 1, 19, 0.173, 0.482}, -- Alterac Mountains <--> Silverpine Forest
   {2, 1, 26, 0.807, 0.347}, -- Alterac Mountains <--> Western Plaguelands
   {2, 2, 28, 0.454, 0.890}, -- Arathi Highlands <--> Wetlands
   {2, 2, 13, 0.200, 0.293}, -- Arathi Highlands <--> Hillsbrad Foothills
   {2, 3, 15, 0.490, 0.071}, -- Badlands <--> Loch Modan
   {2, 3, 17, -0.005, 0.636}, -- Badlands <--> Searing Gorge
   {2, 4, 22, 0.519, 0.051}, -- Blasted Lands <--> Swamp of Sorrows
   {2, 5, 16, 0.790, 0.842}, -- Burning Steppes <--> Redridge Mountains
   {2, 6, 8, 0.324, 0.363}, -- Deadwind Pass <--> Duskwood
   {2, 6, 22, 0.605, 0.410}, -- Deadwind Pass <--> Swamp of Sorrows
   {2, 7, 14, 0.534, 0.349}, -- Dun Morogh <--> Ironforge
   {2, 7, 15, 0.863, 0.514}, -- Dun Morogh <--> Loch Modan
   {2, 7, 15, 0.844, 0.310}, -- Dun Morogh <--> Loch Modan
   {2, 8, 10, 0.801, 0.158}, -- Duskwood <--> Elwynn Forest
   {2, 8, 10, 0.150, 0.214}, -- Duskwood <--> Elwynn Forest
   {2, 8, 21, 0.447, 0.884}, -- Duskwood <--> Stranglethorn Vale
   {2, 8, 21, 0.209, 0.863}, -- Duskwood <--> Stranglethorn Vale
   {2, 8, 16, 0.941, 0.103}, -- Duskwood <--> Redridge Mountains
   {2, 8, 27, 0.079, 0.638}, -- Duskwood <--> Westfall
   {2, 9, 26, 0.107, 0.726}, -- Eastern Plaguelands <--> Western Plaguelands
   {2, 9, 12, 0.625, 0.030}, -- Eastern Plaguelands <--> Ghostlands
   {2, 10, 20, 0.321, 0.493}, -- Elwynn Forest <--> Stormwind City
   {2, 10, 27, 0.202, 0.804}, -- Elwynn Forest <--> Westfall
   {2, 10, 16, 0.944, 0.724}, -- Elwynn Forest <--> Redridge Mountains
   {2, 11, 18, 0.567, 0.494}, -- Eversong Woods <--> Silvermoon City
   {2, 11, 12, 0.486, 0.916}, -- Eversong Woods <--> Ghostlands
   {2, 19, 24, 0.678, 0.049}, -- Silverpine Forest <--> Tirisfal Glades
   {2, 23, 26, 0.217, 0.264}, -- The Hinterlands <--> Western Plaguelands
   {2, 24, 25, 0.619, 0.651}, -- Tirisfal Glades <--> Undercity
   {2, 24, 26, 0.851, 0.703}, -- Tirisfal Glades <--> Western Plaguelands
   {2, 21, 27, 0.292, 0.024}, -- Stranglethorn Vale <--> Westfall
   {2, 13, 19, 0.137, 0.458}, -- Hillsbrad Foothills <--> Silverpine Forest
   {2, 13, 23, 0.899, 0.253}, -- Hillsbrad Foothills <--> The Hinterlands
   {2, 15, 28, 0.252, 0.000}, -- Loch Modan <--> Wetlands
   {3, 3, 6, 0.783, 0.545}, -- Nagrand <--> Shattrath City
   {3, 6, 7, 0.782, 0.492}, -- Shattrath City <--> Terokkar Forest
   
   -- These are just guesses, since I haven't actually been to these areas.
   
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
QuestHelper.named_nodes = {}

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

function QuestHelper:CreateGraphNode(c, x, y, n)
  local node = self.world_graph:CreateNode()
  
  if y then
    node.c = c
    node.x = x
    node.y = y
    node.name = n
  else
    node.c = c[1]
    node.x, node.y = self.Astrolabe:TranslateWorldMapPosition(c[1], c[2], c[3], c[4], c[1], 0)
    node.x = node.x * self.continent_scales_x[node.c]
    node.y = node.y * self.continent_scales_y[node.c]
    node.name = c[5] or select(c[2], GetMapZones(c[1]))
  end
  
  node.w = 1
  return node
end

function QuestHelper:CreateAndAddZoneNode(z, c, x, y)
  local node = self:CreateGraphNode(c, x, y)
  
  -- Not going to merge nodes.
  --[[local closest, travel_time = nil, 0
  
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
  else]]
    table.insert(z, node)
    return node
  --end
end

function QuestHelper:CreateAndAddStaticNodePair(data)
  local node1, node2
  
  if data[5] and self.named_nodes[data[5]] then
    node1 = self.named_nodes[data[5]]
  else
    node1 = self:CreateAndAddZoneNode(self.zone_nodes[data[1][1]][data[1][2]], data[1])
    if data[5] then self.named_nodes[data[5]] = node1 end
  end
  
  if data[6] and self.named_nodes[data[6]] then
    node2 = self.named_nodes[data[6]]
  else
    node2 = self:CreateAndAddZoneNode(self.zone_nodes[data[2][1]][data[2][2]], data[2])
    if data[6] then self.named_nodes[data[6]] = node2 end
  end
  
  node1.name = node1.name or "route to "..select(data[2][2], GetMapZones(data[2][1]))
  node2.name = node2.name or "route to "..select(data[1][2], GetMapZones(data[1][1]))
  
  node1:Link(node2, data[3])
  
  if not data[4] then -- If data[4] is true, then this is a one-way trip.
    node2:Link(node1, data[3])
  end
  
  return node1, node2
end

function QuestHelper:GetNodeByName(name, fallback_data)
  local node = self.named_nodes[name]
  if not node and fallback_data then
    node = self:CreateAndAddZoneNode(self.zone_nodes[fallback_data[1]][fallback_data[2]], fallback_data)
    self.named_nodes[name] = node
  end
  return node
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

local function shouldLink(a, b)
  if a == b then
    return false
  else
    for id in pairs(a.id_from) do
      if not b.id_to[id] then
        for id in pairs(b.id_to) do
          if not a.id_from[id] then
            return true
          end
        end
      end
    end
    
    --if not next(a.id_from, nil) then
    --  return false
    --end
    
    --for id in pairs(b.id_to) do
    --  if not a.id_from[id] then
    --    return true
    --  end
    --end
    return false
  end
end

local function getNPCNode(npc)
  local npc_objective = QuestHelper:GetObjective("monster", npc)
  if npc_objective:Known() then
    npc_objective:PrepareRouting()
    local p = npc_objective:Position()
    local node = nil
    
    if p then
      node = QuestHelper:CreateAndAddZoneNode(p[1], p[1].c, p[3], p[4])
    end
    
    npc_objective:DoneRouting()
    return node
  end
  return nil
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

function QuestHelper:ReleaseObjectivePathingInfo(o)
  if o.setup then
    for z, pl in pairs(o.p) do
      self:ReleaseTable(o.d[z])
      
      for i, p in ipairs(pl) do
        self:ReleaseTable(p[2])
        self:ReleaseTable(p)
      end
      
      self:ReleaseTable(pl)
    end
    
    self:ReleaseTable(o.d)
    self:ReleaseTable(o.p)
    self:ReleaseTable(o.nm)
    self:ReleaseTable(o.nm2)
    self:ReleaseTable(o.nl)
    
    o.d, o.p, o.nm, o.nm2, o.nl = nil, nil, nil, nil, nil
    o.pos, o.sop = nil, nil -- ResetPathing will preserve these values if needed.
    o.setup = nil
  end
end

function QuestHelper:SetupTeleportInfo(info, can_create)
  self:TeleportInfoClear(info)
  
  if QuestHelper_Home then
    local node = self:GetNodeByName("HOME_PORTAL", can_create and QuestHelper_Home)
    if node then
      local cooldown = self:ItemCooldown(6948)
      if cooldown then
        self:SetTeleportInfoTarget(info, node, GetTime()-60*60+cooldown, 60*60, 10)
      end
    else
      self.defered_graph_reset = true
    end
  end
  
  -- TODO: Compact this. . . and find a better way to tell if the player has a spell.
  
  if GetSpellTexture("Teleport: Darnassus") then
    local node = self:GetNodeByName("DARNASSUS_PORTAL", can_create and DARNASSUS_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Exodar") then
    local node = self:GetNodeByName("EXODAR_PORTAL", can_create and EXODAR_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Ironforge") then
    local node = self:GetNodeByName("IRONFORGE_PORTAL", can_create and IRONFORGE_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Moonglade") then
    local node = self:GetNodeByName("MOONGLADE_PORTAL", can_create and MOONGLADE_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Orgrimmar") then
    local node = self:GetNodeByName("ORGRIMMAR_PORTAL", can_create and ORGRIMMAR_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Shattrath") then
    local node = self:GetNodeByName("SHATTRATH_CITY_PORTAL", can_create and SHATTRATH_CITY_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Silvermoon") then
    local node = self:GetNodeByName("SILVERMOON_CITY_PORTAL", can_create and SILVERMOON_CITY_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Stormwind") then
    local node = self:GetNodeByName("STORMWIND_CITY_PORTAL", can_create and STORMWIND_CITY_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Thunder Bluff") then
    local node = self:GetNodeByName("THUNDER_BLUFF_PORTAL", can_create and THUNDER_BLUFF_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  if GetSpellTexture("Teleport: Undercity") then
    local node = self:GetNodeByName("UNDERCITY_PORTAL", can_create and UNDERCITY_PORTAL)
    if node then self:SetTeleportInfoTarget(info, node, 0, 0, 10, 17031) else self.defered_graph_reset = true end
  end
  
  self:SetTeleportInfoReagent(info, 17031, self:CountItem(17031))
end

function QuestHelper:ResetPathing()
  for key in pairs(self.named_nodes) do
    self.named_nodes[key] = nil
  end
  
  -- Objectives may include cached information that depends on the world graph.
  local i = 1
  
  while i <= #self.prepared_objectives do
    local o = self.prepared_objectives[i]
    
    if o.setup_count == 0 then
      table.remove(self.prepared_objectives, i)
      self:ReleaseObjectivePathingInfo(o)
    else
      if o.pos then
        o.old_pos = self:CreateTable()
        o.old_pos[1], o.old_pos[2], o.old_pos[3] = o.pos[1].c, o.pos[3], o.pos[4]
      end
      
      if o.sop then
        o.old_sop = self:CreateTable()
        o.old_sop[1], o.old_sop[2], o.old_sop[3] = o.sop[1].c, o.sop[3], o.sop[4]
      end
      
      self:ReleaseObjectivePathingInfo(o)
      i = i + 1
    end
  end
  
  local to_readd = self.prepared_objectives
  self.prepared_objectives = self.old_prepared_objectives or {}
  self.old_prepared_objectives = to_readd
  
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
  else
    for key in pairs(flight_master_nodes) do
      flight_master_nodes[key] = nil
    end
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
  
  self:SetupTeleportInfo(self.teleport_info, true)
  
  for node, info in pairs(self.teleport_info.node) do
    self:TextOut("You can teleport to "..(node.name or "nil").. " in "..self:TimeString(info[1]+info[2]-GetTime()))
  end
  
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
    self.scratch_table[1], self.scratch_table[2], self.scratch_table[3], self.scratch_table[4] = data[1], data[2], data[4], data[5]
    
    self:CreateAndAddTransitionNode(zone_nodes[data[1]][data[2]],
                                    zone_nodes[data[1]][data[3]],
                                    self.scratch_table).name = select(data[2],GetMapZones(data[1])).."/"..select(data[3],GetMapZones(data[1])).." border"
  end
  
  while table.remove(self.scratch_table) do end
  
  -- Create and link the flight route nodes.
  for c, start_list in pairs(QuestHelper_KnownFlightRoutes) do
    local local_fi = QuestHelper_FlightInstructors[self.faction]
    local static_fi = QuestHelper_StaticData[self.locale].flight_instructors[self.faction]
    for start, end_list in pairs(start_list) do
      for dest in pairs(end_list) do
        local a_npc, b_npc = local_fi[start] or static_fi[start], local_fi[dest], static_fi[dest]
        
        if a_npc and b_npc then
          local a, b = flight_master_nodes[start], flight_master_nodes[dest]
          
          if not a then
            a = getNPCNode(a_npc)
            if a then
              flight_master_nodes[start] = a
              a.name = (select(3, string.find(start, "^(.*),")) or start).." flight point"
            end
          end
          
          if not b then
            b = getNPCNode(b_npc)
            if b then
              flight_master_nodes[dest] = b
              b.name = (select(3, string.find(dest, "^(.*),")) or dest).." flight point"
            end
          end
          
          if a and b then
            a:Link(b, self:GetFlightTime(c, start, dest))
          else
            self:TextOut("Can't link!")
          end
        end
      end
    end
  end
  
  -- id_from, id_to, and id_local will be used in determining whether there is a point to linking nodes together.
  for i, n in ipairs(self.world_graph.nodes) do
    n.id_from = self:CreateTable()
    n.id_to = self:CreateTable()
    n.id_local = self:CreateTable()
  end
  
  -- Setup the local ids a node exists in.
  for c=1,3 do
    local z = 1
    while select(z,GetMapZones(c)) do
      local list = zone_nodes[c][z]
      for i, n in ipairs(list) do
        n.id_local[z+c*100] = true
        n.id_to[z+c*100] = true
        n.id_from[z+c*100] = true
      end
      z = z + 1
    end
  end
  
  -- Figure out where each node can come from or go to.
  for c=1,3 do
    local z = 1
    while select(z,GetMapZones(c)) do
      local list = zone_nodes[c][z]
      for _, node in ipairs(list) do
        for n in pairs(node.n) do
          for id in pairs(n.id_local) do node.id_to[id] = true end
          for id in pairs(node.id_local) do n.id_from[id] = true end
        end
      end
      z = z + 1
    end
  end
  
  -- We'll treat 0 as a special id for where ever it is the player happens to be.
  for node in pairs(self.teleport_info.node) do
    node.id_from[0] = true
  end
  
  -- Will go through each zone and link all the nodes we have so far with every other node.
  for c=1,3 do
    local z = 1
    while select(z,GetMapZones(c)) do
      local list = zone_nodes[c][z]
      for i = 1,#list do
        for j = 1,#list do
          if shouldLink(list[i], list[j]) then
            list[i]:Link(list[j], same_cont_heuristic(list[i], list[j]))
          end
        end
      end
      z = z + 1
    end
  end
  
  -- We don't need to know where the nodes can go or come from now.
  for i, n in ipairs(self.world_graph.nodes) do
    self:ReleaseTable(n.id_from)
    self:ReleaseTable(n.id_to)
    self:ReleaseTable(n.id_local)
    n.id_from, n.id_to, n.id_local = nil, nil, nil
  end
  
  -- TODO: Create a heuristic for this.
  --[[
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
  ]]
  -- self.world_graph:SanityCheck()
  
  -- TODO: heuristic returns NaNs, fix this.
  --self.world_graph:SetHeuristic(heuristic)
  
  -- Remove objectives again, since we created some for the flight masters.
  while true do
    local o = table.remove(self.prepared_objectives)
    if not o then break end
    
    self:ReleaseObjectivePathingInfo(o)
    
    if o.setup_count > 0 then
      -- There's a chance an objective could end up in the list twice, but we'll deal with that by not actually
      -- adding locations for it if it's already setup.
      table.insert(to_readd, o)
    end
  end
  
  while true do
    local obj = table.remove(to_readd)
    if not obj then break end
    
    if not obj.setup then -- In case the objective was added multiple times to the to_readd list.
      obj.d = QuestHelper:CreateTable()
      obj.p = QuestHelper:CreateTable()
      obj.nm = QuestHelper:CreateTable()
      obj.nm2 = QuestHelper:CreateTable()
      obj.nl = QuestHelper:CreateTable()
      obj:AppendPositions(obj, 1, nil)
      obj:FinishAddLoc()
      
      -- Make sure the objectives still contain the positions set by routing.
      -- The might have shifted slightly, but there's not much I can do about that.
      
      if obj.old_pos then
        local p, d = nil, 0
        
        for z, pl in pairs(obj.p) do
          for i, point in ipairs(pl) do
            if obj.old_pos[1] == point[1].c then
              local x, y = obj.old_pos[2]-point[3], obj.old_pos[3]-point[4]
              local d2 = x*x+y*y
              if not p or d2 < d then
                p, d = point, d2
              end
            end
          end
        end
        
        assert(p)
        
        obj.pos = p
        self:ReleaseTable(obj.old_pos)
        obj.old_pos = nil
      end
      
      if obj.old_sop then
        local p, d = nil, 0
        
        for z, pl in pairs(obj.p) do
          for i, point in ipairs(pl) do
            if obj.old_sop[1] == point[1].c then
              local x, y = obj.old_sop[2]-point[3], obj.old_sop[3]-point[4]
              local d2 = x*x+y*y
              if not p or d2 < d then
                p, d = point, d2
              end
            end
          end
        end
        
        assert(p)
        
        obj.sop = p
        self:ReleaseTable(obj.old_sop)
        obj.old_sop = nil
      end
    end
  end
  
  -- And if all went according to plan, we now have a graph we can follow to get from anywhere to anywhere.
  
  if self.graph_walker then
    self.graph_walker:GraphChanged()
  end
end
