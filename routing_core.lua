QuestHelper_File["routing_core.lua"] = "Development Version"
QuestHelper_Loadtime["routing_core.lua"] = GetTime()

--[[

let's think about clustering

Easiest way to pass in clusters, as we've already observed, is to just have a "cluster object" to pass in as an addition. This isn't a node, and we don't want to require "clusters" when people just want to add a single node. It isn't an objective either - it's a group of objectives, because when we return a route, we return a series of objectives.

So, "add cluster" is intrinsically different.

The next question, though, is how we link things. I'm liking the idea of the same ol' "link cluster X to cluster Y" thing. I think it's a good idea to create a list of "start nodes", though.

We're going to restrict it so that dependencies can only be done with clusters, just for the sake of my sanity.
This will also probably make it easier to ignore single parts of clusters, since we can do so by just tweaking the cluster definitions. I think this works.

I think this works tomorrow.

]]

-- Ant colony optimization. Moving from X to Y has the quality (Distance[x,y]^alpha)*(Weight[x,y]^beta). Sum all available qualities, then choose weighted randomly.
-- Weight adjustment: Weight[x,y] = Weight[x,y]*weightadj + sum(alltravels)(1/distance_of_travel)    (note: this is somewhat out of date)

-- Configuration
  local PheremonePreservation = 0.80 -- must be within 0 and 1 exclusive
  local AntCount = 20 -- number of ants to run before doing a pheremone pass

    -- Weighting for the various factors
  local WeightFactor = 0.80
  local DistanceFactor = -3.5
  local DistanceDeweight = 1.5 -- Add this to all distances to avoid sqrt(-1) deals
  
  -- Small amount to add to all weights to ensure it never hits, and to make sure things can still be chosen after a lot of iterations
  local UniversalBonus = 0.25
  
  -- Weight added is 1/([0-1] + BestWorstAdjustment)
  local BestWorstAdjustment = 0.015
  
  -- How much do we want to factor in the "reverse path" weights
  local AsymmetryFactor = 0.32
  local SymmetryFactor = 0.45
-- End configuration

local Notifier
local Dist
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

  local StartNode = {ignore = true}

  local NodeLookup = {[StartNode] = 1}
  local NodeList = {[1] = StartNode}
  local Distance = {{0}}
  local Weight = {{0}}
  
  weight_ave = 0.001
-- End node storage and data structures

function QH_Route_Core_NodeCount()
  return CurrentNodes
end

-- fuck floating-point
local function almost(a, b)
  if a == b then return true end
  if type(a) ~= "number" or type(b) ~= "number" then return false end
  if a == 0 or b == 0 then return false end
  return math.abs(a / b - 1) < 0.0001
end

