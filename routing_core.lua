QuestHelper_File["routing_core.lua"] = "Development Version"
QuestHelper_Loadtime["routing_core.lua"] = GetTime()


local Notifier
local Dist

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
  for y=1, CurrentNodes + 1 do
    if y == CurrentNodes then
      for x=1, CurrentNodes + 1 do
        newadj[dst] = 0
        newweight[dst] = 0
        dst = dst + 1
      end
    else
      for x=1, CurrentNodes + 1 do
        if x == CurrentNodes then
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
  end
  RTO(tostring(src))
  RTO(tostring(#Adjacency))
  RTO(tostring(dst))
  RTO(tostring(CurrentNodes))
  
  QuestHelper: Assert(src == #Adjacency + 1)
  QuestHelper: Assert(dst == (CurrentNodes + 1) * (CurrentNodes + 1) + 1)
  Adjacency = newadj
  Weights = newweight
  
  table.insert(DeadNodes, CurrentNodes)
  CurrentNodes = CurrentNodes + 1
  return AllocateExtraNode() -- ha ha
end

-- Initialize with the necessary functions
function Public_Init(PathNotifier, Distance)
  Notifier = PathNotifier
  Dist = Distance
  QuestHelper: Assert(Notifier)
  QuestHelper: Assert(Dist)
end

local last_yell = GetTime()

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
  QuestHelper: Assert(not NodeLookup[nod])
  
  local idx = AllocateExtraNode()
  RTO("AEN: " .. tostring(idx))
  NodeLookup[nod] = idx
  NodeList[idx] = nod
  for x = 1, #ActiveNodes do
    RTO("ANIDX: " .. tostring(x))
    RTO("ANIDXT: " .. tostring(ActiveNodes[x]))
    RTO("ANIDXTNL: " .. tostring(NodeList[ActiveNodes[x]]))
    Adjacency[GetIndex(x, idx)] = Dist(NodeList[ActiveNodes[x]], nod)
    Adjacency[GetIndex(idx, x)] = Dist(nod, NodeList[ActiveNodes[x]])
    
    -- I don't even know what default weights should look like, so, you know, fuck the man and all
  end
  TestShit()
end

-- Remove a node with the given location
function Public_NodeRemove()
end

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
  for x = 1, #ActiveNodes do
    local ts = ""
    for y = 1, #ActiveNodes do
      ts = ts .. string.format("%f ", Adjacency[GetIndex(ActiveNodes[x], ActiveNodes[y])])
    end
    RTO(ts)
  end
  
  for x = 1, #ActiveNodes do
    for y = 1, #ActiveNodes do
      QuestHelper: Assert(Dist(NodeList[ActiveNodes[x]], NodeList[ActiveNodes[y]]) == Adjacency[GetIndex(ActiveNodes[x], ActiveNodes[y])])
    end
  end
end

-- weeeeee
