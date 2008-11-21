QuestHelper_File["collect_monster.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_monster.lua"] == "Development Version" then debug_output = true end

local QHCM

local GetLoc
local Merger

local function Looted()
--[[
  QuestHelper:TextOut("lootopened")
  for i = 1, GetNumLootItems() do
    _, _, quant, _ = GetLootSlotInfo(i)
    QuestHelper:TextOut("lewted " .. tostring(GetLootSlotLink(i)) .. " with " .. tostring(quant))
  end
]]
end

local function Tooltipy(self, ...)
--[[
  QuestHelper:TextOut(tostring(self:GetAnchorType()))
  if self:GetAnchorType() == "ANCHOR_NONE" then
    QuestHelper:TextOut("gat done")
    local iname, ilink = self:GetItem()
    local mname, mlink = self:GetUnit()
    local sname, srank = self:GetSpell()
    QuestHelper:TextOut(string.format("iname %s mname %s sname %s lines %d", tostring(iname), tostring(mname), tostring(sname), self:NumLines()))
    for i = 1, GameTooltip:NumLines() do
      local mytext = getglobal("GameTooltipTextLeft" .. i)
      QuestHelper:TextOut(mytext:GetText())
    end
  else
    QuestHelper:TextOut("gat fail")
  end
]]
end

local InteractDistances = {28, 11, 10, 0} -- There's actually a 4, but it's also 28 and it's kind of handy to be able to do it this way.

local recentlySeenCritters = {} -- We try not to repeatedly record critters frequently.

-- Kind of a nasty system here, built for efficiency and simplicity. All newly-seen critters go into Recent. When Recent reaches a certain size (100?) everything in NextTrash is deleted and NextTrash is replaced with Recent. Badabing, badaboom.
local recentlySeenCritters_NextTrash = {}
local recentlySeenCritters_Recent = {}

local function AccumulateFrequency(target, name, data)
  local key = name .. "_" .. tostring(data)
  target[key] = (target[key] or 0) + 1
end

local function MouseoverUnit()
  -- First off, we see if it's "interesting".
  -- The original code for this filtered out critters. I don't, because critters are cute, and rare.
  if UnitExists("mouseover") and UnitIsVisible("mouseover") and not UnitIsPlayer("mouseover") and not UnitPlayerControlled("mouseover") then
    local guid = UnitGUID("mouseover")
    
    QuestHelper: Assert(#guid == 18) -- 64 bits, plus the 0x prefix
    QuestHelper: Assert(guid:sub(1, 2) == "0x")
    QuestHelper: Assert(guid:sub(5, 5) == "3")  -- It *shouldn't* be a player or a pet by the time we've gotten here. If so, something's gone wrong.
    local creatureid = guid:sub(9, 18)  -- here's our actual identifier
    
    if not recentlySeenCritters[creatureid] then
      recentlySeenCritters_Recent[creatureid] = true
      recentlySeenCritters[creatureid] = true
      
      -- register the critter here
      local cid = tonumber(creatureid:sub(1, 4), 16)
      
      if not QHCM[cid] then QHCM[cid] = {} end
      local critter = QHCM[cid]
      
      AccumulateFrequency(critter, "name", UnitName("mouseover"))
      AccumulateFrequency(critter, "level", UnitLevel("mouseover"))
      AccumulateFrequency(critter, "reaction", UnitReaction("mouseover", "player"))
      
      local minrange = InteractDistances[1]
      local maxrange = 255
      -- Now we try to derive a bound for how far away it is
      for i = #InteractDistances - 1, 1, -1 do
        if CheckInteractDistance("mouseover", i) then
          minrange = InteractDistances[i + 1]
          maxrange = InteractDistances[i]
          break
        end
      end
      QuestHelper: Assert(minrange >= 0 and minrange < 256 and maxrange >= 0 and maxrange < 256)
      Merger.Add(critter, GetLoc() .. strchar(minrange, maxrange))
      
      if #recentlySeenCritters_Recent >= 100 then
        for k, v in recentlySeenCritters_NextTrash do
          recentlySeenCritters[v] = nil
        end
        
        recentlySeenCritters_NextTrash = recentlySeenCritters_Recent
        recentlySeenCritters_Recent = {}  -- BAM, garbage collection!
      end
    end
  end
end

function QH_Collect_Monster_Init(QHCData, API)
  if not QHCData.monster then QHCData.monster = {} end
  QHCM = QHCData.monster
  
  --API.Registrar_EventHook("PLAYER_TARGET_CHANGED", OnEvent)
  --API.Registrar_EventHook("LOOT_OPENED", Looted)
  API.Registrar_EventHook("UPDATE_MOUSEOVER_UNIT", MouseoverUnit)
  
  API.Registrar_TooltipHook(Tooltipy)
  
  GetLoc = API.Callback_LocationBolusCurrent
  QuestHelper: Assert(GetLoc)
  
  Merger = API.Utility_Merger
  QuestHelper: Assert(Merger)
end
