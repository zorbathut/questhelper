QuestHelper = CreateFrame("Frame", "QuestHelper", nil)

-- Just to make sure it's always 'seen' (there's nothing that can be seen, but still...), and therefore always updating.
QuestHelper:SetFrameStrata("TOOLTIP")

QuestHelper_SaveVersion = 7
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
  share = true,
  scale = 1,
  solo = false,
  comm = false,
  show_ants = true,
  level = 2,
  hide = false,
  cart_wp = true,
  locale = GetLocale() -- This variable is used for display purposes, and has nothing to do with the collected data.
 }

QuestHelper_FlightInstructors = {}
QuestHelper_FlightLinks = {}
QuestHelper_FlightRoutes = {}
QuestHelper_KnownFlightRoutes = {}

QuestHelper.tooltip = CreateFrame("GameTooltip", "QuestHelperTooltip", nil, "GameTooltipTemplate")
QuestHelper.objective_objects = {}
QuestHelper.user_objectives = {}
QuestHelper.quest_objects = {}
QuestHelper.player_level = 1
QuestHelper.locale = QuestHelper_Locale
QuestHelper.faction = (UnitFactionGroup("player") == FACTION_ALLIANCE and 1) or
                      (UnitFactionGroup("player") == FACTION_HORDE and 2)
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

