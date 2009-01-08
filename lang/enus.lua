-- Note: This file is used as fallback for locales that don't exist.

--[[
  
  SYNTAX REFERENCE
  
  All '%' characters mark the position where some text is to be inserted.
  
  Following this character is some alphabetical text controlling how the data is
  to be interpreted, which may be empty.
  
  Following that is either a number, the index to the data to insert, or
  brackets containing some text to transform, which may recursively contain
  other transformed text.
  
  Examples:
    %1
      Inserts first argument into string without changing it.
    
    %h1
      Inserts first argument into string and highlights it.
    
    %(Hello World)
      Inserts the text 'Hello World' into the string. Not entirely useful,
      as you could simply just write 'Hello World'.
    
    %h(Hello World)
      Inserts the text 'Hello World', highlighted so that it stands out.
    
    %h(%q(%(cla)%(ss)))
      This convoluted example demonstrates nesting.
      First 'cla' and 'ss' are converted into 'class', this is made
      quoted, converting it into '"classes"', and then this is highlighted.
  
  Transformations:
    
    h
      Highlight some text. Bewarned that highlighting already highlighted text
      doesn't work as expected.
    
    t
      Insert a time, argument is interpreted as a number representing seconds.
    
    p
      Insert a percentage. Argument should be a number between 0 and 1, text
      will be shaded from red at 0% to green at 100%.
    
    q
      Quotes some text.
    
    Q
      Inserts a Lua quoted and escaped string.
  
  These transformations can made to do different things depending on the locale,
  if you're translating and need something changed, please ask.
  
]]

-- If the client is using this locale, then strings from this table will always be used, regardless of
-- the locale selected for displayed text.
QuestHelper_ForcedTranslations.enUS = 
 {}

