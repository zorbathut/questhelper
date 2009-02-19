QuestHelper_File["collect.lua"] = "Development Version"
QuestHelper_Loadtime["collect.lua"] = GetTime()

local debug_output = false
if QuestHelper_File["collect.lua"] == "Development Version" then debug_output = true end

local QuestHelper_Collector_Version_Current = 5

QuestHelper_Collector = {}

local EventRegistrar = {}
local OnUpdateRegistrar = {}
local TooltipRegistrar = {}

local frame = CreateFrame("Frame")

local function OnEvent(_, event, ...)
  local tstart = GetTime()
  for _, v in pairs(EventRegistrar[event]) do
    v(...)
  end
  QH_Timeslice_Increment(GetTime() - tstart, "collect_event")
end

frame:UnregisterAllEvents()
frame:SetScript("OnEvent", OnEvent)

frame:Show()

function EventHookRegistrar(event, func)
  QuestHelper:Assert(func)
  if not EventRegistrar[event] then
    frame:RegisterEvent(event)
    EventRegistrar[event] = {}
  end
  table.insert(EventRegistrar[event], func)
end

function OnUpdateHookRegistrar(func)
  QuestHelper:Assert(func)
  table.insert(OnUpdateRegistrar, func)
end

local OriginalScript = GameTooltip:GetScript("OnShow")
GameTooltip:SetScript("OnShow", function (self, ...)
  if not self then self = GameTooltip end
  
  local tstart = GetTime()
  for k, v in pairs(TooltipRegistrar) do
    v(self, ...)
  end
  QH_Timeslice_Increment(GetTime() - tstart, "collect_tooltip") -- anything past here is not my fault
  if OriginalScript then
    return OriginalScript(self, ...)
  end
end)

function TooltipHookRegistrar(func)
  QuestHelper:Assert(func)
  table.insert(TooltipRegistrar, func)
end

local API = {
  Registrar_EventHook = EventHookRegistrar,
  Registrar_OnUpdateHook = OnUpdateHookRegistrar,
  Registrar_TooltipHook = TooltipHookRegistrar,
  Callback_RawLocation = function () return QuestHelper:RetrieveRawLocation() end,
}

local CompressCollection

function QH_Collector_Init()
  QH_Collector_UpgradeAll(QuestHelper_Collector)
  

  
  for _, v in pairs(QuestHelper_Collector) do
    if not v.modified then v.modified = time() - 7 * 24 * 60 * 60 end  -- eugh. Yeah, we set it to be a week ago. It's pretty grim.
    if not v.version then v.version = QuestHelper_Collector_Version end -- double-eugh. Man did I fuck this thing up.
  end
  
  local sig = string.format("%s on %s/%s/%d", GetAddOnMetadata("QuestHelper", "Version"), GetBuildInfo(), GetLocale(), QuestHelper:PlayerFaction())
  if not QuestHelper_Collector[sig] or QuestHelper_Collector[sig].compressed then QuestHelper_Collector[sig] = {version = QuestHelper_Collector_Version} end -- fuckin' bullshit, man
  local QHCData = QuestHelper_Collector[sig]
  QuestHelper: Assert(not QHCData.compressed)
  QuestHelper: Assert(QHCData.version == QuestHelper_Collector_Version_Current)
  QHCData.modified = time()
  
  QH_Collect_Util_Init(nil, API)  -- Some may actually add their own functions to the API, and should go first. There's no real formalized order, I just know which depend on others, and it's heavily asserted so it will break if it goes in the wrong order.
  QH_Collect_Merger_Init(nil, API)
  QH_Collect_Bitstream_Init(nil, API)
  
  QH_Collect_Location_Init(nil, API)
  QH_Collect_Patterns_Init(nil, API)
  QH_Collect_Notifier_Init(nil, API)
  QH_Collect_Spec_Init(nil, API)
  
  QH_Collect_LZW_Init(nil, API)
  
  QH_Collect_Achievement_Init(QHCData, API)
  QH_Collect_Traveled_Init(QHCData, API)
  QH_Collect_Zone_Init(QHCData, API)
  QH_Collect_Monster_Init(QHCData, API)
  QH_Collect_Item_Init(QHCData, API)
  QH_Collect_Object_Init(QHCData, API)
  QH_Collect_Flight_Init(QHCData, API)
  QH_Collect_Quest_Init(QHCData, API)
  
  QH_Collect_Loot_Init(QHCData, API)
  QH_Collect_Equip_Init(QHCData, API)
  QH_Collect_Merchant_Init(QHCData, API)
  
  if not QHCData.realms then QHCData.realms = {} end
  QHCData.realms[GetRealmName()] = (QHCData.realms[GetRealmName()] or 0) + 1 -- I'm not entirely sure why I'm counting
  
  -- So, why do we delay it?
  -- It's simple. People are gonna update to this version, and then they're going to look at the memory usage. Then they will panic because omg this version uses so much more memory, I bet that will somehow hurt my framerates in a way which is not adequately explained!
  -- So instead, we just wait half an hour before compressing. Compression will still get done, and I won't have to deal with panicked comments about how bloated QH has gotten.
  -- Want QH to work better? Just make that "30 * 60" bit into "0" instead.
  API.Utility_Notifier(GetTime() + 30 * 60, function() CompressCollection(QHCData, API.Utility_Merger, API.Utility_LZW.Compress) end)
end

function QH_Collector_OnUpdate()
  local tstart = GetTime()
  for _, v in pairs(OnUpdateRegistrar) do
    v()
  end
  QH_Timeslice_Increment(GetTime() - tstart, "collect_update")
end



--- I've tossed the compression stuff down here just 'cause I don't feel like making an entire file for it (even though I probably should.)

local seritem

local serializers = {
  ["nil"] = function(item, add)
    add("nil")
  end,
  ["number"] = function(item, add)
    add(tostring(item))
  end,
  ["string"] = function(item, add)
    add(string.format("%q", item))
  end,
  ["boolean"] = function(item, add)
    add(item and "true" or "false")
  end,
  ["table"] = function(item, add)
    add("{")
    local first = true
    for k, v in pairs(item) do
      if not first then add(",") end
      first = false
      add("[")
      seritem(k, add)
      add("]=")
      seritem(v, add)
    end
    add("}")
  end,
}

seritem = function(item, add)
  QH_Timeslice_Yield()
  serializers[type(item)](item, add)
end

local function DoCompress(item, merger, comp)
if debug_output then QuestHelper: TextOut("Item condensing") end
  local ts = GetTime()
  
  local target = {}
  for k, v in pairs(item) do
    if k ~= "modified" then
      target[k] = v
    end
  end
  
  local mg = {}
  seritem(target, function(dat) merger.Add(mg, dat) end)
  
  local tg = merger.Finish(mg)
  if debug_output then QuestHelper: TextOut(string.format("Item condensed to %d bytes, %f taken so far", #tg, GetTime() - ts)) end
  mg = nil
  
  local cmp = comp(tg, 256, 8)
  
  for k, v in pairs(target) do
    if k ~= "modified" then
      item[k] = nil
    end
  end
  item.compressed = cmp
  
  if debug_output then QuestHelper: TextOut(string.format("Item compressed to %d bytes (previously %d), %f taken", #cmp, #tg, GetTime() - ts)) end
end

CompressCollection = function(active, merger, comp)
  for _, v in pairs(QuestHelper_Collector) do
    if v ~= active and not v.compressed then
      QH_Timeslice_Add(function ()
        DoCompress(v, merger, comp)
        CompressCollection(active, merger, comp)
      end, "compress")
      break
    end
  end
end
