
--[[

Okay let's think about this.

It takes the form of a series of chain blocks. Each chain block is a "manager" in some sort, in that it just represents the shape of the whole shebang. The actual implementation underlaying it doesn't really matter as much, so let's just build the framework first.

Parameters to a block consist only of the construction function for the type it's meant to generate, and the blocks it's meant to pass things to.

No need for inheritance, honestly.
]]

local nextProgressTime = 0

function ProgressMessage(msg)
  if os.time() > nextProgressTime then
    nextProgressTime = os.time() + 1
    print(msg)
  end
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
  ninst.broadcast = function (subkey, value, identifier) for _, v in pairs(ninst.linkdo) do v:Broadcast(subkey, value, identifier) end end
  if linkfrom then
    for k, v in pairs(linkfrom) do
      v:AddLinkTo(ninst)
      ninst.unfinished = ninst.unfinished + 1
    end
  end
  return ninst
end

function ChainBlock:Insert(key, subkey, value, identifier)
  if self.filter and self.filter ~= identifier then return end
  
  if not subkey then
    if value.fileid then push_file_id(value.fileid) else push_file_id(-1) end
    self:GetItem(key):Data(key, subkey, value, self.process)
    pop_file_id()
  else
    table.insert(self:GetData(key), {subkey = subkey, value = value})
  end
end

function ChainBlock:Broadcast(subkey, value, identifier)
  if self.filter and self.filter ~= identifier then return end

  if subkey then
    table.insert(self.broadcasted_keyed, {subkey = subkey, value = value})
  else
    table.insert(self.broadcasted, value)
  end
end

function ChainBlock:Finish()
  self.unfinished = self.unfinished - 1
  if self.unfinished > 0 then return end -- NOT . . . FINISHED . . . YET
  
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
  self.broadcasted = nil
  
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
  
  self.data = nil
  for k, v in pairs(self.items) do
    if v.Finish then v:Finish(self.process, self.broadcast) end
    self.items[k] = 0
  end
  self.items = nil
  
  print("Chaining " .. self.id)
  
  for _, v in pairs(self.linkto) do
    v:Finish()
  end
  
  print("Done " .. self.id)
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
