QuestHelper_File["collect.lua"] = "Development Version"

local QuestHelper_Collector_Version_Current = 2

QuestHelper_Collector = {}
QuestHelper_Collector_Version = QuestHelper_Collector_Version_Current

local EventRegistrar = {}
local OnUpdateRegistrar = {}

local frame = CreateFrame("Frame")

local function OnEvent(_, event, ...)
  for _, v in pairs(EventRegistrar[event]) do
    QuestHelper:TextOut(string.format("handling event %s", event))
    v() -- right now we don't deal with parameters in any way
  end
end

frame:UnregisterAllEvents()
frame:SetScript("OnEvent", OnEvent)

frame:Show()

function EventHookRegistrar(event, func)
  if not EventRegistrar[event] then
    frame:RegisterEvent(event)
    EventRegistrar[event] = {}
  end
  table.insert(EventRegistrar[event], func)
end

function OnUpdateHookRegistrar(func)
  table.insert(OnUpdateRegistrar, func)
end

local API = {
  Registrar_EventHook = EventHookRegistrar,
  Registrar_OnUpdateHook = OnUpdateHookRegistrar,
  Callback_RawLocation = function () return QuestHelper:RetrieveRawLocation() end,
}

function QH_Collector_Init()
  -- First we update shit
  if QuestHelper_Collector_Version == 1 then
    -- We basically just want to clobber all our old route data, it's not worth storing - it's all good data, it's just that we don't want to preserve relics of the old location system
    for _, v in pairs(QuestHelper_Collector) do
      v.traveled = nil
    end
    
    QuestHelper_Collector_Version = 2
  end
  
  QuestHelper: Assert(QuestHelper_Collector_Version == QuestHelper_Collector_Version_Current)
  
  local sig = GetAddOnMetadata("QuestHelper", "Version") .. " on " .. GetBuildInfo()
  if not QuestHelper_Collector[sig] then QuestHelper_Collector[sig] = {} end
  local QHCData = QuestHelper_Collector[sig]

  QH_Collect_Location_Init(nil, API)  -- Some may actually add their own functions to the API, and should go first. There's no real formalized order, I just know which depend on others. Location's sole job is to provide the standard location bolus. (Yeah. It's a bolus. Deal.)
  QH_Collect_Merger_Init(nil, API) -- etc
  
  QH_Collect_LZW_Init(nil, API) -- Depends on Merger
  
  QH_Collect_Achievement_Init(QHCData, API)
  QH_Collect_Traveled_Init(QHCData, API)
  QH_Collect_Zone_Init(QHCData, API)
  
  if not QHCData.realms then QHCData.realms = {} end
  QHCData.realms[GetRealmName()] = (QHCData.realms[GetRealmName()] or 0) + 1 -- I'm not entirely sure why I'm counting
end

function QH_Collector_OnUpdate()
  for _, v in pairs(OnUpdateRegistrar) do
    v()
  end
end
