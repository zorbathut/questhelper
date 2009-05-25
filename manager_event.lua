QuestHelper_File["manager_event.lua"] = "Development Version"
QuestHelper_Loadtime["manager_event.lua"] = GetTime()

-- zorba why does this file exist, are you a terrible person? you are a terrible person aren't you
-- yep, I'm a terrible person

-- File exists to centralize all the event hooks in one place. QH should never (rarely) eat CPU without going through this file. As a nice side effect, I can use this to measure when QH is using CPU. yaaaaay


local EventRegistrar = {}

local qh_event_frame = CreateFrame("Frame")

local function OnEvent(_, event, ...)
  local tstart = GetTime()
  for _, v in pairs(EventRegistrar[event]) do
    v.func(...)
  end
  QH_Timeslice_Increment(GetTime() - tstart, "collect_event")
end

qh_event_frame:UnregisterAllEvents()
qh_event_frame:SetScript("OnEvent", OnEvent)



function QH_Event(event, func, identifier)
  QuestHelper: Assert(func)
  if type(event) == "table" then
    for _, v in ipairs(event) do
      QH_Event(v, func, identifier)
    end
  else
    if not identifier then identifier = "(unknown event " .. event .. ")" end
    if not EventRegistrar[event] then
      qh_event_frame:RegisterEvent(event)
      EventRegistrar[event] = {}
    end
    table.insert(EventRegistrar[event], {func = func, id = identifier})
  end
end

--[[
function QH_Event_FrameHook(identifier, frame, hook, func)
end
]]
