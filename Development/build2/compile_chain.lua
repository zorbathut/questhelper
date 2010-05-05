
--[[

Okay let's think about this.

It takes the form of a series of chain blocks. Each chain block is a "manager" in some sort, in that it just represents the shape of the whole shebang. The actual implementation underlaying it doesn't really matter as much, so let's just build the framework first.

Parameters to a block consist only of the construction function for the type it's meant to generate, and the blocks it's meant to pass things to.

No need for inheritance, honestly.
]]

--[[

LET'S THINK ABOUT MULTIPROCESSING

First off, sharding. Shard by key, hashing. We know how many destination systems we have, so we'll just shard according to that.

Okay here's the trivial version.

blockname_dstkey_srckey

Each block writes all the output that its block will have to the necessary output blocks. Once it's sure it's done, it . . . does what?

argh this is hurting my brain



OKAY

each block takes as input a series of keys, (k, sk, v)

as output, it dumps a set of keys, (k, sk, v, id)

these are filtered based on id to each block. a key may end up in zero, one, or many output blocks

those are split up by k

before processing, they are sorted by sk


SO

Output files are:

(block)/(shard)/(key)_(writer_id)

We can just synchronize it from the controller - one block at a time. The blocks are DAGs, we can plug a Lua serialization library in and just append as we go (with some gzip? benchmark this)

Each step just drops into the directories for its block/kshard, then processes files in series - grab all the files for one k, process, continue.

I'm pretty sure this works, but I'm running out of hard drive space.
]]

require("luarocks.require")
require("md5")
require("pluto")
require("gzio")
require("bit")
zlib = require("zlib") -- lol what

--local intermediate_start_at = "solidity"

--local compress = zlib.compress
--local decompress = zlib.decompress

local compress = lzo_compress
local decompress = lzo_decompress

if false then
  print("comp loaded")
  
  print(compress("hello hello hello"))
  print(decompress(compress("hello hello hello")))
  assert(false)
end

local function safety(func, ...)
  local dt = {...}
  local it = select('#', ...)
  
  local rv, err = xpcall(function () return func(unpack(dt, 1, it)) end, function (ter) return ter .. "\n\n" .. debug.traceback() end)
  if err then
    print("safetyout")
    print("RV, ERR", rv, err)
    assert(false)
  else
    return rv
  end
end

if not push_file_id then push_file_id = function () end end
if not pop_file_id then pop_file_id = function () end end

local nextProgressTime = 0

local function Progressable()
  return os.time() > nextProgressTime
end
local function ProgressMessage(msg)
  if os.time() > nextProgressTime then
    nextProgressTime = os.time() + 1
    print(msg)
  end
end



