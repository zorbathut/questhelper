QuestHelper_File["pathfinding.lua"] = "Development Version"
QuestHelper_Loadtime["pathfinding.lua"] = GetTime()

local IRONFORGE_PORTAL = {25,0.255,0.084, "Ironforge portal site"}
local STORMWIND_CITY_PORTAL = QuestHelper_ConvertCoordsToWrath({36,0.387,0.802, "Stormwind City portal site"}, true)  -- Old pre-Wrath coordinates. I could fix it, but . . . meh.
local DARNASSUS_PORTAL = {21,0.397,0.824, "Darnassus portal site"}
local EXODAR_PORTAL = {12,0.476,0.598, "Exodar portal site"}

local SHATTRATH_CITY_PORTAL = {60,0.530,0.492, "Shattrath City portal site"}
local DALARAN_PORTAL = {67,0.500,0.394, "Dalaran portal site"}
local MOONGLADE_PORTAL = {20,0.563,0.320, "Moonglade portal site"}

local SILVERMOON_CITY_PORTAL = {52,0.583,0.192, "Silvermoon City portal site"}
local UNDERCITY_PORTAL = {45,0.846,0.163, "Undercity portal site"}
local ORGRIMMAR_PORTAL = {1,0.386,0.859, "Orgrimmar portal site"}
local THUNDER_BLUFF_PORTAL = {23,0.222,0.168, "Thunder Bluff portal site"}

local static_horde_routes = 
  {
   {{7, 0.505, 0.124}, {38, 0.313, 0.303}, 210}, -- Durotar <--> Grom'gol Base Camp
   {{38, 0.316, 0.289}, {43, 0.621, 0.591}, 210}, -- Grom'gol Base Camp <--> Tirisfal Glades
   {{43, 0.605, 0.587}, {7, 0.509, 0.141}, 210}, -- Tirisfal Glades <--> Durotar
   {{45, 0.549, 0.11}, {52, 0.495, 0.148}, 60}, -- Undercity <--> Silvermoon City
   
   {{7, 0.413, 0.178}, {65, 0.414, 0.536}, 210}, -- Durotar <--> Warsong Hold
   {{43, 0.591, 0.590}, {70, 0.777, 0.283}, 210}, -- Tirisfal Glades <--> Vengeance Landing
   
   {{60, 0.592, 0.483}, SILVERMOON_CITY_PORTAL, 60, true, nil, "SILVERMOON_CITY_PORTAL"}, -- Shattrath City --> Silvermoon City
   {{60, 0.528, 0.531}, THUNDER_BLUFF_PORTAL, 60, true, nil, "THUNDER_BLUFF_PORTAL"}, -- Shattrath City --> Thunder Bluff
   {{60, 0.522, 0.529}, ORGRIMMAR_PORTAL, 60, true, nil, "ORGRIMMAR_PORTAL"}, -- Shattrath City --> Orgrimmar
   {{60, 0.517, 0.525}, UNDERCITY_PORTAL, 60, true, nil, "UNDERCITY_PORTAL"}, -- Shattrath City --> Undercity
   
   {{67, 0.583, 0.216}, SILVERMOON_CITY_PORTAL, 60, true, nil, "SILVERMOON_CITY_PORTAL"}, -- Dalaran --> Silvermoon City
   {{67, 0.573, 0.219}, THUNDER_BLUFF_PORTAL, 60, true, nil, "THUNDER_BLUFF_PORTAL"}, -- Dalaran --> Thunder Bluff
   {{67, 0.553, 0.255}, ORGRIMMAR_PORTAL, 60, true, nil, "ORGRIMMAR_PORTAL"}, -- Dalaran --> Orgrimmar
   {{67, 0.556, 0.238}, UNDERCITY_PORTAL, 60, true, nil, "UNDERCITY_PORTAL"}, -- Dalaran --> Undercity
   {{67, 0.563, 0.226}, SHATTRATH_CITY_PORTAL, 60, true, nil, "SHATTRATH_CITY_PORTAL"}, -- Dalaran --> Shatt
  }

  
