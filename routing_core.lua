QuestHelper_File["routing_core.lua"] = "Development Version"
QuestHelper_Loadtime["routing_core.lua"] = GetTime()

-- Ant colony optimization. Moving from X to Y has the quality (Distance[x,y]^alpha)*(Weight[x,y]^beta). Sum all available qualities, then choose weighted randomly.
-- Weight adjustment: Weight[x,y] = Weight[x,y]*weightadj + (1/distance_of_travel)

-- Configuration
  local PheremonePreservation = 0.99 -- must be within 0 and 1 exclusive
  local AntCount = 20 -- number of ants to run before doing a pheremone pass

    -- Weighting for the various factors
  local WeightFactor = 1
  local DistanceFactor = -0.5
-- End configuration

local Notifier
local Dist

-- Node storage and data structures
  local MaxNodes = math.floor(math.sqrt(math.pow(2, 19)))
  RTO(tostring(MaxNodes))

  local CurrentNodes = 1
  local ActiveNodes = {1}
  local DeadNodes = {}

  local StartNode = {}

  local NodeLookup = {[StartNode] = 1}
  local NodeList = {[1] = StartNode}
  local Distance = {0}
  local Weight = {0}
  
  local weight_ave = 0.001

  local function GetIndex(x, y) return (x - 1) * CurrentNodes + y end
-- End node storage and data structures

-- Initialization
function Public_Init(PathNotifier, Distance)
  Notifier = PathNotifier
  Dist = Distance
  QuestHelper: Assert(Notifier)
  QuestHelper: Assert(Dist)
end
-- End initialization

local last_yell = GetTime()

local last_best = nil

local function GetWeight(x, y)
  if x == y then return 0.00000000001 end -- sigh
  local idx = GetIndex(x, y)
  if not Weight[idx] or not Distance[idx] then
    RTO(string.format("%d/%d %d", x, y, CurrentNodes))
    QuestHelper: Assert(x <= CurrentNodes)
    QuestHelper: Assert(y <= CurrentNodes)
  end
  return math.pow(Weight[idx], WeightFactor) * math.pow(Distance[idx], DistanceFactor)
end

local function RunAnt()
  local route = NewRoute()
  route[1] = 1
  route.distance = 0
  
  local needed = {}
  local needed_count = -1 -- gets rid of 1 earlier
  for _, v in ipairs(ActiveNodes) do
    needed[v] = true
    needed_count = needed_count + 1
  end
  needed[1] = nil
  
  local curloc = 1
  
  while needed_count > 0 do
    local accumulated_weight = 0
    local tweight = 0
    for k, _ in pairs(needed) do
      QuestHelper:TextOut(tostring(GetWeight(curloc, k)))
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
    
    needed[nod] = nil
    needed_count = needed_count - 1
    route.distance = route.distance + Distance[GetIndex(curloc, nod)]
    table.insert(route, nod)
    curloc = nod
  end
  
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

-- Core loop
function Public_Process()
  QuestHelper: Assert(Notifier)
  QuestHelper: Assert(Dist)
  
  while true do
    if GetTime() > last_yell + 5 then
      RTO("still tickin'")
      last_yell = GetTime()
    end
    
    local trouts = {}
    for x = 1, AntCount do
      table.insert(trouts, RunAnt())
      --if last_best then RTO(string.format("Path generated: %s vs %s", PathToString(trouts[#trouts]), PathToString(last_best))) end
      if not last_best or last_best.distance > trouts[#trouts].distance then
        last_best = trouts[#trouts]
        BetterRoute(last_best)
      end
    end
    
    for _, x in ipairs(ActiveNodes) do
      for _, y in ipairs(ActiveNodes) do
        local idx = GetIndex(x, y)
        Weight[idx] = Weight[idx] * PheremonePreservation + 1e-20 -- ensure that it never hits 0
      end
    end
    
    for _, x in ipairs(trouts) do
      local amount = 1 / x.distance
      for y = 1, #x - 1 do
        local idx = GetIndex(x[y], x[y + 1])
        Weight[idx] = Weight[idx] + amount
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
    --QuestHelper:TextOut(tostring(weight_ave))
    
    QH_Timeslice_Yield()  -- "heh"
  end
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
    
    RTO(string.format("Expanding from %d to %d", CurrentNodes, CurrentNodes + 1))
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
  function Public_SetStart(stt)
    -- We do some kind of ghastly things here.
    NodeLookup[StartNode] = nil
    NodeList[1] = stt
    StartNode = stt
    NodeLookup[StartNode] = 1
    
    -- TODO: recalculate distances also
    -- TODO: properly deallocate old startnode
  end

  -- Add a node to route to
  function Public_NodeAdd(nod)
    TestShit()
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
    TestShit()
    
    last_best = nil
  end

  -- Remove a node with the given location
  function Public_NodeRemove(nod)
    TestShit()
    QuestHelper: Assert(nod)
    QuestHelper: Assert(NodeLookup[nod])
    --RTO("|cffFF8080RFN: " .. tostring(NodeLookup[nod]))
    NodeList[NodeLookup[nod]] = nil
    table.insert(DeadNodes, NodeLookup[nod])
    for k, v in pairs(ActiveNodes) do if v == NodeLookup[nod] then table.remove(ActiveNodes, k) break end end -- this is pretty awful
    NodeLookup[nod] = nil
    -- We don't have to modify the table itself, some sections are just "dead".
    TestShit()
    
    last_best = nil
  end
-- End node allocation and deallocation

-- Add a note that node 1 makes node 2 obsolete (in some sense, it instantly completes node 2.) Right now, this is a symmetrical relationship.
function Public_NodeObsoletes()
end

-- Add a note that node 1 requires node 2.
function Public_NodeRequires()
end

-- Wipe and re-cache all distances.
function Public_DistanceClear()
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
    for y = 1, #ActiveNodes do
      if not (Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]) == Distance[GetIndex(ActiveNodes[x], ActiveNodes[y])]) then
        RTO(string.format("%d/%d (%d/%d) should be %f, is %f", x, y, ActiveNodes[x], ActiveNodes[y], Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]),Distance[GetIndex(ActiveNodes[x], ActiveNodes[y])]))
        fail = true
      end
    end
  end
  QuestHelper: Assert(not fail)
end

-- weeeeee
