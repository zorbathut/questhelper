-- Please see lang_enus.lua for reference.

QuestHelper_Translations.trTR =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Türkçe",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Kayitli verilerinizin dili WoW dilinizle ayni degil.",
  ZONE_LAYOUT_ERROR = "Kaydedilmis verilerinize hasar vermekten korkmaksizin çalismayi reddediyorum. "..
                      "Lütfen yeni bölgeyi kontrol edebilecek bir güncelleme çikana kadar bekleyin.",
  DOWNGRADE_ERROR = "Kayitli verileriniz QuestHelper'in bu versiyonuyla uyumlu degil "..
                    "Yeni bir versiyon indirin veya kayitli verilerinizi silin.",
  HOME_NOT_KNOWN = "Belirli bir konaklama yeriniz yok, firsat buldugunuzda barmen ile konusarak bir yer belirleyin.",
  
  -- This text is only printed for the enUS client, don't worry about translating it.
  ALTERED_INDEX = "!!! QuestHelper_IndexLookup entry needs update: [%Q1] = {%2, %3, %4}",
  ALTERED_ZONE = "!!! QuestHelper_Zones entry needs update: [%1][%2] = %Q3 -- was %4",
  
  -- Route related text.
  ROUTES_CHANGED = "Uçus noktalariniza bakilarak eklenti veritabani güncellendi.",
  HOME_CHANGED = "Konaklama yeriniz degisti.",
  TALK_TO_FLIGHT_MASTER = "Bölgenizdeki uçus kaptani ile görüsün.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Tesekkürler.",
  WILL_RESET_PATH = "Rota bilgileri sifirlandi.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Kullanilabilir diller:",
  LOCALE_CHANGED = "Dil %h1 olarak degistirildi.",
  LOCALE_UNKNOWN = "%h1 dili bilinmiyor.",
  
  -- Words used for objectives.
  SLAY_VERB = "Öldür",
  ACQUIRE_VERB = "topla",
  
  OBJECTIVE_REASON = "%h3 görevi için %h2 %h1.", -- %1 bir fiil, %2 bir isim (cisim veya yaratik)
  OBJECTIVE_REASON_FALLBACK = "%h2 görevi için %h1.",
  OBJECTIVE_REASON_TURNIN = "%h1 görevini tamamla.",
  OBJECTIVE_PURCHASE = "%h1 satin al.",
  OBJECTIVE_TALK = "%h1 ile konus.",
  OBJECTIVE_SLAY = "%h1 öldür.",
  OBJECTIVE_LOOT = "%h1 loot et.",
  
  ZONE_BORDER = "%1/%2 siniri",
  
  -- Stuff used in objective menus.
  PRIORITY = "Öncelik",
  PRIORITY1 = "En yüksek",
  PRIORITY2 = "Yüksek",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Düsük",
  PRIORITY5 = "En düsük",
  SHARING = "Paylasim",
  ENABLE = "Açik",
  DISABLE = "Kapali",
  IGNORE = "Dikkate alma",
  
  IGNORED_PRIORITY_TITLE = "Seçilmis öncelik dikkate alinmayacak.",
  IGNORED_PRIORITY_FIX = "Engelleyici islere ayni önceligi uygula.",
  IGNORED_PRIORITY_IGNORE = "Öncelikleri ben ayarlayacagim",
  
  -- Custom objectives.
  RESULTS_TITLE = "Arama sonuçlari",
  NO_RESULTS = "Hiçbir sonuç bulunamadi!",
  CREATED_OBJ = "Olusturulan: %1",
  REMOVED_OBJ = "Silinen: %1",
  USER_OBJ = "Kullanici görevi: %h1",
  UNKNOWN_OBJ = "Bu görev için nereye gitmen gerektigini bilmiyorum.",
  
  SEARCHING_STATE = "Araniyor: %1",
  SEARCHING_LOCAL = "Local %1",
  SEARCHING_STATIC = "Statique %1",
  SEARCHING_ITEMS = "Cisimler",
  SEARCHING_NPCS = "NPCler",
  SEARCHING_ZONES = "Bölgeler",
  SEARCHING_DONE = "Tamam!",
  
  -- Shared objectives.
  PEER_TURNIN = "%h1 e %h2 görevini tamamlamasini bekle.",
  PEER_LOCATION = "%h1 e %h2 içindeki bölgeye ulasmasina yardim et.",
  PEER_ITEM = "%1 e %h2 toplamasina yardim et.",
  PEER_OTHER = "%h2 için %h1 e yardimci ol.",
  
  PEER_NEWER = "%h1 daha yeni bir versiyon kullaniyor. Güncelleme yapmayi düsünebilirsiniz.",
  PEER_OLDER = "%h1 daha eski bir versiyon kullaniyor",
  
  UNKNOWN_MESSAGE = "'%2' tarafindan '%1', bilinmeyen mesaj tarzi.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Gizli görevler",
  HIDDEN_NONE = "Sizden gizlenen görev bulunmamakta.",
  DEPENDS_ON_SINGLE = "'%1' durumuna bagli.",
  DEPENDS_ON_COUNT = "%1 gizli görevlerin durumuna bagli.",
  FILTERED_LEVEL = "Seviyeniz nedeniyle filtrelendi.",
  FILTERED_ZONE = "Bölge nedeniyle filtrelendi.",
  FILTERED_COMPLETE = "Tamamlandigi için filtrelendi.",
  FILTERED_USER = "Bu görevin gizlenmesini istediniz.",
  FILTERED_UNKNOWN = "Nasil bitirilecegi bilinmiyor.",
  
  HIDDEN_SHOW = "Göster.",
  DISABLE_FILTER = "Filtrelemeyi kapat: %1",
  FILTER_DONE = "Tamamlandi",
  FILTER_ZONE = "bölge",
  FILTER_LEVEL = "seviye",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_SINGLE = "1 %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %s2",
  
  NAG_MULTIPLE_NEW = "%h1 yeni bilgileriniz ve %h2 güncellemeleriniz var %h(%s3).",
  NAG_SINGLE_NEW = "%h1 için yeni bilgilere sahipsiniz.",
  NAG_ADDITIONAL = "%h1 için daha daha fazla yeni bilgiye sahipsiniz.",
  
  NAG_NOT_NEW = "Veritabaninda bulunmayan yeni bir bilgiye sahip degilsiniz.",
  NAG_NEW = "Diger oyuncularin da faydalanabilmesi için bilgilerinizi paylasabilirsiniz.",
  
  NAG_FP = "Uçus kaptani",
  NAG_QUEST = "görev",
  NAG_ROUTE = "uçus noktasi",
  NAG_ITEM_OBJ = "cisim görevi",
  NAG_OBJECT_OBJ = "parça görevi",
  NAG_MONSTER_OBJ = "yaratik görevi",
  NAG_EVENT_OBJ = "olay görevi",
  NAG_REPUTATION_OBJ = "itibar görevi",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 in ilerleyisi:",
  TRAVEL_ESTIMATE = "Kalan tahmini zaman:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Yolda %h1 e ugra:"
 }
