QuestHelper_File["filter_base.lua"] = "Development Version"
QuestHelper_Loadtime["filter_base.lua"] = GetTime()


local filter_quest_level = QH_MakeFilter(function(obj)
  if not QuestHelper_Pref.filter_level then return true end
  
  if not obj.type_quest then return true end -- yeah it's fine
  if obj.type_quest.level > QuestHelper.player_level + QuestHelper_Pref.level then return false end -- bzzt
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
  return obj.type_quest.watched
end)

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
