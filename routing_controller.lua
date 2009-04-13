QuestHelper_File["routing_controller.lua"] = "Development Version"
QuestHelper_Loadtime["routing_controller.lua"] = GetTime()

local debug_output = (QuestHelper_File["routing_controller.lua"] == "Development Version")

local Route_Core_Process = QH_Route_Core_Process

local Route_Core_NodeCount = QH_Route_Core_NodeCount

local Route_Core_Init = QH_Route_Core_Init
local Route_Core_SetStart = QH_Route_Core_SetStart

local Route_Core_ClusterAdd = QH_Route_Core_ClusterAdd
local Route_Core_ClusterRemove = QH_Route_Core_ClusterRemove
local Route_Core_ClusterRequires = QH_Route_Core_ClusterRequires
local Route_Core_DistanceClear = QH_Route_Core_DistanceClear

local Route_Core_IgnoreNode = QH_Route_Core_IgnoreNode
local Route_Core_UnignoreNode = QH_Route_Core_UnignoreNode
local Route_Core_IgnoreCluster = QH_Route_Core_IgnoreCluster
local Route_Core_UnignoreCluster = QH_Route_Core_UnignoreCluster

local Route_Core_GetClusterPriority = QH_Route_Core_GetClusterPriority
local Route_Core_SetClusterPriority = QH_Route_Core_SetClusterPriority

local Route_Core_TraverseNodes = QH_Route_Core_TraverseNodes
local Route_Core_TraverseClusters = QH_Route_Core_TraverseClusters
local Route_Core_IgnoredReasons_Cluster = QH_Route_Core_IgnoredReasons_Cluster
local Route_Core_IgnoredReasons_Node = QH_Route_Core_IgnoredReasons_Node
local Route_Core_Ignored_Cluster = QH_Route_Core_Ignored_Cluster

QH_Route_Core_Process = nil
QH_Route_Core_Init = nil
QH_Route_Core_SetStart = nil
QH_Route_Core_NodeObsoletes = nil
QH_Route_Core_NodeRequires = nil
QH_Route_Core_DistanceClear = nil
QH_Route_Core_IgnoreNode = nil
QH_Route_Core_UnignoreNode = nil
QH_Route_Core_IgnoreCluster = nil
QH_Route_Core_UnignoreCluster = nil
QH_Route_Core_GetClusterPriority = nil
QH_Route_Core_SetClusterPriority = nil
QH_Route_Core_TraverseNodes = nil
QH_Route_Core_TraverseClusters = nil
QH_Route_Core_IgnoredReasons_Cluster = nil
QH_Route_Core_IgnoredReasons_Node = nil
QH_Route_Core_Ignored_Cluster = nil

local pending = {}

local weak_key = {__mode="k"}

local function new_pathcache_table()
  return setmetatable(QuestHelper:CreateTable("controller cache"), weak_key)
end

-- Every minute or two, we dump the inactive and move active to inactive. Every time we touch something, we put it in active.
local pathcache_active = new_pathcache_table()
local pathcache_inactive = new_pathcache_table()

local function pcs(tpcs)
  local ct = 0
  for _, v in pairs(tpcs) do
    for _, t in pairs(v) do
      ct = ct + 1
    end
  end
  return ct
end

function QH_PrintPathcacheSize()
  QuestHelper:TextOut(string.format("Active pathcache: %d", pcs(pathcache_active)))
  QuestHelper:TextOut(string.format("Inactive pathcache: %d", pcs(pathcache_inactive)))
end
function QH_ClearPathcache()
  print("START")
  QuestHelper:Top()
  QH_PrintPathcacheSize()
  pathcache_active = new_pathcache_table()
  pathcache_inactive = new_pathcache_table()
  print("CLEARED")
  QuestHelper:Top()
  QH_PrintPathcacheSize()
  print("END")
end

local notification_funcs = {}

function QH_Route_RegisterNotification(func)
  table.insert(notification_funcs, func)
end

local hits = 0
local misses = 0