function QuestHelper:OnEvent(event)
  if event == "VARIABLES_LOADED" then
    QHFormatSetLocale(QuestHelper_Pref.locale or GetLocale())
    if not QuestHelper_UID then
      QuestHelper_UID = self:CreateUID()
    end
    QuestHelper_SaveDate = time()
    
    QuestHelper_BuildZoneLookup()
    
    if QuestHelper_Locale ~= GetLocale() then
      self:TextOut(QHText("LOCALE_ERROR"))
      return
    end
    
    self.Astrolabe = DongleStub("Astrolabe-0.4")
    
    if not self:ZoneSanity() then
      self:TextOut(QHText("ZONE_LAYOUT_ERROR"))
      message("QuestHelper: "..QHText("ZONE_LAYOUT_ERROR"))
      return
    end
    
    QuestHelper_UpgradeDatabase(_G)
    QuestHelper_UpgradeComplete()
    
    if QuestHelper_SaveVersion ~= 7 then
      self:TextOut(QHText("DOWNGRADE_ERROR"))
      return
    end
    
    self:ResetPathing()
    
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
    self:RegisterEvent("PLAYER_CONTROL_LOST")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("CHAT_MSG_SYSTEM")
    
    self:SetScript("OnUpdate", self.OnUpdate)
    
    for key, def in pairs(QuestHelper_DefaultPref) do
      if QuestHelper_Pref[key] == nil then
        QuestHelper_Pref[key] = def
      end
    end
    
    self.player_level = UnitLevel("player")
    
    if QuestHelper_Pref.share and not QuestHelper_Pref.solo then
      self:EnableSharing()
    end
    
    if QuestHelper_Pref.hide then
      self.map_overlay:Hide()
    end
    
    self:HandlePartyChange()
    self:Nag()
    
    for locale in pairs(QuestHelper_StaticData) do
      if locale ~= self.locale then
        -- Will delete references to locales you don't use.
        QuestHelper_StaticData[locale] = nil
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
    
    collectgarbage("collect") -- Free everything we aren't using.
    
    if self.debug_objectives then
      for name, data in pairs(self.debug_objectives) do
        self:LoadDebugObjective(name, data)
      end
    end
  end
  
  if event == "PLAYER_TARGET_CHANGED" then
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
        monster_objective.o.faction = UnitFactionGroup("target")
        
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
            local total = 0
            local _, _, amount = string.find(name, "(%d+) "..COPPER)
            if amount then total = total + amount end
            _, _, amount = string.find(name, "(%d+) "..SILVER)
            if amount then total = total + amount * 100 end
            _, _, amount = string.find(name, "(%d+) "..GOLD)
            if amount then total = total + amount * 10000 end
            
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
  
  --[[
  if event == "PLAYER_CONTROL_LOST" then
    if self.flight_origin then
      -- We'll check to make sure we were actually on a taxi when we regain control.
      self.flight_start_time = GetTime()
    end
  end
  
  if event == "PLAYER_CONTROL_GAINED" then
    if (self.was_flying or UnitOnTaxi("player")) and self.flight_origin and self.flight_start_time then
      local elapsed = GetTime()-self.flight_start_time
      if elapsed > 0 then
        local index, x, y = self:PlayerPosition()
        local list = QuestHelper_FlightInstructors[self.faction]
        local end_zone = nil
        if list then
          local distance
          for zone, npc in pairs(list) do
            local npc_objective = self:GetObjective("monster", npc)
            
            if npc_objective:Known() then
              npc_objective:PrepareRouting()
              
              local pos = npc_objective:Position()
              
              if pos then
                local d = self:ComputeTravelTime(self.pos, pos)
                if not end_zone or d < distance then
                  end_zone, distance = zone, d
                end
              end
              
              npc_objective:DoneRouting()
            end
          end
          if end_zone and distance > 5 then
            end_zone = nil
          end
        end
        
        if end_zone then
          if self.flight_hashs[end_zone] then
            self:GetFlightPathData(index, self.flight_origin, end_zone, self.flight_hashs[end_zone]).real = elapsed
          else
            self:TextOut("You shouldn't have been able to fly here. And yet here you are. Reality will never be the same again.")
          end
        else
          self:TextOut(QHText("TALK_TO_FLIGHT_MASTER"))
          if not self.pending_flight_data then
            self.pending_flight_data = {}
          end
          table.insert(self.pending_flight_data, {self.flight_origin, self.flight_hashs, elapsed, index, x, y})
          self.flight_hashs = nil
        end
      else
        self:TextOut("You arrived at your destination before you left. I love a good temporal paradox!")
      end
    end
    self.was_flying, self.flight_origin, self.flight_start_time = nil, nil, nil
  end
  
  if event == "TAXIMAP_OPENED" then
    local flight_instructor = UnitName("npc")
    
    local start_index = nil
    for i = 1,NumTaxiNodes() do
      if GetNumRoutes(i) == 0 then
        start_index = i
        break
      end
    end
    
    if start_index ~= nil then
      local start_location = TaxiNodeName(start_index)
      self.flight_origin = start_location
      
      if flight_instructor and start_location then
        local list = QuestHelper_FlightInstructors[self.faction]
        if not list then
          list = {}
          QuestHelper_FlightInstructors[self.faction] = list
        end
        if list[start_location] ~= flight_instructor then
          --self:TextOut("Recorded that "..flight_instructor.." is the "..self.faction.." flight instructor for "..start_location..".")
          list[start_location] = flight_instructor
        end
      end
      
      if self.pending_flight_data then
        local index, x, y = self:UnitPosition("npc")
        for i, data in ipairs(self.pending_flight_data) do
          if self:Distance(index, x, y, data[4], data[5], data[6]) < 20 then
            self:TextOut(QHText("TALK_TO_FLIGHT_MASTER_COMPLETE"))
            self.flight_hashs = data[2]
            self:GetFlightPathData(index, data[1], start_location, self.flight_hashs[start_location]).real = data[3]
            table.remove(self.pending_flight_data, i)
            break
          end
        end
      end
      
      if not self.flight_hashs then
        self.flight_hashs = {}
      else
        while #self.flight_hashs > 0 do
          table.remove(self.flight_hashs)
        end
      end
      
      local altered = false
      
      for i = 1,NumTaxiNodes() do
        local routes = GetNumRoutes(i)
        -- Why Blizzard would tell me there are nine hundred million route nodes instead of returning
        -- nil when you can't get there is beyond me.
        if i ~= start_index and routes and routes > 0 and routes < 100 then
          local required_time = 0
          local path_string = "PATH"
          for j=1,routes do
            path_string=string.format("%s:%d,%d",
                                      path_string,
                                      math.floor(TaxiGetDestX(i,j)*100+0.5),
                                      math.floor(TaxiGetDestY(i,j)*100+0.5))
            
            local x, y = TaxiGetSrcX(i,j)-TaxiGetDestX(i,j), TaxiGetSrcY(i,j)-TaxiGetDestY(i,j)
            
            -- It appears that the coordinates do actually use a square aspect ratio. That's a pleasant surprise.
            -- TODO: I'm concerned this might be affected by scale, need to check this.
            required_time = required_time + math.sqrt(x*x+y*y)
          end
          
          local hash = self:HashString(path_string)
          local end_location = TaxiNodeName(i)
          local index = QuestHelper_IndexLookup[self.c][0]
          
          self.flight_hashs[end_location] = hash
          altered = self:PlayerKnowsFlightRoute(index, start_location, end_location, hash) or altered
          altered = self:PlayerKnowsFlightRoute(index, end_location, start_location) or altered
          self:GetFlightPathData(index, start_location, end_location, hash).raw = required_time
        end
      end
      
      if altered then
        self:TextOut(QHText("ROUTES_CHANGED"))
        self:TextOut(QHText("WILL_RESET_PATH"))
        self.defered_graph_reset = true
      end
    end
  end
  --]]
  
  if event == "TAXIMAP_OPENED" then
    self:taxiMapOpened()
  end
  
  if event == "PLAYER_CONTROL_GAINED" then
    self:flightEnded()
  end
  
  if event == "PLAYER_CONTROL_LOST" then
    self:flightBegan()
  end
