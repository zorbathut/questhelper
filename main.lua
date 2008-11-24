QuestHelper_File["main.lua"] = "Development Version"

QuestHelper = CreateFrame("Frame", "QuestHelper", nil)

-- Just to make sure it's always 'seen' (there's nothing that can be seen, but still...), and therefore always updating.
QuestHelper:SetFrameStrata("TOOLTIP")

QuestHelper_SaveVersion = 10
QuestHelper_CharVersion = 1
QuestHelper_Locale = GetLocale() -- This variable is used only for the collected data, and has nothing to do with displayed text.
QuestHelper_Quests = {}
QuestHelper_Objectives = {}

QuestHelper_Pref =
 {}

QuestHelper_DefaultPref =
 {
  filter_level=true,
  filter_zone=false,
  filter_done=false,
  filter_blocked=false, -- Hides blocked objectives, such as quest turn-ins for incomplete quests
  filter_watched=false, -- Limits to Watched objectives
  track=true,
  track_minimized=false,
  track_scale=1,
  track_level=true,
  track_qcolour=true,
  track_ocolour=true,
  track_size=8,
  tooltip=true,
  share = true,
  scale = 1,
  solo = false,
  comm = false,
  show_ants = true,
  level = 2,
  hide = false,
  cart_wp = true,
  tomtom_wp = true,
  flight_time = true,
  locale = GetLocale(), -- This variable is used for display purposes, and has nothing to do with the collected data.
  perf_scale = 1,       -- How much background processing can the current machine handle?  Higher means more load, lower means better performance.
  map_button = true
 }

QuestHelper_FlightInstructors = {}
QuestHelper_FlightLinks = {}
QuestHelper_FlightRoutes = {}
QuestHelper_KnownFlightRoutes = {}
QuestHelper_SeenRealms = {}

QuestHelper.tooltip = CreateFrame("GameTooltip", "QuestHelperTooltip", nil, "GameTooltipTemplate")
QuestHelper.objective_objects = {}
QuestHelper.user_objectives = {}
QuestHelper.quest_objects = {}
QuestHelper.player_level = 1
QuestHelper.locale = QuestHelper_Locale

QuestHelper.faction = (UnitFactionGroup("player") == "Alliance" and 1) or
                      (UnitFactionGroup("player") == "Horde" and 2)

assert(QuestHelper.faction)

QuestHelper.font = {serif=GameFontNormal:GetFont(), sans=ChatFontNormal:GetFont(), fancy=QuestTitleFont:GetFont()}

function QuestHelper:GetFontPath(list_string, font)
  if list_string then
    for name in string.gmatch(list_string, "[^;]+") do
      if font:SetFont(name, 10) then
        return name
      elseif font:SetFont("Interface\\AddOns\\QuestHelper\\Fonts\\"..name, 10) then
        return "Interface\\AddOns\\QuestHelper\\Fonts\\"..name
      end
    end
  end
end

function QuestHelper:SetLocaleFonts()
  self.font.sans = nil
  self.font.serif = nil
  self.font.fancy = nil

  local font = self:CreateText(self)

  if QuestHelper_Locale ~= QuestHelper_Pref.locale then
    -- Only use alternate fonts if using a language the client wasn't intended for.
    local replacements = QuestHelper_SubstituteFonts[QuestHelper_Pref.locale]
    if replacements then
      self.font.sans = self:GetFontPath(replacements.sans, font)
      self.font.serif = self:GetFontPath(replacements.serif, font)
      self.font.fancy = self:GetFontPath(replacements.fancy, font)
    end
  end

  self.font.sans = self.font.sans or self:GetFontPath(QuestHelper_Pref.locale.."_sans.ttf", font)
  self.font.serif = self.font.serif or self:GetFontPath(QuestHelper_Pref.locale.."_serif.ttf", font) or self.font.sans
  self.font.fancy = self.font.fancy or self:GetFontPath(QuestHelper_Pref.locale.."_fancy.ttf", font) or self.font.serif

  self:ReleaseText(font)

  self.font.sans = self.font.sans or ChatFontNormal:GetFont()
  self.font.serif = self.font.serif or GameFontNormal:GetFont()
  self.font.fancy = self.font.fancy or QuestTitleFont:GetFont()

  -- Need to change the font of the chat frame, for any messages that QuestHelper displays.
  -- This should do nothing if not using an alternate font.
  DEFAULT_CHAT_FRAME:SetFont(self.font.sans, select(2, DEFAULT_CHAT_FRAME:GetFont()))
