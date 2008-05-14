-- Please see lang_enus.lua for reference.

QuestHelper_SubstituteFonts.ruRU =
 {
  sans = "Fonts\\ARIALN.TTF"
 }

QuestHelper_Translations.ruRU =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Русский",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Локализация ваших сохранённых данных не соответствует локализации вашего ВоВ клиента.",
  ZONE_LAYOUT_ERROR = "Боюсь, при загрузке вы потеряете все свои сохранённые данные "..
                      "Пожалуйста, дождитесь выхода патча для обновления информации по новым зонам.",
  DOWNGRADE_ERROR = "Ваши сохранённые данные не подходят для этой версии КвестХэлпера. "..
                    "Используйте новую версию, или удалите старые данные.",
  HOME_NOT_KNOWN = "Местоположение вашего дома неизвестно. Когда будет возможность, пожалуйста, поговорите с Инкипером и обновите информацию о вашем доме.",
  
  -- This text is only printed for the enUS client, don't worry about translating it.
  ALTERED_INDEX = "!!! QuestHelper_IndexLookup entry needs update: [%Q1] = {%2, %3, %4}",
  ALTERED_ZONE = "!!! QuestHelper_Zones entry needs update: [%1][%2] = %Q3 -- was %4",
  
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
  ENABLE = "Вкл",
  DISABLE = "Откл",
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
  NAG_SINGLE = "1 %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %s2",
  
  NAG_MULTIPLE_NEW = "У вас есть новая информация по %h1 и %h2 обновлен %h(%s3).",
  NAG_SINGLE_NEW = "У вас есть новая информация по %h1.",
  NAG_ADDITIONAL = "У вас есть дополнительная информация по %h1.",
  
  NAG_NOT_NEW = "У вас нет информации которой не было бы в статичной базе.",
  NAG_NEW = "Если вы раздадите свою информацию другим, им это сильно пригодиться.",
  
  NAG_FP = "мастер полётов",
  NAG_QUEST = "квест",
  NAG_ROUTE = "маршрут полёта",
  NAG_ITEM_OBJ = "предмет",
  NAG_OBJECT_OBJ = "объект",
  NAG_MONSTER_OBJ = "монстр",
  NAG_EVENT_OBJ = "событие",
  NAG_REPUTATION_OBJ = "репутация",
  
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
  MENU_LOCALE = "Локализация"
 }
