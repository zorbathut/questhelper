QuestHelper_File["manager_event.lua"] = "Development Version"
QuestHelper_Loadtime["manager_event.lua"] = GetTime()

local frame = CreateFrame("Frame")

local EventRegistrar = {}

local function OnEvent(_, event, ...)
  local tstart = GetTime()
  for _, v in pairs(EventRegistrar[event]) do
    v(...)
  end
  QH_Timeslice_Increment(GetTime() - tstart, "manager_event")
end

frame:UnregisterAllEvents()
frame:SetScript("OnEvent", OnEvent)

frame:Show()

function QuestHelper.EventHookRegistrar(event, func)
  QuestHelper:Assert(func)
  if not EventRegistrar[event] then
    frame:RegisterEvent(event)
    EventRegistrar[event] = {}
  end
  table.insert(EventRegistrar[event], func)
end

--[[
function QuestHelper.OnUpdateHookRegistrar(func)
  QuestHelper:Assert(func)
  table.insert(OnUpdateRegistrar, func)
end
]]
