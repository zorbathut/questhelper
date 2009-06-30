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



function QH_Hook_NotMyFault(func, ...)
  return func(...)
end

local function wraptime(ident, func, ...)
  QuestHelper: Assert(ident)
  local st, qhh_nmf
  local qhh_adj = 0
  if qh_loud_and_annoying then
    qhh_nmf = QH_Hook_NotMyFault
    QH_Hook_NotMyFault = function(func, ...)
      local zst = GetTime()
      --print("a", GetTime())
      return (function(...)
        --print("c", GetTime(), GetTime() - zst, qhh_adj)
        qhh_adj = qhh_adj + (GetTime() - zst)
        --print(qhh_adj)
        return ...
      end)(func(...))
    end
    st = GetTime()
  end
  func(...)
  if qh_loud_and_annoying then
    if GetTime() - st - qhh_adj > 0.0025 then
      QuestHelper: TextOut(string.format("Took way too long, %4f, at %s (adjusted by %4f)", (GetTime() - st - qhh_adj) * 1000, ident, qhh_adj * 1000))
    end
    QH_Hook_NotMyFault = qhh_nmf
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

local tls = GetTime()

local last_frame = GetTime()
local time_per_frame = 0.05 -- Assume 20fps so we can get a little early loading

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
  
  local tframe = GetTime()
  local tplf = tframe - last_frame
  time_per_frame = math.exp(math.log(time_per_frame) * 0.99 + math.log(tplf + 0.0000000001) * 0.01)
  
  --[[
  if tls < GetTime() - 1 then
    tls = GetTime()
    print(string.format("Avg TPF %f, current TPLF %f, time_used %f, this adjustment %f", time_per_frame, tplf, time_used, time_used - (time_per_frame - tplf)))
  end]]
  if not qh_hackery_no_work then
    QH_Timeslice_Work(time_used, time_per_frame, math.min(math.min(time_per_frame - tplf, (time_per_frame - tplf) * 0.8), 0.05))
  end
  last_frame = GetTime()
  
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
  if not identifier then identifier = string.format("(unknown hook %s/%s)", hookname, tostring(target)) end
  if hookname == "OnUpdate" then
    if not func then
      OnUpdate[target] = nil
    else
      OnUpdate[target] = {func = function (...) func(target, ...) end, id = identifier}
    end
  else
    if not func then
      target:SetScript(hookname, nil)
    else
      target:SetScript(hookname, function (...) wraptime(identifier, func, ...) end)
    end
  end
end
