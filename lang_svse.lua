-- Please see lang_enus.lua for reference.

QuestHelper_Translations["svSE"] =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Svenska",
  
  -- Messages used when starting.
  LOCALE_ERROR = nil,
  ZONE_LAYOUT_ERROR = nil,
  DOWNGRADE_ERROR = nil,
  HOME_NOT_KNOWN = nil,
  
  -- Route related text.
  ROUTES_CHANGED = nil,
  HOME_CHANGED = "Ditt hem har ändrats.",
  TALK_TO_FLIGHT_MASTER = "Var vänlig prata med den lokala flygmästaren.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Tack.",
  WILL_RESET_PATH = nil,
  UPDATING_ROUTE = "Uppdaterar rutt.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Tillgängliga språk:",
  LOCALE_CHANGED = "Språk ändrat till: %h1",
  LOCALE_UNKNOWN = nil,
  
  -- Words used for objectives.
  SLAY_VERB = "Döda",
  ACQUIRE_VERB = nil,
  
  OBJECTIVE_REASON = "%1 %h2 för uppdraget %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 för uppdraget %h2.",
  OBJECTIVE_REASON_TURNIN = "Lämna in uppdraget %h1.",
  OBJECTIVE_PURCHASE = "Köp från %h1.",
  OBJECTIVE_TALK = "Prata med %h1.",
  OBJECTIVE_SLAY = "Döda %h1.",
  OBJECTIVE_LOOT = nil,
  
  ZONE_BORDER = "gränsen %1/%2",
  
  -- Stuff used in objective menus.
  PRIORITY = "Prioritet",
  PRIORITY1 = "Högsta",
  PRIORITY2 = "Hög",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Låg",
  PRIORITY5 = "Lägsta",
  SHARING = nil,
  SHARING_ENABLE = "Dela",
  SHARING_DISABLE = "Dela inte",
  IGNORE = "Ignorera",
  
  IGNORED_PRIORITY_TITLE = "Den valda prioriteten skulle ignoreras.",
  IGNORED_PRIORITY_FIX = nil,
  IGNORED_PRIORITY_IGNORE = "Jag sätter prioriteterna själv.",
  
  -- Custom objectives.
  RESULTS_TITLE = nil,
  NO_RESULTS = nil,
  CREATED_OBJ = nil,
  REMOVED_OBJ = nil,
  USER_OBJ = nil,
  UNKNOWN_OBJ = nil,
  
  SEARCHING_STATE = "Söker: %1",
  SEARCHING_LOCAL = nil,
  SEARCHING_STATIC = "Statisk %1",
  SEARCHING_ITEMS = "Föremål",
  SEARCHING_NPCS = "NPC:er",
  SEARCHING_ZONES = "Zoner",
  SEARCHING_DONE = "Klar!",
  
  -- Shared objectives.
  PEER_TURNIN = "Vänta på att %h1 ska lämna in %h2.",
  PEER_LOCATION = "Hjälp %h1 nå en plats i %h2.",
  PEER_ITEM = "Hjälp %1 få tag på %h2.",
  PEER_OTHER = "Hjälp %1 med %h2.",
  
  PEER_NEWER = "%h1 använder en nyare version av protokollet.",
  PEER_OLDER = "%h1 använder en äldre version av protokollet.",
  
  UNKNOWN_MESSAGE = nil,
  
  -- Hidden objectives.
  HIDDEN_TITLE = nil,
  HIDDEN_NONE = "Det finns inga ",
  DEPENDS_ON_SINGLE = "Beroende av '%1'.",
  DEPENDS_ON_COUNT = "Beroende av %1 gömda uppdrag.",
  FILTERED_LEVEL = "Filtrerad på grund av nivå.",
  FILTERED_ZONE = "Filtrerad på grund av zon.",
  FILTERED_COMPLETE = nil,
  FILTERED_BLOCKED = nil,
  FILTERED_USER = nil,
  FILTERED_UNKNOWN = "Vet inte hur man klarar av.",
  
  HIDDEN_SHOW = "Visa.",
  DISABLE_FILTER = nil,
  FILTER_DONE = "avklarad",
  FILTER_ZONE = "zon",
  FILTER_LEVEL = "nivå",
  FILTER_BLOCKED = "blockerad",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = nil,
  NAG_SINGLE_NEW = nil,
  NAG_ADDITIONAL = nil,
  
  NAG_NOT_NEW = nil,
  NAG_NEW = nil,
  NAG_INSTRUCTIONS = nil,
  
  NAG_SINGLE_FP = nil,
  NAG_SINGLE_QUEST = "ett uppdrag",
  NAG_SINGLE_ROUTE = nil,
  NAG_SINGLE_ITEM_OBJ = nil,
  NAG_SINGLE_OBJECT_OBJ = nil,
  NAG_SINGLE_MONSTER_OBJ = nil,
  NAG_SINGLE_EVENT_OBJ = nil,
  NAG_SINGLE_REPUTATION_OBJ = nil,
  
  NAG_MULTIPLE_FP = nil,
  NAG_MULTIPLE_QUEST = nil,
  NAG_MULTIPLE_ROUTE = nil,
  NAG_MULTIPLE_ITEM_OBJ = nil,
  NAG_MULTIPLE_OBJECT_OBJ = nil,
  NAG_MULTIPLE_MONSTER_OBJ = nil,
  NAG_MULTIPLE_EVENT_OBJ = nil,
  NAG_MULTIPLE_REPUTATION_OBJ = nil,
  
  -- Stuff used by dodads.
  PEER_PROGRESS = nil,
  TRAVEL_ESTIMATE = "Beräknad restid:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Besök %h1 på väg till:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = nil,
  QH_BUTTON_TOOLTIP2 = nil,
  QH_BUTTON_SHOW = "Visa",
  QH_BUTTON_HIDE = "Dölj",

  MENU_CLOSE = "Stäng Meny",
  MENU_SETTINGS = "Inställningar",
  MENU_ENABLE = "Aktivera",
  MENU_DISABLE = "Avaktivera",
  MENU_OBJECTIVE_TIPS = nil,
  MENU_TRACKER_OPTIONS = nil,
  MENU_QUEST_TRACKER = nil,
  MENU_TRACKER_LEVEL = "%1 Uppdragsnivåer",
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
  MENU_LEVEL_FILTER = nil,
  MENU_LEVEL_OFFSET = nil,
  MENU_ICON_SCALE = "Ikon skala",
  MENU_FILTERS = "Filter",
  MENU_PERFORMANCE = nil,
  MENU_LOCALE = "Språk",
  MENU_PARTY = "Grupp",
  MENU_PARTY_SHARE = nil,
  MENU_PARTY_SOLO = "%1 Ignorera grupp",
  MENU_HELP = "Hjälp",
  MENU_HELP_SLASH = nil,
  MENU_HELP_CHANGES = "Ändringslista",
  MENU_HELP_SUBMIT = nil,
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = nil,
  TOOLTIP_QUEST = "För uppdraget %h1.",
  TOOLTIP_PURCHASE = "Köp %h1.",
  TOOLTIP_SLAY = "Döda för %h1.",
  TOOLTIP_LOOT = "Plocka för %h1."
 }

