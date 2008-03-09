-- Functions we use here.
local create = QuestHelper.create
local createSortedList = QuestHelper.createSortedList
local release = QuestHelper.release
local array = QuestHelper.array
local insert = table.insert
local erase = table.remove
local now = GetTime or os.time

-- The metatable for cron objects.
local Cron = {}

-- Holds values that need to be reinserted.
local temp = {}

local function jobCmp(a, b)
  return a.time > b.time
end

function Cron:onCreate()
  rawset(self, "jobs", createSortedList(jobCmp))
end

function Cron:onRelease()
  release(rawget(self, "jobs"))
end

function Cron:start(delta, func, ...)
  assert(type(delta) == "number" and delta >= 0, "Expected positive number.")
  assert(type(func) == "function", "Expected function.")
  local job= array(...)
  job.time = now()+delta
  job.func = func
  rawget(self, "jobs"):insert(job)
  return job
end

function Cron:stop(job)
  rawget(self, "jobs"):erase(job)
  release(job)
end

function Cron:poll()
  local t = now()
  local jobs = rawget(self, "jobs")
  
  for i = #jobs,1,-1 do
    local job = rawget(jobs, i)
    
    if job.time > t then
       -- No other jobs need to be done.
      break
    end
    
    erase(jobs, i)
    
    local result = job.func(unpack(job))
    if result then
      job.time = t+result
      insert(temp, job)
    else
      release(job)
    end
  end
  
  -- Reinsert the jobs we just did.
  while true do
    local job = erase(temp)
    if not job then return end
    jobs:insert(job)
  end
end

Cron.__newindex = function()
  assert(false, "Shouldn't assign values.")
end

Cron.__index = function(cron, key)
  return rawget(Cron, key)
end

local function createCron()
  return create(Cron)
end

QuestHelper.createCron = createCron
