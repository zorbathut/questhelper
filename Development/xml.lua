-- Here we attempt to convert XML text into a Lua table.
-- This isn't an exact conversion, and is more special case
-- to suit my purposes, but it's good enough.

local codepage =
 {
  [0]=
  0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,
  0x0010,0x0011,0x0012,0x0013,0x0014,0x0015,0x0016,0x0017,0x0018,0x0019,0x001A,0x001B,0x001C,0x001D,0x001E,0x001F,
  0x0020,0x0021,0x0022,0x0023,0x0024,0x0025,0x0026,0x0027,0x0028,0x0029,0x002A,0x002B,0x002C,0x002D,0x002E,0x002F,
  0x0030,0x0031,0x0032,0x0033,0x0034,0x0035,0x0036,0x0037,0x0038,0x0039,0x003A,0x003B,0x003C,0x003D,0x003E,0x003F,
  0x0040,0x0041,0x0042,0x0043,0x0044,0x0045,0x0046,0x0047,0x0048,0x0049,0x004A,0x004B,0x004C,0x004D,0x004E,0x004F,
  0x0050,0x0051,0x0052,0x0053,0x0054,0x0055,0x0056,0x0057,0x0058,0x0059,0x005A,0x005B,0x005C,0x005D,0x005E,0x005F,
  0x0060,0x0061,0x0062,0x0063,0x0064,0x0065,0x0066,0x0067,0x0068,0x0069,0x006A,0x006B,0x006C,0x006D,0x006E,0x006F,
  0x0070,0x0071,0x0072,0x0073,0x0074,0x0075,0x0076,0x0077,0x0078,0x0079,0x007A,0x007B,0x007C,0x007D,0x007E,0x007F,
  0x20AC,0xFFFD,0x201A,0x0192,0x201E,0x2026,0x2020,0x2021,0x02C6,0x2030,0x0160,0x2039,0x0152,0xFFFD,0x017D,0xFFFD,
  0xFFFD,0x2018,0x2019,0x201C,0x201D,0x2022,0x2013,0x2014,0x02DC,0x2122,0x0161,0x203A,0x0153,0xFFFD,0x017E,0x0178,
  0x00A0,0x00A1,0x00A2,0x00A3,0x00A4,0x00A5,0x00A6,0x00A7,0x00A8,0x00A9,0x00AA,0x00AB,0x00AC,0x00AD,0x00AE,0x00AF,
  0x00B0,0x00B1,0x00B2,0x00B3,0x00B4,0x00B5,0x00B6,0x00B7,0x00B8,0x00B9,0x00BA,0x00BB,0x00BC,0x00BD,0x00BE,0x00BF,
  0x00C0,0x00C1,0x00C2,0x00C3,0x00C4,0x00C5,0x00C6,0x00C7,0x00C8,0x00C9,0x00CA,0x00CB,0x00CC,0x00CD,0x00CE,0x00CF,
  0x00D0,0x00D1,0x00D2,0x00D3,0x00D4,0x00D5,0x00D6,0x00D7,0x00D8,0x00D9,0x00DA,0x00DB,0x00DC,0x00DD,0x00DE,0x00DF,
  0x00E0,0x00E1,0x00E2,0x00E3,0x00E4,0x00E5,0x00E6,0x00E7,0x00E8,0x00E9,0x00EA,0x00EB,0x00EC,0x00ED,0x00EE,0x00EF,
  0x00F0,0x00F1,0x00F2,0x00F3,0x00F4,0x00F5,0x00F6,0x00F7,0x00F8,0x00F9,0x00FA,0x00FB,0x00FC,0x00FD,0x00FE,0x00FF,
 }

local char_scale = {[0]=0x01, 0x40, 0x1000, 0x40000, 0x1000000, 0x40000000, 0x80000000}
local char_max   = {[0]=0x00, 0x7f, 0x7ff,  0xffff,  0x1fffff,  0x3ffffff,  0x7fffffff}
local char_base  = {[0]=0x00, 0xc0, 0xe0,   0xf0,    0xf8,      0xfc,       0xfe}

