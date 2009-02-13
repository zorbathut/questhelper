#!/usr/bin/lua
--[[
local orig_print = print
local orig_write = io.write
print = function (...) orig_print(debug.getinfo(2,"n").name, ...) end
io.write = function (...) orig_write(debug.getinfo(2,"n").name, ...) end
]]

local do_zone_map = false
local do_errors = true
local do_compile = true

require("persistence")
require("compile_chain")
require("compile_debug")

ll, err = package.loadlib("/nfs/build/libcompile_core.so", "init")
if not ll then print(err) return end
ll()

ChainBlock_Init(function () 
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

local zone_image_chunksize = 1024
local zone_image_descale = 4
local zone_image_outchunk = zone_image_chunksize / zone_image_descale

local zonecolors = {}

--[[
*****************************************************************
Utility functions
]]

local function sortversion(a, b)
  local mtcha, mtchb = not string.match(a, "[%d.]*"), not string.match(b, "[%d.]*")
  if mtcha == mtchb then return a > b end -- common case. Right now, version numbers are such that simple alphabetization sorts properly (although we want it to be sorted backwards.)
  return mtchb -- mtchb is true if b is not a proper string. if b isn't a proper string, we want it after the rest, so we want a first.
end

local function tablesize(tab)
  local ct = 0
  for _, _ in pairs(tab) do
    ct = ct + 1
  end
  return ct
end

--[[
*****************************************************************
Weighted multi-concept accumulation
]]

local function weighted_concept_finalize(data, fraction, minimum)
  if #data == 0 then return end

  fraction = fraction or 0.9
  minimum = minimum or 1
  
  
  table.sort(data, function (a, b) return a.w > b.w end)

  local tw = 0
  for _, v in pairs(data) do
    tw = tw + v.w
  end
  
  local ept
  local wacu = 0
  for k, v in pairs(data) do
    wacu = wacu + v.w
    v.w = nil
    if wacu >= tw * fraction or (data[k + 1] and data[k + 1].w < minimum) then
      ept = k
      break
    end
  end
  assert(ept, tw)
  
  while #data > ept do table.remove(data) end
  
  return data
end

--[[
*****************************************************************
Position accumulation
]]

local function distance(a, b)
  local x = a.x - b.x
  local y = a.y - b.y
  return math.sqrt(x*x+y*y)
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
    accu[tpos.c] = {}
  end
  
  local conti = accu[tpos.c]
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
    table.insert(conti, {x = tpos.x, y = tpos.y, w = 1})
  end
end

local function position_has(accu)
  for c, v in pairs(accu) do
    return true -- ha ha
  end
  return false
end

local function position_finalize(accu)
  if not position_has(accu) then return end
  
  local pozes = {}
  local tw = 0
  for c, ci in pairs(accu) do
    for _, v in ipairs(ci) do
      table.insert(pozes, {c = c, x = v.x, y = v.y, w = v.w})
    end
  end
  
  return weighted_concept_finalize(pozes, 0.8, 10)
end

--[[
*****************************************************************
List-accum functions
]]

local function list_accumulate(item, id, inp)
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

local function list_most_common(tbl)
  local mcv = nil
  local mcvw = nil
  for k, v in pairs(tbl) do
    if not mcvw or v > mcvw then mcv, mcvw = k, v end
  end
  return mcv
end

--[[
*****************************************************************
Locale name accum functions
]]

local function name_accumulate(accum, name, locale)
  if not name then return end
  if not accum[locale] then accum[locale] = {} end
  accum[locale][name] = (accum[locale][name] or 0) + 1
end

local function name_resolve(accum)
  local rv = {}
  for k, v in pairs(accum) do
    rv[k] = list_most_common(v)
  end
  return rv
end

--[[
*****************************************************************
Chain head
]]

local chainhead = ChainBlock_Create("chainhead", nil,
  function () return {
    Data = function (self, key, subkey, value, Output)
      dat = loadfile(key)()
      
      if do_errors then
        for k, v in pairs(dat.QuestHelper_Errors) do
          if k ~= "version" then
            for _, d in pairs(v) do
              d.key = k
              d.fileid = value.fileid
              Output(d.local_version, nil, d, "error")
            end
          end
        end
      end
      
      for verchunk, v in pairs(dat.QuestHelper_Collector) do
        local qhv, wowv, locale, faction = string.match(verchunk, "([0-9.]+) on ([0-9.]+)/([a-zA-Z]+)/([12])")
        if qhv and wowv and locale and faction
          --and not sortversion("0.80", qhv) -- hacky hacky
        then 
          -- quests!
          if do_compile and v.quest then for qid, qdat in pairs(v.quest) do
            qdat.fileid = value.fileid
            qdat.locale = locale
            Output(string.format("%d", qid), qhv, qdat, "quest")
          end end
          
          -- items!
          if do_compile and v.item then for iid, idat in pairs(v.item) do
            idat.fileid = value.fileid
            idat.locale = locale
            Output(string.format("%d", iid), qhv, idat, "item")
          end end
          
          -- monsters!
          if do_compile and v.monster then for mid, mdat in pairs(v.monster) do
            mdat.fileid = value.fileid
            mdat.locale = locale
            Output(string.format("%d", mid), qhv, mdat, "monster")
          end end
          
          -- zones!
          if locale == "enUS" and do_zone_map and v.zone then for zname, zdat in pairs(v.zone) do
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
Monster collation
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
 loot_trivial = {ignoreyesno = true},
 
 rob = {ignoreyesno = true},
 fish = {ignoreyesno = true},
}

local function loot_accumulate(source, sourcetok, Output)
  for typ, specs in pairs(srces) do
    if not specs[ignoreyesno] then
      local yes = source[typ .. "_yes"] or 0
      local no = source[typ .. "_no"] or 0
      
      if yes + no < 10 then continue end -- DENY
      
      if yes / (yes + no) < 0.95 then continue end -- DOUBLEDENY
    end
    
    -- We don't actually care about frequency at the moment, just where people tend to get it from. This works in most cases.
    if source[typ .. "_loot"] then for k, c in pairs(source[typ .. "_loot"]) do
      Output(tostring(k), nil, {source = sourcetok, count = c, type = typ}, "loot")
    end end
  end
  
  for k, _ in pairs(source) do
    if type(k) ~= "string" then continue end
    local tag = k:match("([^_]+)_items")
    assert(not tag or srces[tag])
  end
end

local monster_slurp

if do_compile then 
  monster_slurp = ChainBlock_Create("monster_slurp", {chainhead},
    function (key) return {
      accum = {name = {}, loc = {}},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        for _, v in ipairs(value) do
          if math.mod(#v, 13) ~= 0 then
            return
          end
        end
        
        for _, v in ipairs(value) do
          for off = 1, #v, 13 do
            local tite = slice_loc(v:sub(off, off + 10))
            if tite then position_accumulate(self.accum.loc, tite) end
          end
        end
        
        -- accumulate names
        for k, v in pairs(value) do
          if type(k) == "string" then
            local q = string.match(k, "name_(.*)")
            if q then name_accumulate(self.accum.name, q, value.locale) end
          end
        end
        
        loot_accumulate(value, {type = "monster", id = tonumber(key)}, Output)
      end,
      
      Finish = function(self, Output)
        self.accum.name = name_resolve(self.accum.name)
        
        local qout = {}
        
        -- we don't actually care about the level, so we don't bother to store it. Really, we only care about the name for debug purposes also, so we should probably get rid of it before release.
        qout.name = self.accum.name
        if position_has(self.accum.loc) then qout.loc = position_finalize(self.accum.loc) end
        
        local has_stuff = false
        for k, v in pairs(qout) do
          has_stuff = true
          break
        end
        if has_stuff then
          assert(tonumber(key))
          Output("", nil, {id="monster", key=tonumber(key), data=qout}, "output")
        end
      end,
    } end,
    sortversion, "monster"
  )
end

--[[
local monster_pack
if do_compile then 
  monster_pack = ChainBlock_Create("monster_pack", {monster_slurp},
    function (key) return {
      data = {},
      
      Data = function(self, key, subkey, value, Output)
        assert(not self.data[value.key])
        if not self.data[value.key] then self.data[value.key] = {} end
        self.data[value.key] = value.data
      end,
      
      Finish = function(self, Output, Broadcast)
        Broadcast(nil, {monster=self.data})
      end,
    } end
  )
end]]

--[[
*****************************************************************
Item collation
]]

local item_slurp

if do_compile then
  local item_slurp_first = ChainBlock_Create("item_slurp", {chainhead},
    function (key) return {
      accum = {name = {}},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        name_accumulate(self.accum.name, value.name, value.locale)
        
        loot_accumulate(value, {type = "item", id = tonumber(key)}, Output)
      end,
      
      Finish = function(self, Output)
        self.accum.name = name_resolve(self.accum.name)
        
        local qout = {}
        
        -- we don't actually care about the level, so we don't bother to store it. Really, we only care about the name for debug purposes also, so we should probably get rid of it before release.
        qout.name = self.accum.name
        
        local has_stuff = false
        for k, v in pairs(qout) do
          has_stuff = true
          break
        end
        if has_stuff then
          Output(key, nil, {type = "core", data = qout}, "item")
        end
      end,
    } end,
    sortversion, "item"
  )
  
  
  -- Input to this module is kind of byzantine, so I'm documenting it here.
  -- {Key, Subkey, Value}
  
  -- {999, nil, {source = {type = "monster", id = 12345}, count = 104, type = "skin"}}
  -- Means: "We've seen 104 skinnings of item #999 from monster #12345"
  local lootables = {}
  if monster_slurp then table.insert(lootables, monster_slurp) end
  if item_slurp_first then table.insert(lootables, item_slurp_first) end
  
  local loot_slurp = ChainBlock_Create("loot_slurp", lootables,
    function (key) return {
      lookup = setmetatable({__exists__ = {}}, 
        {__index = function(self, key)
          if not rawget(self, key.sourcetype) then self[key.sourcetype] = {} end
          if not self[key.sourcetype][key.sourceid] then self[key.sourcetype][key.sourceid] = {} end
          if not self[key.sourcetype][key.sourceid][key.type] then self[key.sourcetype][key.sourceid][key.type] = key  table.insert(self.__exists__, key) end
          return self[key.sourcetype][key.sourceid][key.type]
        end
        }),
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        local vx = self.lookup[{sourcetype = value.source.type, sourceid = value.source.id, type = value.type}]
        vx.w = (vx.w or 0) + value.count
      end,
      
      Finish = function(self, Output)
        local tacu = {}
        for k, v in pairs(self.lookup.__exists__) do
          table.insert(tacu, v)
        end
        
        Output(key, nil, {type = "loot", data = weighted_concept_finalize(tacu, 0.9, 10)}, "item")
      end,
    } end,
    nil, "loot"
  )
  
  item_slurp = ChainBlock_Create("item_merge", {item_slurp_first, loot_slurp},
    function (key) return {
      accum = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        assert(not self.accum[value.type])
        self.accum[value.type] = value.data
      end,
      
      Finish = function(self, Output)
        local qout = self.accum.core
        if not qout then qout = {} end -- Surprisingly, we don't care much about the "core".
        
        if self.accum.loot then for k, v in pairs(self.accum.loot) do
          qout[k] = v
          qout.mergey = true
        end end
        
        if key ~= "gold" then -- okay technically the whole thing could have been ignored, but
          assert(tonumber(key))
          Output("", nil, {id="item", key=tonumber(key), data=qout}, "output")
        end
      end,
    } end,
    nil, "item"
  )
end

--[[
*****************************************************************
Quest collation
]]

local quest_slurp

if do_compile then
  local function find_important(dat, count)
    local mungedat = {}
    for k, v in pairs(dat) do
      table.insert(mungedat, {d = k, w = v})
    end
    
    return weighted_concept_finalize(mungedat, 0.9, 10) -- this is not ideal, but it's functional
  end

  quest_slurp = ChainBlock_Create("quest_slurp", {chainhead},
    function (key) return {
      accum = {name = {}, criteria = {}, level = {}, start = {}, finish = {}},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        -- Split apart the start/end info. This includes locations and possibly the monster that was targeted.
        if value.start then value.start = split_quest_startend(value.start) end
        if value["end"] then   --sigh
          value.finish = split_quest_startend(value["end"])
          value["end"] = nil
        end
        
        -- Parse apart the old complicated criteria strings
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
        
        -- Accumulate the old criteria strings into our new data
        if value.start then for k, v in pairs(value.start) do position_accumulate(self.accum.start, v.loc) end end
        if value.finish then for k, v in pairs(value.finish) do position_accumulate(self.accum.finish, v.loc) end end
        for id, dat in pairs(value.criteria) do
          if not self.accum.criteria[id] then self.accum.criteria[id] = {count = 0, loc = {}, monster = {}, item = {}} end
          local cid = self.accum.criteria[id]
          
          if dat.satisfied then
            for k, v in pairs(dat.satisfied) do
              position_accumulate(cid.loc, v.loc)
              cid.count = cid.count + (v.c or 1)
              list_accumulate(cid, "monster", v.monster)
              list_accumulate(cid, "item", v.item)
            end
          end
          
          list_accumulate(cid, "type", dat.type)
        end
        
        -- Accumulate names and levels
        if value.name then
          -- Names is a little complicated - we want to get rid of any recommended-level tags that we might have.
          local vnx = string.match(value.name, "%b[]%s*(.*)")
          if not vnx then vnx = value.name end
          
          name_accumulate(self.accum.name, vnx, value.locale)
        end
        list_accumulate(self.accum, "level", value.level)
      end,
      
      Finish = function(self, Output)
        self.accum.name = name_resolve(self.accum.name)
        self.accum.level = list_most_common(self.accum.level)
        
        local qout = {}
        for k, v in pairs(self.accum.criteria) do
          
          v.type = list_most_common(v.type)
          
          if not qout.criteria then qout.criteria = {} end
          
          -- temp debug output
          -- We shouldn't actually be doing this, we should be figuring out which monsters and items this really correlates to.
          -- We're currently not. However, this will require correlating with the names for monsters and items.
          local snaggy
          if v.type == "monster" then
            snaggy = find_important(v.monster, v.count)
          elseif v.type == "item" then
            snaggy = find_important(v.item, v.count)
          end
          
          if snaggy then
            assert(#snaggy > 0)
            qout.criteria[k] = {}
            for _, x in ipairs(snaggy) do
              table.insert(qout.criteria[k], {v.type, x.d})
            end
          else
            -- Fallback code if it can't figure out which monster or item it actually needs. Right now, it's the only code.
            -- Also, we're going to have a much, much better method for accumulating and distilling positions eventually.
            qout.criteria[k] = {}
            qout.criteria[k].type = v.type
            
            if position_has(v) then qout.criteria[k].loc = position_finalize(v.loc) end
          end
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
          assert(tonumber(key))
          Output("", nil, {id="quest", key=tonumber(key), data=qout}, "output")
        end
      end,
    } end,
    sortversion, "quest"
  )
end

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
if item_slurp then table.insert(sources, item_slurp) end
if monster_slurp then table.insert(sources, monster_slurp) end

local fileout = ChainBlock_Create("fileout", sources,
  function (key) return {
    finalfile = {},
    
    Data = function(self, key, subkey, value, Output)
      assert(value.data)
      assert(value.id)
      assert(value.key)
      if value.data.name then value.data.name = value.data.name.enUS end -- needs improvement
      
      if not self.finalfile[value.id] then self.finalfile[value.id] = {} end
      assert(not self.finalfile[value.id][value.key])
      self.finalfile[value.id][value.key] = value.data
    end,
    
    Finish = function(self, Output)
      fil = io.open("final/static.lua", "w")
      fil:write([=[QuestHelper_File["static.lua"] = "Development Version"
QuestHelper_Loadtime["static.lua"] = GetTime()

]=])
      fil:write("QuestHelper_Static = ")
      persistence.store(fil, self.finalfile)
      
      fil:close()
    end,
  } end,
  nil, "output"
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
        if value.key ~= "crash" then signature = value.key end
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

if ChainBlock_Work() then return end

local count = 1

--local s = 1048
--local e = 1048
local e = 1000

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
