-- Please see lang_enus.lua for reference.

QuestHelper_Translations.esES =
 {
  -- Messages used when starting.
  LOCALE_ERROR = "El idioma de su datos guardados no coincide con el idioma de su juego.",
  ZONE_LAYOUT_ERROR = "Estoy negarse a correr, por temor a dañar sus datos guardados. "..
                      "Por favor, espere a que un parche que será capaz de manejar la nueva zona de diseño.",
  DOWNGRADE_ERROR = "Sus datos guardados no es compatible con esta versión de QuestHelper. "..
                    "Utilice una nueva versión, o borrar tus variables.",
  HOME_NOT_KNOWN = "Su origen no es conocido. Cuando llegue la oportunidad, por favor, hable con su posadero y restaurarla.",
  
  -- Route related text.
  ROUTES_CHANGED = "Las rutas de vuelo de su personaje han sido alterados.",
  HOME_CHANGED = "Su casa ha sido modificada.",
  TALK_TO_FLIGHT_MASTER = "Por favor, hable con el maestro de vuelo local.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Gracias.",
  WILL_RESET_PATH = "Se restablecerá pathing información.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Idiomas:",
  LOCALE_CHANGED = "Cambiado de idioma: %h1",
  LOCALE_UNKNOWN = "Idioma %h1 no se conoce.",
  
  -- Words used for objectives.
  SLAY_VERB = "Matar",
  ACQUIRE_VERB = "Adquirir",
  
  OBJECTIVE_REASON = "%1 %h2 para la búsqueda %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 para la búsqueda %h2.",
  OBJECTIVE_REASON_TURNIN = "A su vez en búsqueda %h1.",
  OBJECTIVE_PURCHASE = "Compra de %h1.",
  OBJECTIVE_TALK = "Hable con %h1.",
  OBJECTIVE_SLAY = "Matar %h1.",
  OBJECTIVE_LOOT = "Botín %h1.",
  
  ZONE_BORDER = "%1/%2 frontera",
  
  -- Stuff used in objective menus.
  PRIORITY = "Prioridad",
  PRIORITY1 = "Más Alta",
  PRIORITY2 = "Alta",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Baja",
  PRIORITY5 = "Más bajo",
  SHARING = "Compartir",
  ENABLE = "Habilitar",
  DISABLE = "Desactivar",
  IGNORE = "Ignorar",
  
  IGNORED_PRIORITY_TITLE = "El seleccionado prioridad sería ignorado.",
  IGNORED_PRIORITY_FIX = "Aplicar misma prioridad a los objetivos de bloqueo.",
  IGNORED_PRIORITY_IGNORE = "Voy a fijar las prioridades de mí mismo.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Los resultados de la búsqueda",
  NO_RESULTS = "No hay ninguna!",
  CREATED_OBJ = "Creado: %1",
  REMOVED_OBJ = "Eliminado: %1",
  USER_OBJ = "Objetivo de Usuario: %h1",
  UNKNOWN_OBJ = "No sé dónde hay que ir para ese objetivo.",
  
  SEARCHING_STATE = "Buscando: %1",
  SEARCHING_LOCAL = "Locales %1",
  SEARCHING_STATIC = "Estática %1",
  SEARCHING_ITEMS = "Temas",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zonas",
  SEARCHING_DONE = "Hecho!",
  
  -- Shared objectives.
  PEER_TURNIN = "Espere a %h1 para terminar %h2.",
  PEER_LOCATION = "Ayuda %h1 alcanzar un lugar en %h2.",
  PEER_ITEM = "Ayuda %1 para adquirir %h2",
  PEER_OTHER = "Ayudar %1 con %h2.",
  
  PEER_NEWER = "%h1 está utilizando una nueva versión de protocolo. Tal vez sea el momento de la actualización.",
  PEER_OLDER = "%h1 está utilizando una versión de mayor edad de protocolo.",
  
  UNKNOWN_MESSAGE = "Desconocido tipo de mensaje '%1' en '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Objetivos Ocultos",
  HIDDEN_NONE = "No hay objetivos ocultos de usted.",
  DEPENDS_ON_SINGLE = "Depends de '%1'.",
  DEPENDS_ON_COUNT = "Depende de los objetivos ocultos %1.",
  FILTERED_LEVEL = "Filtrado por nivel.",
  FILTERED_ZONE = "Filtrado debido a la zona.",
  FILTERED_COMPLETE = "Filtrado debido a la exhaustividad.",
  FILTERED_USER = "Usted pidió este objetivo se oculta.",
  FILTERED_UNKNOWN = "No sabe cómo llevar a cabo.",
  
  HIDDEN_SHOW = "Mostrar.",
  DISABLE_FILTER = "Desactivar el filtro: %1",
  FILTER_DONE = "hacer",
  FILTER_ZONE = "zona",
  FILTER_LEVEL = "nivel",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_SINGLE = "1 %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %s2",
  
  NAG_MULTIPLE_NEW = "Usted tiene información, %h1 nuevo y %h2 actualizado %h(%s3).",
  NAG_SINGLE_NEW = "Usted tiene nueva información sobre %h1.",
  NAG_ADDITIONAL = "Usted tiene información adicional sobre %h1.",
  
  NAG_NOT_NEW = "Usted no tiene ninguna información que no estén ya en la base de datos estáticos.",
  NAG_NEW = "Usted podría considerar la posibilidad de compartir sus datos para que otros puedan beneficiarse.",
  
  NAG_FP = "maestro de vuelo",
  NAG_QUEST = "búsqueda",
  NAG_ROUTE = "ruta de vuelo",
  NAG_ITEM_OBJ = "tema objetivo",
  NAG_OBJECT_OBJ = "objeto objetivo",
  NAG_MONSTER_OBJ = "monstruo objetivo",
  NAG_EVENT_OBJ = "evento objetivo",
  NAG_REPUTATION_OBJ = "reputación objetivo",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 el progreso:",
  TRAVEL_ESTIMATE = "Tiempo estimado de viaje:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visita %h1 en el camino a:"
 }