-- Converts non-UTF-8 characters to UTF-8, assuming they're encoded as Windows-1252.
-- No guarentees it works, afterall, this was malformed text to begin with.
function correctText(text)
  local i, e = 1,string.len(text)+1
  while i < e do
    local byte = string.byte(text, i)
    assert(byte)
    local valid = false
    
    for l = 1,6 do
      if byte < char_base[l] then
        valid = true
        
        if l == 1 and byte >= 128 then
          valid = false
        else
          for c=i+1,i+l-1 do
            byte = string.byte(text, c)
            if not byte or byte < 0x80 or byte >= 0xC0 then
              valid = false
              break
            end
          end
        end
        
        if valid then
          i = i + l
        end
        
        break
      end
    end
    
    if not valid then
      local char = codepage[string.byte(text, i)]
      
      for size=1,6 do
        if char <= char_max[size] then
          local s = string.char(char_base[size-1]+math.floor(char/char_scale[size-1]))
          
          for o = size-2,0,-1 do
           s = s .. string.char(0x80+math.floor(char/char_scale[o])%0x40)
          end
          
          text = string.format("%s%s%s", string.sub(text, 1,i-1), s, string.sub(text,i+1))
          i = i + size
          e = e + size - 1
          assert(e == string.len(text)+1)
          break
        end
      end
    end
  end
  
  return text
end

local function createObj()
  return {}
end

local function readVar(data)
  data:skipws()
  local var = ""
  while string.find(data:peek(), "%a") do
    var = var .. data:get()
  end
  data:skipws()
  return (var ~= "" and var) or nil
end

local function readString(data)
  data:skipws()
  local s = ""
  if data:peek() == "\"" then
    data:get()
    while true do
      local c, e = data:get()
      if c == "\"" and not e then
        return s
      end
      s = s .. c
    end
    print("readString: '"..s.."'")
    return s
  else
    return readVar(data)
  end
end

local function loadObj(obj, data)
  local buffer = CreateBuffer()
  data:skipws()
  
  while true do
    local c, e = data:get()
    if not c then break end
    if c == "<" and not e then
      data:skipws()
      local p = data:peek()
      
      if p == "?" then
        data:skipto("?>")
      elseif p == "/" then
        data:skipto(">")
        break
      else
        local name = readVar(data)
        if name then
          local obj2 = createObj()
          local closed = false
          obj[name] = obj2
          
          while not string.find(data:peek(), "[/>]") do
            local varname = readVar(data)
            if not varname then break end
            if data:peek() == "=" then
              data:get()
              local value = readString(data)
              if value then
                obj2[varname] = value
              end
            end
          end
          
          if data:peek() == ">" then
            data:get()
            obj[name] = loadObj(obj2, data)
          else
            -- assuming got "/>", closing the tag.
            data:skipto(">")
          end
        end
      end
    else
      buffer:add(c)
    end
  end
  
  local value = select(3, string.find(buffer:dump(), "^%s*(.-)%s*$"))
  if value == "" then
    value = nil
  else
    value = tonumber(value) or value
  end
  
  if value then
    if not next(obj) then
      return value
    else
      obj.value = value
    end
  end
  return obj
end

local function readText(self)
  if self[3] then
    local c, e = self[3], self[4]
    self[3] = nil
    return c, e
  end
  
  local p = self[2]
  local c = string.sub(self[1], p, p)
  
  if c == "&" then
    c = nil
    local s, e, code = string.find(self[1], "^(.-);", p+1)
    self[2] = e+1
    
    if code == "amp" then
      return "&", true
    elseif code == "lt" then
      return "<", true
    elseif code == "gt" then
      return ">", true
    elseif code == "quot" then
      return "\"", true
    else
      assert(false, "Unknown entity code: "..code)
    end
  elseif c == "" then
    return nil, false
  else
    self[2] = p + 1
  end
  
  self[3] = nil
  
  return c, false
end

local function peekText(self)
  if self[3] then
    return self[3], self[4]
  end
  
  self[3], self[4] = readText(self)
  return self[3], self[4]
end

local function skipSpaces(self)
  while string.find(peekText(self), "%s") do readText(self) end
end

local function skipTo(self, pattern)
  self[2] = (select(2, string.find(self[1], pattern, self[2])) or self[2]) + 1
  self[3] = nil
end

function XMLtoLUA(filename)
  local stream = io.open(filename, "r")
  if stream then
    local data = {correctText(stream:read("*a")), 1, get=readText, peek=peekText, skipws=skipSpaces, skipto=skipTo}
    io.close(stream)
    local obj = createObj()
    loadObj(obj, data)
    return obj.xml
  end
  return nil
end

--loadfile("dump.lua")()
--print(ScanAndDumpVariable(XMLtoLUA("test.xml"), "XML", true))