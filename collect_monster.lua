QuestHelper_File["collect_monster.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_monster.lua"] == "Development Version" then debug_output = true end

local QHCM

local GetLoc
local Merger
local Patterns

local logon = GetTime() -- Because I'm incredibly paranoid, I'm waiting fifteen minutes after logon to assume they're not drunk.
local drunk_logon = true
local drunk_message = false

local function SystemMessage(arg, arg2, arg3)
  if strfind(arg, Patterns["DRUNK_MESSAGE_SELF2"]) or strfind(arg, Patterns["DRUNK_MESSAGE_SELF3"]) or strfind(arg, Patterns["DRUNK_MESSAGE_SELF4"]) or strfind(arg, Patterns["DRUNK_MESSAGE_ITEM_SELF2"]) or strfind(arg, Patterns["DRUNK_MESSAGE_ITEM_SELF3"]) or strfind(arg, Patterns["DRUNK_MESSAGE_ITEM_SELF4"]) then
    drunk_message = true
  elseif strfind(arg, Patterns["DRUNK_MESSAGE_SELF1"]) or strfind(arg, Patterns["DRUNK_MESSAGE_ITEM_SELF1"]) then
    drunk_message = false
  end
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
  if logon and logon + 60 * 15 < GetTime() then
    logon = nil
    drunk_logon = false
  end
  
  -- First off, we see if it's "interesting".
  -- The original code for this filtered out critters. I don't, because critters are cute, and rare.
  if UnitExists("mouseover") and UnitIsVisible("mouseover") and not UnitIsPlayer("mouseover") and not UnitPlayerControlled("mouseover") then
    local guid = UnitGUID("mouseover")
    
    QuestHelper: Assert(#guid == 18, "guid len " .. guid) -- 64 bits, plus the 0x prefix
    QuestHelper: Assert(guid:sub(1, 2) == "0x", "guid 0x-prefix " .. guid)
    QuestHelper: Assert(guid:sub(5, 5) == "3" or guid:sub(5, 5) == "5", "guid 3-prefix " .. guid)  -- It *shouldn't* be a player or a pet by the time we've gotten here. If so, something's gone wrong.
    local creatureid = guid:sub(9, 18)  -- here's our actual identifier
    
    if not recentlySeenCritters[creatureid] then
      recentlySeenCritters_Recent[creatureid] = true
      recentlySeenCritters[creatureid] = true
      
      -- register the critter here
      local cid = tonumber(creatureid:sub(1, 4), 16)
      
      if not QHCM[cid] then QHCM[cid] = {} end
      local critter = QHCM[cid]
      
      AccumulateFrequency(critter, "name", UnitName("mouseover"))
      AccumulateFrequency(critter, "reaction", UnitReaction("mouseover", "player"))
      if not drunk_logon and not drunk_message then
        AccumulateFrequency(critter, "level", UnitLevel("mouseover"))
      end
      
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
  
  API.Registrar_EventHook("UPDATE_MOUSEOVER_UNIT", MouseoverUnit)
  API.Registrar_EventHook("CHAT_MSG_SYSTEM", SystemMessage)
  
  Patterns = API.Patterns
  QuestHelper: Assert(Patterns)
  
  API.Patterns_Register("DRUNK_MESSAGE_SELF1", "|c.*|r")
  API.Patterns_Register("DRUNK_MESSAGE_SELF2", "|c.*|r")
  API.Patterns_Register("DRUNK_MESSAGE_SELF3", "|c.*|r")
  API.Patterns_Register("DRUNK_MESSAGE_SELF4", "|c.*|r")
  API.Patterns_Register("DRUNK_MESSAGE_ITEM_SELF1", "|c.*|r")
  API.Patterns_Register("DRUNK_MESSAGE_ITEM_SELF2", "|c.*|r")
  API.Patterns_Register("DRUNK_MESSAGE_ITEM_SELF3", "|c.*|r")
  API.Patterns_Register("DRUNK_MESSAGE_ITEM_SELF4", "|c.*|r")

  GetLoc = API.Callback_LocationBolusCurrent
  QuestHelper: Assert(GetLoc)
  
  Merger = API.Utility_Merger
  QuestHelper: Assert(Merger)
end
