QuestHelper_File["collect.lua"] = "Development Version"
QuestHelper_Loadtime["collect.lua"] = GetTime()

local QuestHelper_Collector_Version_Current = 3

QuestHelper_Collector = {}
QuestHelper_Collector_Version = QuestHelper_Collector_Version_Current

local EventRegistrar = {}
local OnUpdateRegistrar = {}
local TooltipRegistrar = {}

local frame = CreateFrame("Frame")

local function OnEvent(_, event, ...)
  local tstart = GetTime()
  for _, v in pairs(EventRegistrar[event]) do
    v(...)
  end
  QH_Timeslice_Increment(GetTime() - tstart, "collect_event")
end

frame:UnregisterAllEvents()
frame:SetScript("OnEvent", OnEvent)

frame:Show()

function EventHookRegistrar(event, func)
  QuestHelper:Assert(func)
  if not EventRegistrar[event] then
    frame:RegisterEvent(event)
    EventRegistrar[event] = {}
  end
  table.insert(EventRegistrar[event], func)
end

function OnUpdateHookRegistrar(func)
  QuestHelper:Assert(func)
  table.insert(OnUpdateRegistrar, func)
end

local OriginalScript = GameTooltip:GetScript("OnShow")
GameTooltip:SetScript("OnShow", function (self, ...)
  if not self then self = GameTooltip end
  
  local tstart = GetTime()
  for k, v in pairs(TooltipRegistrar) do
    v(self, ...)
  end
  QH_Timeslice_Increment(GetTime() - tstart, "collect_tooltip") -- anything past here is not my fault
  if OriginalScript then
    return OriginalScript(self, ...)
  end
end)

function TooltipHookRegistrar(func)
  QuestHelper:Assert(func)
  table.insert(TooltipRegistrar, func)
end

local API = {
  Registrar_EventHook = EventHookRegistrar,
  Registrar_OnUpdateHook = OnUpdateHookRegistrar,
  Registrar_TooltipHook = TooltipHookRegistrar,
  Callback_RawLocation = function () return QuestHelper:RetrieveRawLocation() end,
}

function QH_Collector_Init()
  -- First we update shit
  if QuestHelper_Collector_Version == 1 then
    -- We basically just want to clobber all our old route data, it's not worth storing - it's all good data, it's just that we don't want to preserve relics of the old location system.
    for _, v in pairs(QuestHelper_Collector) do
      v.traveled = nil
    end
    
    QuestHelper_Collector_Version = 2
  end
  
  if QuestHelper_Collector_Version == 2 then
    -- Originally I split the zones based on locale. Later I just split everything based on locale. Discarding old data rather than doing the gymnastics needed to preserve it.
    -- This is turning into a routine. :D
    for _, v in pairs(QuestHelper_Collector) do
      v.zone = nil
    end
    
    QuestHelper_Collector_Version = 3
  end
  
  QuestHelper: Assert(QuestHelper_Collector_Version == QuestHelper_Collector_Version_Current)
  
  local sig = string.format("%s on %s/%s/%d", GetAddOnMetadata("QuestHelper", "Version"), GetBuildInfo(), GetLocale(), QuestHelper:PlayerFaction())
  if not QuestHelper_Collector[sig] then QuestHelper_Collector[sig] = {} end
  local QHCData = QuestHelper_Collector[sig]

  QH_Collect_Location_Init(nil, API)  -- Some may actually add their own functions to the API, and should go first. There's no real formalized order, I just know which depend on others. Location's sole job is to provide the standard location bolus. (Yeah. It's a bolus. Deal.)
  QH_Collect_Merger_Init(nil, API) -- etc
  QH_Collect_Patterns_Init(nil, API) -- etc
  
  QH_Collect_LZW_Init(nil, API) -- Depends on Merger
  
  QH_Collect_Achievement_Init(QHCData, API)
  QH_Collect_Traveled_Init(QHCData, API)
  QH_Collect_Zone_Init(QHCData, API)
  QH_Collect_Monster_Init(QHCData, API)
  QH_Collect_Item_Init(QHCData, API)
  QH_Collect_Object_Init(QHCData, API)
  QH_Collect_Flight_Init(QHCData, API)
  
  if not QHCData.realms then QHCData.realms = {} end
  QHCData.realms[GetRealmName()] = (QHCData.realms[GetRealmName()] or 0) + 1 -- I'm not entirely sure why I'm counting
end

function QH_Collector_OnUpdate()
  local tstart = GetTime()
  for _, v in pairs(OnUpdateRegistrar) do
    v()
  end
  QH_Timeslice_Increment(GetTime() - tstart, "collect_update")
end
