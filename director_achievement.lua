QuestHelper_File["director_achievement.lua"] = "Development Version"
QuestHelper_Loadtime["director_achievement.lua"] = GetTime()

local debug_output = false
if QuestHelper_File["director_achievement.lua"] == "Development Version" then debug_output = true end

local added = false
function QH_AddFires()
  if added then QuestHelper:TextOut("Objectives are already added! If they haven't shown up yet, just be patient, it may take some time. If they have, and you've ignored some, you'll have to logout and logon to reset them. Sorry! It's kind of a work in progress.") return end
  added = true
  
  QuestHelper:TextOut("Adding bonfire objectives! This may take several minutes - please be patient. Bonfire objectives will not go away automatically when you finish the quest, you'll have to ignore them manually, and it has no idea which bonfires you've already done. It also may take some time for it to generate a good path, or to respond to ignore requests. This is a very early beta feature and is in no way a finished, polished product :) Enjoy the Fire Festival!")

  local fonbires = {
    {39,74,41,"Horde"},
    {39,50,44,"Alliance"},
    {27,4,49,"Horde"},
    {33,58,17,"Alliance"},
    {40,62,29,"Horde"},
    {40,80,62,"Alliance"},
    {25,64,25,"Alliance"},
    {28,46,46,"Alliance"},
    {31,74,51,"Alliance"},
    {37,43,65,"Alliance"},
    {36,49,72,"Alliance"},
    {41,46,50,"Horde"},
    {52,70,43,"Horde"},
    {44,46,26,"Horde"},
    {48,50,46,"Alliance"},
    {48,58,25,"Horde"},
    {29,32,40,"Alliance"},
    {30,24,59,"Alliance"},
    {35,49,38,"Horde"},
    {38,33,73,"Alliance"},
    {38,32,75,"Horde"},
    {46,47,47,"Horde"},
    {42,14,50,"Alliance"},
    {42,76,74,"Horde"},
    {45,68,9,"Horde"},
    {43,57,52,"Horde"},
    {50,43,82,"Alliance"},
    {49,56,54,"Alliance"},
    {51,13,47,"Alliance"},
    {2,38,54,"Alliance"},
    {2,70,69,"Horde"},
    {12,41,26,"Alliance"},
    {3,44,53,"Alliance"},
    {9,55,69,"Alliance"},
    {16,37,46,"Alliance"},
    {4,65,17,"Alliance"},
    {4,26,76,"Horde"},
    {1,47,38,"Horde"},
    {7,52,47,"Horde"},
    {10,62,40,"Alliance"},
    {10,33,30,"Horde"},
    {17,28,44,"Alliance"},
    {17,72,47,"Horde"},
    {23,21,26,"Horde"},
    {22,51,60,"Horde"},
    {5,57,34,"Alliance"},
    {5,46,44,"Horde"},
    {6,50,60,"Horde"},
    {8,52,29,"Alliance"},
    {8,49,27,"Horde"},
    {24,55,91,"Alliance"},
    {24,55,60,"Alliance"},
    {11,52,28,"Horde"},
    {14,41,52,"Horde"},
    {19,62,35,"Alliance"},
    {19,59,35,"Horde"},
    {54,42,66,"Alliance"},
    {54,50,59,"Horde"},
    {56,62,58,"Alliance"},
    {56,55,40,"Horde"},
    {58,50,70,"Alliance"},
    {58,51,34,"Horde"},
    {59,31,63,"Alliance"},
    {59,32,68,"Horde"},
    {53,40,55,"Alliance"},
    {53,33,30,"Horde"},
    {55,55,55,"Alliance"},
    {55,52,43,"Horde"},
    {57,69,52,"Alliance"},
    {57,36,52,"Horde"},
    {72,47,66,"Alliance"},
    {72,47,62,"Horde"},
    {65,55,20,"Alliance"},
    {65,51,12,"Horde"},
    {68,75,44,"Alliance"},
    {68,39,48,"Horde"},
    {70,58,16,"Alliance"},
    {70,48,13,"Horde"},
    {69,34,61,"Alliance"},
    {69,19,61,"Horde"},
    {75,41,61,"Alliance"},
    {75,43,71,"Horde"},
    {73,42,87,"Alliance"},
    {73,40,86,"Horde"},
    {66,78,75,"Alliance"},
    {66,80,53,"Horde"},
  }
  
  local msfires = {desc = "Midsummer Fires", tracker_desc = "Midsummer Fires", tracker_split = true}
  
  for _, v in ipairs(fonbires) do
    local ec, ez = unpack(QuestHelper_ZoneLookup[v[1]])
    local c, x, y = QuestHelper.Astrolabe:GetAbsoluteContinentPosition(ec, ez, v[2] / 100, v[3] / 100)
    --print(v[1], v[2], v[3], v[4], ec, ez, c, x, y, QuestHelper_ParentLookup[v[1]])
    local desc = string.format("%s %s bonfire", v[4], QuestHelper_NameLookup[v[1]])
    local node = {loc = {x = x, y = y, p = v[1], c = QuestHelper_ParentLookup[v[1]]}, why = msfires, map_desc = {desc}, tracker_desc = desc}
    local cluster = {node}
    node.cluster = cluster
    
    QH_Route_ClusterAdd(cluster)
  end
