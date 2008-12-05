QuestHelper_File["collect_loot.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_loot.lua"] == "Development Version" then debug_output = true end

local QHC

local GetMonsterUID
local GetMonsterType

local members = {}
local members_count = 0
local members_refs = {} -- "raid6" and the like

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
      local ite = string.format("raid%d", i)
      local gud = UnitGUID(ite)
      if gud then
        members[gud] = true
        table.insert(members_refs, ite)
        QuestHelper:TextOut(string.format("raid member %s added", UnitName(ite)))
      end
    end
  elseif GetNumPartyMembers() > 0 then
    -- we is in a party
    for i = 1, 4 do
      local ite = string.format("party%d", i)
      local gud = UnitGUID(ite)
      if gud then
        members[gud] = true
        table.insert(members_refs, ite)
        QuestHelper:TextOut(string.format("party member %s added", UnitName(ite)))
      end
    end
    members[UnitGUID("player")] = true
    table.insert(members_refs, "player")
    QuestHelper:TextOut(string.format("player %s added", UnitName("player"))) 
  else
    -- we is alone ;.;
    if UnitGUID("player") then members[UnitGUID("player")] = true end -- it's possible that we haven't logged in entirely yet
    if not UnitGUID("player") then QuestHelper:TextOut("dbg lol") end
    table.insert(members_refs, "player")
    QuestHelper:TextOut(string.format("player %s added", UnitName("player"))) 
  end
  
  if GetLootMethod() == "master" then members = {} members_refs = {} end -- We're not going to bother trying to deal with master loot right now - it's just too different and I just don't care enough.
  
  for _, _ in pairs(members) do members_count = members_count + 1 end -- lulz
end

local MS_TAPPED_US = 1
local MS_TAPPED_OTHER = 2
local MS_TAPPED_LOOTABLE = 3

local monsterstate = {}
local monsterrefresh = {}
local monstertimeout = {}

-- This all does something quite horrible.
-- Some monsters don't become lootable when they're killed and didn't drop anything. We need to record this so we can get real numbers for them. 
-- Unfortunately, we can't just record when "something" is killed. We have to record when "our group" killed it, so we know that there *was* a chance of looting it.
-- As such, we need to check for monster deaths that the player may never have actually targeted. It gets, to put it mildly, grim, and unfortunately we'll never be able to solve it entirely.
-- Worse, we need to *not* record item drops for things that we never actually "saw" but that were lootable anyway, because if we do, we bias the results towards positive (i.e. if we AOE ten monsters down, and two of them drop, and we loot those, that's 2/2 if we record the drops, and 0/0 if we don't, while what we really want is 2/10. 0/0 is at least "not wrong".)
local function CombatLogEvent(_, event, sourceguid, _, _, destguid)
  -- There's two things that are handled here.
  -- First, if there's any damage messages coming either to or from a party member, we check to see if that monster is tapped by us. If it's tapped, we cache the value for 15 seconds, expiring entirely in 30.
  -- Second, there's the Death message. If it's tapped by us, increases the kill count by 1/partymembers and changes its state to lootable.
  if event ~= "UNIT_DIED" then
    -- Something has been attacked by something, maybe.
    if not string.find(event, "_DAMAGE$") then return end -- We only care about something punching something else.
    
    local target
    if members[sourceguid] then target = destguid elseif members[destguid] then target = sourceguid end -- If one of the items is in our party, the other is our target.
    if not target then return end   -- If we don't have a target, then nobody is in our party, and we don't care.
    
    if monsterrefresh[target] and monsterrefresh[target] > GetTime() then return end -- we already have fresh data, so we're good
    
    -- Now comes the tricky part. We can't just look at the target because we're not allowed to target by GUID. So we iterate through all the party/raid members, and their pets, and hope *someone* has it targeted. Luckily, we can stop once we find someone who does.
    local targ
    for _, v in pairs(members_refs) do
      targ = v .. "target"   if UnitGUID(targ) == target then break end
      targ = v .. "pettarget"   if UnitGUID(targ) == target then break end
      targ = nil
    end
    
    if not targ then return end -- Well, nobody seems to be targeting it. That's . . . odd, and annoying. We'll take a look at it next combat message, I suppose.
    
    -- Okay. So we know who's targeting it. Now, let's see who has it tapped, if anyone.
    if not UnitIsTapped(targ) then
      -- Great. Nobody is. That is just *great*. Look how exuberant I feel at this moment.
      monsterstate[target] = nil
      monsterrefresh[target] = nil
      monstertimeout[target] = nil
      QuestHelper:TextOut(string.format("Monster ignorified"))
    else
      -- We know someone is, so we're going to set up our caching . . .
      monsterrefresh[target] = GetTime() + 15
      monstertimeout[target] = GetTime() + 30
      monsterstate[target] = (UnitIsTappedByPlayer(targ) and not UnitIsTrivial(targ)) and MS_TAPPED_US or MS_TAPPED_OTHER -- and figure out if it's us. Or if it's trivial. we ignore it if it's trivial, since it's much less likely to be looted and that could throw off our numbers
      QuestHelper:TextOut(string.format("Monster %s set to %s", target, UnitIsTappedByPlayer(targ) and "MS_TAPPED_US" or "MS_TAPPED_OTHER"))
    end
    
    -- DONE
  else
    -- It's dead. Hooray!
    
    if monsterstate[destguid] and monstertimeout[destguid] > GetTime() and monsterstate[destguid] == MS_TAPPED_US then -- yaaay
      local type = GetMonsterType(destguid)
      if not QHC.monster[type] then QHC.monster[type] = {} end
      QHC.monster[type].kills = (QHC.monster[type].kills or 0) + 1  -- Hopefully, most people loot their kills.
      
      monsterstate[destguid] = MS_TAPPED_LOOTABLE
      monsterrefresh[destguid] = GetTime() + 600
      monstertimeout[destguid] = GetTime() + 600
      QuestHelper:TextOut(string.format("Tapped monster %s slain, set to lootable", destguid))
    else
      monsterstate[destguid] = nil
      monsterrefresh[destguid] = nil
      monstertimeout[destguid] = nil
      QuestHelper:TextOut(string.format("Untapped monster %s slain, cleared", destguid))
    end
  end
end

function QH_Collect_Loot_Init(QHCData, API)
  QHC = QHCData
  
  if not QHC.monster then QHC.monster = {} end
  
  API.Registrar_EventHook("RAID_ROSTER_UPDATE", MembersUpdate)
  API.Registrar_EventHook("PARTY_MEMBERS_CHANGED", MembersUpdate)
  API.Registrar_EventHook("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
  --[[
  API.Registrar_EventHook("PLAYER_TARGET_CHANGED", TargetChanged)
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
  
  GetMonsterUID = API.Utility_GetMonsterUID
  GetMonsterType = API.Utility_GetMonsterType
  QuestHelper: Assert(GetMonsterUID)
  QuestHelper: Assert(GetMonsterType)
  
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
