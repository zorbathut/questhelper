QuestHelper_File["graph_core.lua"] = "Development Version"
QuestHelper_Loadtime["graph_core.lua"] = GetTime()

-- Alright so what's the interface here
-- There's the obvious "find a path from A to B"
-- function QH_Graph_Pathfind(st, nd, make_path)
-- Right now, we're pretending that the world consists of infinite planes with links between them. That's where the whole "between-zone" thing occurs. So one way or another, we need to add links. We'll use name as an identifier so we can get rid of flight paths links later, and the coords will include a plane ID number.
-- function QH_Graph_Plane_Makelink(name, coord1, coord2, cost)
-- And then we need a way to get rid of links, so:

-- how does flying work zorba
-- how can we fly
-- howwwwww

-- Make a map from "phase" to "flyphase". Store all the links we're being told to make. When placing links, if the flyphase is flyable, we use the flyphase instead of the phase for placing. We don't place if it's an internal boundary (there's a few ways we can detect this, but let's just use the hacky one where we just look at the ID.) From there it's all pretty standard.

local QH_Timeslice_Yield = QH_Timeslice_Yield -- performance hack :(

local function heap_left(x) return (2*x) end
local function heap_right(x) return (2*x + 1) end

local function heap_sane(heap)
  local dmp = ""
  local finishbefore = 2
  for i = 1, #heap do
    if i == finishbefore then
      print(dmp)
      dmp = ""
      finishbefore = finishbefore * 2
    end
    dmp = dmp .. string.format("%f ", heap[i].c)
  end
  print(dmp)
  print("")
  for i = 1, #heap do
    assert(not heap[heap_left(i)] or heap[i].c <= heap[heap_left(i)].c)
    assert(not heap[heap_right(i)] or heap[i].c <= heap[heap_right(i)].c)
  end
end

local function heap_insert(heap, item)
  assert(item)
  table.insert(heap, item)
  local pt = #heap
  while pt > 1 do
    local ptd2 = math.floor(pt / 2)
    if heap[ptd2].c <= heap[pt].c then
      break
    end
    local tmp = heap[pt]
    heap[pt] = heap[ptd2]
    heap[ptd2] = tmp
    pt = ptd2
  end
  --heap_sane(heap)
end

local function heap_extract(heap)
  local rv = heap[1]
  if #heap == 1 then table.remove(heap) return rv end
  heap[1] = table.remove(heap)
  local idx = 1
  while idx < #heap do
    local minix = idx
    if heap[heap_left(idx)] and heap[heap_left(idx)].c < heap[minix].c then minix = heap_left(idx) end
    if heap[heap_right(idx)] and heap[heap_right(idx)].c < heap[minix].c then minix = heap_right(idx) end
    if minix ~= idx then
      local tx = heap[minix]
      heap[minix] = heap[idx]
      heap[idx] = tx
      idx = minix
    else
      break
    end
  end
  --heap_sane(heap)
  return rv
end

-- incremented on each graph iteration, so we don't have to clear everything. "GRaph ID" :D
local grid = 0

-- Plane format: each plane contains an array of nodes that exist in that plane.
-- Each node contains both its parent ID and its coordinates within that plane. It may contain a node it links to, along with cost.
local plane = {}

local plane_to_flyplane = {}
local continent_to_flyplane = {}
local flyplanes_enabled = {}
local plane_multiplier = {}

-- canonical plane :D
local function canoplane(plane)
  if flyplanes_enabled[plane_to_flyplane[plane]] then return plane_to_flyplane[plane] else return plane end
end

local function xydist_raw(plane, stx, sty, ndx, ndy)
  local dx, dy = stx - ndx, sty - ndy
  return math.sqrt(dx * dx + dy * dy) / (plane_multiplier[plane] or 7)
end
local function xydist(st, nd)
  QuestHelper: Assert(canoplane(st.p) == canoplane(nd.p))
  local dx, dy = st.x - nd.x, st.y - nd.y
  return math.sqrt(dx * dx + dy * dy) / (plane_multiplier[canoplane(nd.p)] or 7) -- we're getting a result in seconds, not in yards
end





function QH_Graph_Pathfind(st, nd, reverse, make_path)
  return QH_Graph_Pathmultifind(st, {nd}, reverse, make_path)[1]
end

local active = false

function QH_Graph_Pathmultifind(st, nda, reverse, make_path)
  --QuestHelper:TextOut("Starting PMF")
  QuestHelper: Assert(not active)
  active = true -- The fun thing about coroutines is that this is actually safe.
  local out = QuestHelper:CreateTable("graphcore output")  -- THIS HAD BETTER BE RELEASABLE OR IT WILL BE BAD
  
  local undone = QuestHelper:CreateTable("graphcore undone")
  local remaining = 0
  
  local link = QuestHelper:CreateTable("graphcore link")
  
  --local stats = QuestHelper:CreateTable("graphcore --stats")
  
  QuestHelper: Assert(st.x and st.y and st.p)
  
  --stats.dests_complex = 0
  --stats.dests_total = 0
  
  for k, v in ipairs(nda) do
    QuestHelper: Assert(v.x and v.y and v.p)
    local cpvp = canoplane(v.p)
    if plane[cpvp] then
      --print("Destination plane insertion")
      local dest = QuestHelper:CreateTable("graphcore destination")
      dest.x, dest.y, dest.p, dest.goal = v.x, v.y, cpvp, k
      link[k] = dest
      table.insert(plane[cpvp], link[k])
      undone[k] = true
      remaining = remaining + 1
      --stats.dests_complex = --stats.dests_complex + 1
    end
    --stats.dests_total = --stats.dests_total + 1
  end
  
  local link_id = reverse and "rlinks" or "links"
  
  --stats.node_initialized_first = 0
  --stats.node_done = 0
  --stats.node_done_already = 0
  --stats.node_modified_before_use = 0
  --stats.node_link_reprocessed = 0
  --stats.node_link_first = 0
  --stats.node_link_alreadydone = 0
  --stats.node_inner_reprocessed = 0
  --stats.node_inner_first = 0
  --stats.node_inner_alreadydone = 0
  
  local dijheap = QuestHelper:CreateTable("graphcore heap container")
  local stnode = QuestHelper:CreateTable("graphcore stnode")
  do
    stnode.x, stnode.y, stnode.p, stnode.c, stnode.scan_id, stnode.scan_cost = st.x, st.y, canoplane(st.p), st.c, grid, 0
    QuestHelper: Assert(plane[canoplane(st.p)])
    table.insert(plane[stnode.p], stnode)
    
    local hep = QuestHelper:CreateTable("graphcore heap")
    hep.c, hep.n = 0, stnode  -- more than the subtraction, less than the minimum
    heap_insert(dijheap, hep)
  end
  
  --stats.heap_max = #dijheap
  
  --QuestHelper:TextOut("Starting routing")
  
  while remaining > 0 and #dijheap > 0 do
    QH_Timeslice_Yield()
    --stats.heap_max = math.max(--stats.heap_max, #dijheap)
    local cdj = heap_extract(dijheap)
    
    local snode = cdj.n
    --print(string.format("Extracted cost %f/%s pointing at %d/%f/%f", cdj.c, tostring(cdj.n.scan_cost), cdj.n.p, cdj.n.x, cdj.n.y))
    if snode.scan_cost == cdj.c then  -- if we've modified it since then, don't bother
      -- Are we at an end node?
      if snode.goal then
        -- we wouldn't be here if we hadn't found a better solution
        QuestHelper: Assert(undone[snode.goal])
        out[snode.goal] = cdj.c
        undone[snode.goal] = nil
        remaining = remaining - 1
      end
      
      -- Link to everything else on the plane
      if not snode.pi then  -- Did we come from this plane? If so, there's no reason to scan it again  (flag means "plane internal")
        for _, v in ipairs(plane[snode.p]) do
          if v.scan_id ~= grid or v.scan_cost > snode.scan_cost then
            local dst = xydist(snode, v)
            local modcost = snode.scan_cost + dst
            --print(string.format("Doing %d/%f vs %s/%s at %d/%f/%f", grid, modcost, tostring(v.scan_id), tostring(v.scan_cost), v.p, v.x, v.y))
            if v.scan_id ~= grid or v.scan_cost > modcost then
              v.scan_id = grid
              v.scan_cost = modcost
              v.scan_from = snode
              v.scan_processed = false
              v.scan_outnode = nil
              v.scan_outnode_from = nil
              
              do
                local snude = QuestHelper:CreateTable("graphcore heap")
                snude.c, snude.n, snude.pi = modcost, v, true
                heap_insert(dijheap, snude)
                --print(string.format("Inserting %f at %d/%f/%f, plane", snude.c, v.p, v.x, v.y))
              end
            end
          end
        end
      end
      
      -- Link to everything we link to
      if snode[link_id] then
        for _, lnk in pairs(snode[link_id]) do
          local mc2 = snode.scan_cost + lnk.cost
          local linkto = lnk.link
          if linkto.scan_id ~= grid or linkto.scan_cost > mc2 then
            linkto.scan_id = grid
            linkto.scan_cost = mc2
            linkto.scan_from = snode
            linkto.scan_outnode = lnk.outnode_to
            linkto.scan_outnode_from = lnk.outnode_from
            
            local hep = QuestHelper:CreateTable("graphcore heap")
            hep.c, hep.n = mc2, linkto
            heap_insert(dijheap, hep)
            --print(string.format("Inserting %f at %d/%f/%f, link", hep.c, linkto.p, linkto.x, linkto.y))
          end
        end
      end
    end
    QuestHelper:ReleaseTable(cdj)
  end
  
  --QuestHelper:TextOut("Starting pathing")
  
  for _, v in ipairs(dijheap) do
    QuestHelper:ReleaseTable(v)
  end
  QuestHelper:ReleaseTable(dijheap)
  dijheap = nil
  
  --QuestHelper:TextOut(string.format("Earlyout with %d/%d remaining", #dijheap, remaining))
  if remaining > 0 then
    for k, v in ipairs(nda) do
      if not out[k] then
        QuestHelper: Assert(false, string.format("Couldn't find path to %d/%f/%f from %d/%f/%f", nda[k].p, nda[k].x, nda[k].y, st.p, st.x, st.y))
      end
    end
  end
  QuestHelper: Assert(remaining == 0)
  
  grid = grid + 1
  QuestHelper: Assert(grid < 1000000000) -- if this ever triggers I will be amazed
  
  if make_path then
    --print("mpath")
    for k, v in pairs(out) do
      QH_Timeslice_Yield()
      --print(out[k])
      local rp = QuestHelper:CreateTable("graphcore return")
      rp.d = v
      
      out[k] = rp
      --print(out[k])
      
      if link[k] then
        QuestHelper: Assert(link[k].scan_from)
        local tpath = reverse and rp or QuestHelper:CreateTable("graphcore path reversal")
        local cpx = link[k].scan_from
        local mdlast = nil
        while cpx do
          QuestHelper: Assert(cpx)
          
          if cpx.scan_outnode then
            table.insert(tpath, cpx.scan_outnode)
          end
          if cpx.scan_outnode_from then
            table.insert(tpath, cpx.scan_outnode_from)
          end
          
          cpx = cpx.scan_from
        end
        QuestHelper: Assert(not mdlast)
        
        if not reverse then
          for i = #tpath, 1, -1 do
            table.insert(rp, tpath[i])
          end
          
          QuestHelper: Assert(tpath ~= rp)
          QuestHelper:ReleaseTable(tpath)
        end
      end
    end
  end
  
  QuestHelper:ReleaseTable(table.remove(plane[stnode.p])) -- always added last, so we remove it first
  for k, v in ipairs(nda) do
    if plane[canoplane(v.p)] and plane[canoplane(v.p)][#plane[canoplane(v.p)]].goal then   -- might not be the exact one, but we'll remove 'em all once we get there anyway :D
      QuestHelper:ReleaseTable(table.remove(plane[canoplane(v.p)]))
    end
  end
  
  QuestHelper:ReleaseTable(link)
  QuestHelper:ReleaseTable(undone)
  
  --QuestHelper:TextOut("Finishing")
  
  --for k, v in pairs(stats) do
    --print(k, v)
  --end
  
  active = false
  return out  -- THIS HAD BETTER BE RELEASABLE OR IT WILL BE BAD
end

function QH_Graph_Init()
  for c, d in pairs(QuestHelper_IndexLookup) do
    if type(c) == "number" then
      QuestHelper: Assert(d[0])
      continent_to_flyplane[c] = d[0]
      for z, p in pairs(d) do
        if type(z) == "number" then
          --QuestHelper:TextOut(string.format("%d/%d: %d", c, z, p))
          plane_to_flyplane[p] = d[0]
        end
      end
    end
  end
end

local linkages = {}

local function findnode(coord)
  local p = canoplane(coord.p)
  if not plane[p] then plane[p] = {} end
  for _, v in ipairs(plane[p]) do
    if v.x == coord.x and v.y == coord.y and v.name == coord.name then
      return v
    end
  end
  
  local nd = {x = coord.x, y = coord.y, p = p, name = coord.name}
  table.insert(plane[p], nd)
  return nd
end

local function QH_Graph_Plane_ReallyMakeLink(item)
  local name, coord1, coord2, cost, cost_reverse = unpack(item)
  
  QuestHelper: Assert(not active)
  
  --QuestHelper: TextOut(string.format("Link '%s' made from %d/%f/%f to %d/%f/%f of cost %f, asymflag %s", name, coord1.p, coord1.x, coord1.y, coord2.p, coord2.x, coord2.y, cost, tostring(not not asymmetrical)))
  QuestHelper: Assert(name)
  QuestHelper: Assert(coord1)
  QuestHelper: Assert(coord2)
  QuestHelper: Assert(cost)
  
  local n1p = canoplane(coord1.p)
  local n2p = canoplane(coord2.p)
  
  if canoplane(coord1.p) == canoplane(coord2.p) then
    if name == "static_transition" then return end -- ha ha, yep, that's how we find out, tooootally reliable
    
    local xyd = xydist_raw(canoplane(coord1.p), coord1.x, coord1.y, coord2.x, coord2.y)
    if cost >= xyd and (not cost_reverse or cost_reverse >= xyd) then
      return  -- DENIED
    end
  end
  
  local node1 = findnode(coord1)
  local node2 = findnode(coord2)
  
  local n1d = {x = coord1.x, y = coord1.y, p = coord1.p, c = coord1.c, map_desc = coord1.map_desc, condense_class = coord1.condense_class}
  local n2d = {x = coord2.x, y = coord2.y, p = coord2.p, c = coord2.c, map_desc = coord2.map_desc, condense_class = coord2.condense_class}
  
  if not node1.links then node1.links = {} end
  if not node2.rlinks then node2.rlinks = {} end
  
  table.insert(node1.links, {cost = cost, link = node2, outnode_to = n2d, outnode_from = n1d})
  table.insert(node2.rlinks, {cost = cost, link = node1, outnode_to = n1d, outnode_from = n2d})
  
  if cost_reverse then
    if not node1.rlinks then node1.rlinks = {} end
    if not node2.links then node2.links = {} end
    
    table.insert(node1.rlinks, {cost = cost_reverse, link = node2, outnode_to = n2d, outnode_from = n1d})
    table.insert(node2.links, {cost = cost_reverse, link = node1, outnode_to = n1d, outnode_from = n2d})
  end
end

function QH_Graph_Plane_Makelink(name, coord1, coord2, cost, cost_reverse)
  QuestHelper: Assert(not active)
  
  --QuestHelper: TextOut(string.format("Link '%s' made from %d/%f/%f to %d/%f/%f of cost %f, asymflag %s", name, coord1.p, coord1.x, coord1.y, coord2.p, coord2.x, coord2.y, cost, tostring(not not asymmetrical)))
  QuestHelper: Assert(name)
  QuestHelper: Assert(coord1)
  QuestHelper: Assert(coord2)
  QuestHelper: Assert(cost)
  
  QuestHelper: Assert(cost >= 0)
  QuestHelper: Assert(not cost_reverse or cost_reverse >= 0)
  
  --cost = math.max(cost, 0.01)
  --if cost_reverse then cost_reverse = math.max(cost_reverse, 0.01) end
  
  local tlink = {name, coord1, coord2, cost, cost_reverse}
  if not linkages[name] then linkages[name] = {} end
  table.insert(linkages[name], tlink)
  
  QH_Graph_Plane_ReallyMakeLink(tlink)
end

local function QH_Graph_Plane_Destroylinkslocal(name)
  QuestHelper: Assert(not active)
  
  for k, v in pairs(plane) do
    local repl = {}
    for tk, tv in ipairs(v) do
      if tv.name ~= name then
        table.insert(repl, tv)
      end
    end
    plane[k] = repl
  end
end

function QH_Graph_Plane_Destroylinks(name)
  QuestHelper: Assert(not active)
  
  linkages[name] = nil
  
  QH_Graph_Plane_Destroylinkslocal(name)
end

function QH_Graph_Flyplaneset(fpset, speed)
  QuestHelper: Assert(not active)
  
  if not flyplanes_enabled[QuestHelper_IndexLookup[fpset][0]] then
    flyplanes_enabled[QuestHelper_IndexLookup[fpset][0]] = true
    for k, v in pairs(linkages) do
      QH_Graph_Plane_Destroylinkslocal(k)
      
      for _, ite in pairs(v) do
        QH_Graph_Plane_ReallyMakeLink(ite)
      end
    end
    
    plane_multiplier[QuestHelper_IndexLookup[fpset][0]] = speed
  end
end
