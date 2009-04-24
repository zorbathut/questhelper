QuestHelper_File["tooltip.lua"] = "1.0.7-alpha"
QuestHelper_Loadtime["tooltip.lua"] = GetTime()

local function DoTooltip(self, tooltipi)
  local ct = 0
  for data, lines in pairs(tooltipi) do
    ct = ct + 1
    
    local indent = 1
    --QuestHelper:TextOut(QuestHelper:StringizeTable(data))
    --QuestHelper:TextOut(QuestHelper:StringizeTable(lines))
    for _, v in ipairs(lines) do
      self:AddLine(("  "):rep(indent) .. v, 1, 1, 1)
      indent = indent + 1
    end
    self:AddLine(("  "):rep(indent) .. data.desc, 1, 1, 1)
    QuestHelper:AppendObjectiveProgressToTooltip(data, self, nil, indent + 1)
  end
  --QuestHelper:TextOut(string.format("Got %d items", ct))
end

local ctts = {}

function QH_Tooltip_Add(tooltips)
  for k, v in pairs(tooltips) do
    local typ, id = k:match("([^@]+)@@([^@]+)")
    QuestHelper: Assert(typ and id, k)
    if not ctts[typ] then ctts[typ] = {} end
    if not ctts[typ][id] then ctts[typ][id] = {} end
    QuestHelper: Assert(not ctts[typ][id][v[2]])
    ctts[typ][id][v[2]] = v[1]
  end
end
function QH_Tooltip_Remove(tooltips)
  for k, v in pairs(tooltips) do
    local typ, id = k:match("([^@]+)@@([^@]+)")
    QuestHelper: Assert(typ and id, k)
    QuestHelper: Assert(ctts[typ][id][v[2]])
    ctts[typ][id][v[2]] = nil
    
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

local function CopyOver(to, from)
  to:SetFont(from:GetFont())
  to:SetFontObject(from:GetFontObject())
  to:SetText(from:GetText())
  to:SetTextColor(from:GetTextColor())
  to:SetSpacing(from:GetSpacing())
  to:SetShadowOffset(from:GetShadowOffset())
  to:SetShadowColor(from:GetShadowColor())
  to:Show()
end

local function StripBlizzQHTooltipClone(ttp)
  if not UnitExists("mouseover") then return end
  
  local line = 2
  local wpos = line
  
  local changed = false
  local removed = 0
  
  if qh_tooltip_print_a_lot then print(line, _G["GameTooltipTextLeft" .. line], _G["GameTooltipTextLeft" .. line]:IsShown()) end
  
  while _G["GameTooltipTextLeft" .. line] and _G["GameTooltipTextLeft" .. line]:IsShown() do
    local r, g, b, a = _G["GameTooltipTextLeft" .. line]:GetTextColor()
    r, g, b, a = math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5), math.floor(a * 255 + 0.5)
    
    if qh_tooltip_print_a_lot then print(r, g, b, a) end
    
    if r == 255 and g == 210 and b == 0 and a == 255 and not qh_tooltip_do_not_hide_things then
      if qh_tooltip_print_a_lot then print("hiding") end
      --_G["GameTooltipTextLeft" .. line]:SetText("hellos")
      _G["GameTooltipTextLeft" .. line]:SetText(nil)
      _G["GameTooltipTextLeft" .. line]:SetHeight(0)
      _G["GameTooltipTextLeft" .. line]:ClearAllPoints()
      _G["GameTooltipTextLeft" .. line]:SetPoint("TOPLEFT", _G["GameTooltipTextLeft" .. (line - 1)], "BOTTOMLEFT", 0, 1)
      changed = true
      removed = removed + 1
    end
    
    line = line + 1
  end
    
  if changed then
    ttp:Show()
  end
  
  return removed
end

local glob_strip = 0
function CreateTooltip(self)
  glob_strip = 0
  
  if QuestHelper_Pref.tooltip then
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
    
    if qh_tooltip_print_a_lot then print("wut", ulink, IsMonsterGUID(ulink)) print(ulink) print(IsMonsterGUID(ulink)) end
    if ulink and IsMonsterGUID(ulink) then
      if QH_filter_hints then
        glob_strip = StripBlizzQHTooltipClone(self)
      end
      
      local ite = tostring(GetMonsterType(ulink))
      
      if ctts["monster"] and ctts["monster"][ite] then
        DoTooltip(self, ctts["monster"][ite])
      end
      
      self:Show()
    end
  end
end

local ottsu = GameTooltip:GetScript("OnTooltipSetUnit")
GameTooltip:SetScript("OnTooltipSetUnit", function (self, ...)
  if qh_tooltip_print_a_lot then print("lol") end
  CreateTooltip(self)
  if ottsu then ottsu(self, ...) end
end)

local ottsi = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem", function (self, ...)
  CreateTooltip(self)
  if ottsi then return ottsi(self, ...) end
end)

local ttsx = GameTooltip:GetScript("OnUpdate")
GameTooltip:SetScript("OnUpdate", function (self, ...)
  if ttsx then ttsx(self, ...) end
  if self:GetUnit() then
    self:Show()
    self:SetHeight(self:GetHeight() - glob_strip * 3) -- maaaaaagic
  end
end)
