QuestHelper_File["collect_achievement.lua"] = "Development Version"

QHDataCollector.achievement = {}

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
  --QuestHelper:TextOut(string.format("Registering %d (%s)", id, title))
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
    
  local critcount = GetAchievementNumCriteria(id)
  if critcount == 0 then record = true end
  
  for i = 1, critcount do
    local crit_name, crit_type, crit_complete, crit_quantity, crit_reqquantity, _, _, crit_asset, _, crit_id = GetAchievementCriteriaInfo(id, i)
    
    --if not QuestHelper_ZorbaForgotToRemoveThis[string.format("%d", crit_type)] then QuestHelper_ZorbaForgotToRemoveThis[string.format("%d", crit_type)] = {} end
    --QuestHelper_ZorbaForgotToRemoveThis[string.format("%d", crit_type)][title .. " --- " .. mega[1]] = crit_asset
    
    --[[
    table.insert(dbi.criterialist, crit_id)
    assert (not db.criteria[crit_id])
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
  
  if record then achievement_list[id] = true end
end

function createAchievementList()
  for _, catid in pairs(GetCategoryList()) do
    for d = 1, GetCategoryNumAchievements(catid) do
      registerAchievement(GetAchievementInfo(catid, d), db)
    end
  end
end

local achievement_stop_time = 0

local function ScanAchievementYield()
  if GetTime() > achievement_stop_time then
    -- As a safety, reset stop time to 0.  If somehow we fail to set it next time,
    -- we'll be sure to yield promptly.
    achievement_stop_time = 0
    coroutine.yield()
    achievement_stop_time = GetTime() + 1e-3  -- this gives us like 1ms/frame, which is pretty crummy. TODO: unified architecture for coroutines?
  end
end

local function retrieveAchievement(id, db, noyield)
  if not noyield then ScanAchievementYield() end

  local _, _, _, complete = GetAchievementInfo(id)
  --QuestHelper:TextOut(string.format("Registering %d (%s)", id, title))
  
  db.achievements[id] = QuestHelper:CreateTable("collect_achievement achievement")
  db.achievements[id].complete = complete
  
  local dbi = db.achievements[id]
  
  local critcount = GetAchievementNumCriteria(id)
  
  --QuestHelper:TextOut(string.format("%d criteria", crit))
  for i = 1, critcount do
    local _, _, crit_complete, crit_quantity, crit_reqquantity, _, _, _, _, crit_id = GetAchievementCriteriaInfo(id, i)

    db.criteria[crit_id] = QuestHelper:CreateTable("collect_achievement criteria")
    db.criteria[crit_id].complete = crit_complete
    db.criteria[crit_id].progress = crit_quantity
  end
end

function getAchievementDB(noyield)
  local db = {}
  db.achievements = {}
  db.criteria = {}
  
  for k in pairs(achievement_list) do
    retrieveAchievement(k, db, noyield)
  end
  
  return db
end

local needsUpdate = true

local function OnEvent(frame, event)
  needsUpdate = true
end

--[[
function QuestHelper:RunCoroutine()
  if coroutine.status(update_route) ~= "dead" then
    coroutine_running = true
    -- At perf = 100%, we will run 5 ms / frame.
    coroutine_stop_time = GetTime() + 4e-3 * QuestHelper_Pref.perf_scale * ((route_pass > 0) and 5 or 1)
    local state, err = coroutine.resume(update_route, self)
    coroutine_running = false
    if not state then
      self:TextOut("|cffff0000The routing co-routine just exploded|r: |cffffff77"..tostring(err).."|r")
      QuestHelper_ErrorCatcher_ExplicitError(err, "", "(Routing error)\n")
    end
  end
end]]


local function ScanAchievements()
  needsUpdate = false -- This prevents error spam.
  
  local newADB = getAchievementDB()
  local oldADB = QHDataCollector.achievement.AchievementDB
  
  for k, v in pairs(newADB.achievements) do
    if v.complete ~= oldADB.achievements[k].complete then
      assert(v.complete and not oldADB.achievements[k].complete)
      --QuestHelper:TextOut(string.format("Achievement complete, %s", select(2, GetAchievementInfo(k))))
    end
  end
  
  for k, v in pairs(newADB.criteria) do
    if v.complete ~= oldADB.criteria[k].complete then
      assert(v.complete and not oldADB.criteria[k].complete)
      --QuestHelper:TextOut(string.format("Criteria complete, %d", k))
      --QuestHelper:TextOut(string.format("Criteria complete, %s", select(1, GetAchievementCriteriaInfo(k))))
    elseif v.progress > oldADB.criteria[k].progress then
      --QuestHelper:TextOut(string.format("Criteria progress, %d", k))
      --QuestHelper:TextOut(string.format("Criteria progress, %s", select(1, GetAchievementCriteriaInfo(k))))
    end
  end
  
  QHDataCollector.achievement.AchievementDB = newADB
  
  for k, v in pairs(oldADB.achievements) do QuestHelper:ReleaseTable(v) end
  for k, v in pairs(oldADB.criteria) do QuestHelper:ReleaseTable(v) end
end

local achievement_scanning = nil

local function OnUpdate()
  if achievement_scanning then
    QuestHelper:Assert(coroutine.status(achievement_scanning) ~= "dead")
    local state, err = coroutine.resume(achievement_scanning)
    if not state then
      QuestHelper_ErrorCatcher_ExplicitError(err, "", "(Achievement scanning error)\n")
    elseif coroutine.status(achievement_scanning) == "dead" then
      achievement_scanning = nil
    end
  elseif needsUpdate and QHDataCollector.achievement.AchievementDB then
    achievement_scanning = coroutine.create(function() ScanAchievements() end)
    QuestHelper:Assert(achievement_scanning)
    OnUpdate() -- this is just easier
  end
end

QHDataCollector.achievement.frame = CreateFrame("Frame")

QHDataCollector.achievement.frame:UnregisterAllEvents()
QHDataCollector.achievement.frame:RegisterEvent("CRITERIA_UPDATE")
QHDataCollector.achievement.frame:RegisterEvent("ACHIEVEMENT_EARNED")
QHDataCollector.achievement.frame:SetScript("OnEvent", OnEvent)
QHDataCollector.achievement.frame:SetScript("OnUpdate", OnUpdate)

QHDataCollector.achievement.frame:Show()


function QH_InitAchievementCollector()
  createAchievementList()
  QHDataCollector.achievement.AchievementDB = getAchievementDB(true) -- 'coz we're lazy
end
