-- Please see lang_enus.lua for reference.

QuestHelper_Translations["ruRU"] =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Русский",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Локализация ваших сохранённых данных не соответствует локализации вашего ВоВ клиента.",
  ZONE_LAYOUT_ERROR = "Боюсь, при загрузке вы потеряете все свои сохранённые данные Пожалуйста, дождитесь выхода патча для обновления информации по новым зонам.",
  DOWNGRADE_ERROR = "Ваши сохранённые данные не подходят для этой версии КвестХэлпера. Используйте новую версию, или удалите старые данные.",
  HOME_NOT_KNOWN = "Местоположение вашего дома неизвестно. Когда будет возможность, пожалуйста, поговорите с Инкипером и обновите информацию о вашем доме.",
  
  -- Route related text.
  ROUTES_CHANGED = "Маршруты полётов для вашего персонажа обновлены.",
  HOME_CHANGED = "Ваш дом сменился.",
  TALK_TO_FLIGHT_MASTER = "Будьте любезны, поговорите с Мастером Полётов.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Спасибо.",
  WILL_RESET_PATH = "Сброс информации по маршрутам.",
  UPDATING_ROUTE = "Обновляются маршруты.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Доступные локализации:",
  LOCALE_CHANGED = "Локализация изменена на: %h1",
  LOCALE_UNKNOWN = "Локализация %h1 неизвестна.",
  
  -- Words used for objectives.
  SLAY_VERB = "Завалить",
  ACQUIRE_VERB = "Добыть",
  
  OBJECTIVE_REASON = "%1 %h2 для квеста %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 для квеста %h2.",
  OBJECTIVE_REASON_TURNIN = "Цель квеста %h1.",
  OBJECTIVE_PURCHASE = "Приобрести от %h1.",
  OBJECTIVE_TALK = "Поговорить с %h1.",
  OBJECTIVE_SLAY = "Завалить %h1.",
  OBJECTIVE_LOOT = "Лут %h1.",
  
  ZONE_BORDER = "%1/%2 граница",
  
  -- Stuff used in objective menus.
  PRIORITY = "Приоритет",
  PRIORITY1 = "Самый высокий",
  PRIORITY2 = "Высокий",
  PRIORITY3 = "Обычный",
  PRIORITY4 = "Низкий",
  PRIORITY5 = "Самый низкий",
  SHARING = "Раздача",
  SHARING_ENABLE = "Поделиться",
  SHARING_DISABLE = "Не Делиться",
  IGNORE = "Игнор",
  
  IGNORED_PRIORITY_TITLE = "Выбранный приоритет будет проигнорирован.",
  IGNORED_PRIORITY_FIX = "Применить такой же приоритет к связанным заданиям.",
  IGNORED_PRIORITY_IGNORE = "Я выставлю приоритеты самостоятельно.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Результаты поиска",
  NO_RESULTS = "Ничего нету!",
  CREATED_OBJ = "Создано: %1",
  REMOVED_OBJ = "Убрано: %1",
  USER_OBJ = "Задание пользователя: %h1",
  UNKNOWN_OBJ = "Я не знаю куда тебе надо идти для этого задания.",
  
  SEARCHING_STATE = "Идёт поиск: %1",
  SEARCHING_LOCAL = "Местный %1",
  SEARCHING_STATIC = "Статичный %1",
  SEARCHING_ITEMS = "Предметы",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Зоны",
  SEARCHING_DONE = "Готово!",
  
  -- Shared objectives.
  PEER_TURNIN = "Подождите %h1 для хода в %h2.",
  PEER_LOCATION = "Помогите %h1 добраться до места в %h2.",
  PEER_ITEM = "Помогите %1 приобрести %h2.",
  PEER_OTHER = "Посодействуйте %1 с %h2.",
  
  PEER_NEWER = "%h1 использует протокол новой версии. Наверное, время обновиться.",
  PEER_OLDER = "%h1 использует протокол старой версии.",
  
  UNKNOWN_MESSAGE = "Неизвестный тип сообщения '%1' от '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Скрытая цель",
  HIDDEN_NONE = "Для вас нету скрытых целей.",
  DEPENDS_ON_SINGLE = "Зависит от '%1'.",
  DEPENDS_ON_COUNT = "Зависит от %1 скрытых целей.",
  FILTERED_LEVEL = "Фильтр по уровню.",
  FILTERED_ZONE = "Фильтр по зоне.",
  FILTERED_COMPLETE = "Фильтр по завершённости.",
  FILTERED_BLOCKED = "Фильтр по проценту незавершённости",
  FILTERED_USER = "Вы запросили скрыть эту цель.",
  FILTERED_UNKNOWN = "Не знаю как закончить.",
  
  HIDDEN_SHOW = "Показать.",
  DISABLE_FILTER = "Отключить фильтр: %1",
  FILTER_DONE = "готово",
  FILTER_ZONE = "зона",
  FILTER_LEVEL = "уровень",
  FILTER_BLOCKED = "заблокировано",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "У вас есть новая информация по %h1 и %h2 обновлен %h(%s3).",
  NAG_SINGLE_NEW = "У вас есть новая информация по %h1.",
  NAG_ADDITIONAL = "У вас есть дополнительная информация по %h1.",
  
  NAG_NOT_NEW = "У вас нет информации которой не было бы в статичной базе.",
  NAG_NEW = "Если вы раздадите свою информацию другим, им это сильно пригодиться.",
  NAG_INSTRUCTIONS = nil,
  
  NAG_SINGLE_FP = nil,
  NAG_SINGLE_QUEST = "Задание",
  NAG_SINGLE_ROUTE = "Путь полёта",
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
  PEER_PROGRESS = "%1's прогресс:",
  TRAVEL_ESTIMATE = "Время прибытия:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Посетите %h1 для полёта в:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "КвестХэлпер",
  QH_BUTTON_TOOLTIP1 = "Левый клик: %1 информация по маршрутам.",
  QH_BUTTON_TOOLTIP2 = "Правый клик: Показать меню настроек.",
  QH_BUTTON_SHOW = "Показать",
  QH_BUTTON_HIDE = "Скрыть",

  MENU_CLOSE = "Закрыть меню",
  MENU_SETTINGS = "Настройки",
  MENU_ENABLE = "Показать",
  MENU_DISABLE = "Скрыть",
  MENU_OBJECTIVE_TIPS = nil,
  MENU_TRACKER_OPTIONS = nil,
  MENU_QUEST_TRACKER = nil,
  MENU_TRACKER_LEVEL = "Уровни Заданий",
  MENU_TRACKER_QCOLOUR = nil,
  MENU_TRACKER_OCOLOUR = nil,
  MENU_TRACKER_SCALE = nil,
  MENU_TRACKER_RESET = nil,
  MENU_FLIGHT_TIMER = "%1 Таймер полёта",
  MENU_ANT_TRAILS = "%1 Оптимальный путь",
  MENU_WAYPOINT_ARROW = "%1 Направляющую стрелку",
  MENU_MAP_BUTTON = "%1 Кнопку карты",
  MENU_ZONE_FILTER = "%1 Фильтр зоны",
  MENU_DONE_FILTER = "%1 Фильтр завершённости",
  MENU_BLOCKED_FILTER = "%1 Фильтр блокировки",
  MENU_LEVEL_FILTER = "%1 Фильтр уровней",
  MENU_LEVEL_OFFSET = "Параметры фильтра уровней",
  MENU_ICON_SCALE = "Размер иконки",
  MENU_FILTERS = "Фильтры",
  MENU_PERFORMANCE = "Настройки производительности",
  MENU_LOCALE = "Локализация",
  MENU_PARTY = "Группа",
  MENU_PARTY_SHARE = nil,
  MENU_PARTY_SOLO = nil,
  MENU_HELP = "Помошь",
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

