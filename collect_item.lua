QuestHelper_File["collect_item.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_item.lua"] == "Development Version" then debug_output = true end

local QHCI

local function Tooltipy(self, ...)
  local _, ilink = self:GetItem()
  if not ilink then return end
  
  local id = string.match(ilink,
    --"^|cff%x%x%x%x%x%x|Hitem:(%d+):[%d:]+|h\[.*\]|h|r$"
    "^|cff%x%x%x%x%x%x|Hitem:(%d+):[%d:-]+|h%[[^%]]*%]|h|r$"
  )
  
  if not QHCI[id] then QHCI[id] = {} end
  local item = QHCI[id]
  
  local name, _, quality, ilvl, min, itype, isubtype, _, equiploc, _ = GetItemInfo(id)
  
  if name then
    item.name = name
    item.quality = quality
    item.ilevel = ilvl
    item.minlevel = min
    item.type = string.format("%s/%s", itype, isubtype)
    
    local loc = string.match(equiploc, "INVTYPE_(.*)")
    if loc then
      item.equiplocation = loc
    else
      item.equiplocation = nil
    end
  end
end

function QH_Collect_Item_Init(QHCData, API)
  if not QHCData.item then QHCData.item = {} end
  QHCI = QHCData.item
  
  API.Registrar_TooltipHook(Tooltipy)
end
