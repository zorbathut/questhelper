function QuestHelper:GetQuestLogObjective(quest_index, objective_index)
  local text, category, done = GetQuestLogLeaderBoard(objective_index, quest_index)
  local _, _, wanted, have, need = string.find(text, "%s*(.+)%s*:%s*(.+)%s*/%s*(.+)%s*")
  local verb
  if not need then
    have = 0
    need = 1
  end
  if done then
    have = need
  end
  if category == "monster" then
    local start = string.find(wanted, "%sslain$", -6)
    if start then
      wanted = string.sub(wanted, 1, start-1)
      verb = "Slay"
    end
  elseif category == "item" then
    verb = "Acquire"
  end
  
  return category, verb, wanted or text, tonumber(have) or have, tonumber(need) or need
end

function QuestHelper:GetQuestLevel(quest_name)
  local index = 1
  while true do
    local title, level = GetQuestLogTitle(index)
    if not title then return 0 end
    if title == quest_name then
      local original_entry = GetQuestLogSelection()
      SelectQuestLogEntry(index)
      local hash = self:HashString(select(2, GetQuestLogQuestText()))
      SelectQuestLogEntry(original_entry)
      return level, hash
    end
    index = index + 1
  end
end

function QuestHelper:ItemIsForQuest(item_object, item_name)
  if not item_object.o.quest then
    return nil
  else
    for quest, lq in pairs(self.quest_log) do
      if lq.goal then
        for i, lo in ipairs(lq.goal) do
          if lo.category == "item" and lo.wanted == item_name then
            return quest
          end
        end
      end
    end
  end
  return nil
end

local first_time = true

function QuestHelper:ScanQuestLog()
  local original_entry = GetQuestLogSelection()
  local quests = self.quest_log
  
  local party_levels = self.party_levels
  if not party_levels then
    party_levels = {}
    self.party_levels = party_levels
  end
  
  local level_average = UnitLevel("player")
  local users = 1
  
  if not QuestHelper_Pref.solo then
    for n=1,4 do
      local level = UnitLevel("party"..n)
      
      if level and level > 0 then
        level_average = level_average + level
        users = users + 1
      end
    end
  end
  
  level_average = level_average / users
  
  for n = 1,5 do
    party_levels[n] = level_average+15-15*math.pow(n/users, 0.4)
  end
  
  for i, quest in pairs(quests) do
    -- Will set this to false if the player still has it.
    quest.removed = true
  end
  
  local index = 1
  while true do
    local title, level, qtype, players, header, collapsed, status, daily = GetQuestLogTitle(index)
    
    if not title then break end
    
    players = math.min(5, math.max(1, (players and players ~= 0 and players) or (qtype ~= nil and 5) or 1))
    
    if not header then
      SelectQuestLogEntry(index)
      local hash = self:HashString(select(2, GetQuestLogQuestText()))
      local quest = self:GetQuest(title, level, hash)
      local lq = quests[quest]
      local is_new = false
      
      local ignored = party_levels[math.min(5, math.max(1, players or (qtype and 5) or 1))]+QuestHelper_Pref.level < level
      
      if self.quest_giver and self.quest_giver[title] then
        quest.o.start = self.quest_giver[title]
        self.quest_giver[title] = nil
      end
      
      if not lq then
        lq = {}
        
        quests[quest] = lq
        
        if GetQuestLogTimeLeft() then
          -- Quest has a timer, so give it a higher than normal priority.
          self:SetObjectivePriority(quest, 2)
        else
          -- Use a normal priority.
          self:SetObjectivePriority(quest, 3)
        end
        
        
        -- Can't add the objective here, if we don't have it depend on the objectives
        -- first it'll get added and possibly not be doable.
        -- We'll add it after the objectives are determined.
        is_new = true
      end
      
      lq.removed = false
      
      if GetNumQuestLeaderBoards(index) > 0 then
        if not lq.goal then lq.goal = {} end
        for objective = 1, GetNumQuestLeaderBoards(index) do
          local lo = lq.goal[objective]
          if not lo then lo = {} lq.goal[objective] = lo end
          local category, verb, wanted, have, need = self:GetQuestLogObjective(index, objective)
          
          if (category == "item" and wanted == " ") or
             (category == "monster" and wanted == "slain") then
            self.defered_quest_scan = true
          elseif not lo.objective then
            -- objective is new.
            lo.objective = self:GetObjective(category, wanted)
            lo.objective.o.quest = true -- If I ever decide to prune the DB, I'll have the stuff actually used in quests marked.
            self:ObjectiveObjectDependsOn(quest, lo.objective)
            
            if category == "item" then
              -- So the objective knows in what context we're getting the item.
              lo.objective.quest = quest
            end
            
            if verb then
              lo.reason = verb.." "..self:HighlightText(wanted).." for quest "..self:HighlightText(title).."."
            else
              lo.reason = self:HighlightText(wanted).." for quest "..self:HighlightText(title).."."
            end
            
            lo.category = category
            lo.wanted = wanted
            lo.have = have
            lo.need = need
            
            QuestHelper:SetObjectiveProgress(lo.objective, UnitName("player"), have, need)
            
            if have ~= need then -- If the objective isn't complete, watch it.
              lo.objective:Share()
              self:AddObjectiveWatch(lo.objective, lo.reason)
            end
          elseif lo.have ~= have then
            QuestHelper:SetObjectiveProgress(lo.objective, UnitName("player"), have, need)
            
            if lo.objective.peer then
              for u, l in pairs(lo.objective.peer) do
                -- Peers don't know about our progress.
                lo.objective.peer[u] = math.min(l, 2)
              end
            end
            
            if have == need or (type(have) == "number" and have > lo.have) then
              if category == "item" then
                self:AppendItemObjectivePosition(lo.objective, wanted, self:PlayerPosition())
              else
                self:AppendObjectivePosition(lo.objective, self:PlayerPosition())
              end
            end
            
            if lo.have == need then -- The objective was done, but now its not.
              lo.objective:Share()
              self:AddObjectiveWatch(lo.objective, lo.reason)
            elseif have == need then -- The objective is now finished.
              lo.objective:Unshare()
              self:RemoveObjectiveWatch(lo.objective, lo.reason)
            end
            
            lo.have = have
          end
          
          if lo.objective then -- Might not have loaded the objective yet, if it wasn't in the local cache and we defered loading it.
            lo.objective.filter_level = ignored
            lo.objective.filter_done = true
          end
        end
      else
        quest.goal = nil
      end
      
      if is_new then
        lq.reason = "Turn in quest "..self:HighlightText(title).."."
        quest:Share()
        self:AddObjectiveWatch(quest, lq.reason)
      end
    end
    index = index + 1
  end
  
  for quest, lq in pairs(quests) do
    if lq.removed then
      if lq.goal then
        for i, lo in ipairs(lq.goal) do
          if lo.objective and lo.have ~= lo.need then
            QuestHelper:SetObjectiveProgress(lo.objective, UnitName("player"), nil, nil)
            
            lo.objective:Unshare()
            self:RemoveObjectiveWatch(lo.objective, lo.reason)
          end
        end
      end
      
      quest:Unshare()
      self:RemoveObjectiveWatch(quest, lq.reason)
      quests[quest] = nil
    end
  end
  
  if first_time then
    first_time = false
    self:ForceRouteUpdate(3)
  end
  
  SelectQuestLogEntry(original_entry)
end
