QuestHelper_File["filter_base.lua"] = "Development Version"
QuestHelper_Loadtime["filter_base.lua"] = GetTime()

local avg_level = UnitLevel("player")
local count = 1

function QH_Filter_Group_Sync()
  avg_level = UnitLevel("player")
  count = 1
  if GetNumRaidMembers() > 0 then
    avg_level = 0
    count = 0
    -- we is in a raid
    for i = 1, 40 do
      local liv = UnitLevel(string.format("raid%d", i))
      if liv >= 1 then
        avg_level = avg_level + liv
        count = count + 1
      end
    end
  elseif GetNumPartyMembers() > 0 then
    -- we is in a party
    for i = 1, 4 do
      local liv = UnitLevel(string.format("party%d", i))
      if liv >= 1 then
        avg_level = avg_level + liv
        count = count + 1
      end
    end
  end
  
  if count == 0 then -- welp
    QuestHelper:TextOut("This should never, ever happen. Please tell Zorba about it!")
    QuestHelper: Assert(false)
    avg_level = UnitLevel("player")
    count = 1
  end
  
  print(avg_level, count, avg_level + count)
  avg_level = avg_level / count
end

--[[
1
2 +2
3 +2
4 +2
5 +2 (+2 if dungeonflagged)
+6 and on: +15 (total of +25, the goal here is that, with default settings, lv60 raids shouldn't show up at lv80)
]]

local function VirtualLevel(avg_level, count, dungeonflag)
  if dungeonflag == nil and count == 5 then dungeonflag = true end -- "nil" is kind of "default"
  if count > 5 then dungeonflag = true end
  
  if count <= 5 then avg_level = avg_level + 2 * count - 2 end
  if count >= 5 and dungeonflag then avg_level = avg_level + 2 end
  if count > 5 then avg_level = avg_level + 15 end
  
  return avg_level
end

local filter_quest_level = QH_MakeFilter(function(obj)
  if not QuestHelper_Pref.filter_level then return true end
  
  if not obj.type_quest then return true end -- yeah it's fine
  
  local qtx
  if obj.type_quest.variety == GROUP then
    if obj.type_quest.groupsize then
      qtx = VirtualLevel(obj.type_quest.level, obj.type_quest.groupsize, false)
    else
      qtx = VirtualLevel(obj.type_quest.level, 5, false)  -- meh
    end
  elseif obj.type_quest.variety == LFG_TYPE_DUNGEON then
    qtx = VirtualLevel(obj.type_quest.level, 5, true)
  elseif obj.type_quest.variety == LFG_TYPE_RAID then
    qtx = VirtualLevel(obj.type_quest.level, 25, true)
  else
    qtx = VirtualLevel(obj.type_quest.level, 1, false)
  end
  
  if qtx > VirtualLevel(avg_level, count) + QuestHelper_Pref.level then return false end -- bzzt
  return true
end)

local filter_quest_done = QH_MakeFilter(function(obj)
  if not QuestHelper_Pref.filter_done then return true end
  
  if not obj.type_quest then return true end -- yeah it's fine
  if not obj.type_quest.done then return false end -- bzzt
  return true
end)

local filter_quest_watched = QH_MakeFilter(function(obj)
  if not QuestHelper_Pref.filter_watched then return true end
  
  if not obj.type_quest then return true end
  
  return IsQuestWatched(obj.type_quest.index)
end)

local aqw_orig = AddQuestWatch -- yoink
AddQuestWatch = function(...)
  QH_Route_Filter_Rescan("filter_quest_watched")
  return aqw_orig(...)
end

local rqw_orig = RemoveQuestWatch -- yoink
RemoveQuestWatch = function(...)
  QH_Route_Filter_Rescan("filter_quest_watched")
  return rqw_orig(...)
end


local filter_zone = QH_MakeFilter(function(obj)
  if not QuestHelper_Pref.filter_zone then return true end

  return obj.loc.p == QuestHelper.i
end)

local filter_blocked = QH_MakeFilter(function(obj, blocked)
  if not QuestHelper_Pref.filter_blocked then return true end
  
  return not blocked
end)

QH_Route_RegisterFilter(filter_quest_level, "filter_quest_level")
QH_Route_RegisterFilter(filter_quest_done, "filter_quest_done")
QH_Route_RegisterFilter(filter_quest_watched, "filter_quest_watched")
QH_Route_RegisterFilter(filter_zone, "filter_zone")
QH_Route_RegisterFilter(filter_blocked, "filter_blocked")
