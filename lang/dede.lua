-- Please see enus.lua for reference.

QuestHelper_Translations.deDE =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Deutsch",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Die Sprache Deiner gespeicherten Daten stimmt nicht mit der Sprache Deines WoW-Clients überein.",
  ZONE_LAYOUT_ERROR = "Das Addon wird nicht ausgeführt, um Deine gespeicherten Daten nicht zu beschädigen. Warte auf einen Patch, der in der Lage ist, daß neue Zonenlayout zu verarbeiten.",
  DOWNGRADE_ERROR = "Deine gespeicherten Daten sind nicht kompatibel mit dieser Version von QuestHelper. Verwende eine neue Version oder lösche Deine gespeicherten Variablen.",
  HOME_NOT_KNOWN = "Dein Zuhause ist nicht bekannt. Sprich bei der nächsten Gelegenheit mit einem Gastwirt, um es zurückzusetzen.",
  PRIVATE_SERVER = "QuestHelper unterstützt keine privaten Server.",
  PLEASE_RESTART = "Beim Starten von QuestHelper ist ein Fehler aufgetreten. Beende World of Warcraft vollständig und versuche es erneut.",
  NOT_UNZIPPED_CORRECTLY = "QuestHelper wurde nicht ordnungsgemäß installiert. Wir empfehlen den Curse-Client oder 7zip für die Installation. Achte darauf, daß Unterverzeichnisse entpackt werden.",
  PLEASE_DONATE = "%h(QuestHelper lebt nur von Spenden!) Jeder Beitrag ist willkommen. Ein paar Dollar im Monat stellen sicher, daß ich am Addon arbeite und es aktualisiere. Gib %h(/qh donate) ein, um weitere Informationen zu erhalten.",
  HOW_TO_CONFIGURE = "Questhelper hat noch keine funktionierende Einstellungsseite. Du kannst es konfigurieren, indem du %h(/qh settings) eintippst. Mit %h(/qh help) rufst Du die Hilfe auf.",
  TIME_TO_UPDATE = "Möglicherweise ist eine %h(neue QuestHelper-Version) verfügbar. Neue Versionen umfassen gewöhnlich neue Funktionen, neue Questdatenbanken und Bugfixes. Du solltest ein Update durchführen!",
  
  -- Route related text.
  ROUTES_CHANGED = "Die Flugstrecken für Deinen Charakter wurden verändert.",
  HOME_CHANGED = "Dein Zuhause wurde geändert.",
  TALK_TO_FLIGHT_MASTER = "Sprich mit dem örtlichen Flugmeister.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Danke.",
  WILL_RESET_PATH = "Informationen zur Wegfindung werden zurückgesetzt.",
  UPDATING_ROUTE = "Strecke wird neu berechnet.",
  
  -- Special tracker text
  QH_LOADING = "QuestHelper wird geladen: (%1%%)",
  QUESTS_HIDDEN_1 = "Quests sind vielleicht ausgeblendet.",
  QUESTS_HIDDEN_2 = "(\"/qh hidden\" zum Auflisten)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Verfügbare Sprachen:",
  LOCALE_CHANGED = "Sprache geändert in: %h1",
  LOCALE_UNKNOWN = "Die Sprache %h1 ist nicht bekannt.",
  
  -- Words used for objectives.
  SLAY_VERB = "Töte",
  ACQUIRE_VERB = "Erbeute",
  
  OBJECTIVE_REASON = "%1 %h2 für die Quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 für die Quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Gib die Quest %h1 ab.",
  OBJECTIVE_PURCHASE = "Kaufen von %h1.",
  OBJECTIVE_TALK = "Sprich mit %h1.",
  OBJECTIVE_SLAY = "Töte %h1.",
  OBJECTIVE_LOOT = "Erbeute %h1.",
  
  ZONE_BORDER = "Grenze %1/%2",
  
  -- Stuff used in objective menus.
  PRIORITY = "Priorität",
  PRIORITY1 = "Am höchsten",
  PRIORITY2 = "Hoch",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Niedrig",
  PRIORITY5 = "Am niedrigsten",
  SHARING = "Teilen",
  SHARING_ENABLE = "Teilen",
  SHARING_DISABLE = "Nicht teilen",
  IGNORE = "Ignorieren",
  
  IGNORED_PRIORITY_TITLE = "Die ausgewählte Priorität würde ignoriert werden.",
  IGNORED_PRIORITY_FIX = "Fügt dieselbe Priorität zu den blockierten Zielen hinzu.",
  IGNORED_PRIORITY_IGNORE = "Ich werde die Prioritäten selbst festlegen.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Suchergebnisse",
  NO_RESULTS = "Es gibt keine!",
  CREATED_OBJ = "Erstellt: %1",
  REMOVED_OBJ = "Gelöscht: %1",
  USER_OBJ = "Benutzerziel: %h1",
  UNKNOWN_OBJ = "QuestHelper weiß nicht, wo Du für dieses Ziel hingehen solltest.",
  INACCESSIBLE_OBJ = "QuestHelper konnte keinen sinnvollen Ort für %h1 finden. Wir haben Deiner Aufgabenliste möglicherweise einen nicht zu findenden Ort hinzugefügt. Wenn Du eine nützliche Version dieses Objekts findest, sende Deine Daten ein! (%h(/qh submit))",
  
  SEARCHING_STATE = "Suche: %1",
  SEARCHING_LOCAL = "Lokale %1",
  SEARCHING_STATIC = "Statische %1",
  SEARCHING_ITEMS = "Gegenstände",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zonen",
  SEARCHING_DONE = "Fertig!",
  
  -- Shared objectives.
  PEER_TURNIN = "Warte auf %h1, um %h2 abzugeben.",
  PEER_LOCATION = "Hilf %h1, einen Ort in %h2 zu erreichen.",
  PEER_ITEM = "Hilf %1, %h2 zu erwerben.",
  PEER_OTHER = "Unterstütze %1 bei %h2.",
  
  PEER_NEWER = "%h1 verwendet eine neuere Protokollversion. Vielleicht ist es Zeit zum Aktualisieren.",
  PEER_OLDER = "%h1 verwendet eine ältere Protokollversion.",
  
  UNKNOWN_MESSAGE = "Unbekannter Nachrichtentyp '%1' von '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Versteckte Ziele",
  HIDDEN_NONE = "Für Dich werden keine Ziele ausgeblendet.",
  DEPENDS_ON_SINGLE = "Ist abhängig von '%1'.",
  DEPENDS_ON_COUNT = "Ist abhängig von %1 versteckten Zielen.",
  FILTERED_LEVEL = "Gefiltert wegen Level.",
  FILTERED_ZONE = "Gefiltert wegen Zone.",
  FILTERED_COMPLETE = "Gefiltert wegen Vollständigkeit.",
  FILTERED_BLOCKED = "Gefiltert wegen eines unvollständigen vorherigen Ziels.",
  FILTERED_UNWATCHED = "Gefiltert, weil nicht im Quest-Log beobachtet.",
  FILTERED_USER = "Du möchtest dieses Ziel ausblenden lassen.",
  FILTERED_UNKNOWN = "Es ist nicht bekannt, wie es abgeschlossen werden kann.",
  
  HIDDEN_SHOW = "Anzeigen",
  DISABLE_FILTER = "Filter deaktivieren: %1",
  FILTER_DONE = "Erledigt",
  FILTER_ZONE = "Zone",
  FILTER_LEVEL = "Level",
  FILTER_BLOCKED = "Blockiert",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Du hast %h(neue Informationen) zu %h1 und %h(aktualisierte Informationen) zu %h2.",
  NAG_SINGLE_NEW = "Du hast %h(neue Informationen) zu %h1.",
  NAG_ADDITIONAL = "Du hast zusätzliche Informationen zu %h1.",
  NAG_POLLUTED = "In Deiner Datenbank befinden sich Informationen von einem Testserver oder privaten Server. Sie wird beim Starten bereinigt.",
  
  NAG_NOT_NEW = "Du hast keine Informationen, die nicht bereits in der statischen Datenbank sind.",
  NAG_NEW = "Du solltest in Betracht ziehen Deine Daten zu teilen, damit andere davon profitieren können.",
  NAG_INSTRUCTIONS = "Gib %h(/qh submit) ein, um Anweisungen zum Einsenden von Daten zu erhalten.",
  
  NAG_SINGLE_FP = "einem Flugmeister",
  NAG_SINGLE_QUEST = "einer Quest",
  NAG_SINGLE_ROUTE = "einer Flugroute",
  NAG_SINGLE_ITEM_OBJ = "einem Gegenstandsziel",
  NAG_SINGLE_OBJECT_OBJ = "einem Objektziel",
  NAG_SINGLE_MONSTER_OBJ = "einem Monsterziel",
  NAG_SINGLE_EVENT_OBJ = "einem Ereignisziel",
  NAG_SINGLE_REPUTATION_OBJ = "einem Rufziel",
  NAG_SINGLE_PLAYER_OBJ = "einem Spielerziel",
  
  NAG_MULTIPLE_FP = "%1 Flugmeistern",
  NAG_MULTIPLE_QUEST = "%1 Quests",
  NAG_MULTIPLE_ROUTE = "%1 Flugstrecken",
  NAG_MULTIPLE_ITEM_OBJ = "%1 Gegenstandszielen",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 Objektzielen",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 Monsterzielen",
  NAG_MULTIPLE_EVENT_OBJ = "%1 Ereigniszielen",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 Rufzielen",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 Spielerzielen",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's Fortschritte:",
  TRAVEL_ESTIMATE = "Geschätzte Reisezeit:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Besuche %h1 auf dem Weg zu:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Linksklick: Reiseweginformationen %1.",
  QH_BUTTON_TOOLTIP2 = "Rechtsklick: Einstellungsmenü anzeigen.",
  QH_BUTTON_SHOW = "anzeigen",
  QH_BUTTON_HIDE = "ausblenden",

  MENU_CLOSE = "Menü schließen",
  MENU_SETTINGS = "Einstellungen",
  MENU_ENABLE = "aktivieren",
  MENU_DISABLE = "deaktivieren",
  MENU_OBJECTIVE_TIPS = "Ziel-Tooltipps %1",
  MENU_TRACKER_OPTIONS = "Quest Tracker",
  MENU_QUEST_TRACKER = "%1 Quest Tracker",
  MENU_TRACKER_LEVEL = "%1 Quest Levels",
  MENU_TRACKER_QCOLOUR = "Farben für Questschwierigkeit %1",
  MENU_TRACKER_OCOLOUR = "Farben für Zielfortschritt %1",
  MENU_TRACKER_SCALE = "Trackergröße",
  MENU_TRACKER_RESET = "Position zurücksetzen",
  MENU_FLIGHT_TIMER = "Flugzeit %1",
  MENU_ANT_TRAILS = "Ameisenspuren %1",
  MENU_WAYPOINT_ARROW = "Wegpunktpfeil %1",
  MENU_MAP_BUTTON = "Kartenknopf %1",
  MENU_ZONE_FILTER = "Zonenfilter %1",
  MENU_DONE_FILTER = "Erledigt-Filter %1",
  MENU_BLOCKED_FILTER = "Blockiert-Filter %1",
  MENU_WATCHED_FILTER = "Beobachtet-Filter %1",
  MENU_LEVEL_FILTER = "%1 Level Filter",
  MENU_LEVEL_OFFSET = "Offset für Levelfilter",
  MENU_ICON_SCALE = "Symbolgröße",
  MENU_FILTERS = "Filter",
  MENU_PERFORMANCE = "Wert für Streckenauslastung",
  MENU_LOCALE = "Sprache",
  MENU_PARTY = "Gruppe",
  MENU_PARTY_SHARE = "Teilen von Zielen %1",
  MENU_PARTY_SOLO = "Gruppe ignorieren %1",
  MENU_HELP = "Hilfe",
  MENU_HELP_SLASH = "Slash-Befehle",
  MENU_HELP_CHANGES = "Change Log",
  MENU_HELP_SUBMIT = "Daten einsenden",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Von QuestHelper beobachtet.",
  TOOLTIP_QUEST = "Für die Quest %h1.",
  TOOLTIP_PURCHASE = "Kaufe %h1.",
  TOOLTIP_SLAY = "Töte für %h1.",
  TOOLTIP_LOOT = "Erbeute für %h1."
 }

