-- Please see enus.lua for reference.

QuestHelper_Translations.koKR =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "한국어",
  
  -- Messages used when starting.
  LOCALE_ERROR = "저장된 데이터의 로케일이 WoW 클라이언트의 로케일과 맞지 않습니다. 퀘스트헬퍼를 사용하려면 로케일을 되돌리거나 %h(/qh purge)를 입력하여 데이터를 지울 필요가 있습니다.",
  ZONE_LAYOUT_ERROR = "저장된 데이터와 충돌의 위험이 있기 때문에 애드온을 실행하지 않습니다. 새로운 지역을 처리할 수 있는 패치가 나올 때까지 기다려 주세요.",
  DOWNGRADE_ERROR = "저장된 데이터가 이번 버전 퀘스트헬퍼와 맞지 않습니다. 새로운 버전을 사용하거나, 저장된 데이터를 삭제하세요.",
  HOME_NOT_KNOWN = "귀환 장소를 알 수 없습니다. 기회가 될 때, 여관주인에게 말을 걸어 재설정하세요.",
  PRIVATE_SERVER = "퀘스트헬퍼는 해적서버를 지원하지 않습니다.",
  PLEASE_RESTART = "퀘스트헬퍼를 시작하지 못했습니다. 월드 오브 워크래프트를 완전히 종료하고 다시 시도하세요.",
  NOT_UNZIPPED_CORRECTLY = "퀘스트헬퍼가 제대로 설치되지 않았습니다. Curse 클라이언트나 7zip을 이용한 설치를 권장합니다. 하위 폴더가 설치되었는지 확인하세요.",
  PLEASE_DONATE = "%h 퀘스트헬퍼는 여러분의 기부에 의해 운영되고 있습니다! 한달에 몇 달러만 기부해 주시면 저는 업데이트를 계속하겠습니다. 더 많은 정보를 원하시면 %h(/qh donate)를 입력하세요.",
  HOW_TO_CONFIGURE = "퀘스트헬퍼는 아직 설정 페이지가 없지만, %h(/qh settings)를 입력창에 입력하여 설정할 수 있습니다. 도움말은 %h(/qh help)를 입력하세요.",
  TIME_TO_UPDATE = "새로운 %h 버전이 업데이트 되었습니다. 새 버전에서는 보통 새로운 모습, 추가된 퀘스트 그리고 버그가 수정됩니다. 업데이트 하세요!",
  
  -- Route related text.
  ROUTES_CHANGED = "당신의 비행 경로가 변경되었습니다.",
  HOME_CHANGED = "귀환 장소가 변경되었습니다.",
  TALK_TO_FLIGHT_MASTER = "이 지역의 비행 조련사에게 이야기 하세요.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "완료",
  WILL_RESET_PATH = "이동 정보가 재설정 됩니다.",
  UPDATING_ROUTE = "경로 재설정",
  
  -- Special tracker text
  QH_LOADING = "퀘스트헬퍼 로딩 중 (%1%%)...",
  QUESTS_HIDDEN_1 = "퀘스트를 숨겼을 지도 모릅니다",
  QUESTS_HIDDEN_2 = "(목록은 \"/qh hidden\")",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "이용 가능한 로케일:",
  LOCALE_CHANGED = "로케일이 %h1로 변경되었음",
  LOCALE_UNKNOWN = "%h1 로케일을 찾을 수 없음.",
  
  -- Words used for objectives.
  SLAY_VERB = "죽이기",
  ACQUIRE_VERB = "획득",
  
  OBJECTIVE_REASON = "%h3 퀘스트: %h2 %1", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h2 퀘스트: %h1.",
  OBJECTIVE_REASON_TURNIN = "퀘스트 %h1.",
  OBJECTIVE_PURCHASE = "%h1으로부터 구입하라.",
  OBJECTIVE_TALK = "%h1과(와) 이야기하라.",
  OBJECTIVE_SLAY = "%h1을(를) 죽여라.",
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
  SHARING_ENABLE = "공유한다",
  SHARING_DISABLE = "공유하지 않는다",
  IGNORE = "무시",
  
  IGNORED_PRIORITY_TITLE = "선택된 중요도는 무시됩니다.",
  IGNORED_PRIORITY_FIX = "목적들을 막기 위해 같은 중요도를 적용하세요.",
  IGNORED_PRIORITY_IGNORE = "프로퍼티들을 재설정합니다.",
  
  -- Custom objectives.
  RESULTS_TITLE = "검색 결과",
  NO_RESULTS = "결과를 찾을 수 없습니다!",
  CREATED_OBJ = "생성: %1",
  REMOVED_OBJ = "삭제: %1",
  USER_OBJ = "유저 목적: %h1",
  UNKNOWN_OBJ = "목적 달성을 위해 어디로 가야하는지 알 수가 없습니다.",
  INACCESSIBLE_OBJ = "퀘스트헬퍼는 %h1의 위치를 찾지 못했습니다. 우리는 가장 가능성 있는 위치를 목표에 추가했습니다. 만약 이 목표에 대해 정확한 정보를 알고 계시다면 당신의 데이터를 보내주세요! %h(/qh submit))",
  
  SEARCHING_STATE = "검색: %1",
  SEARCHING_LOCAL = "%1 구역",
  SEARCHING_STATIC = "%1 전역",
  SEARCHING_ITEMS = "아이템",
  SEARCHING_NPCS = "NPC",
  SEARCHING_ZONES = "지역",
  SEARCHING_DONE = "완료!",
  
  -- Shared objectives.
  PEER_TURNIN = "%h2로 진행하기 위해 %h1을 기다리세요.",
  PEER_LOCATION = "%h1을 도와 %h2로 이동하라.",
  PEER_ITEM = "%1을 도와 %h2를 획득하라.",
  PEER_OTHER = "%h2와 같이 %1을 도와라.",
  
  PEER_NEWER = "%h1은 새로운 버전의 프로토콜을 이용하였습니다. 업그레이드가 필요할 지도 모릅니다.",
  PEER_OLDER = "%h1은 구버전의 프로토콜을 이용하였습니다.",
  
  UNKNOWN_MESSAGE = "'%2'로부터 받은 '%1'은 알 수 없는 메세지 타입.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "감춘 목적",
  HIDDEN_NONE = "감춘 목적이 없습니다.",
  DEPENDS_ON_SINGLE = "'%1'에 의존함.",
  DEPENDS_ON_COUNT = "%1은 감춘 목적에 의존함.",
  FILTERED_LEVEL = "레벨에 따른 분류.",
  FILTERED_ZONE = "지역에 따른 분류.",
  FILTERED_COMPLETE = "완료 정도에 따른 분류.",
  FILTERED_BLOCKED = "이전 목표를 달성하지 못해서 가려짐.",
  FILTERED_UNWATCHED = "퀘스트 로그에 추적되지 않아 필터링 되었습니다.",
  FILTERED_USER = "이 목적이 감춰지길 요청하였음.",
  FILTERED_UNKNOWN = "완료 방법을 알 수 없음.",
  
  HIDDEN_SHOW = "보기.",
  DISABLE_FILTER = "필터 비활성화: %1",
  FILTER_DONE = "완료",
  FILTER_ZONE = "지역",
  FILTER_LEVEL = "레벨",
  FILTER_BLOCKED = nil,
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "%h1과 %h2의 정보 그리고, %h(%s3)지역의 정보를 갱신하였습니다.",
  NAG_SINGLE_NEW = "%h1의 새로운 정보를 얻었습니다.",
  NAG_ADDITIONAL = "%h1의 추가 정보를 얻었습니다.",
  NAG_POLLUTED = "당신의 데이터베이스가 해적서버에 의해 오염되었습니다. 재시작시에 데이터베이스가 초기화 될 것입니다.",
  
  NAG_NOT_NEW = "당신의 전역 데이터베이스에 어떠한 정보도 가지고 있지 않습니다.",
  NAG_NEW = "다른 사람에게 도움이 될 지도 모르니 당신의 데이터 공유를 고려해 보십시오.",
  NAG_INSTRUCTIONS = "데이터를 보내는 방법에 대해 알고 싶으시다면 %h(/qh sybmit)을 채팅창에 입력하세요.",
  
  NAG_SINGLE_FP = "비행 조련사",
  NAG_SINGLE_QUEST = "퀘스트",
  NAG_SINGLE_ROUTE = "비행 경로",
  NAG_SINGLE_ITEM_OBJ = "목표 아이템",
  NAG_SINGLE_OBJECT_OBJ = "목표 목적",
  NAG_SINGLE_MONSTER_OBJ = "목표 몬스터",
  NAG_SINGLE_EVENT_OBJ = "목표 이벤트",
  NAG_SINGLE_REPUTATION_OBJ = "목표 평판",
  NAG_SINGLE_PLAYER_OBJ = "목표 플레이어",
  
  NAG_MULTIPLE_FP = "비행 조련사 %1",
  NAG_MULTIPLE_QUEST = "퀘스트 %1",
  NAG_MULTIPLE_ROUTE = "비행 경로 %1",
  NAG_MULTIPLE_ITEM_OBJ = "목표 아이템 %1",
  NAG_MULTIPLE_OBJECT_OBJ = "목표 목적 %1",
  NAG_MULTIPLE_MONSTER_OBJ = "목표 몬스터 %1",
  NAG_MULTIPLE_EVENT_OBJ = "목표 이벤트 %1",
  NAG_MULTIPLE_REPUTATION_OBJ = "목표 평판 %1",
  NAG_MULTIPLE_PLAYER_OBJ = "목표 플레이어 %1",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1의 진행상황:",
  TRAVEL_ESTIMATE = "예상 이동 시간:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "다음 경유 장소 %h1 방문 :",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "퀘스트헬퍼",
  QH_BUTTON_TOOLTIP1 = "왼쪽 클릭: 경로 정보 %1.",
  QH_BUTTON_TOOLTIP2 = "오른쪽 클릭: 설정 메뉴 보이기.",
  QH_BUTTON_SHOW = "보이기",
  QH_BUTTON_HIDE = "숨기기",

  MENU_CLOSE = "메뉴 닫기",
  MENU_SETTINGS = "설정",
  MENU_ENABLE = "켜기",
  MENU_DISABLE = "끄기",
  MENU_OBJECTIVE_TIPS = "목표 툴팁 %1",
  MENU_TRACKER_OPTIONS = "퀘스트 추적기",
  MENU_QUEST_TRACKER = "퀘스트 추적기 %1",
  MENU_TRACKER_LEVEL = "퀘스트 레벨 %1",
  MENU_TRACKER_QCOLOUR = "퀘스트 난이도 색 %1",
  MENU_TRACKER_OCOLOUR = "퀘스트 진행 색 %1",
  MENU_TRACKER_SCALE = "추적기 크기",
  MENU_TRACKER_RESET = "위치 초기화",
  MENU_FLIGHT_TIMER = "비행 타이머 %1",
  MENU_ANT_TRAILS = "점선 경로 %1",
  MENU_WAYPOINT_ARROW = "경유지 화살표 %1",
  MENU_MAP_BUTTON = "지도 버튼 %1",
  MENU_ZONE_FILTER = "지역 필터 %1",
  MENU_DONE_FILTER = "완료 필터 %1",
  MENU_BLOCKED_FILTER = "Blocked 필터 %1",
  MENU_WATCHED_FILTER = "Watched 필터 %1",
  MENU_LEVEL_FILTER = "레벨 필터 %1",
  MENU_LEVEL_OFFSET = "레벨 필터 레벨",
  MENU_ICON_SCALE = "아이콘 크기",
  MENU_FILTERS = "필터",
  MENU_PERFORMANCE = "프레임당 작업량",
  MENU_LOCALE = "로케일",
  MENU_PARTY = "파티",
  MENU_PARTY_SHARE = "목표 공유 %1",
  MENU_PARTY_SOLO = "파티 무시 %1",
  MENU_HELP = "도움말",
  MENU_HELP_SLASH = "슬래쉬 명령어",
  MENU_HELP_CHANGES = "바뀐점 로그",
  MENU_HELP_SUBMIT = "데이터 보내기",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = nil,
  TOOLTIP_QUEST = "퀘스트 %h1.",
  TOOLTIP_PURCHASE = "%h1을(를) 구입하라.",
  TOOLTIP_SLAY = "%h1을 죽여라.",
  TOOLTIP_LOOT = "%h1을(를) 찾아라."
 }

