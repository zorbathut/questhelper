function QuestHelper:SetIconScale(input)
  if input == "" then
    self:TextOut("Current icon scale is "..self:HighlightText(math.floor(QuestHelper_Pref.scale*100+0.5).."%")..".")
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
    
    if scale < 0.5 then
      self:TextOut("I won't accept a scale less than 50%.")
    elseif scale > 3 then
      self:TextOut("I won't accept a scale more than 300%.")
    else
      QuestHelper_Pref.scale = scale
      self:TextOut("Icon scale set to "..self:HighlightText(math.floor(scale*100+0.5).."%")..".")
    end
  end
end

-----------------------------------------------------------------------------------------------
-- Set / show the Performance Factor
function QuestHelper:SetPerfFactor(input)
  if input == "" then
    self:TextOut("Current Performance Factor is "..self:HighlightText(math.floor(QuestHelper_Pref.perf_scale*100).."%")..".")
  else
    local perf = tonumber(input)

    if not perf then
      local _, _, x = string.find(input, "^%s*([%d%.]+)%s*%%%s*$")
      perf = tonumber(x)
      if not perf then
        self:TextOut("I don't know how to interpret your input.")
        return
      end
      perf = perf * 0.01
    end

    if perf < 0.1 then
      self:TextOut("I won't accept a performance factor less than 10%.")
    elseif perf > 5 then
      self:TextOut("I won't accept a performance factor more than 500%.")
    else
      QuestHelper_Pref.perf_scale = perf
      self:TextOut("Performance factor set to "..self:HighlightText(math.floor(perf*100+0.5).."%")..".")
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
  QuestHelperWorldMapButton:GetNormalTexture():SetDesaturated(QuestHelper_Pref.hide)
  
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

function QuestHelper:Purge(code)
  if code == self.purge_code then
    QuestHelper_Quests = {}
    QuestHelper_Objectives = {}
    QuestHelper_FlightInstructors = {}
    QuestHelper_FlightRoutes = {}
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
  elseif input == "" then
    self:TextOut("Filter "..self:HighlightText("zone")..": "..self:HighlightText(QuestHelper_Pref.filter_zone and "active" or "inactive"))
    self:TextOut("Filter "..self:HighlightText("level")..": "..self:HighlightText(QuestHelper_Pref.filter_level and "active" or "inactive"))
    self:TextOut("Filter "..self:HighlightText("done")..": "..self:HighlightText(QuestHelper_Pref.filter_done and "active" or "inactive"))
  else
    self:TextOut("Don't know what you want filtered, expect "..self:HighlightText("zone")..", "..self:HighlightText("done")..", or "..self:HighlightText("level")..".")
  end
end

function QuestHelper:ToggleCartWP()
  QuestHelper_Pref.cart_wp = not QuestHelper_Pref.cart_wp
  if QuestHelper_Pref.cart_wp then
    if Cartographer_Waypoints then
      self:TextOut("Will use "..self:HighlightText("Cartographer Waypoints").." to show objectives.")
    else
      self:TextOut("Would use "..self:HighlightText("Cartographer Waypoints").." to show objectives, except it doesn't seem to be present.")
    end
  else
    self:HideCartographerWaypoint()
    self:TextOut("Won't use "..self:HighlightText("Cartographer Waypoints").." to show objectives.")
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

local commands =
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
    {"/qh filter level", "Toggle showing objectives that are probably too hard."}}, QuestHelper.Filter, QuestHelper},
  
  {"SCALE",
   "Scales the map icons used by QuestHelper. Will accept values between 50% and 300%.",
   {{"/qh scale 1", "Uses the default icon size."},
    {"/qh scale 2", "Makes icons twice their default size."},
    {"/qh scale 80%", "Makes icons slightly smaller than their default size."}}, QuestHelper.SetIconScale, QuestHelper},
  
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
   "Sets / shows the Performance Factor.  Higher means more agressive route updating, lower means better performance (better frame rate).  Accepts numbers between 10% and 500%.",
   {{"/qh perf", "Show current Performance Factor"},
    {"/qh perf 1", "Sets standard performance"},
    {"/qh perf 50%", "Does half as much background processing"},
    {"/qh perf 3", "Computes routes 3 times more aggressively.  Better have some good horsepower!"}},
    QuestHelper.SetPerfFactor, QuestHelper}
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
      
      for i = 5,#data do table.insert(st, data[5]) end
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
  
  if command == "HELP" then
    argument = string.upper(argument)
    
    for i, data in ipairs(commands) do
      if data[1] == argument then
        DEFAULT_CHAT_FRAME:AddMessage(data[1], 1.0, 0.8, 0.4)
        DEFAULT_CHAT_FRAME:AddMessage("  "..data[2], 1.0, 0.6, 0.2)
        if #data[3] > 0 then
          DEFAULT_CHAT_FRAME:AddMessage(#data[3] == 1 and "  Example:" or "  Examples:", 1.0, 0.6, 0.2)
          for i, pair in ipairs(data[3]) do
            DEFAULT_CHAT_FRAME:AddMessage("    "..pair[1], 1.0, 1.0, 1.0)
            DEFAULT_CHAT_FRAME:AddMessage("      "..pair[2], 1.0, 0.6, 0.2)
          end
        end
        return
      end
    end
  end
  
  DEFAULT_CHAT_FRAME:AddMessage("Available Commands:", 1.0, 0.6, 0.2)
  
  for i, data in ipairs(commands) do
    DEFAULT_CHAT_FRAME:AddMessage("  "..string.lower(data[1]), 1.0, 0.6, 0.2)
  end
end

SLASH_QuestHelper1 = "/qh"
SLASH_QuestHelper2 = "/questhelper"
SlashCmdList["QuestHelper"] = function (text) QuestHelper:SlashCommand(text) end