local static_alliance_routes = 
  {
   {{36, 0.639, 0.083}, {25, 0.764, 0.512}, 180}, -- Deeprun Tram
   {{10, 0.718, 0.565}, {51, 0.047, 0.636}, 210}, -- Theramore Isle <--> Menethil Harmor
   {{36, 0.228, 0.560}, {16, 0.323, 0.441}, 210}, -- Stormwind City <--> Auberdine
   
   {{36, 0.183, 0.255}, {65, 0.597, 0.694}, 210}, -- Stormwind City <--> Valiance Keep
   {{51, 0.047, 0.571}, {70, 0.612, 0.626}, 210}, -- Menethil <--> Daggercap Bay
   
   {{60, 0.558, 0.366}, STORMWIND_CITY_PORTAL, 60, true, nil, "STORMWIND_CITY_PORTAL"}, -- Shattrath City --> Stormwind City
   {{60, 0.563, 0.37}, IRONFORGE_PORTAL, 60, true, nil, "IRONFORGE_PORTAL"}, -- Shattrath City --> Ironforge
   {{60, 0.552, 0.364}, DARNASSUS_PORTAL, 60, true, nil, "DARNASSUS_PORTAL"}, -- Shattrath City --> Darnassus
   {{60, 0.596, 0.467}, EXODAR_PORTAL, 60, true, nil, "EXODAR_PORTAL"}, -- Shattrath City --> Exodar
   
   {{67, 0.401, 0.628}, STORMWIND_CITY_PORTAL, 60, true, nil, "STORMWIND_CITY_PORTAL"}, -- Dalaran --> Stormwind City
   {{67, 0.395, 0.640}, IRONFORGE_PORTAL, 60, true, nil, "IRONFORGE_PORTAL"}, -- Dalaran --> Ironforge
   {{67, 0.389, 0.651}, DARNASSUS_PORTAL, 60, true, nil, "DARNASSUS_PORTAL"}, -- Dalaran --> Darnassus
   {{67, 0.382, 0.664}, EXODAR_PORTAL, 60, true, nil, "EXODAR_PORTAL"}, -- Dalaran --> Exodar
   {{67, 0.371, 0.667}, SHATTRATH_CITY_PORTAL, 60, true, nil, "SHATTRATH_CITY_PORTAL"}, -- Dalaran --> Shatt
  }

local static_shared_routes = 
  {
   {{11, 0.638, 0.387}, {38, 0.257, 0.73}, 210}, -- Ratchet <--> Booty Bay
   {{40, 0.318, 0.503}, {32, 0.347, 0.84}, 130}, -- Burning Steppes <--> Searing Gorge
   
   -- More Alliance routes than anything, but without them theres no valid path to these areas for Horde characters.
   {{24, 0.559, 0.896}, {21, 0.305, 0.414}, 5}, -- Rut'Theran Village <--> Darnassus
   {{16, 0.332, 0.398}, {24, 0.548, 0.971}, 210}, -- Auberdine <--> Rut'Theran Village
   {{16, 0.306, 0.409}, {3, 0.2, 0.546}, 210}, -- Auberdine <--> Azuremyst Isle
   
   -- Route to new zone. Not valid, exists only to keep routing from exploding if you don't have the flight routes there.
   {{41, 0.5, 0.5}, {64, 0.5, 0.5}, 7200}, -- Eversong Woods <--> Sunwell
   
   {{70, 0.235, 0.578}, {68, 0.496, 0.784}, 210}, -- Kamagua <--> Moa'ki
   {{65, 0.789, 0.536}, {68, 0.480, 0.787}, 210}, -- Unu'pe <--> Moa'ki
   {{67, 0.559, 0.467}, {66, 0.158, 0.428}, 5, true}, -- Dalaran --> Violet Stand
   {{66, 0.157, 0.425}, {67, 0.559, 0.468}, 5, true}, -- Violent Stand --> Dalaran (slightly different coordinates, may be important once solid walls are in)
   
   {{34, 0.817, 0.461}, {78, 0.492, 0.312}, 86400}, -- EPL Ebon Hold <--> Scarlet Enclave Ebon Hold. Exists solely to fix some pathing crashes. 24-hour boat ride :D
  }