end



local blarg

local added = {}
local function QH_AddChunk(targs)
  
  if added[targs] then QuestHelper:TextOut("Objectives are already added! If they haven't shown up yet, just be patient, it may take some time. If they have, and you've ignored some, you'll have to logout and logon to reset them. Sorry! It's kind of a work in progress.") return end
  added[targs] = true
  
  if not blarg then QuestHelper:TextOut("Adding bucket objectives! This may take several minutes - please be patient. Bucket objectives will not go away automatically when you finish the quest, you'll have to ignore them manually, and it has no idea which bonfires you've already done. It also may take some time for it to generate a good path, or to respond to ignore requests. This is a very early beta feature and is in no way a finished, polished product :) Enjoy Hallow's End!") blarg = true end
  
  local msfires = {desc = targs.name, tracker_desc = targs.name, tracker_split = true}
  
  for _, v in ipairs(targs) do
    local cont, zone = v[4]:match("(.*), (.*)")
    
    if not QuestHelper_IndexLookup[cont] then
      --print("nindex", cont)
      if not v[1] then fail = true v[1] = 42 end
    else
      v[1] = QuestHelper_IndexLookup[cont]
    end
    
    local ec, ez = unpack(QuestHelper_ZoneLookup[v[1]])
    local c, x, y = QuestHelper.Astrolabe:GetAbsoluteContinentPosition(ec, ez, v[2] / 100, v[3] / 100)
    local node = {loc = {x = x, y = y, p = v[1], c = QuestHelper_ParentLookup[v[1]]}, why = msfires, map_desc = {v[4]}, tracker_desc = v[4]}
    local cluster = {node}
    node.cluster = cluster
    
    QH_Route_ClusterAdd(cluster)
  end
  
  assert(not fail)
end

local fb

