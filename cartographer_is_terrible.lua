QuestHelper_File["cartographer_is_terrible.lua"] = "Development Version"
QuestHelper_Loadtime["cartographer_is_terrible.lua"] = GetTime()

-- http://gunnerkrigg.wikia.com/wiki/Category:Terrible

if Cartographer and Cartographer.SetCurrentInstance and not Cartographer.TheInstanceBugIsFixedAlready_YouCanStopHackingIt then
  local oldfunc = SetMapZoom
  function SetMapZoom(...)
    local temp = WorldMapLevelDropDown_Update
    WorldMapLevelDropDown_Update = function () end  -- YOINK
    oldfunc(...)
    WorldMapLevelDropDown_Update = temp -- KNIOY
  end
  
  -- BEHOLD, MY MADNESS! BEHOLD AND SUFFER
  
  -- BEHOOOOOOLD
end





-- okay okay I guess I'll explain

-- There's a bug in Cartographer where SetMapZoom(), called in an instance, causes any open menus to instantly close. Questhelper (and in general, anything that uses Astrolabe, and other UI mods as well) call that function every frame if the map is closed. This isn't a performance problem or anything, but it happens to trigger the Cartographer bug.

-- The top two bugs on the Cartographer tracker are both this one, as well as a third bug listed later down. I've talked to both of the Cartographer maintainers about fixing it, neither are interested. It's pretty clearly not going to be fixed.

-- So here's a hack. The problem is the WorldMapLevelDropDown_Update call which, after a few nested calls, is eventually called. Why's it there? I dunno. What will removing it break? Not a clue. This cute little hook automatically disables it during the call of SetMapZoom. Will this be a problem for Cartographer? Damned if I know. Will it be *my* problem? No! No it will not.

-- If the Cartographer crew ever fixes it properly, this hook can be disabled by simply doing Cartographer.TheInstanceBugIsFixedAlready_YouCanStopHackingIt = true. And it will go away. Until then, the bug will go away.

-- LOOK HOW MUCH MY PROBLEM THIS ISN'T ANYMORE
