QuestHelper_File["collect_lzw.lua"] = "Development Version"

function QH_LZW_Bitstreamer_Output(outbits)
  return {
    r = QuestHelper:MakeMerger(),
    cbits = 0,
    cval = 0,
    
    append = function (self, value, bits)
      self.cbits = self.cbits + bits
      self.cval = bit.lshift(self.cval, bits)
      self.cval = self.cval + value
      while self.cbits >= outbits do
        self.r:Add(strchar(bit.rshift(self.cval, self.cbits - outbits)))
        self.cbits = self.cbits - outbits;
        self.cval = bit.band(self.cval, bit.lshift(1, self.cbits) - 1)
      end
    end,
    finish = function (self)
      if self.cbits > 0 then self:append(0, outbits - self.cbits) end
      return self.r:Finish()
    end
  }
end

function QH_LZW_Bitstreamer_Input(indata, outbits)
  return {
    cbits = 0,
    cval = 0,
    coffset = 1,
    
    depend = function (self, bits)
      while self.cbits < bits do
        self.cbits = self.cbits + outbits
        self.cval = bit.lshift(self.cval, outbits) + strbyte(indata, self.coffset)
        self.coffset = self.coffset + 1
      end
      local rv = bit.rshift(self.cval, self.cbits - bits)
      self.cbits = self.cbits - bits;
      self.cval = bit.band(self.cval, bit.lshift(1, self.cbits) - 1)
      return rv
    end,
  }
end

function QH_LZW_Compress(input, tokens, outbits)
  -- shared init code
  local d = {}  
  local i
  for i = 0, tokens-1 do
    d[string.char(i)] = i
  end
  
  local dsize = tokens + 1  -- we use the "tokens" value as an EOF marker
  
  local bits = 1
  local nextbits = 2
  
  while nextbits < dsize do bits = bits + 1; nextbits = nextbits * 2 end
  
  local r = QH_LZW_Bitstreamer_Output(outbits)
  
  local idlect = 0
  
  local w = ""
  for ci = 1, #input do
    if idlect == 100 then
      QH_Timeslice_Yield()
      idlect = 0
    else
      idlect = idlect + 1
    end
    
    local c = input:sub(ci, ci)
    local wcp = w .. c
    if d[wcp] then
      w = wcp
    else
      r:append(d[w], bits)
      d[wcp] = dsize
      dsize = dsize + 1
      if dsize > nextbits then
        bits = bits + 1
        nextbits = nextbits * 2
      end
      w = c
    end
  end
  if w ~= "" then r:append(d[w], bits) end
  
  dsize = dsize + 1   -- Our decompressor doesn't realize we're ending here, so it will have added a table entry for that last token. Sigh.
  if dsize > nextbits then
    bits = bits + 1
    nextbits = nextbits * 2
  end
  r:append(tokens, bits)
  
  local rst = r:finish()
  QuestHelper: Assert(QH_LZW_Decompress(rst, tokens, outbits) == input) -- yay
  
  return rst
end

function QH_LZW_Decompress(input, tokens, outbits)
  local d = {}
  local i
  for i = 0, tokens-1 do
    d[i] = string.char(i)
  end
  
  local dsize = tokens + 1  -- we use the "tokens" value as an EOF marker
  
  local bits = 1
  local nextbits = 2
  
  while nextbits < dsize do bits = bits + 1; nextbits = nextbits * 2 end
  
  local i = QH_LZW_Bitstreamer_Input(input, outbits)
  local rv = QuestHelper:MakeMerger()
  
  local idlect = 0
  
  local tok = i:depend(bits)
  if tok == tokens then return "" end -- Okay. There's nothing. We get it.
  
  rv:Add(d[tok])
  local w = d[tok]
  while true do
    if idlect == 100 then
      QH_Timeslice_Yield()
      idlect = 0
    else
      idlect = idlect + 1
    end
    
    dsize = dsize + 1 -- We haven't actually added the next element yet. However, we could in theory include it in the stream, so we need to adjust the number of bits properly.
    if dsize > nextbits then
      bits = bits + 1
      nextbits = nextbits * 2
    end
    
    tok = i:depend(bits)
    if tok == tokens then break end -- we're done!
    
    local entry
    if d[tok] then
      entry = d[tok]
    elseif tok == dsize - 1 then
      entry = w .. w:sub(1, 1)
    else
      QuestHelper: Assert(false, "faaaail")
    end
    rv:Add(entry)
    
    d[dsize - 1] = w .. entry:sub(1, 1) -- Naturally, we're writing to one *less* than dsize, since we already incremented.
    
    w = entry
  end
  
  return rv:Finish()
end

function QH_LZW_Compress_Dicts(input, inputdict, outputdict)
  local inproc = input
  if inputdict then
    local idc = {}
    for i = 1, #inputdict do idc[inputdict:sub(i, i)] = strchar(i - 1) end
    local im = QuestHelper:MakeMerger()
    for i = 1, #input do im:Add(idc[input:sub(i, i)]) end
    inproc = im:Finish()
  end
  
  local bits, dsize = 1, 2
  if not outputdict then bits = 8 else while dsize < #outputdict do bits = bits + 1 ; dsize = dsize * 2 end end
  QuestHelper: Assert(not outputdict or #outputdict == dsize)
  
  local comp = QH_LZW_Compress(inproc, inputdict and #inputdict or 256, bits)
  
  if outputdict then
    local origcomp = comp
    local im = QuestHelper:MakeMerger()
    for i = 1, #origcomp do im:Add(outputdict:sub(strbyte(origcomp:sub(i, i)) + 1)) end
    comp = im:Finish()
  end
  
  return comp
end

-- old debug code :)
  
--[[  
print("hello")

QH_LZW_Compress("TOBEORNOTTOBEORTOBEORNOT", 256, 8)
]]

--[[
QuestHelper:TextOut("lulz")

local inq = "ABABABABA"
local alpha = 253
local bits = 7

str = QH_LZW_Compress(inq, alpha, bits)
tvr = ""
for i = 1, #str do
  tvr = tvr .. string.format("%d ", strbyte(str, i))
end
QuestHelper:TextOut(tvr)

ret = QH_LZW_Decompress(str, alpha, bits)
QuestHelper:TextOut(ret)

QuestHelper: Assert(inq == ret)
]]