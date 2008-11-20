QuestHelper_File["collect_zone.lua"] = "Development Version"

local QHCZ

local GetLoc

local function DoZoneUpdate(label)
  local zname = string.format("%s@@%s@@%s", GetZoneText(), GetRealZoneText(), GetSubZoneText()) -- I don't *think* any zones will have a @@ in them :D
  if not QHCZ[zname] then QHCZ[zname] = {} end
  if not QHCZ[zname][label] then QHCZ[zname][label] = {} end
  -- MORE TO COME
  QuestHelper:TextOut("zoneupdate " .. zname .. " type " .. label)
  
  local st = ""
  local veep = GetLoc()
  for i = 1, #veep do
    st = st .. string.format("%d ", veep:byte(i))
  end
  QuestHelper:TextOut(st)
end

local function OnEvent()
  DoZoneUpdate("border")
end

local lastupdate = 0
local function OnUpdate()
  if lastupdate + 15 <= GetTime() then
    DoZoneUpdate("update")
    lastupdate = GetTime()
  end
end
  
function QH_Collect_Zone_Init(QHCData, API)
  if not QHCData.zone then QHCData.zone = {} end
  if not QHCData.zone[GetLocale()] then QHCData.zone[GetLocale()] = {} end    -- These are all localized names, so I'm gonna split it up along locale lines.
  QHCZ = QHCData.zone[GetLocale()]
  
  API.Registrar_EventHook("ZONE_CHANGED", OnEvent)
  API.Registrar_EventHook("ZONE_CHANGED_INDOORS", OnEvent)
  API.Registrar_EventHook("ZONE_CHANGED_NEW_AREA", OnEvent)
  
  API.Registrar_OnUpdateHook(OnUpdate)
  
  GetLoc = API.Callback_LocationBolusCurrent
end
