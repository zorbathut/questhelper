QuestHelper_File["collect_loot.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_loot.lua"] == "Development Version" then debug_output = true end

local QHC

local GetMonsterUID
local GetMonsterType

local Patterns

local members = {}
local members_count = 0
local members_refs = {} -- "raid6" and the like

local function MembersUpdate()
  -- We want to keep track of exactly who is in a group with this player, so we can watch for combat messages involving them, so we can see who's been tapped, so we can record the right deaths, so we can know who the player should be able to loot.
  -- I hate my life.
  -- >:(
  
  local alone = false
  
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
    alone = true
  end
  
  if GetLootMethod() == "master" and not alone then members = {} members_refs = {} end -- We're not going to bother trying to deal with master loot right now - it's just too different and I just don't care enough.
  
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
local function CombatLogEvent(_, event, sourceguid, _, _, destguid, _, _, _, spellname)
  -- There's many things that are handled here.
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
    
    if monsterstate[destguid] and monstertimeout[destguid] > GetTime() and monsterstate[destguid] == MS_TAPPED_US and members_count > 0 then -- yaaay
      local type = GetMonsterType(destguid)
      if not QHC.monster[type] then QHC.monster[type] = {} end
      QHC.monster[type].kills = (QHC.monster[type].kills or 0) + 1 / members_count  -- Hopefully, most people loot their kills. Divide by members_count 'cause there's a 1/members chance that we get to loot.
      
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

-- Logic behind this module:
-- Watch for the spell to be sent
-- Watch for it to start
-- Check out the combat log and see what GUID we get
-- If the GUID is null, we're targeting an object, otherwise, we're targeting a critter
-- Wait for spell to succeed
-- If anything doesn't synch up, or the spell is interrupted, nil out all these items.
-- We've got a little special case for pickpocketing, because people often use macros, so we detect that case specifically.

local PP_PHASE_IDLE
local PP_PHASE_SENT
local PP_PHASE_COMPLETE

local pickpocket_phase = PP_PHASE_IDLE
local pickpocket_target
local pickpocket_otarget_guid
local pickpocket_timestamp

local function pp_reset()
  pickpocket_target, pickpocket_otarget_guid, pickpocket_timestamp, pickpocket_phase = nil, nil, nil, PP_PHASE_IDLE
end
pp_reset()

local function PPSent(player, spell, _, target)
  if player ~= "player" then return end
  if spell ~= "Pick Pocket" then return end
  if UnitName("target") ~= target then return end -- DENY
  
  pickpocket_timestamp, pickpocket_target, pickpocket_otarget_guid, pickpocket_phase = GetTime(), target, UnitGUID("target"), PP_PHASE_SENT
end

local function PPSucceed(player, spell, rank)
  if player ~= "player" then return end
  if spell ~= "Pick Pocket" then return end
  
  if pickpocket_phase ~= PP_PHASE_SENT and (not pickpocket_otarget_guid or last_timestamp + 1 < GetTime()) then
    pp_reset()
    return
  end
  
  pickpocket_timestamp, pickpocket_phase = GetTime(), PP_PHASE_COMPLETE
end


-- Here's the segment for longer spells. There aren't any instant spells we currently care about, besides pickpocketing. This will probably change eventually (arrows in the DK starting zone?)

local LAST_PHASE_IDLE = 0
local LAST_PHASE_SENT = 1
local LAST_PHASE_START = 2
local LAST_PHASE_COMBATLOG = 3
local LAST_PHASE_COMPLETE = 4

local last_phase = LAST_PHASE_IDLE
local last_spell
local last_rank
local last_target
local last_target_guid
local last_otarget_guid
local last_timestamp
local last_succeed = false

local function last_reset()
  last_timestamp, last_spell, last_rank, last_target, last_otarget_guid, last_target_guid, last_succeed, last_phase = nil, nil, nil, nil, nil, false, LAST_PHASE_IDLE
end
last_reset()

-- This all doesn't work with instant spells. Luckily, I don't care about instant spells (yet).
local function SpellSent(player, spell, rank, target)
  if player ~= "player" then return end
  
  last_timestamp, last_spell, last_rank, last_target, last_otarget_guid, last_target_guid, last_succeed, last_phase = GetTime(), spell, rank, target, UnitGUID("target"), nil, false, LAST_PHASE_SENT
  
  QuestHelper:TextOut(string.format("ss %s", spell))
end

local function SpellStart(player, spell, rank)
  if player ~= "player" then return end
  
  if spell ~= last_spell or rank ~= last_rank or last_target_guid or last_phase ~= LAST_PHASE_SENT or last_timestamp + 1 < GetTime() then
    last_reset()
  else
    QuestHelper:TextOut(string.format("sst %s", spell))
    last_timestamp, last_phase = GetTime(), LAST_PHASE_START
  end
end

local function SpellCombatLog(_, event, sourceguid, _, _, destguid, _, _, _, spellname)
  if event ~= "SPELL_CAST_START" then return end
  
  if sourceguid ~= UnitGUID("player") then return end
  
  QuestHelper:TextOut(string.format("cle_ss enter %s %s %s %s", tostring(spellname ~= last_spell), tostring(not last_target), tostring(not not last_target_guid), tostring(last_timestamp + 1 < GetTime())))
  
  if spellname ~= last_spell or not last_target or last_target_guid or last_timestamp + 1 < GetTime() then
    last_reset()
    return
  end
  
  QuestHelper:TextOut("cle_ss enter")
  
  if last_phase ~= LAST_PHASE_START  then
    last_reset()
    return
  end
  
  QuestHelper:TextOut(string.format("cesst %s", spellname))
  last_timestamp, last_target_guid, last_phase = GetTime(), destguid, LAST_PHASE_COMBATLOG
  
  if last_target_guid ~= last_otarget_guid and not (last_target_guid == "0x0000000000000000" and not last_otarget_guid) then last_reset() return end
  
  if last_phase == LAST_PHASE_COMPLETE then
    QuestHelper:TextOut(string.format("spell succeeded, casting %s %s on %s/%s", last_spell, last_rank, last_target, last_target_guid))
  end
end

local function SpellSucceed(player, spell, rank)
  if player ~= "player" then return end
  
  QuestHelper:TextOut(string.format("sscu enter %s %s %s %s %s", tostring(last_spell), tostring(last_target), tostring(last_rank), tostring(spell), tostring(rank)))
  
  if not last_spell or not last_target or last_spell ~= spell or last_rank ~= rank then
    last_reset()
    return
  end
  
  QuestHelper:TextOut("sscu enter")
  
  if last_phase ~= LAST_PHASE_COMBATLOG and (not last_target_guid or last_timestamp + 10 < GetTime()) then
    last_reset()
    return
  end
  
  QuestHelper:TextOut(string.format("sscu %s, %d, %s, %s", spell, last_phase, tostring(last_phase == LAST_PHASE_SENT), tostring((last_phase == LAST_PHASE_SENT) and LAST_PHASE_SHORT_SUCCEEDED)))
  last_timestamp, last_succeed, last_phase = GetTime(), true, LAST_PHASE_COMPLETE
  QuestHelper:TextOut(string.format("last_phase %d", last_phase))
  
  if last_phase == LAST_PHASE_COMPLETE then
    QuestHelper:TextOut(string.format("spell succeeded, casting %s %s on %s/%s", last_spell, last_rank, last_target, last_target_guid))
  end
end

local function SpellInterrupt(player, spell, rank)
  if player ~= "player" then return end
  
  -- I don't care what they were casting, they're certainly not doing it now
  QuestHelper:TextOut(string.format("si %s", spell))
  last_reset()
end
  

local function LootOpened()
  -- First off, we try to figure out where the hell these items came from.
  
  --QuestHelper:TextOut(string.format("%s %s %s", tostring(last_phase == LAST_PHASE_COMPLETE), tostring(last_spell == "Mining"), tostring(last_timestamp + 1 > GetTime())))
  --QuestHelper:TextOut(string.format("%s %s %s", tostring(last_phase == LAST_PHASE_COMPLETE), tostring(last_spell == "Mining"), tostring(last_timestamp + 1 > GetTime())))
  
  if last_timestamp then QuestHelper:TextOut(string.format("%s %s %s", tostring(last_phase == LAST_PHASE_COMPLETE), tostring(last_spell == "Mining"), tostring(last_timestamp + 1 > GetTime()))) else QuestHelper:TextOut("timmy") end
  if pickpocket_phase == PP_PHASE_COMPLETE then QuestHelper:TextOut(string.format("%s", tostring(pickpocket_timestamp))) else QuestHelper:TextOut("nein") end
  
  if IsFishingLoot() then
    -- It's fishing loot. Yay! This was the only easy one.
    QuestHelper:TextOut("Fishing loot")
  elseif pickpocket_phase == PP_PHASE_COMPLETE and pickpocket_timestamp + 1 > GetTime() and UnitGUID("target") == pickpocket_otarget_guid then
    QuestHelper:TextOut(string.format("Pickpocketing from %s/%s", pickpocket_target, pickpocket_otarget_guid))
  elseif last_phase == LAST_PHASE_COMPLETE and last_spell == "Mining" and last_timestamp + 1 > GetTime() then
    -- Mining. Add similar tests for skinning, herbing, salvaging. Also, add the various translations.
    QuestHelper:TextOut(string.format("Mining from %s", last_target))
  -- We also want to test:
  -- Disenchanting
  -- Prospecting
  -- Using an entity
  -- Opening a container
  elseif UnitGUID("target") and monsterstate[UnitGUID("target")] == MS_TAPPED_LOOTABLE and monstertimeout[UnitGUID("target")] > GetTime() then
    -- Monster is lootable, so we loot the monster
    -- Todo: add a check that we didn't just cast a spell *after* the monster died? If so, we want might to kick out the monster loot.
    QuestHelper:TextOut(string.format("Monsterloot from %s", UnitGUID("target")))
    monsterstate[UnitGUID("target")] = nil
    monstertimeout[UnitGUID("target")] = nil
    monsterrefresh[UnitGUID("target")] = nil
  else
    QuestHelper:TextOut("Who knows")
  end
  
  
  
  local items = {}
  items.gold = 0
  for i = 1, GetNumLootItems() do
    _, name, quant, _ = GetLootSlotInfo(i)
    link = GetLootSlotLink(i)
    if quant == 0 then
      -- moneys
      local _, _, amount = string.find(name, Patterns.GOLD_AMOUNT)
      if amount then items.gold = items.gold + tonumber(amount) * 10000 end
      
      local _, _, amount = string.find(name, Patterns.SILVER_AMOUNT)
      if amount then items.gold = items.gold + tonumber(amount) * 100 end
      
      local _, _, amount = string.find(name, Patterns.COPPER_AMOUNT)
      if amount then items.gold = items.gold + tonumber(amount) * 1 end
      
      QuestHelper:TextOut(tostring(amount))
    else
      local itype = GetItemType(link)
      items[itype] = (items[itype] or 0) + quant
    end
  end
  
  for k, v in pairs(items) do
    QuestHelper:TextOut(string.format("%s: %d", tostring(k), v))
  end
end

function QH_Collect_Loot_Init(QHCData, API)
  QHC = QHCData
  
  if not QHC.monster then QHC.monster = {} end
  
  API.Registrar_EventHook("RAID_ROSTER_UPDATE", MembersUpdate)
  API.Registrar_EventHook("PARTY_MEMBERS_CHANGED", MembersUpdate)
  API.Registrar_EventHook("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)

  API.Registrar_EventHook("UNIT_SPELLCAST_SENT", PPSent)
  API.Registrar_EventHook("UNIT_SPELLCAST_SUCCEEDED", PPSucceed)
  
  API.Registrar_EventHook("UNIT_SPELLCAST_SENT", SpellSent)
  API.Registrar_EventHook("UNIT_SPELLCAST_START", SpellStart)
  API.Registrar_EventHook("COMBAT_LOG_EVENT_UNFILTERED", SpellCombatLog)
  API.Registrar_EventHook("UNIT_SPELLCAST_SUCCEEDED", SpellSucceed)
  API.Registrar_EventHook("UNIT_SPELLCAST_INTERRUPTED", SpellInterrupt)
  
  API.Registrar_EventHook("LOOT_OPENED", LootOpened)
  --[[
  API.Registrar_EventHook("PLAYER_TARGET_CHANGED", TargetChanged)
  API.Registrar_EventHook("LOOT_OPENED", LootOpened)
  API.Registrar_EventHook("LOOT_SLOT_CLEARED", LootTaken)
  API.Registrar_EventHook("LOOT_CLOSED", LootClosed)
  API.Registrar_EventHook("ITEM_PUSH", ItemReceived)

  ]]
  
  MembersUpdate() -- to get self
  
  GetMonsterUID = API.Utility_GetMonsterUID
  GetMonsterType = API.Utility_GetMonsterType
  QuestHelper: Assert(GetMonsterUID)
  QuestHelper: Assert(GetMonsterType)
  
  Patterns = API.Patterns
  API.Patterns_RegisterNumber("GOLD_AMOUNT")
  API.Patterns_RegisterNumber("SILVER_AMOUNT")
  API.Patterns_RegisterNumber("COPPER_AMOUNT")
  
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