end

local map_shown_decay = 0
local delayed_action = 100

function QuestHelper:OnUpdate()
  if self.Astrolabe.WorldMapVisible then
    -- We won't trust that the zone returned by Astrolabe is correct until map_shown_decay is 0.
    map_shown_decay = 2
  elseif map_shown_decay > 0 then
    map_shown_decay = map_shown_decay - 1
  else
    SetMapToCurrentZone()
  end
  
  delayed_action = delayed_action - 1
  if delayed_action <= 0 then
    delayed_action = 100
    self:HandlePartyChange()
  end
  
  
  local nc, nz, nx, ny = self.Astrolabe:GetCurrentPlayerPosition()
  
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
    if nx and ny and nx > -0.1 and ny > -0.1 and nx < 1.1 and ny < 1.1 then
      nz = self.z
    else
      nc, nz, nx, ny = nil, nil, nil, nil
    end
  end
  
  if nc and nz > 0 then
    if UnitOnTaxi("player") then
      self.was_flying = true
    end
    
    if nc > 0 and nz > 0 then
      self.c, self.z, self.x, self.y = nc or self.c, nz or self.z, nx or self.x, ny or self.y
      self.i = QuestHelper_IndexLookup[self.c][self.z]
      
      self.pos[1] = self.zone_nodes[self.i]
      self.pos[3], self.pos[4] = self.Astrolabe:TranslateWorldMapPosition(self.c, self.z, self.x, self.y, self.c, 0)
      assert(self.pos[3])
      assert(self.pos[4])
      self.pos[3] = self.pos[3] * self.continent_scales_x[self.c]
      self.pos[4] = self.pos[4] * self.continent_scales_y[self.c]
      for i, n in ipairs(self.pos[1]) do
        if not n.x then
          for i, j in pairs(n) do self:TextOut("[%q]=%s %s", i, type(j), tostring(j) or "???") end
          assert(false)
        end
        local a, b = n.x-self.pos[3], n.y-self.pos[4]
        self.pos[2][i] = math.sqrt(a*a+b*b)
      end
    end
  end
  
  if self.c and self.c > 0 and self.z > 0 then
    if self.defered_quest_scan then
      self.defered_quest_scan = false
      self:ScanQuestLog()
    end
    
    if not self.hide and coroutine.status(self.update_route) ~= "dead" then
      local state, err = coroutine.resume(self.update_route, self)
      if not state then self:TextOut("|cffff0000The routing co-routine just exploded|r: |cffffff77"..err.."|r") end
    end
  end
  
  local level = UnitLevel("player")
  if level >= 58 and self.player_level < 58 then
    self.defered_graph_reset = true
  end
  self.player_level = level
  
  self:PumpCommMessages()
end

QuestHelper:RegisterEvent("VARIABLES_LOADED")
QuestHelper:SetScript("OnEvent", QuestHelper.OnEvent)