-- Darkportal is handled specially, depending on whether or not you're level 58+ or not.
local dark_portal_route = {{33, 0.587, 0.599}, {56, 0.898, 0.502}, 60}

local static_zone_transitions =
  {
   {2, 11, 0.687, 0.872}, -- Ashenvale <--> The Barrens
   {2, 6, 0.423, 0.711}, -- Ashenvale <--> Stonetalon Mountains
   {2, 15, 0.954, 0.484}, -- Ashenvale <--> Azshara
   {2, 16, 0.289, 0.144}, -- Ashenvale <--> Darkshore
   {2, 13, 0.557, 0.29}, -- Ashenvale <--> Felwood
   {21, 24, 0.894, 0.358}, -- Darnassus <--> Teldrassil
   {22, 11, 0.697, 0.604}, -- Mulgore <--> The Barrens
   {22, 23, 0.376, 0.33}, -- Mulgore <--> Thunder Bluff
   {22, 23, 0.403, 0.193}, -- Mulgore <--> Thunder Bluff
   {3, 12, 0.247, 0.494}, -- Azuremyst Isle <--> The Exodar
   {3, 12, 0.369, 0.469}, -- Azuremyst Isle <--> The Exodar
   {3, 12, 0.310, 0.487}, -- Azuremyst Isle <--> The Exodar
   {3, 12, 0.335, 0.494}, -- Azuremyst Isle <--> The Exodar
   {3, 9, 0.42, 0.013}, -- Azuremyst Isle <--> Bloodmyst Isle
   {4, 6, 0.539, 0.032}, -- Desolace <--> Stonetalon Mountains
   {4, 17, 0.428, 0.976}, -- Desolace <--> Feralas
   {5, 18, 0.865, 0.115}, -- Silithus <--> Un'Goro Crater
   {7, 11, 0.341, 0.424}, -- Durotar <--> The Barrens
   {7, 1, 0.455, 0.121}, -- Durotar <--> Orgrimmar
   {8, 18, 0.269, 0.516}, -- Tanaris <--> Un'Goro Crater
   {8, 14, 0.512, 0.21}, -- Tanaris <--> Thousand Needles
   {10, 11, 0.287, 0.472}, -- Dustwallow Marsh <--> The Barrens
   {10, 11, 0.563, 0.077}, -- Dustwallow Marsh <--> The Barrens
   {11, 14, 0.442, 0.915}, -- The Barrens <--> Thousand Needles
   {13, 19, 0.685, 0.06}, -- Felwood <--> Winterspring
   {13, 20, 0.669, -0.063}, -- Felwood <--> Moonglade
   {1, 11, 0.118, 0.69}, -- Orgrimmar <--> The Barrens
   {17, 14, 0.899, 0.46}, -- Feralas <--> Thousand Needles
   {6, 11, 0.836, 0.973}, -- Stonetalon Mountains <--> The Barrens
   {26, 48, 0.521, 0.7}, -- Alterac Mountains <--> Hillsbrad Foothills
   {26, 35, 0.173, 0.482}, -- Alterac Mountains <--> Silverpine Forest
   {26, 50, 0.807, 0.347}, -- Alterac Mountains <--> Western Plaguelands
   {39, 51, 0.454, 0.89}, -- Arathi Highlands <--> Wetlands
   {39, 48, 0.2, 0.293}, -- Arathi Highlands <--> Hillsbrad Foothills
   {27, 29, 0.49, 0.071}, -- Badlands <--> Loch Modan
   -- {27, 32, -0.005, 0.636}, -- Badlands <--> Searing Gorge  -- This is the "alliance-only" locked path, I'm disabling it for now entirely
   {33, 46, 0.519, 0.051}, -- Blasted Lands <--> Swamp of Sorrows
   {40, 30, 0.79, 0.842}, -- Burning Steppes <--> Redridge Mountains
   {47, 31, 0.324, 0.363}, -- Deadwind Pass <--> Duskwood
   {47, 46, 0.605, 0.41}, -- Deadwind Pass <--> Swamp of Sorrows
   {28, 25, 0.534, 0.349}, -- Dun Morogh <--> Ironforge
   {28, 29, 0.863, 0.514}, -- Dun Morogh <--> Loch Modan
   {28, 29, 0.844, 0.31}, -- Dun Morogh <--> Loch Modan
   {31, 37, 0.801, 0.158}, -- Duskwood <--> Elwynn Forest
   {31, 37, 0.15, 0.214}, -- Duskwood <--> Elwynn Forest
   {31, 38, 0.447, 0.884}, -- Duskwood <--> Stranglethorn Vale
   {31, 38, 0.209, 0.863}, -- Duskwood <--> Stranglethorn Vale
   {31, 30, 0.941, 0.103}, -- Duskwood <--> Redridge Mountains
   {31, 49, 0.079, 0.638}, -- Duskwood <--> Westfall
   {34, 50, 0.077, 0.661}, -- Eastern Plaguelands <--> Western Plaguelands
   {34, 44, 0.575, 0.000}, -- Eastern Plaguelands <--> Ghostlands
   {37, 36, 0.321, 0.493}, -- Elwynn Forest <--> Stormwind City   -- Don't need to convert because it's in Elwynn coordinates, not Stormwind coordinates
   {37, 49, 0.202, 0.804}, -- Elwynn Forest <--> Westfall
   {37, 30, 0.944, 0.724}, -- Elwynn Forest <--> Redridge Mountains
   {41, 52, 0.567, 0.494}, -- Eversong Woods <--> Silvermoon City
   {41, 44, 0.486, 0.916}, -- Eversong Woods <--> Ghostlands
   {35, 43, 0.678, 0.049}, -- Silverpine Forest <--> Tirisfal Glades
   {42, 50, 0.217, 0.264}, -- The Hinterlands <--> Western Plaguelands
   {43, 45, 0.619, 0.651}, -- Tirisfal Glades <--> Undercity
   {43, 50, 0.851, 0.703}, -- Tirisfal Glades <--> Western Plaguelands
   {38, 49, 0.292, 0.024}, -- Stranglethorn Vale <--> Westfall
   {48, 35, 0.137, 0.458}, -- Hillsbrad Foothills <--> Silverpine Forest
   {48, 42, 0.899, 0.253}, -- Hillsbrad Foothills <--> The Hinterlands
   {29, 51, 0.252, 0}, -- Loch Modan <--> Wetlands
   
   -- These are just guesses, since I haven't actually been to these areas.
   {58, 60, 0.783, 0.545}, -- Nagrand <--> Shattrath City
   {60, 55, 0.782, 0.492}, -- Shattrath City <--> Terokkar Forest
   {54, 59, 0.842, 0.284}, -- Blade's Edge Mountains <--> Netherstorm
   {54, 57, 0.522, 0.996}, -- Blade's Edge Mountains <--> Zangarmarsh
   {54, 57, 0.312, 0.94}, -- Blade's Edge Mountains <--> Zangarmarsh
   {56, 55, 0.353, 0.901}, -- Hellfire Peninsula <--> Terokkar Forest
   {56, 57, 0.093, 0.519}, -- Hellfire Peninsula <--> Zangarmarsh
   {58, 55, 0.8, 0.817}, -- Nagrand <--> Terokkar Forest
   {58, 57, 0.343, 0.159}, -- Nagrand <--> Zangarmarsh
   {58, 57, 0.754, 0.331}, -- Nagrand <--> Zangarmarsh
   {53, 55, 0.208, 0.271}, -- Shadowmoon Valley <--> Terokkar Forest
   {55, 57, 0.341, 0.098}, -- Terokkar Forest <--> Zangarmarsh
   
   -- Most of these are also guesses :)
   {65, 72, 0.547, 0.059}, -- Borean Tundra <--> Sholazar Basin
   {65, 68, 0.967, 0.359}, -- Borean Tundra <--> Dragonblight
   {74, 72, 0.208, 0.191}, -- Wintergrasp <--> Sholazar 
   {68, 74, 0.250, 0.410}, -- Dragonblight <--> Wintergrasp
   {68, 71, 0.359, 0.155}, -- Dragonblight <--> Icecrown
   {68, 66, 0.612, 0.142}, -- Dragonblight <--> Crystalsong
   {68, 75, 0.900, 0.200}, -- Dragonblight <--> Zul'Drak
   {68, 69, 0.924, 0.304}, -- Dragonblight <--> Grizzly Hills
   {68, 69, 0.931, 0.634}, -- Dragonblight <--> Grizzly Hills
   {70, 69, 0.540, 0.042}, -- Howling Fjord <--> Grizzly Hills
   {70, 69, 0.233, 0.074}, -- Howling Fjord <--> Grizzly Hills
   {70, 69, 0.753, 0.060}, -- Howling Fjord <--> Grizzly Hills
   {69, 75, 0.432, 0.253}, -- Grizzly Hills <--> Zul'Drak
   {69, 75, 0.583, 0.136}, -- Grizzly Hills <--> Zul'Drak
   {66, 75, 0.967, 0.599}, -- Crystalsong <--> Zul'Drak
   {66, 71, 0.156, 0.085}, -- Crystalsong <--> Icecrown
   {66, 73, 0.706, 0.315}, -- Crystalsong <--> Storm Peaks
   {66, 73, 0.839, 0.340}, -- Crystalsong <--> Storm Peaks
   {71, 73, 0.920, 0.767}, -- Icecrown <--> Storm Peaks
}