end

QuestHelper.route = {}
QuestHelper.to_add = {}
QuestHelper.to_remove = {}
QuestHelper.quest_log = {}
QuestHelper.pos = {nil, {}, 0, 0, 1, "You are here.", 0}
QuestHelper.sharing = false -- Will be set to true when sharing with at least one user.

function QuestHelper.tooltip:GetPrevLines() -- Just a helper to make life easier.
  local last = self:NumLines()
  local name = self:GetName()
  return _G[name.."TextLeft"..last], _G[name.."TextRight"..last]
end

function QuestHelper:SetTargetLocation(i, x, y, toffset)
  -- Informs QuestHelper that you're going to be at some location in toffset seconds.
  local c, z = unpack(QuestHelper_ZoneLookup[i])

  self.target = self:CreateTable()
  self.target[2] = self:CreateTable()

  self.target_time = time()+(toffset or 0)

  x, y = self.Astrolabe:TranslateWorldMapPosition(c, z, x, y, c, 0)
  self.target[1] = self.zone_nodes[i]
  self.target[3] = x * self.continent_scales_x[c]
  self.target[4] = y * self.continent_scales_y[c]

  self:SetTargetLocationRecalculate()
end

function QuestHelper:SetTargetLocationRecalculate()
  if self.target then
    for i, n in ipairs(self.target[1]) do
      local a, b = n.x-self.target[3], n.y-self.target[4]
      self.target[2][i] = math.sqrt(a*a+b*b)
    end
  end
end

function QuestHelper:UnsetTargetLocation()
  -- Unsets the target set above.
  if self.target then
    self:ReleaseTable(self.target[2])
    self:ReleaseTable(self.target)
    self.target = nil
    self.target_time = nil
  end
end

local interruptcount = 0   -- counts how many "played gained control" messages we recieve, used for flight paths
local init_cartographer_later = false

