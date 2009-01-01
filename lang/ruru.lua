-- Please see lang_enus.lua for reference.

QuestHelper_Translations.ruRU =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Русский",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Локализация ваших сохранённых данных не соответствует локализации вашего ВоВ клиента.",
  ZONE_LAYOUT_ERROR = "Боюсь, при загрузке вы потеряете все свои сохранённые данные Пожалуйста, дождитесь выхода патча для обновления информации по новым зонам.",
  DOWNGRADE_ERROR = "Ваши сохранённые данные не подходят для этой версии КвестХэлпера. Используйте новую версию, или удалите старые данные.",
  HOME_NOT_KNOWN = "Местоположение вашего дома неизвестно. Когда будет возможность, пожалуйста, поговорите с Инкипером и обновите информацию о вашем доме.",
  PRIVATE_SERVER = "КвестХелпер не поддерживает пиратские сервера.",
  PLEASE_RESTART = "При запуске КвестХелпера произошла ошибка. Пожалуйста выйдите из игры полностью и попробуйте еще раз.",
  NOT_UNZIPPED_CORRECTLY = "КвестХелпер был установлен некорректно. Рекомендуется использовать либо Curse Client, либо программу 7zip для инсталляции. Убедитесь, что поддиректории распаковываются верно.",
  PLEASE_DONATE = "%h(Дело КвестХелпера живет благодаря Вашим пожертвованиям!) Мы будем благодарны за Все, что вы сможете пожертвовать - даже несколько долларов в месяц позволит быть уверенным, что я продолжу обновлять и работать над этим аддоном. Введите %(/qh donate) для информации.",
  HOW_TO_CONFIGURE = nil,
  
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
  INACCESSIBLE_OBJ = nil,
  
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
  FILTERED_UNWATCHED = "Отфильтровано, так как не помечено отслеживающимся в журнале квестов.",
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
  NAG_POLLUTED = "Ваша база данных испорчена информацией с тестового или пиратского сервера, и будет очищена при запуске.",
  
  NAG_NOT_NEW = "У вас нет информации которой не было бы в статичной базе.",
  NAG_NEW = "Если вы раздадите свою информацию другим, им это сильно пригодится.",
  NAG_INSTRUCTIONS = "Для помощи наберите %h(/qh submit",
  
  NAG_SINGLE_FP = "Мастер полетов",
  NAG_SINGLE_QUEST = "Задание",
  NAG_SINGLE_ROUTE = "Путь полёта",
  NAG_SINGLE_ITEM_OBJ = "Добывание предмета",
  NAG_SINGLE_OBJECT_OBJ = "Цель Цели",
  NAG_SINGLE_MONSTER_OBJ = "Убийство Монстра",
  NAG_SINGLE_EVENT_OBJ = "Объект событий",
  NAG_SINGLE_REPUTATION_OBJ = "Репутция",
  NAG_SINGLE_PLAYER_OBJ = "Цель Игрока",
  
  NAG_MULTIPLE_FP = "Мастера полетов",
  NAG_MULTIPLE_QUEST = "Квесты",
  NAG_MULTIPLE_ROUTE = "Пути Полетов",
  NAG_MULTIPLE_ITEM_OBJ = "Добывание предметов",
  NAG_MULTIPLE_OBJECT_OBJ = "Цели Целей xD",
  NAG_MULTIPLE_MONSTER_OBJ = "Убийство мобов",
  NAG_MULTIPLE_EVENT_OBJ = "Объекты событий",
  NAG_MULTIPLE_REPUTATION_OBJ = "Репутация",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 цели игроков",
  
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
  MENU_OBJECTIVE_TIPS = "% 1 Цель Подсказки",
  MENU_TRACKER_OPTIONS = "Опции Тракера",
  MENU_QUEST_TRACKER = "Квест Трекер",
  MENU_TRACKER_LEVEL = "Уровни Заданий",
  MENU_TRACKER_QCOLOUR = "Цвет (сложность квестов)",
  MENU_TRACKER_OCOLOUR = "Цвета",
  MENU_TRACKER_SCALE = "Размер Тракера",
  MENU_TRACKER_RESET = "Сброс позиции",
  MENU_FLIGHT_TIMER = "%1 Таймер полёта",
  MENU_ANT_TRAILS = "%1 Оптимальный путь",
  MENU_WAYPOINT_ARROW = "%1 Направляющую стрелку",
  MENU_MAP_BUTTON = "%1 Кнопку карты",
  MENU_ZONE_FILTER = "%1 Фильтр зоны",
  MENU_DONE_FILTER = "%1 Фильтр завершённости",
  MENU_BLOCKED_FILTER = "%1 Фильтр блокировки",
  MENU_WATCHED_FILTER = "%1 Фильтр отслеживания",
  MENU_LEVEL_FILTER = "%1 Фильтр уровней",
  MENU_LEVEL_OFFSET = "Параметры фильтра уровней",
  MENU_ICON_SCALE = "Размер иконки",
  MENU_FILTERS = "Фильтры",
  MENU_PERFORMANCE = "Настройки производительности",
  MENU_LOCALE = "Локализация",
  MENU_PARTY = "Группа",
  MENU_PARTY_SHARE = "Делиться Квестом Опции",
  MENU_PARTY_SOLO = "Игнорировать Пати",
  MENU_HELP = "Помошь",
  MENU_HELP_SLASH = "Слешовые Команды",
  MENU_HELP_CHANGES = "Чендж Лог",
  MENU_HELP_SUBMIT = "Передача данных",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Смотреть QuestHelper",
  TOOLTIP_QUEST = "Для квеста %h1.",
  TOOLTIP_PURCHASE = "Приобрести %h1.",
  TOOLTIP_SLAY = "Убить для %h1.",
  TOOLTIP_LOOT = "Собрать с трупа для %h1."
 }