local function GetCachedPath(loc1, loc2)
  -- If it's in active, it's guaranteed to be in inactive.
  if not pathcache_inactive[loc1] or not pathcache_inactive[loc1][loc2] then
    -- Not in either, time to create
    misses = misses + 1
    local nrt = QH_Graph_Pathfind(loc1.loc, loc2.loc, false, true)
    QuestHelper: Assert(nrt)
    if not pathcache_active[loc1] then pathcache_active[loc1] = new_pathcache_table() end
    if not pathcache_inactive[loc1] then pathcache_inactive[loc1] = new_pathcache_table() end
    pathcache_active[loc1][loc2] = nrt
    pathcache_inactive[loc1][loc2] = nrt
    return nrt
  else
    hits = hits + 1
    if not pathcache_active[loc1] then pathcache_active[loc1] = new_pathcache_table() end
    pathcache_active[loc1][loc2] = pathcache_inactive[loc1][loc2]
    return pathcache_active[loc1][loc2]
  end
end

local last_path = nil
local cleanup_path = nil

local function ReplotPath()
  if not last_path then return end  -- siiigh
  
  local real_path = QuestHelper:CreateTable("path")
  hits = 0
  misses = 0
  
  local distance = 0
  for k, v in ipairs(last_path) do
    QuestHelper: Assert(not v.condense_type) -- no
    v.distance = distance -- I'm not a huge fan of mutating things like this, but it is safe, and these nodes are technically designed to be modified during runtime anyway
    table.insert(real_path, v)
    if last_path[k + 1] then
      local nrt = GetCachedPath(last_path[k], last_path[k + 1])
      distance = distance + nrt.d
      QuestHelper: Assert(nrt)
      
      -- The "condense" is kind of weird - we're actually condensing descriptions, but we condense to the *last* item. Urgh.
      local condense_start = nil
      local condense_type = nil
      local condense_to = nil
      
      -- ugh this is just easier
      local function condense_doit()
        for i = condense_start, #real_path do
          real_path[i].map_desc = condense_to
        end
        condense_start, condense_type, condense_to = nil, nil, nil
      end
      
      if #nrt > 0 then for _, wp in ipairs(nrt) do
        QuestHelper: Assert(wp.c)
        
        if condense_type and condense_type ~= wp.condense_type then condense_doit() end
        
        local pathnode = QuestHelper:CreateTable("pathnode")
        pathnode.loc = QuestHelper:CreateTable("pathnode.loc")
        pathnode.loc.x = wp.x
        pathnode.loc.y = wp.y
        pathnode.loc.c = wp.c
        pathnode.ignore = true
        pathnode.map_desc = wp.map_desc
        pathnode.map_desc_chain = last_path[k + 1]
        pathnode.local_allocated = true
        table.insert(real_path, pathnode) -- Technically, we'll end up with the distance to the next objective. I'm okay with this.
        
        if not condense_type and wp.condense_type then
          condense_start, condense_type, condense_to = #real_path, wp.condense_type, wp.map_desc
        end
      end end
      
      if condense_type then condense_doit() end -- in case we have stuff left over
    end
  end
  
  for _, v in pairs(notification_funcs) do
    v(real_path)
  end
  
  -- I hate having to do this, I feel like I'm just begging for horrifying bugs
  if cleanup_path then
    for k, v in ipairs(cleanup_path) do
      if v.local_allocated then
        QuestHelper:ReleaseTable(v.loc)
        QuestHelper:ReleaseTable(v)
      end
    end
    
    QuestHelper:ReleaseTable(cleanup_path)
    cleanup_path = nil
  end
  
  cleanup_path = real_path
end

local filters = {}

function QH_Route_RegisterFilter(filter)
  QuestHelper: Assert(not filters[filter.name])
  QuestHelper: Assert(filter)
  filters[filter.name] = filter
end

-- we deal very badly with changing the requirement links after things are set up, so right now we're just relying on the fact that everything is unchanging afterwards
-- this is one reason the API is not considered stable :P
local function ScanNode(node, ...)
  local stupid_lua = {...}
  table.insert(pending, function ()
    for k, v in pairs(filters) do
      if v:Process(node, unpack(stupid_lua)) then
        Route_Core_IgnoreNode(node, v)
      else
        Route_Core_UnignoreNode(node, v)
      end
    end
  end)