if QuestHelper:PlayerFaction() == 1 then 
  fb = {
    kalimdor = {
      {nil, 67, 16, "Darnassus, Craftsmen’s Terrace"},
      {nil, 56, 60, "Teldrassil, Dolanaar"},
      {nil, 56, 60, "Bloodmyst Isle, Blood Watch"},
      {12, 60, 19, "Exodar, Seat of the Naaru"},
      {nil, 48, 49, "Azuremyst Isle, Azure Watch"},
      {nil, 37, 44, "Darkshore, Auberdine"},
      {nil, 61, 39, "Winterspring, Everlook"},
      {nil, 37, 49, "Ashenvale, Astranaar"},
      {nil, 35, 7, "Stonetalon Mountains, Stonetalon Peak"},
      {nil, 66, 7, "Desolace, Nijel's Point"},
      {11, 62, 39, "Barrens, Ratchet"},
      {nil, 67, 45, "Dustwallow Marsh, Theramore Isle"},
      {nil, 42, 74, "Dustwallow Marsh, Mudsprocket"},
      {nil, 52, 28, "Tanaris, Gadgetzan"},
      {nil, 52, 39, "Silithus, Cenarion Hold"},
      {nil, 31, 43, "Feralas, Feathermoon Stronghold"},
      name = "Kalimdor candy buckets",
    },
    ek = {
      {nil, 75.9, 52.3, "Eastern Plaguelands, Light's Hope"},
      {42, 14.1, 41.6, "Hinterlands, Aerie Peak"},
      {nil, 51.1, 58.9, "Hillsbrad Foothills, Southshore"},
      {nil, 10.8, 60.9, "Wetlands, Menethil Harbor"},
      {nil, 18.7, 51.5, "Ironforge, The Commons"},
      {nil, 47.4, 52.4, "Dun Morogh, Kharanos"},
      {nil, 35.5, 48.5, "Loch Modan, Thelsamar"},
      {36, 60.5, 75.2, "Stormwind, Trade District"},
      {nil, 43.7, 66, "Elwynn Forest, Goldshire"},
      {nil, 27, 45, "Redridge Mountains, Lakeshire"},
      {nil, 73.9, 44.5, "Duskwood, Darkshire"},
      {nil, 52.9, 53.6, "Westfall, Sentinel Hill"},
      {38, 27.1, 77.3, "Stranglethorn, Booty Bay"},
      name = "Eastern Kingdoms candy buckets",
    },
    outland = {
      {nil, 43.4, 36.1, "Netherstorm, The Stormspire"},
      {nil, 32.1, 64.5, "Netherstorm, Area 52"},
      {nil, 62.9, 38.3, "Blade's Edge Mountains, Evergrove"},
      {nil, 61, 68.1, "Blade's Edge Mountains, Toshley's Station"},
      {nil, 38.5, 63.8, "Blade's Edge Mountains, Sylvanaar"},
      {nil, 41.9, 26.2, "Zangarmarsh, Orebor Harborage"},
      {nil, 67.2, 49, "Zangarmarsh, Telredor"},
      {nil, 78.5, 62.9, "Zangarmarsh, Cenarion Refuge"},
      {nil, 23.4, 36.5, "Hellfire Peninsula, Temple of Telhamat"},
      {nil, 54.3, 63.6, "Hellfire Peninsula, Honor Hold"},
      {53, 61, 28.2, "(Aldor only) Shadowmoon Valley, Altar of Sha'tar"},
      {53, 56.3, 59.8, "(Scryers only) Shadowmoon Valley, Sanctum of the Stars"},
      {nil, 37.1, 58.2, "Shadowmoon Valley, Wildhammer Stronghold"},
      {nil, 56.6, 53.2, "Terokkar Forest, Allerian Stronghold"},
      {60, 56.2, 81.8, "(Scryers only) Shattrath City, Scryers Tier"},
      {60, 28.1, 49, "(Aldor only) Shattrath City, Aldor Rise"},
      {nil, 54.2, 75.8, "Nagrand, Telaar"},
      name = "Outland candy buckets",
    }
  }
