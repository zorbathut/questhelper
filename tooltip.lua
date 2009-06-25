QuestHelper_File["tooltip.lua"] = "Development Version"
QuestHelper_Loadtime["tooltip.lua"] = GetTime()

if QuestHelper_File["tooltip.lua"] == "Development Version" then
  qh_hackery_nosuppress = true
end

local function DoTooltip(self, data, lines)
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

local ctts = {}

-- Format:
-- { ["monster@@1234"] = {{"Slay for blah blah blah"}, (Objective)} }
-- ("Slay for" is frequently an empty table)
function QH_Tooltip_Canned_Add(tooltips)
  for k, v in pairs(tooltips) do
    local typ, id = k:match("([^@]+)@@([^@]+)")
    --[[print(k)
    for tk, tv in pairs(v[1]) do
      print("    ", 1, tk, tv)
    end
    for tk, tv in pairs(v[2]) do
      print("    ", 2, tk, tv)
    end]]
    QuestHelper: Assert(typ and id, k)
    if not ctts[typ] then ctts[typ] = {} end
    if not ctts[typ][id] then ctts[typ][id] = {} end
    QuestHelper: Assert(not ctts[typ][id][v[2]])
    ctts[typ][id][v[2]] = v[1]
  end
end
function QH_Tooltip_Canned_Remove(tooltips)
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

local deferences = {}
local deference_default = {}  -- this is just a unique value that we can use to lookup

-- think about what we want out of this
-- If it matches quest/objective, we suppress it and show our canned text
-- If it matches quest, but has unknown objectives, we suppress it and show some synthesized "Canned thing, for Quest Blahblahblah"

-- tooltips is the same slay/objective pair in the above thing
function QH_Tooltip_Defer_Add(questname, objective, tooltips)
  --print("defer add", questname, objective)
  if not objective then objective = deference_default end
  
  if not deferences[questname] then deferences[questname] = {} end
  QuestHelper: Assert(not deferences[questname][objective])
  deferences[questname][objective] = tooltips
  if not deferences[questname][objective] then deferences[questname] = true end
end
function QH_Tooltip_Defer_Remove(questname, objective)
  if not objective then objective = deference_default end
  
  QuestHelper: Assert(deferences[questname][objective])
  deferences[questname][objective] = nil
  
  local cleanup = true
  for _ in pairs(deferences[questname]) do
    cleanup = false
  end
  
  if cleanup then
    deferences[questname] = nil
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
  --do return end
  if not UnitExists("mouseover") then return end
  
  local line = 2
  local wpos = line
  
  local changed = false
  local removed = 0
  
  if qh_tooltip_print_a_lot then print(line, _G["GameTooltipTextLeft" .. line], _G["GameTooltipTextLeft" .. line]:IsShown()) end
  
  local qobj = nil
  
  while _G["GameTooltipTextLeft" .. line] and _G["GameTooltipTextLeft" .. line]:IsShown() do
    local r, g, b, a = _G["GameTooltipTextLeft" .. line]:GetTextColor()
    r, g, b, a = math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5), math.floor(a * 255 + 0.5)
    
    if qh_tooltip_print_a_lot then print(r, g, b, a) end
    
    if r == 255 and g == 210 and b == 0 and a == 255 and not qh_tooltip_do_not_hide_things then
      if qh_tooltip_print_a_lot then print("hiding") end
      
      local thistext = _G["GameTooltipTextLeft" .. line]:GetText()
      
      if deferences[thistext] then
        qobj = deferences[thistext]
      elseif qobj and qobj[thistext] then
        DoTooltip(ttp, qobj[thistext][2], qobj[thistext][1])
      end
      
      if not qh_hackery_nosuppress then
        _G["GameTooltipTextLeft" .. line]:SetText(nil)
        _G["GameTooltipTextLeft" .. line]:SetHeight(0)
        _G["GameTooltipTextLeft" .. line]:ClearAllPoints()
        _G["GameTooltipTextLeft" .. line]:SetPoint("TOPLEFT", _G["GameTooltipTextLeft" .. (line - 1)], "BOTTOMLEFT", 0, 1)
        changed = true
        removed = removed + 1
      end
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
      if qh_tooltip_print_a_lot then print("huhwuzat") print(QH_filter_hints) end
      
      glob_strip = StripBlizzQHTooltipClone(self)
      
      local ite = tostring(GetMonsterType(ulink))
      
      if ctts["monster"] and ctts["monster"][ite] then
        for data, lines in pairs(ctts["monster"][ite]) do
          DoTooltip(self, data, lines)
        end
      end
      
      self:Show()
    end
  end
end

local unit_to_adjust = nil

local ottsu = GameTooltip:GetScript("OnTooltipSetUnit")
QH_Hook(GameTooltip, "OnTooltipSetUnit", function (self, ...)
  if qh_tooltip_print_a_lot then print("lol") end
  CreateTooltip(self)
  if ottsu then ottsu(self, ...) end
  unit_to_adjust = self:GetUnit()
end, "tooltip OnTooltipSetUnit")

local ottsi = GameTooltip:GetScript("OnTooltipSetItem")
QH_Hook(GameTooltip, "OnTooltipSetItem", function (self, ...)
  QH_Hook_NotMyFault(CreateTooltip, self)
  if ottsi then return QH_Hook_NotMyFault(ottsi, self, ...) end
end, "tooltip OnTooltipSetItem")

local ttsx = GameTooltip:GetScript("OnUpdate")
QH_Hook(GameTooltip, "OnUpdate", function (self, ...)
  if ttsx then QH_Hook_NotMyFault(ttsx, self, ...) end
  if glob_strip and unit_to_adjust and unit_to_adjust == self:GetUnit() then
    self:SetHeight(self:GetHeight() - glob_strip * 3) -- maaaaaagic
    unit_to_adjust = nil
  end
end, "tooltip OnUpdate")
