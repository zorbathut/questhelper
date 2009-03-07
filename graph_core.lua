QuestHelper_File["graph_core.lua"] = "Development Version"
QuestHelper_Loadtime["graph_core.lua"] = GetTime()

-- Alright so what's the interface here
-- There's the obvious "find a path from A to B"
-- function QH_Graph_Pathfind(st, nd, make_path)
-- Right now, we're pretending that the world consists of infinite planes with links between them. That's where the whole "between-zone" thing occurs. So one way or another, we need to add links. We'll use name as an identifier so we can get rid of flight paths links later, and the coords will include a plane ID number.
-- function QH_Graph_Plane_Makelink(name, coord1, coord2, cost)
-- And then we need a way to get rid of links, so:

local function xydist(st, nd)
  QuestHelper: Assert(st.p == nd.p)
  local dx, dy = st.x - nd.x, st.y - nd.y
  return math.sqrt(dx * dx + dy * dy)
end

function QH_Graph_Pathfind(st, nd, make_path)
  QuestHelper: Assert(not make_path)
  
  if st.p == nd.p then return xydist(st, nd) end
end

function QH_Graph_Plane_Makelink(name, coord1, coord2, cost)
end

function QH_Graph_Plane_Destroylinks(name)
end
