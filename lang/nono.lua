-- Please see enus.lua for reference.

QuestHelper_Translations.noNO =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Engelsk",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Språket i dine lagrede data passer ikke til språket på din WoW klient. For å bruke QuestHelper må du enten skifte språk, eller slette alle data ved å skrive %h(/qh purge)",
  ZONE_LAYOUT_ERROR = "QuestHelper nekter å starte, i frykt for å ødelegge lagret data. Vennligst vent på en oppdatering som støtter den nye sone layouten.",
  DOWNGRADE_ERROR = "Dine lagrede data er ikke kompatible med denne versjonen av QuestHelper. Oppdatér til en nyere versjon, eller slett dine lagrede variabler.",
  HOME_NOT_KNOWN = "Ditt hjem er ikke kjent. Når du har mulighet, prat med en innkeeper og tilbakestill det.",
  PRIVATE_SERVER = "QuestHelper støtter ikke private servere.",
  PLEASE_RESTART = "QuestHelper feilet ved oppstart. Vennligst lukk World of Warcraft helt og prøv igjen.",
  NOT_UNZIPPED_CORRECTLY = "QuestHelper ble installert feil. Vi anbefaler enten Curse Client eller 7zip for installasjon. Sjekk at undermapper er pakket ut.",
  PLEASE_DONATE = nil,
  HOW_TO_CONFIGURE = "QuestHelper har ikke noen fungerende innstillinger, men kan konfigureres ved å skrive %h(/qh settings). Hjelp er tilgjengelig med %h(/qh help).",
  TIME_TO_UPDATE = "Det kan være en %h(ny QuestHelper versjon) tilgjengelig. Nye versjoner inkludere som regel nye tillegg, nye quest databaser, og feilrettinger. Vennligst oppdater!",
  
  -- Route related text.
  ROUTES_CHANGED = "Flyverutene for din karakter har blitt endret.",
  HOME_CHANGED = "Ditt hjem har blitt endret.",
  TALK_TO_FLIGHT_MASTER = "Vennligst prat med den lokale flight masteren.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Takk.",
  WILL_RESET_PATH = "Viltilbakestille ruteinformasjon.",
  UPDATING_ROUTE = "Oppdaterer rute.",
  
  -- Special tracker text
  QH_LOADING = "QuestHelper starter (%1%%)...",
  QUESTS_HIDDEN_1 = "Quester kan være skjult",
  QUESTS_HIDDEN_2 = "(\"/qh hidden\" for å liste)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Tilgjenelige språk:",
  LOCALE_CHANGED = "Språk endret til: %h1",
  LOCALE_UNKNOWN = "Språket %h1 er ikke kjent.",
  
  -- Words used for objectives.
  SLAY_VERB = "Drep",
  ACQUIRE_VERB = "Anskaff",
  
  OBJECTIVE_REASON = "%1 %h2 for quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 for quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Lever inn quest %h1.",
  OBJECTIVE_PURCHASE = "Kjøp fra %h.",
  OBJECTIVE_TALK = "Snakk med %h1.",
  OBJECTIVE_SLAY = "Drep %h1",
  OBJECTIVE_LOOT = "Plukk opp %h.",
  
  ZONE_BORDER = "%1/%2 grense",
  
  -- Stuff used in objective menus.
  PRIORITY = "Prioritet",
  PRIORITY1 = "Høyest",
  PRIORITY2 = "Høy",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Lav",
  PRIORITY5 = "lavest",
  SHARING = "Deling",
  SHARING_ENABLE = "Del",
  SHARING_DISABLE = "Ikke Del",
  IGNORE = "Ignorér",
  
  IGNORED_PRIORITY_TITLE = "Den valgte prioriteten blir ignorert.",
  IGNORED_PRIORITY_FIX = "Angi samme prioritet til blokkerte objektiver.",
  IGNORED_PRIORITY_IGNORE = "jeg setter prioriteringene selv.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Søkeresultater",
  NO_RESULTS = "Det er ingen!",
  CREATED_OBJ = "Laget: %1",
  REMOVED_OBJ = "Fjernet: %1",
  USER_OBJ = "Bruker objektiv: %h1",
  UNKNOWN_OBJ = "Jeg vet ikke hvor du skal dra for det objektivet.",
  INACCESSIBLE_OBJ = "QuestHelper er ute av stand til å finne ett område for %h1. Vi har lagt til ett \"nærmest-umulig-å-finne område til objektivlisten. Hvis du finner et brukbart område for dette, vennligst send dine data! (%h(/qh submit)) ",
  
  SEARCHING_STATE = "Søker: %1",
  SEARCHING_LOCAL = "Lokal %1",
  SEARCHING_STATIC = "Statisk %1",
  SEARCHING_ITEMS = "Ting",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Soner",
  SEARCHING_DONE = "Ferdig!",
  
  -- Shared objectives.
  PEER_TURNIN = "Vent på at %h1 skal levere inn %h2.",
  PEER_LOCATION = "Hjelp %h1 å nå lokasjonen %h2.",
  PEER_ITEM = "Hjelp %1 å skaffe %h2.",
  PEER_OTHER = "Hjelp %1 med !h2.",
  
  PEER_NEWER = "%h1 bruker en nyere protokoll versjon. Du bør oppgradere.",
  PEER_OLDER = "%h1 bruker en eldre protokoll versjon.",
  
  UNKNOWN_MESSAGE = "Ukjent beskjed '%1' fra '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Skjulte Objektiver",
  HIDDEN_NONE = "Det er ingen objektiver som er skjult.",
  DEPENDS_ON_SINGLE = "Kommer an på '%1'.",
  DEPENDS_ON_COUNT = "Kommer an på %1 skjulte oppdrag.",
  FILTERED_LEVEL = "Filtrért grunnet nivå.",
  FILTERED_ZONE = "Filtrért grunnet Sone.",
  FILTERED_COMPLETE = "Filtrért grunnet utført quest.",
  FILTERED_BLOCKED = "Filtrért grunnet tidligere uferdige objektiver",
  FILTERED_UNWATCHED = "Filtrért grunnet quest ikke blir fulgt i Oppdragslogg",
  FILTERED_USER = "Du ba om å gjemme dette objektivet.",
  FILTERED_UNKNOWN = "Vet ikke hvordan det utføres.",
  
  HIDDEN_SHOW = "Vis.",
  DISABLE_FILTER = "Slå av filter: %1",
  FILTER_DONE = "ferdig",
  FILTER_ZONE = "sone",
  FILTER_LEVEL = "nivå",
  FILTER_BLOCKED = "blokkert",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Du har %h(ny informasjon) på %h1, og %h(oppdatert informasjon) på %h2.",
  NAG_SINGLE_NEW = "Du har %h(ny informasjon) på %h.",
  NAG_ADDITIONAL = "Du har %h(mere informasjon) om %h1.",
  NAG_POLLUTED = "Databasen din har blitt forurenset med informasjon fra en test eller privat server, og vil bli renset ved oppstart.",
  
  NAG_NOT_NEW = "Du har ingen informasjon som ikke allerede er i den statiske databasen.",
  NAG_NEW = "Du bør tenke på å dele dine data så andre kan dra nytte av dem.",
  NAG_INSTRUCTIONS = "Skriv %h(/qh submit) for instruksjoner om å sende data.",
  
  NAG_SINGLE_FP = "En flight master",
  NAG_SINGLE_QUEST = "1 quest",
  NAG_SINGLE_ROUTE = "En fly rute",
  NAG_SINGLE_ITEM_OBJ = nil,
  NAG_SINGLE_OBJECT_OBJ = nil,
  NAG_SINGLE_MONSTER_OBJ = "Et monster objektiv",
  NAG_SINGLE_EVENT_OBJ = nil,
  NAG_SINGLE_REPUTATION_OBJ = "Et rykte objektiv",
  NAG_SINGLE_PLAYER_OBJ = "Et spiller objektiv",
  
  NAG_MULTIPLE_FP = "%1 flight masters",
  NAG_MULTIPLE_QUEST = "%1 quester",
  NAG_MULTIPLE_ROUTE = "%1 fly rute",
  NAG_MULTIPLE_ITEM_OBJ = nil,
  NAG_MULTIPLE_OBJECT_OBJ = nil,
  NAG_MULTIPLE_MONSTER_OBJ = nil,
  NAG_MULTIPLE_EVENT_OBJ = nil,
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 rykte objektiv",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 spiller objektiver",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's framgang:",
  TRAVEL_ESTIMATE = "Estimert flytid:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Besøk %h1 på vei til:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Venstreklikk: %1 ruteinformasjon.",
  QH_BUTTON_TOOLTIP2 = "Høyreklikk: Vis Innstillinger.",
  QH_BUTTON_SHOW = "Vis",
  QH_BUTTON_HIDE = "Skjul",

  MENU_CLOSE = "Lukk Meny",
  MENU_SETTINGS = "Innstillinger",
  MENU_ENABLE = "Slå På",
  MENU_DISABLE = "Slå Av",
  MENU_OBJECTIVE_TIPS = "%1 Objektivtips",
  MENU_TRACKER_OPTIONS = "Oppdragsfølger",
  MENU_QUEST_TRACKER = "%1 Oppdragsfølger",
  MENU_TRACKER_LEVEL = "%1 Oppragsnivå",
  MENU_TRACKER_QCOLOUR = "%1 Farger for oppdragets vanskelighetsgrad ",
  MENU_TRACKER_OCOLOUR = "%1 Farger for Objektivfremgang",
  MENU_TRACKER_SCALE = "Skala for Oppdragsfølger",
  MENU_TRACKER_RESET = "Tilbakestill Posisjon",
  MENU_FLIGHT_TIMER = "%1 Flytid",
  MENU_ANT_TRAILS = "%1 Maurspor",
  MENU_WAYPOINT_ARROW = "%1 Objektivpil",
  MENU_MAP_BUTTON = "%1 Kartknapp",
  MENU_ZONE_FILTER = "%1 Sone filter",
  MENU_DONE_FILTER = "%1 Utført Filter",
  MENU_BLOCKED_FILTER = "%1 Blokkert Filter",
  MENU_WATCHED_FILTER = "%1 Overvåket Filter",
  MENU_LEVEL_FILTER = "%1 Nivåfilter",
  MENU_LEVEL_OFFSET = "Nivåfilter Offset",
  MENU_ICON_SCALE = "Ikonskala",
  MENU_FILTERS = "Filtre",
  MENU_PERFORMANCE = "Rutens arbeidsskala",
  MENU_LOCALE = "Språk",
  MENU_PARTY = "Gruppe",
  MENU_PARTY_SHARE = "%1 Objektivdeling",
  MENU_PARTY_SOLO = "%1 Overse Gruppe",
  MENU_HELP = "Hjelp",
  MENU_HELP_SLASH = "Slash kommandoer",
  MENU_HELP_CHANGES = "Endringslogg",
  MENU_HELP_SUBMIT = "Sende Data",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Overvåket av QuestHelper",
  TOOLTIP_QUEST = "For Quest %h1.",
  TOOLTIP_PURCHASE = "Kjøp %h1.",
  TOOLTIP_SLAY = "Drep for %h1.",
  TOOLTIP_LOOT = "Bytte for %h1."
 }

