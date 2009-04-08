QuestHelper_File["core.lua"] = "Development Version"
QuestHelper_Loadtime["core.lua"] = GetTime()


QuestHelper.Astrolabe = DongleStub("Astrolabe-0.4-QuestHelper")
QuestHelper: Assert(QuestHelper.Astrolabe)
local walker = QuestHelper:CreateWorldMapWalker()
local minimap = QuestHelper:CreateMipmapDodad()

QH_Route_RegisterNotification(function (route) walker:RouteChanged(route) end)
QH_Route_RegisterNotification(function (route) QH_Tracker_UpdateRoute(route) end)
QH_Route_RegisterNotification(function (route) minimap:SetObjective(route[2]) end)
