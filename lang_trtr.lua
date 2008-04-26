-- Please see lang_enus.lua for reference.

QuestHelper_Translations.trTR =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Türkçe",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Kayıtlı verilerinizin dili WoW dilinizle aynı değil.",
  ZONE_LAYOUT_ERROR = "Kaydedilmiş verilerinize hasar vermekten korkmaksızın çalışmayı reddediyorum. "..
                      "Lütfen yeni bölgeyi kontrol edebilecek bir güncelleme çıkana kadar bekleyin.",
  DOWNGRADE_ERROR = "Kayıtlı verileriniz QuestHelper'ın bu versiyonuyla uyumlu değil "..
                    "Yeni bir versiyon indirin veya kayıtlı verilerinizi silin.",
  HOME_NOT_KNOWN = "Belirli bir konaklama yeriniz yok, fırsat bulduğunuzda barmen ile konuşarak bir yer belirleyin.",
  
  -- This text is only printed for the enUS client, don't worry about translating it.
  ALTERED_INDEX = "!!! QuestHelper_IndexLookup entry needs update: [%Q1] = {%2, %3, %4}",
  ALTERED_ZONE = "!!! QuestHelper_Zones entry needs update: [%1][%2] = %Q3 -- was %4",
  
  -- Route related text.
  ROUTES_CHANGED = "Uçuş noktalarınıza bakılarak eklenti veritabanı güncellendi.",
  HOME_CHANGED = "Konaklama yeriniz değişti.",
  TALK_TO_FLIGHT_MASTER = "Bölgenizdeki uçuş kaptanı ile görüşün.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Teşekkürler.",
  WILL_RESET_PATH = "Rota bilgileri sıfırlandı.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Kullanılabilir diller:",
  LOCALE_CHANGED = "Dil %h1 olarak değiştirildi.",
  LOCALE_UNKNOWN = "%h1 dili bilinmiyor.",
  
  -- Words used for objectives.
  SLAY_VERB = "Öldür",
  ACQUIRE_VERB = "topla",
  
  OBJECTIVE_REASON = "%h3 görevi için %h2 %h1.", -- %1 bir fiil, %2 bir isim (cisim veya yaratık)
  OBJECTIVE_REASON_FALLBACK = "%h2 görevi için %h1.",
  OBJECTIVE_REASON_TURNIN = "%h1 görevini tamamla.",
  OBJECTIVE_PURCHASE = "%h1 satın al.",
  OBJECTIVE_TALK = "%h1 ile konuş.",
  OBJECTIVE_SLAY = "%h1 öldür.",
  OBJECTIVE_LOOT = "%h1 loot et.",
  
  ZONE_BORDER = "%1/%2 sınırı",
  
  -- Stuff used in objective menus.
  PRIORITY = "Öncelik",
  PRIORITY1 = "En yüksek",
  PRIORITY2 = "Yüksek",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Düşük",
  PRIORITY5 = "En düşük",
  SHARING = "Paylaşım",
  ENABLE = "Açık",
  DISABLE = "Kapalı",
  IGNORE = "Dikkate alma",
  
  IGNORED_PRIORITY_TITLE = "Seçilmiş öncelik dikkate alınmayacak.",
  IGNORED_PRIORITY_FIX = "Engelleyici işlere ayni önceliği uygula.",
  IGNORED_PRIORITY_IGNORE = "Öncelikleri ben ayarlayacağım",
  
  -- Custom objectives.
  RESULTS_TITLE = "Arama sonuçları",
  NO_RESULTS = "Hiçbir sonuç bulunamadı!",
  CREATED_OBJ = "Oluşturulan: %1",
  REMOVED_OBJ = "Silinen: %1",
  USER_OBJ = "Kullanıcı görevi: %h1",
  UNKNOWN_OBJ = "Bu görev için nereye gitmen gerektiğini bilmiyorum.",
  
  SEARCHING_STATE = "Aranıyor: %1",
  SEARCHING_LOCAL = "Local %1",
  SEARCHING_STATIC = "Statique %1",
  SEARCHING_ITEMS = "Cisimler",
  SEARCHING_NPCS = "NPCler",
  SEARCHING_ZONES = "Bölgeler",
  SEARCHING_DONE = "Tamam!",
  
  -- Shared objectives.
  PEER_TURNIN = "%h1 e %h2 görevini tamamlamasını bekle.",
  PEER_LOCATION = "%h1 e %h2 içindeki bölgeye ulaşmasına yardım et.",
  PEER_ITEM = "%1 e %h2 toplamasına yardım et.",
  PEER_OTHER = "%h2 için %h1 e yardımcı ol.",
  
  PEER_NEWER = "%h1 daha yeni bir versiyon kullanıyor. Güncelleme yapmayı düşünebilirsiniz.",
  PEER_OLDER = "%h1 daha eski bir versiyon kullanıyor",
  
  UNKNOWN_MESSAGE = "'%2' tarafından '%1', bilinmeyen mesaj tarzı.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Gizli görevler",
  HIDDEN_NONE = "Sizden gizlenen görev bulunmamakta.",
  DEPENDS_ON_SINGLE = "'%1' durumuna bağlı.",
  DEPENDS_ON_COUNT = "%1 gizli görevlerin durumuna bağlı.",
  FILTERED_LEVEL = "Seviyeniz nedeniyle filtrelendi.",
  FILTERED_ZONE = "Bölge nedeniyle filtrelendi.",
  FILTERED_COMPLETE = "Tamamlandığı için filtrelendi.",
  FILTERED_USER = "Bu görevin gizlenmesini istediniz.",
  FILTERED_UNKNOWN = "Nasıl bitirileceği bilinmiyor.",
  
  HIDDEN_SHOW = "Göster.",
  DISABLE_FILTER = "Filtrelemeyi kapat: %1",
  FILTER_DONE = "Tamamlandı",
  FILTER_ZONE = "bölge",
  FILTER_LEVEL = "seviye",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_SINGLE = "1 %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %s2",
  
  NAG_MULTIPLE_NEW = "%h1 yeni bilgileriniz ve %h2 güncellemeleriniz var %h(%s3).",
  NAG_SINGLE_NEW = "%h1 için yeni bilgilere sahipsiniz.",
  NAG_ADDITIONAL = "%h1 için daha daha fazla yeni bilgiye sahipsiniz.",
  
  NAG_NOT_NEW = "Veritabanında bulunmayan yeni bir bilgiye sahip değilsiniz.",
  NAG_NEW = "Diğer oyuncuların da faydalanabilmesi için bilgilerinizi paylasabilirsiniz.",
  
  NAG_FP = "Uçuş kaptanı",
  NAG_QUEST = "görev",
  NAG_ROUTE = "uçuş noktası",
  NAG_ITEM_OBJ = "cisim görevi",
  NAG_OBJECT_OBJ = "parça görevi",
  NAG_MONSTER_OBJ = "yaratık görevi",
  NAG_EVENT_OBJ = "olay görevi",
  NAG_REPUTATION_OBJ = "itibar görevi",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 in ilerleyişi:",
  TRAVEL_ESTIMATE = "Kalan tahmini zaman:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Yolda %h1 e uğra:"
 }
