QuestHelper_File["routing_core.lua"] = "Development Version"
QuestHelper_Loadtime["routing_core.lua"] = GetTime()

local DebugOutput = (QuestHelper_File["routing_core.lua"] == "Development Version")

--[[

let's think about clustering

Easiest way to pass in clusters, as we've already observed, is to just have a "cluster object" to pass in as an addition. This isn't a node, and we don't want to require "clusters" when people just want to add a single node. It isn't an objective either - it's a group of objectives, because when we return a route, we return a series of objectives.

So, "add cluster" is intrinsically different.

The next question, though, is how we link things. I'm liking the idea of the same ol' "link cluster X to cluster Y" thing. I think it's a good idea to create a list of "start nodes", though.

We're going to restrict it so that dependencies can only be done with clusters, just for the sake of my sanity.
This will also probably make it easier to ignore single parts of clusters, since we can do so by just tweaking the cluster definitions. I think this works.

I think this works tomorrow.

]]

local OptimizationHackery = true

if OptimizationHackery then DebugOutput = false end -- :ughh:


-- Ant colony optimization. Moving from X to Y has the quality (Distance[x,y]^alpha)*(Weight[x,y]^beta). Sum all available qualities, then choose weighted randomly.
-- Weight adjustment: Weight[x,y] = Weight[x,y]*weightadj + sum(alltravels)(1/distance_of_travel)    (note: this is somewhat out of date)

-- Configuration
  local PheremonePreservation = 0.98 -- must be within 0 and 1 exclusive
  local AntCount = 20 -- number of ants to run before doing a pheremone pass

    -- Weighting for the various factors
  local WeightFactor = 0.61
  local DistanceFactor = -2.5
  local DistanceDeweight = 1.4 -- Add this to all distances to avoid sqrt(-1) deals
  
  -- Small amount to add to all weights to ensure it never hits, and to make sure things can still be chosen after a lot of iterations
  local UniversalBonus = 0.06
-- End configuration

local Notifier
local DistBatch

-- Node storage and data structures
  local CurrentNodes = 1
  local ActiveNodes = {1}
  local DeadNodes = {}
  
  -- Clusters
  local Cluster = {} -- Goes from cluster ID to node IDs
  local ClusterLookup = {} -- Goes from node ID to cluster ID
  local ClusterTableLookup = {} -- Goes from the actual cluster table to the cluster ID
  local ClusterDead = {} -- List of dead clusters that can be reclaimed
  
  local DependencyLinks = {}  -- Every cluster that cluster X depends on
  local DependencyLinksReverse = {}  -- Every cluster that cluster X depends on
  local DependencyCounts = {}  -- How many different nodes cluster X depends on

  local StartNode = {ignore = true, loc = {x = 37690, y = 19671, p = 25, c = 0}}  -- Ironforge mailbox :)

  local NodeLookup = {[StartNode] = 1}
  local NodeList = {[1] = StartNode}
  local Distance = {{0}}
  local Weight = {{0}}
  
  weight_ave = 0.001
-- End node storage and data structures

--[[
----------------------------------
Here's that wacky storage system.
----------------------------------]]

