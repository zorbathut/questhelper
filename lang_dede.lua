QuestHelper_Translations.deDE =
 {
  -- Messages used when starting.
  LOCALE_ERROR = "Die Sprache deiner gespeicherten Daten stimmt nicht mit der Sprache deines WoW-Clienten überein.",
  ZONE_LAYOUT_ERROR = "Ich weigere mich weiter zu arbeiten, aus Angst deine gespeicherten Daten zu beschädigen."..
                      "Bitte warte auf einen Patch, der in der Lage ist mit dem neuen Zonen Layout umzugehen",
  DOWNGRADE_ERROR = "Deine gespeicherten Daten sind nicht kompatibel mit dieser Version von QuestHelper."..
                    "Verwende eine neue Version oder lösche deine gespeicherten Variablen.",
  HOME_NOT_KNOWN = "Dein Zuhause ist nicht bekannt. Bitte sprich bei der nächsten Gelegenheit einen Gastwirt um es zurückzusetzen.",
  
  -- Route related text.
  ROUTES_CHANGED = "Die Flugstrecken für deinen Charakter wurden verändert.",
  HOME_CHANGED = "Dein Zuhause wurde geändert.",
  TALK_TO_FLIGHT_MASTER = "Bitte sprich mit dem lokalen Flugmeister.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Danke.",
  WILL_RESET_PATH = "Information zur Wegfindung wird zurückgesetzt.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Verfügbare Sprachen:",
  LOCALE_CHANGED = "Sprache geändert zu: %h1",
  LOCALE_UNKNOWN = "Die Sprache %h1 ist nicht bekannt.",
  
  -- Words used for objectives.
  SLAY_VERB = "Töten",
  ACQUIRE_VERB = "Erbeuten",
  
  OBJECTIVE_REASON = "%1 %h2 für das Quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 für das Quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Quest %h1 abgeben.",
  OBJECTIVE_PURCHASE = "Erwerben von %h1.",
  OBJECTIVE_TALK = "Sprechen Sie mit %h1.", -- Came from Google Translate, no promises this makes sense.
  OBJECTIVE_SLAY = "Töte %h1.",
  OBJECTIVE_LOOT = "Erbeute %h1.",
  
  ZONE_BORDER = "%1/%2 Grenze",
  
  -- Stuff used in objective menus.
  PRIORITY = "Priorität",
  PRIORITY1 = "Höchste",
  PRIORITY2 = "Nohe",
  PRIORITY3 = "Normale",
  PRIORITY4 = "Niedrige",
  PRIORITY5 = "Niedrigste",
  SHARING = "Teilen",
  ENABLE = "Aktivieren",
  DISABLE = "Abschalten",
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
  
  UNKNOWN_MESSAGE = "Unbekannter Narichten Typ '%1' von '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Versteckte Ziele",
  HIDDEN_NONE = "Es gibt keine versteckten Ziele von dir.",
  DEPENDS_ON_SINGLE = "Ist abhängig von '%1'.",
  DEPENDS_ON_COUNT = "Ist abhängig von %1 versteckten Zielen.",
  FILTERED_LEVEL = "Gefiltert wegen Level.",
  FILTERED_ZONE = "Gefiltert wegen Zone.",
  FILTERED_COMPLETE = "Gefiltert wegen Vollständigkeit.",
  FILTERED_USER = "Du möchtest dieses Ziel ausblenden lassen.",
  FILTERED_UNKNOWN = "Nicht bekannt wie es abgeschlossen werden kann.",
  
  HIDDEN_SHOW = "Zeigen.",
  DISABLE_FILTER = "Filter abschalten: %1",
  FILTER_DONE = "fertig",
  FILTER_ZONE = "Zone",
  FILTER_LEVEL = "Level",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_SINGLE = "a %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %2s",
  
  NAG_MULTIPLE_NEW = "Du hast Informationen über %h1 neu und %h2 aktualisiert %h3.",
  NAG_SINGLE_NEW = "Du hast Informationen über neue %h1.",
  NAG_ADDITIONAL = "Du hast zusätzliche Informationen über %h1.",
  
  NAG_NOT_NEW = "Du hast keine Informationen, die nicht bereits in der statischen Datenbank sind.",
  NAG_NEW = "Du solltest in Betracht ziehen deine Daten teilen, damit andere davon profitieren können.",
  
  NAG_FP = "Flugmeister",
  NAG_QUEST = "Quest",
  NAG_ROUTE = "Flugroute",
  NAG_ITEM_OBJ = "Gegenstands Ziel",
  NAG_OBJECT_OBJ = "Objekt Ziel",
  NAG_MONSTER_OBJ = "Monster Ziel",
  NAG_EVENT_OBJ = "Event Ziel",
  NAG_REPUTATION_OBJ = "Ruf Ziel",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's Fortschritte:",
  TRAVEL_ESTIMATE = "Geschätzte Fahrzeit:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Besuche %h1 auf dem Weg zu:"
 }
