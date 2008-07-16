-- Please see lang_enus.lua for reference.

QuestHelper_Translations["daDK"] =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Dansk",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Sproget i dine gemte data stemmer ikke med sproget til WoW klienten. For at bruge QuestHelper skal du enten ændre sproget tilbage, eller slette dataerne ved at skrive %h(/qh purge).",
  ZONE_LAYOUT_ERROR = "Jeg nægter at køre, af frygt for at ødelægge dine gemte data. Vent venligt på en ny patch, der vil være i stand til at håndtere det nye zonelayout.",
  DOWNGRADE_ERROR = "Dine gemte data er ikke kompatible med denne version af QuestHelper. Brug en nyere version eller slet dine gemte variabler.",
  HOME_NOT_KNOWN = "Dit hjem er ikke kendt. Når du får chancen, venligst tal med din innkeeper og nulstil det.",
  
  -- Route related text.
  ROUTES_CHANGED = "Flyveruterne for din karakter er blevet ændret.",
  HOME_CHANGED = "Dit hjem er blevet ændret.",
  TALK_TO_FLIGHT_MASTER = "Snak venligst med din lokale flyveleder.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Tak.",
  WILL_RESET_PATH = "Ruteinformation vil blive nulstillet.",
  UPDATING_ROUTE = "Opdaterer rute.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Tilgængelige sprog:",
  LOCALE_CHANGED = "Sprog er ændret til: %h1",
  LOCALE_UNKNOWN = "Sproget %h1 er ikke kendt.",
  
  -- Words used for objectives.
  SLAY_VERB = "Dræb",
  ACQUIRE_VERB = "Få fat i",
  
  OBJECTIVE_REASON = "%1 %h2 til quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 til quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Aflever quest %h1.",
  OBJECTIVE_PURCHASE = "Køb fra %h1.",
  OBJECTIVE_TALK = "Snak med %h1.",
  OBJECTIVE_SLAY = "Dræb %h1.",
  OBJECTIVE_LOOT = "Saml %h1.",
  
  ZONE_BORDER = "%1/%2 grænse",
  
  -- Stuff used in objective menus.
  PRIORITY = "Prioritet",
  PRIORITY1 = "Højeste",
  PRIORITY2 = "Høj",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Lav",
  PRIORITY5 = "Laveste",
  SHARING = "Deling",
  SHARING_ENABLE = "Del",
  SHARING_DISABLE = "Del ikke",
  IGNORE = "Ignore",
  
  IGNORED_PRIORITY_TITLE = "Den valgte prioritet bliver ignoreret.",
  IGNORED_PRIORITY_FIX = "Sæt samme prioritet til de(t) blokerede objekt(er).",
  IGNORED_PRIORITY_IGNORE = "Jeg sætter selv prioriten.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Søgeresultater",
  NO_RESULTS = "Der er ingen!",
  CREATED_OBJ = "Oprettet: %1",
  REMOVED_OBJ = "Fjernet: %1",
  USER_OBJ = "Brugerobjektiv: %h1",
  UNKNOWN_OBJ = "Jeg ved ikke, hvor du skal gå hen med dette objektiv.",
  
  SEARCHING_STATE = "Søger: %1",
  SEARCHING_LOCAL = "Sprog %1",
  SEARCHING_STATIC = "Statisk %1",
  SEARCHING_ITEMS = "Genstande",
  SEARCHING_NPCS = "NPCer",
  SEARCHING_ZONES = "Zoner",
  SEARCHING_DONE = "Færdig!",
  
  -- Shared objectives.
  PEER_TURNIN = "Vent på at %h1 afleverer %h2.",
  PEER_LOCATION = "Hjælp %h1 med at nå et sted i %h2.",
  PEER_ITEM = "Hjælp %1 med at få fat i %h2.",
  PEER_OTHER = "Assistér %1 med %h2.",
  
  PEER_NEWER = "%h1 bruger en nyere protokolversion. Måske det er på tide at opgradere.",
  PEER_OLDER = "%h1 bruger en ældre protokolversion.",
  
  UNKNOWN_MESSAGE = "Ukendt beskedstype '%1' fra '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Gemte Objekter",
  HIDDEN_NONE = "Der er ingen gemte objekter for dig.",
  DEPENDS_ON_SINGLE = "Kommer an på '%1'.",
  DEPENDS_ON_COUNT = "Kommer an på %1 gemte objekter.",
  FILTERED_LEVEL = "Filtreret på grund af level.",
  FILTERED_ZONE = "Filtreret på grund af område.",
  FILTERED_COMPLETE = "Filtreret da det er afsluttet.",
  FILTERED_BLOCKED = "Filtreret grundet forudgående mål der ikke er afsluttet",
  FILTERED_USER = "Du har anmodet om, at dette objektiv bliver gemt.",
  FILTERED_UNKNOWN = "Jeg ved ikke hvordan det færdiggøres.",
  
  HIDDEN_SHOW = "Vis.",
  DISABLE_FILTER = "Lukkede filtre: %1",
  FILTER_DONE = "færdig",
  FILTER_ZONE = "område",
  FILTER_LEVEL = "level",
  FILTER_BLOCKED = "blokeret",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Du har %h(ny information) til %h1 og %h(opdateret information) til %h2.",
  NAG_SINGLE_NEW = "Du har %h(ny information) om %h1.",
  NAG_ADDITIONAL = "Du har %h(yderligere information) til %h1.",
  
  NAG_NOT_NEW = "Du har ingen information, som ikke allerede er i den statiske database.",
  NAG_NEW = "Du bør overveje, at dele dine data, så andre kan gøre brug af dem.",
  NAG_INSTRUCTIONS = "Skriv %h(/qh submit) for instruktioner til at sende data.",
  
  NAG_SINGLE_FP = "en flyveleder",
  NAG_SINGLE_QUEST = "en quest",
  NAG_SINGLE_ROUTE = "en flyverute",
  NAG_SINGLE_ITEM_OBJ = "en genstands objektiv",
  NAG_SINGLE_OBJECT_OBJ = "et objekt objektiv",
  NAG_SINGLE_MONSTER_OBJ = "et monster objektiv",
  NAG_SINGLE_EVENT_OBJ = "et event objektiv",
  NAG_SINGLE_REPUTATION_OBJ = "et omdømme objektiv",
  
  NAG_MULTIPLE_FP = "%1 flyveledere",
  NAG_MULTIPLE_QUEST = "%1 quests",
  NAG_MULTIPLE_ROUTE = "%1 flyve ruter",
  NAG_MULTIPLE_ITEM_OBJ = "%1 genstand objektiver",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 objekt objektiver",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 monster objektiver",
  NAG_MULTIPLE_EVENT_OBJ = "%1 event objektiver",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 omdømme objektiver",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's fremskridt:",
  TRAVEL_ESTIMATE = "Anslået rejsetid:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Besøg %h1 på vej til:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Venstreklik: %1 rute information.",
  QH_BUTTON_TOOLTIP2 = "Højreklik: Vis Indstillingsmenu.",
  QH_BUTTON_SHOW = "Vis",
  QH_BUTTON_HIDE = "Gem",

  MENU_CLOSE = "Luk Menu",
  MENU_SETTINGS = "Indstillinger",
  MENU_ENABLE = "Aktiver",
  MENU_DISABLE = "Deaktiver",
  MENU_OBJECTIVE_TIPS = "%1 Objektiv Tooltips",
  MENU_TRACKER_OPTIONS = "Quest Tracker",
  MENU_QUEST_TRACKER = "%1 Quest Tracker",
  MENU_TRACKER_LEVEL = "%1 Quest Levels",
  MENU_TRACKER_QCOLOUR = "%1 Quest Sværhedsgrads Farver",
  MENU_TRACKER_OCOLOUR = "%1 Objektiv Fremgangs Farver",
  MENU_TRACKER_SCALE = "Tracker Skalering",
  MENU_TRACKER_RESET = "Nulstil Position",
  MENU_FLIGHT_TIMER = "%1 Flyvetid",
  MENU_ANT_TRAILS = "%1 Myre Spor",
  MENU_WAYPOINT_ARROW = "%1 Waypoint Pil",
  MENU_MAP_BUTTON = "%1 Kort Knap",
  MENU_ZONE_FILTER = "%1 Zone Filter",
  MENU_DONE_FILTER = "%1 Færdig Filter",
  MENU_BLOCKED_FILTER = "%1 Blokeret Filter",
  MENU_LEVEL_FILTER = "%1 Level Filter",
  MENU_LEVEL_OFFSET = "Level Filter Offset",
  MENU_ICON_SCALE = "Ikon Skalering",
  MENU_FILTERS = "Filtre",
  MENU_PERFORMANCE = "Skaler Rute Arbejdsbyrde",
  MENU_LOCALE = "Sprog",
  MENU_PARTY = "Gruppe",
  MENU_PARTY_SHARE = "%1 Objektiv Deling",
  MENU_PARTY_SOLO = "%1 Ignorer Gruppe",
  MENU_HELP = "Hjælp",
  MENU_HELP_SLASH = "Skråstreg Kommandoer",
  MENU_HELP_CHANGES = "Ændre log",
  MENU_HELP_SUBMIT = "Sender data",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Fulgt af QuestHelper",
  TOOLTIP_QUEST = "Til Questen %h1.",
  TOOLTIP_PURCHASE = "Køb %h1",
  TOOLTIP_SLAY = "Dræb for %h1.",
  TOOLTIP_LOOT = "Plyndr fra %h1."
 }

