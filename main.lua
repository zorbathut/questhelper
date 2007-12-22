if GetLocale() ~= "enUS" then
  DEFAULT_CHAT_FRAME:AddMessage("|cffffcc77QuestHelper: |rI'm not ready to support your locale yet. Sorry!", 1.0, 0.6, 0.2)
  return
end

QuestHelper = CreateFrame("Frame", "QuestHelper", UIParent)
QuestHelper.Astrolabe = DongleStub("Astrolabe-0.4")

QuestHelper_SaveVersion = 3
QuestHelper_Locale = GetLocale()
QuestHelper_Quests = {}
QuestHelper_Objectives = {}

-- Character ID identifies the player's charaters by a number instead of a Name/Realm pair. You know, in case
-- they want to submit their data anonymously without references to their characters in them.
-- This way the most I can tell is how many characters the submitter has, which probably isn't a big deal.
QuestHelper_NextCharacterID = 1
QuestHelper_CharacterID = nil

QuestHelper_FlightInstructors = {}
QuestHelper_FlightRoutes = {}
QuestHelper_KnownFlightRoutes = {}

QuestHelper_ZoneTransition = {}

QuestHelper.tooltip = CreateFrame("GameTooltip", "QuestHelperTooltip", nil, "GameTooltipTemplate")
QuestHelper.objective_objects = {}
QuestHelper.user_objectives = {}
QuestHelper.quest_objects = {}
QuestHelper.locale = GetLocale()
QuestHelper.faction = UnitFactionGroup("player")
QuestHelper.route = {}
QuestHelper.to_add = {}
QuestHelper.to_remove = {}
QuestHelper.quest_log = {}
QuestHelper.pos = {nil, {}, 0, 0, 1, "You are here.", 0}

function QuestHelper:GetCharacterID()
  if QuestHelper_CharacterID == nil then
    QuestHelper_CharacterID = QuestHelper_NextCharacterID
    QuestHelper_NextCharacterID = QuestHelper_NextCharacterID + 1
  end
  return QuestHelper_NextCharacterID
end

function QuestHelper:GetFlightPathData(c, start_string, end_string, hash)
  local cont = QuestHelper_FlightRoutes[c]
  if not cont then
    cont = {}
    QuestHelper_FlightRoutes[c] = cont
  end
  local map = cont[start_string]
  if not map then
    map = {}
    cont[start_string] = map
  end
  local hash_list = map[end_string]
  if not hash_list then
    hash_list = {}
    map[end_string] = hash_list
  end
  local data = hash_list[hash]
  if not data then
    data = {}
    hash_list[hash] = data
  end
  return data
end

function QuestHelper:GetFallbackFlightPathData(c, start_string, end_string, hash)
  local l = QuestHelper_StaticData[self.locale]
  local cont = l and l.flight_routes
  local map = cont and cont[start_string]
  local hash_list = map and map[end_string]
  return hash_list and hash_list[hash]
end

function QuestHelper:PlayerKnowsFlightRoute(c, start_string, end_string, hash)
  local cont = QuestHelper_KnownFlightRoutes[c]
  if not cont then
    cont = {}
    QuestHelper_KnownFlightRoutes[c] = cont
  end
  local map = cont[start_string]
  if not map then
    map = {}
    cont[start_string] = map
  end
  
  if not map[end_string] or (hash and hash ~= map[end_string]) then
    map[end_string] = hash or map[end_string] or 0
    return true
  end
  
  return false
end

function QuestHelper:ComputeRawFlightScaler(c)
  local real, raw = 0, 0
  
  if QuestHelper_FlightRoutes[c] then
    for start, end_list in pairs(QuestHelper_FlightRoutes[c]) do
      for dest, hash_list in pairs(end_list) do
        for hash, data in pairs(hash_list) do
          if data.raw and data.real then
            real = real + data.real
            raw = raw + data.raw
          end
        end
      end
    end
  end
  
  if QuestHelper_StaticData[self.locale] and QuestHelper_StaticData[self.locale].flight_routes[c] then
    for start, end_list in pairs(QuestHelper_StaticData[self.locale].flight_routes[c]) do
      for dest, hash_list in pairs(end_list) do
        for hash, data in pairs(hash_list) do
          if data.raw and data.real then
            real = real + data.real
            raw = raw + data.raw
          end
        end
      end
    end
  end
  
  if raw > 0 then
    return real/raw
  end