local function unsigned2b(c)
  if c > 65535 then -- ughh. again.
    print(c)
    c = 65535
  end
  
  if not (c < 65536) then
    print(c)
  end
  QuestHelper: Assert(c < 65536)
  
  QuestHelper: Assert(bit.mod(c, 256))
  QuestHelper: Assert(bit.rshift(c, 8))
  local strix = strchar(bit.mod(c, 256), bit.rshift(c, 8))
  QuestHelper: Assert(#strix == 2)
  return strix
end

-- L
local loopcount = 0
local function Storage_Loop()
  loopcount = loopcount + 1
end
local function Storage_LoopFlush()
  if loopcount > 0 then
    QH_Merger_Add(QH_Collect_Routing_Dump, "L" .. unsigned2b(loopcount) .. "L")
    loopcount = 0
  end
end

-- -
local function Storage_Distance_StoreFromIDToAll(id)
  if not QH_Collect_Routing_Dump then return end
  Storage_LoopFlush()
  
  QH_Merger_Add(QH_Collect_Routing_Dump, "-" .. unsigned2b(id))
  for _, v in ipairs(ActiveNodes) do
    QH_Merger_Add(QH_Collect_Routing_Dump, unsigned2b(Distance[id][v]))
  end
  QH_Merger_Add(QH_Collect_Routing_Dump, "-")
end

-- X
local function Storage_Distance_StoreCrossID(id)
  if not QH_Collect_Routing_Dump then return end
  Storage_LoopFlush()
  
  QH_Merger_Add(QH_Collect_Routing_Dump, "X")
  for _, v in ipairs(ActiveNodes) do
    QH_Merger_Add(QH_Collect_Routing_Dump, unsigned2b(Distance[id][v]))
    if v ~= id then QH_Merger_Add(QH_Collect_Routing_Dump, unsigned2b(Distance[v][id])) end
  end
  QH_Merger_Add(QH_Collect_Routing_Dump, "X")
end

-- #
local function Storage_Distance_StoreAll()
  if not QH_Collect_Routing_Dump then return end
  Storage_LoopFlush()
  
  QH_Merger_Add(QH_Collect_Routing_Dump, "#")
  for _, v in ipairs(ActiveNodes) do
    for _, w in ipairs(ActiveNodes) do
      QH_Merger_Add(QH_Collect_Routing_Dump, unsigned2b(Distance[v][w]))
    end
  end
  QH_Merger_Add(QH_Collect_Routing_Dump, "#")
end

-- A
local function Storage_NodeAdded(id)
  if not QH_Collect_Routing_Dump then return end
  Storage_LoopFlush()
  
  QH_Merger_Add(QH_Collect_Routing_Dump, "A" .. unsigned2b(id))
  Storage_Distance_StoreCrossID(id)
  QH_Merger_Add(QH_Collect_Routing_Dump, "A")
end

-- R
local function Storage_NodeRemoved(id)
  if not QH_Collect_Routing_Dump then return end
  Storage_LoopFlush()
  
  QH_Merger_Add(QH_Collect_Routing_Dump, "R" .. unsigned2b(id) .. "R")
end

-- C
local function Storage_ClusterCreated(id)
  if not QH_Collect_Routing_Dump then return end
  Storage_LoopFlush()
  
  QH_Merger_Add(QH_Collect_Routing_Dump, "C" .. unsigned2b(id) .. unsigned2b(#Cluster[id]))
  for _, v in ipairs(Cluster[id]) do
    QH_Merger_Add(QH_Collect_Routing_Dump, unsigned2b(v))
  end
  QH_Merger_Add(QH_Collect_Routing_Dump, "C")
end

-- D
local function Storage_ClusterDestroyed(id)
  if not QH_Collect_Routing_Dump then return end
  Storage_LoopFlush()
  
  QH_Merger_Add(QH_Collect_Routing_Dump, "D" .. unsigned2b(id) .. "D")
end

-- >
local function Storage_ClusterDependency(from, to)
  if not QH_Collect_Routing_Dump then return end
  Storage_LoopFlush()
  
  QH_Merger_Add(QH_Collect_Routing_Dump, ">" .. unsigned2b(from) .. unsigned2b(to) .. ">")
end

--[[
----------------------------------
and here's the other end of the wacky storage system
----------------------------------]]

-- we may need to play with these
local QH_Route_Core_NodeAdd_Internal
local QH_Route_Core_NodeRemove_Internal

if OptimizationHackery then
  function Unstorage_SetDists(newdists)
    local tc = 1
    QuestHelper: Assert(#newdists == #ActiveNodes * #ActiveNodes)
    for _, v in ipairs(ActiveNodes) do
      for _, w in ipairs(ActiveNodes) do
        Distance[v][w] = newdists[tc]
        tc = tc + 1
      end
    end
    QuestHelper: Assert(tc - 1 == #newdists)
  end
  
  function Unstorage_SetDistsX(pivot, newdists)
    local tc = 1
    QuestHelper: Assert(#newdists == #ActiveNodes * 2 - 1)
    for _, v in ipairs(ActiveNodes) do
      Distance[pivot][v] = newdists[tc]
      tc = tc + 1
      if v ~= pivot then
        Distance[v][pivot] = newdists[tc]
        tc = tc + 1
      end
    end
    QuestHelper: Assert(tc - 1 == #newdists)
  end
  
  function Unstorage_SetDistsLine(pivot, newdists)
    local tc = 1
    QuestHelper: Assert(#newdists == #ActiveNodes)
    
    if pivot == 1 then
      if last_best and #last_best > 1 then
        last_best.distance = last_best.distance - Distance[last_best[1]][last_best[2]]
      end
    end
    
    for _, v in ipairs(ActiveNodes) do
      Distance[pivot][v] = newdists[tc]
      tc = tc + 1
    end
    QuestHelper: Assert(tc - 1 == #newdists)
    
    if pivot == 1 then
      if last_best and #last_best > 1 then
        last_best.distance = last_best.distance + Distance[last_best[1]][last_best[2]]
      end
    end
  end
  
  function Unstorage_Add(nod)
    QH_Route_Core_NodeAdd_Internal({}, nod)
  end
  
  function Unstorage_Remove(nod)
    QH_Route_Core_NodeRemove_Internal({}, nod)
  end
  
  function Unstorage_ClusterAdd(nod, tab)
    QH_Route_Core_ClusterAdd({}, nod)
    for _, v in ipairs(tab) do
      QuestHelper: Assert(NodeList[v])
      ClusterLookup[v] = nod
      table.insert(Cluster[nod], v)
    end
  end
  
  function Unstorage_ClusterRemove(nod)
    QH_Route_Core_ClusterRemove({}, nod)
  end
  
  function Unstorage_Link(a, b)
    QH_Route_Core_ClusterRequires(a, b, true)
  end
  
  function Unstorage_Nastyscan()
    for _, v in ipairs(ActiveNodes) do
      for _, w in ipairs(ActiveNodes) do
        QuestHelper: Assert(Distance[v][w])
        QuestHelper: Assert(Weight[v][w])
      end
    end
  end
  
  function Unstorage_Magic(tab)
    local touched = {}
    
    PheremonePreservation = tab.PheremonePreservation  QuestHelper: Assert(PheremonePreservation)   touched.PheremonePreservation = true
    AntCount = tab.AntCount  QuestHelper: Assert(AntCount)   touched.AntCount = true
    WeightFactor = tab.WeightFactor  QuestHelper: Assert(WeightFactor)   touched.WeightFactor = true
    DistanceFactor = tab.DistanceFactor  QuestHelper: Assert(DistanceFactor)   touched.DistanceFactor = true
    DistanceDeweight = tab.DistanceDeweight  QuestHelper: Assert(DistanceDeweight)   touched.DistanceDeweight = true
    UniversalBonus = tab.UniversalBonus  QuestHelper: Assert(UniversalBonus)   touched.UniversalBonus = true
    
    for k, v in pairs(tab) do
      QuestHelper: Assert(touched[k])
    end
  end
end

--[[
----------------------------------
here ends the butt of the wacky storage system. yeah, that's right. I said butt. Butt. Hee hee. Butt.
----------------------------------]]


function QH_Route_Core_NodeCount()
  return #ActiveNodes
end

-- fuck floating-point
local function almost(a, b)
  if a == b then return true end
  if type(a) ~= "number" or type(b) ~= "number" then return false end
  if a == 0 or b == 0 then return false end
  return math.abs(a / b - 1) < 0.0001
end

-- Initialization
function QH_Route_Core_Init(PathNotifier, DistanceBatch)
  Notifier = PathNotifier
  DistBatch = DistanceBatch
  QuestHelper: Assert(Notifier)
  QuestHelper: Assert(DistBatch)
end
-- End initialization

local last_best = nil

local function ValidateNumber(x)
  QuestHelper: Assert(x == x)
  QuestHelper: Assert(x ~= math.huge)
  QuestHelper: Assert(x ~= -math.huge)
end

local function GetWeight(x, y)
  if x == y then return 0.00000000001 end -- sigh
  --local idx = GetIndex(x, y)
  --local revidx = GetIndex(y, x)
  if not Weight[x][y] or not Distance[x][y] then
    RTO(string.format("%d/%d %d", x, y, CurrentNodes))
    QuestHelper: Assert(x <= CurrentNodes)
    QuestHelper: Assert(y <= CurrentNodes)
    QuestHelper: Assert(false)
  end
  local weight = math.pow(Weight[x][y], WeightFactor) * math.pow(Distance[x][y] + DistanceDeweight, DistanceFactor)
  --print(Weight[idx], Weight[revidx], bonus, WeightFactor, Distance[idx], DistanceFactor)
  --ValidateNumber(weight)
  return weight
end

local function RunAnt()
  local route = NewRoute()
  route[1] = 1
  route.distance = 0
  
  local dependencies = {}
  
  local needed = {}
  local needed_count = -1 -- gets rid of 1 earlier
  local needed_ready_count = -1
  
  for k, v in pairs(DependencyCounts) do
    dependencies[k] = v
  end
  
  for _, v in ipairs(ActiveNodes) do
    local need = false
    
    if ClusterLookup[v] then
      QuestHelper: Assert(dependencies[ClusterLookup[v]])
      if dependencies[ClusterLookup[v]] == 0 then
        need = true
      end
    else
      need = true
    end
    
    if need then
      needed[v] = true
      needed_ready_count = needed_ready_count + 1
    end
    
    needed_count = needed_count + 1
  end
  
  needed[1] = nil
  
  local curloc = 1
  
  local gwc = {}
  
  QuestHelper: Assert(needed_ready_count > 0 or needed_count == 0)
  
  while needed_count > 0 do
    QuestHelper: Assert(needed_ready_count > 0)
    
    local accumulated_weight = 0
    local tweight = 0
    for k, _ in pairs(needed) do
      local tw = GetWeight(curloc, k)
      gwc[k] = tw
      accumulated_weight = accumulated_weight + tw
    end
  
    tweight = accumulated_weight
    accumulated_weight = accumulated_weight * math.random()
    
    local nod = nil
    for k, _ in pairs(needed) do
      accumulated_weight = accumulated_weight - gwc[k]
      if accumulated_weight < 0 then
        nod = k
        break
      end
    end
    
    if not nod then
      RTO(string.format("no nod :( %f/%f", accumulated_weight, tweight))
      for k, _ in pairs(needed) do
        nod = k
        break
      end
    end
    
    -- Now we've chosen stuff. Bookkeeping.
    if ClusterLookup[nod] then
      local clust = ClusterLookup[nod]
      
      -- Obliterate other cluster items.
      for _, v in pairs(Cluster[clust]) do
        needed[v] = nil
        needed_count = needed_count - 1
        needed_ready_count = needed_ready_count - 1
      end
      
      -- Dependency links.
      if DependencyLinksReverse[clust] then for _, v in ipairs(DependencyLinksReverse[clust]) do
        dependencies[v] = dependencies[v] - 1
        if dependencies[v] == 0 then
          for _, v in pairs(Cluster[v]) do
            needed[v] = true
            needed_ready_count = needed_ready_count + 1
          end
        end
      end end
    else
      needed[nod] = nil
      needed_count = needed_count - 1
      needed_ready_count = needed_ready_count - 1
    end
    
    route.distance = route.distance + Distance[curloc][nod]
    table.insert(route, nod)
    curloc = nod
  end
  
  QuestHelper: Assert(needed_ready_count == 0)
  return route
end

local function BetterRoute(route)
  local rt = {}
  for k, v in ipairs(route) do
    rt[k] = NodeList[v]
  end
  rt.distance = route.distance -- this is probably temporary
  Notifier(rt)
end

-- Core process function
function QH_Route_Core_Process()
  Storage_Loop()
  
  local worst = 0
  
  local trouts = {}
  for x = 1, AntCount do
    table.insert(trouts, RunAnt())
    --if last_best then RTO(string.format("Path generated: %s vs %s", PathToString(trouts[#trouts]), PathToString(last_best))) end
    if not last_best or last_best.distance > trouts[#trouts].distance then
      last_best = trouts[#trouts]
      BetterRoute(last_best)
    end
    
    worst = math.max(worst, trouts[#trouts].distance)
    
    QH_Timeslice_Yield()
  end
  
  local scale
  if worst == last_best.distance then
    scale = 1
  else
    scale = 1 / (worst - last_best.distance)
  end
  
  for _, x in ipairs(ActiveNodes) do
    for _, y in ipairs(ActiveNodes) do
      --local idx = GetIndex(x, y)
      Weight[x][y] = Weight[x][y] * PheremonePreservation + UniversalBonus
      --ValidateNumber(Weight[idx])
    end
  end
  
  for _, x in ipairs(trouts) do
    local amount = 1 / x.distance
    for y = 1, #x - 1 do
      --local idx = GetIndex(x[y], x[y + 1])
      Weight[x[y]][x[y + 1]] = Weight[x[y]][x[y + 1]] + amount
      --ValidateNumber(Weight[idx])
    end
  end
  
  local weitotal = 0
  local weicount = 0
  for _, x in ipairs(ActiveNodes) do
    for _, y in ipairs(ActiveNodes) do
      --local idx = GetIndex(x, y)
      weitotal = weitotal + Weight[x][y]
      weicount = weicount + 1
    end
  end
  
  weight_ave = weitotal / weicount
  
  QH_Timeslice_Yield()  -- "heh"
end
-- End core loop

-- Node allocation and deallocation

  -- this is only separate so we can use it for the crazy optimization hackery
  local function Expand()
    for _, v in ipairs(Distance) do
      table.insert(v, 0)
    end
    for _, v in ipairs(Weight) do
      table.insert(v, 0)
    end
    table.insert(Distance, {})
    table.insert(Weight, {})
    
    for k = 1, CurrentNodes + 1 do
      table.insert(Distance[#Distance], 0)
      table.insert(Weight[#Weight], 0)
    end
    
    CurrentNodes = CurrentNodes + 1
  end
  
  -- This is pretty bad overall. Going from 0 nodes to N nodes is an O(n^3) operation. Eugh. Todo: allocate more than one at a time?
  local function AllocateExtraNode()
    if #DeadNodes > 0 then
      local nod = table.remove(DeadNodes)
      table.insert(ActiveNodes, nod)
      table.sort(ActiveNodes)
      return nod
    end
    
    -- We always allocate on the end, so we know this is safe.
    Expand()
    
    table.insert(DeadNodes, CurrentNodes)
    return AllocateExtraNode() -- ha ha
  end

  -- Set the start location
  function QH_Route_Core_SetStart(stt)
    -- We do some kind of ghastly things here.
    --TestShit()
    if last_best and #last_best > 1 then
      last_best.distance = last_best.distance - Distance[last_best[1]][last_best[2]]
    end
    
    NodeLookup[StartNode] = nil
    NodeList[1] = stt
    StartNode = stt
    NodeLookup[StartNode] = 1
    
    local tlnod = {}
    
    for _, v in ipairs(ActiveNodes) do
      if v ~= 1 then
        table.insert(tlnod, NodeList[v])
      end
    end
    
    local forward = DistBatch(NodeList[1], tlnod)
    
    local ct = 1
    for _, v in ipairs(ActiveNodes) do
      if v ~= 1 then
        QuestHelper: Assert(forward[ct])
        Distance[1][v] = forward[ct]
        ct = ct + 1
        
        Distance[v][1] = 65500 -- this should never be used anyway
      end
    end
    
    if last_best and #last_best > 1 then
      last_best.distance = last_best.distance + Distance[last_best[1]][last_best[2]]
    end
    
    Storage_Distance_StoreFromIDToAll(1)
    --TestShit()
    -- TODO: properly deallocate old startnode?
  end
  
  QH_Route_Core_NodeAdd_Internal = function (nod, used_idx)
    --QuestHelper:TextOut(tostring(nod))
    --TestShit()
    QuestHelper: Assert(nod)
    QuestHelper: Assert(not NodeLookup[nod])
    
    local idx
    if used_idx then
      QuestHelper: Assert(OptimizationHackery)
      QuestHelper: Assert(not NodeList[used_idx])
      idx = used_idx
      table.insert(ActiveNodes, used_idx)
      table.sort(ActiveNodes)
      if not Distance[idx] then Expand() QuestHelper: Assert(Distance[idx]) end
    else
      idx = AllocateExtraNode()
    end
    
    --RTO("|cffFF8080AEN: " .. tostring(idx))
    NodeLookup[nod] = idx
    NodeList[idx] = nod
    
    local tlnod = {}
    for _, v in ipairs(ActiveNodes) do
      table.insert(tlnod, NodeList[v])
      
      Weight[v][idx] = weight_ave
      Weight[idx][v] = weight_ave
    end
    
    local forward = DistBatch(NodeList[idx], tlnod)
    local backward = DistBatch(NodeList[idx], tlnod, true)
    
    for k, v in ipairs(ActiveNodes) do
      --QuestHelper:TextOut(string.format("%f/%f and %f/%f",Dist(NodeList[idx], NodeList[v]), forward[k], Dist(NodeList[v], NodeList[idx]), backward[k]))
      --QuestHelper:Assert(almost(Dist(NodeList[idx], NodeList[v]), forward[k]))
      --QuestHelper:Assert(almost(Dist(NodeList[v], NodeList[idx]), backward[k]))
      Distance[idx][v] = forward[k]
      Distance[v][idx] = backward[k]
    end
    --TestShit()
    
    last_best = nil
    
    return idx
  end

  -- Add a node to route to
  function QH_Route_Core_NodeAdd(nod)
    local idx = QH_Route_Core_NodeAdd_Internal(nod) -- we're just stripping the return value, really
    Storage_NodeAdded(idx)
  end

  -- Remove a node with the given location
  QH_Route_Core_NodeRemove_Internal = function (nod, used_idx)
    --TestShit()
    QuestHelper: Assert(nod)
    
    local idx
    if used_idx then
      QuestHelper: Assert(OptimizationHackery)
      QuestHelper: Assert(NodeList[used_idx])
      idx = used_idx
    else
      QuestHelper: Assert(NodeLookup[nod])
      idx = NodeLookup[nod]
    end
    
    --RTO("|cffFF8080RFN: " .. tostring(NodeLookup[nod]))
    NodeList[idx] = nil
    table.insert(DeadNodes, idx)
    local oas = #ActiveNodes
    for k, v in pairs(ActiveNodes) do if v == idx then table.remove(ActiveNodes, k) break end end -- this is pretty awful
    QuestHelper: Assert(#ActiveNodes < oas)
    NodeLookup[nod] = nil
    -- We don't have to modify the table itself, some sections are just "dead".
    --TestShit()
    
    last_best = nil
    
    return idx
  end
  
  function QH_Route_Core_NodeRemove(nod)
    local idx = QH_Route_Core_NodeRemove_Internal(nod)
    Storage_NodeRemoved(idx)
  end
-- End node allocation and deallocation

function QH_Route_Core_ClusterAdd(clust, clustid_used)
  local clustid
  if clustid_used then
    QuestHelper: Assert(OptimizationHackery)
    QuestHelper: Assert(not Cluster[clustid_used])
    clustid = clustid_used
  else
    QuestHelper: Assert(#clust > 0)
    clustid = table.remove(ClusterDead)
    if not clustid then clustid = #Cluster + 1 end
  end
  
  if DebugOutput then QuestHelper:TextOut(string.format("Adding cluster %d", clustid)) end
  
  Cluster[clustid] = {}
  ClusterTableLookup[clust] = clustid
  
  -- if we're doing hackery, clust will just be an empty table and we'll retrofit stuff later
  for _, v in ipairs(clust) do
    local idx = QH_Route_Core_NodeAdd_Internal(v)
    Storage_NodeAdded(idx)
    ClusterLookup[idx] = clustid
    table.insert(Cluster[clustid], idx)
  end
  
  DependencyCounts[clustid] = 0
  
  Storage_ClusterCreated(clustid)
end

function QH_Route_Core_ClusterRemove(clust, clustid_used)
  local clustid
  if clustid_used then
    QuestHelper: Assert(OptimizationHackery)
    QuestHelper: Assert(Cluster[clustid_used])
    clustid = clustid_used
    
    for _, v in ipairs(Cluster[clustid]) do
      QH_Route_Core_NodeRemove_Internal({}, v)
      ClusterLookup[v] = nil
    end
  else
    clustid = ClusterTableLookup[clust]
  end
  
  if DebugOutput then QuestHelper:TextOut(string.format("Removing cluster %d", clustid)) end
  
  for _, v in ipairs(clust) do
    local idx = QH_Route_Core_NodeRemove_Internal(v)
    ClusterLookup[idx] = nil
  end
  
  DependencyCounts[clustid] = nil
  
  if DependencyLinks[clustid] then
    for k, v in pairs(DependencyLinks[clustid]) do
      for m, f in pairs(DependencyLinksReverse[v]) do
        if f == clustid then
          if DebugOutput then QuestHelper:TextOut(string.format("Unlinking cluster %d needs %d", clustid, v)) end
          table.remove(DependencyLinksReverse[v], m)
          break
        end
      end
    end
  end
  DependencyLinks[clustid] = nil
  
  if DependencyLinksReverse[clustid] then
    for k, v in pairs(DependencyLinksReverse[clustid]) do
      for m, f in pairs(DependencyLinks[v]) do
        if f == clustid then
          if DebugOutput then QuestHelper:TextOut(string.format("Unlinking cluster %d needs %d", v, clustid)) end
          table.remove(DependencyLinks[v], m)
          DependencyCounts[v] = DependencyCounts[v] - 1
          break
        end
      end
    end
  end
  DependencyLinksReverse[clustid] = nil
  
  Cluster[clustid] = nil
  ClusterTableLookup[clust] = nil
  table.insert(ClusterDead, clustid)
  
  Storage_ClusterDestroyed(clustid)
end

-- Add a note that node 1 requires node 2.
function QH_Route_Core_ClusterRequires(a, b, hackery)
  local aidx
  local bidx
  if hackery then
    QuestHelper: Assert(OptimizationHackery)
    QuestHelper: Assert(Cluster[a])
    QuestHelper: Assert(Cluster[b])
    aidx, bidx = a, b
  else
    aidx = ClusterTableLookup[a]
    bidx = ClusterTableLookup[b]
  end
  QuestHelper: Assert(aidx)
  QuestHelper: Assert(bidx)
  QuestHelper: Assert(aidx ~= bidx)
  
  if DebugOutput then QuestHelper:TextOut(string.format("Linking cluster %d needs %d", aidx, bidx)) end
  
  DependencyCounts[aidx] = DependencyCounts[aidx] + 1
  
  if not DependencyLinks[aidx] then DependencyLinks[aidx] = {} end
  table.insert(DependencyLinks[aidx], bidx)
  
  if not DependencyLinksReverse[bidx] then DependencyLinksReverse[bidx] = {} end
  table.insert(DependencyLinksReverse[bidx], aidx)
  
  last_best = nil
  
  Storage_ClusterDependency(aidx, bidx)
end

-- Wipe and re-cache all distances.
function QH_Route_Core_DistanceClear()  
  local tlnod = {}
  for _, v in ipairs(ActiveNodes) do
    table.insert(tlnod, NodeList[v])
  end

  for _, idx in ipairs(ActiveNodes) do
    local forward = DistBatch(NodeList[idx], tlnod)
    
    for k, v in ipairs(ActiveNodes) do
      Distance[idx][v] = forward[k]
    end
  end
  
  last_best = nil   -- todo: just generate new distance info
  
  Storage_Distance_StoreAll()
end

--[=[
function findin(tab, val)
  local ct = 0
  for k, v in pairs(tab) do
    if v == val then ct = ct + 1 end
  end
  return ct == 1
end

function TestShit()
--[[
  for x = 1, #ActiveNodes do
    local ts = ""
    for y = 1, #ActiveNodes do
      ts = ts .. string.format("%f ", Distance[GetIndex(ActiveNodes[x], ActiveNodes[y])])
    end
    RTO(ts)
  end
  ]]
  
  --[[
  RTO("Lookup table")
  for x = 1, #ActiveNodes do
    RTO(tostring(ActiveNodes[x]))
  end
  RTO("Lookup table done")
  ]]
  
  local fail = false
  for x = 1, #ActiveNodes do
    for y = 2, #ActiveNodes do
      if not (almost(Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]), Distance[ActiveNodes[x]][ActiveNodes[y]])) then
        RTO(string.format("%d/%d (%d/%d) should be %f, is %f", x, y, ActiveNodes[x], ActiveNodes[y], Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]),Distance[ActiveNodes[x]][ActiveNodes[y]]))
        fail = true
      end
    end
  end
  
  for k, v in pairs(DependencyLinks) do
    QuestHelper: Assert(#v == DependencyCounts[k])
  end
  
  for k, v in pairs(DependencyCounts) do
    QuestHelper: Assert(v == (DependencyLinks[k] and #DependencyLinks[k] or 0))
  end
  
  for k, v in pairs(DependencyLinks) do
    for _, v2 in pairs(v) do
      QuestHelper: Assert(findin(DependencyLinksReverse[v2], k))
    end
  end
  
  for k, v in pairs(DependencyLinksReverse) do
    for _, v2 in pairs(v) do
      QuestHelper: Assert(findin(DependencyLinks[v2], k))
    end
  end
  
  QuestHelper: Assert(not fail)
end]=]

--[=[
function HackeryDump()
  local st = "{"
  for k, v in pairs(ActiveNodes) do
    if v ~= 1 then
      st = st .. string.format("{c = %d, x = %f, y = %f}, ", NodeList[k].loc.c, NodeList[k].loc.x, NodeList[k].loc.y)
    end
  end
  st = st .. "}"
  QuestHelper: Assert(false, st)
end]=]

-- weeeeee
