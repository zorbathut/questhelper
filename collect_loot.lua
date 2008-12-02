QuestHelper_File["collect_loot.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_loot.lua"] == "Development Version" then debug_output = true end

local QHC

local members = {}
local members_count = 0

local function MembersUpdate()
  -- We want to keep track of exactly who is in a group with this player, so we can watch for combat messages involving them, so we can see who's been tapped, so we can record the right deaths, so we can know who the player should be able to loot.
  -- I hate my life.
  -- >:(
  QuestHelper:TextOut("MU start")
  members = {} -- we burn a table every time this updates, but whatever
  members_count = 0
  if GetNumRaidMembers() > 0 then
    -- we is in a raid
    for i = 1, 40 do
      local gud = UnitGUID(string.format("raid%d", i))
      if gud then members[gud] = true QuestHelper:TextOut(string.format("raid member %s added", UnitName(string.format("raid%d", i)))) end
    end
  elseif GetNumPartyMembers() > 0 then
    -- we is in a party
    for i = 1, 4 do
      local gud = UnitGUID(string.format("party%d", i))
      if gud then members[gud] = true QuestHelper:TextOut(string.format("party member %s added", UnitName(string.format("party%d", i)))) end
    end
    members[UnitGUID("player")] = true
    QuestHelper:TextOut(string.format("player %s added", UnitName("player"))) 
  else
    -- we is alone ;.;
    members[UnitGUID("player")] = true
    QuestHelper:TextOut(string.format("player %s added", UnitName("player"))) 
  end
  
  for _, _ in pairs(members) do members_count = members_count + 1 end -- lulz
end

local MS_TAPPED_US = 1
local MS_TAPPED_OTHER = 2
local MS_LOOTABLE = 3

local monsterstate = {}

local function CombatLogEvent(_, event, sourceguid, _, _, destguid)
  -- There's two things that are handled here.
  -- First, if there's any damage messages coming either to or from a party member, we check to see if that monster is tapped by us. If it's tapped, we cache the value for 15 seconds, expiring entirely in 30.
  -- Second, there's the Death message. If it's tapped by us, increases the kill count by 1/partymembers and changes its state to lootable.
  --if event ~= 
  
  
end

local function MouseoverUnit()
  -- Again, we see if it's a normal, useful monster.
  if UnitExists("mouseover") and UnitIsVisible("mouseover") and not UnitIsPlayer("mouseover") and not UnitPlayerControlled("mouseover") then
    local guid = UnitGUID("mouseover")
    
    QuestHelper: Assert(#guid == 18, "guid len " .. guid) -- 64 bits, plus the 0x prefix
    QuestHelper: Assert(guid:sub(1, 2) == "0x", "guid 0x-prefix " .. guid)
    QuestHelper: Assert(guid:sub(5, 5) == "3" or guid:sub(5, 5) == "5", "guid 3-prefix " .. guid)  -- It *shouldn't* be a player or a pet by the time we've gotten here. If so, something's gone wrong.
    local creatureid = guid:sub(9, 18)  -- here's our actual identifier
    
    -- more to come
  end
end

function QH_Collect_Loot_Init(QHCData, API)
  QHC = QHCData
  
  
  API.Registrar_EventHook("RAID_ROSTER_UPDATE", MembersUpdate)
  API.Registrar_EventHook("PARTY_MEMBERS_CHANGED", MembersUpdate)
  API.Registrar_EventHook("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
  --[[
  API.Registrar_EventHook("UPDATE_MOUSEOVER_UNIT", MouseoverUnit)
  API.Registrar_EventHook("LOOT_OPENED", LootOpened)
  API.Registrar_EventHook("LOOT_SLOT_CLEARED", LootTaken)
  API.Registrar_EventHook("LOOT_CLOSED", LootClosed)
  API.Registrar_EventHook("ITEM_PUSH", ItemReceived)
  API.Registrar_EventHook("UNIT_SPELLCAST_START", SpellStart)
  API.Registrar_EventHook("UNIT_SPELLCAST_SUCCEEDED", SpellSucceed)
  API.Registrar_EventHook("UNIT_SPELLCAST_INTERRUPTED", SpellSucceed)
  API.Registrar_EventHook("UNIT_SPELLCAST_STOP", SpellStop)
  ]]
  
  MembersUpdate() -- to get self
  
  -- What I want to know is whether it was tagged by me or my group when dead
  -- Check target-of-each-groupmember? Once we see him tapped once, and by us, it's probably sufficient.
  -- Notes:
  --[[
  
  COMBAT_LOG_EVENT_UNFILTERED arg2 UNIT_DIED, PLAYER_TARGET_CHANGED, LOOT_OPENED, (LOOT_CLOSED, [LOOT_SLOT_CLEARED, ITEM_PUSH, CHAT_MSG_LOOT]), PLAYER_TARGET_CHANGED, SPELLCAST_SENT, SPELLCAST_START, SUCCEEDED/INTERRUPTED, STOP, LOOT_OPENED (etc)
  
  ITEM_PUSH can happen after LOOT_CLOSED, but it still happens.
  Between LOOT_OPENED and LOOT_CLOSED, the lootable target is still targeted. Unsure what happens when looting items. LOOT_CLOSED triggers first if we target someone else.
  ITEM_PUSH happens, then CHAT_MSG_LOOT. CHAT_MSG_LOOT includes quite a lot of potentially useful arguments.
  PLAYER_TARGET_CHANGED before either looting or skinning.
  SPELLCAST_SENT, SPELLCAST_START, SUCCEEDED/INTERRUPTED, STOP in that order. Arg4 on SENT seems to be the target's name. Arg4 on the others appears to be a unique identifier.
  When started, we target the right thing. After that, we don't seem to. Check the combat log.
  
  ]]
end
