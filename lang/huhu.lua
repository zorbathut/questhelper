-- Please see enus.lua for reference.

QuestHelper_Translations.huHU =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Magyar",
  
  -- Messages used when starting.
  LOCALE_ERROR = "A mentett adatok nyelve nem egyezik meg a WoW-kliensed nyelvével. Ahhoz, hogy használd a QuestHelpert vagy vissza kell állítsd a kliensed nyelvét, vagy törölnöd kell a mentett adatokat azzal, hogy beírod: %h(/qh purge).",
  ZONE_LAYOUT_ERROR = "Sajnálom, de meg kelell tagadnom működésem, az eddig felhalmozott adatok védelméért. Kérlek várj, míg kijön egy frissítés, ami képes lesz kezelni az új terület kialakítását.",
  DOWNGRADE_ERROR = "A rögzített adatok nem kompatibilisek a QuestHelper ezen verziójával. Tölts le egy újabb verziót, vagy töröld a mentett adatokat a 'Saved Variables' mappádban.",
  HOME_NOT_KNOWN = "Nem tudom hol van az otthonod. Amikor csak tudsz, beszélj az 'Innkeeper'-eddel, és kérj új HS-t.",
  PRIVATE_SERVER = "A QuestHelper nem támogatja a privát szervereket.",
  PLEASE_RESTART = "Hiba történt a QuestHelper indításakor. Kérlek zárd be teljesen a WoW-ot, és lépj be újra!",
  NOT_UNZIPPED_CORRECTLY = "A QuestHelper hibásan lett telepítve! Kérlek telepítsd újta a hivatalos Curse oldalról, az ottani telepítési-utasításokat követve!",
  PLEASE_DONATE = "%h( A QuestHelper-t jelenleg a Ti Adományaitok tartják életben!) Bármennyit, amit tudtok nélkülözni, szívesen fogadunk, és pár száz forint havonta is segít, hogy működésben, és frissítve tartsam az AddOnt. Több információért írd be: %h(/qh donate)",
  HOW_TO_CONFIGURE = "Még nincs működő Beállítások része ezen QuestHelpernek, de konfigurálhatod, ha beírod: %h(/qh settings). Segítség a %h(/qh help) beírásával érhatő el.",
  TIME_TO_UPDATE = "Valószinűleg létezik egy újabb QuestHelper verzió ( %h )! Újabb verziók újabb funkciókat, quest-adatbázisokat és hibajavításokat tartalmaznak. Kérlek, frissíts!",
  
  -- Route related text.
  ROUTES_CHANGED = "A karaktered repülési útvonalai megváltoztak.",
  HOME_CHANGED = "Az otthonond megváltozott.",
  TALK_TO_FLIGHT_MASTER = "Kérlek beszélj a helyi Griffessel.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Köszönöm.",
  WILL_RESET_PATH = "Útvonalterv újraszerkesztése folyamatban...",
  UPDATING_ROUTE = "Útvonalterv frissítése.",
  
  -- Special tracker text
  QH_LOADING = "QuestHelper betöltése folyamatban... (%1%%)",
  QUESTS_HIDDEN_1 = "Rejtett Questek lehetnek...",
  QUESTS_HIDDEN_2 = "( Használd a \"/qh hidden\" parancsot a felsoroláshoz)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Választható nyelvek:",
  LOCALE_CHANGED = "Beállított nyelv: %h1",
  LOCALE_UNKNOWN = "Ismeretlen nyelv: %h1 .",
  
  -- Words used for objectives.
  SLAY_VERB = "Ölj",
  ACQUIRE_VERB = "Szerezz",
  
  OBJECTIVE_REASON = "%1 %h2-t a(z) %h3 questhez.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1-t a(z) %h2 questhez.",
  OBJECTIVE_REASON_TURNIN = "Add le a(z) %h1 questet.",
  OBJECTIVE_PURCHASE = "Vegyél innen: %h1.",
  OBJECTIVE_TALK = "Beszélj vele: %h1.",
  OBJECTIVE_SLAY = "Ölj %h1-t.",
  OBJECTIVE_LOOT = "Gyűjts %h1-t.",
  
  ZONE_BORDER = "%1 és %2 határa",
  
  -- Stuff used in objective menus.
  PRIORITY = "Elsőbbség",
  PRIORITY1 = "Legmagasabb",
  PRIORITY2 = "Magas",
  PRIORITY3 = "Szokásos",
  PRIORITY4 = "Alacsony",
  PRIORITY5 = "Legalacsonyabb",
  SHARING = "Megosztás Be",
  SHARING_ENABLE = "Megoszt",
  SHARING_DISABLE = "Megosztás Ki",
  IGNORE = "Hagyd figyelmen kívül",
  
  IGNORED_PRIORITY_TITLE = "A választott elsőbbséget figyelmen kívül hagyom.",
  IGNORED_PRIORITY_FIX = "Állíts be elsőbbségeket az akadályozó feladatoknak.",
  IGNORED_PRIORITY_IGNORE = "Magam állítom be az elsőbbségeket.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Keresés Eredménye",
  NO_RESULTS = "Nincs találat!",
  CREATED_OBJ = "%1 készítette",
  REMOVED_OBJ = "%1 törölve",
  USER_OBJ = "Felhasználói Feladat: %h1",
  UNKNOWN_OBJ = "Nemtudom hova kellene menned, hogy teljesítsd ezt a feladatod.",
  INACCESSIBLE_OBJ = "A QuestHelper nem talált használható elhelyezést ennek: %h1. Hozzáadtam egy valószinűleg-lehetetlen-megtalálni pozíciót a feladataidhoz. Ha sikerül megtalálnod az valós helyét, kérlek küld el az adatbázisod: (%h(/qh submit))",
  
  SEARCHING_STATE = "Keresés folyamatban a(z) %1 közt...",
  SEARCHING_LOCAL = "Helyi %1",
  SEARCHING_STATIC = "Fő Adatbankbeli %1",
  SEARCHING_ITEMS = "Tárgyak",
  SEARCHING_NPCS = "NPCk",
  SEARCHING_ZONES = "Területek",
  SEARCHING_DONE = "Kész a keresés!",
  
  -- Shared objectives.
  PEER_TURNIN = "Várd meg míg %h1 leadja a(z) %h2 questet.",
  PEER_LOCATION = "Segítsd %1-t, hogy elérjen egy helyet itt: %h2",
  PEER_ITEM = "Sagítsd %1-t, hogy szerezzen %h2-t.",
  PEER_OTHER = "Segítsd %1-t a(z)%h2 questben.",
  
  PEER_NEWER = "%h1 újabb verzióját használja a QuestHelpernek. Itt az ideje újítani.",
  PEER_OLDER = "%h1 régebbi verzióját használja a QuestHelpernek.",
  
  UNKNOWN_MESSAGE = "ismeretlen adatfajta: '%1', tőle: '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Rejtett feladatok",
  HIDDEN_NONE = "Nincsenek elrejtett feladatok.",
  DEPENDS_ON_SINGLE = "Ettől függ: '%1'.",
  DEPENDS_ON_COUNT = "%1 rejtett objektumtól függ.",
  FILTERED_LEVEL = "Rejtve a szintkülönbség miatt.",
  FILTERED_ZONE = "Rejtve, mivel másik területen található.",
  FILTERED_COMPLETE = "Rejtve, mivel kész.",
  FILTERED_BLOCKED = "Rejtve inkompatibilis elsődleges feladat miatt.",
  FILTERED_UNWATCHED = "Szűrve, mert nincs benne a Quest Log-odban!",
  FILTERED_USER = "Te rejtetted el ezt a feladatot.",
  FILTERED_UNKNOWN = "Nem tudom, hogyan kell megcsinálni.",
  
  HIDDEN_SHOW = "Mutasd.",
  DISABLE_FILTER = "%1-szűrő kikapcsolása.",
  FILTER_DONE = "kész",
  FILTER_ZONE = "terület",
  FILTER_LEVEL = "szint",
  FILTER_BLOCKED = "blokkolt",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "%h(Új információd) van %h1, és %h(frissített adatod) %h2.",
  NAG_SINGLE_NEW = "%h(Új információd) van %h1.",
  NAG_ADDITIONAL = "%h(További információt) gyűjtöttél erről: %h1",
  NAG_POLLUTED = "Az adatbázisod szennyezett Tört Szerverről ( vagy teszt szerverről ) származó információval, a következő indításkor megtisztja önmagát.",
  
  NAG_NOT_NEW = "Eddig még nem gyűjtöttél semmilyen olyan adatot ami ne lenne benne a Fő Adatbankban.",
  NAG_NEW = "Megoszthatod az eddig rögzített adataidat, hogy mások hasznára is lehessen.",
  NAG_INSTRUCTIONS = "Használd a %h(/qh submit) paracsot, hogy megtudd, hogyan küldd el a rögzített adatjaidat.",
  
  NAG_SINGLE_FP = "egy 'Griffesről'",
  NAG_SINGLE_QUEST = "egy questről",
  NAG_SINGLE_ROUTE = "egy repülési útvonalról",
  NAG_SINGLE_ITEM_OBJ = "egy cikk-feladatról",
  NAG_SINGLE_OBJECT_OBJ = "egy tárgy-feladatról",
  NAG_SINGLE_MONSTER_OBJ = "egy mob-feladatról",
  NAG_SINGLE_EVENT_OBJ = "egy esemény-feladatról",
  NAG_SINGLE_REPUTATION_OBJ = "egy reputáció-feladatról",
  NAG_SINGLE_PLAYER_OBJ = "egy játékos feladatról",
  
  NAG_MULTIPLE_FP = "%1 'Griffesről'",
  NAG_MULTIPLE_QUEST = "%1 questről",
  NAG_MULTIPLE_ROUTE = "%1 repülési útvonalról",
  NAG_MULTIPLE_ITEM_OBJ = "%1 cikk-feladatról",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 tárgy-feladatról",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 mob-feladatról",
  NAG_MULTIPLE_EVENT_OBJ = "%1 esemény-feladatról",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 reputáció-feladatról",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 játékos feladatról",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 így halad:",
  TRAVEL_ESTIMATE = "Előrelátható utazási idő:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Érintsd %h1-t, hogy elérd:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper (by 123.wizek@gmail.com)",
  QH_BUTTON_TOOLTIP1 = "Bal Klikk: Útvonalterv %1.",
  QH_BUTTON_TOOLTIP2 = "Jobb Klikk: Beállítások-menü megjelenítése.",
  QH_BUTTON_SHOW = "Mutat",
  QH_BUTTON_HIDE = "Elrejt",

  MENU_CLOSE = "%h(Menü Bezárása)",
  MENU_SETTINGS = "Beállítások",
  MENU_ENABLE = "Bekapcsolás",
  MENU_DISABLE = "Kikapcsolás",
  MENU_OBJECTIVE_TIPS = "%1 a Feladat-Szövegbuborékokat",
  MENU_TRACKER_OPTIONS = "Quest-Figyelő",
  MENU_QUEST_TRACKER = "%1 a Quest-Figyelőt",
  MENU_TRACKER_LEVEL = "%1 a Questek szintjeinek mutatását",
  MENU_TRACKER_QCOLOUR = "%1 a szinezést Nehézség szerint",
  MENU_TRACKER_OCOLOUR = "%1 a szinezést Állapot szerint",
  MENU_TRACKER_SCALE = "Figyelő méretezése",
  MENU_TRACKER_RESET = "Elhelyezésének Visszaállítása",
  MENU_FLIGHT_TIMER = "%1 a Repülés Stoppert",
  MENU_ANT_TRAILS = "%1 a Mozgó Pöttyöket",
  MENU_WAYPOINT_ARROW = "%1 az Útvonalterv-Nyilat",
  MENU_MAP_BUTTON = "%1 a Térkép-Gombot",
  MENU_ZONE_FILTER = "%1 a Terület-Szűrőt",
  MENU_DONE_FILTER = "%1 a Kész-Szűrőt",
  MENU_BLOCKED_FILTER = "%1 a Blokkolt-Szűrőt",
  MENU_WATCHED_FILTER = "%1 Figyelő-Szűrőt",
  MENU_LEVEL_FILTER = "%1 a Szint-Szűrőt",
  MENU_LEVEL_OFFSET = "Szint-Szűrő Eltolása:",
  MENU_ICON_SCALE = "Ikonok Méretezése:",
  MENU_FILTERS = "Szűrők",
  MENU_PERFORMANCE = "Számítások Gyakorisága",
  MENU_LOCALE = "Nyelv",
  MENU_PARTY = "Party",
  MENU_PARTY_SHARE = "%1 a Feladatok Megosztását",
  MENU_PARTY_SOLO = "%1 a Party figyelmen kívül hagyását",
  MENU_HELP = "Segítség",
  MENU_HELP_SLASH = "Per-Parancsok ( / )",
  MENU_HELP_CHANGES = "Változáslista",
  MENU_HELP_SUBMIT = "Rögzített Adatok Elküldése",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "QuestHelper által figyelt",
  TOOLTIP_QUEST = "A(z) %h1 questhez.",
  TOOLTIP_PURCHASE = "Végy %h1-t.",
  TOOLTIP_SLAY = "Ölj ehhez: %h1.",
  TOOLTIP_LOOT = "Lootolj %h1-t."
 }

