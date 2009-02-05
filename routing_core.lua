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

-- Node storage and data structures
  local MaxNodes = math.floor(math.sqrt(math.pow(2, 19)))

  local CurrentNodes = 1
  local ActiveNodes = {1}
  local DeadNodes = {}
  
  local DependencyLinks = {}  -- Everything that node X depends on (integers)
  local DependencyLinksReverse = {}  -- Everything that depends on node X (integers)
  local DependencyCounts = {[1] = 0}  -- How many different nodes node X depends on

  local StartNode = {}

  local NodeLookup = {[StartNode] = 1}
  local NodeList = {[1] = StartNode}
  local Distance = {0}
  local Weight = {0}
  
  weight_ave = 0.001

  local function GetIndex(x, y) return (x - 1) * CurrentNodes + y end
-- End node storage and data structures

-- Initialization
function QH_Route_Core_Init(PathNotifier, Distance)
  Notifier = PathNotifier
  Dist = Distance
  QuestHelper: Assert(Notifier)
  QuestHelper: Assert(Dist)
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
  local idx = GetIndex(x, y)
  local revidx = GetIndex(y, x)
  if not Weight[idx] or not Distance[idx] then
    RTO(string.format("%d/%d %d", x, y, CurrentNodes))
    QuestHelper: Assert(x <= CurrentNodes)
    QuestHelper: Assert(y <= CurrentNodes)
  end
  local bonus
  if Distance[idx] == Distance[revidx] then
    bonus = SymmetryFactor
  else
    bonus = AsymmetryFactor
  end
  local weight = math.pow(Weight[idx] + Weight[revidx] * bonus, WeightFactor) * math.pow(Distance[idx] + DistanceDeweight, DistanceFactor)
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
  for _, v in ipairs(ActiveNodes) do
    dependencies[v] = DependencyCounts[v]
    if dependencies[v] == 0 then
      needed[v] = true
      needed_ready_count = needed_ready_count + 1
    end
    needed_count = needed_count + 1
  end
  needed[1] = nil
  
  local curloc = 1
  
  while needed_count > 0 do
    QuestHelper: Assert(needed_ready_count > 0)
    local accumulated_weight = 0
    local tweight = 0
    for k, _ in pairs(needed) do
      accumulated_weight = accumulated_weight + GetWeight(curloc, k)
    end
  
    tweight = accumulated_weight
    accumulated_weight = accumulated_weight * math.random()
    
    local nod = nil
    for k, _ in pairs(needed) do
      accumulated_weight = accumulated_weight - GetWeight(curloc, k)
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
    needed[nod] = nil
    needed_count = needed_count - 1
    needed_ready_count = needed_ready_count - 1
    
    -- Dependency links.
    if DependencyLinksReverse[nod] then for _, v in ipairs(DependencyLinksReverse[nod]) do
      dependencies[v] = dependencies[v] - 1
      if dependencies[v] == 0 then
        needed[v] = true
        needed_ready_count = needed_ready_count + 1
      end
    end end
    
    route.distance = route.distance + Distance[GetIndex(curloc, nod)]
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
      local idx = GetIndex(x, y)
      Weight[idx] = Weight[idx] * PheremonePreservation + UniversalBonus
      --ValidateNumber(Weight[idx])
    end
  end
  
  for _, x in ipairs(trouts) do
    local amount = 1 / ((x.distance - last_best.distance) / scale + BestWorstAdjustment)
    for y = 1, #x - 1 do
      local idx = GetIndex(x[y], x[y + 1])
      Weight[idx] = Weight[idx] + amount
      --ValidateNumber(Weight[idx])
    end
  end
  
  local weitotal = 0
  local weicount = 0
  for _, x in ipairs(ActiveNodes) do
    for _, y in ipairs(ActiveNodes) do
      local idx = GetIndex(x, y)
      weitotal = weitotal + Weight[idx]
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
    
    --RTO(string.format("Expanding from %d to %d", CurrentNodes, CurrentNodes + 1))
    QuestHelper: Assert(CurrentNodes < MaxNodes)
    local newadj = {}
    local newweight = {}
    local src = 1
    local dst = 1
    for y=1, CurrentNodes do  
      for x=1, CurrentNodes + 1 do
        if x == CurrentNodes + 1 then
          newadj[dst] = 0
          newweight[dst] = 0
          dst = dst + 1
        else
          newadj[dst] = Distance[src]
          newweight[dst] = Weight[src]
          dst = dst + 1
          src = src + 1
        end
      end
    end
    for x=1, CurrentNodes + 1 do
      newadj[dst] = 0
      newweight[dst] = 0
      dst = dst + 1
    end
    --[[
    RTO(tostring(src))
    RTO(tostring(#Distance))
    RTO(tostring(dst))
    RTO(tostring(CurrentNodes))]]
    
    QuestHelper: Assert(src == #Distance + 1)
    QuestHelper: Assert(dst == (CurrentNodes + 1) * (CurrentNodes + 1) + 1)
    Distance = newadj
    Weight = newweight
    
    CurrentNodes = CurrentNodes + 1
    table.insert(DeadNodes, CurrentNodes)
    return AllocateExtraNode() -- ha ha
  end

  -- Set the start location
  function QH_Route_Core_SetStart(stt)
    -- We do some kind of ghastly things here.
    NodeLookup[StartNode] = nil
    NodeList[1] = stt
    StartNode = stt
    NodeLookup[StartNode] = 1
    
    for _, v in ipairs(ActiveNodes) do
      if v ~= 1 then
        Distance[GetIndex(1, v)] = Dist(NodeList[1], NodeList[v])
        Distance[GetIndex(v, 1)] = Dist(NodeList[v], NodeList[1])
      end
    end
    
    -- TODO: properly deallocate old startnode?
  end

  -- Add a node to route to
  function QH_Route_Core_NodeAdd(nod)
    --QuestHelper:TextOut(tostring(nod))
    --TestShit()
    QuestHelper: Assert(nod)
    QuestHelper: Assert(not NodeLookup[nod])
    
    local idx = AllocateExtraNode()
    --RTO("|cffFF8080AEN: " .. tostring(idx))
    NodeLookup[nod] = idx
    NodeList[idx] = nod
    for x = 1, #ActiveNodes do
      --RTO("ANIDX: " .. tostring(x))
      --RTO("ANIDXT: " .. tostring(ActiveNodes[x]))
      --RTO("ANIDXTNL: " .. tostring(NodeList[ActiveNodes[x]]))
      Distance[GetIndex(ActiveNodes[x], idx)] = Dist(NodeList[ActiveNodes[x]], nod)
      Distance[GetIndex(idx, ActiveNodes[x])] = Dist(nod, NodeList[ActiveNodes[x]])
      
      Weight[GetIndex(ActiveNodes[x], idx)] = weight_ave
      Weight[GetIndex(idx, ActiveNodes[x])] = weight_ave
    end
    --TestShit()
    
    DependencyCounts[idx] = 0
    
    last_best = nil
  end

  -- Remove a node with the given location
  function QH_Route_Core_NodeRemove(nod)
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
    
    DependencyCounts[idx] = nil
    
    if DependencyLinks[idx] then
      for k, v in pairs(DependencyLinks[idx]) do
        for m, f in pairs(DependencyLinksReverse[v]) do
          if f == idx then table.remove(DependencyLinksReverse[v], m) break end
        end
      end
    end
    DependencyLinks[idx] = nil
    
    if DependencyLinksReverse[idx] then
      for k, v in pairs(DependencyLinksReverse[idx]) do
        for m, f in pairs(DependencyLinks[v]) do
          if f == idx then table.remove(DependencyLinks[v], m) DependencyCounts[v] = DependencyCounts[v] - 1 break end
        end
      end
    end
    DependencyLinksReverse[idx] = nil
    
    last_best = nil
  end
-- End node allocation and deallocation

-- Add a note that node 1 makes node 2 obsolete (in some sense, it instantly completes node 2.) Right now, this is a symmetrical relationship.
function QH_Route_Core_NodeObsoletes()
end

-- Add a note that node 1 requires node 2.
function QH_Route_Core_NodeRequires(a, b)
  local aidx = NodeLookup[a]
  local bidx = NodeLookup[b]
  QuestHelper: Assert(aidx)
  QuestHelper: Assert(bidx)
  QuestHelper: Assert(aidx ~= bidx)
  
  DependencyCounts[aidx] = DependencyCounts[aidx] + 1
  
  if not DependencyLinks[aidx] then DependencyLinks[aidx] = {} end
  table.insert(DependencyLinks[aidx], bidx)
  
  if not DependencyLinksReverse[bidx] then DependencyLinksReverse[bidx] = {} end
  table.insert(DependencyLinksReverse[bidx], aidx)
end

-- Wipe and re-cache all distances.
function QH_Route_Core_DistanceClear()
end

--[==[

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
    for y = 1, #ActiveNodes do
      if not (Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]) == Distance[GetIndex(ActiveNodes[x], ActiveNodes[y])]) then
        RTO(string.format("%d/%d (%d/%d) should be %f, is %f", x, y, ActiveNodes[x], ActiveNodes[y], Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]),Distance[GetIndex(ActiveNodes[x], ActiveNodes[y])]))
        fail = true
      end
    end
  end
  QuestHelper: Assert(not fail)
end

function HackeryDump()
  local st = "{"
  for k, v in pairs(ActiveNodes) do
    if v ~= 1 then
      st = st .. string.format("{c = %d, x = %f, y = %f}, ", NodeList[k].loc.c, NodeList[k].loc.x, NodeList[k].loc.y)
    end
  end
  st = st .. "}"
  assert(false, st)
end
]==]

-- weeeeee
