QuestHelper_File["collect_location.lua"] = "Development Version"
QuestHelper_Loadtime["collect_location.lua"] = GetTime()

-- little endian two's complement
local function signed(c)
  QuestHelper: Assert(not c or c >= -127 and c < 127)
  if not c then c = -128 end
  if c < 0 then c = c + 256 end
  return strchar(c)
end

local function float(c)
  if c then
    c = math.floor(c * 1000 + 0.5) -- get our 3 digits, then integer it
    QuestHelper: Assert(c >= -2147483647 and c < 2147483647)
  else
    c = -2147483648
  end
  if c < 0 then c = c + 4294967296 end
  return strchar(bit.band(c, 0xff), bit.band(c, 0xff00) / 256, bit.band(c, 0xff0000) / 65536, bit.band(c, 0xff000000) / 16777216)
end

local function BolusizeLocation(c, x, y, rc, rz, delayed)
  -- c, rc, and rz are all *signed* integers that fit within an 8-bit int.
  -- x and y are floating-point values. We're going to assume they're 5-digit, but we also want at least 3 digits of precision. (Note that 3 digits is a more than most sites use - most of them do 3 digits in terms of local map coordinates, but most maps are more than 1000 yards large, with the exception of some major cities.) That's 8 digits total, so we're gonna be spending 32 bits on this. Lua uses 64-bit float types, which have something like 53 digits of precision, so we've got plenty of accuracy for our 32 bits.
  -- Overall we're using a somewhat-more-normal 12 bytes on this. Meh.
  -- Also, any nil values are being turned into MIN_WHATEVER.
  return signed(delayed and 1 or 0) .. signed(c) .. float(x) .. float(y) .. signed(rc) .. signed(rz)
end

-- This merely provides another API function
function QH_Collect_Location_Init(_, API)
  API.Callback_LocationBolus = BolusizeLocation  -- Yeah. *Bolusize*. You heard me.
  API.Callback_LocationBolusCurrent = function () return BolusizeLocation(API.Callback_RawLocation()) end  -- This is just a convenience function, really
end
