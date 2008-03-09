local create = QuestHelper.create
local release = QuestHelper.release
local erase = table.remove
local append = QuestHelper.append

-- The metatable for Callback objects.
local Callback = {}

-- Initiates a callback that will invoke func with some arguments, plus any additional arguments
-- passed at the time the callback is invoked.
function Callback:onCreate(func, ...)
  rawset(self, 0, func)
  rawset(self, "r", 0)
  append(self, ...)
end

function Callback:onRelease()
  for i = -1, rawget(self, "r"), -1 do release(rawget(self, i)) end
end

local function cb_release(cb, tbl, ...)
  if tbl then
    assert(type(tbl) == "table", "Can only release tables.")
    local r = rawget(cb, "r")
    r = r - 1
    rawset(cb, r, tbl)
    rawset(cb, "r", r)
    cb_release(cb, ...)
  end
end

-- The callback doesn't do any special book keeping with the function's arguments.
-- If you would like any of them to be released when the callback is, pass them
-- to this function.
Callback.release = cb_release

local temp = {}

-- Invokes the callback, appending any passed arguments to those assigned when the callback was created.
function Callback:invoke(...)
  while erase(temp) do end
  append(temp, unpack(self))
  append(temp, ...)
  return rawget(self, 0)(unpack(temp))
end

-- Allows you to use a callback as if it were a function.
Callback.__call = Callback.invoke

Callback.__newindex = function()
  assert(false, "Shouldn't assign values.")
end

Callback.__index = function(_, key)
  return rawget(Callback, key)
end

local function createCallback(...)
  return create(Callback, ...)
end

QuestHelper.createCallback = createCallback