else
  fb = {
    kalimdor = {
      {nil, 61, 39, "Winterspring, Everlook"},
      {nil, 74, 60, "Ashenvale, Splintertree Post"},
      {nil, 54, 69, "Orgrimmar, Valley of Strength"},
      {nil, 51, 41, "Durotar, Razor Hill"},
      {nil, 62, 39, "The Barrens, Ratchet"},
      {nil, 52, 30, "The Barrens, The Crosswoods"},
      {nil, 47, 62, "Stonetalon Mountains, Sun Rock Retreat"},
      {nil, 24, 68, "Desolace, Shadowprey Village"},
      {nil, 45, 64, "Thunder Bluff, Lower Rise"},
      {nil, 47, 61, "Mulgore, Bloodhoof Village"},
      {nil, 74, 61, "The Barrens, Camp Taurajo"},
      {nil, 36, 32, "Dustwallow Marsh, Brackenwall Village"},
      {nil, 75, 45, "Feralas, Camp Mojache"},
      {nil, 41, 74, "Dustwallow Marsh, Mudsprocket"},
      {nil, 46, 51, "Thousand Needles, Freewind Post"},
      {nil, 52, 28, "Tanaris, Gadgetzan"},
      {nil, 51, 39, "Silithus, Cenarion Hold"},
      name = "Kalimdor candy buckets",
    },
    ek = {
      {nil, 48.1, 47.8, "Eversong Woods, Falconwing Square"},
      {nil, 79.6, 57.8, "Silvermoon City, Royal Exchange"},
      {nil, 67.7, 73.2, "Silvermoon City, The Bazaar"},
      {nil, 43.7, 71.1, "Eversong Woods, Fairbreeze Village"},
      {nil, 48.6, 32, "Ghostlands, Tranquillien"},
      {34, 75.9, 52.3, "East Plaguelands, Light's Hope"},
      {nil, 61.8, 52.2, "Tirisfal Glades, Brill"},
      {nil, 68, 37.3, "Undercity, Trade Quarter"},
      {nil, 43.2, 41.4, "Silverpine Forest, Sepulcher"},
      {nil, 62.8, 19, "Hillsbrad Foothills, Tarren Mill"},
      {24, 78.2, 81.5, "Hinterlands, Revantusk Village"},
      {nil, 73.9, 32.6, "Arathi Highlands, Hammerfall"},
      {nil, 2.9, 36, "Badlands, Kargath"},
      {nil, 45.1, 56.5, "Swamp of Sorrows, Stonard"},
      {38, 35.1, 29.7, "Stranglethorn, Grom'gol"},
      {38, 27.1, 77.3, "Stranglethorn, Booty Bay"},
      name = "Eastern Kingdoms candy buckets",
    },
    outland = {
      {nil, 43.4, 36.1, "Netherstorm, The Stormspire"},
      {nil, 32.1, 64.5, "Netherstorm, Area 52"},
      {nil, 76.2, 60.4, "Blade's Edge Mountains, Mok'Nathal Village"},
      {nil, 62.9, 38.3, "Blade's Edge Mountains, Evergrove"},
      {nil, 53.4, 55.5, "Blade's Edge Mountains, Thunderlord Stronghold"},
      {nil, 30.7, 50.9, "Zangarmarsh, Zabra'jin"},
      {nil, 56.7, 34.6, "Nagrand, Garadar"},
      {nil, 78.5, 62.9, "Zangarmarsh, Cenarion Refuge"},
      {nil, 56.8, 37.5, "Hellfire Peninsula, Thrallmar"},
      {nil, 26.9, 59.6, "Hellfire Peninsula, Falcon Watch"},
      {60, 28.1, 49, "(Aldor only) Shattrath City, Aldor Rise"},
      {60, 56.2, 81.8, "(Scryer only) Shattrath City, Scryers Tier"},
      {nil, 48.8, 45.2, "Terokkar Forest, Stonebreaker Hold"},
      {nil, 30.3, 27.8, "Shadowmoon Valley, Shadowmoon Village"},
      {53, 61, 28.2, "(Aldor only) Shadowmoon Valley, Altar of Sha'tar"},
      {53, 56.3, 59.8, "(Scryer only) Shadowmoon Valley, Sanctum of the Stars"},
      name = "Outland candy buckets",
    }
  }
end
  
function QH_AddBuckets(typ)
  blarg = false
  if typ and fb[typ] then
    QH_AddChunk(fb[typ])
  else
    QH_AddChunk(fb.kalimdor)
    QH_AddChunk(fb.ek)
    QH_AddChunk(fb.outland)
  end
end

local achieveable = {}

local function IsDoable(id)
  if achieveable[id] == nil then
    -- First we just see if we have a DB entry for it
    -- This can be made *much* more efficient.
    if not DB_Ready() then
      print("DB not yet ready, please wait")
      return false
    end
    
    local dbi = DB_GetItem("achievement", id, true, true)
    if dbi then
      DB_ReleaseItem(dbi)
      print(id, "achieveable via db")
      achieveable[id] = true
      return true
    end
    
    local crit = GetAchievementNumCriteria(id)
    
    -- Whenever I write "crit" as a variable name it always slightly worries me.
    
    -- Y'see, several years ago I competed in a programming competition called Topcoder. At the end of a big tournament, if you did well, they flew you to a casino or a hotel and you competed against a bunch of other geeks, with your code posted on monitors. This was uncommonly boring unless you were a geek, but luckily, we were, so it was actually kind of exciting.
    -- So I'm up there competing, and I need a count, so I make a variable called "cont". "count", y'see, is a function, so I can't use that. But then I need another one. I can't go with "cout" because that's actually a global variable in C++, which is what I'm using. And, well, I want to keep the first and last letters preserved, because that way it reminds me it's a count.
    
    -- So I start typing the first thing that comes to mind that fulfills all the requirements.
    
    -- Luckily, I stop myself in time, and write "cnt" instead.
    
    -- Once or twice in QuestHelper I've needed a few variables about criteria. And there's . . . something . . . which is only one letter off from "crit", and is something I should probably not be typing in publicly accessible sourcecode.
  
    -- So now you know. Back to the code.
    
    -- (although let's be honest with the amount of profanity scattered throughout this codebase I'm not quite sure why I care buuuuuuuuuut here we are anyway)
    
    if crit > 0 then
      for i = 1, crit do
        local _, typ, _, _, _, _, _, asset, _, cid = GetAchievementCriteriaInfo(id, i)
        if typ == 0 then
          -- Monster kill. We're good! We can do these.
        elseif typ == 8 then
          if not IsDoable(asset) then
            achieveable[id] = false
            break
          end
        else
          achieveable[id] = false
          break
        end
      end
      
      if achieveable[id] == nil then print(id, "achieveable via occlusion") achieveable[id] = true end
    else
      print(id, "not achieveable due to wizard casting what the fuck")
      achieveable[id] = false
    end
  end
  
  return achieveable[id]
