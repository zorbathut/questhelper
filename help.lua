QuestHelper_File["help.lua"] = "Development Version"

function QuestHelper:scaleString(val)
  return self:HighlightText(math.floor(val*100+0.5).."%")
end

function QuestHelper:genericSetScale(varname, name, mn, mx, input, onchange, ...)
  if input == "" then
    self:TextOut(string.format("Current %s scale is %s.", name, self:scaleString(QuestHelper_Pref[varname])))
  else
    local scale = tonumber(input)
    
    if not scale then
      local _, _, x = string.find(input, "^%s*([%d%.]+)%s*%%%s*$")
      scale = tonumber(x)
      if not scale then
        self:TextOut("I don't know how to interpret your input.")
        return
      end
      scale = scale * 0.01
    end
    
    if scale < mn then
      self:TextOut(string.format("I won't accept a scale less than %s.", self:scaleString(mn)))
    elseif scale > mx then
      self:TextOut(string.format("I won't accept a scale more than %s.", self:scaleString(mx)))
    else
      QuestHelper_Pref[varname] = scale
      self:TextOut(string.format("Set %s scale set to %s.", name, self:scaleString(scale)))
      if onchange then
        onchange(...)
      end
    end
  end
end

function QuestHelper:SetLocale(loc)
  if not loc or loc == "" then
    self:TextOut(QHText("LOCALE_LIST_BEGIN"))
    for loc, tbl in pairs(QuestHelper_Translations) do
      self:TextOut(string.format("  %s%s %s", self:HighlightText(loc),
                                              loc == QuestHelper_Pref.locale and " *" or "  ",
                                              tbl.LOCALE_NAME or "???"))
    end
  else
    for l, tbl in pairs(QuestHelper_Translations) do
      if string.find(string.lower(l), "^"..string.lower(loc)) or
         string.find(string.lower(tbl.LOCALE_NAME or ""), "^"..string.lower(loc)) then
        QuestHelper_Pref.locale = l
        QHFormatSetLocale(l)
        self:SetLocaleFonts()
        self:TextOut(QHFormat("LOCALE_CHANGED", l))
        return
      end
    end
    
    self:TextOut(QHFormat("LOCALE_UNKNOWN", tostring(loc) or "UNKNOWN"))
  end
end

function QuestHelper:ToggleHide()
  local current_objective = self.minimap_dodad.objective
  
  QuestHelper_Pref.hide = not QuestHelper_Pref.hide
  
  -- Desaturate the button texture if QuestHelper is disabled.
  if self.MapButton then
    -- This should always be true, but just in case...
    self.MapButton:GetNormalTexture():SetDesaturated(QuestHelper_Pref.hide)
  end
  
  if QuestHelper_Pref.hide then
    self.map_overlay:Hide()
    self.minimap_dodad:SetObjective(nil)
    self.minimap_dodad.objective = current_objective
    self:TextOut("QuestHelper is now |cffff0000hidden|r.")
  else
    self.map_overlay:Show()
    self.minimap_dodad.objective = nil
    self.minimap_dodad:SetObjective(current_objective)
    self:TextOut("QuestHelper is now |cff00ff00shown|r.")
    -- WoW Will lockup inside ForceRouteUpdate, and so the UPDATING_ROUTE message won't appear until afterwards, making
    -- this message kind of redundant.
    -- self:TextOut(QHText("UPDATING_ROUTE"))
    self:ForceRouteUpdate(4)        -- Let the corutine do some overtime...
  end
end

function QuestHelper:ToggleShare()
  QuestHelper_Pref.share = not QuestHelper_Pref.share
  if QuestHelper_Pref.share then
    if QuestHelper_Pref.solo then
      self:TextOut("Objective sharing will been |cff00ff00enabled|r when you disable solo mode.")
    else
      self:TextOut("Objective sharing has been |cff00ff00enabled|r.")
      self:EnableSharing()
    end
  else
    self:TextOut("Objective sharing has been |cffff0000disabled|r.")
    if QuestHelper_Pref.solo then
      self:TextOut("Objective sharing won't be reenabled when you disable solo mode.")
    else
      self:DisableSharing()
    end
  end
end

function QuestHelper:ToggleFlightTimes()
  QuestHelper_Pref.flight_time = not QuestHelper_Pref.flight_time
  if QuestHelper_Pref.flight_time then
    self:TextOut("The flight timer has been |cff00ff00enabled|r.")
  else
    self:TextOut("The flight timer has been |cffff0000disabled|r.")
  end
end

