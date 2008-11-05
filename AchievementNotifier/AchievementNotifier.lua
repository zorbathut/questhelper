--[[
Name: AchievementNotifier
Revision: 1
Author(s): Zorba (see questhelper docs)
Description:
  Provide a callback method to see when achievements have been modified.
  
  This relies on the CRITERIA_UPDATE event, which gives no actual information about which achievement it is that got tweaked. Therefore, each time the event is called, you must poll all achievements to see what has been changed (as well as store the previous values for all achievements.) On top of *that*, CRITERIA_UPDATE is frequently called multiple times consecutively, so it's best to wait until the first non-CRITERIA_UPDATE event and do the updating then. As this is all a significant amount of work for something which I suspect will be a common goal, I'm putting it in a library.

Copyright (C) 2008 Ben Wilhelm

License:
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

Note:
	This library's source code is specifically designed to work with
	World of Warcraft's interpreted AddOn system.  You have an implicit
	licence to use this library with these facilities since that is its
	designated purpose as per:
	http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

-- WARNING!!!
-- DO NOT MAKE CHANGES TO THIS LIBRARY WITHOUT FIRST CHANGING THE LIBRARY_VERSION_MAJOR
-- STRING (to something unique) OR ELSE YOU MAY BREAK OTHER ADDONS THAT USE THIS LIBRARY!!!
local LIBRARY_VERSION_MAJOR = "AchievementNotifier-0.1"
local LIBRARY_VERSION_MINOR = 1

if not DongleStub then error(LIBRARY_VERSION_MAJOR .. " requires DongleStub.") end
if not DongleStub:IsNewerVersion(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR) then return end

local AchievementNotifier = {}

AchievementNotifier.AchievementCallbacks = {}

function AchievementNotifier:GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end

function TO(text)
  DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffffcc00AchievementNotifier: |r%s", text))
end

--X 0 is a monster kill, asset is the monster ID
--X 1 is winning PvP objectives in a thorough manner (holding all bases, controlling all flags)
--X 7 is weapon skill, asset is probably a skill ID of some sort
--X 8 is another achievement, asset is achievement ID
--X 9 is completing quests globally
--X 10 is completing a daily quest every day
--X 11 is completing quests in specific areas
--X 14 is completing daily quests
--X 27 is a quest, asset is quest ID
--X 28 is getting a spell cast on you, asset is a spell ID
--X 29 is casting a spell (often crafting), asset is a spell ID
--X 30 is PvP objectives (flags, assaulting, defending)
--X 31 is PvP kills in battleground PvP locations
--X 32 is winning ranked arena matches in specific locations (asset is probably a location ID)
--X 34 is the Squashling (owning a specific pet?), asset is the spell ID
--X 35 is PvP kills while under the influence of something
--X 36 is acquiring items (soulbound), asset is an item ID
--X 37 is winning arenas
--X 41 is eating or drinking a specific item, asset is item ID
--X 42 is fishing things up, asset is item ID
--X 43 is exploration, asset is a location ID?
--X 45 is purchasing 7 bank slots
--X 46 is exalted rep, asset is presumably some kind of faction ID
--X 47 is 5 reputations to exalted
--X 49 is equipping items, asset is a slot ID (quality is presumably encoded into flags)
--X 52 is killing specific classes of player
--X 53 is kill-a-given-race, asset is race ID?
-- 54 is using emotes on targets, asset ID is likely the emote ID
--X 56 is being a wrecking ball in Alterac Valley
--X 62 is getting gold from quest rewards
--X 67 is looting gold
-- 68 is reading books
-- 70 is killing players in world PvP locations
-- 72 is fishing things from schools or wreckage
--X 73 is killing Mal'Ganis on Heroic. Why? Who can say.
--X 75 is obtaining mounts
-- 109 is fishing, either in general or in specific locations
-- 110 is casting spells on specific targets, asset ID is the spell ID
--X 112 is learning cooking recipes
--X 113 is honorable kills
local achievement_type_blacklist = {}
for _, v in pairs({0, 1, 7, 8, 9, 10, 11, 14, 27, 28, 29, 30, 31, 32, 34, 35, 36, 37, 41, 42, 43, 45, 46, 47, 49, 52, 53, 56, 62, 67, 73, 75, 112, 113}) do
  achievement_type_blacklist[v] = true
end

local achievement_list = {}

--local crittypes = {}
--QuestHelper_ZorbaForgotToRemoveThis = {}

local function registerAchievement(id)
  --if db.achievements[id] then return end
  
  local _, title, _, complete = GetAchievementInfo(id)
  --TO(string.format("Registering %d (%s)", id, title))
  local prev = GetPreviousAchievement(id)
  local record = false
  
  --[[
  db.achievements[id] = {
    previous = prev,
    compete = complete,
    name = title,
    criterialist = {}
  }
  local dbi = db.achievements[id]
  ]]
  
  if prev then
    registerAchievement(prev)
  end
  
  --[[
  local known = {}
  known[0] = true
  known[1] = true
  known[7] = true
  known[8] = true
  known[29] = true
  known[110] = true
  ]]
  
  local critcount = GetAchievementNumCriteria(id)
  if critcount == 0 then record = true end
  
  --TO(string.format("%d criteria", crit))
  for i = 1, critcount do
    local crit_name, crit_type, crit_complete, crit_quantity, crit_reqquantity, _, _, crit_asset, _, crit_id = GetAchievementCriteriaInfo(id, i)
    --[[local mega = {GetAchievementCriteriaInfo(id, i)}
    if mega[2] == 0 then
      TO(string.format("%s: %s, %s, %s, %s, %s, %s, %s, %s, %s, %s", tostring(title), tostring(mega[1]), tostring(mega[2]), tostring(mega[3]), tostring(mega[4]), tostring(mega[5]), tostring(mega[6]), tostring(mega[7]), tostring(mega[8]), tostring(mega[9]), tostring(mega[10])))
    end]]
    
    --if not QuestHelper_ZorbaForgotToRemoveThis[string.format("%d", crit_type)] then QuestHelper_ZorbaForgotToRemoveThis[string.format("%d", crit_type)] = {} end
    --QuestHelper_ZorbaForgotToRemoveThis[string.format("%d", crit_type)][title .. " --- " .. mega[1]] = crit_asset
    
    --[[
    table.insert(dbi.criterialist, crit_id)
    assert(not db.criteria[crit_id])
    crittypes[crit_type] = (crittypes[crit_type] or 0) + 1]]
    
    if not achievement_type_blacklist[crit_type] then record = true end
    
    --[[
    db.criteria[crit_id] = {
      name = crit_name,
      type = crit_type,
      complete = crit_complete,
      progress = crit_quantity,
      progress_total = crit_reqquantity,
      asset = crit_asset,
    }]]
  end
  
  TO(string.format("%d: %s", id, tostring(record)))
  if record then achievement_list[id] = true end
end

function createAchievementList()
  TO("CAL")
  for _, catid in pairs(GetCategoryList()) do
    for d = 1, GetCategoryNumAchievements(catid) do
      registerAchievement(GetAchievementInfo(catid, d), db)
    end
  end
end

local function retrieveAchievement(id, db)
  local _, _, _, complete = GetAchievementInfo(id)
  --TO(string.format("Registering %d (%s)", id, title))
  
  db.achievements[id] = {
    complete = complete,
    criterialist = {}
  }
  local dbi = db.achievements[id]
  
  local critcount = GetAchievementNumCriteria(id)
  
  --TO(string.format("%d criteria", crit))
  for i = 1, critcount do
    local _, _, crit_complete, crit_quantity, crit_reqquantity, _, _, _, _, crit_id = GetAchievementCriteriaInfo(id, i)

    table.insert(dbi.criterialist, crit_id)
    db.criteria[crit_id] = {
      complete = crit_complete,
      progress = crit_quantity,
    }
  end
end

function getAchievementDB()
  local db = {}
  db.achievements = {}
  db.criteria = {}
  
  for k in pairs(achievement_list) do
    retrieveAchievement(k, db)
  end
  
  return db
end

local function activate(newinstance, oldinstance)
  if oldinstance then
    newinstance.AchievementCallbacks = oldinstance.AchievementCallbacks -- yoink
  end
  
  createAchievementList()
  newinstance.AchievementDB = getAchievementDB() -- 'coz we're lazy
  
  TO("Created shit!")
end

local needsUpdate = true

local function OnEvent(frame, event)
  TO(event)
  needsUpdate = true
end

local function OnUpdate()
  if needsUpdate and AchievementNotifier.AchievementDB then
    needsUpdate = false -- This prevents spamming.
    
    local newADB = getAchievementDB()
    local oldADB = AchievementNotifier.AchievementDB
    TO(string.format("akount %d %d", QuestHelper:TableSize(newADB.achievements), QuestHelper:TableSize(newADB.criteria)))
    
    for k, v in pairs(newADB.achievements) do
      if v.complete ~= oldADB.achievements[k].complete then
        assert(v.complete and not oldADB.achievements[k].complete)
        TO(string.format("Achievement complete, %s", select(2, GetAchievementInfo(k))))
      end
    end
    
    for k, v in pairs(newADB.criteria) do
      if v.complete ~= oldADB.criteria[k].complete then
        assert(v.complete and not oldADB.criteria[k].complete)
        TO(string.format("Criteria complete, %d", k))
        TO(string.format("Criteria complete, %s", select(1, GetAchievementCriteriaInfo(k))))
      elseif v.progress > oldADB.criteria[k].progress then
        TO(string.format("Criteria progress, %d", k))
        TO(string.format("Criteria progress, %s", select(1, GetAchievementCriteriaInfo(k))))
      end
    end
    
    TO("update!")
    AchievementNotifier.AchievementDB = newADB
  end
end

AchievementNotifier.frame = CreateFrame("Frame")

AchievementNotifier.frame:UnregisterAllEvents()
AchievementNotifier.frame:RegisterEvent("CRITERIA_UPDATE")
AchievementNotifier.frame:RegisterEvent("ACHIEVEMENT_EARNED")
AchievementNotifier.frame:RegisterEvent("ZONE_CHANGED")
AchievementNotifier.frame:RegisterEvent("ZONE_CHANGED_INDOORS")
AchievementNotifier.frame:RegisterEvent("MINIMAP_PING")
AchievementNotifier.frame:SetScript("OnEvent", OnEvent)
AchievementNotifier.frame:SetScript("OnUpdate", OnUpdate)

AchievementNotifier.frame:Show()

--SlashCmdList["ACHIEVEMENT_NOTIFIER"] = SlashCommand;
--ACHIEVEMENT_NOTIFIER1 = "/an";

DongleStub:Register(AchievementNotifier, activate)

--[[ Data structure notes

{
  "achievement" = {
    achievementid = {
      name = "name"
      complete = false/true
      criterialist = { a, b, c }
    }
  }
  "criteria" = {
    criteriaid = {
      name = "name"
      progress = 5
      progress_total = 10
      complete = false/true
    }
  }
}


notifications/hooks:
* Criteria changed
* Progress made (subset of criteria changed)
* Achievement completed (subset of progress made)

* New achievement
]]