function load_graph_links()
  local function convert_coordinate(coord)
    QuestHelper: Assert(coord[1] and coord[2] and coord[3])
    local c, x, y = QuestHelper.Astrolabe:GetAbsoluteContinentPosition(QuestHelper_ZoneLookup[coord[1]][1], QuestHelper_ZoneLookup[coord[1]][2], coord[2], coord[3])
    return {x = x, y = y, p = coord[1]}
  end

  local function do_routes(routes)
    for _, v in ipairs(routes) do
      local src = convert_coordinate(v[1])
      local dst = convert_coordinate(v[2])
      QuestHelper: Assert(src and dst)
      QH_Graph_Plane_Makelink("static_route", src, dst, v[3], v[4]) -- this couldn't possibly fail
    end
  end
  
  local faction_db
  if UnitFactionGroup("player") == "Alliance" then
    faction_db = static_alliance_routes
  else
    faction_db = static_horde_routes
  end
  
  do_routes(faction_db)
  do_routes(static_shared_routes)
  
  for _, v in ipairs(static_zone_transitions) do
    local src = convert_coordinate({v[1], v[3], v[4]})
    local dst = convert_coordinate({v[1], v[3], v[4]})
    dst.p = v[2]
    QH_Graph_Plane_Makelink("static_transition", src, dst, 0, false)
  end
  
  do
    local src = convert_coordinate(dark_portal_route[1])
    local dst = convert_coordinate(dark_portal_route[2])
    QH_Graph_Plane_Makelink("dark_portal", src, dst, 15)
  end
