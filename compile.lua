#!/usr/bin/lua
--[[
local orig_print = print
local orig_write = io.write
print = function (...) orig_print(debug.getinfo(2,"n").name, ...) end
io.write = function (...) orig_write(debug.getinfo(2,"n").name, ...) end
]]

local do_zone_map = true
local do_errors = true

require("persistence")
require("compile_chain")
require("compile_debug")

ll, err = package.loadlib("/home/zorba/build/libcompile_core.so", "init")
if not ll then print(err) return end
ll()

os.execute("rm -rf intermed")
os.execute("mkdir intermed")

os.execute("rm -rf final")
os.execute("mkdir final")

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

local function most_common(tbl)
  local mcv = nil
  local mcvw = nil
  for k, v in pairs(tbl) do
    if not mcvw or v > mcvw then mcv, mcvw = k, v end
  end
  return mcv
end

local function valid_pos(ite)
  if not ite then return end
  if not ite.c or not ite.x or not ite.y or not ite.rc or not ite.rz then return end
  if ite.c ~= 0 and ite.c ~= 3 and ite.c ~= -77 then return end
  return true
end

local function position_accumulate(accu, tpos)
  if not valid_pos(tpos) then return end
  if not accu[tpos.c] then
    accu[tpos.c] = {x = tpos.x, y = tpos.y, weight = 1}
  else
    accu[tpos.c].x = accu[tpos.c].x + tpos.x
    accu[tpos.c].y = accu[tpos.c].y + tpos.y
    accu[tpos.c].weight = accu[tpos.c].weight + 1
  end
end

local function position_has(accu)
  for c, v in pairs(accu) do
    return true -- ha ha
  end
  return false
end

local function position_finalize(accu)
  local best_continent = nil
  local best_continent_count = 0
  for c, v in pairs(accu) do
    if accu[c].weight > best_continent_count then
      best_continent_count = accu[c].weight
      best_continent = c
    end
  end
  if best_continent then
    return { c = best_continent, x = accu[best_continent].x / accu[best_continent].weight, y = accu[best_continent].y / accu[best_continent].weight }
  else
    return nil
  end
end

local function tablesize(tab)
  local ct = 0
  for _, _ in pairs(tab) do
    ct = ct + 1
  end
  return ct
end

