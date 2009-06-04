-- Please see enus.lua for reference.

QuestHelper_Translations.fiFI =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Englanti",
  
  -- Messages used when starting.
  LOCALE_ERROR = nil,
  ZONE_LAYOUT_ERROR = nil,
  DOWNGRADE_ERROR = nil,
  HOME_NOT_KNOWN = "Kotisi sijainti ei ole tiedossa. Kun mahdollista, puhu majatalon pitäjälle antaaksesi tiedon.",
  PRIVATE_SERVER = "QuestHelper ei tue yksityispalvelimia",
  PLEASE_RESTART = "virhe käynnistettäessä QuestHelperiä. sulje World of Warcraft ja yritä uudelleen.",
  NOT_UNZIPPED_CORRECTLY = nil,
  PLEASE_DONATE = nil,
  HOW_TO_CONFIGURE = nil,
  TIME_TO_UPDATE = nil,
  
  -- Route related text.
  ROUTES_CHANGED = nil,
  HOME_CHANGED = "kotisi on vaihdettu",
  TALK_TO_FLIGHT_MASTER = nil,
  TALK_TO_FLIGHT_MASTER_COMPLETE = "kiitos",
  WILL_RESET_PATH = nil,
  UPDATING_ROUTE = nil,
  
  -- Special tracker text
  QH_LOADING = "ladataan QuestHelper (%1%)...",
  QH_FLIGHTPATH = nil,
  QUESTS_HIDDEN_1 = "tehtäviä piilotettu",
  QUESTS_HIDDEN_2 = "(kirjoita \"/qh hidden\" nähdäksesi kaikki)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Valittavat kielet",
  LOCALE_CHANGED = "Kieli vaihdettu: %h1",
  LOCALE_UNKNOWN = "Kieltä %h1 ei tunneta.",
  
  -- Words used for objectives.
  SLAY_VERB = "tapa",
  ACQUIRE_VERB = "poimi",
  
  OBJECTIVE_REASON = nil, -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = nil,
  OBJECTIVE_REASON_TURNIN = nil,
  OBJECTIVE_PURCHASE = nil,
  OBJECTIVE_TALK = "Puhu %h1:lle",
  OBJECTIVE_SLAY = "Tapa %h1.",
  OBJECTIVE_LOOT = "Kerää %h1.",
  
  OBJECTIVE_MONSTER_UNKNOWN = "tuntematon vihollinen",
  OBJECTIVE_ITEM_UNKNOWN = "tuntematon esine",
  
  ZONE_BORDER = nil,
  
  -- Stuff used in objective menus.
  PRIORITY = "tärkeysaste",
  PRIORITY1 = "korkein",
  PRIORITY2 = "korkea",
  PRIORITY3 = "normaali",
  PRIORITY4 = "matala",
  PRIORITY5 = "matalin",
  SHARING = "jaettu",
  SHARING_ENABLE = "jaa",
  SHARING_DISABLE = "elä jaa",
  IGNORE = "piilota",
  IGNORE_LOCATION = "Piilota tämä sijainti",
  
  IGNORED_PRIORITY_TITLE = "Valittu tärkeysaste piilotettu",
  IGNORED_PRIORITY_FIX = nil,
  IGNORED_PRIORITY_IGNORE = "Määritän tärkeysasteen itse",
  
  -- Custom objectives.
  RESULTS_TITLE = "hakutulokset",
  NO_RESULTS = nil,
  CREATED_OBJ = "tee",
  REMOVED_OBJ = nil,
  USER_OBJ = nil,
  UNKNOWN_OBJ = nil,
  INACCESSIBLE_OBJ = nil,
  
  SEARCHING_STATE = "haetaan: %1",
  SEARCHING_LOCAL = nil,
  SEARCHING_STATIC = nil,
  SEARCHING_ITEMS = nil,
  SEARCHING_NPCS = nil,
  SEARCHING_ZONES = "alueet",
  SEARCHING_DONE = "valmis!",
  
  -- Shared objectives.
  PEER_TURNIN = nil,
  PEER_LOCATION = nil,
  PEER_ITEM = nil,
  PEER_OTHER = nil,
  
  PEER_NEWER = "%h1 käyttää uudempaa versiota. päivitä QuestHelper.",
  PEER_OLDER = "%h1 käyttää vanhempaa versiota.",
  
  UNKNOWN_MESSAGE = nil,
  
  -- Hidden objectives.
  HIDDEN_TITLE = nil,
  HIDDEN_NONE = "ei piilotettuja objekteja",
  DEPENDS_ON_SINGLE = nil,
  DEPENDS_ON_COUNT = nil,
  DEPENDS_ON = nil,
  FILTERED_LEVEL = nil,
  FILTERED_ZONE = nil,
  FILTERED_COMPLETE = nil,
  FILTERED_BLOCKED = nil,
  FILTERED_UNWATCHED = nil,
  FILTERED_USER = nil,
  FILTERED_UNKNOWN = nil,
  
  HIDDEN_SHOW = "näytä",
  HIDDEN_SHOW_NO = "ei näytettävissä",
  HIDDEN_EXCEPTION = nil,
  DISABLE_FILTER = nil,
  FILTER_DONE = "tehty",
  FILTER_ZONE = "alue",
  FILTER_LEVEL = "lvl",
  FILTER_BLOCKED = "estetty",
  FILTER_WATCHED = nil,
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = nil,
  NAG_SINGLE_NEW = nil,
  NAG_ADDITIONAL = nil,
  NAG_POLLUTED = nil,
  
  NAG_NOT_NEW = nil,
  NAG_NEW = nil,
  NAG_INSTRUCTIONS = nil,
  
  NAG_SINGLE_FP = nil,
  NAG_SINGLE_QUEST = "tehtävä",
  NAG_SINGLE_ROUTE = nil,
  NAG_SINGLE_ITEM_OBJ = nil,
  NAG_SINGLE_OBJECT_OBJ = nil,
  NAG_SINGLE_MONSTER_OBJ = nil,
  NAG_SINGLE_EVENT_OBJ = nil,
  NAG_SINGLE_REPUTATION_OBJ = nil,
  NAG_SINGLE_PLAYER_OBJ = nil,
  
  NAG_MULTIPLE_FP = nil,
  NAG_MULTIPLE_QUEST = nil,
  NAG_MULTIPLE_ROUTE = nil,
  NAG_MULTIPLE_ITEM_OBJ = nil,
  NAG_MULTIPLE_OBJECT_OBJ = nil,
  NAG_MULTIPLE_MONSTER_OBJ = nil,
  NAG_MULTIPLE_EVENT_OBJ = nil,
  NAG_MULTIPLE_REPUTATION_OBJ = nil,
  NAG_MULTIPLE_PLAYER_OBJ = nil,
  
  -- Stuff used by dodads.
  PEER_PROGRESS = nil,
  TRAVEL_ESTIMATE = "Arvioitu matkustusaika",
  TRAVEL_ESTIMATE_VALUE = nil,
  WAYPOINT_REASON = nil,
  FLIGHT_POINT = "%1: lentopiste",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = nil,
  QH_BUTTON_TOOLTIP2 = "hiiren oikea painike: näytä asetukset",
  QH_BUTTON_SHOW = "näytä",
  QH_BUTTON_HIDE = "piilota",

  MENU_CLOSE = "Sulje",
  MENU_SETTINGS = "asetukset",
  MENU_ENABLE = nil,
  MENU_DISABLE = "Estä",
  MENU_OBJECTIVE_TIPS = nil,
  MENU_TRACKER_OPTIONS = nil,
  MENU_QUEST_TRACKER = nil,
  MENU_TRACKER_LEVEL = nil,
  MENU_TRACKER_QCOLOUR = nil,
  MENU_TRACKER_OCOLOUR = nil,
  MENU_TRACKER_SCALE = nil,
  MENU_TRACKER_RESET = nil,
  MENU_FLIGHT_TIMER = nil,
  MENU_ANT_TRAILS = nil,
  MENU_WAYPOINT_ARROW = nil,
  MENU_MAP_BUTTON = nil,
  MENU_ZONE_FILTER = nil,
  MENU_DONE_FILTER = nil,
  MENU_BLOCKED_FILTER = nil,
  MENU_WATCHED_FILTER = nil,
  MENU_LEVEL_FILTER = "%1 tason suodatus",
  MENU_LEVEL_OFFSET = nil,
  MENU_ICON_SCALE = nil,
  MENU_FILTERS = "suotimet",
  MENU_PERFORMANCE = nil,
  MENU_LOCALE = nil,
  MENU_PARTY = "party",
  MENU_PARTY_SHARE = nil,
  MENU_PARTY_SOLO = nil,
  MENU_HELP = "apua",
  MENU_HELP_SLASH = nil,
  MENU_HELP_CHANGES = "muutosloki",
  MENU_HELP_SUBMIT = nil,
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = nil,
  TOOLTIP_QUEST = nil,
  TOOLTIP_PURCHASE = nil,
  TOOLTIP_SLAY = "tapa %h1:lle",
  TOOLTIP_LOOT = "kerää %h1:ltä",
  
  -- Settings
  SETTINGS_ARROWLINK_ON = nil,
  SETTINGS_ARROWLINK_OFF = nil,
  SETTINGS_ARROWLINK_ARROW = "QuestHelper nuoli",
  SETTINGS_ARROWLINK_CART = nil,
  SETTINGS_ARROWLINK_TOMTOM = "TomTom",
  SETTINGS_PRECACHE_ON = nil,
  SETTINGS_PRECACHE_OFF = nil,
  
  SETTINGS_MENU_ENABLE = "salli",
  SETTINGS_MENU_DISABLE = "estä",
  SETTINGS_MENU_CARTWP = nil,
  SETTINGS_MENU_TOMTOM = nil,
  
  SETTINGS_MENU_ARROW_LOCK = "lukitse",
  SETTINGS_MENU_ARROW_ARROWSCALE = "nuolen koko",
  SETTINGS_MENU_ARROW_TEXTSCALE = nil,
  SETTINGS_MENU_ARROW_RESET = "nollaa",
  
  -- I'm just tossing miscellaneous stuff down here
  DISTANCE_YARDS = "%h1 jaardia",
  DISTANCE_METRES = nil
 }

