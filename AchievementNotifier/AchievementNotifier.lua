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

local AchievementNotifier = {};

AchievementNotifier.AchievementCallbacks = {}

function AchievementNotifier:GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end

local function getAchievementDB()
  db = {}
  vals = {GetNumCompletedAchievements()}
  for k, v in pairs(vals) do
    
end

local function activate(newinstance, oldinstance)
  if oldinstance then
    newinstance.AchievementCallbacks = oldinstance.AchievementCallbacks -- yoink
  end
  newinstance.AchievementDB = getAchievementDB()
end

QuestHelper = CreateFrame("Frame", "QuestHelper", nil)

DongleStub:Register(AchievementNotifier, activate)
