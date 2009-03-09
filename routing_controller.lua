QuestHelper_File["routing_controller.lua"] = "Development Version"
QuestHelper_Loadtime["routing_controller.lua"] = GetTime()

local Route_Core_Process = QH_Route_Core_Process

local Route_Core_NodeCount = QH_Route_Core_NodeCount

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
  QuestHelper: Assert(node.map_desc)
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
  function(path)
    local real_path = {}
    for k, v in ipairs(path) do
      table.insert(real_path, v)
      if path[k + 1] then
        local nrt = QH_Graph_Pathfind(path[k].loc, path[k + 1].loc, false, true)
        QuestHelper: Assert(nrt)
        if nrt.path then for _, wp in ipairs(nrt.path) do
          QuestHelper: Assert(wp.c)
          table.insert(real_path, {loc = {x = wp.x, y = wp.y, c = wp.c}, ignore = true, map_desc = wp.map_desc})
        end end
      end
    end
    
    for _, v in pairs(notification_funcs) do
      v(real_path)
    end
  end,
  function(loc1, loc2)
    QH_Timeslice_Yield()
    -- Distance function
    local v = QH_Graph_Pathfind(loc1.loc, loc2.loc)
    if not v then
      QuestHelper:TextOut(QuestHelper:StringizeTable(loc1.loc))
      QuestHelper:TextOut(QuestHelper:StringizeTable(loc2.loc))
      QuestHelper: Assert(v)
    end
    return v
  end,
  function(loc1, loctable, reverse)
    local lt = {}
    for _, v in ipairs(loctable) do
      table.insert(lt, v.loc)
    end
    local rv = QH_Graph_Pathmultifind(loc1.loc, lt, reverse)
    for k, v in ipairs(lt) do
      if not rv[k] then
        QuestHelper:TextOut(QuestHelper:StringizeTable(loc1.loc))
        QuestHelper:TextOut(QuestHelper:StringizeTable(lt[k]))
      end
      QuestHelper: Assert(rv[k])
    end
    return rv
  end
)

local StartObjective = {desc = "Start", tracker_hidden = true} -- this should never be displayed

local lapa = GetTime()
local passcount = 0

local lc, lx, ly, lrc, lrz

local function process()
  -- Order here is important. We don't want to update the location, then wait for a while as we add nodes. We also need the location updated before the first nodes are added. This way, it all works and we don't need anything outside the loop.
  while true do
    local c, x, y, rc, rz = QuestHelper.collect_c, QuestHelper.collect_x, QuestHelper.collect_y, QuestHelper.c, QuestHelper.z  -- ugh we need a better solution to this, but with this weird "planes" hybrid there just isn't one right now
    if c and x and y and (c ~= lc or x ~= lx or y ~= ly or rc ~= lrc or rz ~= lrz) then
      --local t = GetTime()
      lc, lx, ly, lrc, lrz = c, x, y, rc, rz
      Route_Core_SetStart({desc = "Start", why = StartObjective, loc = NewLoc(c, x, y, rc, rz), tracker_hidden = true, ignore = true})
      --QuestHelper: TextOut(string.format("SS takes %f", GetTime() - t))
    end
    
    Route_Core_Process()
    
    passcount = passcount + 1
    if lapa + 60 < GetTime() then
      QuestHelper:TextOut(string.format("%d passes in the last minute, %d nodes", passcount, Route_Core_NodeCount()))
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