function QuestHelper:Initialize()
  local file_problem = false
  local expected_version = GetAddOnMetadata("QuestHelper", "Version")

  local expected_files =
    {
     ["upgrade.lua"] = true,
     ["main.lua"] = true,
     ["recycle.lua"] = true,
     ["objective.lua"] = true,
     ["quest.lua"] = true,
     ["questlog.lua"] = true,
     ["utility.lua"] = true,
     ["dodads.lua"] = true,
     ["graph.lua"] = true,
     ["teleport.lua"] = true,
     ["pathfinding.lua"] = true,
     ["routing.lua"] = true,
     ["custom.lua"] = true,
     ["menu.lua"] = true,
     ["hidden.lua"] = true,
     ["nag.lua"] = true,
     ["comm.lua"] = true,
     ["mapbutton.lua"] = true,
     ["help.lua"] = true,
     ["pattern.lua"] = true,
     ["flightpath.lua"] = true,
     ["tracker.lua"] = true,
     ["objtips.lua"] = true,
     ["cartographer.lua"] = true,
     ["tomtom.lua"] = true,
     ["textviewer.lua"] = true,
     ["error.lua"] = true,
     ["timeslice.lua"] = true,
     
     ["static.lua"] = true,
     ["static_deDE.lua"] = true,
     ["static_enUS.lua"] = true,
     ["static_esES.lua"] = true,
     ["static_esMX.lua"] = true,
     ["static_frFR.lua"] = true,
     ["static_koKR.lua"] = true,
     ["static_ruRU.lua"] = true,
     ["static_zhCN.lua"] = true,
     ["static_zhTW.lua"] = true,
     
     ["collect.lua"] = true,
     ["collect_achievement.lua"] = true,
     ["collect_lzw.lua"] = true,
     ["collect_traveled.lua"] = true,
     ["collect_zone.lua"] = true,
     ["collect_location.lua"] = true,
     ["collect_merger.lua"] = true,
     ["collect_monster.lua"] = true,
    }

  for file, version in pairs(QuestHelper_File) do
    if not expected_files[file] then
      DEFAULT_CHAT_FRAME:AddMessage("Unexpected QuestHelper file: "..file)
      file_problem = true
    elseif version ~= expected_version then
      DEFAULT_CHAT_FRAME:AddMessage("Wrong version of QuestHelper file: "..file.." (found '"..version.."', should be '"..expected_version.."')")
      if version ~= "Development Version" and expected_version ~= "Development Version" then
        -- Developers are allowed to mix dev versions with release versions
        file_problem = true
      end
    end
  end

  for file in pairs(expected_files) do
    if not QuestHelper_File[file] then
      DEFAULT_CHAT_FRAME:AddMessage("Missing QuestHelper file: "..file)
      file_problem = true
    end
  end

  -- Don't need this table anymore.
  QuestHelper_File = nil

  if QuestHelper_StaticData and not QuestHelper_StaticData[GetLocale()] then
    file_problem = true
    DEFAULT_CHAT_FRAME:AddMessage("Static data does not seem to exist")
  end

  if file_problem then
    message(QHText("PLEASE_RESTART"))
    QuestHelper_ErrorCatcher_ExplicitError("not-installed-properly")
    QuestHelper = nil     -- Just in case anybody else is checking for us, we're not home
    return
  end
  
  if not GetCategoryList then
    message(QHText("PRIVATE_SERVER"))
    QuestHelper_ErrorCatcher_ExplicitError("error id cakbep ten T")
    QuestHelper = nil
    return
  end
  
  if not DongleStub then
    message(QHText("NOT_UNZIPPED_CORRECTLY"))
    QuestHelper_ErrorCatcher_ExplicitError("not-unzipped-properly")
    QuestHelper = nil     -- Just in case anybody else is checking for us, we're not home
    return
  end

  QuestHelper_ErrorCatcher_CompletelyStarted()
  
  if not QuestHelper_StaticData then
    -- If there is no static data for some mysterious reason, create an empty table so that
    -- other parts of the code can carry on as usual, using locally collected data if it exists.
    QuestHelper_StaticData = {}
  end

  QHFormatSetLocale(QuestHelper_Pref.locale or GetLocale())

  if not QuestHelper_UID then
    QuestHelper_UID = self:CreateUID()
  end
  QuestHelper_SaveDate = time()

  self.Astrolabe = DongleStub("Astrolabe-0.4-QuestHelper")
  QuestHelper_BuildZoneLookup()

  if QuestHelper_Locale ~= GetLocale() then
    self:TextOut(QHText("LOCALE_ERROR"))
    return
  end

  if not self:ZoneSanity() then
    self:TextOut(QHText("ZONE_LAYOUT_ERROR"))
    message("QuestHelper: "..QHText("ZONE_LAYOUT_ERROR"))
    return
  end

  QuestHelper_UpgradeDatabase(_G)
  QuestHelper_UpgradeComplete()
  
  if QuestHelper_SaveVersion ~= 10 then
    self:TextOut(QHText("DOWNGRADE_ERROR"))
    return
  end
  
  if QuestHelper_IsPolluted(_G) then
    self:TextOut(QHFormat("NAG_POLLUTED"))
    self:Purge(nil, true, true)
  end
  
  local signature = expected_version .. " on " .. GetBuildInfo()
  QuestHelper_Quests[signature] = QuestHelper_Quests[signature] or {}
  QuestHelper_Objectives[signature] = QuestHelper_Objectives[signature] or {}
  QuestHelper_FlightInstructors[signature] = QuestHelper_FlightInstructors[signature] or {}
  QuestHelper_FlightRoutes[signature] = QuestHelper_FlightRoutes[signature] or {}
  
  QuestHelper_Quests_Local = QuestHelper_Quests[signature]
  QuestHelper_Objectives_Local = QuestHelper_Objectives[signature]
  QuestHelper_FlightInstructors_Local = QuestHelper_FlightInstructors[signature]
  QuestHelper_FlightRoutes_Local = QuestHelper_FlightRoutes[signature]
  
  QuestHelper_SeenRealms[GetRealmName()] = true -- some attempt at tracking private servers
  
  QH_Collector_Init()
  
  self.player_level = UnitLevel("player")

  self:UnregisterEvent("VARIABLES_LOADED")
  self:RegisterEvent("PLAYER_TARGET_CHANGED")
  self:RegisterEvent("LOOT_OPENED")
  self:RegisterEvent("QUEST_COMPLETE")
  self:RegisterEvent("QUEST_LOG_UPDATE")
  self:RegisterEvent("QUEST_PROGRESS")
  self:RegisterEvent("MERCHANT_SHOW")
  self:RegisterEvent("QUEST_DETAIL")
  self:RegisterEvent("TAXIMAP_OPENED")
  self:RegisterEvent("PLAYER_CONTROL_GAINED")
  self:RegisterEvent("PLAYER_LEVEL_UP")
  self:RegisterEvent("PARTY_MEMBERS_CHANGED")
  self:RegisterEvent("CHAT_MSG_ADDON")
  self:RegisterEvent("CHAT_MSG_SYSTEM")
  self:RegisterEvent("BAG_UPDATE")
  self:RegisterEvent("GOSSIP_SHOW")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")

  for key, def in pairs(QuestHelper_DefaultPref) do
    if QuestHelper_Pref[key] == nil then
      QuestHelper_Pref[key] = def
    end
  end

  self:SetLocaleFonts()

  if QuestHelper_Pref.share and not QuestHelper_Pref.solo then
    self:EnableSharing()
  end

  if QuestHelper_Pref.hide then
    self.map_overlay:Hide()
  end

  self:HandlePartyChange()

  self:Nag("all")

  for locale in pairs(QuestHelper_StaticData) do
    if locale ~= self.locale then
      -- Will delete references to locales you don't use.
      QuestHelper_StaticData[locale] = nil
      _G["QuestHelper_StaticData_" .. locale] = nil
    end
  end

  local static = QuestHelper_StaticData[self.locale]

  if static then
    if static.flight_instructors then for faction in pairs(static.flight_instructors) do
      if faction ~= self.faction then
        -- Will delete references to flight instructors that don't belong to your faction.
        static.flight_instructors[faction] = nil
      end
    end end

    if static.quest then for faction in pairs(static.quest) do
      if faction ~= self.faction then
        -- Will delete references to quests that don't belong to your faction.
        static.quest[faction] = nil
      end
    end end
  end
  
  self:ResetPathing()
  
  -- Adding QuestHelper_CharVersion, so I know if I've already converted this characters saved data.
  if not QuestHelper_CharVersion then
    -- Changing per-character flight routes, now only storing the flight points they have,
    -- will attempt to guess the routes from this.
    local routes = {}

    for i, l in pairs(QuestHelper_KnownFlightRoutes) do
      for key in pairs(l) do
        routes[key] = true
      end
    end

    QuestHelper_KnownFlightRoutes = routes

    -- Deleting the player's home again.
    -- But using the new CharVersion variable I'm adding is cleaner that what I was doing, so I'll go with it.
    QuestHelper_Home = nil
    QuestHelper_CharVersion = 1
  end

  if not QuestHelper_Home then
    -- Not going to bother complaining about the player's home not being set, uncomment this when the home is used in routing.
    -- self:TextOut(QHText("HOME_NOT_KNOWN"))
  end

  self.minimap_dodad = self:CreateMipmapDodad()

  if QuestHelper_Pref.map_button then
      QuestHelper:InitMapButton()
  end
  
  if QuestHelper_Pref.cart_wp then
    init_cartographer_later = true
  end

  if QuestHelper_Pref.tomtom_wp then
    self:EnableTomTom()
  end

  self.tracker:SetScale(QuestHelper_Pref.track_scale)

  if QuestHelper_Pref.track and not QuestHelper_Pref.hide then
    self:ShowTracker()
  end

  local version = GetAddOnMetadata("QuestHelper", "Version") or "Unknown"
  if QuestHelper_Version ~= version then
    QuestHelper_Version = version
    self:ChangeLog()
  end

  self:SetScript("OnUpdate", self.OnUpdate)

  -- Seems to do its own garbage collection pass before fully loading, so I'll just rely on that
  --collectgarbage("collect") -- Free everything we aren't using.

  if self.debug_objectives then
    for name, data in pairs(self.debug_objectives) do
      self:LoadDebugObjective(name, data)
    end
  end
  
  self.Routing:Initialize()       -- Set up the routing task
  
  --[[ -- This is just an example of how the WoW profiler biases its profiles heavily.  
  function C()
  end
  
  function A()
    q = 0
    for x = 0, 130000000, 1 do
    end
  end

  function B()
    q = 0
    for x = 0, 12000000, 1 do
      C()
    end
  end

  function B2()
    q = 0
    for x = 0, 1200000, 1 do
      --q = q + x
      C()
    end
  end
  
  debugprofilestart()
  
  local ta = debugprofilestop()
  A()
  local tb = debugprofilestop()
  B()
  local tc = debugprofilestop()
  
  QuestHelper:TextOut(string.format("%d %d %d", ta, tb - ta, tc - tb))
  QuestHelper:TextOut(string.format("%d %d", GetFunctionCPUUsage(A), GetFunctionCPUUsage(B)))
  
  --/script SetCVar("scriptProfile", value)]]
