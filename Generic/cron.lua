-- Functions we use here.
local create = QuestHelper.create
local createSortedList = QuestHelper.createSortedList
local createCallback = QuestHelper.createCallback
local release = QuestHelper.release
local reference = QuestHelper.reference
local array = QuestHelper.array
local insert = table.insert
local erase = table.remove
local now = GetTime or os.time

-- The metatable for Cron objects.
local Cron = {}

local function jobCmp(a, b)
  return a.time > b.time
end

function Cron:onCreate()
  rawset(self, "jobs", createSortedList(jobCmp))
end

function Cron:onRelease()
  local jobs = rawget(self, "jobs")
  for i, job in ipairs(jobs) do
    release(job.callback)
    release(job)
  end
  release(jobs)
end

-- Will invoke callback 'wait' or more seconds from now, at some future invocation of poll.
-- 
-- If the callback returns a number, it will be invoked again in at least that number of seconds.
-- 
-- The callback is referenced and that reference will be released when the job is complete or
-- the cron object itself is released.
-- 
-- If callback is actually a function, a callback is created from it using the additional arguments.
-- Otherwise, any additional arguments are ignored.
-- 
-- You could probably get away with passing an event object here as if it were a callback.
-- 
-- Returns the passed or created callback.
function Cron:start(wait, callback, ...)
  assert(type(wait) == "number", "Expected positive number.")
  local job= array(delta, callback)
  job.time = now()+wait
  job.callback = type(callback) == "function" and createCallback(callback, ...) or reference(callback)
  rawget(self, "jobs"):insert(job)
end

-- Attempts to find a job with the specified callback and stop it.
function Cron:stop(callback)
  local jobs = rawget(self, "jobs")
  for i, job in pairs(jobs) do
    if job.callback == callback then
      erase(jobs, i)
      release(job.callback)
      release(job)
      return
    end
  end
  
  assert(false, "Callback wasn't handled.")
end

-- Returns true if the cron object isn't tracking any objects.
function Cron:empty()
  return #rawget(self, "jobs") == 0
end

-- Will invoke the next callback that needs to be called, returning true if something happened, nil otherwise.
function Cron:poll()
  local t = now()
  local jobs = rawget(self, "jobs")
  local i = #jobs
  
  if i > 0 then
    local job = rawget(jobs, i)
    
    if job.time < t then
      erase(jobs, i)
      local result = job.callback()
      if result then
        job.time = t+result
        insert(temp, job)
      else
        release(job.callback)
        release(job)
      end
      
      return true
    end
  end
end

-- Allow you to use cron object as if it were a function.
Cron.__call = Cron.poll

Cron.__newindex = function()
  assert(false, "Shouldn't assign values.")
end

Cron.__index = function(_, key)
  return rawget(Cron, key)
end

local function createCron()
  return create(Cron)
end

QuestHelper.createCron = createCron
