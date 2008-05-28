-- Please see lang_enus.lua for reference.

QuestHelper_Translations["daDK"] =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Dansk",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Sproget i dine gemte data stemmer ikke med sprogt for til WoW klient.",
  ZONE_LAYOUT_ERROR = "Jeg nægter at køre, af frygt for at ødelægge dine gemte data. Vent venligt på en ny patch, der vil være i stand til at håndtere det nye zonelayout.",
  DOWNGRADE_ERROR = "Dine gemte data er ikke kompatible med denne version af QuestHelper. Brug en nyere version eller slet dine gemte variabler.",
  HOME_NOT_KNOWN = "Din hjemmelokation er ikke kendt. Kontakt din foretrukne kroejer for at vælge en.",
  
  -- Route related text.
  ROUTES_CHANGED = "Flyveruterne for din karakter er blevet ændret.",
  HOME_CHANGED = "Din hjemmelokation er ændret.",
  TALK_TO_FLIGHT_MASTER = "Snak venligst med din lokale flyvemester.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Tak.",
  WILL_RESET_PATH = "Ruteinformation vil blive nulstillet.",
  UPDATING_ROUTE = nil,
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Tilgængelige sprog:",
  LOCALE_CHANGED = "Sprog er ændret til: %h1",
  LOCALE_UNKNOWN = "Sproget %h1 er ikke kendt.",
  
  -- Words used for objectives.
  SLAY_VERB = "Dræb",
  ACQUIRE_VERB = "Få fat i",
  
  OBJECTIVE_REASON = "%1 %h2 til quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 til questen %h2.",
  OBJECTIVE_REASON_TURNIN = "Aflever questen %h1.",
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
  SHARING = "Del",
  SHARING_ENABLE = "del",
  SHARING_DISABLE = "del ikke",
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
  UNKNOWN_OBJ = "Jeg ved ikke, hvor du skal gå hen til dette objektiv.",
  
  SEARCHING_STATE = "Søger: %1",
  SEARCHING_LOCAL = "Sprog %1",
  SEARCHING_STATIC = "Statisk %1",
  SEARCHING_ITEMS = "Genstand",
  SEARCHING_NPCS = "NPCer",
  SEARCHING_ZONES = "Zoner",
  SEARCHING_DONE = "Færdig!",
  
  -- Shared objectives.
  PEER_TURNIN = "Vent på %h1 for at aflevere %h2.",
  PEER_LOCATION = "Hjælp %h1 med at nå et sted hen i %h2.",
  PEER_ITEM = "Hjælp %1 med at få fat i %h2.",
  PEER_OTHER = "Assistér %1 med %h2.",
  
  PEER_NEWER = "%h1 bruger en nyere protokolversion. Måske det er på tide at opgradere.",
  PEER_OLDER = "%h1 bruger en ældre protokolversion.",
  
  UNKNOWN_MESSAGE = "Ukendt beskedstype '%1' fra '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Gemte Objekter",
  HIDDEN_NONE = "Der er ingen gemte objekter for dig.",
  DEPENDS_ON_SINGLE = "Kommer an på '%1'.",
  DEPENDS_ON_COUNT = "Kommer an på %1 gemte objecter.",
  FILTERED_LEVEL = "Filtreret på grund af level.",
  FILTERED_ZONE = "Filtreret på grund af område.",
  FILTERED_COMPLETE = "Filtreret da det er afsluttet.",
  FILTERED_BLOCKED = nil,
  FILTERED_USER = "Du har anmodet om, at dette objektiv bliver gemt.",
  FILTERED_UNKNOWN = "Jeg ved ikke hvordan det færdiggøres.",
  
  HIDDEN_SHOW = "Vis.",
  DISABLE_FILTER = "Lukkede filtre: %1",
  FILTER_DONE = "færdig",
  FILTER_ZONE = "område",
  FILTER_LEVEL = "level",
  FILTER_BLOCKED = "blokeret",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Du har ny information omkring %h1 og %h2 opdaterede %h(%s3).",
  NAG_SINGLE_NEW = "Du har ny information til %h1.",
  NAG_ADDITIONAL = "Du har yderligere information til %h1.",
  
  NAG_NOT_NEW = "Du har ingen information, som ikke allerede er i den statiske database.",
  NAG_NEW = "Du bør overveje, at dele dine data, så andre kan gøre brug af dem.",
  NAG_INSTRUCTIONS = nil,
  
  NAG_SINGLE_FP = nil,
  NAG_SINGLE_QUEST = nil,
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
  PEER_PROGRESS = "%1's fremskridt:",
  TRAVEL_ESTIMATE = "Anslået rejsetid:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Besøg %h1 på vej til:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = nil,
  QH_BUTTON_TOOLTIP1 = nil,
  QH_BUTTON_TOOLTIP2 = nil,
  QH_BUTTON_SHOW = "vis",
  QH_BUTTON_HIDE = "gem",

  MENU_CLOSE = "luk menu",
  MENU_SETTINGS = "indstillinger",
  MENU_ENABLE = "tændt",
  MENU_DISABLE = "slukket",
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
  MENU_BLOCKED_FILTER = "%1 blokeret filter",
  MENU_LEVEL_FILTER = nil,
  MENU_LEVEL_OFFSET = nil,
  MENU_ICON_SCALE = nil,
  MENU_FILTERS = nil,
  MENU_PERFORMANCE = nil,
  MENU_LOCALE = nil,
  MENU_PARTY = "Gruppe",
  MENU_PARTY_SHARE = nil,
  MENU_PARTY_SOLO = "%1 ignorer gruppe",
  MENU_HELP = "hjælp",
  MENU_HELP_SLASH = nil,
  MENU_HELP_CHANGES = "ændre log",
  MENU_HELP_SUBMIT = nil,
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = nil,
  TOOLTIP_QUEST = nil,
  TOOLTIP_PURCHASE = "køb %h1",
  TOOLTIP_SLAY = "Dræb for %h1.",
  TOOLTIP_LOOT = nil
 }

