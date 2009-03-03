
assert(arg[1])
assert(arg[2])

require("luarocks.require")
require("pluto")
require("gzio")
require("bit")
require("md5")

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
  world.bit = {mod = function(a, b) return a - math.floor(a / b) * b end, lshift = bit.lshift, rshift = bit.rshift, band = bit.band}
  world.math = math
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

local function md5_clean(dat)
  local binny = md5.sum(dat)
  local rv = ""
  for k = 1, #binny do
    rv = rv .. string.format("%02x", string.byte(binny, k))
  end
  return rv
end

local function dumpout(compdat)
  io.stderr:write(string.format("  Dumped signature %s\n", compdat.signature))
  
  local serial = pluto.persist({}, compdat)

  local md5 = md5_clean(serial)
  
  local gzout = gzio.open(string.format("%s/%s", arg[2], md5), "w")
  gzout:write(serial)
  gzout:close()
end

for k, v in pairs(csave.QuestHelper_Collector) do
  local compdat = {}
  if v.modified then
    compdat.modified = v.modified
    v.modified = nil
  else
    compdat.modified = csave.QuestHelper_SaveDate - 6 * 30 * 24 * 60 * 60
  end
  
  compdat.data = v
  compdat.uid = csave.QuestHelper_UID
  compdat.signature = k

  dumpout(compdat)
end

if csave.QuestHelper_Errors then
  local keep
  for k, v in pairs(csave.QuestHelper_Errors) do
    if type(v) == "table" and #v > 0 then keep = true end
  end

  if keep then
    local errdat = {}
    errdat.modified = csave.QuestHelper_SaveDate
    errdat.uid = csave.QuestHelper_UID
    errdat.signature = "error"
    errdat.errors = csave.QuestHelper_Errors
    dumpout(errdat)
  end
end
