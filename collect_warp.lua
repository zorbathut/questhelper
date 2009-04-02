QuestHelper_File["collect_warp.lua"] = "Development Version"
QuestHelper_Loadtime["collect_warp.lua"] = GetTime()

local debug_output = false
if QuestHelper_File["collect_warp.lua"] == "Development Version" then debug_output = true end

local QHCW

local GetLoc
local Merger
local RawLocation

local lastloc_bolus
local lastloc_table

local function OnUpdate()
  local bolus, tab = GetLoc(), {RawLocation()}
  if lastloc_table and lastloc_table[2] and tab[2] and lastloc_table[3] and tab[3] and not lastloc_table[1] and not tab[1] then
    local leapy = false
    if lastloc_table[2] ~= tab[2] or lastloc_table[3] ~= tab[3] then
      leapy = true
    else
      local dx, dy = lastloc_table[4] - tab[4], lastloc_table[5] - tab[5]
      dx, dy = dx * dx, dy * dy
      if dx + dy > 25 * 25 then -- Blink is 20, so we need to do more than that.
        leapy = true
      end
    end
    
    if leapy then
      Merger.Add(QHCW, lastloc_bolus .. bolus)
    end
  end
  
  lastloc_bolus = bolus
  lastloc_table = tab
end

function QH_Collect_Warp_Init(QHCData, API)
  if not QHCData.warp then QHCData.warp = {} end
  QHCW = QHCData.warp
  
  API.Registrar_OnUpdateHook(OnUpdate)
  
  GetLoc = API.Callback_LocationBolusCurrent
  QuestHelper: Assert(GetLoc)
  
  RawLocation = API.Callback_Location_Raw
  QuestHelper: Assert(RawLocation)
  
  Merger = API.Utility_Merger
  QuestHelper: Assert(Merger)
end
