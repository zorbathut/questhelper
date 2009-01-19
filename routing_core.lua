QuestHelper_File["routing_core.lua"] = "Development Version"
QuestHelper_Loadtime["routing_core.lua"] = GetTime()


-- Initialize with the necessary functions
local function Public_Init(PathNotifier, Distance)
end

-- Process CPU for a bit
local function Public_Process()
end

-- Add a node to route to
local function Public_NodeAdd()
end

-- Remove a node with the given location
local function Public_NodeRemove()
end

-- Add a note that node 1 makes node 2 obsolete (in some sense, it instantly completes node 2.) Right now, this is a symmetrical relationship.
local function Public_NodeObsoletes()
end

-- Add a note that node 1 requires node 2.
local function Public_NodeRequires()
end

-- Wipe and re-cache all distances.
local function Public_DistanceClear()
end


-- weeeeee
