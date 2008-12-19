-- Please see lang_enus.lua for reference.

QuestHelper_Translations.koKR =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "한국어",
  
  -- Messages used when starting.
  LOCALE_ERROR = "저장된 데이터의 로케일이 Wow 클라이언트의 로케일과 맞지 않습니다.",
  ZONE_LAYOUT_ERROR = "세이브된 데이터와 충돌의 위험이 있기 때문에 애드온을 실행하지 않습니다. 새로운 지역을 처리 할 수 있는 패치가 나올때까지 기다려주세요.",
  DOWNGRADE_ERROR = "저장된 데이터는 이 버전의 QuestHelper와 맞지 않습니다. 새로운 버전을 사용하거나, 저장된 데이터를 삭제하세요.",
  HOME_NOT_KNOWN = "귀환 장소를 알 수 없습니다. 기회가 될 때, 여관주인에게 말을 걸어 재설정 하세요..",
  PRIVATE_SERVER = nil,
  PLEASE_RESTART = nil,
  NOT_UNZIPPED_CORRECTLY = nil,
  PLEASE_DONATE = nil,
  
  -- Route related text.
  ROUTES_CHANGED = "당신의 이동 경로가 변경되었습니다.",
  HOME_CHANGED = "귀환 장소가 변경되었습니다.",
  TALK_TO_FLIGHT_MASTER = "이 지역의 비행 조련사에게 이야기 하세요.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "완료",
  WILL_RESET_PATH = "이동 정보가 재설정 됩니다.",
  UPDATING_ROUTE = nil,
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "이용 가능한 로케일 :",
  LOCALE_CHANGED = "로케일이 변경되었음 : %h1",
  LOCALE_UNKNOWN = "%h1 로케일을 찾을 수 없음.",
  
  -- Words used for objectives.
  SLAY_VERB = "죽여라",
  ACQUIRE_VERB = "획득하라",
  
  OBJECTIVE_REASON = "%h3 퀘스트 : %h2 %1", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h2 퀘스트 : %h1.",
  OBJECTIVE_REASON_TURNIN = "퀘스트 %h1.",
  OBJECTIVE_PURCHASE = "%h1으로부터 구입하라.",
  OBJECTIVE_TALK = "%h1에게 말하라.",
  OBJECTIVE_SLAY = "%h1을 죽여라.",
  OBJECTIVE_LOOT = "%h1을 루팅하라.",
  
  ZONE_BORDER = "%1/%2 지역",
  
  -- Stuff used in objective menus.
  PRIORITY = "중요도",
  PRIORITY1 = "매우 높음",
  PRIORITY2 = "높음",
  PRIORITY3 = "보통",
  PRIORITY4 = "낮음",
  PRIORITY5 = "매우 낮음",
  SHARING = "공유",
  SHARING_ENABLE = nil,
  SHARING_DISABLE = nil,
  IGNORE = "무시",
  
  IGNORED_PRIORITY_TITLE = "선택된 중요도는 무시됩니다.",
  IGNORED_PRIORITY_FIX = "목적들을 막기위해 같은 중요도를 적용하세요.",
  IGNORED_PRIORITY_IGNORE = "프로퍼티들을 재설정 합니다.",
  
  -- Custom objectives.
  RESULTS_TITLE = "검색 결과",
  NO_RESULTS = "결과를 찾을 수 없습니다.",
  CREATED_OBJ = "생성 : %1",
  REMOVED_OBJ = "삭제 : %1",
  USER_OBJ = "유저 목적 : %h1",
  UNKNOWN_OBJ = "목적 달성을 위해 어디로 가야하는지 알 수가 없습니다.",
  INACCESSIBLE_OBJ = nil,
  
  SEARCHING_STATE = "검색 : %1",
  SEARCHING_LOCAL = "%1 구역",
  SEARCHING_STATIC = "%1 전역",
  SEARCHING_ITEMS = "아이템",
  SEARCHING_NPCS = "NPC들",
  SEARCHING_ZONES = "지역",
  SEARCHING_DONE = "완료!",
  
  -- Shared objectives.
  PEER_TURNIN = "%h2로 진행하기 위해 %h1을 기다리세요.",
  PEER_LOCATION = "%h1을 도와 %h2 지역으로 이동하라.",
  PEER_ITEM = "%1을 도와 %h2를 획득하라.",
  PEER_OTHER = "%h2와 같이 %1을 도와라.",
  
  PEER_NEWER = "%h1은 새로운 버전의 프로토콜을 이용하였습니다. 업그레이드가 필요할 지도 모릅니다.",
  PEER_OLDER = "%h1은 구버전의 프로토콜을 이용하였습니다.",
  
  UNKNOWN_MESSAGE = "'%2'로 부터 받은 '%1'은 알 수 없는 메세지 타입.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "감춘 목적",
  HIDDEN_NONE = "감춘 목적이 존재하지 않습니다.",
  DEPENDS_ON_SINGLE = "'%1'에 의존함.",
  DEPENDS_ON_COUNT = "%1은 감춘 목적에 의존함.",
  FILTERED_LEVEL = "레벨에 따른 분류.",
  FILTERED_ZONE = "지역에 따른 분류.",
  FILTERED_COMPLETE = "완료 상태에 따른 분류.",
  FILTERED_BLOCKED = nil,
  FILTERED_UNWATCHED = nil,
  FILTERED_USER = "이 목적을 감추길 요청하였음.",
  FILTERED_UNKNOWN = "완료 방법을 알 수 없음.",
  
  HIDDEN_SHOW = "보기.",
  DISABLE_FILTER = "필터 비활성화 : %1",
  FILTER_DONE = "완료",
  FILTER_ZONE = "지역",
  FILTER_LEVEL = "레벨",
  FILTER_BLOCKED = nil,
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "%h1과 %h2의 정보 그리고, %h(%s3)지역의 정보를 갱신하였습니다.",
  NAG_SINGLE_NEW = "%h1의 새로운 정보를 얻었습니다.",
  NAG_ADDITIONAL = "%h1의 추가 정보를 얻었습니다.",
  NAG_POLLUTED = nil,
  
  NAG_NOT_NEW = "당신의 전역 데이터베이스에 어떠한 정보도 가지고 있지 않습니다.",
  NAG_NEW = "다른 사람들에게 도움이 될 지도 모르니 당신의 데이터 공유를 고려해 보십시오.",
  NAG_INSTRUCTIONS = nil,
  
  NAG_SINGLE_FP = nil,
  NAG_SINGLE_QUEST = nil,
  NAG_SINGLE_ROUTE = nil,
  NAG_SINGLE_ITEM_OBJ = nil,
  NAG_SINGLE_OBJECT_OBJ = nil,
  NAG_SINGLE_MONSTER_OBJ = nil,
  NAG_SINGLE_EVENT_OBJ = nil,
  NAG_SINGLE_REPUTATION_OBJ = nil,
  NAG_SINGLE_PLAYER_OBJ = nil,
  
  NAG_MULTIPLE_FP = nil,
  NAG_MULTIPLE_QUEST = nil,
  NAG_MULTIPLE_ROUTE = nil,
  NAG_MULTIPLE_ITEM_OBJ = nil,
  NAG_MULTIPLE_OBJECT_OBJ = nil,
  NAG_MULTIPLE_MONSTER_OBJ = nil,
  NAG_MULTIPLE_EVENT_OBJ = nil,
  NAG_MULTIPLE_REPUTATION_OBJ = nil,
  NAG_MULTIPLE_PLAYER_OBJ = nil,
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1의 진행상황 :",
  TRAVEL_ESTIMATE = "계산된 여행 시간 :",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "이곳을 통하여 %h1을 방문하라 :",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = nil,
  QH_BUTTON_TOOLTIP1 = nil,
  QH_BUTTON_TOOLTIP2 = nil,
  QH_BUTTON_SHOW = nil,
  QH_BUTTON_HIDE = nil,

  MENU_CLOSE = nil,
  MENU_SETTINGS = nil,
  MENU_ENABLE = nil,
  MENU_DISABLE = nil,
  MENU_OBJECTIVE_TIPS = nil,
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
  MENU_MAP_BUTTON = nil,
  MENU_ZONE_FILTER = nil,
  MENU_DONE_FILTER = nil,
  MENU_BLOCKED_FILTER = nil,
  MENU_WATCHED_FILTER = nil,
  MENU_LEVEL_FILTER = nil,
  MENU_LEVEL_OFFSET = nil,
  MENU_ICON_SCALE = nil,
  MENU_FILTERS = nil,
  MENU_PERFORMANCE = nil,
  MENU_LOCALE = nil,
  MENU_PARTY = nil,
  MENU_PARTY_SHARE = nil,
  MENU_PARTY_SOLO = nil,
  MENU_HELP = nil,
  MENU_HELP_SLASH = nil,
  MENU_HELP_CHANGES = nil,
  MENU_HELP_SUBMIT = nil,
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = nil,
  TOOLTIP_QUEST = nil,
  TOOLTIP_PURCHASE = nil,
  TOOLTIP_SLAY = nil,
  TOOLTIP_LOOT = nil
 }

