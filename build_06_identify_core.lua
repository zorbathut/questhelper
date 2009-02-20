
assert(arg[1])

require("luarocks.require")
require("pluto")
require("gzio")

local gzr = gzio.open(arg[1], "r")
local stt = gzr:read("*a")
local data = pluto.unpersist({}, stt)

assert(data)

io.stdout:write(data.QuestHelper_UID .. "\n" .. tostring(data.QuestHelper_SaveDate))
