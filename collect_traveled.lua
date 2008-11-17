QuestHelper_File["collect_traveled.lua"] = "Development Version"

local QHCT

local cc, cx, cy, cd = nil, nil, nil, nil
local flags = {}

local nx, ny = nil, nil

local function round(x) return math.floor(x + 0.5) end
local function dist(x, y) return math.abs(x) + math.abs(y) end  -- fuck it, manhattan distance

-- ++ is turning right
local dx = {1, 0, -1, 0}
local dy = {0, 1, 0, -1}

local function InitWorking()
  QHCT.working.prefix = ""
end

local function AddDataPrefix(data)
  QHCT.working.prefix = QHCT.working.prefix .. data
end

local function AddData(data)
  QuestHelper:TextOut(string.format("Adding data %s", data))
  table.insert(QHCT.working, data)
  for i = #QHCT.working - 1, 1, -1 do
    if string.len(QHCT.working[i]) > string.len(QHCT.working[i + 1]) then break end
    QHCT.working[i] = QHCT.working[i] .. table.remove(QHCT.working, i + 1)
  end
end

local function FinishData()
  for i=#QHCT.working - 1, 1, -1 do
    QHCT.working[i] = QHCT.working[i] .. table.remove(QHCT.working)
  end
  return QHCT.working[1] or ""
end

local function TestDirection(nd, kar)
  if nd < 1 then nd = nd + 4 end
  if nd > 4 then nd = nd - 4 end
  
  if dist(cx + dx[nd] - nx , cy + dy[nd] - ny) < dist(cx - nx, cy - ny) then
    AddData(kar)
    cd = nd
    cx = cx + dx[cd]
    cy = cy + dy[cd]
    return true
  else
    return false
  end
end

local function CompressAndComplete(ki)
  QuestHelper:TextOut(string.format("%d tokens", #QHCT.compressing[ki].data))
  local tim = GetTime()
  local lzwed = QH_LZW_Compress(QHCT.compressing[ki].data, 256, 8) -- this will be tweaked heavily
  QuestHelper:TextOut(string.format("%d tokens: compressed to %d in %f", #QHCT.compressing[ki].data, #lzwed, GetTime() - tim))
  
  if not QHCT.done then QHCT.done = {} end
  table.insert(QHCT.done, QHCT.compressing[ki].prefix .. lzwed)
  QHCT.compressing[ki] = nil
end

local function CompileData()
  local data = FinishData()
  local prefix = QHCT.working.prefix
  
  QHCT.working = {}
  InitWorking()
  
  if #data > 0 then
    if not QHCT.compressing then QHCT.compressing = {} end
    local ki = GetTime()
    while QHCT.compressing[ki] do ki = ki + 1 end -- if this ever triggers, I'm shocked
    
    QHCT.compressing[ki] = {data = data, prefix = prefix}
    
    QH_Timeslice_Add(function () CompressAndComplete(ki) end, 2, "lzw")
  end
end

function AppendFlag(flagval, flagid)
  flagval = not not flagval
  flags[flagid] = not not flags[flagid]
  if flagval ~= flags[flagid] then
    flags[flagid] = flagval
    AddData(flagid)
  end
end

function QH_Collect_Traveled_Point(c, x, y)
  nx, ny = round(x), round(y)
  if c ~= cc or dist(nx - cx, ny - cy) > 10 then
    CompileData()
    
    cc, cx, cy, cd = c, nx, ny, 1
    swim, mount, flying, taxi = false, false, false, false
    AddDataPrefix(string.format("%d,%d,%d,%d|", cc, cx, cy, QuestHelper:PlayerFaction()))
  end
  
  AppendFlag(IsMounted(), 'M')
  AppendFlag(IsFlying(), 'Y')
  AppendFlag(IsSwimming(), 'S')
  AppendFlag(UnitOnTaxi("player"), 'X')
  
  for x = 1, dist(nx - cx, ny - cy) - 1 do
    AddData('C')
  end
  
  -- first we go forward as much as is reasonable
  while TestDirection(cd, '^') do end
  
  if TestDirection(cd + 1, '>') then -- if we can go right, we do so, then we go forward again
    while TestDirection(cd, '^') do end
    -- In theory, if the original spot was back-and-to-the-right of us, we could need to go right *again* and then forward *again*. So we do.
    if TestDirection(cd + 1, '>') then
      while TestDirection(cd, '^') do end
    end
  elseif TestDirection(cd - 1, '<') then -- the same logic applies for left.
    while TestDirection(cd, '^') do end
    if TestDirection(cd - 1, '<') then
      while TestDirection(cd, '^') do end
    end
  else
    -- And we also test back, just in case.
    if TestDirection(cd + 2, 'v') then
      while TestDirection(cd, '^') do end
    end
  end
  
  QuestHelper:Assert(cx == nx and cy == ny)
  -- Done!
end

function QH_Collect_Traveled_Init(QHCData)
  if not QHCData.traveled then QHCData.traveled = {} end
  QHCT = QHCData.traveled
  
  if not QHCT.working then QHCT.working = {} ; InitWorking() end
end

function hackeryflush()
  CompileData()
  cc = nil
end
