-- Please see lang_enus.lua for reference.

QuestHelper_Translations.svSE =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Svenska",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Språket för dina sparade data matchar inte språket för din WoW klient. För att använda QuestHelper, måste du antingen ändra tillbaka språket, eller radera datan genom att skriva %h(/qh purge).",
  ZONE_LAYOUT_ERROR = nil,
  DOWNGRADE_ERROR = "Din sparade data är inte kompatibel med denna version av Questhelper. Använd en ny version, eller radera sina sparade variabler.",
  HOME_NOT_KNOWN = "Ditt hem är okänt. När du får chansen, prata med din innkeeper för att nollställa det.",
  PRIVATE_SERVER = nil,
  PLEASE_RESTART = nil,
  NOT_UNZIPPED_CORRECTLY = nil,
  PLEASE_DONATE = nil,
  
  -- Route related text.
  ROUTES_CHANGED = "Flygvägen för din karaktär har ändrats",
  HOME_CHANGED = "Ditt hem har ändrats.",
  TALK_TO_FLIGHT_MASTER = "Var vänlig prata med den lokala flygmästaren.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Tack.",
  WILL_RESET_PATH = nil,
  UPDATING_ROUTE = "Uppdaterar rutt.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Tillgängliga språk:",
  LOCALE_CHANGED = "Språk ändrat till: %h1",
  LOCALE_UNKNOWN = "Språket %h1 är okänt",
  
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
  SHARING = "Delar",
  SHARING_ENABLE = "Dela",
  SHARING_DISABLE = "Dela inte",
  IGNORE = "Ignorera",
  
  IGNORED_PRIORITY_TITLE = "Den valda prioriteten skulle ignoreras.",
  IGNORED_PRIORITY_FIX = "Godkänn samma prioritet till det blockerade uppdraget.",
  IGNORED_PRIORITY_IGNORE = "Jag sätter prioriteterna själv.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Sök resultat",
  NO_RESULTS = nil,
  CREATED_OBJ = "Skapad: %1",
  REMOVED_OBJ = "Borttagen: %1",
  USER_OBJ = nil,
  UNKNOWN_OBJ = nil,
  INACCESSIBLE_OBJ = nil,
  
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
  
  PEER_NEWER = "%h1 använder en nyare version av protokollet. Det är kanske tid att uppgradera",
  PEER_OLDER = "%h1 använder en äldre version av protokollet.",
  
  UNKNOWN_MESSAGE = "Okänt meddelande av typen '%1' från '%2'",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Gömda Uppdrag",
  HIDDEN_NONE = "Det finns inga objekt gömda i från dig",
  DEPENDS_ON_SINGLE = "Beroende av '%1'.",
  DEPENDS_ON_COUNT = "Beroende av %1 gömda uppdrag.",
  FILTERED_LEVEL = "Filtrerad på grund av nivå.",
  FILTERED_ZONE = "Filtrerad på grund av zon.",
  FILTERED_COMPLETE = "Filtrerad på grund av fullgjort",
  FILTERED_BLOCKED = "Filtrerad på grund av att föregående uppdrag inte är klart.",
  FILTERED_UNWATCHED = nil,
  FILTERED_USER = "Du har begärt att detta uppdrag ska vara gömt.",
  FILTERED_UNKNOWN = "Vet inte hur man klarar av.",
  
  HIDDEN_SHOW = "Visa.",
  DISABLE_FILTER = "Inaktivera filter: %1",
  FILTER_DONE = "avklarad",
  FILTER_ZONE = "zon",
  FILTER_LEVEL = "nivå",
  FILTER_BLOCKED = "blockerad",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = nil,
  NAG_SINGLE_NEW = "Du har (ny information) om",
  NAG_ADDITIONAL = "Du har (information) om",
  NAG_POLLUTED = nil,
  
  NAG_NOT_NEW = "Du har ingen information som inte redan finns i static databasen",
  NAG_NEW = "Du ska kanske dela med av dina data så andra kan ha nytta av dom",
  NAG_INSTRUCTIONS = "Skriv (/qh submit) för instruktioner om hur du sänder data",
  
  NAG_SINGLE_FP = nil,
  NAG_SINGLE_QUEST = "ett uppdrag",
  NAG_SINGLE_ROUTE = nil,
  NAG_SINGLE_ITEM_OBJ = nil,
  NAG_SINGLE_OBJECT_OBJ = nil,
  NAG_SINGLE_MONSTER_OBJ = nil,
  NAG_SINGLE_EVENT_OBJ = nil,
  NAG_SINGLE_REPUTATION_OBJ = nil,
  NAG_SINGLE_PLAYER_OBJ = nil,
  
  NAG_MULTIPLE_FP = nil,
  NAG_MULTIPLE_QUEST = "uppdrag",
  NAG_MULTIPLE_ROUTE = "Flyg vägar",
  NAG_MULTIPLE_ITEM_OBJ = nil,
  NAG_MULTIPLE_OBJECT_OBJ = nil,
  NAG_MULTIPLE_MONSTER_OBJ = nil,
  NAG_MULTIPLE_EVENT_OBJ = nil,
  NAG_MULTIPLE_REPUTATION_OBJ = nil,
  NAG_MULTIPLE_PLAYER_OBJ = nil,
  
  -- Stuff used by dodads.
  PEER_PROGRESS = nil,
  TRAVEL_ESTIMATE = "Beräknad restid:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Besök %h1 på väg till:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = nil,
  QH_BUTTON_TOOLTIP2 = "Höger klicka: Visa Inställningar",
  QH_BUTTON_SHOW = "Visa",
  QH_BUTTON_HIDE = "Dölj",

  MENU_CLOSE = "Stäng Meny",
  MENU_SETTINGS = "Inställningar",
  MENU_ENABLE = "Aktivera",
  MENU_DISABLE = "Avaktivera",
  MENU_OBJECTIVE_TIPS = "Uppdrag tips",
  MENU_TRACKER_OPTIONS = "Uppdrags sökare",
  MENU_QUEST_TRACKER = "Uppdrags sökare",
  MENU_TRACKER_LEVEL = "%1 Uppdragsnivåer",
  MENU_TRACKER_QCOLOUR = "Uppdrags svårighets färger",
  MENU_TRACKER_OCOLOUR = nil,
  MENU_TRACKER_SCALE = nil,
  MENU_TRACKER_RESET = nil,
  MENU_FLIGHT_TIMER = "%1 Flygtimer",
  MENU_ANT_TRAILS = "%1 Myr Spår",
  MENU_WAYPOINT_ARROW = nil,
  MENU_MAP_BUTTON = "Kartknapp",
  MENU_ZONE_FILTER = "Områdes filter",
  MENU_DONE_FILTER = "%1 Filtret Färdigt",
  MENU_BLOCKED_FILTER = "%1 Blockerat Filter",
  MENU_WATCHED_FILTER = nil,
  MENU_LEVEL_FILTER = "%1 Nivå Filter",
  MENU_LEVEL_OFFSET = "Nivå Filter Offset",
  MENU_ICON_SCALE = "Ikon skala",
  MENU_FILTERS = "Filter",
  MENU_PERFORMANCE = "Ändra arbetsbördans skala",
  MENU_LOCALE = "Språk",
  MENU_PARTY = "Grupp",
  MENU_PARTY_SHARE = "Dela Uppdrag",
  MENU_PARTY_SOLO = "%1 Ignorera grupp",
  MENU_HELP = "Hjälp",
  MENU_HELP_SLASH = "Slash Kommandon",
  MENU_HELP_CHANGES = "Ändringslista",
  MENU_HELP_SUBMIT = "Skicka data",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "övervakad av Questhelper",
  TOOLTIP_QUEST = "För uppdraget %h1.",
  TOOLTIP_PURCHASE = "Köp %h1.",
  TOOLTIP_SLAY = "Döda för %h1.",
  TOOLTIP_LOOT = "Plocka för %h1."
 }

