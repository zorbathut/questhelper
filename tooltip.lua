QuestHelper_File["tooltip.lua"] = "Development Version"
QuestHelper_Loadtime["tooltip.lua"] = GetTime()

local function DoTooltip(self, tooltipi)
  QuestHelper:TextOut(string.format("Got %d items", #tooltipi))
  for data, _ in pairs(tooltipi) do
    self:AddLine(data.desc)
    self:AddLine("we hateses you")
  end
end

local ctts = {}

function QH_Tooltip_Add(tooltips)
  QuestHelper:TextOut(QuestHelper:StringizeTable(tooltips))
  for k, v in pairs(tooltips) do
    local typ, id = k:match("([^@]+)@@([^@]+)")
    QuestHelper:TextOut(string.format("Adding for %s/%s", typ, id))
    if not ctts[typ] then ctts[typ] = {} end
    if not ctts[typ][id] then ctts[typ][id] = {} end
    QuestHelper: Assert(not ctts[typ][id][v])
    ctts[typ][id][v] = true
  end
end
function QH_Tooltip_Remove(tooltips)
  for k, v in pairs(tooltips) do
    local typ, id = k:match("([^@]+)@@([^@]+)")
    QuestHelper: Assert(ctts[typ][id][v])
    ctts[typ][id][v] = nil
    
    local cleanup = true
    for _, _ in pairs(ctts[typ][id]) do
      cleanup = false
    end
    
    if cleanup then
      ctts[typ][id] = nil
    end
  end
end

-- TODO: move this into some common file, I hate that I'm duplicating them but I just want this to work. entire codebase will need a going-over soon
local function IsMonsterGUID(guid)
  QuestHelper: Assert(#guid == 18, "guid len " .. guid) -- 64 bits, plus the 0x prefix
  QuestHelper: Assert(guid:sub(1, 2) == "0x", "guid 0x-prefix " .. guid)
  return guid:sub(5, 5) == "3" or guid:sub(5, 5) == "5"
end

local function GetMonsterType(guid)
  QuestHelper: Assert(#guid == 18, "guid len " .. guid) -- 64 bits, plus the 0x prefix
  QuestHelper: Assert(guid:sub(1, 2) == "0x", "guid 0x-prefix " .. guid)
  QuestHelper: Assert(guid:sub(5, 5) == "3" or guid:sub(5, 5) == "5", "guid 3-prefix " .. guid)  -- It *shouldn't* be a player or a pet by the time we've gotten here. If so, something's gone wrong.
  return tonumber(guid:sub(9, 12), 16)  -- here's our actual identifier
end

local function GetItemType(link, vague)
  return tonumber(string.match(link,
    (vague and "" or "^") .. "|cff%x%x%x%x%x%x|Hitem:(%d+):[%d:-]+|h%[[^%]]*%]|h|r".. (vague and "" or "$") 
  ))
end

local OrigScript = GameTooltip:GetScript("OnShow")      -- how many times have I hooked this function by now?
GameTooltip:SetScript("OnShow", function (self, ...)

  local inu, ilink = self:GetItem()
  local un, ulink = self:GetUnit()
  if ulink then ulink = UnitGUID(ulink) end
  
  if ilink then
    local ite = tostring(GetItemType(ilink))
    
    if ctts["item"] and ctts["item"][ite] then
      DoTooltip(self, ctts["item"][ite])
    end
    
    self:Show()
  end
  
  if ulink and IsMonsterGUID(ulink) then
    local ite = tostring(GetMonsterType(ulink))
    print(ite)
    
    if ctts["monster"] and ctts["monster"][ite] then
      DoTooltip(self, ctts["monster"][ite])
    end
    
    self:Show()
  end
  
  if OrigScript then OrigScript(self, ...) end
end)
