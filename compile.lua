#!/usr/bin/lua

-- I don't know why print is giving me so much trouble, but it is, sooooo
print = function (...)
  local pad = ""
  for _, v in ipairs({...}) do
    io.stdout:write(pad)
    local tst = tostring(v)
    pad = (" "):rep(#tst - math.floor(#tst / 6) * 6 + 4)
    io.stdout:write(tst)
  end
  io.stdout:write("\n")
end

local do_zone_map = false
local do_errors = false
local do_questtables = false
local do_compile = true

local dbg_data = true

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

local function version_parse(x)
  if not x then return end
  
  local rv = {}
  for t in x:gmatch("[%d]+") do
    table.insert(rv, t)
  end
  return rv
end

local function sortversion(a, b)
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

local function weighted_concept_finalize(data, fraction, minimum, total_needed)
  if #data == 0 then return end

  fraction = fraction or 0.9
  minimum = minimum or 1
  
  table.sort(data, function (a, b) return a.w > b.w end)

  local tw = total_needed
  if not tw then
    tw = 0
    for _, v in pairs(data) do
      tw = tw + v.w
    end
  end
  
  local ept
  local wacu = 0
  for k, v in pairs(data) do
    wacu = wacu + v.w
    v.w = nil
    if wacu >= tw * fraction or (data[k + 1] and data[k + 1].w < minimum) or not data[k + 1] then
      ept = k
      break
    end
  end
  
  if not ept then
    print(total_needed)
    for k, v in pairs(data) do
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

local function list_most_common(tbl, mv)
  local mcv = nil
  local mcvw = mv
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

local function loot_accumulate(source, sourcetok, Output)
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

local function standard_pos_accum(accum, value, fluff)
  if not fluff then fluff = 0 end
  for _, v in ipairs(value) do
    if math.mod(#v, 11 + fluff) ~= 0 then
      return true
    end
  end
  
  for _, v in ipairs(value) do
    for off = 1, #v, 11 + fluff do
      local tite = slice_loc(v:sub(off, off + 10))
      if tite then position_accumulate(accum.loc, tite) end
    end
  end
end

local function standard_name_accum(accum, value)
  for k, v in pairs(value) do
    if type(k) == "string" then
      local q = string.match(k, "name_(.*)")
      if q then name_accumulate(accum.name, q, value.locale) end
    end
  end
end

--[[
*****************************************************************
Chain head
]]

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
      
      if do_errors and dat.errors then
        for k, v in pairs(dat.errors) do
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
      local v = dat.data
      if qhv and wowv and locale and faction
        --and not sortversion("0.80", qhv) -- hacky hacky
      then
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
        
        -- quests!
        if do_compile and do_questtables and v.quest then for qid, qdat in pairs(v.quest) do
          qdat.fileid = value.fileid
          qdat.locale = locale
          Output(string.format("%d", qid), qhv, qdat, "quest")
        end end
        
        -- items!
        if do_compile and do_questtables and v.item then for iid, idat in pairs(v.item) do
          idat.fileid = value.fileid
          idat.locale = locale
          Output(tostring(iid), qhv, idat, "item")
        end end
        
        -- monsters!
        if do_compile and do_questtables and v.monster then for mid, mdat in pairs(v.monster) do
          mdat.fileid = value.fileid
          mdat.locale = locale
          Output(tostring(mid), qhv, mdat, "monster")
        end end
        
        -- objects!
        if do_compile and do_questtables and v.object then for oid, odat in pairs(v.object) do
          odat.fileid = value.fileid
          Output(string.format("%s@@%s", oid, locale), qhv, odat, "object")
        end end
        
        -- flight masters!
        if do_compile and v.flight_master then for fmname, fmdat in pairs(v.flight_master) do
          if type(fmdat.master) == "string" then continue end  -- I don't even know how this is possible
          Output(string.format("%s@@%s@@%s", faction, fmname, locale), qhv, {dat = fmdat, wowv = wowv}, "flight_master")
        end end
        
        -- flight times!
        if do_compile and v.flight_times then for ftname, ftdat in pairs(v.flight_times) do
          Output(string.format("%s@@%s@@%s", ftname, faction, locale), qhv, ftdat, "flight_times")
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

if false and do_compile then 
  local object_locate = ChainBlock_Create("object_locate", {chainhead},
    function (key) return {
      accum = {name = {}, loc = {}},
      
      fids = {},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        local name, locale = key:match("(.*)@@(.*)")
        
        if standard_pos_accum(self.accum, value) then return end
        
        while #value > 0 do table.remove(value) end
        
        table.insert(self.accum, value)
        self.fids[value.fileid] = true
      end,
      
      Finish = function(self, Output, Broadcast)
        local fidc = 0
        for k, v in pairs(self.fids) do
          fidc = fidc + 1
        end
        
        if fidc < 3 then return end -- bzzzzzt
        
        local name, locale = key:match("(.*)@@(.*)")
        
        local qout = {}
        
        if position_has(self.accum.loc) then
          qout.loc = position_finalize(self.accum.loc)
        else
          return  -- BZZZZZT
        end
        
        if locale == "enUS" then
          Broadcast("object", {name = name, loc = qout.loc})
          Output("", nil, {type = "data", name = key, data = self.accum}, "reparse")
        else
          Output(key, nil, qout.loc, "link")
          Output("", nil, {type = "data", name = key, data = self.accum}, "reparse")
        end
      end,
    } end,
    sortversion, "object"
  )
  
  local function find_closest(loc, locblock)
    local closest = 5000000000  -- yeah, that's five billion. five fuckin' billion.
    --print(#locblock)
    for _, ite in ipairs(locblock) do
      if loc.c == ite.c then
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
  
  local object_combine = ChainBlock_Create("object_combine", {object_link},
    function (key) return {
    
      source = {enUS = {}},
      heap = {},
    
      Data = function(self, key, subkey, value, Output)
        local name, locale = value.key:match("(.*)@@(.*)")  -- boobies regexp
        -- insert shit into a heap
        if not self.source[locale] then self.source[locale] = {} end
        self.source[locale][name] = {}
        for k, v in pairs(value.data) do
          self.source.enUS[k] = {linkedto = {}}
          heap_insert(self.heap, {c = v, dst_locale = locale, dst = name, src = k})
        end
      end,
      
      Receive = function() end,
      
      Finish = function(self, Output, Broadcast)
        print("heap is", #self.heap)
        
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
        -- pull shit out of the heap, link things up
        
        -- determine unique IDs for everything we have left
        
        -- output stuff for actual parsing and processing of any remaining data
        -- also, output a chart of what we linked
        -- remember to output that chart in order-of-linkage
      end,
    } end,
    nil, "combine"
  )
  
  
  -- then, now that we finally have IDs, we do our standard mambo of stuff
  
  
  --[[object_slurp = ChainBlock_Create("object_slurp", {chainhead},
    function (key) return {
      accum = {name = {}, loc = {}},
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        if standard_pos_accum(self.accum, value) then return end
        name_accumulate(self.accum.name, key, value.locale)
        
        while #value > 0 do table.remove(value) end
        value.locale = nil
        
        table.insert(accum, value)
      end,
      
      Finish = function(self, Output)
        self.accum.name = name_resolve(self.accum.name)
        
        local qout = {}
        
        if dbg_data then qout.name = self.accum.name end
        if position_has(self.accum.loc) then qout.loc = position_finalize(self.accum.loc) end
        
        local has_stuff = false
        for k, v in pairs(qout) do
          has_stuff = true
          break
        end
        if has_stuff then
          Output("", nil, {id="object", key=key, data=qout}, "output")
        end
      end,
    } end,
    sortversion, "object"
  )]]
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
      
      -- Here's our actual data
      Data = function(self, key, subkey, value, Output)
        if standard_pos_accum(self.accum, value, 2) then return end
        if standard_name_accum(self.accum, value) then return end
        
        loot_accumulate(value, {type = "monster", id = tonumber(key)}, Output)
      end,
      
      Finish = function(self, Output)
        self.accum.name = name_resolve(self.accum.name)
        
        local qout = {}
        
        -- we don't actually care about the level, so we don't bother to store it. Really, we only care about the name for debug purposes also, so we should probably get rid of it before release.
        if dbg_data then qout.name = self.accum.name end
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

local item_name_package
local item_slurp

if do_compile and do_questtables then
  local item_slurp_first = ChainBlock_Create("item_parse", {chainhead},
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
        if dbg_data then qout.name = self.accum.name end
        
        Output("", nil, {key = key, name = qout.name}, "name")
        
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
  )
  
  -- Input to this module is kind of byzantine, so I'm documenting it here.
  -- {Key, Subkey, Value}
  
  -- {999, nil, {source = {type = "monster", id = 12345}, count = 104, type = "skin"}}
  -- Means: "We've seen 104 skinnings of item #999 from monster #12345"
  local lootables = {}
  if monster_slurp then table.insert(lootables, monster_slurp) end
  if item_slurp_first then table.insert(lootables, item_slurp_first) end
  
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
  
  item_slurp = ChainBlock_Create("item_slurp", {item_slurp_first, loot_merge},
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

  quest_slurp = ChainBlock_Create("quest_slurp", {chainhead, item_name_package},
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
      
      Receive = function(self, id, data)
        self.namedb = data
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
        
        -- we don't actually care about the level, so we don't bother to store it. Really, we only care about the name for debug purposes also, so we should probably get rid of it before release.
        if dbg_data then qout.name = self.accum.name end
        
        local has_stuff = false
        for k, v in pairs(qout) do
          has_stuff = true
          break
        end
        if has_stuff then
          assert(tonumber(key))
          --print("Quest output " .. tostring(key))
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

local flight_output

if do_compile then
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
          print(key, value.locale, self.names[value.locale], value.name)
          
          print(self.names[value.locale].version, value.version, sortversion(self.names[value.locale].version, value.version), self.names[value.locale].name, value.name)
          assert(self.names[value.locale].version ~= value.version)
          print(self.names[value.locale].version, value.version, sortversion(self.names[value.locale].version, value.version))
          
          if not sortversion(self.names[value.locale].version, value.version) then
            self.names[value.locale] = nil  -- we just blow it away and rebuild it later
          else
            return
          end
        end
        assert(not self.names[value.locale])
        assert(not self.mid or not value.mid or self.mid == value.mid, key)
        
        self.names[value.locale] = {name = value.name, version = value.version}
        self.mid = value.mid
      end,
      
      Finish = function(self, Output)
        local x, y, faction = key:match("(.*)@@(.*)@@(.*)")
        local namepack = {}
        for k, v in pairs(self.names) do
          namepack[k] = v.name
        end
        
        Output(tostring(faction), nil, {x = x, y = y, faction = faction, mid = self.mid, names = namepack})
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
    
      accumu = {},
      
      Data = function(self, key, subkey, value, Output)
        if self.fail then return end
        
        if not self.table then print(key, "failure") end
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
              assert(closest)
              table.insert(path, closest)
            end
            
            local mtch
            
            for k, v in pairs(self.accumu) do
              if #k ~= #path then continue end
              local match = true
              for i = 1, #k do
                if k[i] ~= path[i] then match = false break end
              end
              
              if not match then continue end
              
              mtch = v
              break
            end
            
            if not mtch then
              mtch = {}
              self.accumu[path] = mtch
            end
            
            table.insert(mtch, v / value[k .. "##count"])
          end
        end
      end,
      
      Receive = function(self, id, value)
        if id == faction then self.table = value end
      end,
      
      Finish = function(self, Output, Broadcast)
        if self.fail then return end
        
        local dumpy = {}
        for k, v in pairs(self.accumu) do
          if #v == 0 then continue end
          
          table.sort(v)
          
          local chop = math.floor(#v / 5)
          
          local acu = 0
          local ct = 0
          for i = 1 + chop, #v - chop do
            acu = acu + v[i]
            ct = ct + 1
          end
          
          acu = acu / ct
          
          print(#v, src, dst, faction, acu)
          if #v > 10 then
            print(src, dst, faction, acu)
            dumpy[k] = acu
          end
        end
        
        Output("", nil, {src = self.src, dst = self.dst, faction = self.faction, links = dumpy})
      end,
    } end,
    nil, "flight_times"
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
if object_slurp then table.insert(sources, object_slurp) end

local function do_loc_choice(file, item)
  local has_linkloc = false
  for k, v in ipairs(item) do
    if file[v.sourcetype][v.sourceid] then
      if do_loc_choice(file, file[v.sourcetype][v.sourceid]) then
        has_linkloc = true
      end
    end
  end
  
  if has_linkloc then
    if dbg_data then
      item.loc_unused = item.loc_unused or item.loc
    end
    
    item.loc = nil
  else
    if dbg_data then
      if #item > 0 then
        item.link_unused = {}
        while #item > 0 do table.insert(item.link_unused, table.remove(item, 1)) end
      end
    else
      while #item > 0 do table.remove(item) end
    end
  end
  
  return item.loc or #item > 0
end

local function mark_chains(file, item)
  for k, v in ipairs(item) do
    print("link", v.sourcetype, v.sourceid)
    if file[v.sourcetype][v.sourceid] then
      file[v.sourcetype][v.sourceid].used = true
      mark_chains(file, file[v.sourcetype][v.sourceid])
    end
  end
end

local fileout = ChainBlock_Create("fileout", sources,
  function (key) return {
    finalfile = {},
    
    Data = function(self, key, subkey, value, Output)
      assert(key == "")
      
      assert(value.data)
      assert(value.id)
      assert(value.key)
      if value.data.name then value.data.name = value.data.name.enUS end -- needs improvement
      
      if not self.finalfile[value.id] then self.finalfile[value.id] = {} end
      assert(not self.finalfile[value.id][value.key])
      self.finalfile[value.id][value.key] = value.data
    end,
    
    Finish = function(self, Output)
      -- First we go through and check to see who's got actual locations, and cull either location or linkage
      if self.finalfile.quest then for k, v in pairs(self.finalfile.quest) do
        if v.criteria then
          for _, crit in pairs(v.criteria) do
            do_loc_choice(self.finalfile, crit)
          end
        end
      end end
      
      -- Then we mark used/unused items
      if self.finalfile.quest then for k, v in pairs(self.finalfile.quest) do
        v.used = true
        if v.criteria then
          for _, crit in pairs(v.criteria) do
            mark_chains(self.finalfile, crit)
          end
        end
      end end
      
      -- Then we optionally cull and unmark
      for t, d in pairs(self.finalfile) do
        local repl = {}
        for k, v in pairs(d) do
          if v.used then
            repl[k] = v
          else
            v.used = false
          end
        end
        
        if not dbg_data then
          self.finalfile[t] = d
        end
      end
      
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
local e = 100

flist = io.popen("ls data/08"):read("*a")
local filz = {}
for f in string.gmatch(flist, "[^\n]+") do
  if not s or count >= s then table.insert(filz, {fname = f, id = count}) end
  count = count + 1
  
  if e and count > e then break end
end

for k, v in pairs(filz) do
  --print(string.format("%d/%d: %s", k, #filz, v.fname))
  chainhead:Insert("data/08/" .. v.fname, nil, {fileid = v.id})
end

print("Finishing with " .. tostring(count - 1) .. " files")
chainhead:Finish()

check_semiass_failure()
