QuestHelper_File["collect.lua"] = "Development Version"

QuestHelper_Collector = {}
QuestHelper_Collector_Version = 1

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
  local sig = GetAddOnMetadata("QuestHelper", "Version") .. " on " .. GetBuildInfo()
  if not QuestHelper_Collector[sig] then QuestHelper_Collector[sig] = {} end
  local QHCData = QuestHelper_Collector[sig]

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
