QuestHelper_File["director_achievement.lua"] = "Development Version"
QuestHelper_Loadtime["director_achievement.lua"] = GetTime()

local debug_output = false
if QuestHelper_File["director_achievement.lua"] == "Development Version" then debug_output = true end

local added = false
function QH_AddFires()
  if added then QuestHelper:TextOut("Objectives are already added! If they haven't shown up yet, just be patient, it may take some time. If they have, and you've ignored some, you'll have to logout and logon to reset them. Sorry! It's kind of a work in progress.") return end
  added = true
  
  QuestHelper:TextOut("Adding bonfire objectives! This may take several minutes - please be patient. Bonfire objectives will not go away automatically when you finish the quest, you'll have to ignore them manually, and it has no idea which bonfires you've already done. It also may take some time for it to generate a good path, or to respond to ignore requests. This is a very early beta feature and is in no way a finished, polished product :) Enjoy the Fire Festival!")

  local fonbires = {
    {39,74,41,"Horde"},
    {39,50,44,"Alliance"},
    {27,4,49,"Horde"},
    {33,58,17,"Alliance"},
    {40,62,29,"Horde"},
    {40,80,62,"Alliance"},
    {25,64,25,"Alliance"},
    {28,46,46,"Alliance"},
    {31,74,51,"Alliance"},
    {37,43,65,"Alliance"},
    {36,49,72,"Alliance"},
    {41,46,50,"Horde"},
    {52,70,43,"Horde"},
    {44,46,26,"Horde"},
    {48,50,46,"Alliance"},
    {48,58,25,"Horde"},
    {29,32,40,"Alliance"},
    {30,24,59,"Alliance"},
    {35,49,38,"Horde"},
    {38,33,73,"Alliance"},
    {38,32,75,"Horde"},
    {46,47,47,"Horde"},
    {42,14,50,"Alliance"},
    {42,76,74,"Horde"},
    {45,68,9,"Horde"},
    {43,57,52,"Horde"},
    {50,43,82,"Alliance"},
    {49,56,54,"Alliance"},
    {51,13,47,"Alliance"},
    {2,38,54,"Alliance"},
    {2,70,69,"Horde"},
    {12,41,26,"Alliance"},
    {3,44,53,"Alliance"},
    {9,55,69,"Alliance"},
    {16,37,46,"Alliance"},
    {4,65,17,"Alliance"},
    {4,26,76,"Horde"},
    {1,47,38,"Horde"},
    {7,52,47,"Horde"},
    {10,62,40,"Alliance"},
    {10,33,30,"Horde"},
    {17,28,44,"Alliance"},
    {17,72,47,"Horde"},
    {23,21,26,"Horde"},
    {22,51,60,"Horde"},
    {5,57,34,"Alliance"},
    {5,46,44,"Horde"},
    {6,50,60,"Horde"},
    {8,52,29,"Alliance"},
    {8,49,27,"Horde"},
    {24,55,91,"Alliance"},
    {24,55,60,"Alliance"},
    {11,52,28,"Horde"},
    {14,41,52,"Horde"},
    {19,62,35,"Alliance"},
    {19,59,35,"Horde"},
    {54,42,66,"Alliance"},
    {54,50,59,"Horde"},
    {56,62,58,"Alliance"},
    {56,55,40,"Horde"},
    {58,50,70,"Alliance"},
    {58,51,34,"Horde"},
    {59,31,63,"Alliance"},
    {59,32,68,"Horde"},
    {53,40,55,"Alliance"},
    {53,33,30,"Horde"},
    {55,55,55,"Alliance"},
    {55,52,43,"Horde"},
    {57,69,52,"Alliance"},
    {57,36,52,"Horde"},
    {72,47,66,"Alliance"},
    {72,47,62,"Horde"},
    {65,55,20,"Alliance"},
    {65,51,12,"Horde"},
    {68,75,44,"Alliance"},
    {68,39,48,"Horde"},
    {70,58,16,"Alliance"},
    {70,48,13,"Horde"},
    {69,34,61,"Alliance"},
    {69,19,61,"Horde"},
    {75,41,61,"Alliance"},
    {75,43,71,"Horde"},
    {73,42,87,"Alliance"},
    {73,40,86,"Horde"},
    {66,78,75,"Alliance"},
    {66,80,53,"Horde"},
  }
  
  local msfires = {desc = "Midsummer Fires", tracker_desc = "Midsummer Fires", tracker_split = true}
  
  for _, v in ipairs(fonbires) do
    local ec, ez = unpack(QuestHelper_ZoneLookup[v[1]])
    local c, x, y = QuestHelper.Astrolabe:GetAbsoluteContinentPosition(ec, ez, v[2] / 100, v[3] / 100)
    --print(v[1], v[2], v[3], v[4], ec, ez, c, x, y, QuestHelper_ParentLookup[v[1]])
    local desc = string.format("%s %s bonfire", v[4], QuestHelper_NameLookup[v[1]])
    local node = {loc = {x = x, y = y, p = v[1], c = QuestHelper_ParentLookup[v[1]]}, why = msfires, map_desc = {desc}, tracker_desc = desc}
    
    QH_Route_ClusterAdd({node})
  end
end