end

local function ScanCluster(clust)
  table.insert(pending, function ()
    for _, v in ipairs(clust) do
      ScanNode(v)
    end
  end)
end

function QH_Route_Filter_Rescan(name)
  QuestHelper: Assert(not name or filters[name])
  table.insert(pending, function ()
    Route_Core_TraverseNodes(function (...)
      ScanNode(...)  -- yeah, so we're really rescanning every node, aren't we. laaaazy
    end)
  end)
end

function QH_Route_IgnoreNode(node, reason)
  table.insert(pending, function () Route_Core_IgnoreNode(node, reason) end)
end

function QH_Route_UnignoreNode(node, reason)
  table.insert(pending, function () Route_Core_UnignoreNode(node, reason) end)
end

function QH_Route_ClusterAdd(clust)
  table.insert(pending, function () Route_Core_ClusterAdd(clust) ScanCluster(clust) end)
end

function QH_Route_ClusterRemove(clust)
  table.insert(pending, function () Route_Core_ClusterRemove(clust) end)
end

function QH_Route_ClusterRequires(a, b)
  table.insert(pending, function () Route_Core_ClusterRequires(a, b) end)
end

function QH_Route_IgnoreCluster(clust, reason)
  table.insert(pending, function () Route_Core_IgnoreCluster(clust, reason) end)
end

function QH_Route_UnignoreCluster(clust, reason)
  table.insert(pending, function () Route_Core_UnignoreCluster(clust, reason) end)
end

function QH_Route_UnignoreCluster(clust, pri)
  table.insert(pending, function () Route_Core_UnignoreCluster(clust, reason) end)
end

function QH_Route_SetClusterPriority(clust, pri)
  table.insert(pending, function () Route_Core_SetClusterPriority(clust, pri) end)
end

function QH_Route_FlightPathRecalc()
  table.insert(pending, function () QH_redo_flightpath() pathcache_active = new_pathcache_table() pathcache_inactive = new_pathcache_table() Route_Core_DistanceClear() ReplotPath() end)
end
QH_Route_FlightPathRecalc() -- heh heh

-- Right now we just defer to the existing ones
function QH_Route_TraverseNodes(func)
  return Route_Core_TraverseNodes(func)
end
function QH_Route_TraverseClusters(func)
  return Route_Core_TraverseClusters(func)
end
function QH_Route_IgnoredReasons_Cluster(clust, func)
  return Route_Core_IgnoredReasons_Cluster(clust, func)
end
function QH_Route_IgnoredReasons_Node(node, func)
  return Route_Core_IgnoredReasons_Node(node, func)
end
function QH_Route_Ignored_Cluster(clust)
  return Route_Core_Ignored_Cluster(clust)
end
function QH_Route_GetClusterPriority(clust)
  return Route_Core_GetClusterPriority(clust)
end



Route_Core_Init(
  function(path)
    last_path = path
    ReplotPath()
  end,
  function(loc1, loctable, reverse)
    QH_Timeslice_Yield()
    QuestHelper: Assert(loc1)
    QuestHelper: Assert(loc1.loc)
    
    if not pathcache_active[loc1] then pathcache_active[loc1] = new_pathcache_table() end
    if not pathcache_inactive[loc1] then pathcache_inactive[loc1] = new_pathcache_table() end
    
    local lt = QuestHelper:CreateTable("route controller path shunt loctable")
    for _, v in ipairs(loctable) do
      QuestHelper: Assert(v.loc)
      table.insert(lt, v.loc)
      
      if not pathcache_active[v] then pathcache_active[v] = new_pathcache_table() end
      if not pathcache_inactive[v] then pathcache_inactive[v] = new_pathcache_table() end
    end
    local rv = QH_Graph_Pathmultifind(loc1.loc, lt, reverse, true)
    
    local rvv = QuestHelper:CreateTable("route controller path shunt returnvalue")
    for k, v in ipairs(lt) do
      if not rv[k] then
        QuestHelper:TextOut(QuestHelper:StringizeTable(loc1.loc))
        QuestHelper:TextOut(QuestHelper:StringizeTable(lt[k]))
      end
      QuestHelper: Assert(rv[k], string.format("%d to %d", loc1.loc.p, loctable[k].loc.p))
      QuestHelper: Assert(rv[k].d)
      rvv[k] = rv[k].d
      
      -- We're only setting the inactive to give the garbage collector potentially a little more to clean up (i.e. the old path.)
      if not reverse then
        pathcache_active[loc1][loctable[k]] = rv[k]
        pathcache_inactive[loc1][loctable[k]] = rv[k]
      else
        pathcache_active[loctable[k]][loc1] = rv[k]
        pathcache_inactive[loctable[k]][loc1] = rv[k]
      end
    end
    
    QuestHelper:ReleaseTable(lt)
    QuestHelper:ReleaseTable(rv)  -- this had better be releasable
    return rvv
  end
)