end

function QuestHelper:GetFlightTime(c, start_string, end_string)
  local hash1, hash2
  if QuestHelper_KnownFlightRoutes[c] and
     QuestHelper_KnownFlightRoutes[c][start_string] and 
     QuestHelper_KnownFlightRoutes[c][start_string][end_string] then
    hash1 = QuestHelper_KnownFlightRoutes[c][start_string][end_string]
  end
  
  local data1 = hash1 and hash1 ~= 0 and self:GetFlightPathData(c, start_string, end_string, hash1)
  
  if data1 and data1.real then -- Have we flown and know the exact time there?
    return data1.real
  end
  
  local fbdata1 = self:GetFallbackFlightPathData(c, start_string, end_string, hash1)
  
  if fbdata1 and fbdata1.real then
    return fbdata1.real
  end
  
  if QuestHelper_KnownFlightRoutes[c] and
     QuestHelper_KnownFlightRoutes[c][end_string] and 
     QuestHelper_KnownFlightRoutes[c][end_string][start_string] then
    hash2 = QuestHelper_KnownFlightRoutes[c][end_string][start_string]
  end
  
  local data2 = hash2 and hash2 ~= 0 and self:GetFlightPathData(c, end_string, start_string, hash2)
  
  if data2 and data2.real then -- Have we flown from there to here? We'll use that time instead.
    return data2.real
  end
  
  local fbdata2 = self:GetFallbackFlightPathData(c, end_string, start_string, hash1)
  
  if fbdata2 and fbdata2.real then
    return fbdata2.real
  end
  
  local scale = self:ComputeRawFlightScaler(c)
  
  if scale then
    if data1 and data1.raw then -- We'll estimate the flight time based on the route distance.
      return data1.raw * scale
    end
    
    if fbdata1 and fbdata1.raw then
      return fbdata1.raw * scale
    end
    
    if data2 and data2.raw then
      return data2.raw * scale
    end
    
    if fbdata2 and fbdata2.raw then
      return fbdata2.raw * scale
    end
  end
  
  -- If we got here, then we have absolutely no idea how long the flight will take.
  -- We'll pretend to know and say three and a half minutes.
  return 210
end

