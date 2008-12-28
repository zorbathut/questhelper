QuestHelper_File["collect_equip.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_equip.lua"] == "Development Version" then debug_output = true end

local GetItemType
local Notifier

local QHCI

-- why does this need to exist
local invloc_lookup_proto = {
  INVTYPE_HEAD = {"HeadSlot"},
  INVTYPE_NECK = {"NeckSlot"},
  INVTYPE_SHOULDER = {"ShoulderSlot"},
  INVTYPE_CHEST = {"ChestSlot"},
  INVTYPE_ROBE = {"ChestSlot"},
  INVTYPE_WAIST = {"WaistSlot"},
  INVTYPE_LEGS = {"LegsSlot"},
  INVTYPE_FEET = {"FeetSlot"},
  INVTYPE_WRIST = {"WristSlot"},
  INVTYPE_HAND = {"HandsSlot"},
  INVTYPE_FINGER = {"Finger0Slot", "Finger1Slot"},
  INVTYPE_TRINKET = {"Trinket0Slot", "Trinket1Slot"},
  INVTYPE_CLOAK = {"BackSlot"},
  INVTYPE_WEAPON = {"MainHandSlot", "SecondaryHandSlot"},
  INVTYPE_SHIELD = {"SecondaryHandSlot"},
  INVTYPE_2HWEAPON = {"MainHandSlot"},
  INVTYPE_WEAPONMAINHAND = {"MainHandSlot"},
  INVTYPE_WEAPONOFFHAND = {"SecondaryHandSlot"},
  INVTYPE_HOLDABLE = {"RangedSlot"},
  INVTYPE_RANGED = {"RangedSlot"},
  INVTYPE_THROWN = {"RangedSlot"},
  INVTYPE_RANGEDRIGHT = {"RangedSlot"},
  INVTYPE_RELIC = {"RangedSlot"},
}

local invloc_lookup = {}

for k, v in pairs(invloc_lookup_proto) do
  local temp = {}
  for _, tv in pairs(v) do
    local gisi = GetInventorySlotInfo(tv)
    QuestHelper:TextOut(string.format("%s %s", tv, gisi))
    table.insert(temp, (GetInventorySlotInfo(tv)))
  end
  invloc_lookup[k] = temp
end

local function Recheck(item, location, competing)
  for i, v in pairs(invloc_lookup[location]) do
    if competing[i] then
      local ilink = GetInventoryItemLink("player", v)
      if ilink then
        local itype = GetItemType(ilink)
        if itype == item then
          QuestHelper:TextOut("We equipped it!")
        elseif itype == competing[i] then
          QuestHelper:TextOut("We didn't equip it!")
        else
          QuestHelper:TextOut("We failed.")
        end
      end
    end
  end
end

local function Looted(message)
  local item = GetItemType(message, true)
  
  local name, _, quality, ilvl, min, itype, isubtype, _, equiploc, _ = GetItemInfo(item)

  QuestHelper:TextOut(string.format("lotsashit %s %s %s %s", tostring(name), tostring(IsEquippableItem(item)), tostring(min <= UnitLevel("player")), tostring(invloc_lookup[equiploc])))
  if name and IsEquippableItem(item) and min <= UnitLevel("player") and invloc_lookup[equiploc] then   -- The level comparison may be redundant
    local competing = {}
    local nonempty = false
    for i, v in pairs(invloc_lookup[equiploc]) do
      local litem = GetInventoryItemLink("player", v)
      if litem then litem = GetItemType(litem) end
      if litem and litem ~= item then competing[i] = litem  nonempty = true end
    end
    
    QuestHelper:TextOut(string.format("nonempty is %s", nonempty and "yes" or "no"))
    if not nonempty then return end -- congratulations you are better than nothing, we do not care
    
    --Notifier(GetTime() + 5 * 60, function () Recheck(item, equiploc, competing) end)
    Notifier(GetTime() + 15, function () Recheck(item, equiploc, competing) end)
  end
end

function QH_Collect_Equip_Init(QHCData, API)
  if not QHCData.item then QHCData.item = {} end
  QHCI = QHCData.item
  
  API.Registrar_EventHook("CHAT_MSG_LOOT", Looted)
  
  GetItemType = API.Utility_GetItemType
  Notifier = API.Utility_Notifier
  QuestHelper: Assert(GetItemType)
  QuestHelper: Assert(Notifier)
end
