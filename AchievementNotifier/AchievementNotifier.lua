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
                                
local function getAchievementDB()
  local db = {}
  db.achievements = {}
  db.criteria = {}
  TO(string.format("ASS DB"))
  
  local function registerAchievement(id, db)
    if db[id] then return end
    
    db[id] = {}
    dbi = db[id]
    
    local _, title, _, complete = GetAchievementInfo(id)
    --TO(string.format("Registering %d (%s)", id, title))
    local prev = GetPreviousAchievement(id)
    dbi.previous = prev
    dbi.complete = complete
    dbi.name = title
    dbi.criterialist = {}
    
    if prev then
      registerAchievement(prev, db)
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
    
    local crit = GetAchievementNumCriteria(id)
    --TO(string.format("%d criteria", crit))
    for i = 1, crit do
      local crit_name, crit_type, crit_complete, crit_quantity, crit_reqquantity, _, _, crit_asset, _, crit_id = GetAchievementCriteriaInfo(id, i)
      --[[if not known[mega[2] ] then
        TO(string.format("%s: %s, %s, %s, %s, %s, %s, %s, %s, %s, %s", tostring(title), tostring(mega[1]), tostring(mega[2]), tostring(mega[3]), tostring(mega[4]), tostring(mega[5]), tostring(mega[6]), tostring(mega[7]), tostring(mega[8]), tostring(mega[9]), tostring(mega[10])))
      end]]
      table.insert(dbi.criterialist, crit_id)
      assert(not db.criteria[crit_id])
      db.criteria[crit_id] = {
        name = crit_name,
        type = crit_type,
        complete = crit_complete,
        progress = crit_quantity,
        progress_total = crit_reqquantity,
        asset = crit_asset,
      }
    end
  end
  
  -- Type 0 is a monster kill
  --  assetID is the monster ID
  -- Type 1 is some sort of PvP objective? "holding bases", "controlling flags"
  -- Type 7 is weapon skill
  -- Type 8 means another achievement
  --  assetID is achievement ID
  -- Type 29 is "craft by cooking"
  -- Type 110 is "use mistletoe on" (what)
  -- I'm not bothering with more right now
  
  for _, catid in pairs(GetCategoryList()) do
    for d = 1, GetCategoryNumAchievements(catid) do
      registerAchievement(GetAchievementInfo(catid, d), db)
    end
  end
  
  return db
end

local function activate(newinstance, oldinstance)
  if oldinstance then
    newinstance.AchievementCallbacks = oldinstance.AchievementCallbacks -- yoink
  end
  
  newinstance.AchievementDB = getAchievementDB() -- 'coz we're lazy
end

AchievementNotifier.frame = CreateFrame("Frame")

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

]]