function QuestHelper:ToggleTrack()
  QuestHelper_Pref.track = not QuestHelper_Pref.track
  if QuestHelper_Pref.track then
    self.tracker:HideDefaultTracker()
    self.tracker:Show()
    self:TextOut("The quest tracker has been |cff00ff00enabled|r.")
  else
    self.tracker:ShowDefaultTracker()
    self.tracker:Hide()
    self:TextOut("The quest tracker has been |cffff0000disabled|r.")
  end
end

function QuestHelper:ToggleTooltip()
  QuestHelper_Pref.tooltip = not QuestHelper_Pref.tooltip
  if QuestHelper_Pref.tooltip then
    self:TextOut("Objectuve tooltip information has been |cff00ff00enabled|r.")
  else
    self:TextOut("Objectuve tooltip information has been |cffff0000disabled|r.")
  end
end

function QuestHelper:Purge(code)
  if code == self.purge_code then
    QuestHelper_Quests = {}
    QuestHelper_Objectives = {}
    QuestHelper_FlightInstructors = {}
    QuestHelper_FlightRoutes = {}
    QuestHelper_Locale = GetLocale()
    QuestHelper_UID = self:CreateUID()
    ReloadUI()
  else
    if not self.purge_code then self.purge_code = self:CreateUID(8) end
    QuestHelper:TextOut("THIS COMMAND WILL DELETE ALL YOUR COLLECTED DATA")
    QuestHelper:TextOut("I would consider this a tragic loss, and would appreciate it if you sent me your saved data before going through with it.")
    QuestHelper:TextOut("Enter "..self:HighlightText("/qh nag verbose").." to check and see if you're destroying anything important.")
    QuestHelper:TextOut("See the "..self:HighlightText("How You Can Help").." section on the project website for instructions.")
    QuestHelper:TextOut("If you're sure you want to go through with this, enter: "..self:HighlightText("/qh purge "..self.purge_code))
  end
end

function QuestHelper:ToggleSolo()
  QuestHelper_Pref.solo = not QuestHelper_Pref.solo
  if QuestHelper_Pref.solo then
    if QuestHelper_Pref.share then
      self:DisableSharing()
      self:TextOut("Objective sharing has been temporarly |cffff0000disabled|r.")
    end
    self:TextOut("Solo mode has been |cff00ff00enabled|r.")
  else
    self:TextOut("Solo mode has been |cffff0000disabled|r.")
    if QuestHelper_Pref.share then
      self:EnableSharing()
      self:TextOut("Objective sharing has been re|cff00ff00enabled|r.")
    end
  end
end

function QuestHelper:ToggleComm()
  if QuestHelper_Pref.comm then
    QuestHelper_Pref.comm = false
    self:TextOut("Communication display has been |cffff0000disabled|r.")
  else
    QuestHelper_Pref.comm = true
    self:TextOut("Communication display has been |cff00ff00enabled|r.")
  end
end

function QuestHelper:ToggleAnts()
  if QuestHelper_Pref.show_ants then
    QuestHelper_Pref.show_ants = false
    self:TextOut("Ant trails have been |cffff0000disabled|r.")
  else
    QuestHelper_Pref.show_ants = true
    self:TextOut("Ant trails have been |cff00ff00enabled|r.")
  end
end

function QuestHelper:LevelOffset(offset)
  local level = tonumber(offset)
  if level then
    if level > 0 then
      self:TextOut("Allowing quests up to "..self:HighlightText(level).." level"..(level==1 and " " or "s ")..self:HighlightText("above").." you.")
    elseif level < 0 then
      self:TextOut("Only allowing quests "..self:HighlightText(-level).." level"..(level==-1 and " " or "s ")..self:HighlightText("below").." you.")
    else
      self:TextOut("Only allowing quests "..self:HighlightText("at or below").." your current level.")
    end
    
    if not QuestHelper_Pref.filter_level then
      self:TextOut("Note: This won't have any effect until you turn the level filter on.")
    end
    
    if QuestHelper_Pref.level ~= level then
      QuestHelper_Pref.level = level
      self.defered_quest_scan = true
    end
  elseif offset == "" then
    if QuestHelper_Pref.level <= 0 then
      self:TextOut("Level offset is currently set to "..self:HighlightText(QuestHelper_Pref.level)..".")
    else
      self:TextOut("Level offset is currently set to "..self:HighlightText("+"..QuestHelper_Pref.level)..".")
    end
    
    if self.party_levels then for n, l in ipairs(self.party_levels) do
      self:TextOut("Your effective level in a "..self:HighlightText(n).." player quest is "..self:HighlightText(string.format("%.1f", l))..".")
    end end
    
    if QuestHelper_Pref.solo then
      self:TextOut("Peers aren't considered in your effective level, because you're playing solo.")
    end
  else
    self:TextOut("Expected a level offset.")
  end
