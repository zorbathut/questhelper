-- Please see lang_enus.lua for reference.

QuestHelper_Translations.zhCN =
 {
  --[[ THIS FILE NEEDS TO BE TRANSLATED; REMOVE THIS LINE WHEN COMPLETED.
  
  -- Displayed by locale chooser.
  LOCALE_NAME = "English",
  
  -- Messages used when starting.
  LOCALE_ERROR = "The locale of your saved data doesn't match the locale of your WoW client.",
  ZONE_LAYOUT_ERROR = "I'm refusing to run, out of fear of corrupting your saved data. "..
                      "Please wait for a patch that will be able to handle the new zone layout.",
  DOWNGRADE_ERROR = "Your saved data isn't compatible with this version of QuestHelper. "..
                    "Use a new version, or delete your saved variables.",
  HOME_NOT_KNOWN = "Your home isn't known. When you get a chance, please talk to your innkeeper and reset it.",
  
  -- This text is only printed for the enUS client, don't worry about translating it.
  ALTERED_INDEX = "!!! QuestHelper_IndexLookup entry needs update: [%Q1] = {%2, %3, %4}",
  ALTERED_ZONE = "!!! QuestHelper_Zones entry needs update: [%1][%2] = %Q3 -- was %4",
  
  -- Route related text.
  ROUTES_CHANGED = "The flight routes for your character have been altered.",
  HOME_CHANGED = "Your home has been changed.",
  TALK_TO_FLIGHT_MASTER = "Please talk to the local flight master.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Thanks.",
  WILL_RESET_PATH = "Will reset pathing information.",
  
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
  ENABLE = "Enable",
  DISABLE = "Disable",
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
  FILTERED_USER = "You requested this objective be hidden.",
  FILTERED_UNKNOWN = "Don't know how to complete.",
  
  HIDDEN_SHOW = "Show.",
  DISABLE_FILTER = "Disable filter: %1",
  FILTER_DONE = "done",
  FILTER_ZONE = "zone",
  FILTER_LEVEL = "level",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_SINGLE = "1 %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %s2",
  
  NAG_MULTIPLE_NEW = "You have information on %h1 new and %h2 updated %h(%s3).",
  NAG_SINGLE_NEW = "You have new information on %h1.",
  NAG_ADDITIONAL = "You have additional information on %h1.",
  
  NAG_NOT_NEW = "You don't have any information not already in the static database.",
  NAG_NEW = "You might consider sharing your data so that others may benefit.",
  
  NAG_FP = "flight master",
  NAG_QUEST = "quest",
  NAG_ROUTE = "flight route",
  NAG_ITEM_OBJ = "item objective",
  NAG_OBJECT_OBJ = "object objective",
  NAG_MONSTER_OBJ = "monster objective",
  NAG_EVENT_OBJ = "event objective",
  NAG_REPUTATION_OBJ = "reputation objective",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's progress:",
  TRAVEL_ESTIMATE = "Estimated travel time:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visit %h1 en route to:"
  
  END COMMENT BLOCK; REMOVE THIS LINE WHEN COMPLETED ]]
 }
