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
    else
      start = string.find(wanted, "s%sCollected$", -11)
      if start then
        wanted = string.sub(wanted, 1, start-1)
        verb = "Collect"
      end
    end
  elseif category == "item" then
    verb = "Acquire"
  end
  
  return category, verb or "<VERB>", wanted or text, tonumber(have) or have, tonumber(need) or need
end

function QuestHelper:GetQuestLevel(quest_name)
  local index = 1
  while true do
    local title, level = GetQuestLogTitle(index)
    if not title then return 0 end
    if title == quest_name then
      SelectQuestLogEntry(index)
      return level, self:HashString(select(2, GetQuestLogQuestText()))
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
  local quests = self.quest_log
  
  local party_levels = self.party_levels
  if not party_levels then
    party_levels = {}
    self.party_levels = party_levels
  end
  
  party_levels[1] = UnitLevel("player")
  
  for n=1,4 do
    party_levels[n+1] = UnitLevel("party"..n)
    
    if not party_levels[n+1] or party_levels[n+1] <= 0 then
      local sum = 0
      for m = 1,n do
        sum = sum + party_levels[m]
      end
      party_levels[n+1] = sum/n*3/5
    end
  end
  
  table.sort(party_levels, function(a, b) return a > b end)
  
  for n = 5,1,-1 do
    local sum = 0
    for m = 1,n do
      sum = sum + party_levels[m]
    end
    party_levels[n] = sum/n
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
      
      local ignored = party_levels[math.min(5, math.max(1, players or (qtype and 5) or 1))]+3 < level
      
      -- quest.auto_ignore = ignored
      
      if self.quest_giver and self.quest_giver[title] then
        quest.o.start = self.quest_giver[title]
        self.quest_giver[title] = nil
      end
      
      if not lq then
        lq = {}
        
        quests[quest] = lq
        
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
              lo.objective.item = wanted
            end
            
            lo.reason = verb.." "..self:HighlightText(wanted).." for quest "..self:HighlightText(title).."."
            
            lo.category = category
            lo.wanted = wanted
            lo.have = have
            lo.need = need
            if have ~= need then -- If the objective isn't complete, watch it.
              self:AddObjectiveWatch(lo.objective, lo.reason)
            end
          elseif lo.have ~= have then
            if have == need or (type(have) == "number" and have > lo.have) then
              if category == "item" then
                self:AppendItemObjectivePosition(lo.objective, wanted, self:PlayerPosition())
              else
                self:AppendObjectivePosition(lo.objective, self:PlayerPosition())
              end
            end
            if lo.have == need then -- The objective was done, but now its not.
              self:AddObjectiveWatch(lo.objective, lo.reason)
            elseif have == need then -- The objective is now finished.
              self:RemoveObjectiveWatch(lo.objective, lo.reason)
            end
            lo.have = have
          end
          
          if lo.objective then -- Might not have loaded the objective yet, if it wasn't in the local cache and we defered loading it.
            lo.objective.auto_ignore = ignored
          end
        end
      else
        quest.goal = nil
      end
      
      if is_new then
        lq.reason = "Turn in quest "..self:HighlightText(title).."."
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
            self:RemoveObjectiveWatch(lo.objective, lo.reason)
          end
        end
      end
      self:RemoveObjectiveWatch(quest, lq.reason)
      quests[quest] = nil
    end
  end
  
  if first_time then
    first_time = false
    self:ForceRouteUpdate(3)
  end
end