QuestHelper_Translations.enUS =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "English",
  
  -- Messages used when starting.
  LOCALE_ERROR = "The locale of your saved data doesn't match the locale of your WoW client. To use QuestHelper you'll need to either change the locale back, or delete the data by typing %h(/qh purge).",
  ZONE_LAYOUT_ERROR = "I'm refusing to run, out of fear of corrupting your saved data. "..
                      "Please wait for a patch that will be able to handle the new zone layout.",
  DOWNGRADE_ERROR = "Your saved data isn't compatible with this version of QuestHelper. "..
                    "Use a new version, or delete your saved variables.",
  HOME_NOT_KNOWN = "Your home isn't known. When you get a chance, please talk to your innkeeper and reset it.",
  PRIVATE_SERVER = "QuestHelper does not support private servers.",
  PLEASE_RESTART = "There was an error starting QuestHelper. Please exit World of Warcraft entirely and try again.",
  NOT_UNZIPPED_CORRECTLY = "QuestHelper was installed incorrectly. We recommend using either the Curse Client or 7zip to install. Make sure subdirectories are extracted.",
  PLEASE_DONATE = "%h(QuestHelper currently survives on your donations!) Anything you can contribute is appreciated, and only a few dollars a month ensures that I'll keep it updated and working. Type %h(/qh donate) for more information.",
  HOW_TO_CONFIGURE = "QuestHelper does not yet have a working settings page, but can be configured by typing %h(/qh settings). Help is available with %h(/qh help).",
  TIME_TO_UPDATE = "There may be a %h(new QuestHelper version) available. New versions usually include new features, new quest databases, and bugfixes. Please update!",
  
  -- Route related text.
  ROUTES_CHANGED = "The flight routes for your character have been altered.",
  HOME_CHANGED = "Your home has been changed.",
  TALK_TO_FLIGHT_MASTER = "Please talk to the local flight master.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Thanks.",
  WILL_RESET_PATH = "Will reset pathing information.",
  UPDATING_ROUTE = "Refreshing route.",
  
  -- Special tracker text
  QH_LOADING = "QuestHelper is loading (%1%%)...",
  QUESTS_HIDDEN_1 = "Quests may be hidden",
  QUESTS_HIDDEN_2 = "(\"/qh hidden\" to list)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Available Locales:",
  LOCALE_CHANGED = "Locale changed to: %h1",
  LOCALE_UNKNOWN = "Locale %h1 isn't known.",
  
  -- Words used for objectives.
  SLAY_VERB = "Slay",
  ACQUIRE_VERB = "Acquire",
  
  OBJECTIVE_REASON = "%1 %h2 for quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 for quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Turn in quest %h1.",
  OBJECTIVE_PURCHASE = "Purchase from %h1.",
  OBJECTIVE_TALK = "Talk to %h1.",
  OBJECTIVE_SLAY = "Slay %h1.",
  OBJECTIVE_LOOT = "Loot %h1.",
  
  ZONE_BORDER = "%1/%2 border",
  
  -- Stuff used in objective menus.
  PRIORITY = "Priority",
  PRIORITY1 = "Highest",
  PRIORITY2 = "High",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Low",
  PRIORITY5 = "Lowest",
  SHARING = "Sharing",
  SHARING_ENABLE = "Share",
  SHARING_DISABLE = "Don't Share",
  IGNORE = "Ignore",
  
  IGNORED_PRIORITY_TITLE = "The selected priority would be ignored.",
  IGNORED_PRIORITY_FIX = "Apply same priority to the blocking objectives.",
  IGNORED_PRIORITY_IGNORE = "I'll set the priorities myself.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Search Results",
  NO_RESULTS = "There aren't any!",
  CREATED_OBJ = "Created: %1",
  REMOVED_OBJ = "Removed: %1",
  USER_OBJ = "User Objective: %h1",
  UNKNOWN_OBJ = "I don't know where you should go for that objective.",
  INACCESSIBLE_OBJ = "QuestHelper has been unable to find a useful location for %h1. We've added a likely-impossible-to-find location to your objectives list. If you find a useful version of this object, please submit your data! (%h(/qh submit))",
  
  SEARCHING_STATE = "Searching: %1",
  SEARCHING_LOCAL = "Local %1",
  SEARCHING_STATIC = "Static %1",
  SEARCHING_ITEMS = "Items",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zones",
  SEARCHING_DONE = "Done!",
  
  -- Shared objectives.
  PEER_TURNIN = "Wait for %h1 to turn in %h2.",
  PEER_LOCATION = "Help %h1 reach a location in %h2.",
  PEER_ITEM = "Help %1 to acquire %h2.",
  PEER_OTHER = "Assist %1 with %h2.",
  
  PEER_NEWER = "%h1 is using a newer protocol version. It might be time to upgrade.",
  PEER_OLDER = "%h1 is using an older protocol version.",
  
  UNKNOWN_MESSAGE = "Unknown message type '%1' from '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Hidden Objectives",
  HIDDEN_NONE = "There are no objectives hidden from you.",
  DEPENDS_ON_SINGLE = "Depends on '%1'.",
  DEPENDS_ON_COUNT = "Depends on %1 hidden objectives.",
  FILTERED_LEVEL = "Filtered due to level.",
  FILTERED_ZONE = "Filtered due to zone.",
  FILTERED_COMPLETE = "Filtered due to completeness.",
  FILTERED_BLOCKED = "Filtered due to incomplete prior objective",
  FILTERED_UNWATCHED = "Filtered due to not being Tracked in the Quest Log",
  FILTERED_USER = "You requested this objective be hidden.",
  FILTERED_UNKNOWN = "Don't know how to complete.",
  
  HIDDEN_SHOW = "Show.",
  DISABLE_FILTER = "Disable filter: %1",
  FILTER_DONE = "done",
  FILTER_ZONE = "zone",
  FILTER_LEVEL = "level",
  FILTER_BLOCKED = "blocked",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "You have %h(new information) on %h1, and %h(updated information) on %h2.",
  NAG_SINGLE_NEW = "You have %h(new information) on %h1.",
  NAG_ADDITIONAL = "You have %h(additional information) on %h1.",
  NAG_POLLUTED = "Your database has been polluted by information from a test or private server, and will be cleared on startup.",
  
  NAG_NOT_NEW = "You don't have any information not already in the static database.",
  NAG_NEW = "You might consider sharing your data so that others may benefit.",
  NAG_INSTRUCTIONS = "Type %h(/qh submit) for instructions on submitting data.",
  
  NAG_SINGLE_FP = "a flight master",
  NAG_SINGLE_QUEST = "a quest",
  NAG_SINGLE_ROUTE = "a flight route",
  NAG_SINGLE_ITEM_OBJ = "an item objective",
  NAG_SINGLE_OBJECT_OBJ = "an object objective",
  NAG_SINGLE_MONSTER_OBJ = "a monster objective",
  NAG_SINGLE_EVENT_OBJ = "an event objective",
  NAG_SINGLE_REPUTATION_OBJ = "a reputation objective",
  NAG_SINGLE_PLAYER_OBJ = "a player objective",
  
  NAG_MULTIPLE_FP = "%1 flight masters",
  NAG_MULTIPLE_QUEST = "%1 quests",
  NAG_MULTIPLE_ROUTE = "%1 flight routes",
  NAG_MULTIPLE_ITEM_OBJ = "%1 item objectives",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 object objectives",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 monster objectives",
  NAG_MULTIPLE_EVENT_OBJ = "%1 event objectives",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 reputation objectives",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 player objectives",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's progress:",
  TRAVEL_ESTIMATE = "Estimated travel time:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visit %h1 en route to:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Left Click: %1 routing information.",
  QH_BUTTON_TOOLTIP2 = "Right Click: Show Settings menu.",
  QH_BUTTON_SHOW = "Show",
  QH_BUTTON_HIDE = "Hide",

  MENU_CLOSE = "Close Menu",
  MENU_SETTINGS = "Settings",
  MENU_ENABLE = "Enable",
  MENU_DISABLE = "Disable",
  MENU_OBJECTIVE_TIPS = "%1 Objective Tooltips",
  MENU_TRACKER_OPTIONS = "Quest Tracker",
  MENU_QUEST_TRACKER = "%1 Quest Tracker",
  MENU_TRACKER_LEVEL = "%1 Quest Levels",
  MENU_TRACKER_QCOLOUR = "%1 Quest Difficulty Colours",
  MENU_TRACKER_OCOLOUR = "%1 Objective Progress Colours",
  MENU_TRACKER_SCALE = "Tracker Scale",
  MENU_TRACKER_RESET = "Reset Position",
  MENU_FLIGHT_TIMER = "%1 Flight Timer",
  MENU_ANT_TRAILS = "%1 Ant Trails",
  MENU_WAYPOINT_ARROW = "%1 Waypoint Arrow",
  MENU_MAP_BUTTON = "%1 Map Button",
  MENU_ZONE_FILTER = "%1 Zone Filter",
  MENU_DONE_FILTER = "%1 Done Filter",
  MENU_BLOCKED_FILTER = "%1 Blocked Filter",
  MENU_WATCHED_FILTER = "%1 Watched Filter",
  MENU_LEVEL_FILTER = "%1 Level Filter",
  MENU_LEVEL_OFFSET = "Level Filter Offset",
  MENU_ICON_SCALE = "Icon Scale",
  MENU_FILTERS = "Filters",
  MENU_PERFORMANCE = "Route Workload Scale",
  MENU_LOCALE = "Locale",
  MENU_PARTY = "Party",
  MENU_PARTY_SHARE = "%1 Objective Sharing",
  MENU_PARTY_SOLO = "%1 Ignore Party",
  MENU_HELP = "Help",
  MENU_HELP_SLASH = "Slash Commands",
  MENU_HELP_CHANGES = "Change Log",
  MENU_HELP_SUBMIT = "Submitting Data",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Watched by QuestHelper",
  TOOLTIP_QUEST = "For Quest %h1.",
  TOOLTIP_PURCHASE = "Purchase %h1.",
  TOOLTIP_SLAY = "Slay for %h1.",
  TOOLTIP_LOOT = "Loot for %h1."
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
  
  -- Quote: "%q1" will insert argument 1 as quoted text.
  ["q"] = function(data) return string.format("“%s”", data) end,
  
  -- Lua quote: "%Q1" will insert argument 1 as a quoted lua string.
  ["Q"] = function(data) return string.format("%q", data) end
 }
