-- Please see lang_enus.lua for reference.

QuestHelper_Translations["zhTW"] =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "繁體中文",
  
  -- Messages used when starting.
  LOCALE_ERROR = nil,
  ZONE_LAYOUT_ERROR = nil,
  DOWNGRADE_ERROR = "存檔資料與目前的版本不合，請更新版本，或是將原有的記錄檔刪除！",
  HOME_NOT_KNOWN = nil,
  
  -- Route related text.
  ROUTES_CHANGED = nil,
  HOME_CHANGED = "爐石地點已變更",
  TALK_TO_FLIGHT_MASTER = "與飛行管理員交談",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "謝謝！",
  WILL_RESET_PATH = "將重設路線訊息",
  UPDATING_ROUTE = "更新路線",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "可選擇語系",
  LOCALE_CHANGED = "變更使用語系為： %h1",
  LOCALE_UNKNOWN = "%h1 是個未知的語系",
  
  -- Words used for objectives.
  SLAY_VERB = "殺死",
  ACQUIRE_VERB = "需要",
  
  OBJECTIVE_REASON = nil, -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = nil,
  OBJECTIVE_REASON_TURNIN = nil,
  OBJECTIVE_PURCHASE = nil,
  OBJECTIVE_TALK = "與 %1 交談",
  OBJECTIVE_SLAY = "殺死 %h1",
  OBJECTIVE_LOOT = "拾取 %h1",
  
  ZONE_BORDER = nil,
  
  -- Stuff used in objective menus.
  PRIORITY = "優先度",
  PRIORITY1 = "最高",
  PRIORITY2 = "高",
  PRIORITY3 = "一般",
  PRIORITY4 = "低",
  PRIORITY5 = "最低",
  SHARING = "分享中！",
  SHARING_ENABLE = "分享",
  SHARING_DISABLE = "不分享",
  IGNORE = "忽略",
  
  IGNORED_PRIORITY_TITLE = nil,
  IGNORED_PRIORITY_FIX = nil,
  IGNORED_PRIORITY_IGNORE = "自訂優先度",
  
  -- Custom objectives.
  RESULTS_TITLE = "搜尋結果",
  NO_RESULTS = nil,
  CREATED_OBJ = "製造了 %1",
  REMOVED_OBJ = "移除： %1",
  USER_OBJ = nil,
  UNKNOWN_OBJ = nil,
  
  SEARCHING_STATE = "搜尋中： %1",
  SEARCHING_LOCAL = nil,
  SEARCHING_STATIC = "狀態 %1",
  SEARCHING_ITEMS = "物品",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "地區",
  SEARCHING_DONE = "完成！",
  
  -- Shared objectives.
  PEER_TURNIN = nil,
  PEER_LOCATION = nil,
  PEER_ITEM = nil,
  PEER_OTHER = nil,
  
  PEER_NEWER = nil,
  PEER_OLDER = nil,
  
  UNKNOWN_MESSAGE = nil,
  
  -- Hidden objectives.
  HIDDEN_TITLE = "隱藏的目標",
  HIDDEN_NONE = nil,
  DEPENDS_ON_SINGLE = nil,
  DEPENDS_ON_COUNT = nil,
  FILTERED_LEVEL = nil,
  FILTERED_ZONE = nil,
  FILTERED_COMPLETE = nil,
  FILTERED_BLOCKED = nil,
  FILTERED_USER = nil,
  FILTERED_UNKNOWN = "不知道如何完成任務",
  
  HIDDEN_SHOW = "顯示",
  DISABLE_FILTER = nil,
  FILTER_DONE = "完成",
  FILTER_ZONE = "地區",
  FILTER_LEVEL = "等級",
  FILTER_BLOCKED = nil,
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = nil,
  NAG_SINGLE_NEW = nil,
  NAG_ADDITIONAL = nil,
  
  NAG_NOT_NEW = nil,
  NAG_NEW = nil,
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
  PEER_PROGRESS = "%1 目前的進度",
  TRAVEL_ESTIMATE = "剩餘時間：",
  TRAVEL_ESTIMATE_VALUE = nil,
  WAYPOINT_REASON = nil,

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = nil,
  QH_BUTTON_TOOLTIP1 = "左鍵： %1 路線訊息",
  QH_BUTTON_TOOLTIP2 = "右鍵： 顯示設定選單",
  QH_BUTTON_SHOW = "顯示",
  QH_BUTTON_HIDE = "隱藏",

  MENU_CLOSE = "關閉選單",
  MENU_SETTINGS = "設定",
  MENU_ENABLE = "啟用",
  MENU_DISABLE = "停用",
  MENU_OBJECTIVE_TIPS = "%1 任務目標提示",
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
  MENU_MAP_BUTTON = "%1 地圖按鈕",
  MENU_ZONE_FILTER = nil,
  MENU_DONE_FILTER = nil,
  MENU_BLOCKED_FILTER = nil,
  MENU_LEVEL_FILTER = nil,
  MENU_LEVEL_OFFSET = nil,
  MENU_ICON_SCALE = "圖示尺寸",
  MENU_FILTERS = nil,
  MENU_PERFORMANCE = nil,
  MENU_LOCALE = "語系",
  MENU_PARTY = "小隊",
  MENU_PARTY_SHARE = "分享 %1 任務",
  MENU_PARTY_SOLO = nil,
  MENU_HELP = "幫助",
  MENU_HELP_SLASH = nil,
  MENU_HELP_CHANGES = "變更記錄檔",
  MENU_HELP_SUBMIT = "送出資料",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = nil,
  TOOLTIP_QUEST = nil,
  TOOLTIP_PURCHASE = nil,
  TOOLTIP_SLAY = nil,
  TOOLTIP_LOOT = nil
 }

