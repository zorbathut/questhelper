QuestHelper_File["collect_lzw.lua"] = "Development Version"
QuestHelper_Loadtime["collect_lzw.lua"] = GetTime()

local Merger
local Bitstream

local function cleanup(tab)
  for _, v in pairs(tab) do
    QuestHelper:ReleaseTable(v)
  end
  QuestHelper:ReleaseTable(tab)
end

local function QH_LZW_Decompress(input, tokens, outbits)
  local d = QuestHelper:CreateTable("lzw")
  local i
  for i = 0, tokens-1 do
    d[i] = QuestHelper:CreateTable("lzw")
    d[i][0] = string.char(i)
  end
  
  local dsize = tokens + 1  -- we use the "tokens" value as an EOF marker
  
  local bits = 1
  local nextbits = 2
  
  while nextbits < dsize do bits = bits + 1; nextbits = nextbits * 2 end
  
  local i = Bitstream.Input(input, outbits)
  local rv = {}
  
  local idlect = 0
  
  local tok = i:depend(bits)
  if tok == tokens then cleanup(d) return "" end -- Okay. There's nothing. We get it.
  
  Merger.Add(rv, d[bit.mod(tok, tokens)][math.floor(tok / tokens)])
  local w = d[bit.mod(tok, tokens)][math.floor(tok / tokens)]
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
    if d[bit.mod(tok, tokens)][math.floor(tok / tokens)] then
      entry = d[bit.mod(tok, tokens)][math.floor(tok / tokens)]
    elseif tok == dsize - 1 then
      entry = w .. w:sub(1, 1)
    else
      QuestHelper: Assert(false, "faaaail")
    end
    Merger.Add(rv, entry)
    
    d[bit.mod(dsize - 1, tokens)][math.floor((dsize - 1) / tokens)] = w .. entry:sub(1, 1) -- Naturally, we're writing to one *less* than dsize, since we already incremented.
    
    w = entry
  end
  
  cleanup(d)
  
  return Merger.Finish(rv)
end

local function QH_LZW_Compress(input, tokens, outbits)
  -- shared init code
  local d = {}
  local i
  for i = 0, tokens-1 do
    d[string.char(i)] = {[""] = i}
  end
  
  local dsize = tokens + 1  -- we use the "tokens" value as an EOF marker
  
  local bits = 1
  local nextbits = 2
  
  while nextbits < dsize do bits = bits + 1; nextbits = nextbits * 2 end
  
  local r = Bitstream.Output(outbits)
  
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
    if d[wcp:sub(1, 1)][wcp:sub(2)] then
      w = wcp
    else
      r:append(d[w:sub(1, 1)][w:sub(2)], bits)
      d[wcp:sub(1, 1)][wcp:sub(2)] = dsize
      dsize = dsize + 1
      if dsize > nextbits then
        bits = bits + 1
        nextbits = nextbits * 2
      end
      w = c
    end
  end
  if w ~= "" then r:append(d[w:sub(1, 1)][w:sub(2)], bits) end
  
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

local function QH_LZW_Compress_Dicts(input, inputdict, outputdict)
  local inproc = input
  if inputdict then
    local idc = {}
    for i = 1, #inputdict do idc[inputdict:sub(i, i)] = strchar(i - 1) end
    local im = {}
    for i = 1, #input do Merger.Add(im, idc[input:sub(i, i)]) end
    inproc = Merger.Finish(im)
  end
  
  local bits, dsize = 1, 2
  if not outputdict then bits = 8 else while dsize < #outputdict do bits = bits + 1 ; dsize = dsize * 2 end end
  QuestHelper: Assert(not outputdict or #outputdict == dsize)
  
  local comp = QH_LZW_Compress(inproc, inputdict and #inputdict or 256, bits)
  
  if outputdict then
    local origcomp = comp
    local im = {}
    for i = 1, #origcomp do Merger.Add(im, outputdict:sub(strbyte(origcomp:sub(i, i)) + 1)) end
    comp = Merger.Finish(im)
  end
  
  return comp
end

local function QH_LZW_Decompress_Dicts(compressed, inputdict, outputdict) -- this is kind of backwards - we assume that "outputdict" is the dictionary that "compressed" is encoded in
  QuestHelper: Assert(not outputdict)
  QuestHelper: Assert(inputdict)
  
  local decomp = QH_LZW_Decompress(compressed, #inputdict, 8)
  
  local ov = {}
  for i = 1, #decomp do
    Merger.Add(ov, inputdict:sub(decomp:byte(i) + 1, decomp:byte(i) + 1))
  end
  return Merger.Finish(ov)
end

QH_LZW_Decompress_Dicts_Arghhacky = QH_LZW_Decompress_Dicts -- need to rig up a better mechanism for this really

function QH_Collect_LZW_Init(_, API)
  Merger = API.Utility_Merger
  QuestHelper: Assert(Merger)
  
  Bitstream = API.Utility_Bitstream
  QuestHelper: Assert(Bitstream)
  
  API.Utility_LZW = {Compress = QH_LZW_Compress, Decompress = QH_LZW_Decompress, Compress_Dicts = QH_LZW_Compress_Dicts, Decompress_Dicts = QH_LZW_Decompress_Dicts}
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
