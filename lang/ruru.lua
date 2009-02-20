-- Please see enus.lua for reference.

QuestHelper_Translations.ruRU =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Русский",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Локализация ваших сохраненных данных не соответствует локализации вашего клиента WoW.",
  ZONE_LAYOUT_ERROR = "Боюсь, при загрузке вы потеряете все свои сохраненные данные Пожалуйста, дождитесь выхода патча для обновления информации по новым зонам.",
  DOWNGRADE_ERROR = "Ваши сохраненные данные не подходят для этой версии QuestHelper. Используйте новую версию или удалите старые данные.",
  HOME_NOT_KNOWN = "Местоположение вашего дома неизвестно. Когда будет возможность, пожалуйста, поговорите с хозяином таверны и обновите информацию о вашем доме.",
  PRIVATE_SERVER = "QuestHelper не поддерживает частные серверы.",
  PLEASE_RESTART = "При запуске QuestHelper произошла ошибка. Пожалуйста, выйдите из игры полностью и попробуйте еще раз.",
  NOT_UNZIPPED_CORRECTLY = "QuestHelper был установлен некорректно. Рекомендуется использовать либо Curse Client, либо программу 7zip для инсталляции. Убедитесь, что поддиректории распаковываются верно.",
  PLEASE_DONATE = "%h(QuestHelper выживает благодаря вашим пожертвованиям!) Мы будем благодарны за Все, что вы сможете пожертвовать - даже несколько долларов в месяц позволит быть уверенным, что я продолжу обновлять и работать над этим аддоном. Наберите %h(/qh donate) для подробной информации.",
  HOW_TO_CONFIGURE = "QuestHelper пока не имеет работающей страницы опций, но может быть настроен при введении %h(/qh settings). Помощь доступна при наборе %h(/qh help).",
  TIME_TO_UPDATE = "Возможно, доступна %h(новая версия QuestHelper). Новые версии содержат улучшения и исправления ошибок. Пожалуйста, обновите вашу версию!",
  
  -- Route related text.
  ROUTES_CHANGED = "Маршруты полетов для вашего персонажа обновлены.",
  HOME_CHANGED = "Ваш дом сменился.",
  TALK_TO_FLIGHT_MASTER = "Пожалуйста, поговорите с распорядителем полетов.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Спасибо.",
  WILL_RESET_PATH = "Сброс информации по маршрутам.",
  UPDATING_ROUTE = "Обновляются маршруты.",
  
  -- Special tracker text
  QH_LOADING = "QuestHelper загружается (%1%%)...",
  QUESTS_HIDDEN_1 = "Задания могут быть скрыты",
  QUESTS_HIDDEN_2 = "(\"/qh hidden\" для просмотра списка)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Доступные локализации:",
  LOCALE_CHANGED = "Локализация изменена на: %h1",
  LOCALE_UNKNOWN = "Локализация %h1 неизвестна.",
  
  -- Words used for objectives.
  SLAY_VERB = "Убейте",
  ACQUIRE_VERB = "Добудьте",
  
  OBJECTIVE_REASON = "%1 %h2 для задания %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 для задания %h2.",
  OBJECTIVE_REASON_TURNIN = "Завершите задание %h1.",
  OBJECTIVE_PURCHASE = "Купите у %h1.",
  OBJECTIVE_TALK = "Поговорите с %h1.",
  OBJECTIVE_SLAY = "Убейте %h1.",
  OBJECTIVE_LOOT = "Соберите %h1.",
  
  ZONE_BORDER = "граница %1/%2",
  
  -- Stuff used in objective menus.
  PRIORITY = "Приоритет",
  PRIORITY1 = "Самый высокий",
  PRIORITY2 = "Высокий",
  PRIORITY3 = "Обычный",
  PRIORITY4 = "Низкий",
  PRIORITY5 = "Самый низкий",
  SHARING = "Разделение задания",
  SHARING_ENABLE = "Разделять задание",
  SHARING_DISABLE = "Не разделять задание",
  IGNORE = "Игнорировать",
  
  IGNORED_PRIORITY_TITLE = "Выбранный приоритет будет проигнорирован.",
  IGNORED_PRIORITY_FIX = "Применить такой же приоритет к связанным заданиям.",
  IGNORED_PRIORITY_IGNORE = "Я выставлю приоритеты самостоятельно.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Результаты поиска",
  NO_RESULTS = "Ничего нет!",
  CREATED_OBJ = "Создано: %1",
  REMOVED_OBJ = "Утрачено: %1",
  USER_OBJ = "Цель пользователя: %h1",
  UNKNOWN_OBJ = "Я не знаю, куда надо идти для этой цели.",
  INACCESSIBLE_OBJ = "QuestHelper не смог найти подходящей области для %h1. В список заданий добавлено недоступное для указания место. Если вы обнаружите подходящее место для выполнения этого задания, пришлите нам данные об этом! (%h(/qh submit))",
  
  SEARCHING_STATE = "Идет поиск: %1",
  SEARCHING_LOCAL = "локальные %1",
  SEARCHING_STATIC = "статичные %1",
  SEARCHING_ITEMS = "предметы",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "зоны",
  SEARCHING_DONE = "Готово!",
  
  -- Shared objectives.
  PEER_TURNIN = "Подождите пока %h1 завершит %h2.",
  PEER_LOCATION = "Помогите %h1 добраться до места в %h2.",
  PEER_ITEM = "Помогите %1 добыть %h2.",
  PEER_OTHER = "Помогите %1 с %h2.",
  
  PEER_NEWER = "%h1 использует протокол новой версии. Наверное, время обновиться.",
  PEER_OLDER = "%h1 использует протокол старой версии.",
  
  UNKNOWN_MESSAGE = "Неизвестный тип сообщения '%1' от '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Скрытые цели",
  HIDDEN_NONE = "У вас нет скрытых целей.",
  DEPENDS_ON_SINGLE = "Зависит от '%1'.",
  DEPENDS_ON_COUNT = "Зависит от %1 скрытых целей.",
  FILTERED_LEVEL = "Скрыто в соответствии с фильтром уровня.",
  FILTERED_ZONE = "Скрыто в соответствии с фильтром зоны.",
  FILTERED_COMPLETE = "Скрыто по причине завершенности задания.",
  FILTERED_BLOCKED = "Скрыто из-за незавершенной предыдущей цели задания.",
  FILTERED_UNWATCHED = "Скрыто, так как не помечено отслеживающимся в журнале заданий.",
  FILTERED_USER = "Вы запросили скрыть эту цель.",
  FILTERED_UNKNOWN = "Неизвестно как завершить задание.",
  
  HIDDEN_SHOW = "Показать.",
  DISABLE_FILTER = "Отключить фильтр: %1",
  FILTER_DONE = "готово",
  FILTER_ZONE = "зона",
  FILTER_LEVEL = "уровень",
  FILTER_BLOCKED = "заблокировано",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "У вас есть %h(новая информация) о %h1 и %h(обновленная информация) о %h2.",
  NAG_SINGLE_NEW = "У вас есть %h(новая информация) о %h1.",
  NAG_ADDITIONAL = "У вас есть %h(дополнительная информация) о %h1.",
  NAG_POLLUTED = "Ваша база данных испорчена информацией с тестового или частного сервера, и будет очищена при запуске.",
  
  NAG_NOT_NEW = "У вас нет информации, которой не было бы в статичной базе.",
  NAG_NEW = "Если вы раздадите свою информацию другим, им это сильно пригодится.",
  NAG_INSTRUCTIONS = "Наберите %h(/qh submit) для получения инструкций об отправке данных.",
  
  NAG_SINGLE_FP = "распорядителе полетов",
  NAG_SINGLE_QUEST = "задании",
  NAG_SINGLE_ROUTE = "пути полета",
  NAG_SINGLE_ITEM_OBJ = "целевом предмете",
  NAG_SINGLE_OBJECT_OBJ = "целевом объекте",
  NAG_SINGLE_MONSTER_OBJ = "целевом монстре",
  NAG_SINGLE_EVENT_OBJ = "целевом месте события",
  NAG_SINGLE_REPUTATION_OBJ = "задании на репутацию",
  NAG_SINGLE_PLAYER_OBJ = "целевом игроке",
  
  NAG_MULTIPLE_FP = "%1 распорядителях полетов",
  NAG_MULTIPLE_QUEST = "%1 заданиях",
  NAG_MULTIPLE_ROUTE = "%1 путях полета",
  NAG_MULTIPLE_ITEM_OBJ = "%1 целевых предметах",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 целевых объектах",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 целевых монстрах",
  NAG_MULTIPLE_EVENT_OBJ = "%1 целевых местах событий",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 заданиях на репутацию",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 целевых игроках",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 прогресс:",
  TRAVEL_ESTIMATE = "Время прибытия:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Пройдите через %h1 по дороге к:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Левый клик: %1 информацию по маршрутам.",
  QH_BUTTON_TOOLTIP2 = "Правый клик: показать меню настроек.",
  QH_BUTTON_SHOW = "показать",
  QH_BUTTON_HIDE = "скрыть",

  MENU_CLOSE = "Закрыть меню",
  MENU_SETTINGS = "Настройки",
  MENU_ENABLE = "Включить",
  MENU_DISABLE = "Отключить",
  MENU_OBJECTIVE_TIPS = "%1 подсказку цели",
  MENU_TRACKER_OPTIONS = "Отслеживание заданий",
  MENU_QUEST_TRACKER = "%1 отслеживание заданий",
  MENU_TRACKER_LEVEL = "%1 отображение уровней заданий",
  MENU_TRACKER_QCOLOUR = "%1 окраску заданий по сложности",
  MENU_TRACKER_OCOLOUR = "%1 индикацию прогресса цветом",
  MENU_TRACKER_SCALE = "Масштаб списка заданий",
  MENU_TRACKER_RESET = "Сбросить позицию",
  MENU_FLIGHT_TIMER = "%1 таймер полета",
  MENU_ANT_TRAILS = "%1 оптимальный путь",
  MENU_WAYPOINT_ARROW = "%1 направляющую стрелку",
  MENU_MAP_BUTTON = "%1 кнопку на карте",
  MENU_ZONE_FILTER = "%1 фильтр по зоне",
  MENU_DONE_FILTER = "%1 фильтр завершенных заданий",
  MENU_BLOCKED_FILTER = "%1 фильтр заблокированных заданий",
  MENU_WATCHED_FILTER = "%1 фильтр отслеживаемых заданий",
  MENU_LEVEL_FILTER = "%1 фильтр по уровню заданий",
  MENU_LEVEL_OFFSET = "Ограничение заданий по уровню",
  MENU_ICON_SCALE = "Размер иконки",
  MENU_FILTERS = "Фильтры",
  MENU_PERFORMANCE = "Уровень производительности",
  MENU_LOCALE = "Локализация",
  MENU_PARTY = "Группа",
  MENU_PARTY_SHARE = "%1 обмен целями",
  MENU_PARTY_SOLO = "%1 игнорирование группы",
  MENU_HELP = "Помощь",
  MENU_HELP_SLASH = "Клавиатурные команды",
  MENU_HELP_CHANGES = "История изменений",
  MENU_HELP_SUBMIT = "Отправка данных",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Отслеживается QuestHelper'ом",
  TOOLTIP_QUEST = "Для задания %h1.",
  TOOLTIP_PURCHASE = "Купите %h1.",
  TOOLTIP_SLAY = "Убейте, чтобы получить %h1.",
  TOOLTIP_LOOT = "Соберите добычу, чтобы получить %h1."
 }