function filecontents(filename)
  local fil = io.open(filename, "rb")
  if not fil then print("Failed to open filename", filename) end
  assert(fil)
  
  local fcerror = {}
  
  local dofunc = function ()
    local red = fil:read(4)
    if not red then return fcerror end
    assert(#red == 4)
    local a, b, c, d = red:byte(1, 4)
    local len = a + b * 256 + c * 65536 + d * 16777216
    if len == math.pow(2, 32) - 1 then
      return nil
    end
    local junk = fil:read(len)
    assert(#junk == len)
    return junk
  end
  
  local first = dofunc()
  if first == fcerror then
    fil:close()
    print("everything is broken", filename)
    sleep(1)
    return filecontents(filename)
  end
    
  return function ()
    if first then
      local f = first
      first = nil
      return f
    end
    local rv = dofunc()
    if rv == fcerror then
      print("everything is error", filename)
      assert(rv ~= fcerror)
    end
    return rv
  end
end
local function multifile(...)
  local files = {...}
  local curf
  local curfname
  return function ()
    if curf then
      local dat = curf()
      if dat then return dat end
      curf = nil
    end
    
    if not curf then
      local nfil = table.remove(files)
      if not nfil then return nil end
      curfname = nfil
      curf = filecontents(nfil)
    end
    
    local dat, err = curf()
    if not dat then print(err, curfname) end
    assert(dat)
    return dat
  end
end

local function cheap_left(x) return (2*x) end
local function cheap_right(x) return (2*x + 1) end
local function cheap_sane(heap)
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
    assert(not heap[cheap_left(i)] or heap[i].c <= heap[cheap_left(i)].c)
    assert(not heap[cheap_right(i)] or heap[i].c <= heap[cheap_right(i)].c)
  end
end
local function cheap_insert(heap, item, pred)
  assert(item)
  table.insert(heap, item)
  local pt = #heap
  while pt > 1 do
    local ptd2 = math.floor(pt / 2)
    if not pred(heap[pt], heap[ptd2]) then
      break
    end
    local tmp = heap[pt]
    heap[pt] = heap[ptd2]
    heap[ptd2] = tmp
    pt = ptd2
  end
  --cheap_sane(heap)
end
local function cheap_extract(heap, pred)
  local rv = heap[1]
  if #heap == 1 then table.remove(heap) return rv end
  heap[1] = table.remove(heap)
  local idx = 1
  while idx < #heap do
    local minix = idx
    if heap[cheap_left(idx)] and pred(heap[cheap_left(idx)], heap[minix]) then minix = cheap_left(idx) end
    if heap[cheap_right(idx)] and pred(heap[cheap_right(idx)], heap[minix]) then minix = cheap_right(idx) end
    if minix ~= idx then
      local tx = heap[minix]
      heap[minix] = heap[idx]
      heap[idx] = tx
      idx = minix
    else
      break
    end
  end
  --cheap_sane(heap)
  return rv
end

local function multifilesort(pred, ...)
  local filenames = {...}
  
  local lpred = function (a, b)
    return pred(a.nxt, b.nxt)
  end
  
  local heep = {}
  
  for i = 1, #filenames do
    local fil = filecontents(filenames[i])
    local dt = fil()
    if dt then
      cheap_insert(heep, {fil = fil, nxt = pluto.unpersist({}, decompress(dt))}, lpred)
    end
  end
  
  return function ()
    if #heep == 0 then return nil end
    
    local dt = cheap_extract(heep, lpred)

    local nxt = dt.nxt
    
    dt.nxt = dt.fil()
    if dt.nxt then
      dt.nxt = pluto.unpersist({}, decompress(dt.nxt))
      cheap_insert(heep, dt, lpred)
    end
    
    return nxt
  end
end

local function filewriter(filename)
  local fil = io.open(filename, "wb")
  if not fil then
    assert(os.execute("mkdir -p " .. string.match(filename, "(.*)/.-")) == 0)
    fil = io.open(filename, "wb")
  end
  assert(fil)
  
  local wroteshit = false
  
  return {
    close = function ()
      fil:write(string.char(0xff, 0xff, 0xff, 0xff))
      fil:close()
    end,
    write = function (_, dat)
      wroteshit = true
      fil:write(string.char(bit.band(#dat, 0xff), bit.band(#dat, 0xff00) / 256, bit.band(#dat, 0xff0000) / 65536, bit.band(#dat, 0xff000000) / 16777216))
      fil:write(dat)
    end
  }
end

local file_cache = {}

local function get_file(fname)
  if file_cache[fname] then return file_cache[fname] end
  file_cache[fname] = filewriter(fname)
  return file_cache[fname]
end
local function flush_cache()
  for k, v in pairs(file_cache) do
    v:close()
  end
  file_cache = {}
end



local MODE_MASTER = 1
local MODE_SLAVE = 2

local mode

local slaveblock

local shard
local shard_count
local internal_split = 16

local shard_ips = {}

local block_lookup = {}

local fname
local path

function ChainBlock_Init(path_f, fname_f, init_f)
  if arg[1] == "master" then
    mode = MODE_MASTER
    path = path_f
    fname = fname_f
    init_f()
    
    if not intermediate_start_at then
      print("Removing ancient data . . .")
      os.execute("rm -rf temp_removing")
      print("Shifting old data . . .")
      os.execute("mv temp temp_removing")
      io.popen("rm -rf temp_removing", "w")
      print("Beginning . . .")
    end
    
    shard = 0
    
    for k = 3, #arg do
      local ip, ct = arg[k]:match("(.+)x([0-9]+)")
      assert(ip)
      assert(ct)
      for v = 1, ct do
        table.insert(shard_ips, ip)
      end
    end
    
    shard_count = tonumber(arg[2])
    
    local print_bk = print
    print = function(...) print_bk("Master", ...) end
    
  elseif arg[1] == "slave" then
    mode = MODE_SLAVE
    slaveblock = arg[2]
    shard = tonumber(arg[3])
    shard_count = tonumber(arg[4])
    assert(slaveblock)
    assert(shard)
    assert(shard_count)
    
    local print_bk = print
    local shardid = string.format("Shard %2d/%2d %s", shard, shard_count, slaveblock)
    print = function(...) print_bk(shardid, ...) io.stdout:flush() end
    
    ProgressMessage("Starting")
  elseif arg[1] then
    assert(false)
  end
end

function ChainBlock_Work()
  if mode == MODE_SLAVE then
    local prefix = string.format("temp/%s/%d", slaveblock, shard)
    local hnd = io.popen(string.format("ls %s 2> /dev/null", prefix))
    
    local tblock = block_lookup[slaveblock]
    assert(tblock)
    local ckey = nil
    
    local lines = {}
    for line in hnd:lines() do
      table.insert(lines, line)
    end
    hnd:close()
    
    local srcfiles = {}
    for pos, line in ipairs(lines) do
      if line:match("data_.*") then
        table.insert(srcfiles, prefix .. "/" .. line)
      end
    end
    
    local function megasortpred(a, b)
      if a.key ~= b.key then return a.key < b.key end
      return tblock.sortpred and tblock.sortpred(a.subkey, b.subkey)
    end
    
    -- sort step
    local intermediaries = {}
    
    local sortct = 0
    
    local datix = {}
    local ct = 0
    local function finish_datix()
      if #datix == 0 then return end  -- bzzzzt
      
      local intermedfname = string.format("%s/intermed_%d", prefix, #intermediaries + 1)
      table.insert(intermediaries, intermedfname)
      
      table.sort(datix, function(a, b)
        return megasortpred(a.deco, b.deco)
      end)
      
      local out = filewriter(intermedfname)
      if not out then print(intermedfname) end
      assert(out, intermedfname)
      for _, v in ipairs(datix) do
        out:write(v.raw)
      end
      out:close()
      
      datix = {}
      
      collectgarbage("collect")
    end
    local gogo = 0
    for data in multifile(unpack(srcfiles)) do
      if false then
        if math.mod(gogo, 100000) == 50 then
          for i = 1, 5 do
            local t = os.time()
            local ct = 0
            while os.time() == t do
              ct = ct + 1
              decompress(data)
            end
            print("benchmarking", ct)
          end
        end
        gogo = gogo + 1
      end
      local daca = decompress(data)
      local chunk = pluto.unpersist({}, daca)
      table.insert(datix, {raw = data, deco = chunk})
      ct = ct + 1
      sortct = sortct + 1
      if ct == 1000 then
        local garbaj = collectgarbage("count")
        ct = 0
        if garbaj > 250000 then
          ProgressMessage(string.format("Dumping intermediate file %d containing %d", #intermediaries + 1, #datix))
          finish_datix()
        end
      end
    end
    finish_datix()
    
    local bctcount = 0
    local broadcasts = {}
    for pos, line in ipairs(lines) do
      if line:match("broadcast_.*") then
        for k in filecontents(prefix .. "/" .. line) do
          local tab = pluto.unpersist({}, decompress(k))
          tblock:Broadcast(tab.id, tab.value)
          bctcount = bctcount + 1
        end
      end
    end
    
    print(string.format("Processing %d broadcasts, %d data, %d mem", bctcount, sortct, collectgarbage("count")))
    
    -- merge
    local curkey = nil
    local curct = 0
    for tab in multifilesort(megasortpred, unpack(intermediaries)) do
      if Progressable() then
        ProgressMessage(string.format("Processing %d/%d, %d mem", curct, sortct, collectgarbage("count")))
      end
      curct = curct + 1
      if tab.key ~= curkey then
        --print("finishing")
        tblock:Finish()
        curkey = tab.key
      end
      
      --print("tbi")
      tblock:Insert(tab.key, tab.subkey, tab.value, tblock.filter)
    end
    
    tblock:Finish()
    
    flush_cache()
    return true
  end
end


local function md5_value(dat)
  if tonumber(dat) then return dat end
  
  local binny = md5.sum(dat)
  local v = 0
  for k = 1, 4 do
    v = v * 256
    v = v + string.byte(binny, k)
  end
  return v
end
--[[
local function md5_clean(dat)
  local binny = md5.sum(dat)
  local rv = ""
  for k = 1, #binny do
    rv = rv .. string.format("%02x", string.byte(binny, k))
  end
  return rv
end

local function shardy(dat, shards)
  if tonumber(dat) then return math.mod(tonumber(dat), shards) + 1 end
  
  local binny = md5.sum(dat)
  assert(shards)
  local v = 0
  for k = 1, 4 do
    v = v * 256
    v = v + string.byte(binny, k)
  end
  return math.mod(v, shards) + 1
end]]


local ChainBlock = {}
local ChainBlock_mt = { __index = ChainBlock }

function ChainBlock_Create(id, linkfrom, factory, sortpred, filter)
  local ninst = {}
  setmetatable(ninst, ChainBlock_mt)
  ninst.id = id
  ninst.factory = factory
  ninst.sortpred = sortpred
  ninst.filter = filter
  ninst.items = {}
  ninst.data = {}
  ninst.linkto = {}
  ninst.broadcasted = {}
  ninst.unfinished = 0
  ninst.process = function (key, subkey, value, identifier)
    if not (key and value and type(key) == "string") then
      print("Something's wrong with key and value!")
      print("Key: ", type(key), key)
      print("Value: ", type(value), value)
      assert(key and value and type(key) == "string")
    end
      
    local touched = false
    for _, v in pairs(ninst.linkto) do
      touched = v:Insert(key, subkey, value, identifier) or touched
    end
    
    if not touched then
      print("Identifier", identifier, "from block", id, "didn't connect to anything!")
      assert(touched, identifier)
    end
  end
  ninst.broadcast = function (id, value) for _, v in pairs(ninst.linkto) do v:Broadcast(id, value) end end
  if linkfrom then
    for k, v in pairs(linkfrom) do
      v:AddLinkTo(ninst)
      ninst.unfinished = ninst.unfinished + 1
    end
  end
  
  assert(not block_lookup[id])
  block_lookup[id] = ninst
  
  return ninst
end


function ChainBlock:Insert(key, subkey, value, identifier)
  assert(key)
  assert(type(key) == "string")
  if self.filter and self.filter ~= identifier then return end
  
  if slaveblock ~= self.id then -- we write
    local ki = md5_value(key)
    local shard_dest_1 = math.mod(ki, shard_count) + 1
      
    local f = get_file(string.format("temp/%s/%d/data_%s_%s", self.id, shard_dest_1, (mode == MODE_MASTER and "master" or slaveblock), shard))
    f:write(compress(pluto.persist({}, {key = key, subkey = subkey, value = value})))
  else  -- we put to the system
    if type(value) == "table" and value.fileid then push_file_id(value.fileid) else push_file_id(-1) end
    safety(self:GetItem(key).Data, self:GetItem(key), key, subkey, value, self.process)
    pop_file_id()
  end
  
  return true
end


function ChainBlock:Broadcast(id, value)
  if slaveblock ~= self.id then -- we write
    for k = 1, shard_count do
      local f = get_file(string.format("temp/%s/%d/broadcast_%s_%s", self.id, k, (mode == MODE_MASTER and "master" or slaveblock), shard))
      f:write(compress(pluto.persist({}, {id = id, value = value})))
    end
  else  -- we put to the system
    table.insert(self.broadcasted, {id = id, value = value})
  end
end


local finish_root_node = true

local timing = {}

function ChainBlock:Finish()
  if mode == MODE_MASTER then
    local frn = finish_root_node
    finish_root_node = false
  
    flush_cache()
    
    self.unfinished = self.unfinished - 1
    if self.unfinished > 0 then return end -- NOT . . . FINISHED . . . YET
    
    sync()
    
    local start = os.time()
    
    if not intermediate_start_at or self.id == intermediate_start_at then
      intermediate_start_at = nil
      multirun_clear()
      for k = 1, shard_count do
        multirun_add(string.format("ssh %s \"cd %s && nice luajit -O2 %s slave %s %d %d\"", shard_ips[1], path, fname, self.id, k, shard_count))  -- so, right now this works because we only have one computer, but if we ever have more than one IP we'll have to put part of this into multirun_complete
      end
      multirun_complete(self.id, #shard_ips)
    end
    
    table.insert(timing, {id = self.id, dur = os.time() - start})
    
    for _, v in pairs(self.linkto) do
      v:Finish()
    end
    
    if frn then
      for k, v in ipairs(timing) do
        print(string.format("%20s %4d", v.id, v.dur))
      end
    end
    
  elseif mode == MODE_SLAVE and slaveblock ~= self.id then
    return
  elseif mode == MODE_SLAVE and slaveblock == self.id then
    for k, v in pairs(self.items) do
      if v.Finish then safety(v.Finish, v, self.process, self.broadcast) end
      self.items[k] = 0
    end
    self.items = {}
  end
end

function ChainBlock:AddLinkTo(item)
  table.insert(self.linkto, item)
end

function ChainBlock:GetItem(key)
  if not self.items[key] then
    self.items[key] = self.factory(key)
    
    for _, v in ipairs(self.broadcasted) do
      safety(self.items[key].Receive, self.items[key], v.id, v.value)
    end
  end
  return self.items[key]
end

function ChainBlock:GetData(key)
  self:GetItem(key) -- just to ensure
  if not self.data[key] then self.data[key] = {} end
  return self.data[key]
end
