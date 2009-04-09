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
  QuestHelper: Assert(not active)
  active = true -- The fun thing about coroutines is that this is actually safe.
  local out = QuestHelper:CreateTable("graphcore output")  -- THIS HAD BETTER BE RELEASABLE OR IT WILL BE BAD
  
  local undone = QuestHelper:CreateTable("graphcore undone")
  local remaining = 0
  
  local link = QuestHelper:CreateTable("graphcore link")
  
  QuestHelper: Assert(st.x and st.y and st.p)
  
  for k, v in ipairs(nda) do
    QuestHelper: Assert(v.x and v.y and v.p)
    local cpvp = canoplane(v.p)
    if canoplane(st.p) == cpvp then
      out[k] = xydist(st, v)
    else
      if plane[cpvp] then
      --print("Destination plane insertion")
        -- ugh I hate this optimization
        local dest = QuestHelper:CreateTable("graphcore destination")
        dest.x, dest.y, dest.p, dest.goal = v.x, v.y, cpvp, k
        link[k] = dest
        table.insert(plane[cpvp], link[k])
        undone[k] = true
        remaining = remaining + 1
      end
    end
  end
  
  local link_id = reverse and "rlink" or "link"
  local link_cost_id = reverse and "rlink_cost" or "link_cost"
  
  local dijheap = QuestHelper:CreateTable("graphcore heap center")
  if plane[canoplane(st.p)] then
    --print("ST plane insertion")
    for _, v in ipairs(plane[canoplane(st.p)]) do
      if v[link_id] then
        QuestHelper: Assert(not v.goal)
        local dst = xydist(st, v)
        v.scan_id = grid
        v.scan_cost = dst
        v.scan_from = nil
        
        local hep = QuestHelper:CreateTable("graphcore heap")
        hep.c, hep.cs, hep.n = dst + v[link_cost_id], dst, v
        heap_insert(dijheap, hep)
      end
    end
  end
  
  while remaining > 0 and #dijheap > 0 do
    QH_Timeslice_Yield()
    local cdj = heap_extract(dijheap)
    if cdj.done then
      if undone[cdj.done] then
        undone[cdj.done] = nil
        remaining = remaining - 1
      end
    else
    --print(string.format("Extracted cost %f/%s pointing at %f/%f/%d", cdj.c, tostring(cdj.n.scan_cost), cdj.n.x, cdj.n.y, cdj.n.p))
      QuestHelper: Assert(cdj.n[link_id])
      if cdj.n.scan_cost == cdj.cs then  -- if we've modified it since then, don't bother
        local linkto = cdj.n[link_id]
        local basecost = cdj.c + cdj.n[link_cost_id]
        if linkto.scan_id ~= grid or linkto.scan_cost > basecost then
          linkto.scan_id = grid
          linkto.scan_cost = basecost
          linkto.scan_from = nil
          
          for _, v in ipairs(plane[linkto.p]) do
            if v.goal then
              -- One way or another, we gotta calculate this.
              local goalcost = basecost + xydist(linkto, v)
              if not out[v.goal] or out[v.goal] > goalcost then
                out[v.goal] = goalcost
                v.scan_from = cdj.n
                
                local hep = QuestHelper:CreateTable("graphcore heap")
                hep.c, hep.done = goalcost, v.goal
                heap_insert(dijheap, hep)
              end
            elseif v[link_id] and (v.scan_id ~= grid or v.scan_cost > basecost) then
              local goalcost = basecost + xydist(linkto, v)
              if v.scan_id ~= grid or v.scan_cost > goalcost then
                v.scan_id = grid
                v.scan_cost = goalcost
                v.scan_from = cdj.n
                
                local hep = QuestHelper:CreateTable("graphcore heap")
                hep.c, hep.cs, hep.n = goalcost + v[link_cost_id], goalcost, v
                heap_insert(dijheap, hep)
              end
            end
          end
        end
      end
    end
    QuestHelper:ReleaseTable(cdj)
  end
  
  for _, v in ipairs(dijheap) do
    QuestHelper:ReleaseTable(v)
  end
  QuestHelper:ReleaseTable(dijheap)
  dijheap = nil
  
  --QuestHelper:TextOut(string.format("Earlyout with %d/%d remaining", #dijheap, remaining))
  QuestHelper: Assert(remaining == 0)
  
  grid = grid + 1
  QuestHelper: Assert(grid < 1000000000) -- if this ever triggers I will be amazed
  
  if make_path then
    --print("mpath")
    for k, v in pairs(out) do
      --print(out[k])
      local rp = QuestHelper:CreateTable("graphcore return")
      rp.d = v
      
      out[k] = rp
      --print(out[k])
      
      if link[k] then
        QuestHelper: Assert(link[k].scan_from)
        local tpath = reverse and rp or QuestHelper:CreateTable("graphcore path reversal")
        local cpx = link[k].scan_from
        while cpx do
          if reverse then
            QuestHelper: Assert(cpx.rlink)
            table.insert(tpath, cpx.rlink)
          else
            QuestHelper: Assert(cpx.link)
            table.insert(tpath, cpx.link)
          end
          QuestHelper: Assert(cpx)
          table.insert(tpath, cpx)
          
          cpx = cpx.scan_from
        end
        
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
  
  for k, v in ipairs(nda) do
    if plane[canoplane(v.p)] and plane[canoplane(v.p)][#plane[canoplane(v.p)]].goal then   -- might not be the exact one, but we'll remove 'em all once we get there anyway :D
      QuestHelper:ReleaseTable(table.remove(plane[canoplane(v.p)]))
    end
  end
  
  QuestHelper:ReleaseTable(link)
  QuestHelper:ReleaseTable(undone)
  
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
          QuestHelper:TextOut(string.format("%d/%d: %d", c, z, p))
          plane_to_flyplane[p] = d[0]
        end
      end
    end
  end
end

local linkages = {}

local function QH_Graph_Plane_ReallyMakeLink(item)
  local name, coord1, coord2, cost, cost_reverse = unpack(item)
  
  QuestHelper: Assert(not active)
  
  --QuestHelper: TextOut(string.format("Link '%s' made from %d/%f/%f to %d/%f/%f of cost %f, asymflag %s", name, coord1.p, coord1.x, coord1.y, coord2.p, coord2.x, coord2.y, cost, tostring(not not asymmetrical)))
  QuestHelper: Assert(name)
  QuestHelper: Assert(coord1)
  QuestHelper: Assert(coord2)
  QuestHelper: Assert(cost)
  
  local node1 = {x = coord1.x, y = coord1.y, p = canoplane(coord1.p), c = coord1.c, map_desc = coord1.map_desc, condense_class = coord1.condense_class, name = name}
  local node2 = {x = coord2.x, y = coord2.y, p = canoplane(coord2.p), c = coord2.c, map_desc = coord2.map_desc, condense_class = coord2.condense_class, name = name}
  
  if node1.p == node2.p then
    -- if they're the same location, we don't want to include them
    -- right now, "the same location" is being done really, really cheaply
    -- hey look me! I'm kind of a bastard!
    
    if name == "static_transition" then return end -- ha ha, yep, that's how we find out, tooootally reliable
  end
  
  if not plane[node1.p] then plane[node1.p] = {} end
  if not plane[node2.p] then plane[node2.p] = {} end
  
  node1.link, node1.link_cost, node2.rlink, node2.rlink_cost = node2, cost, node1, cost
  if cost_reverse then node1.rlink, node1.rlink_cost, node2.link, node2.link_cost = node2, cost_reverse, node1, cost_reverse end
  
  table.insert(plane[node1.p], node1)
  table.insert(plane[node2.p], node2)
end

function QH_Graph_Plane_Makelink(name, coord1, coord2, cost, cost_reverse)
  QuestHelper: Assert(not active)
  
  --QuestHelper: TextOut(string.format("Link '%s' made from %d/%f/%f to %d/%f/%f of cost %f, asymflag %s", name, coord1.p, coord1.x, coord1.y, coord2.p, coord2.x, coord2.y, cost, tostring(not not asymmetrical)))
  QuestHelper: Assert(name)
  QuestHelper: Assert(coord1)
  QuestHelper: Assert(coord2)
  QuestHelper: Assert(cost)
  
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