local chainhead = ChainBlock_Create("chainhead", nil,
  function () return {
    Data = function (self, key, subkey, value, Output)
      dat = loadfile(key)()
      
      if do_errors then
        for k, v in pairs(dat.QuestHelper_Errors) do
          for _, d in pairs(v) do
            d.key = k
            d.fileid = value.fileid
            Output(d.local_version, nil, d, "error")
          end
        end
      end
      
      for verchunk, v in pairs(dat.QuestHelper_Collector) do
        local qhv, wowv, locale, faction = string.match(verchunk, "([0-9.]+) on ([0-9.]+)/([a-zA-Z]+)/([12])")
        if qhv and wowv and locale and faction and locale == "enUS"
          --and not sortversion("0.80", qhv) -- hacky hacky
        then 
          -- quests!
          if v.quest then for qid, qdat in pairs(v.quest) do
            qdat.fileid = value.fileid
            Output(string.format("%d", qid), qhv, qdat, "quest")
          end end
          
          -- zones!
          if do_zone_map and v.zone then for zname, zdat in pairs(v.zone) do
            local items = {}
            
            for _, key in pairs({"border", "update"}) do
              if items and zdat[key] then for idx, chunk in pairs(zdat[key]) do
                if math.mod(#chunk, 11) ~= 0 then items = nil end
                if not items then break end -- abort, abort
                
                assert(math.mod(#chunk, 11) == 0, tostring(#chunk))
                for point = 1, #chunk, 11 do
                  local pos = slice_loc(string.sub(chunk, point, point + 10))
                  if pos then
                    if not zonecolors[zname] then
                      local r, g, b = math.ceil(math.random(32, 255)), math.ceil(math.random(32, 255)), math.ceil(math.random(32, 255))
                      zonecolors[zname] = r * 65536 + g * 256 + b
                    end
                    pos.zonecolor = zonecolors[zname]
                    if pos.c and pos.x and pos.y then  -- These might be invalid if there are nils embedded in the string. They might still be useful with only one or two nils, but I've got a bunch of data and don't really need more.
                      if not valid_pos(pos) then
                        items = nil
                        break
                      end
                      
                      table.insert(items, pos)
                    end
                  end
                end
              end end
            end
            
            if items then for _, v in pairs(items) do
              v.fileid = value.fileid
              Output(string.format("%d@%04d@%04d", v.c, math.floor(v.y / zone_image_chunksize), math.floor(v.x / zone_image_chunksize)), nil, v, "zone") -- This is inverted - it's continent, y, x, for proper sorting.
              Output(string.format("%d", v.c), nil, {fileid = value.fileid; math.floor(v.x / zone_image_chunksize), math.floor(v.y / zone_image_chunksize)}, "zone_bounds")
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
    accum = {name = {}, criteria = {}, level = {}, start = {}, finish = {}},
    
    Data = function(self, key, subkey, value, Output)
      if value.start then value.start = split_quest_startend(value.start) end
      if value["end"] then   --sigh
        value.finish = split_quest_startend(value["end"])
        value["end"] = nil
      end
      
      if not value.criteria then value.criteria = {} end
      for k, v in pairs(value) do
        local item, token = string.match(k, "criteria_([%d]+)_([a-z]+)")
        if token then
          assert(item)
          
          if token == "satisfied" then
            value[k] = split_quest_satisfied(value[k])
          end
          
          if not value.criteria[tonumber(item)] then value.criteria[tonumber(item)] = {} end
          value.criteria[tonumber(item)][token] = value[k]
          value[k] = nil
        end
      end
      
      if value.start then for k, v in pairs(value.start) do position_accumulate(self.accum.start, v.loc) end end
      if value.finish then for k, v in pairs(value.finish) do position_accumulate(self.accum.finish, v.loc) end end
      for id, dat in pairs(value.criteria) do
        if dat.satisfied then
          if not self.accum.criteria[id] then self.accum.criteria[id] = {} end
          for k, v in pairs(dat.satisfied) do
            position_accumulate(self.accum.criteria[id], v.loc)
          end
        end
      end
      
      
      if value.name then
        local vnx = string.match(value.name, "%b[]%s*(.*)")
        if not vnx then vnx = value.name end
        if vnx ~= value.name then print(value.name, vnx) end
        self.accum.name[vnx] = (self.accum.name[vnx] or 0) + 1
      end
      if value.level then self.accum.level[value.level] = (self.accum.level[value.level] or 0) + 1 end
    end,
    
    Finish = function(self, Output)
      self.accum.name = most_common(self.accum.name)
      self.accum.level = most_common(self.accum.level)
      
      local qout = {}
      for k, v in pairs(self.accum.criteria) do
      
        if not qout.criteria then qout.criteria = {} end
        -- This should be fallback code if it can't figure out which monster or item it actually needs. Right now, it's the only code.
        -- Also, we're going to have a much, much better method for accumulating and distilling positions eventually.
        if position_has(v) then qout.criteria[k] = { loc = position_finalize(v) } end
      end
      
      --if position_has(self.accum.start) then qout.start = { loc = position_finalize(self.accum.start) } end  -- we don't actually care about the start position
      if position_has(self.accum.finish) then qout.finish = { loc = position_finalize(self.accum.finish) } end
      
      -- we don't actually care about the level, so we don't bother to store it. Really, we only care about the name for debug purposes also, so we should probably get rid of it before release.
      qout.name = self.accum.name
      
      local has_stuff = false
      for k, v in pairs(qout) do
        has_stuff = true
        break
      end
      
      if has_stuff then
        Output("", nil, {id="quest", key=tonumber(key), data=qout})
      end
    end,
  } end,
  sortversion, "quest"
)

--[[
*****************************************************************
Zone collation
]]

if do_zone_map then
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
Final file generation
]]

local sources = {}
if quest_slurp then table.insert(sources, quest_slurp) end

local fileout = ChainBlock_Create("fileout", sources,
  function (key) return {
    finalfile = {},
    
    Data = function(self, key, subkey, value, Output)
      if not self.finalfile[value.id] then self.finalfile[value.id] = {} end
      assert(not self.finalfile[value.id][value.key])
      self.finalfile[value.id][value.key] = value.data
    end,
    
    Finish = function(self, Output)
      fil = io.open("final/static.lua", "w")
      
      fil:write("QuestHelper_Static = ")
      persistence.store(fil, self.finalfile)
      
      fil:close()
    end,
  } end
)

--[[
*****************************************************************
Error collation
]]

if do_errors then
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

--local e = 100
--local s = 2650
--local e = 2650

flist = io.popen("ls data/08"):read("*a")
local filz = {}
for f in string.gmatch(flist, "[^\n]+") do
  if not s or count >= s then table.insert(filz, {fname = f, id = count}) end
  count = count + 1
  
  if e and count > e then break end
end

for k, v in pairs(filz) do
  print(string.format("%d/%d: %s", k, #filz, v.fname))
  chainhead:Insert("data/08/" .. v.fname, nil, {fileid = v.id})
end

print("Finishing")
chainhead:Finish()

check_semiass_failure()
