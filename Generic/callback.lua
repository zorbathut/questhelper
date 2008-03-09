local create = QuestHelper.create
local release = QuestHelper.release
local erase = table.remove
local append = QuestHelper.append

-- The metatable for Callback objects.
local Callback = {}

-- Initiates a callback that will invoke func with some arguments, plus any additional arguments
-- passed at the time the callback is invoked.
-- If func is a callback, then this function copies it, creates references to anything that callback was marked to release,
-- and then adds any additional arguments.
function Callback:onCreate(func, ...)
  -- Callback is organized as an array:
  --   Element 0 is the function to call.
  --   Elements 1 through #self are the arguments to pass to that function.
  --   Elements self.r through -1 are tables to release when the callback is released.
  
  if type(func) == "table" then
    assert(getmetatable(func) == Callback, "Expected callback to copy.")
    -- Creating a callback to a callback. For this special case, we'll copy it.
    rawset(self, 0, rawget(func, 0))
    local r = rawget(func, "r")
    rawset(self, "r", r)
    for i = 1,#func do rawset(self, i, rawget(func, i)) end
    for i = -1,r,-1 do rawset(self, i, reference(rawget(func, i))) end
  else
    assert(type(func) == "function", "Expected function as first argument.")
    rawset(self, 0, func)
    rawset(self, "r", 0)
  end
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
