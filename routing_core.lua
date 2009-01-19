QuestHelper_File["routing_core.lua"] = "Development Version"
QuestHelper_Loadtime["routing_core.lua"] = GetTime()


local Notifier
local Dist

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

-- Add a node to route to
function Public_NodeAdd()
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


-- weeeeee