end

local function GetListOfAchievements(category)
  local ct = GetCategoryNumAchievements(category)
  
  local available_achieves = {}
  
  for i = 1, ct do
    local id, _, _, complete = GetAchievementInfo(category, i)
    if not complete and IsDoable(id) then
      table.insert(available_achieves, i)
    end
  end
  
  return available_achieves
end

local function FilterFunction(category)
  local aa = GetListOfAchievements(category)
  
  return #aa, 0, 0
end

local function SetQHVis(button, ach, _, _, complete)
  print("setqhvis")
  button.qh_checkbox:Hide()
  if complete or not IsDoable(ach) then
    button.qh_checkbox:Hide()
  else
    button.qh_checkbox:Show()
  end
end

local ABDA_suppress
local ABDA
local function ABDA_Replacement(button, category, achievement, selectionID)
  -- hee hee hee
  -- i am sneaky like fish
  -- *sneaky* fish
  -- ^__^
  
  if not ABDA_suppress and ACHIEVEMENTUI_SELECTEDFILTER == FilterFunction then
    local aa = GetListOfAchievements(category)
    local ach = aa[achievement]
    ABDA(button, category, ach, selectionID)
    SetQHVis(button, GetAchievementInfo(category, ach))
    print("passthru")
  else
    ABDA(button, category, achievement, selectionID)
    SetQHVis(button, GetAchievementInfo(category, achievement))
  end
end

local AFAU
local function AFAU_Replacement(...)
  ABDA_permit = true
  AFAU(...)
  ABDA_permit = false
end

local TrackedAchievements = {}

local function check_onclick(self)
  if self:GetChecked() then
    TrackedAchievements[self:GetParent().id] = true
  else
    TrackedAchievements[self:GetParent().id] = nil
  end
end
local function check_onenter(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText(QHText("ACHIEVEMENT_CHECKBOX"))
end
local function check_onleave(self)
  GameTooltip:Hide()
end
local function check_onshow(self)
  self:SetChecked(TrackedAchievements[self:GetParent().id])
end



QH_Event("ADDON_LOADED", function (addonid)
  if addonid == "Blizzard_AchievementUI" then
    -- yyyyyyoink
    table.insert(AchievementFrameFilters, {text="QuestHelpable", func=FilterFunction})
    
    ABDA = AchievementButton_DisplayAchievement
    AchievementButton_DisplayAchievement = ABDA_Replacement
    
    AFAU = AchievementFrameAchievements_Update
    AchievementFrameAchievements_Update = AFAU_Replacement
    
    for i = 1, 7 do
      local framix = CreateFrame("CheckButton", "qh_arglbargl_" .. i, AchievementFrameAchievements.buttons[i], "AchievementCheckButtonTemplate")
      framix:SetPoint("BOTTOMRIGHT", AchievementFrameAchievements.buttons[i], "BOTTOMRIGHT", -22, 7.5)
      framix:SetScript("OnEnter", check_onenter)
      framix:SetScript("OnLeave", check_onleave)
      
      framix:SetScript("OnShow", check_onshow)
      framix:SetScript("OnClick", check_onclick)
      
      _G["qh_arglbargl_" .. i .. "Text"]:Hide() -- no
      
      local sigil = framix:CreateTexture("BACKGROUND")
      sigil:SetHeight(24)
      sigil:SetWidth(24)
      sigil:SetTexture("Interface\\AddOns\\QuestHelper\\sigil")
      sigil:SetPoint("RIGHT", framix, "LEFT", -1, 0)
      sigil:SetVertexColor(0.6, 0.6, 0.6)
      
      AchievementFrameAchievements.buttons[i].qh_checkbox = framix
    end
  end
end)