end

local startup_time
local please_donate_enabled = true

function QuestHelper:OnEvent(event)
  if event == "VARIABLES_LOADED" then
    local tstart = GetTime()
    self:Initialize()
    QH_Timeslice_Increment(GetTime() - tstart, "init")
  end

  local tstart = GetTime()
  
  if event == "GOSSIP_SHOW" then
    local name, id = UnitName("npc"), self:GetUnitID("npc")
    if name and id then
      self:GetObjective("monster", name).o.id = id
      --self:TextOut("NPC: "..name.." = "..id)
    end
  end

  if event == "PLAYER_TARGET_CHANGED" then
    local name, id = UnitName("target"), self:GetUnitID("target")
    if name and id then
      self:GetObjective("monster", name).o.id = id
      --self:TextOut("Target: "..name.." = "..id)
    end

    if UnitExists("target") and UnitIsVisible("target") and UnitCreatureType("target") ~= "Critter" and not UnitIsPlayer("target") and not UnitPlayerControlled("target") then
      local index, x, y = self:UnitPosition("target")

      if index then -- Might not have a position if inside an instance.
        local w = 0.1

        -- Modify the weight based on how far they are from us.
        -- We don't know the exact location (using our own location), so the farther, the less sure we are that it's correct.
        if CheckInteractDistance("target", 3) then w = 1
        elseif CheckInteractDistance("target", 2) then w = 0.89
        elseif CheckInteractDistance("target", 1) or CheckInteractDistance("target", 4) then w = 0.33 end

        local monster_objective = self:GetObjective("monster", UnitName("target"))
        self:AppendObjectivePosition(monster_objective, index, x, y, w)

        monster_objective.o.faction = (UnitFactionGroup("target") == "Alliance" and 1) or
                                      (UnitFactionGroup("target") == "Horde" and 2) or nil

        local level = UnitLevel("target")
        if level and level >= 1 then
          local w = monster_objective.o.levelw or 0
          monster_objective.o.level = ((monster_objective.o.level or 0)*w+level)/(w+1)
          monster_objective.o.levelw = w+1
        end
      end
    end
  end

  if event == "LOOT_OPENED" then
    local target = UnitName("target")
    if target and UnitIsDead("target") and UnitCreatureType("target") ~= "Critter" and not UnitIsPlayer("target") and not UnitPlayerControlled("target") then
      local index, x, y = self:UnitPosition("target")

      local monster_objective = self:GetObjective("monster", target)
      monster_objective.o.looted = (monster_objective.o.looted or 0) + 1

      if index then -- Might not have a position if inside an instance.
        self:AppendObjectivePosition(monster_objective, index, x, y)
      end

      for i = 1, GetNumLootItems() do
        local icon, name, number, rarity = GetLootSlotInfo(i)
        if name then
          if number and number >= 1 then
            self:AppendItemObjectiveDrop(self:GetObjective("item", name), name, target, number)
          else
            local total = (name:match(COPPER_AMOUNT:gsub("%%d", "%(%%d+%)")) or 0) +
                          (name:match(SILVER_AMOUNT:gsub("%%d", "%(%%d+%)")) or 0) * 100 +
                          (name:match(GOLD_AMOUNT:gsub("%%d", "%(%%d+%)")) or 0) * 10000

            if total > 0 then
              self:AppendObjectiveDrop(self:GetObjective("item", "money"), target, total)
            end
          end
        end
      end
    else
      local container = nil

      -- Go through the players inventory and look for a locked item, we're probably looting it.
      for bag = 0,NUM_BAG_SLOTS do
        for slot = 1,GetContainerNumSlots(bag) do
          local link = GetContainerItemLink(bag, slot)
          if link and select(3, GetContainerItemInfo(bag, slot)) then
            if container == nil then
              -- Found a locked item and haven't previously assigned to container, assign its name, or false if we fail to parse it.
              container = select(3, string.find(link, "|h%[(.+)%]|h|r")) or false
            else
              -- Already tried to assign to a container. If there are multiple locked items, we give up.
              container = false
            end
          end
        end
      end

      if container then
        local container_objective = self:GetObjective("item", container)
        container_objective.o.opened = (container_objective.o.opened or 0) + 1

        for i = 1, GetNumLootItems() do
          local icon, name, number, rarity = GetLootSlotInfo(i)
          if name and number >= 1 then
            self:AppendItemObjectiveContainer(self:GetObjective("item", name), container, number)
          end
        end
      else
        -- No idea where the items came from.
        local index, x, y = self:PlayerPosition()

        if index then
          for i = 1, GetNumLootItems() do
            local icon, name, number, rarity = GetLootSlotInfo(i)
            if name and number >= 1 then
              self:AppendItemObjectivePosition(self:GetObjective("item", name), name, index, x, y)
            end
          end
        end
      end
    end
  end

  if event == "CHAT_MSG_SYSTEM" then
    local home_name = self:convertPattern(ERR_DEATHBIND_SUCCESS_S)(arg1)
    if home_name then
      if self.i then
        self:TextOut(QHText("HOME_CHANGED"))
        self:TextOut(QHText("WILL_RESET_PATH"))

        local home = QuestHelper_Home
        if not home then
          home = {}
          QuestHelper_Home = home
        end

        home[1], home[2], home[3], home[4] = self.i, self.x, self.y, home_name
        self.defered_graph_reset = true
      end
    end
  end

  if event == "CHAT_MSG_ADDON" then
    if arg1 == "QHpr" and (arg3 == "PARTY" or arg3 == "WHISPER") and arg4 ~= UnitName("player") then
      self:HandleRemoteData(arg2, arg4)
    end
  end

  if event == "PARTY_MEMBERS_CHANGED" then
    self:HandlePartyChange()
  end

  if event == "QUEST_LOG_UPDATE" or
     event == "PLAYER_LEVEL_UP" or
     event == "PARTY_MEMBERS_CHANGED" then
    self.defered_quest_scan = true
  end

  if event == "QUEST_DETAIL" then
    if not self.quest_giver then self.quest_giver = {} end
    local npc = UnitName("npc")
    if npc then
      -- Some NPCs aren't actually creatures, and so their positions might not be marked by PLAYER_TARGET_CHANGED.
      local index, x, y = self:UnitPosition("npc")

      if index then -- Might not have a position if inside an instance.
        local npc_objective = self:GetObjective("monster", npc)
        self:AppendObjectivePosition(npc_objective, index, x, y)
        self.quest_giver[GetTitleText()] = npc
      end
    end
  end

  if event == "QUEST_COMPLETE" or event == "QUEST_PROGRESS" then
    local quest = GetTitleText()
    if quest then
      local level, hash = self:GetQuestLevel(quest)
      if not level or level < 1 then
        --self:TextOut("Don't know quest level for ".. quest.."!")
        return
      end
      local q = self:GetQuest(quest, level, hash)

      if q.need_hash then
        q.o.hash = hash
      end

      local unit = UnitName("npc")
      if unit then
        q.o.finish = unit
        q.o.pos = nil

        -- Some NPCs aren't actually creatures, and so their positions might not be marked by PLAYER_TARGET_CHANGED.
        local index, x, y = self:UnitPosition("npc")
        if index then -- Might not have a position if inside an instance.
          local npc_objective = self:GetObjective("monster", unit)
          self:AppendObjectivePosition(npc_objective, index, x, y)
        end
      elseif not q.o.finish then
        local index, x, y = self:PlayerPosition()
        if index then -- Might not have a position if inside an instance.
          self:AppendObjectivePosition(q, index, x, y)
        end
      end
    end
  end

  if event == "MERCHANT_SHOW" then
    local npc_name = UnitName("npc")
    if npc_name then
      local npc_objective = self:GetObjective("monster", npc_name)
      local index = 1
      while true do
        local item_name = GetMerchantItemInfo(index)
        if item_name then
          index = index + 1
          local item_objective = self:GetObjective("item", item_name)
          if not item_objective.o.vendor then
            item_objective.o.vendor = {npc_name}
          else
            local known = false
            for i, vendor in ipairs(item_objective.o.vendor) do
              if npc_name == vendor then
                known = true
                break
              end
            end
            if not known then
              table.insert(item_objective.o.vendor, npc_name)
            end
          end
        else
          break
        end
      end
    end
  end

  if event == "TAXIMAP_OPENED" then
    self:taxiMapOpened()
  end
  
  if event == "PLAYER_CONTROL_GAINED" then
    interruptcount = interruptcount + 1
  end

  if event == "BAG_UPDATE" then
    for slot = 1,GetContainerNumSlots(arg1) do
      local link = GetContainerItemLink(arg1, slot)
      if link then
        local id, name = select(3, string.find(link, "|Hitem:(%d+):.-|h%[(.-)%]|h"))
        if name then
          self:GetObjective("item", name).o.id = tonumber(id)
        end
      end
    end
  end
  
  if event == "PLAYER_ENTERING_WORLD" and please_donate_enabled then
    startup_time = GetTime()
    _, month, day, year = CalendarGetDate();
    if year > 2008 or year == 2008 and month > 11 or year == 2008 and month == 11 and day > 24 or year == 2008 and month == 11 and day < 21 then -- don't feel right about pestering people during thanksgiving
      startup_time = nil
      please_donate_enabled = false
    end
  end
  
  QH_Timeslice_Increment(GetTime() - tstart, "event")
