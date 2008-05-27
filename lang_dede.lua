-- Please see lang_enus.lua for reference.

QuestHelper_Translations["deDE"] =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Deutsch",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Die Sprache deiner gespeicherten Daten stimmt nicht mit der Sprache deines WoW-Clienten überein.",
  ZONE_LAYOUT_ERROR = "Ich arbeite nicht weiter, um deine gespeicherten Daten nicht zu beschädigen.Bitte warte auf einen Patch, der in der Lage ist mit dem neuen Zonen Layout umzugehen",
  DOWNGRADE_ERROR = "Deine gespeicherten Daten sind nicht kompatibel mit dieser Version von QuestHelper. Verwende eine neue Version oder lösche deine gespeicherten Variablen.",
  HOME_NOT_KNOWN = "Dein Zuhause ist nicht bekannt. Bitte sprich bei der nächsten Gelegenheit einen Gastwirt an um es zurückzusetzen.",
  
  -- Route related text.
  ROUTES_CHANGED = "Die Flugstrecken für deinen Charakter wurden verändert.",
  HOME_CHANGED = "Dein Zuhause wurde geändert.",
  TALK_TO_FLIGHT_MASTER = "Bitte sprich mit dem lokalen Flugmeister.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Danke.",
  WILL_RESET_PATH = "Information zur Wegfindung wird zurückgesetzt.",
  UPDATING_ROUTE = "Route auffrischen.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Verfügbare Sprachen:",
  LOCALE_CHANGED = "Sprache geändert zu: %h1",
  LOCALE_UNKNOWN = "Die Sprache %h1 ist nicht bekannt.",
  
  -- Words used for objectives.
  SLAY_VERB = "Töte",
  ACQUIRE_VERB = "Erbeute",
  
  OBJECTIVE_REASON = "%1 %h2 für die Quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 für die Quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Gib die Quest %h1 ab.",
  OBJECTIVE_PURCHASE = "Erwerben von %h1.",
  OBJECTIVE_TALK = "Sprich mit %h1.",
  OBJECTIVE_SLAY = "Töte %h1.",
  OBJECTIVE_LOOT = "Erbeute %h1.",
  
  ZONE_BORDER = "%1/%2 Grenze",
  
  -- Stuff used in objective menus.
  PRIORITY = "Priorität",
  PRIORITY1 = "Höchste",
  PRIORITY2 = "Hohe",
  PRIORITY3 = "Normale",
  PRIORITY4 = "Niedrige",
  PRIORITY5 = "Niedrigste",
  SHARING = "Teilen",
  SHARING_ENABLE = "Teilen",
  SHARING_DISABLE = "Nicht Teilen",
  IGNORE = "Ignorieren",
  
  IGNORED_PRIORITY_TITLE = "Die ausgewählte Priorität würde ignoriert werden.",
  IGNORED_PRIORITY_FIX = "Fügt die gleiche Priorität zu den blockierten Zielen hinzu.",
  IGNORED_PRIORITY_IGNORE = "Ich werde die Prioritäten selbst setzen.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Suchergebnis",
  NO_RESULTS = "Es gibt keine!",
  CREATED_OBJ = "Erstellt: %1",
  REMOVED_OBJ = "Gelöscht: %1",
  USER_OBJ = "Benutzer Ziel: %h1",
  UNKNOWN_OBJ = "Ich weiß nicht, wo du für dieses Ziel hingehen solltest.",
  
  SEARCHING_STATE = "Suche: %1",
  SEARCHING_LOCAL = "Sprache %1",
  SEARCHING_STATIC = "Statisch %1",
  SEARCHING_ITEMS = "Gegenstand",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zonen",
  SEARCHING_DONE = "Fertig!",
  
  -- Shared objectives.
  PEER_TURNIN = "Warte auf %h1 um %h2 abzugeben.",
  PEER_LOCATION = "Hilf %h1 einen Ort in %h2 zu erreichen.",
  PEER_ITEM = "Hilf %1 zu erwerben %h2.",
  PEER_OTHER = "Assistiere %1 mit %h2.",
  
  PEER_NEWER = "%h1 verwendet eine neuere Protokoll Version. Vielleicht ist es Zeit zum Aktualisieren.",
  PEER_OLDER = "%h1 verwendet eine ältere Protokoll Version.",
  
  UNKNOWN_MESSAGE = "Unbekannter Nachrichten Typ '%1' von '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Versteckte Ziele",
  HIDDEN_NONE = "Es gibt keine versteckten Ziele von dir.",
  DEPENDS_ON_SINGLE = "Ist abhängig von '%1'.",
  DEPENDS_ON_COUNT = "Ist abhängig von %1 versteckten Zielen.",
  FILTERED_LEVEL = "Gefiltert wegen Level.",
  FILTERED_ZONE = "Gefiltert wegen Zone.",
  FILTERED_COMPLETE = "Gefiltert wegen Vollständigkeit.",
  FILTERED_BLOCKED = "Gefiltert wegen des unvollständigen vorherigen Ziels",
  FILTERED_USER = "Du möchtest dieses Ziel ausblenden lassen.",
  FILTERED_UNKNOWN = "Es ist nicht bekannt wie es abgeschlossen werden kann.",
  
  HIDDEN_SHOW = "Zeigen.",
  DISABLE_FILTER = "Filter abschalten: %1",
  FILTER_DONE = "fertig",
  FILTER_ZONE = "Zone",
  FILTER_LEVEL = "Level",
  FILTER_BLOCKED = "blockiert",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Du hast Informationen über %h1 neue und %h2 aktualisierte %h(%s3).",
  NAG_SINGLE_NEW = "Du hast neue Informationen über %h1.",
  NAG_ADDITIONAL = "Du hast zusätzliche Informationen über %h1.",
  
  NAG_NOT_NEW = "Du hast keine Informationen, die nicht bereits in der statischen Datenbank sind.",
  NAG_NEW = "Du solltest in Betracht ziehen deine Daten zu teilen, damit andere davon profitieren können.",
  NAG_INSTRUCTIONS = "Schreibe %h (/qh submit), für Instruktionen zum einsenden von Daten.",
  
  NAG_SINGLE_FP = "einen Flugmeister",
  NAG_SINGLE_QUEST = "ein Quest",
  NAG_SINGLE_ROUTE = "eine Flugroute",
  NAG_SINGLE_ITEM_OBJ = "ein Item-Ziel",
  NAG_SINGLE_OBJECT_OBJ = "ein Gegenstands-Ziel",
  NAG_SINGLE_MONSTER_OBJ = "ein Monster-Ziel",
  NAG_SINGLE_EVENT_OBJ = "ein Ereignis-Ziel",
  NAG_SINGLE_REPUTATION_OBJ = "ein Ruf-Ziel",
  
  NAG_MULTIPLE_FP = "%1 Flugmeister",
  NAG_MULTIPLE_QUEST = "%1 Quests",
  NAG_MULTIPLE_ROUTE = "%1 Flugrouten",
  NAG_MULTIPLE_ITEM_OBJ = "%1 Item-Ziele",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 Gegenstands-Ziele",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 Monster-Ziele",
  NAG_MULTIPLE_EVENT_OBJ = "%1 Ereignis-Ziele",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 Ruf-Ziele",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's Fortschritte:",
  TRAVEL_ESTIMATE = "Geschätzte Reisezeit:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Besuche %h1 auf dem Weg zu:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Linksklick: %1 Reiseweg Information.",
  QH_BUTTON_TOOLTIP2 = "Rechtsklick: Zeige Einstellungsmenü.",
  QH_BUTTON_SHOW = "Zeige",
  QH_BUTTON_HIDE = "Verstecke",

  MENU_CLOSE = "Menü schließen",
  MENU_SETTINGS = "Einstellungen",
  MENU_ENABLE = "Aktivieren",
  MENU_DISABLE = "Deaktivieren",
  MENU_OBJECTIVE_TIPS = "%1 Ziele Tooltips",
  MENU_TRACKER_OPTIONS = "Quest Tracker",
  MENU_QUEST_TRACKER = "%1 Quest Tracker",
  MENU_TRACKER_LEVEL = "%1 Quest Levels",
  MENU_TRACKER_QCOLOUR = "%1 Quest-Schwierigkeitsfarben",
  MENU_TRACKER_OCOLOUR = "%1 Ziel Fortschritts-Farben",
  MENU_TRACKER_SCALE = "Tracker Größe",
  MENU_TRACKER_RESET = "Position zurücksetzen",
  MENU_FLIGHT_TIMER = "%1 Flug Timer",
  MENU_ANT_TRAILS = "%1 Ameisen-Spuren",
  MENU_WAYPOINT_ARROW = "%1 Wegpunkt Pfeil",
  MENU_MAP_BUTTON = "%1 Karten-Knopf",
  MENU_ZONE_FILTER = "%1 Zonenfilter",
  MENU_DONE_FILTER = "%1 Getaner Filter",
  MENU_BLOCKED_FILTER = "%1 Blockierter Filter",
  MENU_LEVEL_FILTER = "%1 Level Filter",
  MENU_LEVEL_OFFSET = "Level-Filterausgleich",
  MENU_ICON_SCALE = "Symbolgröße",
  MENU_FILTERS = "Filter",
  MENU_PERFORMANCE = "Routen-Auslastungs-Größe",
  MENU_LOCALE = "Lokalisierung",
  MENU_PARTY = "Gruppe",
  MENU_PARTY_SHARE = "%1 Ziele teilen",
  MENU_PARTY_SOLO = "%1 Gruppe ignorieren",
  MENU_HELP = "Hilfe",
  MENU_HELP_SLASH = "Slash-Befehle",
  MENU_HELP_CHANGES = "Change Log",
  MENU_HELP_SUBMIT = "Daten einsenden",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Beobachtet durch QuestHelper",
  TOOLTIP_QUEST = "Für das Quest %h1.",
  TOOLTIP_PURCHASE = "Kaufe %h1.",
  TOOLTIP_SLAY = "Töte für %h1.",
  TOOLTIP_LOOT = "Erbeute für %h1."
 }

