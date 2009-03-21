QuestHelper_File["questlog.lua"] = "Development Version"
QuestHelper_Loadtime["questlog.lua"] = GetTime()

do return end -- pretty sure this is all dead

--[[QuestHelper.debug_objectives =
 {
  ["Harbinger of Doom"] =
   {
    cat="quest", what="Harbinger of Doom", sub=
     {
      ["Slay Harbinger Skyriss"] =
       {
        cat="monster", what="Harbinger Skyriss"
       }
     }
   }
 }]]

function QuestHelper:LoadDebugObjective(name, data)
  local obj = self:GetObjective(data.cat, data.what)
  
  self:SetObjectivePriority(obj, 3)
  self:AddObjectiveWatch(obj, name)
  
  if data.sub then
    for name, sdata in pairs(data.sub) do
      self:ObjectiveObjectDependsOn(obj, QuestHelper:LoadDebugObjective(name, sdata))
    end
  end
  
  return obj
end

local ITEM_PATTERN, REPUTATION_PATTERN, MONSTER_PATTERN, OBJECT_PATTERN = false, false, false, false

local function buildPatterns()
  if not ITEM_PATTERN then
    ITEM_PATTERN = QuestHelper:convertPattern(QUEST_OBJECTS_FOUND)
    REPUTATION_PATTERN = QuestHelper:convertPattern(QUEST_FACTION_NEEDED)
    MONSTER_PATTERN = QuestHelper:convertPattern(QUEST_MONSTERS_KILLED)
    OBJECT_PATTERN = QuestHelper:convertPattern(QUEST_OBJECTS_FOUND)
    PLAYER_PATTERN = QuestHelper:convertPattern(QUEST_PLAYERS_KILLED)
    replacePattern = nil
  end
end

function QuestHelper:GetQuestLogObjective(quest_index, objective_index)
  local text, category, done = GetQuestLogLeaderBoard(objective_index, quest_index)
  
  buildPatterns()
  
  local wanted, verb, have, need
  
  if category == "monster" then
    wanted, have, need = MONSTER_PATTERN(text)
    verb = QHText("SLAY_VERB")
  elseif category == "item" then
    wanted, have, need = ITEM_PATTERN(text)
    verb = QHText("ACQUIRE_VERB")
  elseif category == "reputation" then
    wanted, have, need = REPUTATION_PATTERN(text)
  elseif category == "object" then
    wanted, have, need = OBJECT_PATTERN(text)
  elseif category == "event" then
    wanted, have, need = text, 0, 1
  elseif category == "player" then
    wanted, have, need = PLAYER_PATTERN(text)
  else
    QuestHelper:TextOut("Unhandled event type: "..category)
  end
  
  if not wanted then
    verb = nil
    
    _, _, wanted, have, need = string.find(text, "^%s*(.-)%s*:%s*(.-)%s*/%s*(.-)%s*$")
    if not wanted then
      _, _, wanted = string.find(text, "^%s*(.-)%s*$")
      have, need = 0, 1
    end
  end
  
  if not need then need = 1 end
  if done then have = need end
  
  return category, verb, wanted or text, tonumber(have) or have, tonumber(need) or need
end

function QuestHelper:FixedGetQuestLogTitle(index)
  local title, level, qtype, players, header, collapsed, status, daily = GetQuestLogTitle(index)
  
  if title and level then
    local _, _, real_title = string.find(title, "^%["..level.."[^%s]-%]%s?(.+)$")
    title = real_title or title
  end
  
  return title, level, qtype, players, header, collapsed, status, daily
end

function QuestHelper:GetQuestLevel(quest_name)
  local index = 1
  while true do
    local title, level, _, _, header = self:FixedGetQuestLogTitle(index)
    if not title then return 0 end
    if not header and title == quest_name then
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
    local title, level, qtype, players, header, collapsed, status, daily = self:FixedGetQuestLogTitle(index)
    --QuestHelper:TextOut(string.format("Gathering quests - %s %s", tostring(title), tostring(level)))
    
    if not title then break end
    
    if players and players <= 0 then
      players = nil
    end
    
    if not players then
      players = qtype == nil and 1 or 5
    else
      players = math.min(5, math.max(1, players))
    end
    
    -- Quest was failed if status is -1.
    if not header and status ~= -1 then
      SelectQuestLogEntry(index)
      local hash = self:HashString(select(2, GetQuestLogQuestText()))
      local quest = self:GetQuest(title, level, hash)
      local lq = quests[quest]
      local is_new = false
      
      local ignored = party_levels[players]+QuestHelper_Pref.level < level
      
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
        
        
        quest.o.id = self:GetQuestID(index)
        
        -- Can't add the objective here, if we don't have it depend on the objectives
        -- first it'll get added and possibly not be doable.
        -- We'll add it after the objectives are determined.
        is_new = true
      end
      
      lq.index = index
      lq.removed = false
      
      if GetNumQuestLeaderBoards(index) > 0 then
        if not lq.goal then lq.goal = {} end
        for objective = 1, GetNumQuestLeaderBoards(index) do
          local lo = lq.goal[objective]
          if not lo then lo = {} lq.goal[objective] = lo end
          
          local category, verb, wanted, have, need = self:GetQuestLogObjective(index, objective)
          
          if not wanted or not string.find(wanted, "[^%s]") then
            self.defered_quest_scan = true
          elseif not lo.objective then
            -- objective is new.
            lo.objective = self:GetObjective(category, wanted)
            lo.objective.o.quest = true -- If I ever decide to prune the DB, I'll have the stuff actually used in quests marked.
            self:ObjectiveObjectDependsOn(quest, lo.objective)
            
            lo.objective.quest = quest
            
            if verb then
              lo.reason = QHFormat("OBJECTIVE_REASON", verb, wanted, title)
            else
              lo.reason = QHFormat("OBJECTIVE_REASON_FALLBACK", wanted, title)
            end
            
            lo.category = category
            lo.wanted = wanted
            lo.have = have
            lo.need = need
            
            if have ~= need then -- If the objective isn't complete, watch it.
              lo.objective:Share()
              self:AddObjectiveWatch(lo.objective, lo.reason)
            end
          elseif lo.have ~= have then
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
            self:SetObjectiveProgress(lo.objective, UnitName("player"), have, need)
          end
        end
      else
        quest.goal = nil
      end
      
      if is_new then
        lq.reason = QHFormat("OBJECTIVE_REASON_TURNIN", title)
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
            lo.objective:Unshare()
            self:RemoveObjectiveWatch(lo.objective, lo.reason)
          end
          
          self:SetObjectiveProgress(lo.objective, UnitName("player"), nil, nil)
        end
      end
      
      quest:Unshare()
      self:RemoveObjectiveWatch(quest, lq.reason)
      quests[quest] = nil
    end
  end
  
  if first_time then
    first_time = false
    QH_Timeslice_Bonus(15)
  end
  
  SelectQuestLogEntry(original_entry)
  
  if QuestHelper_Pref.track then
    self.tracker:update()
  end
end
