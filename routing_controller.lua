QuestHelper_File["routing_controller.lua"] = "Development Version"
QuestHelper_Loadtime["routing_controller.lua"] = GetTime()

local Route_Core_Process = QH_Route_Core_Process

local Route_Core_Init = QH_Route_Core_Init
local Route_Core_NodeAdd = QH_Route_Core_NodeAdd
local Route_Core_NodeRemove = QH_Route_Core_NodeRemove
local Route_Core_SetStart = QH_Route_Core_SetStart

local Route_Core_ClusterAdd = QH_Route_Core_ClusterAdd
local Route_Core_ClusterRemove = QH_Route_Core_ClusterRemove
local Route_Core_ClusterRequires = QH_Route_Core_ClusterRequires
local Route_Core_DistanceClear = QH_Route_Core_DistanceClear

QH_Route_Core_Process = nil
QH_Route_Core_Init = nil
QH_Route_Core_NodeAdd = nil
QH_Route_Core_NodeRemove = nil
QH_Route_Core_SetStart = nil
QH_Route_Core_NodeObsoletes = nil
QH_Route_Core_NodeRequires = nil
QH_Route_Core_DistanceClear = nil


local pending = {}

function QH_Route_NodeAdd(node)
  table.insert(pending, function () Route_Core_NodeAdd(node) end)
end

function QH_Route_NodeRemove(node)
  table.insert(pending, function () Route_Core_NodeRemove(node) end)
end

function QH_Route_ClusterAdd(node)
  table.insert(pending, function () Route_Core_ClusterAdd(node) end)
end

function QH_Route_ClusterRemove(node)
  table.insert(pending, function () Route_Core_ClusterRemove(node) end)
end

function QH_Route_ClusterRequires(a, b)
  table.insert(pending, function () Route_Core_ClusterRequires(a, b) end)
end

local notification_funcs = {}

function QH_Route_RegisterNotification(func)
  table.insert(notification_funcs, func)
end

Route_Core_Init(
  function(path) for _, v in pairs(notification_funcs) do v(path) end end,
  function(loc1, loc2)
    -- Distance function
    if loc1.loc.c == loc2.loc.c then
      local dx = loc1.loc.x - loc2.loc.x
      local dy = loc1.loc.y - loc2.loc.y
      return math.sqrt(dx * dx + dy * dy)
    else
      return 100000 -- one milllllion time units
    end
  end
)

local StartObjective = {desc = "Start", tracker_hidden = true} -- this should never be displayed

local lapa = GetTime()
local passcount = 0

local function process()
  -- Order here is important. We don't want to update the location, then wait for a while as we add nodes. We also need the location updated before nodes are added. This way, it all works and we don't need anything outside the loop.
  while true do
    local c, x, y = QuestHelper:RetrieveRawLocation()
    if c and x and y then
      Route_Core_SetStart({desc = "Start", why = StartObjective, loc = NewLoc(c, x, y, "Start"), tracker_hidden = true})
    end
    
    Route_Core_Process()
    
    passcount = passcount + 1
    if lapa + 60 < GetTime() then
      QuestHelper:TextOut(string.format("%d passes in the last minute", passcount))
      lapa = lapa + 60
      passcount = 0
    end
    
    QH_Timeslice_Yield()
    
    -- snag stuff so we don't accidentally end up changing pending in two things at once
    while #pending > 0 do
      local lpending = pending
      pending = {}
      
      for k, v in ipairs(lpending) do
        v()
        QH_Timeslice_Yield()
      end
    end
  end
end

QH_Timeslice_Add(process, "new_routing")