end

-- pretty much everything after this is going to eventually end up eviscerated very, very soon

local walkspeed_multiplier = 1/7 -- Every yard walked takes this many seconds.

QuestHelper.prepared_objectives = {}
QuestHelper.named_nodes = {}

local function cont_dist(a, b)
  local x, y = a.x-b.x, a.y-b.y
  return math.sqrt(x*x+y*y)
end

function QuestHelper:ComputeRoute(p1, p2)
  for i in ipairs(p1[1]) do QuestHelper: Assert(p1[2][i], "p1 nil flightpath error resurgence!") end
  for i in ipairs(p2[1]) do QuestHelper: Assert(p2[2][i], "p2 nil flightpath error resurgence!") end

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
  for n in pairs(graph.open) do QuestHelper: Assert(nil, "not empty in preparesearch within computeroute") end
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

-- Let's annotate the hell out of this
-- ComputeTravelTime finds the shortest path between points p1 and p2. It will cheerfully use route boundaries, ships, etc. It returns the distance of that path, gleefully throwing away the path itself. Thanks, ComputeTravelTime! Thomputetraveltime. (That joke does not work as well in this case.)
-- ZORBANOTE: Given that Graph works properly, this does too! Almost - it doesn't actually keep track of the last leg when optimizing, though it does create a valid path with a valid cost. Yaaaaaaaay :(
function QuestHelper:ComputeTravelTime(p1, p2)
  if not p1 or not p2 then QuestHelper:Error("Boom!") end
  local graph = self.world_graph
  
  graph:PrepareSearch()
  
  local l = p2[2] -- Distance to zone boundaries in p2
  local el = p2[1] -- Zone object for the zone that p2 is in
  for i, n in ipairs(el) do -- i is the zone index, n is the zone data
    n.e, n.w = l[i], 1 -- n.e is distance from p2 to the current zone boundary, n.w is 1 (weight?)
    assert(n.e)
    n.s = 3 -- this is "state", I think it means "visited". TODO: untangle n.s and make it suck less than it currently does
  end
  
  l = p1[2] -- Distance to zone boundaries, again
  for i, n in ipairs(p1[1]) do
    graph:AddStartNode(n, l[i], el) -- We're adding start nodes - a prebuilt cost of the distance-to-that-zone. Each startnode also contains its own endlist, for reasons unknown yet byzantine. "n" is the zone link itself, l[i] is the cost that we still have stored. Why does this need to be in both n.e and AddStartNode?
  end
  
  local e = graph:DoSearch(el)
  
  assert(e)
  
  local d = e.g+e.e -- e.e is presumably the same n.e we introduced earlier. e.g - graph cost? wait a second - does this mean that the graph system is not taking e.e into account? ha ha no it isn't, oh boy oh boy
  
  if p1[1] == p2[1] then -- if they're in the same zone, we allow the user to walk from one point to another
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
    QuestHelper: Assert(QuestHelper_ZoneLookup[c[1]], "Zone couldn't be found, and should have been")
    local cont, zone = unpack(QuestHelper_ZoneLookup[c[1]])
    node.c = cont
    node.x, node.y = self.Astrolabe:TranslateWorldMapPosition(cont, zone, c[2], c[3], cont, 0)
    node.x = node.x * self.continent_scales_x[node.c]
    node.y = node.y * self.continent_scales_y[node.c]
    node.name = c[5] or QuestHelper_NameLookup[c[1]]
  end
  
  node.w = 1
  return node
