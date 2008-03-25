-- Functions we use here.
local create = QuestHelper.create
local createCallback = QuestHelper.createCallback
local reference = QuestHelper.reference
local release = QuestHelper.release

-- The metatable for Event objects.
local Event = {}

function Event:onCreate()
  rawset(self, "set", create())
end

function Event:onRelease()
  local set = rawget(self, "set")
  for cb in pairs(set) do release(cb) end
  release(set)
end

-- Adds a reference to callback to if it hasn't already been added.
-- If callback is a function, creates a callback.
-- You could probably register another event here as if it were a callback, but I doubt that would be a great idea.
-- Returns the passed (or created) callback.
function Event:register(callback, ...)
  local set = rawget(self, "set")
  if type(callback) == "function" then
    callback = createCallback(callback, ...)
    set[callback] = true
  else
    if not set[callback] then
      set[reference(callback)] = true
    end
  end
  
  return callback
end

-- Unregisters a callback previously passed to or returned from register.
function Event:unregister(callback)
  local set = rawget(self, "set")
  assert(set[callback], "Wasn't previously registered.")
  set[callback] = nil
  release(callback)
end

-- Invokes all associated callbacks with passed arguments.
function Event:invoke(...)
  local set = rawget(self, "set")
  for cb in pairs(set) do cb(...) end
end

-- Allows event to be invoked as if it were a function.
Event.__call = Event.invoke

Event.__newindex = function()
  assert(false, "Shouldn't assign values.")
end

Event.__index = function(_, key)
  return rawget(Event, key)
end

local function createEvent()
  return create(Event)
end

QuestHelper.createEvent = createEvent