end

function QuestHelper:Filter(input)
  input = string.upper(input)
  if input == "ZONE" then
    QuestHelper_Pref.filter_zone = not QuestHelper_Pref.filter_zone
    self:TextOut("Filter "..self:HighlightText("zone").." set to "..self:HighlightText(QuestHelper_Pref.filter_zone and "active" or "inactive")..".")
  elseif input == "DONE" then
    QuestHelper_Pref.filter_done = not QuestHelper_Pref.filter_done
    self:TextOut("Filter "..self:HighlightText("done").." set to "..self:HighlightText(QuestHelper_Pref.filter_done and "active" or "inactive")..".")
  elseif input == "LEVEL" then
    QuestHelper_Pref.filter_level = not QuestHelper_Pref.filter_level
    self:TextOut("Filter "..self:HighlightText("level").." set to "..self:HighlightText(QuestHelper_Pref.filter_level and "active" or "inactive")..".")
  elseif input == "BLOCKED" or input == "BLOCK" then
    QuestHelper_Pref.filter_blocked = not QuestHelper_Pref.filter_blocked
    self:TextOut("Filter "..self:HighlightText("blocked").." set to "..self:HighlightText(QuestHelper_Pref.filter_blocked and "active" or "inactive")..".")
  elseif input == "" then
    self:TextOut("Filter "..self:HighlightText("zone")..": "..self:HighlightText(QuestHelper_Pref.filter_zone and "active" or "inactive"))
    self:TextOut("Filter "..self:HighlightText("level")..": "..self:HighlightText(QuestHelper_Pref.filter_level and "active" or "inactive"))
    self:TextOut("Filter "..self:HighlightText("done")..": "..self:HighlightText(QuestHelper_Pref.filter_done and "active" or "inactive"))
    self:TextOut("Filter "..self:HighlightText("blocked")..": "..self:HighlightText(QuestHelper_Pref.filter_blocked and "active" or "inactive"))
  else
    self:TextOut("Don't know what you want filtered, expect "..self:HighlightText("zone")..", "..self:HighlightText("done")..", or "..self:HighlightText("level")..".")
  end
end

function QuestHelper:ToggleCartWP()
  QuestHelper_Pref.cart_wp = not QuestHelper_Pref.cart_wp
  if QuestHelper_Pref.cart_wp then
    self:EnableCartographer()
    if Cartographer_Waypoints then
      if Waypoint and Waypoint.prototype then
        self:TextOut("Would use "..self:HightlightText("Cartographer Waypoints").." to show objectives, but another mod is interfering with it.")
      else
        self:TextOut("Will use "..self:HighlightText("Cartographer Waypoints").." to show objectives.")
      end
    else
      self:TextOut("Would use "..self:HighlightText("Cartographer Waypoints").." to show objectives, except it doesn't seem to be present.")
    end
  else
    self:DisableCartographer()
    self:TextOut("Won't use "..self:HighlightText("Cartographer Waypoints").." to show objectives.")
  end
end

function QuestHelper:ToggleTomTomWP()
  QuestHelper_Pref.tomtom_wp = not QuestHelper_Pref.tomtom_wp
  if QuestHelper_Pref.tomtom_wp then
    self:EnableTomTom()
    if TomTom then
      self:TextOut("Will use "..self:HighlightText("TomTom").." to show objectives.")
    else
      self:TextOut("Would use "..self:HighlightText("TomTom").." to show objectives, except it doesn't seem to be present.")
    end
  else
    self:DisableTomTom()
    self:TextOut("Won't use "..self:HighlightText("TomTom").." to show objectives.")
  end
end

function QuestHelper:WantPathingReset()
  self:TextOut("Will reset world graph.")
  self.defered_graph_reset = true
end

function QuestHelper:PrintVersion()
  self:TextOut("Version: "..self:HighlightText(GetAddOnMetadata("QuestHelper", "Version") or "Unknown"))
end

local function RecycleStatusString(fmt, used, free)
  return string.format(fmt, QuestHelper:ProgressString(string.format("%d/%d", used, used+free), ((used+free == 0) and 1) or (1-used/(used+free))))
end