end

local map_shown_decay = 0
local delayed_action = 100
--local update_count = 0
local ontaxi = false

function QuestHelper:OnUpdate()
  local tstart = GetTime()

  if please_donate_enabled and startup_time and startup_time + 1 < GetTime() then
    QuestHelper:TextOut(QHText("PLEASE_DONATE"))
    startup_time = nil
    please_donate_enabled = false
  end
  
  if init_cartographer_later and Cartographer_Waypoints then    -- there has to be a better way to do this
    init_cartographer_later = false
    if QuestHelper_Pref.cart_wp then
      self:EnableCartographer()
    end
  end
  
  if not ontaxi and UnitOnTaxi("player") then
    self:flightBegan()
    interruptcount = 0
  elseif ontaxi and not UnitOnTaxi("player") then
    self:flightEnded(interruptcount > 1)
  end
  ontaxi = UnitOnTaxi("player")
  
  -- For now I'm ripping out the update_count code
  --update_count = update_count - 1
  --if update_count <= 0 then

    -- Reset the update count for next time around; this will make sure the body executes every time
    -- when perf_scale >= 1, and down to 1 in 10 iterations when perf_scale < 1, or when hidden.
    --update_count = update_count + (QuestHelper_Pref.hide and 10 or 1/QuestHelper_Pref.perf_scale)

    --if update_count < 0 then
      -- Make sure the count doesn't go perpetually negative; don't know what will happen if it underflows.
      --update_count = 0
    --end

    if self.Astrolabe.WorldMapVisible then
      -- We won't trust that the zone returned by Astrolabe is correct until map_shown_decay is 0.
      map_shown_decay = 2
    elseif map_shown_decay > 0 then
      map_shown_decay = map_shown_decay - 1
    else
      --SetMapToCurrentZone() -- not sure why this existed
    end

    delayed_action = delayed_action - 1
    if delayed_action <= 0 then
      delayed_action = 100
      self:HandlePartyChange()
    end

    local nc, nz, nx, ny = self.Astrolabe:GetCurrentPlayerPosition()
    local tc, tx, ty
    
    if nc and nc ~= -1 then -- We just want the raw data here, before we've done anything clever.
      tc, tx, ty = self.Astrolabe:GetAbsoluteContinentPosition(nc, nz, nx, ny)
      QuestHelper: Assert(tc and tx and ty)  -- is it true? nobody knows! :D
    end
    
    if nc and nc == self.c and map_shown_decay > 0 and self.z > 0 and self.z ~= nz then
      -- There's a chance Astrolable will return the wrong zone if you're messing with the world map, if you can
      -- be seen in that zone but aren't in it.
      local nnx, nny = self.Astrolabe:TranslateWorldMapPosition(nc, nz, nx, ny, nc, self.z)
      if nnx > 0 and nny > 0 and nnx < 1 and nny < 1 then
        nz, nx, ny = self.z, nnx, nny
      end
    end
    
    if nc and nc > 0 and nz == 0 and nc == self.c and self.z > 0 then
      nx, ny = self.Astrolabe:TranslateWorldMapPosition(nc, nz, nx, ny, nc, self.z)
      if nx and ny --[[and nx > -0.1 and ny > -0.1 and nx < 1.1 and ny < 1.1]] then -- removing the conditional because I think I can use the data even when it's a little wonky
        nz = self.z
      else
        nc, nz, nx, ny = nil, nil, nil, nil
      end
    end

    if nc and nz > 0 then
      self.c, self.z, self.x, self.y = nc, nz, nx, ny
      self.i = QuestHelper_IndexLookup[nc][nz]
    end
    
    self.collect_c, self.collect_x, self.collect_y, self.collect_rc, self.collect_rz = tc, tx, ty, nc, nz

    if self.defered_quest_scan and not self.graph_in_limbo then
      self.defered_quest_scan = false
      self:ScanQuestLog()
    end

    QH_Timeslice_Toggle("routing", not not self.c)

    local level = UnitLevel("player")
    if level >= 58 and self.player_level < 58 then
      self.defered_graph_reset = true
    end
    self.player_level = level

    self:PumpCommMessages()
  --end
  
  QH_Collector_OnUpdate()
  
  QH_Timeslice_Increment(GetTime() - tstart, "onupdate")
  
  QH_Timeslice_Work()
end

-- Some or all of these may be nil. c,x,y should be enough for a location - c is the pure continent (currently either 0 or 3 for Azeroth or Outland) and x,y are the coordinates within that continent.
-- rc and rz are the continent and zone that Questhelper thinks it's within. For various reasons, this isn't perfect. TODO: Base it off the map zone name identifiers instead of the map itself?
function QuestHelper:RetrieveRawLocation()
  return self.collect_c, self.collect_x, self.collect_y, self.collect_rc, self.collect_rz 
end

QuestHelper:RegisterEvent("VARIABLES_LOADED")
QuestHelper:SetScript("OnEvent", QuestHelper.OnEvent)
