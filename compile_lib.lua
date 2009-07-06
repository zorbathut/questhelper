
-- I don't know why print is giving me so much trouble, but it is, sooooo
print = function (...)
  local pad = ""
  for i = 1, select("#", ...) do
    io.stdout:write(pad)
    local tst = tostring(select(i, ...))
    pad = (" "):rep(#tst - math.floor(#tst / 6) * 6 + 4)
    io.stdout:write(tst)
  end
  io.stdout:write("\n")
end


require("luarocks.require")
require("persistence")
require("compile_chain")
require("compile_debug")
require("bit")
require("pluto")
require("gzio")
  

ll, err = package.loadlib("/nfs/build/libcompile_core.so", "init")
if not ll then print(err) return end
ll()


-- we pretend to be WoW

do
  local world = {}
  world.QuestHelper_File = {}
  world.QuestHelper_Loadtime = {}
  world.GetTime = function() return 0 end
  world.QuestHelper = { Assert = function (self, ...) assert(...) end, CreateTable = function() return {} end, ReleaseTable = function() end, IsWrath32 = function () return false end }
  world.string = string
  world.table = table
  world.assert = assert
  world.bit = {mod = function(a, b) return a - math.floor(a / b) * b end, lshift = bit.lshift, rshift = bit.rshift, band = bit.band}
  world.math = math
  world.strbyte = string.byte
  world.strchar = string.char
  world.pairs = pairs
  world.ipairs = ipairs
  world.print = function(...) print(...) end
  world.QH_Timeslice_Yield = function() end
  setfenv(loadfile("../questhelper/collect_merger.lua"), world)()
  setfenv(loadfile("../questhelper/collect_bitstream.lua"), world)()
  setfenv(loadfile("../questhelper/collect_lzw.lua"), world)()
  local api = {}
  world.QH_Collect_Merger_Init(nil, api)
  world.QH_Collect_Bitstream_Init(nil, api)
  world.QH_Collect_LZW_Init(nil, api)
  LZW = api.Utility_LZW
  Merger = api.Utility_Merger
  Bitstream = api.Utility_Bitstream
  assert(Merger.Add)
end



do
  local world = {}
  local cropy = {
    "string",
    "tonumber",
    "print",
    "setmetatable",
    "type",
    "table",
    "tostring",
    "error",
    "math",
    "coroutine",
    "pairs",
    "ipairs",
    "select",
  }
  for _, v in ipairs(cropy) do
    world[v] = _G[v]
  end
  world.getfenv = function (x) assert(x == 0 or not x) return world end
  
  
  world._G = world
  world.GetPlayerFacing = function () return 0 end
  world.MinimapCompassTexture = {GetTexCoord = function() return 0, 1 end}
  world.CreateFrame = function () return {Hide = function () end, SetParent = function () end, UnregisterAllEvents = function () end, RegisterEvent = function () end, SetScript = function () end} end
  world.GetMapContinents = function () return "Kalimdor", "Eastern Kingdoms", "Outland", "Northrend" end
  world.GetMapZones = function (z)
    local db = {
      {"Ashenvale", "Azshara", "Azuremyst Isle", "Bloodmyst Isle", "Darkshore", "Darnassus", "Desolace", "Durotar", "Dustwallow Marsh", "Felwood", "Feralas", "Moonglade", "Mulgore", "Orgrimmar", "Silithus", "Stonetalon Mountains", "Tanaris", "Teldrassil", "The Barrens", "The Exodar", "Thousand Needles", "Thunder Bluff", "Un'Goro Crater", "Winterspring"},
      {"Alterac Mountains", "Arathi Highlands", "Badlands", "Blasted Lands", "Burning Steppes", "Deadwind Pass", "Dun Morogh", "Duskwood", "Eastern Plaguelands", "Elwynn Forest", "Eversong Woods", "Ghostlands", "Hillsbrad Foothills", "Ironforge", "Isle of Quel'Danas", "Loch Modan", "Redridge Mountains", "Searing Gorge", "Silvermoon City", "Silverpine Forest", "Stormwind City", "Stranglethorn Vale", "Swamp of Sorrows", "The Hinterlands", "Tirisfal Glades", "Undercity", "Western Plaguelands", "Westfall", "Wetlands"},
      {"Blade's Edge Mountains", "Hellfire Peninsula", "Nagrand", "Netherstorm", "Shadowmoon Valley", "Shattrath City", "Terokkar Forest", "Zangarmarsh"},
      {"Borean Tundra", "Crystalsong Forest", "Dalaran", "Dragonblight", "Grizzly Hills", "Howling Fjord", "Icecrown", "Sholazar Basin", "The Storm Peaks", "Wintergrasp", "Zul'Drak"},
    }
    return unpack(db[z])
  end
  
  local tc, tz
  world.SetMapZoom = function (c, z) tc, tz = c, z end
  world.GetMapInfo = function ()
    local db = {
      {"Ashenvale", "Aszhara", "AzuremystIsle", "BloodmystIsle", "Darkshore", "Darnassis", "Desolace", "Durotar", "Dustwallow", "Felwood", "Feralas", "Moonglade", "Mulgore", "Ogrimmar", "Silithus", "StonetalonMountains", "Tanaris", "Teldrassil", "Barrens", "TheExodar", "ThousandNeedles", "ThunderBluff", "UngoroCrater", "Winterspring", [0] = "Kalimdor"},
      {"Alterac", "Arathi", "Badlands", "BlastedLands", "BurningSteppes", "DeadwindPass", "DunMorogh", "Duskwood", "EasternPlaguelands", "Elwynn", "EversongWoods", "Ghostlands", "Hilsbrad", "Ironforge", "Sunwell", "LochModan", "Redridge", "SearingGorge", "SilvermoonCity", "Silverpine", "Stormwind", "Stranglethorn", "SwampOfSorrows", "Hinterlands", "Tirisfal", "Undercity", "WesternPlaguelands", "Westfall", "Wetlands", [0] = "Azeroth"},
      {"BladesEdgeMountains", "Hellfire", "Nagrand", "Netherstorm", "ShadowmoonValley", "ShattrathCity", "TerokkarForest", "Zangarmarsh", [0] = "Expansion01"},
      {"BoreanTundra", "CrystalsongForest", "Dalaran", "Dragonblight", "GrizzlyHills", "HowlingFjord", "IcecrownGlacier", "SholazarBasin", "TheStormPeaks", "LakeWintergrasp", "ZulDrak", [0] = "Northrend"},
    }
    
    return db[tc][tz]
  end
  world.IsLoggedIn = function () end
  
  world.QuestHelper_File = {}
  world.QuestHelper_Loadtime = {}
  world.GetTime = function() return 0 end
  world.QuestHelper = { Assert = function (self, ...) assert(...) end, CreateTable = function() return {} end, ReleaseTable = function() end, TextOut = function(qh, ...) print(...) end, IsWrath32 = function () return false end }
  
  setfenv(loadfile("../questhelper/AstrolabeQH/DongleStub.lua"), world)()
  setfenv(loadfile("../questhelper/AstrolabeQH/AstrolabeMapMonitor.lua"), world)()
  setfenv(loadfile("../questhelper/AstrolabeQH/Astrolabe.lua"), world)()
  setfenv(loadfile("../questhelper/upgrade.lua"), world)()
  
  world.QuestHelper.Astrolabe = world.DongleStub("Astrolabe-0.4-QuestHelper")
  Astrolabe = world.QuestHelper.Astrolabe
  assert(Astrolabe)
  
  world.QuestHelper_BuildZoneLookup()
  
  QuestHelper_IndexLookup = world.QuestHelper_IndexLookup
  QuestHelper_ZoneLookup = world.QuestHelper_ZoneLookup
end

-- LuaSrcDiet embedding
do
  local world = {arg = {}}
  world.string = string
  world.table = table
  world.pcall = pcall
  world.print = print
  world.ipairs = ipairs
  world.TEST = true
  setfenv(loadfile("LuaSrcDiet.lua"), world)()
  world.TEST = false
  world.error = error
  world.tonumber = tonumber
  
  local files = {input = {}, output = {}}
  
  local function readgeneral(target)
    local rv = target[target.cline]
    target.cline = target.cline + 1
    return rv
  end
  
  world.io = {
    open = function(fname, typ)
      if fname == "input" then
        assert(typ == "rb")
        return {
          read = function(_, wut)
            assert(wut == "*l")
            return readgeneral(files.input)
          end,
          close = function() end
        }
      elseif fname == "output" then
      
        if typ == "wb" then
          return {
            write = function(_, wut, nilo)
              assert(not nilo)
              assert(not files.output_beta)
              Merger.Add(files.output, wut)
            end,
            close = function() end
          }
        elseif typ == "rb" then
          files.output_beta = {}
          for k in Merger.Finish(files.output):gmatch("[^\n]*") do
            table.insert(files.output_beta, k)
          end
          files.output_beta.cline = 1
          
          return {
            read = function(_, wut)
              assert(wut == "*l")
              return readgeneral(files.output_beta)
            end,
            close = function() end
          }
        else
          assert()
        end
        
      end
    end,
    close = function() end,
    stdout = io.stdout,
  }
  
  Diet = function(inp)
    world.arg = {"input", "-o", "output", "--quiet", "--maximum"}
    files.input = {}
    for k in inp:gmatch("[^\n]*") do
      table.insert(files.input, k)
    end
    files.input.cline = 1
    files.output = {}
    files.output_beta = nil
    
    local ok = pcall(world.main)
    if not ok then return end
    
    return Merger.Finish(files.output)
  end
  
  --assert(Diet("   q    = 15 ") == "q=15")
  --assert(Diet("   jbx    = 15 ") == "jbx=15")
  --return
end


ChainBlock_Init("/nfs/build", "compile.lua", function () 
  os.execute("rm -rf intermed")
  os.execute("mkdir intermed")

  os.execute("rm -rf final")
  os.execute("mkdir final") end, ...)

math.umod = function (val, med)
  if val < 0 then
    return math.mod(val + math.ceil(-val / med + 10) * med, med)
  else
    return math.mod(val, med)
  end
end

zone_image_chunksize = 1024
zone_image_descale = 4
zone_image_outchunk = zone_image_chunksize / zone_image_descale

zonecolors = {}

--[[
*****************************************************************
Utility functions
]]

function version_parse(x)
  if not x then return end
  
  local rv = {}
  for t in x:gmatch("[%d]+") do
    table.insert(rv, tonumber(t))
  end
  return rv
end

function sortversion(a, b)
  local ap, bp = version_parse(a), version_parse(b)
  if not ap and not bp then return false end
  if not ap then return false end
  if not bp then return true end
  for x = 1, #ap do
    if ap[x] ~= bp[x] then
      return ap[x] > bp[x]
    end
  end
  return false
end

function tablesize(tab)
  local ct = 0
  for _, _ in pairs(tab) do
    ct = ct + 1
  end
  return ct
end

function loc_version(ver)
  local major = ver:match("([0-9])%..*")
  if major == "0" then
    return sortversion("0.96", ver) and 0 or 1
  elseif major == "1" then
    return sortversion("1.0.2", ver) and 0 or 1
  else
    assert()
  end
end

function convert_loc(loc, locale)
  if not loc then return end
  assert(locale)
  if locale ~= "enUS" then return end -- arrrgh, to be fixed eventually
  
  local lr = loc.relative
  if loc.relative then
    loc.c, loc.x, loc.y = Astrolabe:GetAbsoluteContinentPosition(loc.rc, loc.rz, loc.x, loc.y)
    loc.relative = false
  end
  
  if not loc.c or not QuestHelper_IndexLookup[loc.rc] then return end
  
  if not QuestHelper_IndexLookup[loc.rc] or not QuestHelper_IndexLookup[loc.rc][loc.rz] then
    print(loc.c, loc.rc, loc.rz, QuestHelper_IndexLookup, QuestHelper_IndexLookup[loc.rc])
    print(loc.c, loc.rc, loc.rz, QuestHelper_IndexLookup, QuestHelper_IndexLookup[loc.rc], QuestHelper_IndexLookup[loc.rc][loc.rz])
  end
  loc.p = QuestHelper_IndexLookup[loc.rc][loc.rz]
  loc.rc, loc.rz = nil, nil
  
  return loc
end

function convert_multiple_loc(locs, locale)
  if not locs then return end
  
  for _, v in ipairs(locs) do
    if v.loc then
      convert_loc(v.loc, locale)
    end
  end
end

--[[
*****************************************************************
Weighted multi-concept accumulation
]]

function weighted_concept_finalize(data, fraction, minimum, total_needed)
  if #data == 0 then return end

  fraction = fraction or 0.9
  minimum = minimum or 1
  
  table.sort(data, function (a, b) return a.w > b.w end)

  local tw = total_needed
  if not tw then
    tw = 0
    for _, v in ipairs(data) do
      tw = tw + v.w
    end
  end
  
  local ept
  local wacu = 0
  for k, v in ipairs(data) do
    wacu = wacu + v.w
    v.w = nil
    if wacu >= tw * fraction or (data[k + 1] and data[k + 1].w < minimum) or not data[k + 1] then
      ept = k
      break
    end
  end
  
  if not ept then
    print(total_needed)
    for k, v in ipairs(data) do
      print("", v.w)
    end
    assert(false)
  end
  assert(ept, tw)
  
  while #data > ept do table.remove(data) end
  
  return data
end

--[[
*****************************************************************
List-accum functions
]]

function list_accumulate(item, id, inp)
  if not inp then return end
  
  if not item[id] then item[id] = {} end
  local t = item[id]
  
  if type(inp) == "table" then
    for k, v in pairs(inp) do
      t[v] = (t[v] or 0) + 1
    end
  else
    t[inp] = (t[inp] or 0) + 1
  end
end

function list_most_common(tbl, mv)
  local mcv = nil
  local mcvw = mv
  for k, v in pairs(tbl) do
    if not mcvw or v > mcvw then mcv, mcvw = k, v end
  end
  return mcv
end

--[[
*****************************************************************
Solids accumulation
]]

solid_grid = 16

function solids_accumulate(accu, tpos)
  if not accu[tpos.c] then accu[tpos.c] = {} end
  local lex, ley = math.floor(tpos.x / solid_grid), math.floor(tpos.y / solid_grid)
  if not accu[tpos.c][lex] then accu[tpos.c][lex] = {} end
  accu[tpos.c][lex][ley] = (accu[tpos.c][lex][ley] or 0) + 1
end
function solids_combine(dest, src)
  for k, v in pairs(src) do
    if not dest[k] then dest[k] = {} end
    for x, tv in pairs(v) do
      if not dest[k][x] then dest[k][x] = {} end
      for y, ttv in pairs(tv) do
        dest[k][x][y] = (dest[k][x][y] or 0) + ttv
      end
    end
  end
end
  
--[[
*****************************************************************
Position accumulation
]]

function distance(a, b)
  local x = a.x - b.x
  local y = a.y - b.y
  return math.sqrt(x*x+y*y)
end

function valid_pos(ite)
  if not ite then return end
  if not ite.p or not ite.x or not ite.y then return end
  if QuestHelper_ZoneLookup[ite.p][2] == 0 then return end -- this should get rid of locations showing up in "northrend" or whatever
  return true
end

function position_accumulate(accu, tpos)
  if not valid_pos(tpos) then return end
  
  assert(tpos.priority)
  
  if not accu[tpos.priority] then accu[tpos.priority] = {solid = {}} end
  accu = accu[tpos.priority]  -- this is a bit grim
  
  if not accu[tpos.p] then
    accu[tpos.p] = {}
  end
  
  local conti = accu[tpos.p]
  local closest = nil
  local clodist = 300
  for k, v in ipairs(conti) do
    local cdist = distance(tpos, v)
    if cdist < clodist then
      clodist = cdist
      closest = v
    end
  end
  
  if closest then
    closest.x = (closest.x * closest.w + tpos.x) / (closest.w + 1)
    closest.y = (closest.y * closest.w + tpos.y) / (closest.w + 1)
    closest.w = closest.w + 1
  else
    closest = {x = tpos.x, y = tpos.y, w = 1}
    table.insert(conti, closest)
  end
  
  accu.weight = (accu.weight or 0) + 1
  
  solids_accumulate(accu.solid, tpos)
end

function position_has(accu)
  for c, v in pairs(accu) do
    return true -- ha ha
  end
  return false
end

function position_finalize(sacu, mostest)
  if not position_has(sacu) then return end
  
  --[[local hi = sacu[1] and sacu[1].weight or 0
  local lo = sacu[2] and sacu[2].weight or 0]]
  
  local highest = 0
  for k, v in pairs(sacu) do
    if mostest and k > mostest then continue end
    highest = math.max(highest, k)
  end
  assert(highest > 0 or mostest)
  if highest == 0 then return end
  
  local accu = sacu[highest]  -- highest priority! :D
  
  local pozes = {}
  local tw = 0
  for p, pi in pairs(accu) do
    if type(p) == "string" then continue end
    for _, v in ipairs(pi) do
      table.insert(pozes, {p = p, x = math.floor(v.x + 0.5), y = math.floor(v.y + 0.5), w = v.w})
    end
  end
  
  if #pozes == 0 then return position_finalize(sacu, highest - 1) end
  
  local rv = weighted_concept_finalize(pozes, 0.8, 10)
  rv.solid = accu.solid
  return rv
end

--[[
*****************************************************************
Locale name accum functions
]]

function name_accumulate(accum, name, locale)
  if not name then return end
  if not accum[locale] then accum[locale] = {} end
  accum[locale][name] = (accum[locale][name] or 0) + 1
end

function name_resolve(accum)
  local rv = {}
  for k, v in pairs(accum) do
    rv[k] = list_most_common(v)
  end
  return rv
end

--[[
*****************************************************************
Loot accumulation functions
]]

local srces = {
 eng = {},
 mine = {},
 herb = {},
 skin = {},
 open = {},
 extract = {},
 de = {},
 prospect = {},
 mill = {},
 
 loot = {ignoreyesno = true},
 loot_trivial = {ignoreyesno = true, become = "loot"},
 
 rob = {ignoreyesno = true},
 fish = {ignoreyesno = true},
}

function loot_accumulate(source, sourcetok, Output)
  for typ, specs in pairs(srces) do
    if not specs.ignoreyesno then
      local yes = source[typ .. "_yes"] or 0
      local no = source[typ .. "_no"] or 0
      
      if yes + no < 10 then continue end -- DENY
      
      if yes / (yes + no) < 0.95 then continue end -- DOUBLEDENY
    end
    
    -- We don't actually care about frequency at the moment, just where people tend to get it from. This works in most cases.
    if source[typ .. "_loot"] then for k, c in pairs(source[typ .. "_loot"]) do
      if k ~= "gold" then
        Output(tostring(k), nil, {source = sourcetok, count = c, type = specs.become or typ}, "loot")
      end
    end end
  end
  
  for k, _ in pairs(source) do
    if type(k) ~= "string" then continue end
    local tag = k:match("([^_]+)_items")
    assert(not tag or srces[tag])
  end
end

--[[
*****************************************************************
Standard data accumulation functions
]]

function standard_pos_accum(accum, value, lv, locale, fluff)
  if not fluff then fluff = 0 end
  for _, v in ipairs(value) do
    if math.mod(#v, 11 + fluff) ~= 0 then
      return true
    end
  end
  
  for _, v in ipairs(value) do
    for off = 1, #v, 11 + fluff do
      local tite = convert_loc(slice_loc(v:sub(off, off + 10), lv), locale)
      if tite then position_accumulate(accum.loc, tite) end
    end
  end
end

function standard_name_accum(accum, value)
  for k, v in pairs(value) do
    if type(k) == "string" then
      local q = string.match(k, "name_(.*)")
      if q then name_accumulate(accum, q, value.locale) end
    end
  end
end
