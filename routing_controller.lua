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

local Route_Core_IgnoreCluster = QH_Route_Core_IgnoreCluster
local Route_Core_UnignoreCluster = QH_Route_Core_UnignoreCluster

QH_Route_Core_Process = nil
QH_Route_Core_Init = nil
QH_Route_Core_NodeAdd = nil
QH_Route_Core_NodeRemove = nil
QH_Route_Core_SetStart = nil
QH_Route_Core_NodeObsoletes = nil
QH_Route_Core_NodeRequires = nil
QH_Route_Core_DistanceClear = nil
QH_Route_Core_IgnoreCluster = nil
QH_Route_Core_UnignoreCluster = nil

local pending = {}

-- Every minute or two, we dump the inactive and move active to inactive. Every time we touch something, we put it in active.
local pathcache_active = {}
local pathcache_inactive = {}

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
    if not pathcache_active[loc1] then pathcache_active[loc1] = {} end
    if not pathcache_inactive[loc1] then pathcache_inactive[loc1] = {} end
    pathcache_active[loc1][loc2] = nrt
    pathcache_inactive[loc1][loc2] = nrt
    return nrt
  else
    hits = hits + 1
    if not pathcache_active[loc1] then pathcache_active[loc1] = {} end
    pathcache_active[loc1][loc2] = pathcache_inactive[loc1][loc2]
    return pathcache_active[loc1][loc2]
  end
end

local last_path = nil

local function ReplotPath()
  if not last_path then return end  -- siiigh
  
  local real_path = {}
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
      
      if nrt.path then for _, wp in ipairs(nrt.path) do
        QuestHelper: Assert(wp.c)
        
        if condense_type and condense_type ~= wp.condense_type then condense_doit() end
        
        table.insert(real_path, {loc = {x = wp.x, y = wp.y, c = wp.c}, ignore = true, map_desc = wp.map_desc, map_desc_chain = last_path[k + 1]}) -- Technically, we'll end up with the distance to the next objective. I'm okay with this.
        
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
end


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

function QH_Route_IgnoreCluster(clust, reason)
  print(clust, reason)
  table.insert(pending, function () Route_Core_IgnoreCluster(clust, reason) end)
end

function QH_Route_UnignoreCluster(clust, reason)
  table.insert(pending, function () Route_Core_UnignoreCluster(clust, reason) end)
end

function QH_Route_FlightPathRecalc()
  table.insert(pending, function () QH_redo_flightpath() pathcache_active = {} pathcache_inactive = {} Route_Core_DistanceClear() ReplotPath() end)
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
    
    if not pathcache_active[loc1] then pathcache_active[loc1] = {} end
    if not pathcache_inactive[loc1] then pathcache_inactive[loc1] = {} end
    
    local lt = {}
    for _, v in ipairs(loctable) do
      QuestHelper: Assert(v.loc)
      table.insert(lt, v.loc)
      
      if not pathcache_active[v] then pathcache_active[v] = {} end
      if not pathcache_inactive[v] then pathcache_inactive[v] = {} end
    end
    local rv = QH_Graph_Pathmultifind(loc1.loc, lt, reverse, true)
    
    local rvv = {}
    for k, v in ipairs(lt) do
      if not rv[k] then
        QuestHelper:TextOut(QuestHelper:StringizeTable(loc1.loc))
        QuestHelper:TextOut(QuestHelper:StringizeTable(lt[k]))
      end
      QuestHelper: Assert(rv[k])
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
    return rvv
  end
)

local StartObjective = {desc = "Start", tracker_hidden = true} -- this should never be displayed

local lapa = GetTime()
local passcount = 0

local lc, lx, ly, lrc, lrz

local function process()

  local last_cull = 0
  
  -- Order here is important. We don't want to update the location, then wait for a while as we add nodes. We also need the location updated before the first nodes are added. This way, it all works and we don't need anything outside the loop.
  while true do
    if last_cull + 120 < GetTime() then
      last_cull = GetTime()
      pathcache_inactive = pathcache_active
      pathcache_active = {} -- eat it, garbage collector
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
