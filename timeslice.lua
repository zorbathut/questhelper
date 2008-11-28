QuestHelper_File["timeslice.lua"] = "Development Version"
QuestHelper_Loadtime["timeslice.lua"] = GetTime()

-- Any non-local item here is part of an available public interface.

local coroutine_running = false
local coroutine_stop_time = 0
local coroutine_list = {}
local coroutine_route_pass = 1

local coroutine_verbose = false

local coroutine_time_used = {}
local coroutine_power_up = GetTime()

local coroutine_time_exceeded = 0

function QH_Timeslice_DumpPerf()
  local sortable = {}
  for k, v in pairs(coroutine_time_used) do
    table.insert(sortable, {name = k, amount = v})
  end
  table.sort(sortable, function(a, b) return a.name < b.name end)
  for _, v in pairs(sortable) do
    QuestHelper:TextOut(string.format("%s: %f", QuestHelper:HighlightText(v.name), v.amount))
  end
  QuestHelper:TextOut(string.format("%s: %f", QuestHelper:HighlightText("poweron"), GetTime() - coroutine_power_up))
end

function QH_Timeslice_Yield()
  if coroutine_running then
    -- Check if we've run our alotted time
    if GetTime() > coroutine_stop_time then
      -- As a safety, reset stop time to 0.  If somehow we fail to set it next time,
      -- we'll be sure to yield promptly.
      coroutine_stop_time = 0
      coroutine.yield()
    end
  end
end

function QH_Timeslice_Bonus(quantity)
  if coroutine_verbose then QuestHelper:TextOut(string.format("timeslice: %d bonus", quantity)) end
  coroutine_route_pass = coroutine_route_pass + quantity
end

local prioritize = {
  criteria = 10,
  lzw = -5,
  routing = -10,
}

function QH_Timeslice_Add(workfunc, name)
  local priority = prioritize[name] or 0
  if coroutine_verbose then QuestHelper:TextOut(string.format("timeslice: %s added (%s, %d)", name, tostring(workfunc), priority)) end
  local ncoro = coroutine.create(workfunc)
  QuestHelper: Assert(ncoro)
  table.insert(coroutine_list, {priority = priority, name = name, coro = ncoro, active = true})
end

function QH_Timeslice_Toggle(name, flag)
  --if coroutine_verbose then QuestHelper:TextOut(string.format("timeslice: %s toggled to %s", name, tostring(not not flag))) end
  for _, v in pairs(coroutine_list) do
    if v.name == name then v.active = flag end
  end
end

function QH_Timeslice_Work()
  -- There's probably a better way to do this, but. Eh. Lua.
  coro = nil
  key = nil
  for k, v in pairs(coroutine_list) do
    if v.active and (not coro or v.priority > coro.priority) then coro = v; key = k end
  end
  
  if coro then
    --if coroutine_verbose then QuestHelper:TextOut(string.format("timeslice: %s running", coro.name)) end
    
    QuestHelper: Assert(coroutine.status(coro.coro) ~= "dead")
    local coroutine_intended_stop_time = GetTime() + 4e-3 * (QuestHelper_Pref.hide and 0.01 or (QuestHelper_Pref.perf_scale * math.min(coroutine_route_pass, 5)))
    coroutine_stop_time = coroutine_intended_stop_time - coroutine_time_exceeded
    coroutine_route_pass = coroutine_route_pass - 5
    if coroutine_route_pass <= 0 then coroutine_route_pass = 1 end
    
    local start = GetTime()
    local state, err = true, nil -- default values for "we're fine"
    if start < coroutine_stop_time then -- We don't want to just return on failure because we want to credit the exceeded time properly.
      coroutine_running = true
      state, err = coroutine.resume(coro.coro)
      coroutine_running = false
    end
    local total = GetTime() - start
    
    local coroutine_this_cycle_exceeded = GetTime() - coroutine_intended_stop_time -- may be either positive or negative
    coroutine_time_exceeded = coroutine_time_exceeded + coroutine_this_cycle_exceeded
    
    coroutine_time_used[coro.name] = (coroutine_time_used[coro.name] or 0) + total
    
    if not state then
      if coroutine_verbose then QuestHelper:TextOut(string.format("timeslice: %s errored", coro.name)) end
      QuestHelper_ErrorCatcher_ExplicitError(err, "", string.format("(Coroutine error in %s)\n", coro.name))
    end
    
    QuestHelper: Assert(coro.coro)
    if coroutine.status(coro.coro) == "dead" then
      if coroutine_verbose then QuestHelper:TextOut(string.format("timeslice: %s complete", coro.name)) end
      coroutine_list[key] = nil
    end
  else
    if coroutine_verbose then QuestHelper:TextOut(string.format("timeslice: no available tasks")) end
  end
end

function QH_Timeslice_Increment(quantity, name)
  local an = "(nc) " .. name
  coroutine_time_used[an] = (coroutine_time_used[an] or 0) + quantity
end