function QuestHelper:OnEvent(event)
  if event == "VARIABLES_LOADED" then
    QuestHelper_UpgradeDatabase(_G)
    
    -- TODO: Just sanity for now, should be able to remove later.
    for c, start_list in pairs(QuestHelper_ZoneTransition) do
      for start, end_list in pairs(start_list) do
        for dest, pos_list in pairs(end_list) do
          local i = 1
          while i <= #pos_list do
            local pos = pos_list[i]
            
            local x, y = QuestHelper.Astrolabe:TranslateWorldMapPosition(c, start, pos[3], pos[4], c, dest)
            
            if x > -0.1 and y > -0.1 and x < 1.1 and y < 1.1 and
               pos[3] > -0.1 and pos[4] > -0.1 and pos[3] < 1.1 and pos[4] < 1.1 then
              i = i + 1
            else
              table.remove(pos_list, i)
            end
          end
        end
      end
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
    
    self:SetScript("OnUpdate", self.OnUpdate)
  end
  
  if event == "PLAYER_TARGET_CHANGED" then
    if UnitExists("target") and UnitIsVisible("target") and UnitCreatureType("target") ~= "Critter" and not UnitIsPlayer("target") and not UnitPlayerControlled("target") then
      local monster_objective = self:GetObjective("monster", UnitName("target"))
      self:AppendObjectivePosition(monster_objective, self:UnitPosition("target"))
      monster_objective.o.faction = UnitFactionGroup("target")
      
      local level = UnitLevel("target")
      if level and level >= 1 then
        local w = monster_objective.o.levelw or 0
        monster_objective.o.level = ((monster_objective.o.level or 0)*w+level)/(w+1)
        monster_objective.o.levelw = w+1
      end
    end
  end
  
  if event == "LOOT_OPENED" then
    local target = UnitName("target")
    if target and UnitIsDead("target") and UnitCreatureType("target") ~= "Critter" and not UnitIsPlayer("target") and not UnitPlayerControlled("target") then
      local monster_objective = self:GetObjective("monster", target)
      monster_objective.o.looted = (monster_objective.o.looted or 0) + 1
      
      self:AppendObjectivePosition(monster_objective, self:UnitPosition("target"))
      
      for i = 1, GetNumLootItems() do
        local icon, name, number, rarity = GetLootSlotInfo(i)
        if name then
          if number and number >= 1 then
            self:AppendItemObjectiveDrop(self:GetObjective("item", name), name, target, number)
          else
            local total = 0
            local _, _, amount = string.find(name, "(%d+) Copper")
            if amount then total = total + amount end
            _, _, amount = string.find(name, "(%d+) Silver")
            if amount then total = total + amount * 100 end
            _, _, amount = string.find(name, "(%d+) Gold")
            if amount then total = total + amount * 10000 end
            
            if total > 0 then
              self:AppendObjectiveDrop(self:GetObjective("item", "money"), target, total)
            end
          end
        end
      end
    else
      for i = 1, GetNumLootItems() do
        local icon, name, number, rarity = GetLootSlotInfo(i)
        if name and number >= 1 then
          self:AppendItemObjectivePosition(self:GetObjective("item", name), name, self:PlayerPosition())
        end
      end
    end
  end
  
  if event == "QUEST_LOG_UPDATE" or
     event == "PLAYER_LEVEL_UP" or
     event == "PARTY_MEMBERS_CHANGED" then
    self.defered_quest_scan = true
  end
  
  if event == "QUEST_DETAIL" then
    if not self.quest_giver then self.quest_giver = {} end
    self.quest_giver[GetTitleText()] = UnitName("npc")
  end
  
  if event == "QUEST_COMPLETE" or event == "QUEST_PROGRESS" then
    local quest = GetTitleText()
    if quest then
      local level, hash = self:GetQuestLevel(quest)
      if not level or level < 1 then
        self:TextOut("Don't know quest level for ".. quest.."!")
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
      elseif not q.o.finish then
        self:AppendObjectivePosition(q, self:PlayerPosition())
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
  
  if event == "PLAYER_CONTROL_LOST" then
    if self.flight_origin then
      -- We'll check to make sure we were actually on a taxi when we regain control.
      self.flight_start_time = time()
    end
  end
  
  if event == "PLAYER_CONTROL_GAINED" then
    if (self.was_flying or UnitOnTaxi("player")) and self.flight_origin and self.flight_start_time then
      local elapsed = time()-self.flight_start_time
      if elapsed > 0 then
        local c, z, x, y = self:PlayerPosition()
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
            end
          end
          if end_zone and distance > 5 then
            end_zone = nil
          end
        end
        
        if end_zone then
          if self.flight_hashs[end_zone] then
            self:GetFlightPathData(c, self.flight_origin, end_zone, self.flight_hashs[end_zone]).real = elapsed
          else
            self:TextOut("You shouldn't have been able to fly here. And yet here you are. Reality will never be the same again.")
          end
        else
          self:TextOut("Please talk to the local flight master.")
          if not self.pending_flight_data then
            self.pending_flight_data = {}
          end
          table.insert(self.pending_flight_data, {self.flight_origin, self.flight_hashs, elapsed, c, z, x, y})
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
        local c, z, x, y = self:UnitPosition("npc")
        for i, data in ipairs(self.pending_flight_data) do
          if self:Distance(c, z, x, y, data[4], data[5], data[6], data[7]) < 20 then
            self:TextOut("Thanks.")
            self.flight_hashs = data[2]
            self:GetFlightPathData(c, data[1], start_location, self.flight_hashs[start_location]).real = data[3]
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
            required_time = required_time + math.sqrt(x*x+y*y)
          end
          
          local hash = self:HashString(path_string)
          local end_location = TaxiNodeName(i)
          
          self.flight_hashs[end_location] = hash
          altered = self:PlayerKnowsFlightRoute(self.c, start_location, end_location, hash) or altered
          altered = self:PlayerKnowsFlightRoute(self.c, end_location, start_location) or altered
          self:GetFlightPathData(self.c, start_location, end_location, hash).raw = required_time
        end
      end
      
      if altered then
        self:TextOut("The flight routes for your character have been altered. Will recalculate world pathing information.")
        self:ResetPathing()
      end
    end
  end
