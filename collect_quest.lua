QuestHelper_File["collect_quest.lua"] = "Development Version"

local debug_output = false
if QuestHelper_File["collect_quest.lua"] == "Development Version" then debug_output = true end

local GetQuestType
local GetItemType

local QHCQ

local deebey

function RegisterQuestData(category, location, GetQuestLogWhateverInfo)
  local index = 1
  local localspot
  while true do
    local ilink = GetQuestLogItemLink(category, index)
    if not ilink then break end
    
    if not localspot then if not location["items_" .. category] then location["items_" .. category] = {} end localspot = location["items_" .. category] end
    
    local name, tex, num, qual, usa = GetQuestLogWhateverInfo(index)
    localspot[GetItemType(ilink)] = num
    
    --QuestHelper:TextOut(string.format("%s:%d - %d %s %s", category, index, num, tostring(ilink), tostring(name)))
    
    index = index + 1
  end
end

local complete_suffix = string.gsub(string.gsub(string.gsub(ERR_QUEST_OBJECTIVE_COMPLETE_S, "%%s", ""), "%)", "%%)"), "%(", "%%(")
function pin()
  QuestHelper:TextOut("^.*: (%d+)/(%d+)(" .. complete_suffix .. ")?$")
end

function ScanQuests() -- make it local once we've debugged it
  
  local selected
  local index = 1
  
  local dbx = {}
  
  while true do
    if not GetQuestLogTitle(index) then break end
    
    local qlink = GetQuestLink(index)
    if qlink then
      local id, level = GetQuestType(qlink)
      
      --QuestHelper:TextOut(string.format("%s - %d %d", qlink, id, level))
      
      if not QHCQ[id] then
      --if true then
        if not selected then selected = GetQuestLogSelection() end
        SelectQuestLogEntry(index)
        
        QHCQ[id] = {}
        QHCQ[id].level = level
        
        RegisterQuestData("reward", QHCQ[id], GetQuestLogRewardInfo)
        RegisterQuestData("choice", QHCQ[id], GetQuestLogChoiceInfo)
        
        
        
        --QuestHelper:TextOut(string.format("%d", GetNumQuestLeaderBoards(index)))
        for i = 1, GetNumQuestLeaderBoards(index) do
          local desc, type = GetQuestLogLeaderBoard(i, index)
          QHCQ[id][string.format("criteria_%d_text", i)] = desc
          QHCQ[id][string.format("criteria_%d_type", i)] = type
          --QuestHelper:TextOut(string.format("%s, %s", desc, type))
        end
      end
      
      dbx[id] = {}
      
      
      --QuestHelper:TextOut(string.format("%d", GetNumQuestLeaderBoards(index)))
      
      for i = 1, GetNumQuestLeaderBoards(index) do
        local desc, _, done = GetQuestLogLeaderBoard(i, index)
        
        -- If we wanted to parse everything here, we'd do something very complicated.
        -- Fundamentally, we don't. We only care if numeric values change or if something goes from "not done" to "done".
        -- Luckily, the patterns are identical in all cases for this (I think.)
        local have, needed = string.match(desc, "^.*: (%d+)/(%d+)$")
        have = tonumber(have)
        needed = tonumber(needed)
        
        --[[QuestHelper:TextOut(desc)
        QuestHelper:TextOut("^.*: (%d+)/(%d+)(" .. complete_suffix .. ")?$")
        QuestHelper:TextOut(string.gsub(desc, complete_suffix, ""))
        QuestHelper:TextOut(string.format("%s %s", tostring(have), tostring(needed)))]]
        if not have or not needed then
          have = done and 1 or 0
          needed = 1  -- okay so we don't really use this unless we're debugging, shut up >:(
        end
        
        dbx[id][i] = have
      end
    end
    
    index = index + 1
  end
  
  if selected then SelectQuestLogEntry(selected) end  -- abort abort bzzt bzzt bzzt awoooooooga dive, dive, dive
  
  return dbx
end

local changed = false

local function LogChanged()
  changed = true
end

local function WatchUpdate()  -- we're currently ignoring the ID of the quest that was updated for simplicity's sake.
  changed = true
end

function UpdateQuests()
  if not changed then return end
  changed = false
  
  local tim = GetTime()
  
  local noobey = ScanQuests()
  
  local traverse = {}
  
  for k, _ in pairs(deebey) do traverse[k] = true end
  for k, _ in pairs(noobey) do traverse[k] = true end
  
  for k, _ in pairs(traverse) do
    if not deebey[k] then
      QuestHelper:TextOut(string.format("Acquired! Questid %d", k))
      -- Quest was acquired
    elseif not noobey[k] then
      -- Quest was dropped or completed (check to see which!)
      QuestHelper:TextOut(string.format("Dropped/completed! Questid %d", k))
    else
      QuestHelper: Assert(#deebey[k] == #noobey[k])
      for i = 1, #deebey[k] do
        if not (noobey[k][i] >= deebey[k][i]) then
          QuestHelper:TextOut(string.format("%s, %s", type(noobey[k][i]), type(deebey[k][i])))
          QuestHelper:TextOut(string.format("%d, %d", noobey[k][i], deebey[k][i]))
        end
        QuestHelper: Assert(noobey[k][i] >= deebey[k][i]) -- man I hope this is true
        if noobey[k][i] > deebey[k][i] then
          QuestHelper:TextOut(string.format("Updated! Questid %d item %d", k, i))
        end
      end
    end
  end
  
  deebey = noobey
  
  --QuestHelper:TextOut(string.format("done in %f", GetTime() - tim))
end

function QH_Collect_Quest_Init(QHCData, API)
  if not QHCData.quest then QHCData.quest = {} end
  QHCQ = QHCData.quest
  
  GetQuestType = API.Utility_GetQuestType
  GetItemType = API.Utility_GetItemType
  QuestHelper: Assert(GetQuestType)
  QuestHelper: Assert(GetItemType)
  
  deebey = ScanQuests()
  
  API.Registrar_EventHook("UNIT_QUEST_LOG_CHANGED", LogChanged)
  API.Registrar_EventHook("QUEST_LOG_UPDATE", UpdateQuests)
  API.Registrar_EventHook("QUEST_WATCH_UPDATE", WatchUpdate)
end
