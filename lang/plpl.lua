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
  PRIVATE_SERVER = "QuestHelper nie obsluguje prywatnych serwerow.",
  PLEASE_RESTART = "Podczas uruchamiania QuestHelpera wystąpił błąd. Proszę całkowicie wyjść z World of Warcraft i spróbować uruchomić go ponownie.",
  NOT_UNZIPPED_CORRECTLY = "QuestHelper został nieprawidłowo zainstalowany. Do instalacji zalecamy stosowanie klienta Curse lub 7zip. Upewnij się, że podkatalogi są wyodrębnione.",
  PLEASE_DONATE = "%h(QuestHelper przetrwa tylko dzieki twoim dotacjom!) Każdy twój wkład jest doceniany, a zaledwie kilka dolarów miesięcznie zapewni, że będę na bieżąco aktualizował i pracował nad AddOnem. Wposz %h(/qh donate) aby uzyskać więcej informacji.",
  HOW_TO_CONFIGURE = "QuestHelper nie ma jeszcze gotowej strony ustawień, ale może być skonfigurowany poprzez komendę %h(/qh ustawienia). Pomoc jest udzielana poprzez %h(/qh pomoc).",
  TIME_TO_UPDATE = nil,
  
  -- Route related text.
  ROUTES_CHANGED = "Zmieniono twoje trasy lotow.",
  HOME_CHANGED = "Twoje miejsce docelowe zostało zmienione.",
  TALK_TO_FLIGHT_MASTER = "Porozmawiaj z lokalnym Flight Masterem.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Dziekuje.",
  WILL_RESET_PATH = nil,
  UPDATING_ROUTE = "Odswiezanie trasy",
  
  -- Special tracker text
  QH_LOADING = "Ładowanie QuestHelper'a (%1%%)...",
  QUESTS_HIDDEN_1 = "Questy mogą być ukryte",
  QUESTS_HIDDEN_2 = "(wpisz \"/qh hidden\" w celu uzyskania listy ukrytych questów)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Dostępne regiony:",
  LOCALE_CHANGED = "Region zmieniony dla: %h1",
  LOCALE_UNKNOWN = "Region %h1 jest nieznany.",
  
  -- Words used for objectives.
  SLAY_VERB = "Zabij",
  ACQUIRE_VERB = "Uzyskać",
  
  OBJECTIVE_REASON = "%1 %h2 do questa %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 do questa %h2.",
  OBJECTIVE_REASON_TURNIN = "Oddaj questa %h1.",
  OBJECTIVE_PURCHASE = "Kup od %h1",
  OBJECTIVE_TALK = "Porozmawiaj z %h1.",
  OBJECTIVE_SLAY = "Zabij %h1",
  OBJECTIVE_LOOT = nil,
  
  ZONE_BORDER = nil,
  
  -- Stuff used in objective menus.
  PRIORITY = "Priorytet",
  PRIORITY1 = "Najwyzszy",
  PRIORITY2 = "Wysoki",
  PRIORITY3 = "Normalny",
  PRIORITY4 = "Niski",
  PRIORITY5 = "Najnizszy",
  SHARING = "Udostepniane",
  SHARING_ENABLE = "Udostepnij",
  SHARING_DISABLE = "Nie udostepniaj",
  IGNORE = "Zignoruj",
  
  IGNORED_PRIORITY_TITLE = "Zaznaczony priorytet będzie ignorowany.",
  IGNORED_PRIORITY_FIX = "zaakceptuj ten sam priorytet do blokowanych obiektów",
  IGNORED_PRIORITY_IGNORE = "Sam ustwię priorytet.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Wyniki wyszukiwania",
  NO_RESULTS = nil,
  CREATED_OBJ = "Utworzono: %1",
  REMOVED_OBJ = "Usunieto: %1",
  USER_OBJ = "Cel użytkownika: %h1",
  UNKNOWN_OBJ = "Nie wiem gdzie masz isc, aby osiagnac cel.",
  INACCESSIBLE_OBJ = "QuestHelper nie był w stanie znaleźć lokacji dla %h1. Zostało to dodane do listy lokalizacji niemożliwych do odnalezienia. Jeśli znajdziesz użyteczną wesję tego obiektu, proszę o przesłanie danych.",
  
  SEARCHING_STATE = "Wyszukiwanie: %1",
  SEARCHING_LOCAL = "Lokalne %1",
  SEARCHING_STATIC = "Statyczne %1",
  SEARCHING_ITEMS = "Przedmioty",
  SEARCHING_NPCS = "NPC",
  SEARCHING_ZONES = "Strefy",
  SEARCHING_DONE = "Gotowe!",
  
  -- Shared objectives.
  PEER_TURNIN = "Poczekaj na %h1 aby oddac %h2",
  PEER_LOCATION = "Pomoz %h1 dotrzec do %h2.",
  PEER_ITEM = "Pomoz %1 zdobyc %h2.",
  PEER_OTHER = "Pomóż %1 z %h2",
  
  PEER_NEWER = "%h1 używa nowszej wersji protokołu. Być może czas na uaktualnienie.",
  PEER_OLDER = "%h1 używa starszej wersji protokołu.",
  
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
  NAG_MULTIPLE_NEW = "Masz %h(nowa informacje) w %h1, i %h(zaktualizowana informacje) w %h2.",
  NAG_SINGLE_NEW = "Masz %h(nowa informacje) w %h1.",
  NAG_ADDITIONAL = "Masz %h(dodatkowych informacji) na %h1.",
  NAG_POLLUTED = nil,
  
  NAG_NOT_NEW = nil,
  NAG_NEW = nil,
  NAG_INSTRUCTIONS = nil,
  
  NAG_SINGLE_FP = "Flight Master",
  NAG_SINGLE_QUEST = "Quest",
  NAG_SINGLE_ROUTE = nil,
  NAG_SINGLE_ITEM_OBJ = "cel - przedmiot",
  NAG_SINGLE_OBJECT_OBJ = nil,
  NAG_SINGLE_MONSTER_OBJ = "cel- potwor",
  NAG_SINGLE_EVENT_OBJ = nil,
  NAG_SINGLE_REPUTATION_OBJ = nil,
  NAG_SINGLE_PLAYER_OBJ = "Cel gracza",
  
  NAG_MULTIPLE_FP = "%1 Flight Masterzy",
  NAG_MULTIPLE_QUEST = "%1 Questy",
  NAG_MULTIPLE_ROUTE = "%1 trasy lotu",
  NAG_MULTIPLE_ITEM_OBJ = nil,
  NAG_MULTIPLE_OBJECT_OBJ = nil,
  NAG_MULTIPLE_MONSTER_OBJ = nil,
  NAG_MULTIPLE_EVENT_OBJ = nil,
  NAG_MULTIPLE_REPUTATION_OBJ = nil,
  NAG_MULTIPLE_PLAYER_OBJ = "%1 Cele gracza",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = nil,
  TRAVEL_ESTIMATE = "Pozostaly czas podrozy:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = nil,

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = nil,
  QH_BUTTON_TOOLTIP2 = "PKlik: Pokaż menu ustawień.",
  QH_BUTTON_SHOW = "Pokaz",
  QH_BUTTON_HIDE = "Ukryj",

  MENU_CLOSE = "Zamknij menu",
  MENU_SETTINGS = "Ustawienia",
  MENU_ENABLE = "Włączenie",
  MENU_DISABLE = "Wyłączenie",
  MENU_OBJECTIVE_TIPS = "Menu zadań",
  MENU_TRACKER_OPTIONS = "zaznaczenie zadań",
  MENU_QUEST_TRACKER = "Zaznaczanie zadań",
  MENU_TRACKER_LEVEL = "%1 Poziom Questów",
  MENU_TRACKER_QCOLOUR = "kolor poziomu questów",
  MENU_TRACKER_OCOLOUR = "kolor zadań",
  MENU_TRACKER_SCALE = "rozmiar szukania",
  MENU_TRACKER_RESET = "Zresetuj pozycje",
  MENU_FLIGHT_TIMER = "%1 Czas lotu",
  MENU_ANT_TRAILS = "%1 \"Szlak Mrówek\"",
  MENU_WAYPOINT_ARROW = nil,
  MENU_MAP_BUTTON = "%1 Przycisk Mapy",
  MENU_ZONE_FILTER = "% filtr strefy",
  MENU_DONE_FILTER = "%1 Zrobione filtry",
  MENU_BLOCKED_FILTER = "%1 Zablokowane filtry",
  MENU_WATCHED_FILTER = "%1 Obserwowane filtry",
  MENU_LEVEL_FILTER = "%1 Filtr Poziomu",
  MENU_LEVEL_OFFSET = "Przesuniecie filtru poziomu",
  MENU_ICON_SCALE = "Skala Ikon",
  MENU_FILTERS = "Filtry",
  MENU_PERFORMANCE = nil,
  MENU_LOCALE = "Lokalizacja",
  MENU_PARTY = "Party",
  MENU_PARTY_SHARE = "%1 Udostepnianie celu",
  MENU_PARTY_SOLO = "%1 Ignoruj Party",
  MENU_HELP = "Pomoc",
  MENU_HELP_SLASH = "Komendy",
  MENU_HELP_CHANGES = "Lista zmian",
  MENU_HELP_SUBMIT = "Wysyłanie danych",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Obserwowany przez QuestHelper",
  TOOLTIP_QUEST = "Do Questa %h1",
  TOOLTIP_PURCHASE = "Kup %h1",
  TOOLTIP_SLAY = "Zabij do %h1",
  TOOLTIP_LOOT = nil
 }

