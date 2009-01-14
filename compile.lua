#!/usr/bin/lua

loadfile("compile_chain.lua")()
loadfile("compile_debug.lua")()

ll, err = package.loadlib("/home/zorba/build/libcompile_core.so", "init")
if not ll then print(err) return end
ll()

os.execute("rm -rf intermed")
os.execute("mkdir intermed")

math.umod = function (val, med)
  if val < 0 then
    return math.mod(val + math.ceil(-val / med + 10) * med, med)
  else
    return math.mod(val, med)
  end
end

local zone_image_chunksize = 1024
local zone_image_descale = 4
local zone_image_outchunk = zone_image_chunksize / zone_image_descale

local zonecolors = {}

local function sortversion(a, b)
  local mtcha, mtchb = not string.match(a, "[%d.]*"), not string.match(b, "[%d.]*")
  if mtcha == mtchb then return a > b end -- common case. Right now, version numbers are such that simple alphabetization sorts properly (although we want it to be sorted backwards.)
  return mtchb -- mtchb is true if b is not a proper string. if b isn't a proper string, we want it after the rest, so we want a first.
end

local chainhead = ChainBlock_Create("chainhead", nil,
  function () return {
    Data = function (self, key, subkey, value, Output)
      dat = loadfile(key)()
      for k, v in pairs(dat.QuestHelper_Errors) do
        for _, d in pairs(v) do
          d.key = k
          Output(d.local_version, nil, d, "error")
        end
      end
      
      for verchunk, v in pairs(dat.QuestHelper_Collector) do
        local qhv, wowv, locale, faction = string.match(verchunk, "([0-9.]+) on ([0-9.]+)/([a-zA-Z]+)/([12])")
        if qhv and wowv and locale and faction and locale == "enUS" and not sortversion("0.80", qhv) then -- hacky hacky
          -- quests!
          print(v.quest)
          if v.quest then for qid, qdat in pairs(v.quest) do
            Output(string.format("%d", qid), qhv, qdat, "quest")
            print("hey quests")
          end end
          
          -- zones!
          if v.zone then for zname, zdat in pairs(v.zone) do
            local items = {}
            
            for _, key in pairs({"border", "update"}) do
              if items and zdat[key] then for idx, chunk in pairs(zdat[key]) do
                if math.mod(#chunk, 11) ~= 0 then items = nil end
                if not items then break end -- abort, abort
                
                assert(math.mod(#chunk, 11) == 0, tostring(#chunk))
                for point = 1, #chunk, 11 do
                  local pos = slice_loc(string.sub(chunk, point, point + 10))
                  if not zonecolors[zname] then
                    local r, g, b = math.ceil(math.random(32, 255)), math.ceil(math.random(32, 255)), math.ceil(math.random(32, 255))
                    zonecolors[zname] = r * 65536 + g * 256 + b
                  end
                  pos.zonecolor = zonecolors[zname]
                  if pos.c and pos.x and pos.y then  -- These might be invalid if there are nils embedded in the string. They might still be useful with only one or two nils, but I've got a bunch of data and don't really need more.
                    if pos.c ~= 0 and pos.c ~= 3 and pos.c ~= -77 then
                      items = nil
                      break
                    end
                    
                    table.insert(items, pos)
                  end
                end
              end end
            end
            
            if items then for _, v in pairs(items) do
              Output(string.format("%d@%04d@%04d", v.c, math.floor(v.y / zone_image_chunksize), math.floor(v.x / zone_image_chunksize)), nil, v, "zone") -- This is inverted - it's continent, y, x, for proper sorting.
              Output(string.format("%d", v.c), nil, {math.floor(v.x / zone_image_chunksize), math.floor(v.y / zone_image_chunksize)}, "zone_bounds")
            end end
          end end
        else
          print("Dumped, locale " .. verchunk)
        end
      end
    end
  } end
)

--[[
*****************************************************************
Quest collation
]]

local quest_slurp = ChainBlock_Create("quest_slurp", {chainhead},
  function (key) return {
    Data = function(self, key, subkey, value, Output)
      print("we got a quest")
      if value.start then value.start = split_quest_startend(value.start) end
      if value["end"] then   --sigh
        value.finish = split_quest_startend(value["end"])
        value["end"] = nil
      end
      
      for k, v in pairs(value) do
        local item = string.match(k, "criteria_([%d]+)_satisfied")
        if item then
          value[k] = split_quest_satisfied(value[k])
        end
      end
      
      --dbgout(value)
    end,
    
    Finish = function(self, Output)
    end,
  } end,
  sortversion, "quest"
)

--[[
*****************************************************************
Zone collation
]]

do
  local zone_draw = ChainBlock_Create("zone_draw", {chainhead},
    function (key) return {
      imagepiece = Image(zone_image_outchunk, zone_image_outchunk),
      ct = 0,
      
      Data = function(self, key, subkey, value, Output)
        self.imagepiece:set(math.floor(math.umod(value.x, zone_image_chunksize) / zone_image_descale), math.floor(math.umod(value.y, zone_image_chunksize) / zone_image_descale), value.zonecolor)
        self.ct = self.ct + 1
      end,
      
      Finish = function(self, Output)
        if self.ct > 0 then Output(string.gsub(key, "@.*", ""), key, self.imagepiece, "zone_stitch") end
      end,
    } end,
    nil, "zone"
  )
  
  local zone_bounds = ChainBlock_Create("zone_bounds", {chainhead},
    function (key) return {
      sx = 1000000,
      sy = 1000000,
      ex = -1000000,
      ey = -1000000,
      
      ct = 0,
      
      Data = function(self, key, subkey, value, Output)
        self.sx = math.min(self.sx, value[1])
        self.sy = math.min(self.sy, value[2])
        self.ex = math.max(self.ex, value[1])
        self.ey = math.max(self.ey, value[2])
        self.ct = self.ct + 1
      end,
      
      Finish = function(self, Output)
        if self.ct > 1000 then
          Output(key, nil, {sx = self.sx, sy = self.sy, ex = self.ex, ey = self.ey}, "zone_stitch")
        end
      end,
    } end,
    nil, "zone_bounds"
  )
  
  local zone_stitch = ChainBlock_Create("zone_stitch", {zone_draw, zone_bounds},
    function (key) return {
      Data = function(self, key, subkey, value, Output)
        if not subkey then
          self.bounds = value
          self.imagewriter = ImageTileWriter(string.format("intermed/zone_%s.png", key), self.bounds.ex - self.bounds.sx + 1, self.bounds.ey - self.bounds.sy + 1, zone_image_outchunk)
          return
        end
        
        if not self.bounds then return end
        
        local yp, xp = string.match(subkey, "[%d-]+@([%d-]+)@([%d-]+)")
        if not xp or not yp then print(subkey) end
        xp = xp - self.bounds.sx
        yp = yp - self.bounds.sy

        self.imagewriter:write_tile(xp, yp, value)
      end,
      
      Finish = function(self, Output)
        if self.imagewriter then self.imagewriter:finish() end
      end,
    } end,
    nil, "zone_stitch"
  )
end

--[[
*****************************************************************
Error collation
]]

do
  local error_collater = ChainBlock_Create("error_collater", {chainhead},
    function (key) return {
      accum = {},
      
      Data = function (self, key, subkey, value, Output)
        assert(value.local_version)
        if not value.toc_version or value.local_version ~= value.toc_version then return end
        local signature
        if value.key ~= "crashes" then signature = value.key end
        if not signature then signature = value.message end
        local v = value.local_version
        if not self.accum[v] then self.accum[v] = {} end
        if not self.accum[v][signature] then self.accum[v][signature] = {count = 0, dats = {}, sig = signature, ver = v} end
        self.accum[v][signature].count = self.accum[v][signature].count + 1
        table.insert(self.accum[v][signature].dats, value)
      end,
      
      Finish = function (self, Output)
        for ver, chunk in pairs(self.accum) do
          local tbd = {}
          for _, v in pairs(chunk) do
            table.insert(tbd, v)
          end
          table.sort(tbd, function(a, b) return a.count > b.count end)
          for i, dat in pairs(tbd) do
            dat.count_pos = i
            Output("", nil, dat)
          end
        end
      end
    } end,
    nil, "error"
  )

  do
    local function acuv(tab, ites)
      local sit = ""
      for _, v in pairs(ites) do
        sit = sit .. string.format("%s: %s\n", tostring(v), tostring(tab[v]))
        tab[v] = nil
      end
      return sit
    end
    local function keez(tab)
      local rv = {}
      for k, _ in pairs(tab) do
        table.insert(rv, k)
      end
      return rv
    end
    
    local error_writer = ChainBlock_Create("error_writer", {error_collater},
      function (key) return {
        Data = function (self, key, subkey, value, Output)
          os.execute("mkdir -p intermed/error/" .. value.ver)
          fil = io.open(string.format("intermed/error/%s/%03d-%05d.txt", value.ver, value.count_pos, value.count), "w")
          fil:write(value.sig)
          fil:write("\n\n\n\n")
          
          for _, tab in pairs(value.dats) do
            local prefix = acuv(tab, {"message", "key", "toc_version", "local_version", "game_version", "locale", "timestamp", "mutation"})
            local postfix = acuv(tab, {"stack", "addons"})
            local midfix = acuv(tab, keez(tab))
            
            fil:write(prefix)
            fil:write("\n")
            fil:write(midfix)
            fil:write("\n")
            fil:write(postfix)
            fil:write("\n\n\n")
          end
          
          fil:close()
        end
      } end
    )
  end
end

local count = 0

local e = 100
--local s = 3500
--local e = 3700

flist = io.popen("ls data/08"):read("*a")
local filz = {}
for f in string.gmatch(flist, "[^\n]+") do
  if not s or count >= s then table.insert(filz, f) end
  count = count + 1
  
  if count == e then break end
end

for k, v in pairs(filz) do
  print(string.format("%d/%d: %s", k, #filz, v))
  chainhead:Insert("data/08/" .. v, nil, nil)
end

print("Finishing")
chainhead:Finish()

check_semiass_failure()
