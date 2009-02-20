
assert(arg[1])

require("luarocks.require")
require("pluto")
require("gzio")

-- we pretend to be WoW
function GetTime() return 0 end
QuestHelper_File = {}
QuestHelper_Loadtime = {}
QuestHelper = {Assert = function(...) assert(...) end}

loadfile("../questhelper/collect_upgrade.lua")()
loadfile("../questhelper/upgrade.lua")()

local LZW

do
  local world = {}
  world.QuestHelper_File = {}
  world.QuestHelper_Loadtime = {}
  world.GetTime = function() return 0 end
  world.QuestHelper = { Assert = function(...) assert(...) end }
  world.string = string
  world.table = table
  world.bit = bit
  world.strbyte = string.byte
  world.QH_Timeslice_Yield = function() end
  setfenv(loadfile("../questhelper/collect_merger.lua"), world)()
  setfenv(loadfile("../questhelper/collect_bitstream.lua"), world)()
  setfenv(loadfile("../questhelper/collect_lzw.lua"), world)()
  local api = {}
  world.QH_Collect_Merger_Init(nil, api)
  world.QH_Collect_Bitstream_Init(nil, api)
  world.QH_Collect_LZW_Init(nil, api)
  LZW = api.Utility_LZW
end

dat = loadfile(arg[1])
if not dat then io.stderr:write("  Did not load\n") return end

local chunk = {}
setfenv(dat, chunk)
if not pcall(dat) then io.stderr:write("  Did not run\n") return end

local csave = {}

for _, v in pairs({"QuestHelper_Collector", "QuestHelper_UID", "QuestHelper_SaveDate"}) do
  if not chunk[v] then io.stderr:write(string.format("  Did not contain %s\n", v)) return end
end

for _, v in pairs({"QuestHelper_Collector", "QuestHelper_Collector_Version", "QuestHelper_UID", "QuestHelper_SaveDate", "QuestHelper_Errors"}) do
  csave[v] = chunk[v]
end

-- now it gets complicated
for _, v in pairs(csave.QuestHelper_Collector) do
  if v.compressed then
    local deco = "return " .. LZW.Decompress(v.compressed, 256, 8)
    local tx = loadstring(deco)()
    assert(tx)
    v.compressed = nil
    for tk, tv in pairs(tx) do
      v[tk] = tv
    end
  end
end

local neededutils = {"pairs", "type", "QuestHelper", "QH_Collector_Upgrade"}
for _, v in pairs(neededutils) do
  csave[v] = _G[v]
end

setfenv(QH_Collector_UpgradeAll, csave)
QH_Collector_UpgradeAll(csave.QuestHelper_Collector)

for _, v in pairs(neededutils) do
  csave[v] = nil
end

-- At some point we'll need to toss the private server filtering in here.

local serial = pluto.persist({}, csave)

local gzout = gzio.open("/proc/self/fd/1", "w")
gzout:write(serial)
gzout:close()
