QuestHelper_File["core.lua"] = "Development Version"
QuestHelper_Loadtime["core.lua"] = GetTime()

local temp_walker = QuestHelper:CreateWorldMapWalker()

QH_Route_RegisterNotification(function (route) temp_walker:RouteChanged(route) end)
QH_Route_RegisterNotification(function (route) tracker_update_route(route) end)