end

function QuestHelper:CreateAndAddZoneNode(z, c, x, y)
  local node = self:CreateGraphNode(c, x, y)
  if not node then return end -- exception for Wrath changeover
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
    node1 = self:CreateAndAddZoneNode(self.zone_nodes[data[1][1]], data[1])
    if not node1 then return end -- exception for Wrath changeover
    if data[5] then self.named_nodes[data[5]] = node1 end
  end
  
  if data[6] and self.named_nodes[data[6]] then
    node2 = self.named_nodes[data[6]]
  else
    node2 = self:CreateAndAddZoneNode(self.zone_nodes[data[2][1]], data[2])
    if not node2 then return end -- exception for Wrath changeover
    if data[6] then self.named_nodes[data[6]] = node2 end
  end
  
  node1.name = node1.name or "route to "..QuestHelper_NameLookup[data[2][1]]
  node2.name = node2.name or "route to "..QuestHelper_NameLookup[data[1][1]]
  
  node1:Link(node2, data[3])
  
  if not data[4] then -- If data[4] is true, then this is a one-way trip.
    node2:Link(node1, data[3])
  end
  
  QH_Timeslice_Yield()
  return node1, node2
end

function QuestHelper:GetNodeByName(name, fallback_data)
  local node = self.named_nodes[name]
  if not node and fallback_data then
    node = self:CreateAndAddZoneNode(self.zone_nodes[fallback_data[1]], fallback_data)
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
  -- TODO: Need to have objectives not create links to unreachable nodes.
  return a ~= b
  --[[
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
    
    return false
  end]]
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
  QuestHelper: Assert(z1 and z2, "Zone couldn't be found, and should have been")
  
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
    QH_Timeslice_Yield()
    return closest
  else
    table.insert(z1, node)
    if z1 ~= z2 then table.insert(z2, node) end
    QH_Timeslice_Yield()
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
    
    local cache = o.distance_cache
    for k, v in pairs(cache) do
      self:ReleaseTable(v)
      cache[k] = nil
    end
    self:ReleaseTable(cache)
    
    o.d, o.p, o.nm, o.nm2, o.nl = nil, nil, nil, nil, nil
    o.distance_cache = nil
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
      -- Routing should reset the positions of objectives in the route after the reset is complete.
      o.pos = nil
      self:ReleaseObjectivePathingInfo(o)
      i = i + 1
    end
  end
  
  local to_readd = self.prepared_objectives
  self.prepared_objectives = self.old_prepared_objectives or {}
  self.old_prepared_objectives = to_readd
  
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
  QH_Timeslice_Yield()
  
  local continent_scales_x, continent_scales_y = self.continent_scales_x, self.continent_scales_y
  if not continent_scales_x then
    continent_scales_x = {}
    continent_scales_y = {}
    self.continent_scales_x = continent_scales_x
    self.continent_scales_y = continent_scales_y
  end
  
  for c in pairs(self.Astrolabe:GetMapVirtualContinents()) do
    if not continent_scales_x[c] then
      local _, x, y = self.Astrolabe:ComputeDistance(c, 0, 0.25, 0.25, c, 0, 0.75, 0.75)
      
      continent_scales_x[c] = x*walkspeed_multiplier*2
      continent_scales_y[c] = y*walkspeed_multiplier*2
    end
  end
  
  for i, name in pairs(QuestHelper_NameLookup) do
    local z = zone_nodes[i]
    if not z then
      z = QuestHelper:CreateTable("zone")  -- This was originally z = {}. I'm pretty sure that the CreateTable/ReleaseTable system is (largely) immune to leaks, and I'm also pretty sure that zones are only created once, at the beginning of the system. Keep this in mind if leaks start occuring.
      zone_nodes[i] = z
      z.i, z.c, z.z = i, unpack(QuestHelper_ZoneLookup[i])
    else
      for key in pairs(z) do
        z[key] = nil
      end
      z.i, z.c, z.z = i, unpack(QuestHelper_ZoneLookup[i])
    end
  end
  
  self:SetupTeleportInfo(self.teleport_info, true)
  QH_Timeslice_Yield()
  
  --[[for node, info in pairs(self.teleport_info.node) do
    self:TextOut("You can teleport to "..(node.name or "nil").. " in "..self:TimeString(info[1]+info[2]-GetTime()))
  end]]
  
  if self.faction == 1 then
    for i, data in ipairs(static_alliance_routes) do
      self:CreateAndAddStaticNodePair(data)
    end
  elseif self.faction == 2 then
    for i, data in ipairs(static_horde_routes) do
      self:CreateAndAddStaticNodePair(data)
    end
  end
  
  for i, data in ipairs(static_shared_routes) do
    self:CreateAndAddStaticNodePair(data)
  end
  
  if self.player_level >= 58 then
    dark_portal_route[3] = 5
  else
    -- If you can't take the route yet, we'll still add it and just pretend it will take a really long time.
    dark_portal_route[3] = 86400
  end
  
  self:CreateAndAddStaticNodePair(dark_portal_route)
  
  local st = self:CreateTable("ResetPathing local st")
  
  for i, data in pairs(static_zone_transitions) do
    st[1], st[2], st[3] = data[1], data[3], data[4]
    
    local transnode = self:CreateAndAddTransitionNode(zone_nodes[data[1]],
                                    zone_nodes[data[2]],
                                    st)
    if transnode then transnode.name = QHFormat("ZONE_BORDER", QuestHelper_NameLookup[data[1]], QuestHelper_NameLookup[data[2]]) end -- if the transition node wasn't creatable, we obviously can't name it
  end
  
  self:ReleaseTable(st)
  
  -- Create and link the flight route nodes.
  local flight_times = self.flight_times
  if not flight_times then
    self:buildFlightTimes()
    flight_times = self.flight_times
  end
  
  for start, list in pairs(flight_times) do
    for dest, duration in pairs(list) do
      local a_npc, b_npc = self:getFlightInstructor(start), self:getFlightInstructor(dest)
      
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
          a:Link(b, duration+5)
        end
      end
    end
    QH_Timeslice_Yield()
  end
  
  -- id_from, id_to, and id_local will be used in determining whether there is a point to linking nodes together.
  for i, n in ipairs(self.world_graph.nodes) do
    n.id_from = self:CreateTable("ResetPathing n.id_from")
    n.id_to = self:CreateTable("ResetPathing n.id_to")
    n.id_local = self:CreateTable("ResetPathing n.id_local")
  end
  
  -- Setup the local ids a node exists in.
  for i, list in pairs(zone_nodes) do
    for _, n in ipairs(list) do
      n.id_local[i] = true
      n.id_to[i] = true
      n.id_from[i] = true
    end
  end
  
  -- Figure out where each node can come from or go to.
  for i, list in pairs(zone_nodes) do
    for _, node in ipairs(list) do
      for n in pairs(node.n) do
        for id in pairs(n.id_local) do node.id_to[id] = true end
        for id in pairs(node.id_local) do n.id_from[id] = true end
      end
    end
  end
  
  -- We'll treat 0 as a special id for where ever it is the player happens to be.
  for node in pairs(self.teleport_info.node) do
    node.id_from[0] = true
  end
  
  -- Will go through each zone and link all the nodes we have so far with every other node.
  for _, list in pairs(zone_nodes) do
    for i = 1,#list do
      for j = 1,#list do
        if shouldLink(list[i], list[j]) then
          list[i]:Link(list[j], cont_dist(list[i], list[j]))
        end
      end
    end
  end
  
  QH_Timeslice_Yield()

  -- We don't need to know where the nodes can go or come from now.
  for i, n in ipairs(self.world_graph.nodes) do
    self:ReleaseTable(n.id_from)
    self:ReleaseTable(n.id_to)
    self:ReleaseTable(n.id_local)
    n.id_from, n.id_to, n.id_local = nil, nil, nil
  end
  
  -- TODO: This is a work around until I fix shouldLink
  for start, list in pairs(flight_times) do
    for dest, duration in pairs(list) do
      local a, b = flight_master_nodes[start], flight_master_nodes[dest]
      if a and b then
        a:Link(b, duration+5)
      end
    end
  end
  
  QH_Timeslice_Yield()
  -- self.world_graph:SanityCheck()
  
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
      obj.d = QuestHelper:CreateTable("ResetPathing obj.d")
      obj.p = QuestHelper:CreateTable("ResetPathing obj.p")
      obj.nm = QuestHelper:CreateTable("ResetPathing obj.nm")
      obj.nm2 = QuestHelper:CreateTable("ResetPathing obj.nm2")
      obj.nl = QuestHelper:CreateTable("ResetPathing obj.nl")
      obj.distance_cache = QuestHelper:CreateTable("ResetPathing obj.distance_cache")
      obj:AppendPositions(obj, 1, nil)
      obj:FinishAddLoc()
    end
  end
  
  if self.i then
    self.pos[1] = self.zone_nodes[self.i]
    for i, n in ipairs(self.pos[1]) do
      local a, b = n.x-self.pos[3], n.y-self.pos[4]
      self.pos[2][i] = math.sqrt(a*a+b*b)
    end
  end
  
  -- And if all went according to plan, we now have a graph we can follow to get from anywhere to anywhere.
  
  if self.graph_walker then
    self.graph_walker:GraphChanged()
  end
end


function QuestHelper:Disallowed(index)
  return QuestHelper_RestrictedZones[index] ~= QuestHelper_RestrictedZones[self.i]
end