end

function QuestHelper:OnUpdate()
  local nc, nz, nx, ny = self.Astrolabe:GetCurrentPlayerPosition()
  
  if nc and nz > 0 then
    if UnitOnTaxi("player") then
      self.was_flying = true
    elseif nc > 0 and nz > 0 then
      if nc == self.c and nz ~= self.z and nz > 0 and self.z > 0 and
         nx > -0.1 and ny > -0.1 and nx < 1.1 and ny < 1.1 and
         self.x > -0.1 and self.y > -0.1 and self.x < 1.1 and self.y < 1.1 then
        -- Changed zones!
        local distance = self.Astrolabe:ComputeDistance(self.c, self.z, self.x, self.y, nc, nz, nx, ny)
        if distance and distance < 5 then
          local cont = QuestHelper_ZoneTransition[nc]
          if not cont then
            cont = {}
            QuestHelper_ZoneTransition[nc] = cont
          end
          if nz > self.z then
            local from = cont[self.z]
            if not from then from = {} cont[self.z] = from end
            local to = from[nz]
            if not to then to = {} from[nz] = to end
            self:AppendPosition(to, self.c, self.z, self.x, self.y, 1, 1500.0)
          else
            local from = cont[nz]
            if not from then from = {} cont[nz] = from end
            local to = from[self.z]
            if not to then to = {} from[self.z] = to end
            self:AppendPosition(to, nc, nz, nx, ny, 1, 1500.0)
          end
          
          self:TextOut("Zone connection altered. Will recalculate world pathing information.")
          self:ResetPathing()
        end
      end
    end
    
    if nc > 0 and nz > 0 then
      self.c, self.z, self.x, self.y = nc or self.c, nz or self.z, nx or self.x, ny or self.y
      
      self.pos[1] = self.zone_nodes[self.c][self.z]
      self.pos[3], self.pos[4] = self.Astrolabe:TranslateWorldMapPosition(self.c, self.z, self.x, self.y, self.c, 0)
      self.pos[3] = self.pos[3] * self.continent_scales_x[self.c]
      self.pos[4] = self.pos[4] * self.continent_scales_y[self.c]
      for i, n in ipairs(self.pos[1]) do
        local a, b = n.x-self.pos[3], n.y-self.pos[4]
        self.pos[2][i] = math.sqrt(a*a+b*b)
      end
    end
  end
  
  if self.c and self.c > 0 then
    if self.defered_quest_scan then
      self.defered_quest_scan = false
      self:ScanQuestLog()
    end
    
    if coroutine.status(self.update_route) ~= "dead" then
      local state, err = coroutine.resume(self.update_route, self)
      if not state then self:TextOut("|cffff0000The routing co-routine just exploded|r: |cffffff77"..err.."|r") end
    end
  end
end

QuestHelper:RegisterEvent("VARIABLES_LOADED")
QuestHelper:SetScript("OnEvent", QuestHelper.OnEvent)
