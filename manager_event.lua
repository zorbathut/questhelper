QuestHelper_File["manager_event.lua"] = "Development Version"
QuestHelper_Loadtime["manager_event.lua"] = GetTime()

-- zorba why does this file exist, are you a terrible person? you are a terrible person aren't you
-- yep, I'm a terrible person

-- File exists to centralize all the event hooks in one place. QH should never (rarely) eat CPU without going through this file. As a nice side effect, I can use this to measure when QH is using CPU. yaaaaay

local next_started = false

local time_used = 0

local EventRegistrar = {}

local OnUpdate_Keyed = {}

local qh_event_frame = CreateFrame("Frame")

local function wraptime(ident, func, ...)
  local st
  if qh_loud_and_annoying then
    st = GetTime()
  end
  func(...)
  if qh_loud_and_annoying and GetTime() - st > 0.0025 then
    QuestHelper: TextOut(string.format("Took way too long, %4f, at %s", (GetTime() - st) * 1000, ident))
  end
end

local function OnEvent(_, event, ...)
  if not next_started then next_started, time_used = true, 0 end
  
  if EventRegistrar[event] then 
    local tstart = GetTime()
    for _, v in pairs(EventRegistrar[event]) do
      wraptime(v.id, v.func, ...)
    end
    time_used = time_used + (GetTime() - tstart)
  end
end

qh_event_frame:UnregisterAllEvents()
qh_event_frame:RegisterAllEvents() -- I wonder what the performance penalty of this actually is
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
      --qh_event_frame:RegisterEvent(event)
      EventRegistrar[event] = {}
    end
    table.insert(EventRegistrar[event], {func = func, id = identifier})
  end
end


local OnUpdate = {}
local OnUpdateHigh = {}
local function OnUpdateTrigger(_, ...)
  if not next_started then next_started, time_used = true, 0 end
  
  do
    local tstart = GetTime()
    for _, v in pairs(OnUpdateHigh) do
      wraptime(v.id, v.func, ...)
    end
    
    for _, v in pairs(OnUpdate) do
      if v.func then wraptime(v.id, v.func, ...) end
    end
    time_used = time_used + (GetTime() - tstart)
  end
  
  QH_Timeslice_Work(time_used)
  
  next_started = false
end

function QH_OnUpdate(func, identifier)
  if not identifier then identifier = "(unknown onupdate)" end
  table.insert(OnUpdate, {func = func, id = identifier})
end

function QH_OnUpdate_High(func, identifier)
  if not identifier then identifier = "(unknown high-onupdate)" end
  table.insert(OnUpdateHigh, {func = func, id = identifier})
end

qh_event_frame:SetScript("OnUpdate", OnUpdateTrigger)


function QH_Hook(target, hookname, func, identifier)
  if hookname == "OnUpdate" then
    OnUpdate[target] = {func = func and function (...) func(target, ...) end, id = identifier}
  else
    local ide = string.format("(unknown %s/%s)", tostring(target), hookname)
    target:SetScript(hookname, function (...) wraptime(ide, func, ...) end)
  end
end