-- Initialization
function QH_Route_Core_Init(PathNotifier, Distance, DistanceBatch)
  Notifier = PathNotifier
  Dist = Distance
  DistBatch = DistanceBatch
  QuestHelper: Assert(Notifier)
  QuestHelper: Assert(Dist)
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
  end
  local bonus
  if Distance[x][y] == Distance[y][x] then
    bonus = SymmetryFactor
  else
    bonus = AsymmetryFactor
  end
  local weight = math.pow(Weight[x][y] + Weight[y][x] * bonus, WeightFactor) * math.pow(Distance[x][y] + DistanceDeweight, DistanceFactor)
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
    local amount = 1 / ((x.distance - last_best.distance) / scale + BestWorstAdjustment)
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
  -- This is pretty bad overall. Going from 0 nodes to N nodes is an O(n^3) operation. Eugh. Todo: allocate more than one at a time?
  local function AllocateExtraNode()
    if #DeadNodes > 0 then
      local nod = table.remove(DeadNodes)
      table.insert(ActiveNodes, nod)
      table.sort(ActiveNodes)
      return nod
    end
    
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
        
        Distance[v][1] = 1000000 -- this should never be used anyway
      end
    end
    
    if last_best and #last_best > 1 then
      last_best.distance = last_best.distance + Distance[last_best[1]][last_best[2]]
    end
    
    --TestShit()
    -- TODO: properly deallocate old startnode?
  end
  
  local function QH_Route_Core_NodeAdd_Internal(nod)
    --QuestHelper:TextOut(tostring(nod))
    --TestShit()
    QuestHelper: Assert(nod)
    QuestHelper: Assert(not NodeLookup[nod])
    
    local idx = AllocateExtraNode()
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
    QH_Route_Core_NodeAdd_Internal(nod) -- we're just stripping the return value, really
  end

  -- Remove a node with the given location
  local function QH_Route_Core_NodeRemove_Internal(nod)
    --TestShit()
    QuestHelper: Assert(nod)
    QuestHelper: Assert(NodeLookup[nod])
    
    local idx = NodeLookup[nod]
    --RTO("|cffFF8080RFN: " .. tostring(NodeLookup[nod]))
    NodeList[idx] = nil
    table.insert(DeadNodes, idx)
    for k, v in pairs(ActiveNodes) do if v == idx then table.remove(ActiveNodes, k) break end end -- this is pretty awful
    NodeLookup[nod] = nil
    -- We don't have to modify the table itself, some sections are just "dead".
    --TestShit()
    
    last_best = nil
    
    return idx
  end
  
  function QH_Route_Core_NodeRemove(nod)
    QH_Route_Core_NodeRemove_Internal(nod)
  end
-- End node allocation and deallocation

function QH_Route_Core_ClusterAdd(clust)
  QuestHelper: Assert(#clust > 0)
  local clustid = table.remove(ClusterDead)
  if not clustid then clustid = #Cluster + 1 end
  
  QuestHelper:TextOut(string.format("Adding cluster %d", clustid))
  
  Cluster[clustid] = {}
  ClusterTableLookup[clust] = clustid
  
  for _, v in ipairs(clust) do
    local idx = QH_Route_Core_NodeAdd_Internal(v)
    ClusterLookup[idx] = clustid
    table.insert(Cluster[clustid], idx)
  end
  
  DependencyCounts[clustid] = 0
end

function QH_Route_Core_ClusterRemove(clust)
  local clustid = ClusterTableLookup[clust]
  
  QuestHelper:TextOut(string.format("Removing cluster %d", clustid))
  
  for _, v in ipairs(clust) do
    local idx = QH_Route_Core_NodeRemove_Internal(v)
    ClusterLookup[idx] = nil
  end
  
  DependencyCounts[clustid] = nil
  
  if DependencyLinks[clustid] then
    for k, v in pairs(DependencyLinks[clustid]) do
      for m, f in pairs(DependencyLinksReverse[v]) do
        if f == clustid then
          QuestHelper:TextOut(string.format("Unlinking cluster %d needs %d", clustid, v))
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
          QuestHelper:TextOut(string.format("Unlinking cluster %d needs %d", v, clustid))
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
end

-- Add a note that node 1 requires node 2.
function QH_Route_Core_ClusterRequires(a, b)
  local aidx = ClusterTableLookup[a]
  local bidx = ClusterTableLookup[b]
  QuestHelper: Assert(aidx)
  QuestHelper: Assert(bidx)
  QuestHelper: Assert(aidx ~= bidx)
  
  QuestHelper:TextOut(string.format("Linking cluster %d needs %d", aidx, bidx))
  
  DependencyCounts[aidx] = DependencyCounts[aidx] + 1
  
  if not DependencyLinks[aidx] then DependencyLinks[aidx] = {} end
  table.insert(DependencyLinks[aidx], bidx)
  
  if not DependencyLinksReverse[bidx] then DependencyLinksReverse[bidx] = {} end
  table.insert(DependencyLinksReverse[bidx], aidx)
  
  last_best = nil
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
  assert(false, st)
end]=]

-- weeeeee
