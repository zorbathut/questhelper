QuestHelper_File["collect_quest.lua"] = "Development Version"
QuestHelper_Loadtime["collect_quest.lua"] = GetTime()

local debug_output = false
if QuestHelper_File["collect_quest.lua"] == "Development Version" then debug_output = true end

local IsMonsterGUID
local GetMonsterType

local GetQuestType
local GetItemType

local GetLoc

local QHCQ

local deebey

local function RegisterQuestData(category, location, GetQuestLogWhateverInfo)
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

local function ScanQuests() -- make it local once we've debugged it
  
  local selected
  local index = 1
  
  local dbx = {}
  
  while true do
    if not GetQuestLogTitle(index) then break end
    
    local qlink = GetQuestLink(index)
    if qlink then
      --QuestHelper:TextOut(qlink)
      --QuestHelper:TextOut(string.gsub(qlink, "|", "||"))
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

local eventy = {}

local function Looted(message)
  local ltype = GetItemType(message, true)
  table.insert(eventy, {time = GetTime(), event = string.format("I%di", ltype)})
  if debug_output then QuestHelper:TextOut(string.format("Added event %s", string.format("I%di", ltype))) end
end

local function Combat(_, event, _, _, _, guid)
  if event ~= "UNIT_DIED" then return end
  if not IsMonsterGUID(guid) then return end
  local mtype = GetMonsterType(guid, true)
  table.insert(eventy, {time = GetTime(), event = string.format("M%dm", mtype)})
  if debug_output then QuestHelper:TextOut(string.format("Added event %s", string.format("M%dm", mtype))) end
end

local changed = false
local first = true

local function LogChanged()
  changed = true
end

local function WatchUpdate()  -- we're currently ignoring the ID of the quest that was updated for simplicity's sake.
  changed = true
end

local function AppendMember(tab, key, dat)
  tab[key] = (tab[key] or "") .. dat
end

local function StartOrEnd(se, id)
  local targuid = UnitGUID("target")
  local chunk = ""
  if targuid and IsMonsterGUID(targuid) then
    chunk = string.format("M%dm", GetMonsterType(targuid))
  end
  chunk = chunk .. GetLoc()
  
  AppendMember(QHCQ[id], se, chunk)
end

local abandoncomplete = ""
local abandoncomplete_timestamp = nil

local GetQuestReward_Orig = GetQuestReward
GetQuestReward = function (...)
  abandoncomplete = "complete"
  abandoncomplete_timestamp = GetTime()
  GetQuestReward_Orig(...)
end

local AbandonQuest_Orig = AbandonQuest
AbandonQuest = function ()
  abandoncomplete = "abandon"
  abandoncomplete_timestamp = GetTime()
  AbandonQuest_Orig()
end

function UpdateQuests()
  if first then deebey = ScanQuests() first = false end
  if not changed then return end
  changed = false
  
  local tim = GetTime()
  
  local noobey = ScanQuests()
  
  local traverse = {}
  
  local dsize, nsize = QuestHelper:TableSize(deebey), QuestHelper:TableSize(noobey)
  
  for k, _ in pairs(deebey) do traverse[k] = true end
  for k, _ in pairs(noobey) do traverse[k] = true end
  
  --[[
  if QuestHelper:TableSize(deebey) ~= QuestHelper:TableSize(noobey) then
    QuestHelper:TextOut(string.format("%d %d", QuestHelper:TableSize(deebey), QuestHelper:TableSize(noobey)))
  end]]
  
  while #eventy > 0 and eventy[1].time < GetTime() - 1 do table.remove(eventy, 1) end -- slurp
  local token
  local debugtok
  
  local diffs = 0
  
  for k, _ in pairs(traverse) do
    if not deebey[k] then
      -- Quest was acquired
      if debug_output then QuestHelper:TextOut(string.format("Acquired! Questid %d", k)) end
      StartOrEnd("start", k)
      diffs = diffs + 1
      
    elseif not noobey[k] then
      -- Quest was dropped or completed
      if abandoncomplete == "complete" and abandoncomplete_timestamp + 30 >= GetTime() then
        if debug_output then QuestHelper:TextOut(string.format("Completed! Questid %d", k)) end
        StartOrEnd("end", k)
        abandoncomplete = ""
      else
        if debug_output then QuestHelper:TextOut(string.format("Dropped! Questid %d", k)) end
      end
      
      diffs = diffs + 1
      
    else
      QuestHelper: Assert(#deebey[k] == #noobey[k])
      for i = 1, #deebey[k] do
      
      --[[
        if not (noobey[k][i] >= deebey[k][i]) then
          QuestHelper:TextOut(string.format("%s, %s", type(noobey[k][i]), type(deebey[k][i])))
          QuestHelper:TextOut(string.format("%d, %d", noobey[k][i], deebey[k][i]))
          for index = 1, 100 do
            local qlink = GetQuestLink(index)
            if qlink then qlink = GetQuestType(qlink) end
            if qlink == k then
              QuestHelper:TextOut(GetQuestLogLeaderBoard(i, index))
            end
          end
        end
        QuestHelper: Assert(noobey[k][i] >= deebey[k][i]) -- man I hope this is true]]  -- This entire section can fail if people throw away quest items, or if quest items have a duration that expires. Sigh.
        
        if noobey[k][i] > deebey[k][i] then
          if not token then
            token = ""
            for k, v in pairs(eventy) do token = token .. v.event end
            debugtok = token
            token = token .. "L" .. GetLoc() .. "l"
          end
          
          local ttok = token
          if noobey[k][i] - 1 ~= deebey[k][i] then
            ttok = string.format("C%dc", noobey[k][i] - deebey[k][i]) .. ttok
          end
          
          AppendMember(QHCQ[k], string.format("criteria_%d_satisfied", i), ttok)
          
          if debug_output then QuestHelper:TextOut(string.format("Updated! Questid %d item %d count %d tok %s", k, i, noobey[k][i] - deebey[k][i], debugtok)) end
          diffs = diffs + 1
        end
      end
    end
  end
  
  deebey = noobey
  
  QuestHelper: Assert(diffs <= 5, string.format("excessive quest diffs - delta is %d, went from %d to %d", diffs, dsize, nsize))
  --QuestHelper:TextOut(string.format("done in %f", GetTime() - tim))
end

function QH_Collect_Quest_Init(QHCData, API)
  if not QHCData.quest then QHCData.quest = {} end
  QHCQ = QHCData.quest
  
  GetQuestType = API.Utility_GetQuestType
  GetItemType = API.Utility_GetItemType
  IsMonsterGUID = API.Utility_IsMonsterGUID
  GetMonsterType = API.Utility_GetMonsterType
  QuestHelper: Assert(GetQuestType)
  QuestHelper: Assert(GetItemType)
  QuestHelper: Assert(IsMonsterGUID)
  QuestHelper: Assert(GetMonsterType)
  
  GetLoc = API.Callback_LocationBolusCurrent
  QuestHelper: Assert(GetLoc)
  
  deebey = ScanQuests()
  
  API.Registrar_EventHook("UNIT_QUEST_LOG_CHANGED", LogChanged)
  API.Registrar_EventHook("QUEST_LOG_UPDATE", UpdateQuests)
  API.Registrar_EventHook("QUEST_WATCH_UPDATE", WatchUpdate)
  
  API.Registrar_EventHook("CHAT_MSG_LOOT", Looted)
  API.Registrar_EventHook("COMBAT_LOG_EVENT_UNFILTERED", Combat)
  
  API.Registrar_EventHook("PLAYER_ENTERING_WORLD", function () deebey = ScanQuests() end)
end
