
--[[

Okay let's think about this.

It takes the form of a series of chain blocks. Each chain block is a "manager" in some sort, in that it just represents the shape of the whole shebang. The actual implementation underlaying it doesn't really matter as much, so let's just build the framework first.

Parameters to a block consist only of the construction function for the type it's meant to generate, and the blocks it's meant to pass things to.

No need for inheritance, honestly.
]]

local ChainBlock = {}
local ChainBlock_mt = { __index = ChainBlock }

function ChainBlock_Create(linkfrom, factory, sortpred, filter)
  local ninst = {}
  setmetatable(ninst, ChainBlock_mt)
  ninst.factory = factory
  ninst.sortpred = sortpred
  ninst.items = {}
  ninst.data = {}
  ninst.linkto = {}
  ninst.process = function (key, subkey, value) for _, v in pairs(ninst.linkto) do v:Insert(key, subkey, value) end end
  if linkfrom then linkfrom:AddLinkTo(ninst) end
  return ninst
end

function ChainBlock:Insert(key, subkey, value)
  if not subkey then
    self:GetItem(key):Data(key, subkey, value, self.process)
  else
    table.insert(self:GetData(key), {subkey = subkey, value = value})
  end
end

function ChainBlock:Finish()
  for k, v in pairs(self.data) do
    table.sort(v, function (a, b) return self.sortpred(a.subkey, b.subkey) end)
    local item = self:GetItem(k)
    for _, d in pairs(v) do
      item:Data(k, d.subkey, d.value, self.process)
    end
  end
  self.data = nil
  for _, v in pairs(self.items) do
    if v.Finish then v:Finish(self.process) end
  end
  self.items = nil
  for _, v in pairs(self.linkto) do
    v:Finish()
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