local StartObjective = {desc = "Start", tracker_hidden = true} -- this should never be displayed

local lapa = GetTime()
local passcount = 0

local lc, lx, ly, lrc, lrz

local last_playerpos = nil

local function ReleaseShard(ki, shard)
  for k, tv in pairs(shard) do
    if not pathcache_active[ki] or not pathcache_active[ki][k] then QuestHelper:ReleaseTable(tv) end
  end
  QuestHelper:ReleaseTable(shard)
end

local function process()

  local last_cull = 0
  
  local first = true
  -- Order here is important. We don't want to update the location, then wait for a while as we add nodes. We also need the location updated before the first nodes are added. This way, it all works and we don't need anything outside the loop.
  while true do
    if last_cull + 120 < GetTime() then
      last_cull = GetTime()
      
      for k, v in pairs(pathcache_inactive) do
        ReleaseShard(k, v)
      end
      QuestHelper:ReleaseTable(pathcache_inactive)
      
      pathcache_inactive = pathcache_active
      pathcache_active = new_pathcache_table()
    end
    
    local c, x, y, rc, rz = QuestHelper.collect_ac, QuestHelper.collect_ax, QuestHelper.collect_ay, QuestHelper.c, QuestHelper.z  -- ugh we need a better solution to this, but with this weird "planes" hybrid there just isn't one right now
    if c and x and y and rc and rz and (c ~= lc or x ~= lx or y ~= ly or rc ~= lrc or rz ~= lrz) then
      --local t = GetTime()
      lc, lx, ly, lrc, lrz = c, x, y, rc, rz
      
      local new_playerpos = {desc = "Start", why = StartObjective, loc = NewLoc(c, x, y, rc, rz), tracker_hidden = true, ignore = true}
      Route_Core_SetStart(new_playerpos)
      if last_path then last_path[1] = new_playerpos end
      --QuestHelper: TextOut(string.format("SS takes %f", GetTime() - t))
      ReplotPath()
      
      if last_playerpos then
        -- if it's in active, then it must be in inactive as well, so we do our actual deallocation in inactive only
        if pathcache_active[last_playerpos] then QuestHelper:ReleaseTable(pathcache_active[last_playerpos]) pathcache_active[last_playerpos] = nil end
        for k, v in pairs(pathcache_active) do v[last_playerpos] = nil end
        
        if pathcache_inactive[last_playerpos] then ReleaseShard(last_playerpos, pathcache_inactive[last_playerpos]) pathcache_inactive[last_playerpos] = nil end
        for k, v in pairs(pathcache_inactive) do if v[last_playerpos] then QuestHelper:ReleaseTable(v[last_playerpos]) v[last_playerpos] = nil end end
      end
      
      last_playerpos = new_playerpos
    end
    
    if not first then
      Route_Core_Process()
      QH_Timeslice_Doneinit()
    end
    first = false
    
    passcount = passcount + 1
    if lapa + 60 < GetTime() then
      if debug_output then QuestHelper:TextOut(string.format("%d passes in the last minute, %d nodes", passcount, Route_Core_NodeCount())) end
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
