QuestHelper_File["routing_core.lua"] = "Development Version"
QuestHelper_Loadtime["routing_core.lua"] = GetTime()

-- Ant colony optimization. Moving from X to Y has the quality (Adjacency[x,y]^alpha)*(Weights[x,y]^beta). Sum all available qualities, then choose weighted randomly.
-- Weight adjustment: Weight[x,y] = Weight[x,y]*weightadj + (1/distance_of_travel)

-- Configuration
  local PheremonePreservation = 0.8 -- must be within 0 and 1 exclusive
  local AntCount = 20 -- number of ants to run before doing a pheremone pass

    -- Weighting for the various factors
  local PheremoneFactor = 1
  local WeightFactor = 1
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
  local Adjacency = {0}
  local Weights = {0}

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

-- Core loop
function Public_Process()
  QuestHelper: Assert(Notifier)
  QuestHelper: Assert(Dist)
  while true do
    if GetTime() > last_yell + 5 then
      RTO("still tickin'")
      last_yell = GetTime()
    end
    
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
          newadj[dst] = Adjacency[src]
          newweight[dst] = Weights[src]
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
    RTO(tostring(#Adjacency))
    RTO(tostring(dst))
    RTO(tostring(CurrentNodes))]]
    
    QuestHelper: Assert(src == #Adjacency + 1)
    QuestHelper: Assert(dst == (CurrentNodes + 1) * (CurrentNodes + 1) + 1)
    Adjacency = newadj
    Weights = newweight
    
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
      Adjacency[GetIndex(ActiveNodes[x], idx)] = Dist(NodeList[ActiveNodes[x]], nod)
      Adjacency[GetIndex(idx, ActiveNodes[x])] = Dist(nod, NodeList[ActiveNodes[x]])
      
      -- I don't even know what default weights should look like, so, you know, fuck the man and all
    end
    TestShit()
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
      ts = ts .. string.format("%f ", Adjacency[GetIndex(ActiveNodes[x], ActiveNodes[y])])
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
      if not (Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]) == Adjacency[GetIndex(ActiveNodes[x], ActiveNodes[y])]) then
        RTO(string.format("%d/%d (%d/%d) should be %f, is %f", x, y, ActiveNodes[x], ActiveNodes[y], Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]),Adjacency[GetIndex(ActiveNodes[x], ActiveNodes[y])]))
        fail = true
      end
    end
  end
  QuestHelper: Assert(not fail)
end

-- weeeeee
