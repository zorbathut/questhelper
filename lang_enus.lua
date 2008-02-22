-- Note: This file is used as fallback for locales that don't exist.

-- If the client is using this locale, then strings from this table will always be used, regardless of
-- the locale selected for displayed text.
QuestHelper_ForcedTranslations.enUS = 
 {}

QuestHelper_ZoneTranslations.enUS =
 {
  -- Maps the locale zone names to the enUS zone names.
 }

QuestHelper_Translations.enUS =
 {
  -- Messages used when starting.
  LOCALE_ERROR = "The locale of your saved data doesn't match the locale of your WoW client.",
  ZONE_LAYOUT_ERROR = "I'm refusing to run, out of fear of corrupting your saved data. "..
                          "Please wait for a patch that will be able to handle the new zone layout.",
  DOWNGRADE_ERROR = "Your saved data isn't compatible with this version of QuestHelper. "..
                        "Use a new version, or delete your saved variables.",
  HOME_NOT_KNOWN = "Your home isn't known. When you get a chance, please talk to your innkeeper and reset it.",
  
  ALTERED_INDEX = "!!! QuestHelper_IndexLookup entry needs update: [%q1] = {%2, %3, %4}",
  ALTERED_ZONE = "!!! QuestHelper_Zones entry needs update: [%1][%2] = %q3 -- was %4",
  
  -- Words used for objectives.
  SLAY_VERB = "Slay",
  ACQUIRE_VERB = "Acquire",
  
  OBJECTIVE_REASON = "%1 %h2 for quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 for quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Turn in quest %h1.",
  OBJECTIVE_PURCHASE = "Purchase from %h1.",
  OBJECTIVE_SLAY = "Slay %h1.",
  
  ZONE_BORDER = "%1/%2 border",
  
  -- Stuff used in objective menus.
  PRIORITY = "Priority",
  PRIORITY1 = "Highest",
  PRIORITY2 = "High",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Low",
  PRIORITY5 = "Lowest",
  SHARING = "Sharing",
  ENABLE = "Enable",
  DISABLE = "Disable",
  IGNORE = "Ignore",
  
  IGNORED_PRIORITY_TITLE = "The selected priority would be ignored.",
  IGNORED_PRIORITY_FIX = "Apply same priority to the blocking objectives.",
  IGNORED_PRIORITY_IGNORE = "I'll set the priorities myself.",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's progress:",
  TRAVEL_ESTIMATE = "Estimated travel time:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visit %h1 en route to:"
 }

QuestHelper_TranslationFunctions.enUS =
 {
  -- %1 will insert a copy of argument 1, converted to a string.
  [""] = tostring,
  
  -- Highlight: "%h1" will insert a highlighted copy of argument 1, converted to a string.
  ["h"] = function(data) return QuestHelper:HighlightText(tostring(data)) end,
  
  -- Time: "%t1" will insert argument 1 as a number representing seconds.
  -- A value of 9296 will for example be inserted as '2:34:56'.
  ["t"] = function(data) return QuestHelper:TimeString(tonumber(data)) end,
  
  -- Percentage: "%p1" will insert argument 1 as a number representing a fraction.
  -- A value of .3183 will for example be inserted as '31.8%'.
  ["p"] = function(data) return QuestHelper:PercentString(tonumber(data)) end,
  
  -- Quote: "%q1" will insert argument 1 as a quoted lua string.
  ["q"] = function(data) return string.format("%q", data) end
 }
