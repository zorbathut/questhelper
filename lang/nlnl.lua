-- Please see enus.lua for reference.

QuestHelper_Translations.nlNL =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Nederlands",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Sorry, de vertaling van je opgeslagen data komt niet overeen met de taal van je WoW client. Om QuestHelper te gebruiken herstel je de vertaling of verwijder je de data door het volgende te typen: %h(/qh purge).",
  ZONE_LAYOUT_ERROR = "Ik kan niet opstarten, omdat ik bang ben anders je opgeslagen data kapot te maken. Wacht alsjeblieft op een patch die wel deze zone layout aankan.",
  DOWNGRADE_ERROR = "Je opgeslagen data is niet bruikbaar met deze versie van QuestHelper. Gebruik een nieuwere versie of verwijder je 'saved variables' data.",
  HOME_NOT_KNOWN = "Je thuis is niet bekend. Praat met een innkeeper om deze in te stellen.",
  PRIVATE_SERVER = "Private servers worden niet door QuestHelper ondersteund.",
  PLEASE_RESTART = "Er is een error gevonden tijdens het opstarten van World of Warcraft, exit dit programma helemaal en probeer het opnieuw.",
  NOT_UNZIPPED_CORRECTLY = "QuestHelper is niet goed geinstalleerd. we raden aan om de curse cleint of 7zip te installeren. Controleer of de sub-mappen uit zijn gepakt.",
  PLEASE_DONATE = "%h(QuestHelper currently survives on your donations!) Alles wat je kunt missen is welkom, en een paar euro per maand zorgen ervoor dat ik het kan updaten en werkend kan houden. Type %h(/qh donate) voor meer informatie.",
  HOW_TO_CONFIGURE = "Questelper heeft nog geen werkende settings pagina, maar dit kan geconfigureerd worden door %h(/qh settings) te typen. Hulp is beschikbaar met %h(/qh help).",
  TIME_TO_UPDATE = nil,
  
  -- Route related text.
  ROUTES_CHANGED = "De vliegroutes voor je karakter zijn veranderd.",
  HOME_CHANGED = "Je thuis is veranderd.",
  TALK_TO_FLIGHT_MASTER = "Praat met de lokale Flightmaster.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Bedankt.",
  WILL_RESET_PATH = "Routes worden opnieuw ingesteld.",
  UPDATING_ROUTE = "Route wordt ververst.",
  
  -- Special tracker text
  QH_LOADING = nil,
  QUESTS_HIDDEN_1 = nil,
  QUESTS_HIDDEN_2 = nil,
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Beschikbare Vertalingen:",
  LOCALE_CHANGED = "Taal veranderd in: %h1",
  LOCALE_UNKNOWN = "De vertaling %h1 is onbekend.",
  
  -- Words used for objectives.
  SLAY_VERB = "Dood",
  ACQUIRE_VERB = "Verwerf",
  
  OBJECTIVE_REASON = "%1 %h2 for quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 for quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Lever quest %h1 in.",
  OBJECTIVE_PURCHASE = "Koop van %h1.",
  OBJECTIVE_TALK = "Praat met %h1.",
  OBJECTIVE_SLAY = "Dood %h1.",
  OBJECTIVE_LOOT = "Loot %h1.",
  
  ZONE_BORDER = "%1/%2 border",
  
  -- Stuff used in objective menus.
  PRIORITY = "Prioriteit",
  PRIORITY1 = "Hoogste",
  PRIORITY2 = "Hoog",
  PRIORITY3 = "Normaal",
  PRIORITY4 = "Laag",
  PRIORITY5 = "Laagste",
  SHARING = "Delen",
  SHARING_ENABLE = "Deel",
  SHARING_DISABLE = "Deel niet",
  IGNORE = "Negeren",
  
  IGNORED_PRIORITY_TITLE = "De geselecteerde prioriteit zal worden genegeerd.",
  IGNORED_PRIORITY_FIX = "Apply same priority to the blocking objectives.",
  IGNORED_PRIORITY_IGNORE = "Ik stel zelf de prioriteiten in.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Zoek Resultaten",
  NO_RESULTS = "Sorry, geen resultaten gevonden!",
  CREATED_OBJ = "Gemaakt: %1",
  REMOVED_OBJ = "Verwijderd: %1",
  USER_OBJ = "Gebruikers Doel: %h1",
  UNKNOWN_OBJ = "Geen idee waar je dat doel kunt vinden.",
  INACCESSIBLE_OBJ = "QuestHelper heeft geen locatie gevonden voor %h1. We hebben een zo-goed-als-onmogelijk-vindbare locatie aan de doelenlijst toegevoegd. Wanneer je een bruikbare versie van dit object vind, deel dan je data! (%h( /qh submit))",
  
  SEARCHING_STATE = "Aan het zoeken: %1",
  SEARCHING_LOCAL = "Local %1",
  SEARCHING_STATIC = "Static %1",
  SEARCHING_ITEMS = "Items",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zones",
  SEARCHING_DONE = "Klaar!",
  
  -- Shared objectives.
  PEER_TURNIN = "Wacht op %h1 om %h2 in te leveren.",
  PEER_LOCATION = "Help %h1 reach a location in %h2.",
  PEER_ITEM = "Help %1 om %h2 te krijgen.",
  PEER_OTHER = "Help %1 met %h2.",
  
  PEER_NEWER = "%h1 gebruikt een versie met een nieuwer protocol. Het is misschien handig om te upgraden naar een nieuwe versie van QuestHelper.",
  PEER_OLDER = "%h1 gebruikt een versie met een ouder protocol.",
  
  UNKNOWN_MESSAGE = "Unknown message type '%1' from '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Verborgen Doelen",
  HIDDEN_NONE = "Er zijn geen doelen verborgen voor je.",
  DEPENDS_ON_SINGLE = "Hangt van '%1' af.",
  DEPENDS_ON_COUNT = "Hangt van %1 verborgen doelen af.",
  FILTERED_LEVEL = "Gefilterd als gevolg van je level.",
  FILTERED_ZONE = "Gefilterd voor je zone.",
  FILTERED_COMPLETE = "Gefilterd omdat je het al voltooid heb.",
  FILTERED_BLOCKED = "Gefilterd door een eerder incompleet doel.",
  FILTERED_UNWATCHED = "Uitgefilterd omdat het niet gevolgd wordt in het Quest logboek",
  FILTERED_USER = "Je hebt dit doel verborgen.",
  FILTERED_UNKNOWN = "Geen idee hoe dit te voltooien.",
  
  HIDDEN_SHOW = "Toon.",
  DISABLE_FILTER = "Zet filter: %1 uit.",
  FILTER_DONE = "klaar",
  FILTER_ZONE = "zone",
  FILTER_LEVEL = "level",
  FILTER_BLOCKED = "geblokkeerd",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Je hebt nieuwe informatie voor %h1: %h(new information). En geupdated informatie voor %h2: %h(updated information).",
  NAG_SINGLE_NEW = "Je hebt nieuwe informatie voor %h1: %h(new information).",
  NAG_ADDITIONAL = "Je hebt meer informatie voor %h1 verkregen.",
  NAG_POLLUTED = "Je database is vervuild met informatie van een test of private server en wordt opgeschoond bij opstarten.",
  
  NAG_NOT_NEW = "Je hebt geen nieuwe informatie voor de database.",
  NAG_NEW = "Deel je informatie, zodat anderen er ook van kunnen profiteren.",
  NAG_INSTRUCTIONS = "Type %h(/qh submit) om instructies te krijgen voor het insturen van data.",
  
  NAG_SINGLE_FP = "een Flightmaster",
  NAG_SINGLE_QUEST = "een quest",
  NAG_SINGLE_ROUTE = "een vliegroute",
  NAG_SINGLE_ITEM_OBJ = "een item doel",
  NAG_SINGLE_OBJECT_OBJ = "een object doel",
  NAG_SINGLE_MONSTER_OBJ = "een monster doel",
  NAG_SINGLE_EVENT_OBJ = "een gebeurtenis doel",
  NAG_SINGLE_REPUTATION_OBJ = "een reputatie doel",
  NAG_SINGLE_PLAYER_OBJ = "een speler doel",
  
  NAG_MULTIPLE_FP = "%1 Flightmasters",
  NAG_MULTIPLE_QUEST = "%1 quests",
  NAG_MULTIPLE_ROUTE = "%1 vlieg routes",
  NAG_MULTIPLE_ITEM_OBJ = "%1 item doelen",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 object doelen",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 monster doelen",
  NAG_MULTIPLE_EVENT_OBJ = "%1 gebeurtenis doel",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 reputatie doelen",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 speler doelen",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's voortgang:",
  TRAVEL_ESTIMATE = "Geschatte reistijd:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Bezoek %h1 en route naar:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Links klik: %1 route informatie.",
  QH_BUTTON_TOOLTIP2 = "Rechts klik: Toon Instellingen.",
  QH_BUTTON_SHOW = "Laat zien",
  QH_BUTTON_HIDE = "Verberg",

  MENU_CLOSE = "Sluit Menu",
  MENU_SETTINGS = "Instellingen",
  MENU_ENABLE = "Activeer",
  MENU_DISABLE = "Deactiveer",
  MENU_OBJECTIVE_TIPS = "%1 Doel Tooltips",
  MENU_TRACKER_OPTIONS = "Quest Volger",
  MENU_QUEST_TRACKER = "%1 Quest Volger",
  MENU_TRACKER_LEVEL = "%1 Quest Levels",
  MENU_TRACKER_QCOLOUR = "%1 Kleuren Moeilijkheidsgraad Quests",
  MENU_TRACKER_OCOLOUR = "%1 Kleur Voortgang Doelen",
  MENU_TRACKER_SCALE = "Schaal Volger",
  MENU_TRACKER_RESET = "Herstel Positie",
  MENU_FLIGHT_TIMER = "%1 Vliegtimer",
  MENU_ANT_TRAILS = "%1 Ant Trails",
  MENU_WAYPOINT_ARROW = "%1 Wegwijzer Pijl",
  MENU_MAP_BUTTON = "%1 Map Knop",
  MENU_ZONE_FILTER = "%1 Zone Filter",
  MENU_DONE_FILTER = "%1 Afgerond Filter",
  MENU_BLOCKED_FILTER = "%1 Geblokkeerd Filter",
  MENU_WATCHED_FILTER = "%1 Volg filter",
  MENU_LEVEL_FILTER = "%1 Level Filter",
  MENU_LEVEL_OFFSET = "Level Filter Afstand",
  MENU_ICON_SCALE = "Icoon Grootte",
  MENU_FILTERS = "Filters",
  MENU_PERFORMANCE = "Werkdruk van Route",
  MENU_LOCALE = "Taal",
  MENU_PARTY = "Groep",
  MENU_PARTY_SHARE = "%1 Doel Deling",
  MENU_PARTY_SOLO = "%1 Negeer Groep",
  MENU_HELP = "Help",
  MENU_HELP_SLASH = "Slash Commando's",
  MENU_HELP_CHANGES = "Veranderingen Logboek",
  MENU_HELP_SUBMIT = "Data versturen",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Bekeken door QuestHelper",
  TOOLTIP_QUEST = "Voor Quest %h1.",
  TOOLTIP_PURCHASE = "Koop %h1.",
  TOOLTIP_SLAY = "Dood voor %h1.",
  TOOLTIP_LOOT = "Loot voor %h1."
 }

