#!/usr/bin/lua

-- Loot reset starting at 1.2.4?

local do_zone_map = false
local do_errors = true

local do_compile = true
local do_questtables = true
local do_flight = true
local do_achievements = true
local do_find = true

local do_cull = true

local do_compress = true
local do_serialize = true

dbg_data = false

if dbg_data then do_cull = false do_compress = false end

--local s = 47411
--local e = 47411
--local s = 0
--local e = 10000

require "compile_lib"
require "overrides"

--[[
*****************************************************************
Chain head
]]

local versix = nil

local chainhead = ChainBlock_Create("parse", nil,
  function () return {
    Data = function (self, key, subkey, value, Output)
      local gzx = gzio.open(key, "r")
      local gzd = gzx:read("*a")
      gzx:close()
      gzx = nil
      local dat = pluto.unpersist({}, gzd)
      gzd = nil
      assert(dat)
      
      if do_errors and dat.errors and false then
        for k, v in pairs(dat.errors) do
          --do continue end -- ARGH
          if k ~= "version" then
            for _, d in pairs(v) do
              d.key = k
              d.fileid = value.fileid
              Output(d.local_version, nil, d, "error")
            end
          end
        end
      end
      
      local qhv, wowv, locale, faction = string.match(dat.signature, "([0-9.]+) on ([0-9.]+)/([a-zA-Z]+)/([12])")
      if qhv and wowv and locale and faction
        --and not sortversion("0.80", qhv) -- hacky hacky
      then
        if wowv == "0.3.0" and version_lessthan(qhv, "1.2.0") then print("Corrupted 0.3.0 data, discarding") return end
      
        local v = dat.data
        assert(v.version)
        if versix then
          if versix ~= v.version then print("Version mismatch!", versix, v.version) end
          assert(versix == v.version)
        end
        versix = v.version
        
        --[[if v.compressed then
          local deco = "return " .. LZW.Decompress(v.compressed, 256, 8)
          print(#v.compressed, #deco)
          local tx = loadstring(deco)()
          assert(tx)
          v.compressed = nil
          for tk, tv in pairs(tx) do
            v[tk] = tv
          end
        end]]
        assert(not v.compressed)
        
        QuestHelper_IndexLookup(wowv) -- make sure we've got the version available
        
        -- quests!
        if do_compile and do_questtables and v.quest then for qid, qdat in pairs(v.quest) do
          --if qid ~= 14107 then continue end -- ARGH
          qdat.fileid = value.fileid
          qdat.locale = locale
          qdat.wowv = wowv
          qdat.faction = tonumber(faction)
          Output(string.format("%d", qid), qhv, qdat, "quest")
        end end
        
        -- items!
        if do_compile and do_questtables and v.item then for iid, idat in pairs(v.item) do
          --do continue end -- ARGH
          idat.fileid = value.fileid
          idat.locale = locale
          idat.wowv = wowv
          Output(tostring(iid), qhv, idat, "item")
        end end
        
        -- monsters!
        if do_compile and do_questtables and v.monster then for mid, mdat in pairs(v.monster) do
          --do continue end -- ARGH
          mdat.fileid = value.fileid
          mdat.locale = locale
          mdat.wowv = wowv
          Output(tostring(mid), qhv, mdat, "monster")
        end end
        
        if do_compile and do_questtables and v.fishing then for floc, fdat in pairs(v.fishing) do
          --do continue end -- ARGH
          fdat.fileid = value.fileid
          fdat.locale = locale
          fdat.wowv = wowv
          Output(floc, qhv, fdat, "fishing")
        end end
        
        -- objects!
        if do_compile and do_questtables and v.object then for oid, odat in pairs(v.object) do
          odat.fileid = value.fileid
          odat.locale = locale
          odat.wowv = wowv
          Output(string.format("%s@@%s", oid, locale), qhv, odat, "object")
        end end
        
        -- flight masters!
        if do_compile and do_flight and v.flight_master then for fmname, fmdat in pairs(v.flight_master) do
          --do continue end -- ARGH
          if type(fmdat.master) == "string" then continue end  -- I don't even know how this is possible
          Output(string.format("%s@@%s@@%s", faction, fmname, locale), qhv, {dat = fmdat, wowv = wowv}, "flight_master")
        end end
        
        -- flight times!
        if do_compile and do_flight and v.flight_times then for ftname, ftdat in pairs(v.flight_times) do
          --do continue end -- ARGH
          if type(ftdat) ~= "table" then continue end
          Output(string.format("%s@@%s@@%s", ftname, faction, locale), qhv, ftdat, "flight_times")
        end end
        
        -- achievements!
        if do_compile and do_achievements and v.achievement then for aloc, adat in pairs(v.achievement) do
          adat.fileid = value.fileid
          adat.locale = locale
          adat.wowv = wowv
          Output(tostring(aloc), qhv, adat, "achievement")
        end end
        
        -- zones!
        if locale == "enUS" and do_zone_map and v.zone then for zname, zdat in pairs(v.zone) do
          local items = {}
          local lv = loc_version(qhv)
          
          for _, key in pairs({"border", "update"}) do
            if items and zdat[key] then for idx, chunk in pairs(zdat[key]) do
              if math.mod(#chunk, 11) ~= 0 then items = nil end
              if not items then break end -- abort, abort
              
              assert(math.mod(#chunk, 11) == 0, tostring(#chunk))
              for point = 1, #chunk, 11 do
                local pos = convert_loc(slice_loc(string.sub(chunk, point, point + 10), lv), locale, lv)
                if pos then
                  if not zonecolors[zname] then
                    local r, g, b = math.ceil(math.random(32, 255)), math.ceil(math.random(32, 255)), math.ceil(math.random(32, 255))
                    zonecolors[zname] = r * 65536 + g * 256 + b
                  end
                  pos.zonecolor = zonecolors[zname]
                  if pos.p and pos.x and pos.y then  -- These might be invalid if there are nils embedded in the string. They might still be useful with only one or two nils, but I've got a bunch of data and don't really need more.
                    if not valid_pos(pos) then
                      items = nil
                      break
                    end
                    
                    pos.c = QuestHelper_ZoneLookup(wowv)[ite.p][1]
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
        --print("Dumped, locale " .. dat.signature)
      end
    end
  } end
)

--[[
*****************************************************************
Object collation
]]

local object_slurp

if do_compile then 
  local object_locate = ChainBlock_Create("object_locate", {chainhead},
    function (key) return {
      accum = {name = {}, loc = {}},
      
      fids = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        local name, locale = key:match("(.*)@@(.*)")
        
        if standard_pos_accum(self.accum, value, loc_version(subkey), locale, 0, value.wowv) then return end
        
        while #value > 0 do table.remove(value) end
        
        table.insert(self.accum, value)
        self.fids[value.fileid] = true
      end,
      
      Finish = function(self, Output, Broadcast)
        local fidc = 0
        for k, v in pairs(self.fids) do
          fidc = fidc + 1
        end
        
        local name, locale = key:match("(.*)@@(.*)")
        --if locale ~= "enUS" then print(locale, fidc) end
        if fidc < 3 then return end -- bzzzzzt
        
        local qout = {}
        
        if position_has(self.accum.loc) then
          qout.loc = position_finalize(self.accum.loc)
        else
          --if locale ~= "enUS" then print("nopos") end
          return  -- BZZZZZT
        end
        
        if locale == "enUS" then
          Broadcast("object", {name = name, loc = qout.loc})
          Output("", nil, {enUS = name}, "combine")
          --Output("", nil, {type = "data", name = key, data = self.accum}, "reparse")
        else
          Output(key, nil, qout.loc, "link")
          --Output("", nil, {type = "data", name = key, data = self.accum}, "reparse")
        end
      end,
    } end,
    sortversion, "object"
  )
  
  local function find_closest(loc, locblock)
    local closest = 5000000000  -- yeah, that's five billion. five fuckin' billion.
    --print(#locblock)
    for _, ite in ipairs(locblock) do
      if loc.p == ite.p then
        local tx = loc.x - ite.x
        local ty = loc.y - ite.y
        local d = tx * tx + ty * ty
        if d < closest then
          closest = d
        end
      end
    end
    return closest
  end
  
  local object_link = ChainBlock_Create("object_link", {object_locate},
    function (key) return {
      
      compare = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        assert(not self.key)
        assert(not self.loc)
        assert(key)
        assert(value)
        
        self.key = key
        self.loc = value
      end,
      
      Receive = function(self, id, data)
        assert(id == "object")
        assert(data)
        assert(not self.compare[data.name])
        
        self.compare[data.name] = data.loc
      end,
      
      Finish = function(self, Output, Broadcast)
        assert(self.key)
        assert(self.loc)
        assert(self.compare)
        
        local results = {}
        local res_size = 0
        
        for enuname, loca in pairs(self.compare) do
          local yaku = 0
          for _, cl in ipairs(loca) do
            yaku = yaku + find_closest(cl, self.loc)
          end
          for _, cl in ipairs(self.loc) do
            yaku = yaku + find_closest(cl, loca)
          end
          yaku = yaku / (#loca + #self.loc)
          assert(not results[enuname])
          results[enuname] = yaku
          res_size = res_size + 1
        end
        
        local nres_size = 0
        local nres = {}
        for k, v in pairs(results) do
          if v < 1000000 then
            nres[k] = v
            nres_size = nres_size + 1
          end
        end
        
        print(res_size, nres_size)
        Output("", nil, {key = key, data = nres}, "combine")
      end,
    } end,
    nil, "link"
  )
  
  local function heap_left(x) return (2*x) end
  local function heap_right(x) return (2*x + 1) end
  
  local function heap_sane(heap)
    local dmp = ""
    local finishbefore = 2
    for i = 1, #heap do
      if i == finishbefore then
        print(dmp)
        dmp = ""
        finishbefore = finishbefore * 2
      end
      dmp = dmp .. string.format("%f ", heap[i].c)
    end
    print(dmp)
    print("")
    for i = 1, #heap do
      assert(not heap[heap_left(i)] or heap[i].c <= heap[heap_left(i)].c)
      assert(not heap[heap_right(i)] or heap[i].c <= heap[heap_right(i)].c)
    end
  end
  
  local function heap_insert(heap, item)
    assert(item)
    table.insert(heap, item)
    local pt = #heap
    while pt > 1 do
      local ptd2 = math.floor(pt / 2)
      if heap[ptd2].c <= heap[pt].c then
        break
      end
      local tmp = heap[pt]
      heap[pt] = heap[ptd2]
      heap[ptd2] = tmp
      pt = ptd2
    end
    --heap_sane(heap)
  end
  

  local function heap_extract(heap)
    local rv = heap[1]
    if #heap == 1 then table.remove(heap) return rv end
    heap[1] = table.remove(heap)
    local idx = 1
    while idx < #heap do
      local minix = idx
      if heap[heap_left(idx)] and heap[heap_left(idx)].c < heap[minix].c then minix = heap_left(idx) end
      if heap[heap_right(idx)] and heap[heap_right(idx)].c < heap[minix].c then minix = heap_right(idx) end
      if minix ~= idx then
        local tx = heap[minix]
        heap[minix] = heap[idx]
        heap[idx] = tx
        idx = minix
      else
        break
      end
    end
    --heap_sane(heap)
    return rv
  end
  
  --[[
  do
    local heaptest = {}
    for k = 1, 10 do
      heap_insert(heaptest, {c = math.random()})
    end
    while #heaptest > 0 do
      heap_extract(heaptest)
    end
  end]]
  
  local object_combine = ChainBlock_Create("object_combine", {object_link, object_locate},
    function (key) return {
    
      source = {enUS = {}},
      heap = {},
    
      Data = function(self, key, subkey, value, Output)
        if value.key then
          local name, locale = value.key:match("(.*)@@(.*)")  -- boobies regexp
          -- insert shit into a heap
          if not self.source[locale] then self.source[locale] = {} end
          self.source[locale][name] = {}
          for k, v in pairs(value.data) do
            heap_insert(self.heap, {c = v, dst_locale = locale, dst = name, src = k})
          end
        else
          assert(value.enUS)
          self.source.enUS[value.enUS] = {linkedto = {}}
        end
      end,
      
      Receive = function () end,
      
      Finish = function(self, Output, Broadcast)
        print("heap is", #self.heap)
        
        -- pull shit out of the heap, link things up
        local llst = 0
        while #self.heap > 0 do
          local ite = heap_extract(self.heap)
          assert(ite.c >= llst)
          llst = ite.c
          
          if not self.source.enUS[ite.src].linkedto[ite.dst_locale] and not self.source[ite.dst_locale][ite.dst].linked then
            self.source.enUS[ite.src].linkedto[ite.dst_locale] = ite.dst
            self.source[ite.dst_locale][ite.dst].linked = true
            print(string.format("Linked %s to %s/%s (%f)", ite.src, ite.dst_locale, ite.dst, ite.c))
          end
        end
        
        -- we're going to assume that if it's not in enUS, it doesn't exist
        -- determine unique IDs for everything we have
        local ids = {}
        local lookup = {enUS = {}}
        for k, v in pairs(self.source.enUS) do
          print("enUS:", k)
          table.insert(ids, k)
          local id = #ids
          
          lookup.enUS[k] = id
          
          for nation, str in pairs(v.linkedto) do
            print(string.format("  %s:", nation), str)
            if not lookup[nation] then lookup[nation] = {} end
            lookup[nation][str] = id
          end
        end
        
        Broadcast("lookup", lookup)
      end,
    } end,
    nil, "combine"
  )
  
  
  local object_redispatch = ChainBlock_Create("object_redispatch", {chainhead, object_combine},
    function (key) return {
      Data = function(self, key, subkey, value, Output)
        local name, locale = key:match("(.*)@@(.*)")  -- boobies regexp
        if self.lookup and self.lookup[locale] and self.lookup[locale][name] then
          local mkmore = {}
          for k, v in pairs(value) do
            mkmore[k] = v
          end
          mkmore.name = name
          Output(tostring(self.lookup[locale][name]), subkey, mkmore, "object")
        end
      end,
      
      Receive = function(self, key, data)
        assert(key == "lookup")
        assert(not self.lookup)
        assert(data)
        self.lookup = data
      end,
    } end,
    nil, "object"
  )
  
  -- then, now that we finally have IDs, we do our standard mambo of stuff
  object_slurp = ChainBlock_Create("object_slurp", {object_redispatch},
    function (key) return {
      accum = {name = {}, loc = {}},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        if standard_pos_accum(self.accum, value, loc_version(subkey), value.locale, 0, value.wowv) then return end
        name_accumulate(self.accum.name, value.name, value.locale)
        
        loot_accumulate(value, {type = "object", id = tonumber(key)}, Output)
      end,
      
      Finish = function(self, Output)
        self.accum.name = name_resolve(self.accum.name)
        
        local qout = {}
        
        if dbg_data then qout.dbg_name = self.accum.name.enUS end
        if position_has(self.accum.loc) then qout.loc = position_finalize(self.accum.loc) end
        
        local has_stuff = false
        for k, v in pairs(qout) do
          has_stuff = true
          break
        end
        assert(tonumber(key))
        if has_stuff then
          Output("*/*", nil, {id="object", key=tonumber(key), data=qout}, "output")
        end
        for k, v in pairs(self.accum.name) do
          Output(("%s/*"):format(k), nil, {id="object", key=tonumber(key), data={name=v}}, "output")
        end
      end,
    } end,
    sortversion, "object"
  )
end

--[[
*****************************************************************
Monster collation
]]

local monster_slurp

if do_compile and do_questtables then 
  monster_slurp = ChainBlock_Create("monster_slurp", {chainhead},
    function (key) return {
      accum = {name = {}, loc = {}},
      tof = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        assert(value.wowv)
        if overrides.quest[tonumber(key)] and sortversion(overrides.quest[tonumber(key)], value.wowv) then
          if not self.tof[value.wowv] then
            print("Threw out", key, value.wowv, overrides.quest[tonumber(key)])
            self.tof[value.wowv] = true
          end
          return
        end
        
        if standard_pos_accum(self.accum, value, loc_version(subkey), value.locale, 2, value.wowv) then return end
        if standard_name_accum(self.accum.name, value) then return end
        
        loot_accumulate(value, {type = "monster", id = tonumber(key)}, Output)
      end,
      
      Finish = function(self, Output)
        self.accum.name = name_resolve(self.accum.name)
        
        local qout = {}
        
        if dbg_data then qout.dbg_name = self.accum.name.enUS end
        if position_has(self.accum.loc) then qout.loc = position_finalize(self.accum.loc) end
        
        local has_stuff = false
        for k, v in pairs(qout) do
          has_stuff = true
          break
        end
        assert(tonumber(key))
        if has_stuff then
          Output("*/*", nil, {id="monster", key=tonumber(key), data=qout}, "output")
        end
        for k, v in pairs(self.accum.name) do
          Output(("%s/*"):format(k), nil, {id="monster", key=tonumber(key), data={name=v}}, "output")
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

local item_name_package
local item_slurp
local item_parse

if do_compile and do_questtables then
  fishing = ChainBlock_Create("fishing", {chainhead},
    function (key) return {
      Data = function(self, key, subkey, value, Output)
        if value.fish_loot then for k, v in pairs(value.fish_loot) do
          Output(tostring(k), nil, {count = v, loc = key, locale = value.locale, wowv = value.wowv, qhv = subkey}, "item_loc")
        end end
      end,
    } end,
  nil, "fishing")
  
  item_loc = ChainBlock_Create("item_loc", {fishing},
    function (key) return {
      accum = {loc = {}},
      Data = function(self, key, subkey, value, Output)
        if overrides.item[tonumber(key)] and sortversion(overrides.item[tonumber(key)], value.wowv) then
          if not self.tof[value.wowv] then
            print("Threw out", key, value.wowv, overrides.item[tonumber(key)])
            self.tof[value.wowv] = true
          end
          return
        end
        
        if #value.loc ~= 11 then print("Unknown size", #value.loc, value.loc) return end  -- what
        
        local loc = convert_loc(slice_loc(value.loc, loc_version(value.qhv)), value.locale, loc_version(value.qhv), value.wowv)
        if loc then position_accumulate(self.accum.loc, loc, value.wowv) end
      end,
      Finish = function(self, Output)
        if position_has(self.accum.loc) then
          Output(key, nil, {type = "loc", data = position_finalize(self.accum.loc)}, "item")
        end
      end,
    } end,
  nil, "item_loc")
  
  item_parse = ChainBlock_Create("item_parse", {chainhead},
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
        if dbg_data then qout.dbg_name = self.accum.name.enUS end
        
        --[[Output("", nil, {key = key, name = qout.name}, "name")]]
        
        local has_stuff = false
        for k, v in pairs(qout) do
          has_stuff = true
          break
        end
        
        if has_stuff then
          Output(key, nil, {type = "core", data = qout}, "item")
        end
        for k, v in pairs(self.accum.name) do
          Output(("%s/*"):format(k), nil, {id="item", key=tonumber(key), data={name=v}}, "output")
        end
      end,
    } end,
    sortversion, "item"
  )
  
  --[[
  item_name_package = ChainBlock_Create("item_name_package", {item_slurp_first},
    function (key) return {
      accum = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        assert(not self.accum[value.key])
        self.accum[value.key] = value.name
      end,
      
      Finish = function(self, Output, Broadcast)
        Broadcast("item_name_package", self.accum)
      end,
    } end,
    nil, "name"
  )]]
  
  -- Input to this module is kind of byzantine, so I'm documenting it here.
  -- {Key, Subkey, Value}
  
  -- {999, nil, {source = {type = "monster", id = 12345}, count = 104, type = "skin"}}
  -- Means: "We've seen 104 skinnings of item #999 from monster #12345"
  local lootables = {}
  if monster_slurp then table.insert(lootables, monster_slurp) end
  if object_slurp then table.insert(lootables, object_slurp) end
  if item_parse then table.insert(lootables, item_parse) end
  
  local loot_merge = ChainBlock_Create("loot_merge", lootables,
    function (key) return {
      lookup = setmetatable({__exists__ = {}}, 
        {__index = function(self, key)
          if not rawget(self, key.sourcetype) then self[key.sourcetype] = {} end
          if not self[key.sourcetype][key.sourceid] then self[key.sourcetype][key.sourceid] = {} end
          if not self[key.sourcetype][key.sourceid][key.type] then self[key.sourcetype][key.sourceid][key.type] = key  table.insert(self.__exists__, key) end
          return self[key.sourcetype][key.sourceid][key.type]
        end
        }),
      
      dtime = 0,
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        --local st = os.time()
        local vx = self.lookup[{sourcetype = value.source.type, sourceid = value.source.id, type = value.type}]
        vx.w = (vx.w or 0) + value.count
        --self.dtime = self.dtime + os.time() - st
      end,
      
      Finish = function(self, Output)
        --local st = os.time()
        local tacu = {}
        for k, v in pairs(self.lookup.__exists__) do
          table.insert(tacu, v)
        end
        
        --local tacuc = #tacu
        
        Output(key, nil, {type = "loot", data = weighted_concept_finalize(tacu, 0.9, 10)}, "item")
      end,
    } end,
    nil, "loot"
  )
  
  item_slurp = ChainBlock_Create("item_slurp", {item_parse, loot_merge, item_loc},
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
        end end
        
        if self.accum.loc then qout.loc = self.accum.loc end
        
        if key ~= "gold" then -- okay technically the whole thing could have been ignored, but
          assert(tonumber(key))
          Output("*/*", nil, {id="item", key=tonumber(key), data=qout}, "output")
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

if do_compile and do_questtables then
  local function find_important(dat, count)
    local mungedat = {}
    local tweight = 0
    for k, v in pairs(dat) do
      table.insert(mungedat, {d = k, w = v})
      tweight = tweight + v
    end
    
    if tweight < count / 2 then return end  -- we just don't have enough, something's gone wrong
    
    return weighted_concept_finalize(mungedat, 0.9, 10, count) -- this is not ideal, but it's functional
  end

  quest_slurp = ChainBlock_Create("quest_slurp", {chainhead --[[, item_name_package]]},
    function (key) return {
      accum = {name = {}, criteria = {}, level = {}, start = {}, finish = {}},
      tof = {},
      faction = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        assert(value.wowv)
        if overrides.quest[tonumber(key)] and sortversion(overrides.quest[tonumber(key)], value.wowv) then
          if not self.tof[value.wowv] then
            print("Threw out", key, value.wowv, overrides.quest[tonumber(key)])
            self.tof[value.wowv] = true
          end
          return
        end
        
        self.exists = true
        self.faction[value.faction] = (self.faction[value.faction] or 0) + 1
        --print("faction", value.faction)

        local lv = loc_version(subkey)
        
        -- Split apart the start/end info. This includes locations and possibly the monster that was targeted.
        if value.start then
          value.start = split_quest_startend(value.start, lv)
          assert(value.wowv)
          convert_multiple_loc(value.start, value.locale, lv, value.wowv)
        end
        if value["end"] then   --sigh
          value.finish = split_quest_startend(value["end"], lv)
          convert_multiple_loc(value.finish, value.locale, lv, value.wowv)
          value["end"] = nil
        end
        
        -- Parse apart the old complicated criteria strings
        if not value.criteria then value.criteria = {} end
        for k, v in pairs(value) do
          local item, token = string.match(k, "criteria_([%d]+)_([a-z]+)")
          if token then
            assert(item)
            
            if token == "satisfied" then
              value[k] = split_quest_satisfied(value[k], lv)
              convert_multiple_loc(value[k], value.locale, lv, value.wowv)
            end
            
            if not value.criteria[tonumber(item)] then value.criteria[tonumber(item)] = {} end
            value.criteria[tonumber(item)][token] = value[k]
            value[k] = nil
          end
        end
        
        -- Accumulate the old criteria strings into our new data
        if value.start then for k, v in pairs(value.start) do position_accumulate(self.accum.start, v.loc, value.wowv) end end
        if value.finish then for k, v in pairs(value.finish) do position_accumulate(self.accum.finish, v.loc, value.wowv) end end
        
        if value.daily == true then
          self.accum.daily_true = (self.accum.daily_true or 0) + 1
        end
        if value.daily == false then
          self.accum.daily_false = (self.accum.daily_false or 0) + 1
        end
        
        self.accum.appearances = (self.accum.appearances or 0) + 1
        for id, dat in pairs(value.criteria) do
          if not self.accum.criteria[id] then self.accum.criteria[id] = {count = 0, loc = {}, monster = {}, item = {}} end
          local cid = self.accum.criteria[id]
          
          if dat.satisfied then
            for k, v in pairs(dat.satisfied) do
              position_accumulate(cid.loc, v.loc, value.wowv)
              cid.count = cid.count + (v.c or 1)
              list_accumulate(cid, "monster", v.monster)
              list_accumulate(cid, "item", v.item)
            end
          end
          
          cid.appearances = (cid.appearances or 0) + 1
          
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
      
      --[[
      Receive = function(self, id, data)
        self.namedb = data
      end,]]
      
      Finish = function(self, Output)
        if not self.accum.appearances then print("Know the existence of, but have no data for quest", key) return end
        if not self.exists then return end
        
        if not self.faction[1] and not self.faction[2] then
          print("wackyfact start")
          for k, v in pairs(self.faction) do
            print("wackyfact:", k)
          end
        end
        assert(self.faction[1] or self.faction[2])
        
        self.accum.name = name_resolve(self.accum.name)
        self.accum.level = list_most_common(self.accum.level)
        
        -- First we see if we need to chop out some criteria
        do
          local appearances = self.accum.appearances * 0.9
          appearances = appearances * 0.9
          local strips = {}
          for k, v in pairs(self.accum.criteria) do
            if v.appearances < appearances then
              table.insert(strips, k)
            end
          end
          for _, v in pairs(strips) do
            self.accum.criteria[v] = nil
          end
        end
        
        local qout = {}
        for k, v in pairs(self.accum.criteria) do
          
          v.type = list_most_common(v.type)
          
          if not qout.criteria then qout.criteria = {} end
          
          -- temp debug output
          -- We shouldn't actually be doing this, we should be figuring out which monsters and items this really correlates to.
          -- We're currently not. However, this will require correlating with the names for monsters and items.
          local snaggy, typ
          if v.type == "monster" then
            snaggy = find_important(v.monster, v.count)
            typ = "kill"
          elseif v.type == "item" then
            snaggy = find_important(v.item, v.count)
            typ = "get"
          end
          
          qout.criteria[k] = {}
          
          if dbg_data then
            qout.criteria[k].item = v.item
            qout.criteria[k].monster = v.monster
            qout.criteria[k].count = v.count
            qout.criteria[k].type = v.type
            qout.criteria[k].appearances = v.appearances
            
            qout.criteria[k].snaggy = snaggy or "(nothin')"
          end
          
          if snaggy then
            assert(#snaggy > 0)
            
            for _, x in ipairs(snaggy) do
              table.insert(qout.criteria[k], {sourcetype = v.type, sourceid = x.d, type = typ})
            end
          end
          
          if position_has(v) then qout.criteria[k].loc = position_finalize(v.loc) end
        end
        
        --if position_has(self.accum.start) then qout.start = { loc = position_finalize(self.accum.start) } end  -- we don't actually care about the start position
        if position_has(self.accum.finish) then qout.finish = { loc = position_finalize(self.accum.finish) } end
        if position_has(self.accum.start) then qout.start = { loc = position_finalize(self.accum.start) } end
        
        qout.faction = self.faction
        
        if (self.accum.daily_true or 0) > (self.accum.daily_false or 0) then
          qout.daily = true
        end
        
        -- we don't actually care about the level, so we don't bother to store it. Really, we only care about the name for debug purposes also, so we should probably get rid of it before release.
        if dbg_data then
          qout.dbg_name = self.accum.name.enUS
          qout.appearances = self.accum.appearances or "none"
        end
        
        local has_stuff = false
        for k, v in pairs(qout) do
          has_stuff = true
          break
        end
        assert(tonumber(key))
        if has_stuff then
          --print("Quest output " .. tostring(key))
          Output("*/*", nil, {id="quest", key=tonumber(key), data=qout}, "output")
          
          for k, v in pairs(self.accum.name) do
            Output(("%s/*"):format(k), nil, {id="quest", key=tonumber(key), data={name=v}}, "output")
          end
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
Flight paths
]]

--[[

let us talk about flight paths

sit down

have some tea

very well, let us begin

So, flight masters. First, accumulate each one of each faction/name/locale set. This includes both monsterid (pick most common) and vertex location (simple most-common.)

Then we link together name/locale's of various factions, just so we can get names out and IDs.

After that, we take our routes and determine IDs, with name-lookup for the first and last node, and vertex-lookup for all other nodes, with some really low error threshold. Pick the mean time for each route that has over N tests, then dump those.

For now we'll assume that this will provide sufficiently accurate information.

We'll do this, then start working on the clientside code.

]]

local flight_data_output
local flight_table_output
local flight_master_name_output

if do_compile and do_flight then
  local flight_master_parse = ChainBlock_Create("flight_master_parse", {chainhead},
    function (key) return {
      mids = {},
      locs = {},
      newest_version = nil,
      count = 0,
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        if not sortversion(self.newest_version, value.wowv) then
          self.newest_version = value.wowv
        end
        
        list_accumulate(self, "mids", value.dat.master)
        list_accumulate(self, "locs", string.format("%s@@%s", value.dat.x, value.dat.y))
        self.count = self.count + 1
      end,
      
      Finish = function(self, Output)
        if self.count < 10 then return end
        
        local faction, name, locale = key:match("(.*)@@(.*)@@(.*)")
        assert(faction)
        assert(name)
        assert(locale)
        local mid = list_most_common(self.mids)
        local loc = list_most_common(self.locs)
        
        Output(string.format("%s@@%s", loc, faction), nil, {locale = locale, name = name, mid = mid, version = self.newest_version})
      end,
    } end,
    sortversion, "flight_master"
  )
  
  local flight_master_accumulate = ChainBlock_Create("flight_master_accumulate", {flight_master_parse},
    function (key) return {
      
      names = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        if self.names[value.locale] then
          --print(key, value.locale, self.names[value.locale], value.name)
          
          --print(self.names[value.locale].version, value.version, sortversion(self.names[value.locale].version, value.version), self.names[value.locale].name, value.name)
          
          if version_lessthan(value.version, self.names[value.locale].version) then
            self.names[value.locale] = nil  -- we just blow it away and rebuild it later
          end
        end
        
        if not self.names[value.locale] then self.names[value.locale] = {version = value.version} end
        
        list_accumulate(self.names[value.locale], "name", value.name)
        list_accumulate(self, "mid", value.mid)
      end,
      
      Finish = function(self, Output)
        local x, y, faction = key:match("(.*)@@(.*)@@(.*)")
        local namepack = {}
        for k, v in pairs(self.names) do
          namepack[k] = list_most_common(v.name)
        end
        
        Output(tostring(faction), nil, {x = x, y = y, faction = faction, mid = list_most_common(self.mid), names = namepack})
      end,
    } end
  )
  
  if false then
    local flight_master_test = ChainBlock_Create("flight_master_test", {flight_master_accumulate},
      function (key) return {
        
        data = {},
        
        -- Here's our actual data
        Data = function(self, key, subkey, value, Output)
          table.insert(self.data, value)
        end,
        
        Finish = function(self, Output)
          local links = {}
          for x = 1, #self.data do
            for y = x + 1, #self.data do
              local dx = self.data[x].x - self.data[y].x
              local dy = self.data[x].y - self.data[y].y
              local diff = math.sqrt(dx * dx + dy * dy)
              if diff < 0.001 then
                print("------")
                print(diff)
                dbgout(self.data[x])
                dbgout(self.data[y])
              end
              table.insert(links, diff)
            end
          end
          
          table.sort(links)
          
          for x = 1, math.min(100, #links) do
            print(links[x])
          end
        end,
      } end
    )
  end
  
  local flight_master_pack = ChainBlock_Create("flight_master_pack", {flight_master_accumulate},
    function (key) return {
      pack = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        table.insert(self.pack, value)
      end,
      
      Finish = function(self, Output, Broadcast)
        print("Broadcasting", key)
        Broadcast(key, self.pack)
        
        Output(key, nil, "", "name_output") -- just exists to make sure name_output does something
      end,
    } end
  )
  
  local function findname(lookup, dat, locale)
    for k, v in ipairs(lookup) do
      if v.names[locale] == dat then return k end
    end
  end
  
  local flight_master_times = ChainBlock_Create("flight_master_times", {flight_master_pack, chainhead},
    function (key) local src, dst, faction, locale = key:match("(.*)@@(.*)@@(.*)@@(.*)") assert(faction and src and dst and locale) return {
      
      Data = function(self, key, subkey, value, Output)
        if self.fail then return end
        
        if not self.table then if not e or e > 1000 then print("Entire missing faction table!") end return end
        assert(self.table)
        
        if not self.src or not self.dst then
          self.src = findname(self.table, src, locale)
          self.dst = findname(self.table, dst, locale)
          
          --if not self.src then print("failed to find ", src) end
          --if not self.dst then print("failed to find ", dst) end
          if not self.src or not self.dst then self.fail = true return end
        end
        
        assert(self.src)
        assert(self.dst)
        
        for k, v in pairs(value) do
          if type(v) == "number" and value[k .. "##count"] then
            local path = {}
            for node in k:gmatch("[^@]+") do
              local x, y = node:match("(.*):(.*)")
              x, y = tonumber(x), tonumber(y)
              local closest, closestval = nil, 0.01
              for k, v in ipairs(self.table) do
                local dx, dy = v.x - x, v.y - y
                dx, dy = dx * dx, dy * dy
                local dist = math.sqrt(dx + dy)
                if dist < closestval then
                  closestval = dist
                  closest = k
                end
              end
              
              if not closest then --[[print("Can't find nearby flightpath")]] return end
              assert(closest)
              table.insert(path, closest)
            end
            table.insert(path, self.dst)
            
            local tx = tostring(self.src)
            for _, v in ipairs(path) do
              tx = tx .. "@" .. tostring(v)
            end
            
            Output(faction .. "/" .. tx, nil, v / value[k .. "##count"])
          end
        end
      end,
      
      Receive = function(self, id, value)
        if id == faction then self.table = value end
      end,
    } end,
    nil, "flight_times"
  )
  
  local flight_master_assemble = ChainBlock_Create("flight_master_assemble", {flight_master_times},
    function (key) return {
      dat = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        table.insert(self.dat, value)
      end,
      
      Finish = function(self, Output, Broadcast)
        table.sort(self.dat)
        
        local chop = math.floor(#self.dat / 3)
        
        local acu = 0
        local ct = 0
        for i = 1 + chop, #self.dat - chop do
          acu = acu + self.dat[i]
          ct = ct + 1
        end
        
        acu = acu / ct
        
        if #self.dat > 10 then
          Output(key:match("([%d]+/[%d]+)@.+"), nil, {path = key, distance = acu})
        end
      end,
    } end
  )
  
  flight_data_output = ChainBlock_Create("flight_data_output", {flight_master_assemble},
    function (key) local faction, src = key:match("([%d]+)/([%d]+)") assert(faction and src) return {
      chunky = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        local f, s, m, e = value.path:match("([%d]+)/([%d]+)@(.+)@([%d]+)")
        if not f then f, s, e = value.path:match("([%d]+)/([%d]+)@([%d]+)") end
        assert(f and s and e)
        assert((f .. "/" .. s) == key)
        s = tonumber(s)
        e = tonumber(e)
        assert(s)
        assert(e)
        
        if not self.chunky[e] then
          self.chunky[e] = {}
        end
        
        local dex = {distance = value.distance, path = {}}
        if m then for x in m:gmatch("[%d]+") do
          assert(tonumber(x))
          table.insert(dex.path, tonumber(x))
        end end
        
        table.insert(self.chunky[e], dex)
      end,
      
      Finish = function(self, Output, Broadcast)
        for _, v in pairs(self.chunky) do
          table.sort(v, function(a, b) return a.distance < b.distance end)
        end
        
        Output(string.format("*/%s", faction), nil, {id = "flightpaths", key = tonumber(src), data = self.chunky}, "output_direct")
      end,
    } end
  )
  
  flight_master_name_output = ChainBlock_Create("flight_master_name_output", {flight_master_pack},
    function (key) return {
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
      end,
      
      Receive = function(self, id, value)
        if id == key then self.table = value end
      end,
      
      Finish = function(self, Output, Broadcast)
        print("finnish")
        for k, v in ipairs(self.table) do
          Output(string.format("*/%s", key), nil, {id = "flightmasters", key = k, data = {mid = v.mid}}, "output")
          for l, n in pairs(v.names) do
            Output(string.format("%s/%s", l, key), nil, {id = "flightmasters", key = k, data = {name = n}}, "output_direct")
          end
        end
      end,
    } end,
    nil, "name_output"
  )
end

--[[
*****************************************************************
Achievement collation
]]

local achievement_slurp

if do_compile and do_achievements then 
  achievement_slurp = ChainBlock_Create("achievement_slurp", {chainhead},
    function (key) return {
      accum = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        require "compile_achievement" -- whoa nelly
        if not achievements.achievements[tonumber(key)] then return end -- bzart
        
        for k, v in pairs(value) do
          if type(k) == "number" or k == "achieved" then
            if not self.accum[k] then self.accum[k] = {loc = {}} end
            
            if standard_pos_accum(self.accum[k], v, loc_version(subkey), value.locale, 0, value.wowv) then return end
          end
        end
      end,
      
      Finish = function(self, Output)
        if not achievements.achievements[tonumber(key)] then return end
        
        local oot = {}
        local gud = false
        
        local rettemp = {}
        if achievements.achievements[tonumber(key)].unify then
          rettemp.achieved = self.accum.achieved
        else
          for k, v in pairs(self.accum) do
            if type(k) == "number" then
              rettemp[k] = v
            end
          end
        end
        
        for k, v in pairs(rettemp) do
          if position_has(v.loc) then oot[k] = {loc = position_finalize(v.loc)} gud = true end
        end
        
        if gud then
          Output("*/*", nil, {id="achievement", key=tonumber(key), data=oot}, "output")
        end
      end
    } end,
    sortversion, "achievement"
  )
end

--[[
*****************************************************************
Final file generation
]]

local sources = {}
if quest_slurp then table.insert(sources, quest_slurp) end
if item_slurp then table.insert(sources, item_slurp) end
if item_parse then table.insert(sources, item_parse) end
if monster_slurp then table.insert(sources, monster_slurp) end
if object_slurp then table.insert(sources, object_slurp) end
if flight_data_output then table.insert(sources, flight_data_output) end
if flight_table_output then table.insert(sources, flight_table_output) end
if flight_master_name_output then table.insert(sources, flight_master_name_output) end
if achievement_slurp then table.insert(sources, achievement_slurp) end

local touched = {}

local function do_loc_choice(file, item, toplevel, solidity)
  if touched[item] then print("Recursed in file_cull somehow") return end
  
  touched[item] = true
  
  local has_linkloc = false
  local count = 0
  
  if not solidity then assert(toplevel)  solidity = {} end
  
  do
    local loc_obliterate = {}
    for k, v in ipairs(item) do
      local worked = false
      if file[v.sourcetype] and file[v.sourcetype][v.sourceid] and file[v.sourcetype][v.sourceid]["*/*"] then
        local valid, tcount = do_loc_choice(file, file[v.sourcetype][v.sourceid]["*/*"], false, solidity)
        if valid then
          has_linkloc = true
          worked = true
          count = count + tcount
        end
      end
      
      if not worked then
        table.insert(loc_obliterate, k)
      end
    end
    
    for i = #loc_obliterate, 1, -1 do
      table.remove(item, loc_obliterate[i])
    end
  end
  
  if dbg_data then
    item.full_objective_count = count
  end
  
  local reason = string.format("%s, %s, %s", tostring(has_linkloc), tostring(count), (item.loc and tostring(#item.loc) or "(no item.loc)"))
  
  if has_linkloc then
    assert(count > 0)
    if toplevel and count > 10 and item.loc then
      while #item.loc > 10 do
        table.remove(item.loc)
      end
      count = #item.loc
      --solidity = item.loc.solid   -- reset solidity to just the quest objectives
    elseif toplevel and count > 10 then
      item.loc = {} -- we're doing this just so we can say "hey, we don't want to use the original locations"
      count = 0 -- :(
    else
      if dbg_data then
        item.loc_unused = item.loc_unused or item.loc
      end
      
      item.loc = nil
    end
 else
    assert(count == 0)
    if item.loc then
      count = #item.loc
      solids_combine(solidity, item.loc.solid)
    end
    
    if dbg_data then
      if #item > 0 then
        item.link_unused = {}
        while #item > 0 do table.insert(item.link_unused, table.remove(item, 1)) end
      end
    else
      while #item > 0 do table.remove(item) end
    end
  end
  
  local valid = item.loc or #item > 0
  --[[if valid then -- technically not necessarily true
    assert(count > 0)
  else
    assert(count == 0)
  end]]
  
  touched[item] = nil
  return valid, count, reason, solidity
end

local function mark_chains(file, item)
  for k, v in ipairs(item) do
    if file[v.sourcetype] and file[v.sourcetype][v.sourceid] then
      file[v.sourcetype][v.sourceid].used = true
      if file[v.sourcetype][v.sourceid]["*/*"] then mark_chains(file, file[v.sourcetype][v.sourceid]["*/*"]) end
    end
  end
end

local file_collater = ChainBlock_Create("file_collater", sources,
  function (key) return {
    Data = function(self, key, subkey, value, Output)
      Output("", nil, {fragment = key, value = value})
    end
  } end,
  nil, "output"
)

local file_cull = ChainBlock_Create("file_cull", {file_collater},
  function (key) return {
    finalfile = {},
    
    Data = function(self, key, subkey, value, Output)
      assert(value.value.data)
      assert(value.value.id)
      assert(value.value.key)
      assert(value.fragment)
      
      if not self.finalfile[value.value.id] then self.finalfile[value.value.id] = {} end
      if not self.finalfile[value.value.id][value.value.key] then self.finalfile[value.value.id][value.value.key] = {} end
      assert(not self.finalfile[value.value.id][value.value.key][value.fragment])
      self.finalfile[value.value.id][value.value.key][value.fragment] = value.value.data
    end,
    
    Finish = function(self, Output)
      -- First we go through and check to see who's got actual locations, and cull either location or linkage. We also dispatch solidity requests as appropriate.
      local qct = {}
      
      if self.finalfile.quest then for k, v in pairs(self.finalfile.quest) do
        if v["*/*"] and v["*/*"].criteria then
          for cid, crit in pairs(v["*/*"].criteria) do
            local _, ct, reason, solids = do_loc_choice(self.finalfile, crit, true)
            Output(tostring(solids), nil, {data = solids, key = string.format("quest/%d", k), path = {"criteria", cid}}, "solidity")
            crit.solid = nil
            table.insert(qct, {ct = ct, id = string.format("%d/%d", k, cid), reason = reason})
          end
          
          if v["*/*"].finish and v["*/*"].finish.loc and v["*/*"].finish.loc.solid then
            Output(tostring(v["*/*"].finish.loc.solid), nil, {data = v["*/*"].finish.loc.solid, key = string.format("quest/%d", k), path = {"finish"}}, "solidity")
            v["*/*"].finish.loc.solid = nil
          end
          
          if v["*/*"].start and not v["*/*"].daily then
            while #v["*/*"].start.loc > 1 do
              table.remove(v["*/*"].start.loc)
            end
            assert(#v["*/*"].start.loc == 1)
            v["*/*"].start.loc.solid = nil
            
            local vf = v["*/*"].faction
            
            local tot = (vf[1] or 0) + (vf[2] or 0)
            assert(tot > 0)
            
            if (vf[1] or 0) > tot * 0.1 then
              Output(string.format("1/%d", v["*/*"].start.loc[1].p), nil, {q = k}, "quest_plane")
            end
            if (vf[2] or 0) > tot * 0.1 then
              Output(string.format("2/%d", v["*/*"].start.loc[1].p), nil, {q = k}, "quest_plane")
            end
          end
        end
        
        if v["*/*"] then
          v["*/*"].faction = nil
          v["*/*"].daily = nil
        end
      end end
      if self.finalfile.achievement then for k, v in pairs(self.finalfile.achievement) do
        assert(k ~= 713)
        if v["*/*"] then
          for cid, crit in pairs(v["*/*"]) do
            local _, ct, reason, solids = do_loc_choice(self.finalfile, crit, true)
            Output(tostring(solids), nil, {data = solids, key = string.format("achievement/%d", k), path = {cid}}, "solidity")
            crit.loc.solid = nil
          end
        end
      end end
      
      -- grab the monsters that are necessary for achievements
      require "compile_achievement" -- whoa nelly
      if self.finalfile.monster then for k, v in pairs(self.finalfile.monster) do
        if not achievements.monsters[k] then continue end
        
        print("achievement monsting", k)
        
        if v["*/*"] and v["*/*"].loc then
          Output(tostring(v["*/*"].loc.solid), nil, {data = v["*/*"].loc.solid, key = string.format("monster/%d", k), path = {}}, "solidity")
        end
        v.used = true
      end end
      
      table.sort(qct, function(a, b) return a.ct < b.ct end)
      for _, v in ipairs(qct) do
        --print("qct", v.ct, v.id, v.reason)
      end
      
      -- Then we mark used/unused items
      if self.finalfile.quest then for k, v in pairs(self.finalfile.quest) do
        if v["*/*"] and v["*/*"].criteria then
          for _, crit in pairs(v["*/*"].criteria) do
            mark_chains(self.finalfile, crit)
          end
        end
        v.used = true
      end end
      if self.finalfile.achievement then for k, v in pairs(self.finalfile.achievement) do
        if v["*/*"] then
          mark_chains(self.finalfile, v["*/*"])
        end
        v.used = true
      end end
      
      if self.finalfile.flightmasters then for k, v in pairs(self.finalfile.flightmasters) do
        for _, d in pairs(v) do
          if d.mid then
            mark_chains(self.finalfile, {{sourcetype = "monster", sourceid = d.mid}})
          end
        end
        v.used = true
      end end
      
      -- Go through and clear out remaining solidity
      if self.finalfile.quest then for k, v in pairs(self.finalfile.quest) do
        if v["*/*"] and v["*/*"].criteria then
          for cid, crit in pairs(v["*/*"].criteria) do
            if crit.loc then
              crit.loc.solid = nil
            end
          end
        end
      end end
      if self.finalfile.monster then for k, v in pairs(self.finalfile.monster) do
        if v["*/*"] and v["*/*"].loc then
          v["*/*"].loc.solid = nil
        end
      end end
      if self.finalfile.item then for k, v in pairs(self.finalfile.item) do
        if v["*/*"] and v["*/*"].loc then
          v["*/*"].loc.solid = nil
        end
      end end
      
      
      -- Then we optionally cull and unmark
      for t, d in pairs(self.finalfile) do
        local ultrafinal = {}
        
        for k, v in pairs(d) do
          if dbg_data then
            for plane, tv in pairs(v) do
              if type(tv) == "table" then tv.used = v.used or false end
            end
          end
          
          if not do_cull or v.used then
            ultrafinal[k] = v
          end
          
          v.used = nil
        end
        
        self.finalfile[t] = ultrafinal
      end
      
      for t, d in pairs(self.finalfile) do
        for k, v in pairs(d) do
          for plane, tv in pairs(v) do
            assert(tv)
            
            if plane == "*/*" and (t == "quest" or t == "achievement" or t == "monster") then
              Output(string.format("%s/%d", t, k), nil, {core = tv}, "solidity_recombine")
            else
              Output(plane, nil, {id = t, key = k, data = tv}, "output_direct")
            end
          end
        end
      end
      
      if do_find then
        for t, d in pairs(self.finalfile) do
          if t ~= "monster" then continue end -- stfu
          for k, d2 in pairs(d) do
            for s, d3 in pairs(d2) do
              if d3.name then
                local lang = s:match("(.*)/[12*]")
                assert(lang)
                Output(lang, nil, {cat = t, key = k, name = d3.name}, "find")
              end
            end
          end
        end
      end
    end
  } end
)


--[[
*****************************************************************
Create the agglomerated data for quest plane existence
]]


local quest_plane = ChainBlock_Create("quest_plane", {file_cull},
  function (key) return {
    acum = {},
    Data = function(self, key, subkey, value, Output)
      table.insert(self.acum, value.q)
    end,
    Finish = function(self, Output)
      table.sort(self.acum)
      
      local facet, plane = key:match("^(%d+)/(%d+)$")
      facet, plane = tonumber(facet), tonumber(plane)
      
      print(string.format("Outputting %s %d", facet, plane))
      Output(string.format("*/%d", facet), nil, {id = "questlist", key = plane, data = self.acum}, "output_direct")
    end
  } end,
  nil, "quest_plane"
)


--[[
*****************************************************************
Create the solid triangle meshes
]]

local gausswidth = 6
local gausscompact = 2
local gaussu = gausswidth / gausscompact
local gaussiate = {}
do
  for k = 0, gausswidth do
    gaussiate[k] = (1 / (math.sqrt(2 * 3.14159) * gaussu)) * math.pow(2.71828183, -(k * k) / (2 * math.pow(gaussu, 2)))
    --print(gaussiate[k])
  end
  
  for k = -#gaussiate, -1 do
    gaussiate[k] = gaussiate[math.abs(k)]
  end
  
  local gtot = 0
  for _, v in pairs(gaussiate) do
    gtot = gtot +v
  end
  for k, v in pairs(gaussiate) do
    gaussiate[k] = gaussiate[k] / gtot
  end
end -- normalized! :D (not that it really matters)

-- we blur and swap axes, then swap again on the next call. black magic, etc
local function doblur(chunk)
  local targ = {}
  for x, v in pairs(chunk) do
    for y, tv in pairs(v) do
      if not targ[y] then targ[y] = {} end
      for k = -#gaussiate, #gaussiate do
        targ[y][x + k] = (targ[y][x + k] or 0) + tv * gaussiate[k]
      end
    end
  end
  return targ
end
local function blur(chunk)
  return doblur(doblur(chunk))
end

local solidity = ChainBlock_Create("solidity", {file_cull},
  function (key) return {
    Data = function(self, key, subkey, value, Output)
      --local fileprefix = key:gsub("/", "_")
      local returno = {}
      local omx = {}
      omx.processed = true
      local tsize = 0
      
      for k, v in pairs(value.data) do
        omx[k] = blur(v)
        
        local mox = blur(v)
        local mnx = 1000000
        local mny = 1000000
        local mxx = -1000000
        local mxy = -1000000
        local emphatic = 0
        
        for tx, v in pairs(mox) do
          mnx = math.min(mnx, tx)
          mxx = math.max(mxx, tx)
          for ty, tv in pairs(v) do
            mny = math.min(mny, ty)
            mxy = math.max(mxy, ty)
            emphatic = math.max(emphatic, tv)
          end
        end
        
        local wid = mxx - mnx + 1
        local hei = mxy - mny + 1
        
        local mask = {}
        
        --local image = Image(wid, hei)
        for tx, v in pairs(mox) do
          for ty, tv in pairs(v) do
            local hard = math.floor((tv / emphatic) * 128 + 0.5)
            assert(hard >= 0 and hard <= 255)
            
            local color
            if hard > 10 then
              if not mask[tx] then mask[tx] = {} end
              mask[tx][ty] = true
              hard = hard + 127
            end
            
            color = 0x01010101 * hard
            
            --print(tx - mnx, ty - mny, wid, hei, color)
            --image:set(tx - mnx, ty - mny, color)
          end
        end
        
        --image:write(string.format("intermed/%s_%s.png", fileprefix, tostring(k)))
        --image = nil
        
        -- alright, we process the mask here
        local function process_item()
          local x = next(mask)
          if not x then return false end
          local y = next(mask[x])
          
          local mnx = 1000000
          local mny = 1000000
          local mxx = -1000000
          local mxy = -1000000
          
          local edges = {}
          
          local function recop(x, y)
            if not mask[x] or not mask[x][y] then
              if not edges[x] then edges[x] = {} end
              edges[x][y] = "early"
              mnx = math.min(mnx, x)
              mny = math.min(mny, y)
              mxx = math.max(mxx, x)
              mxy = math.max(mxy, y)
            else
              mask[x][y] = nil
              if not next(mask[x]) then mask[x] = nil end
              
              recop(x + 1, y)
              recop(x - 1, y)
              recop(x, y + 1)
              recop(x, y - 1)
            end
          end
          recop(x, y, edges)
          
          mnx = mnx - 1
          mny = mny - 1
          mxx = mxx + 1
          mxy = mxy + 1
          
          local stx
          local sty
          
          local function floody(x, y)
            if x < mnx or x > mxx then return end
            if y < mny or y > mxy then return end
            
            if not edges[x] then edges[x] = {} end
            
            if not edges[x][y] then
              edges[x][y] = "filled"
              floody(x + 1, y)
              floody(x - 1, y)
              floody(x, y + 1)
              floody(x, y - 1)
            elseif edges[x][y] == "early" then
              edges[x][y] = "important"
              stx, sty = x, y
            end
          end
          floody(mnx, mny)
          
          local path = {}
          
          local function mpathy(x, y, first)
            local adjct = 0
            assert(edges[x][y] == "important")
            edges[x][y] = "complete"
            local ax
            local ay
            local function ctadj(x, y)
              if edges[x] and edges[x][y] == "important" then
                adjct = adjct + 1
                ax = x
                ay = y
              end
            end
            
            ctadj(x + 1, y + 1)
            ctadj(x + 1, y - 1)
            ctadj(x - 1, y + 1)
            ctadj(x - 1, y - 1)
            ctadj(x + 1, y)
            ctadj(x - 1, y)
            ctadj(x, y + 1)
            ctadj(x, y - 1)
            
            if first then
              assert(adjct == 2)
              assert(ax)
              assert(ay)
            elseif adjct == 1 then
              assert(ax)
              assert(ay)
            elseif adjct == 0 then
              assert(not ax)
              assert(not ay)
            else
              print(adjct, first)
              assert()
            end
            
            table.insert(path, {x, y})
            
            if ax and ay then mpathy(ax, ay) end
          end
          mpathy(stx, sty, true)
          
          assert(math.abs(path[1][1] - path[#path][1]) <= 1 and math.abs(path[1][2] - path[#path][2]) <= 1)
          
          local st = #path
          --print("starting with", #path)
          
          -- FURTHER BLACK MAGIC
          local function line_len(a, b)
            local dx, dy = a[1] - b[1], a[2] - b[2]
            return math.sqrt(dx * dx + dy * dy)
          end
          local function triangle_area(a, b, c)
            local lenab, lenbc, lenca = line_len(a, b), line_len(b, c), line_len(c, a)
            local s = (lenab + lenbc + lenca) / 2
            if s * (s - lenab) * (s - lenbc) * (s - lenca) < 0 then return 0 end -- shouldn't happen, but, y'know, floating-point inaccuracy and all
            return math.sqrt(s * (s - lenab) * (s - lenbc) * (s - lenca)) -- heron's formula
          end
          local function spin(i)
            if i <= 0 then i = i + #path end
            if i > #path then i = i - #path end
            return i
          end
          local function evaluate_quality(i, spot)
            local A, alt, B = spin(i - 1), spin(i + 1), spin(i + 2)
            assert(path[A])
            assert(path[i])
            assert(path[alt])
            assert(path[B])
            assert(spot)
            -- given that we have the path A i alt B
            -- we will be combining this to A spot B
            -- the cost is the sum of the triangles "A i spot" and "spot alt B"
            return triangle_area(path[A], path[i], spot) + triangle_area(spot, path[alt], path[B])
          end
          local function get_best_spot(i)
            local alt = spin(i + 1)
            
            local ctx = {(path[i][1] + path[alt][1]) / 2, (path[i][2] + path[alt][2]) / 2}
            
            local iv, av, cv = evaluate_quality(i, path[i]), evaluate_quality(i, path[alt]), evaluate_quality(i, ctx)
            local mn = math.min(iv, av, cv)
            
            if mn == iv then return path[i] end
            if mn == av then return path[alt] end
            if mn == cv then return ctx end
            assert(false, iv, av, cv, mn)
          end
          local function evaluate_best(i)
            return evaluate_quality(i, get_best_spot(i))
          end
          
          -- first we add up the area, before we muck with it
          for i = 3, #path do
            tsize = tsize + triangle_area(path[1], path[i - 1], path[i])
          end
          
          local costs = {}
          local bcost = 1000000000
          local bspot = nil
          --print("orig")
          for i = 1, #path do
            --print("  ", path[i][1], path[i][2])
            local tcost = evaluate_best(i)
            if bcost > tcost then bcost = tcost bspot = i end
            table.insert(costs, tcost)
          end
          
          while bcost < 0.5 and #path > 3 do
            --print("obliterating")
            path[bspot] = get_best_spot(bspot)
            
            costs[bspot] = evaluate_best(bspot)
            if bspot == #path then
              table.remove(path, 1)
              table.remove(costs, 1)
            else
              table.remove(path, bspot + 1)
              table.remove(costs, bspot + 1)
            end
            
            if bspot == 1 then
              costs[#path] = evaluate_best(#path)
            else
              costs[bspot - 1] = evaluate_best(bspot - 1)
            end
            
            bcost = 1000000000
            bspot = nil
            
            for i = 1, #costs do
              if costs[i] < bcost then
                bcost = costs[i]
                bspot = i
              end
            end
          end
          
          --print("left with", #path, "from", st)
          
          local function doop(i)
            if type(i) ~= "table" then return i end
            
            local rv = {}
            for k, v in pairs(i) do
              rv[k] = v
            end
            return rv
          end
          
          local perimeter = {}
          for _, v in ipairs(path) do
            table.insert(perimeter, doop(v))
          end
          
          --[[print("Minima")
          for i = 1, #path do
            print("  ", path[i][1], path[i][2])
          end]]
          
          -- format:
          -- all values are relative to the first pair.
          -- "d" means there is a discontinuity - stop drawing triangles and store the next two coordinates as the first two for a new fan.
          -- "l" means each item after that is a line segment, with implicit connection between last and first
          -- as such, you will never see "de", since the previous and next coords are utterly unrelated anyway.
          -- {1000, 2000, 4, 6, 7, 5, 2, 3, "d", 2, 3, 6, 5, "l", 4, 6, 7, 5, 2, 3, 6, 5}
          
          -- process: start with vertex 1 and 2. see if we can grab 3 - if not, rotate the entire thing and try again. if so, dump vertex 2 and keep grabbing future polys in the same matter (todo: how do we detect missing edges?)
          
          
          local function line_intersect(a, b, c, d)
            local Ax, Ay = a[1], a[2]
            local Bx, By = b[1], b[2]
            local Cx, Cy = c[1], c[2]
            local Dx, Dy = d[1], d[2]
            
            local d = (Bx-Ax)*(Dy-Cy)-(By-Ay)*(Dx-Cx)
            
            if d == 0 then return false end
            
            local r = ((Ay-Cy)*(Dx-Cx)-(Ax-Cx)*(Dy-Cy)) / d
            local s = ((Ay-Cy)*(Bx-Ax)-(Ax-Cx)*(By-Ay)) / d
            
            if r < 0 or r > 1 then return false end
            if s < 0 or s > 1 then return false end
            return true
          end
          local function inside_path(ptx)
            local acu = 0
            for i = 1, #path do
              local alt = i + 1
              if alt > #path then alt = alt - #path end
              
              local a = math.atan2(path[i][1] - ptx[1], path[i][2] - ptx[2])
              local b = math.atan2(path[alt][1] - ptx[1], path[alt][2] - ptx[2])
              
              local df = a - b
              if df < -3.14159265 then
                df = df + 3.14159265 * 2
              end
              if df > 3.14159265 then
                df = df - 3.14159265 * 2
              end
              
              acu = acu + df
            end
            
            return math.abs(acu) > 1
          end
          local function clean()
            if not inside_path({(path[1][1] + path[2][1] + path[3][1]) / 3, (path[1][2] + path[2][2] + path[3][2]) / 3}) then return false end
            if #path > 3 and not inside_path({(path[1][1] + path[3][1]) / 2, (path[1][2] + path[3][2]) / 2}) then return false end
            
            for i = 4, #path - 1 do
              if line_intersect(path[i], path[i + 1], path[1], path[3]) then return false end
            end
            
            return true
          end
          
          local spinning = 0
          
          local output = {}
          while #path > 2 do
            if clean(path) then
              table.insert(output, path[1])
              table.insert(output, path[2])
              table.insert(output, path[3])
              --print("Clean triangle - ", path[1][1], path[1][2], path[2][1], path[2][2], path[3][1], path[3][2])
              table.remove(path, 2)
              
              --[[print("After triangle removal")
              for i = 1, #path do
                print("  ", path[i][1], path[i][2])
              end]]
              
              while #path > 2 do
                if clean(path) then
                  table.insert(output, path[3])
                  --print("Iterative triangle - ", path[1][1], path[1][2], path[2][1], path[2][2], path[3][1], path[3][2])
                  --print("Test", line_intersect(path[#path - 1], path[#path], path[1], path[3], true))
                  table.remove(path, 2)
                  
                  --[[
                  print("After triangle removal")
                  for i = 1, #path do
                    print("  ", path[i][1], path[i][2])
                  end]]
                  
                else
                  break
                end
              end
              
              if #path > 2 then
                table.insert(output, "d")
              end
              spinning = 0
            end
            
            spinning = spinning + 1
            table.insert(path, table.remove(path, 1))
            if spinning > #path then
              print("Can't seem to tesselate", spinning, #path)
              for i = 1, #path do
                print("  ", path[i][1], path[i][2])
              end
              
              -- reverse a little
              if type(output[#output]) == "string" then
                output[#output] = nil
              end
              
              break
            end
          end
          
          if #perimeter > 0 then
            table.insert(output, "l")
            for _, v in ipairs(perimeter) do
              table.insert(output, v)
            end
          end
          
          for k, v in ipairs(output) do
            output[k] = doop(v)
          end
          
          for _, v in ipairs(output) do
            if v == output[1] then continue end
            if type(v) ~= "table" then continue end
            v[1] = v[1] - output[1][1]
            v[2] = v[2] - output[1][2]
          end
          
          local doneoutput = {}
          for _, v in ipairs(output) do
            if type(v) == "table" then
              table.insert(doneoutput, v[1] * solid_grid)
              table.insert(doneoutput, v[2] * solid_grid)
            else
              table.insert(doneoutput, v)
            end
          end
          doneoutput[1] = doneoutput[1] + solid_grid / 2
          doneoutput[2] = doneoutput[2] + solid_grid / 2
          doneoutput.continent = k
          
          for k, v in ipairs(doneoutput) do
            if type(v) == "string" then
              assert(type(doneoutput[k + 1]) == "number")
              assert(type(doneoutput[k + 2]) == "number")
            end
          end
          
          table.insert(returno, doneoutput)
          
          return true
        end
        
        while process_item() do end
      end
      
      --print("size:", tsize)
      if tsize < 180 then returno = nil end
      
      Output(value.key, nil, {solid = returno, path = value.path}, "solidity_recombine")
    end,
  } end,
  nil, "solidity"
)

local solidity_recombine = ChainBlock_Create("solidity_recombine", {file_cull, solidity},
  function (key) return {
    solid = {},
    Data = function(self, key, subkey, value, Output)
      if value.core then
        assert(not self.core)
        self.core = value.core
      end
      if value.solid then
        table.insert(self.solid, value)
      end
    end,
    Finish = function(self, Output)
      if not self.core then print("Missing core:", key) end
      assert(self.core)
      
      for _, v in ipairs(self.solid) do
        local nod = self.core
        for _, link in ipairs(v.path) do
          if not nod[link] then nod[link] = {} end
          assert(type(nod[link] == "table"))
          nod = nod[link]
        end
        assert(nod and type(nod) == "table")
        nod.solid = v.solid
      end
      
      local typ, ki = key:match("(.+)/(.+)")
        
      Output("*/*", nil, {id = typ, key = tonumber(ki) or ki, data = self.core}, "output_direct")
    end,
  } end,
  nil, "solidity_recombine"
)

--[[
*****************************************************************
"/qh find" db
]]

local find
if do_find then
  local shardlen = 2
  
  find = ChainBlock_Create("find", {file_cull},
    function (key) return {
      db = {},
      Data = function(self, key, subkey, value, Output)
        for i = 1, #value.name - shardlen + 1 do
          local subs = value.name:sub(i, i + shardlen - 1):lower()
          if #subs ~= 2 then
            print(i, #value.name, shardlen, i, i + shardlen - 1)
            assert(#subs == 2)
          end
          if subs:find(" ") then continue end
          if not self.db[subs] then self.db[subs] = {} end
          self.db[subs][value.key] = true
        end
      end,
      Finish = function(self, Output)
        for k, v in pairs(self.db) do
          local out = {}
          for id in pairs(v) do
            table.insert(out, id)
          end
          
          table.sort(out)
          
          local outcondense = {}
          local cd = 0
          for _, d in ipairs(out) do
            table.insert(outcondense, d - cd)
            cd = d
          end
          
          Output(key .. "/*", nil, {id = "find", key = (k:byte(1) * 256 + k:byte(2)), data = outcondense}, "output_direct")
        end
      end,
    } end,
    nil, "find"
  )
end

--[[
*****************************************************************
Compress and output all the data
]]

local output_sources = {}
for _, v in ipairs(sources) do
  table.insert(output_sources, v)
end
table.insert(output_sources, file_cull)
table.insert(output_sources, solidity_recombine)
table.insert(output_sources, find)
table.insert(output_sources, quest_plane)

local function LZW_precompute_table(inputs, tokens)
  -- shared init code
  local d = {}
  local i
  for i = 1, #tokens do
    d[tokens:sub(i, i)] = 0
  end
  
  for _, input in ipairs(inputs) do
    local w = ""
    for ci = 1, #input do
      local c = input:sub(ci, ci)
      local wcp = w .. c
      if d[wcp] then
        w = wcp
        d[wcp] = d[wcp] + 1
      else
        d[wcp] = 1
        w = c
      end
    end
  end
  
  local freq = {}
  for k, v in pairs(d) do
    if #k > 1 then
      table.insert(freq, {v, k})
    end
  end
  table.sort(freq, function(a, b) return a[1] < b[1] end)
  
  return freq
end

local function pdump(v)
  assert(type(v) == "table")
  local writo = {write = function (self, data) Merger.Add(self, data) end}
  persistence.store(writo, v)
  if not loadstring("return " .. Merger.Finish(writo)) then print(Merger.Finish(writo)) assert(false) end
  assert(loadstring("return " .. Merger.Finish(writo)))
  local dense = Diet(Merger.Finish(writo))
  if not dense then print("Couldn't condense") print(Merger.Finish(writo)) return end  -- wellp
  local dist = dense:match("{(.*)}")
  assert(dist)
  return dist
end


local compress_split = ChainBlock_Create("compress_split", output_sources,
  function (key) return {
    Data = function(self, key, subkey, value, Output)
      Output(key .. "/" .. value.id, subkey, value)
    end,
  } end, nil, "output_direct")
  
local compress = ChainBlock_Create("compress", {compress_split},
  function (key) return {
    finalfile = {},
    
    Data = function(self, key, subkey, value, Output)
      assert(value.data, string.format("%s, %s", tostring(value.id), tostring(value.key)))
      assert(value.id)
      assert(value.key)
      
      assert(not self.finalfile[value.key])
      self.finalfile[value.key] = value.data
    end,
    
    Finish = function(self, Output)
      
      local fname = "static"
      
      local locale, faction, segment = key:match("(.*)/(.*)/(.*)")
      local orig_locale, orig_faction, orig_segment = locale, faction, segment
      assert(locale and faction)
      if locale == "*" then locale = nil end
      if faction == "*" then faction = nil end      
      
      if locale then
        fname = fname .. "_" .. locale
      end
      if faction then
        fname = fname .. "_" .. faction
      end
      
      -- First, compression.
      if do_compress then
        local d = self.finalfile
        local k = segment
        
        -- First we dump all our tables to strings
        for sk, v in pairs(d) do
          assert(type(sk) ~= "string" or not sk:match("__.*"))
          assert(type(v) == "table")
          
          dist = pdump(v)
          if not dist then continue end
          
          self.finalfile[sk] = dist
        end
        
        -- Strip out prefix/suffix
        prefix = d[next(d)]
        suffix = d[next(d)]
        local minlen = #d
        
        --if #prefix > 0 then self.finalfile.__prefix_init = d[next(d)] end
        
        for sk, v in pairs(d) do
          if type(v) ~= "string" or (type(sk) == "string" and sk:match("__.*")) then continue end
          
          if #v < #prefix then prefix = prefix:sub(1, #v) end
          if #v < #suffix then suffix = suffix:sub(#suffix - #v, #suffix) end
          
          while v:sub(1, #prefix) ~= prefix do prefix = prefix:sub(1, #prefix - 1) end
          while v:sub(#v - (#suffix - 1), #suffix) ~= suffix do suffix = suffix:sub(2, #suffix) end
          
          minlen = math.min(minlen, #v)
        end
        
        if minlen < #prefix then
          if #prefix > 0 then self.finalfile.__prefix = prefix end
          if #suffix > 0 then self.finalfile.__suffix = suffix end
          
          for sk, v in pairs(d) do
            if type(v) ~= "string" or (type(sk) == "string" and sk:match("__.*")) then continue end
            assert(v:sub(1, #prefix) == prefix)
            assert(v:sub(#v - (#suffix - 1), #v) == suffix)
            d[sk] = d[sk]:sub(#prefix + 1, #v)
            d[sk] = d[sk]:sub(1, #v - #suffix)
            assert(prefix .. d[sk] .. suffix == v)
          end
        end
        
        -- Get working dictionary of items
        local dict = {}
        for sk, v in pairs(d) do
          if type(v) ~= "string" or (type(sk) == "string" and sk:match("__.*")) then continue end
          
          for i = 1, #v do
            dict[v:byte(i)] = true
          end
        end
        
        local dicto = {}
        for k, v in pairs(dict) do
          table.insert(dicto, k)
        end
        
        table.sort(dicto)
        
        local dictix = string.char(unpack(dicto))
        assert(dictix)
        d.__dictionary = dictix
        
        -- Now we build the precomputed LZW table
        do
          -- hackery steakery
          if true then
            local inps = {}
            for sk, v in pairs(d) do
              if type(v) ~= "string" or (type(sk) == "string" and sk:match("__.*")) then continue end
              
              table.insert(inps, v)
            end
            local preco = LZW_precompute_table(inps, dictix)
            
            local total = 0
            for _, v in ipairs(preco) do
              total = total + v[1] / #v[2]
            end
            
            for _, v in ipairs(preco) do
              if v[1] > total / 100 then
                --print(locale, faction, v[1], v[2])
              end
            end
            
            --local ofile = ("final/%s_%s.stats"):format(fname, k)
            --fil = io.open(ofile, "w")
            
            --for i = 1, 51, 10 do
              --local thresh = total / 100 / i
              local thresh = total / 100 / 40 -- this seems about the right threshold
              
              local tix = {}
              for _, v in ipairs(preco) do
                if v[1] > thresh then
                  table.insert(tix, v[2])
                end
              end
              table.sort(tix, function(a, b) return #a > #b end)
              
              local fundatoks = {}
              local usedtoks = {}
              for _, v in ipairs(tix) do
                if usedtoks[v] then continue end
                
                for i = 1, #v do
                  local sub = v:sub(1, i)
                  usedtoks[sub] = true
                end
                table.insert(fundatoks, v)
              end
              
              if segment ~= "flightmasters" or true then  -- the new decompression is quite a bit slower, and flightmasters are decompressed in large bulk on logon
                local redictix = dictix
                if not redictix:find("\"") then redictix = redictix .. "\"" end
                if not redictix:find(",") then redictix = redictix .. "," end
                if not redictix:find("\\") then redictix = redictix .. "\\" end
                local ftd = pdump(fundatoks)
                self.finalfile.__tokens = LZW.Compress_Dicts(ftd, redictix)
                if LZW.Decompress_Dicts(self.finalfile.__tokens, redictix) ~= ftd then
                  print(ftd)
                  print(LZW.Decompress_Dicts(self.finalfile.__tokens, redictix))
                  print(dictix)
                  print(redictix)
                end
                assert(LZW.Decompress_Dicts(self.finalfile.__tokens, redictix) == ftd)
                
                local prep_id, prep_id_size, prep_is = LZW.Prepare(dictix, fundatoks)
                
                --local dictsize = #self.finalfile.__tokens
                --local datsize = 0
                
                for sk, v in pairs(d) do
                  if (type(sk) ~= "string" or not sk:match("__.*")) and type(v) == "string" then
                    assert(type(v) == "string")
                    local compy = LZW.Compress_Dicts_Prepared(v, prep_id, prep_id_size, nil, prep_is)
                    --assert(LZW.Decompress_Dicts(compy, dictix, nil, fundatoks) == v)
                    --datsize = datsize + #compy
                    
                    self.finalfile[sk] = compy
                    assert(LZW.Decompress_Dicts_Prepared(self.finalfile[sk], dictix, nil, prep_is) == v)
                  end
                end
              else
                for sk, v in pairs(d) do
                  if (type(sk) ~= "string" or not sk:match("__.*")) and type(v) == "string" then
                    assert(type(v) == "string")
                    self.finalfile[sk] = LZW.Compress_Dicts(v, dictix)
                    assert(LZW.Decompress_Dicts(self.finalfile[sk], dictix) == v)
                  end
                end
              end
              
              --fil:write(string.format("%d\t%d\t%d\t%d\n", i, dictsize + datsize, dictsize, datsize))
              
              --print(locale, faction, k, i, #fundatoks, dictsize, datsize, dictsize + datsize)
            --end
            
            --fil:close()
            
            
            --[=[fil = io.open(ofile .. ".gnuplot", "w")
            fil:write("set term png\n")
            fil:write(string.format("set output \"%s.png\"\n", ofile))
            fil:write(string.format([[
                plot \
                  "%s" using 1:2 with lines title 'Total', \
                  "%s" using 1:3 with lines title 'Dict', \
                  "%s" using 1:4 with lines title 'Dat']], ofile, ofile, ofile))
            fil:write("\n")
            fil:close()
            
            os.execute(string.format("gnuplot %s.gnuplot", ofile))]=]
          end
        end
        
        --[[for sk, v in pairs(d) do
          if (type(sk) ~= "string" or not sk:match("__.*")) and type(v) == "string" then
            assert(type(v) == "string")
            self.finalfile[sk] = LZW.Compress_Dicts(v, dictix)
            assert(LZW.Decompress_Dicts(self.finalfile[sk], dictix) == v)
          end
        end]]
      end
      
      if do_compress and do_serialize and segment ~= "flightmasters" then
        --[[Header format:

          Itemid (0 for endnode)
          Offset
          Length
          Rightlink]]

        assert(not self.finalfile.__serialize_index)
        assert(not self.finalfile.__serialize_data)
        
        local ntx = {}
        local intdat = {}
        for k, v in pairs(self.finalfile) do
          if type(k) == "number" then
            if k <= 0 then
              print("Out of bounds:", orig_locale, orig_faction, orig_segment, k)
              ntx[k] = v
            elseif type(v) ~= "string" then
              print("Not a string:", orig_locale, orig_faction, orig_segment, k)
              ntx[k] = v
            else
              assert(#v >= 1)
              table.insert(intdat, {key = k, value = v})
            end
          else
            ntx[k] = v
          end
        end
        
        local data = {}
        local dat_len = 1
        
        table.sort(intdat, function(a, b) return a.key < b.key end)
        
        local function write_adaptint(dest, val)
          assert(type(val) == "number")
          assert(val == math.floor(val))
          
          repeat
            dest:append(math.mod(val, 128), 7)
            dest:append((val >= 128) and 1 or 0, 1)
            val = math.floor(val / 128)
          until val == 0
        end
        
        local function streamout(st, nd)
          local ttx = Bitstream.Output(8)
          if st > nd then
            write_adaptint(ttx, 0)
            return ttx:finish()
          else
            local tindex = math.floor((st + nd) / 2)
            write_adaptint(ttx, intdat[tindex].key)
            write_adaptint(ttx, dat_len)
            write_adaptint(ttx, #intdat[tindex].value - 1)
            Merger.Add(data, intdat[tindex].value)
            dat_len = dat_len + #intdat[tindex].value
            local lhs = streamout(st, tindex - 1)
            local rhs = streamout(tindex + 1, nd)
            write_adaptint(ttx, #lhs)
            return ttx:finish() .. lhs .. rhs
          end
        end
        
        ntx.__serialize_index = streamout(1, #intdat)
        ntx.__serialize_data = Merger.Finish(data)
        
        print("Index is", #ntx.__serialize_index, "data is", #ntx.__serialize_data)
        
        self.finalfile = ntx
      end
      
      Output(string.format("%s/%s", orig_locale, orig_faction), nil, {id = orig_segment, data = self.finalfile})
    end,
  } end)

local fileout = ChainBlock_Create("fileout", {compress},
  function (key) return {
    finalfile = {},
    
    Data = function(self, key, subkey, value, Output)
      assert(value.data, string.format("%s, %s", tostring(value.id), tostring(value.key)))
      assert(value.id)
      
      assert(not self.finalfile[value.id])
      self.finalfile[value.id] = value.data
    end,
    
    Finish = function(self, Output)
      
      local fname = "static"
      
      local locale, faction = key:match("(.*)/(.*)")
      assert(locale and faction)
      if locale == "*" then locale = nil end
      if faction == "*" then faction = nil end      
      
      if locale then
        fname = fname .. "_" .. locale
      end
      if faction then
        fname = fname .. "_" .. faction
      end
      
      fil = io.open(("final/%s.lua"):format(fname), "w")
      fil:write(([=[QuestHelper_File["%s.lua"] = "Development Version"
QuestHelper_Loadtime["%s.lua"] = GetTime()

]=]):format(fname, fname))

      if not locale and not faction then
        fil:write("QHDB = {}", "\n")
      end
      if locale then
        fil:write(([[if GetLocale() ~= "%s" then return end]]):format(locale), "\n")
      end
      if faction then
        fil:write(([[if (UnitFactionGroup("player") == "Alliance" and 1 or 2) ~= %s then return end]]):format(faction), "\n")
      end
      fil:write("\n")
      
      --fil:write("loadstring([[table.insert(QHDB, ")
      fil:write("table.insert(QHDB, ")
      persistence.store(fil, self.finalfile)
      fil:write(")")
      --fil:write(")]])()")
      
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

local function readdir()
  local pip = io.popen(("find data/08 -type f | head -n %s | tail -n +%s"):format(e or 1000000000, s or 0))
  local flist = pip:read("*a")
  pip:close()
  local filz = {}
  for f in string.gmatch(flist, "[^\n]+") do
    table.insert(filz, {fname = f, id = count})
    count = count + 1
  end
  return filz
end

print("Reading files")
local filout = readdir("data/08")

for k, v in pairs(filout) do
  --print(string.format("%d/%d: %s", k, #filout, v.fname))
  chainhead:Insert(v.fname, nil, {fileid = v.id})
end

print("Finishing with " .. tostring(count - 1) .. " files")
chainhead:Finish()

check_semiass_failure()