function QuestHelper:RecycleInfo()
  self:TextOut(RecycleStatusString("Using %s lua tables.", self.used_tables, #self.free_tables))
  self:TextOut(RecycleStatusString("Using %s texture objects.", self.used_textures, #self.free_textures))
  self:TextOut(RecycleStatusString("Using %s font objects.", self.used_text, #self.free_text))
  self:TextOut(RecycleStatusString("Using %s frame objects.", self.used_frames, #self.free_frames))
end

function QuestHelper:ToggleMapButton()
  QuestHelper_Pref.map_button = not QuestHelper_Pref.map_button

  if QuestHelper_Pref.map_button then
    QuestHelper:InitMapButton()
    self:TextOut("Map button has been |cff00ff00enabled|r.")
  else
    QuestHelper:HideMapButton()
    self:TextOut("Map button has been |cffff0000disabled|r.  Use '/qh button' to restore it.")
  end
end

function QuestHelper:ChangeLog()
  self:ShowText(QuestHelper_ChangeLog, string.format("QuestHelper %s ChangeLog", QuestHelper_Version))
end

local commands

function QuestHelper:Help(argument)
  local text = ""
  local argument = argument and argument:upper() or ""
  
  for i, data in ipairs(commands) do
    if data[1]:find(argument, 1, true) then
      text = string.format("%s|cffff8000%s|r   %s\n", text, data[1], data[2])
      
      if #data[3] > 0 then
        text = string.format("%s\n  %s\n", text, #data[3] == 1 and "Example:" or "Examples:")
        for i, pair in ipairs(data[3]) do
          text = string.format("%s    |cff40bbff%s|r\n      %s\n", text, pair[1], pair[2])
        end
      end
      
      text = text .. "\n"
    end
  end
  
  self:ShowText(text == "" and ("No commands containing '.."..argument.."..'") or text, "QuestHelper Slash Commands")
end

commands =
 {
  {"VERSION",
   "Displays QuestHelper's version.", {}, QuestHelper.PrintVersion, QuestHelper},
  
  {"RECALC",
   "Recalculates the world graph and locations for any active objectives.", {}, QuestHelper.WantPathingReset, QuestHelper},
  
  {"FTIME",
   "Toggles display of flight time estimates.", {}, QuestHelper.ToggleFlightTimes, QuestHelper},
  
  {"PURGE",
   "Deletes all QuestHelper's collected data.", {}, QuestHelper.Purge, QuestHelper},
  
  {"FILTER",
   "Automatically ignores/unignores objectives based on criteria.",
   {{"/qh filter zone", "Toggle showing objectives outside the current zone"},
    {"/qh filter done", "Toggle showing objectives for uncompleted quests."},
    {"/qh filter level", "Toggle showing objectives that are probably too hard."},
    {"/qh filter blocked", "Toggle showing blocked objectives, such as quest turn-ins for incomplete quests."}}, QuestHelper.Filter, QuestHelper},
  
  {"SCALE",
   "Scales the map icons used by QuestHelper. Will accept values between 50% and 300%.",
   {{"/qh scale 1", "Uses the default icon size."},
    {"/qh scale 2", "Makes icons twice their default size."},
    {"/qh scale 80%", "Makes icons slightly smaller than their default size."}},
    QuestHelper.genericSetScale, QuestHelper, "scale", "icon scale", .5, 3},
  
  {"TSCALE",
   "Scales the quest tracker provided by QuestHelper. Will accept values between 50% and 300%.",
   {},
   function (input) QuestHelper:genericSetScale("track_scale", "tracker scale", .5, 2, input,
     function() QuestHelper.tracker:SetScale(QuestHelper_Pref.track_scale) end) end},
  
  {"NAG",
   "Tells you if you have anything that's missing from the static database.",
    {{"/qh nag", "Prints just the summary of changes."},
     {"/qh nag verbose", "Prints the specific changes that were found."}}, QuestHelper.Nag, QuestHelper},
  
  {"LEVEL",
   "Adjusts the level offset used by the level filter. Naturally, the level filter must be turned on to have an effect.",
   {{"/qh level", "See information related to the level filter."},
    {"/qh level 0", "Only allow objectives at below your current level."},
    {"/qh level +2", "Allow objectives up to two levels above your current level."},
    {"/qh level -1", "Only allow objectives below your current level."}}, QuestHelper.LevelOffset, QuestHelper},
  
  {"POS",
    "Prints the player's current position. Exists mainly for my own personal convenience.",
    {}, function (qh) qh:TextOut(qh:LocationString(qh.i, qh.x, qh.y)) end, QuestHelper},
  
  {"HIDDEN",
   "Compiles a list of objectives that QuestHelper is hiding from you. Depending on the reason, you can also unhide the objective.",
   {}, QuestHelper.ShowHidden, QuestHelper},
  
  {"FIND",
   "Search for an item, location, or npc.",
   {{"/qh find item rune of teleport", "Finds a reagent vendor."},
    {"/qh find npc bragok", "Finds the Ratchet flight point."},
    {"/qh find loc stormwind 50 60", "Finds the Stormwind auction house."}}, QuestHelper.PerformSearch, QuestHelper},
  
  {"COMM",
   "Toggles showing of the communication between QuestHelper users. Exists mainly for my own personal convenience.",
    {}, QuestHelper.ToggleComm, QuestHelper},
  
  {"RECYCLE",
   "Displays how many unused entities QuestHelper is tracking, so that it can reuse them in the future instead of creating new ones in the future.",
    {}, QuestHelper.RecycleInfo, QuestHelper},
  
  {"CARTWP",
   "Toggles displaying the current objective using Cartographer Waypoints.",
    {}, QuestHelper.ToggleCartWP, QuestHelper},
  
  {"TOMTOM",
   "Toggles displaying the current objective using TomTom.",
    {}, QuestHelper.ToggleTomTomWP, QuestHelper},
  
  {"TRACK",
   "Toggles the visibility of the objective tracker.",
    {}, QuestHelper.ToggleTrack, QuestHelper},
  
  {"TOOLTIP",
   "Toggles appending information about tracked items and NPCs to their tooltips.",
    {}, QuestHelper.ToggleTooltip, QuestHelper},
  
  {"SHARE",
   "Toggles objective sharing between QuestHelper users.",
    {}, QuestHelper.ToggleShare, QuestHelper},
  
  {"HIDE",
   "Hides QuestHelper's modifications to the minimap and world map, and pauses routing calculations.",
    {}, QuestHelper.ToggleHide, QuestHelper},
  
  {"ANTS",
   "Toggles the world map ant trails on and off.",
    {}, QuestHelper.ToggleAnts, QuestHelper},
  
  {"SOLO",
   "Toggles solo mode. When enabled, assumes you're playing alone, even when in a party.",
    {}, QuestHelper.ToggleSolo, QuestHelper},
  
  {"LOCALE",
   "Select the locale to use for displayed messages.",
    {}, QuestHelper.SetLocale, QuestHelper},

  {"PERF",
   "Sets / shows the Route Workload / Performance Factor.  Higher means more agressive route updating, lower means better performance (better frame rate).  Accepts numbers between 10% and 500%.",
   {{"/qh perf", "Show current Performance Factor"},
    {"/qh perf 1", "Sets standard performance"},
    {"/qh perf 50%", "Does half as much background processing"},
    {"/qh perf 3", "Computes routes 3 times more aggressively.  Better have some good horsepower!"}},
    QuestHelper.genericSetScale, QuestHelper, "perf_scale", "performance factor", .1, 5},
  
  {"BUTTON",
   "Toggle the QuestHelper button on the World Map frame",
   {}, QuestHelper.ToggleMapButton, QuestHelper},

  {"SETTINGS",
   "Show the Settings menu",
   {}, QuestHelper.DoSettingsMenu, QuestHelper},
  
  {"CHANGES",
   "Displays a summary of changes recently made to QuestHelper. This is always displayed when an upgrade is detected.",
   {}, QuestHelper.ChangeLog, QuestHelper},
  
  {"HELP",
   "Displays a list of help commands. Listed commands are filtered by the passed string.",
   {}, QuestHelper.Help, QuestHelper}
 }

function QuestHelper:SlashCommand(input)
  local _, _, command, argument = string.find(input, "^%s*([^%s]-)%s+(.-)%s*$")
  if not command then
    command, argument = input, ""
  end
  
  command = string.upper(command)
  
  for i, data in ipairs(commands) do
    if data[1] == command then
      local st = self:CreateTable()
      
      for i = 5,#data do table.insert(st, data[i]) end
      table.insert(st, argument)
      
      if type(data[4]) == "function" then
        data[4](unpack(st))
      else
        self:TextOut(data[1].." is not yet implemented.")
      end
      
      self:ReleaseTable(st)
      return
    end
  end
  
  self:Help()
end

SLASH_QuestHelper1 = "/qh"
SLASH_QuestHelper2 = "/questhelper"
SlashCmdList["QuestHelper"] = function (text) QuestHelper:SlashCommand(text) end
