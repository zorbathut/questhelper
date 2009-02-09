
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
require("persistence")

local nextProgressTime = 0

local function ProgressMessage(msg)
  if os.time() > nextProgressTime then
    nextProgressTime = os.time() + 1
    print(msg)
  end
end



local file_cache = {}
local function flush_cache()
  print("Flushing cache")
  if file_cache then
    for k, v in pairs(file_cache) do
      v:close()
    end
    file_cache = {}
  end
end

local function get_file(fname)
  if file_cache[fname] then return file_cache[fname] end
  local f, reason = io.open(fname, "ab")
  if not f and string.find(reason, "No such file or directory") then
    os.execute("mkdir -p " .. string.match(fname, "(.*)/.-"))
    f, reason = io.open(fname, "ab")
  end
  if not f and string.find(reason, "Too many open files") then
    flush_cache()
    f, reason = io.open(fname, "ab")
  end
  assert(f, reason)
  file_cache[fname] = f
  return f
end




local MODE_SOLO = 0
local MODE_MASTER = 1
local MODE_SLAVE = 2

local mode

local slaveblock

local shard
local shard_count

local block_lookup = {}

function ChainBlock_Init(init_f, ...)
  dbgout(arg)
  if arg[1] == "master" then
    mode = MODE_MASTER
    init_f()
    os.execute("rm -rf temp")
    shard = 0
    shard_count = 4
  elseif arg[1] == "slave" then
    mode = MODE_SLAVE
    slaveblock = arg[2]
    shard = tonumber(arg[3])
    shard_count = tonumber(arg[4])
    assert(slaveblock)
    assert(shard)
    assert(shard_count)
  elseif arg[1] then
    assert(false)
  else
    mode = MODE_SOLO
    init_f()
  end
  
  print(mode)
end

function ChainBlock_Work()
  if mode == MODE_SLAVE then
    print("slavemode")
    local prefix = string.format("temp/%s/%d", slaveblock, shard)
    local hnd = io.popen(string.format("ls %s", prefix))
    for line in hnd:lines() do
      print("reading " .. line)
      jamtable = {}
      loadfile(prefix .. "/" .. line)()
      
      local tblock = block_lookup[slaveblock]
      for _, v in ipairs(jamtable) do
        tblock:Insert(v.key, v.subkey, v.value)
      end
      tblock:Finish()
    end
    hnd:close()
    flush_cache()
    return true
  end
end


local function md5_clean(dat)
  local binny = md5.sum(dat)
  local rv = ""
  for k = 1, #binny do
    rv = rv .. string.format("%02x", string.byte(binny, k))
  end
  return rv
end

local function shardy(dat, shards)
  local binny = md5.sum(dat)
  local v = 0
  for k = 1, 4 do
    v = v * 256
    v = v + string.byte(binny, k)
  end
  return math.mod(v, shards) + 1
end


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
  ninst.broadcasted_keyed = {}
  ninst.unfinished = 0
  ninst.process = function (key, subkey, value, identifier) for _, v in pairs(ninst.linkto) do v:Insert(key, subkey, value, identifier) end end
  ninst.broadcast = function (subkey, value, identifier) for _, v in pairs(ninst.linkto) do v:Broadcast(subkey, value, identifier) end end
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
  if self.filter and self.filter ~= identifier then return end
  
  if mode ~= MODE_SOLO and slaveblock ~= self.id then
    local f = get_file(string.format("temp/%s/%d/%s_%s", self.id, shardy(key, shard_count), md5_clean(key):sub(1,2), shard))
    f:write("table.insert(jamtable, ")
    persistence.store(f, {key = key, subkey = subkey, value = value})
    f:write(")\n")
  else
    if not subkey then
      if value.fileid then push_file_id(value.fileid) else push_file_id(-1) end
      self:GetItem(key):Data(key, subkey, value, self.process)
      pop_file_id()
    else
      table.insert(self:GetData(key), {subkey = subkey, value = value})
    end
  end
end

--[[
function ChainBlock:Broadcast(subkey, value, identifier)
  if self.filter and identifier and self.filter ~= identifier then return end

  if subkey then
    table.insert(self.broadcasted_keyed, {subkey = subkey, value = value})
  else
    table.insert(self.broadcasted, value)
  end
end
]]

function ChainBlock:Finish()
  if mode == MODE_MASTER then
  
    flush_cache()
    
    self.unfinished = self.unfinished - 1
    if self.unfinished > 0 then return end -- NOT . . . FINISHED . . . YET
    for k = 1, shard_count do
      assert(os.execute(string.format("luajit -O2 compile.lua slave %s %d %d", self.id, k, shard_count)) == 0)
    end
    for _, v in pairs(self.linkto) do
      v:Finish()
    end
    
  elseif mode == MODE_SLAVE and slaveblock ~= self.id then
    return
  elseif mode == MODE_SOLO or (mode == MODE_SLAVE and slaveblock == self.id)then
    self.unfinished = self.unfinished - 1
    if self.unfinished > 0 and mode == MODE_SOLO then return end -- NOT . . . FINISHED . . . YET
    
    print("Sorting " .. self.id)
    
    local sdc = 0
    for k, v in pairs(self.data) do sdc = sdc + 1 end
    local sdcc = 0
    
    if #self.broadcasted > 0 then
      for k, v in pairs(self.items) do
        for _, d in pairs(self.broadcasted) do
          v:Data(k, nil, v, self.process, self.broadcast)
        end
      end
    end
    self.broadcasted = {}
    
    for k, v in pairs(self.data) do
      ProgressMessage(string.format("Sorting %s, %d/%d", self.id, sdcc, sdc))
      sdcc = sdcc + 1
      
      for _, bv in ipairs(self.broadcasted_keyed) do
        table.insert(v, bv)
      end
      
      if self.sortpred then
        table.sort(v, function (a, b) return self.sortpred(a.subkey, b.subkey) end)
      else
        table.sort(v, function (a, b) return a.subkey < b.subkey end)
      end
      local item = self:GetItem(k)
      
      local ict = 0
      for _, d in pairs(v) do
        ProgressMessage(string.format("Sorting %s, %d/%d + %d/%d", self.id, sdcc, sdc, ict, #v))
        ict = ict + 1
        if d.value.fileid then push_file_id(d.value.fileid) else push_file_id(-1) end
        item:Data(k, d.subkey, d.value, self.process, self.broadcast)
        pop_file_id()
      end
      
      self.data[k] = 0 -- This is kind of like setting it to nil, but instead of not working, it does work.
    end
    self.broadcasted_keyed = nil
    
    print("Finishing " .. self.id)
    
    self.data = {}
    for k, v in pairs(self.items) do
      if v.Finish then v:Finish(self.process, self.broadcast) end
      self.items[k] = 0
    end
    self.items = {}
    
    print("Chaining " .. self.id)
    
    for _, v in pairs(self.linkto) do
      v:Finish()
    end
    
    print("Done " .. self.id)
  end
end

function ChainBlock:AddLinkTo(item)
  table.insert(self.linkto, item)
end

function ChainBlock:GetItem(key)
  if not self.items[key] then
    self.items[key] = self.factory(key)
  end
  return self.items[key]
end

function ChainBlock:GetData(key)
  if not self.data[key] then self.data[key] = {} end
  return self.data[key]
end
