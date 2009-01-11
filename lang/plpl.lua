-- Please see enus.lua for reference.

QuestHelper_Translations.plPL =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Polski",
  
  -- Messages used when starting.
  LOCALE_ERROR = nil,
  ZONE_LAYOUT_ERROR = nil,
  DOWNGRADE_ERROR = "Twoje zapisane dane nie są zgodne z tą wersją QuestHelper'a. Użyj nowszej wersji albo usuń stare zmienne.",
  HOME_NOT_KNOWN = "Twoje pochodzenie nie jest znane. Kiedy będziesz miał czas, porozmawiaj z gospodarzem (Innkeeper) i ustaw miejsce docelowe.",
  PRIVATE_SERVER = nil,
  PLEASE_RESTART = nil,
  NOT_UNZIPPED_CORRECTLY = nil,
  PLEASE_DONATE = nil,
  HOW_TO_CONFIGURE = "QuestHelper nie ma jeszcze gotowej strony ustawień, ale może być skonfigurowany poprzez komendę %h(/qh ustawienia). Pomoc jest udzielana poprzez %h(/qh pomoc).",
  TIME_TO_UPDATE = nil,
  
  -- Route related text.
  ROUTES_CHANGED = nil,
  HOME_CHANGED = "Twoje miejsce docelowe zostało zmienione.",
  TALK_TO_FLIGHT_MASTER = nil,
  TALK_TO_FLIGHT_MASTER_COMPLETE = nil,
  WILL_RESET_PATH = nil,
  UPDATING_ROUTE = nil,
  
  -- Special tracker text
  QH_LOADING = nil,
  QUESTS_HIDDEN_1 = nil,
  QUESTS_HIDDEN_2 = nil,
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = nil,
  LOCALE_CHANGED = nil,
  LOCALE_UNKNOWN = nil,
  
  -- Words used for objectives.
  SLAY_VERB = nil,
  ACQUIRE_VERB = "Uzyskać",
  
  OBJECTIVE_REASON = nil, -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = nil,
  OBJECTIVE_REASON_TURNIN = nil,
  OBJECTIVE_PURCHASE = nil,
  OBJECTIVE_TALK = nil,
  OBJECTIVE_SLAY = nil,
  OBJECTIVE_LOOT = nil,
  
  ZONE_BORDER = nil,
  
  -- Stuff used in objective menus.
  PRIORITY = nil,
  PRIORITY1 = nil,
  PRIORITY2 = nil,
  PRIORITY3 = nil,
  PRIORITY4 = nil,
  PRIORITY5 = nil,
  SHARING = nil,
  SHARING_ENABLE = nil,
  SHARING_DISABLE = nil,
  IGNORE = "Zignoruj",
  
  IGNORED_PRIORITY_TITLE = nil,
  IGNORED_PRIORITY_FIX = nil,
  IGNORED_PRIORITY_IGNORE = nil,
  
  -- Custom objectives.
  RESULTS_TITLE = nil,
  NO_RESULTS = nil,
  CREATED_OBJ = "Utworzono: %1",
  REMOVED_OBJ = nil,
  USER_OBJ = nil,
  UNKNOWN_OBJ = nil,
  INACCESSIBLE_OBJ = nil,
  
  SEARCHING_STATE = nil,
  SEARCHING_LOCAL = nil,
  SEARCHING_STATIC = nil,
  SEARCHING_ITEMS = nil,
  SEARCHING_NPCS = nil,
  SEARCHING_ZONES = nil,
  SEARCHING_DONE = nil,
  
  -- Shared objectives.
  PEER_TURNIN = nil,
  PEER_LOCATION = nil,
  PEER_ITEM = nil,
  PEER_OTHER = nil,
  
  PEER_NEWER = nil,
  PEER_OLDER = nil,
  
  UNKNOWN_MESSAGE = nil,
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Ukryte Zadania",
  HIDDEN_NONE = "Nie ma ukrytych zadań.",
  DEPENDS_ON_SINGLE = "Zależy od '%1'",
  DEPENDS_ON_COUNT = "Zależy od %1 ukrytych zadań.",
  FILTERED_LEVEL = "Filtr ukrył zadanie, gdyż masz za niski poziom.",
  FILTERED_ZONE = "Ukryte z powodu obszaru.",
  FILTERED_COMPLETE = "Zadanie wypełnione, filtr je ukrył.",
  FILTERED_BLOCKED = "Ukryte przez filtr z powodu niewykonanego ważniejszego zadania.",
  FILTERED_UNWATCHED = "Zadanie ukryte, gdyż nie jest śledzone w Quest Log'u.",
  FILTERED_USER = "Ustawiłeś to zadanie jako ukryte.",
  FILTERED_UNKNOWN = "Program nie wie, jak ukończyć zadanie.",
  
  HIDDEN_SHOW = "Pokaż.",
  DISABLE_FILTER = "Zablokuj filtry: %1",
  FILTER_DONE = "zrobione",
  FILTER_ZONE = "obszar",
  FILTER_LEVEL = "poziom",
  FILTER_BLOCKED = "zablokowane",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = nil,
  NAG_SINGLE_NEW = nil,
  NAG_ADDITIONAL = nil,
  NAG_POLLUTED = nil,
  
  NAG_NOT_NEW = nil,
  NAG_NEW = nil,
  NAG_INSTRUCTIONS = nil,
  
  NAG_SINGLE_FP = nil,
  NAG_SINGLE_QUEST = nil,
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
  TRAVEL_ESTIMATE = nil,
  TRAVEL_ESTIMATE_VALUE = nil,
  WAYPOINT_REASON = nil,

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = nil,
  QH_BUTTON_TOOLTIP1 = nil,
  QH_BUTTON_TOOLTIP2 = nil,
  QH_BUTTON_SHOW = nil,
  QH_BUTTON_HIDE = nil,

  MENU_CLOSE = "Zamknij menu",
  MENU_SETTINGS = nil,
  MENU_ENABLE = "Włączenie",
  MENU_DISABLE = "Wyłączenie",
  MENU_OBJECTIVE_TIPS = nil,
  MENU_TRACKER_OPTIONS = nil,
  MENU_QUEST_TRACKER = nil,
  MENU_TRACKER_LEVEL = nil,
  MENU_TRACKER_QCOLOUR = nil,
  MENU_TRACKER_OCOLOUR = nil,
  MENU_TRACKER_SCALE = nil,
  MENU_TRACKER_RESET = nil,
  MENU_FLIGHT_TIMER = "%1 Czas lotu",
  MENU_ANT_TRAILS = nil,
  MENU_WAYPOINT_ARROW = nil,
  MENU_MAP_BUTTON = nil,
  MENU_ZONE_FILTER = nil,
  MENU_DONE_FILTER = "%1 Zrobione filtry",
  MENU_BLOCKED_FILTER = "%1 Zablokowane filtry",
  MENU_WATCHED_FILTER = nil,
  MENU_LEVEL_FILTER = nil,
  MENU_LEVEL_OFFSET = nil,
  MENU_ICON_SCALE = nil,
  MENU_FILTERS = "Filtry",
  MENU_PERFORMANCE = nil,
  MENU_LOCALE = nil,
  MENU_PARTY = nil,
  MENU_PARTY_SHARE = nil,
  MENU_PARTY_SOLO = nil,
  MENU_HELP = "Pomoc",
  MENU_HELP_SLASH = nil,
  MENU_HELP_CHANGES = nil,
  MENU_HELP_SUBMIT = nil,
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = nil,
  TOOLTIP_QUEST = nil,
  TOOLTIP_PURCHASE = nil,
  TOOLTIP_SLAY = nil,
  TOOLTIP_LOOT = nil
 }

