-- Please see lang_enus.lua for reference.

QuestHelper_Translations.esES =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Español",
  
  -- Messages used when starting.
  LOCALE_ERROR = "El idioma de su datos guardados no coincide con el idioma del cliente Wow.",
  ZONE_LAYOUT_ERROR = "Me niego a ejecutarme, por miedo a dañar sus datos guardados. "..
                      "Por favor, espere a que un parche que será capaz de manejar el nueva diseño de zona.",
  DOWNGRADE_ERROR = "Sus datos guardados no son compatibles con esta versión de QuestHelper. "..
                    "Utilice una nueva versión, o borre su variables guardadas.",
  HOME_NOT_KNOWN = "No se conoce su hogar. Cuando tenga una oportunidad, por favor, hable con su posadero para restaurarla.",
  
  -- Route related text.
  ROUTES_CHANGED = "Las rutas de vuelo de su personaje han sido alteradas.",
  HOME_CHANGED = "Su hogar ha sido modificado.",
  TALK_TO_FLIGHT_MASTER = "Por favor, hable con el maestro de vuelo local.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Gracias.",
  WILL_RESET_PATH = "Se restablecerá la información de rutas.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Idiomas:",
  LOCALE_CHANGED = "Idioma cambiado a: %h1",
  LOCALE_UNKNOWN = "El Idioma %h1 es desconocido.",
  
  -- Words used for objectives.
  SLAY_VERB = "Matar",
  ACQUIRE_VERB = "Adquirir",
  
  OBJECTIVE_REASON = "%1 %h2 para la misión  %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 para la misión %h2.",
  OBJECTIVE_REASON_TURNIN = "Entrega la misión %h1.",
  OBJECTIVE_PURCHASE = "Compra de %h1.",
  OBJECTIVE_TALK = "Habla con %h1.",
  OBJECTIVE_SLAY = "Matar %h1.",
  OBJECTIVE_LOOT = "Recoge de %h1.",
  
  ZONE_BORDER = "la frontera %1/%2",
  
  -- Stuff used in objective menus.
  PRIORITY = "Prioridad",
  PRIORITY1 = "La más Alta",
  PRIORITY2 = "Alta",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Baja",
  PRIORITY5 = "La más baja",
  SHARING = "Compartir",
  ENABLE = "Activar",
  DISABLE = "Desactivar",
  IGNORE = "Ignorar",
  
  IGNORED_PRIORITY_TITLE = "La prioridad seleccionada podria ser ignorada.",
  IGNORED_PRIORITY_FIX = "Aplique la misma prioridad a los objetivos que bloquean.",
  IGNORED_PRIORITY_IGNORE = "Voy a fijar las prioridades de mí mismo.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Resultados de la búsqueda",
  NO_RESULTS = "No hay ninguno!",
  CREATED_OBJ = "Creado: %1",
  REMOVED_OBJ = "Eliminado: %1",
  USER_OBJ = "Objetivo de Usuario: %h1",
  UNKNOWN_OBJ = "No sé dónde hay que ir para ese objetivo.",
  
  SEARCHING_STATE = "Buscando: %1",
  SEARCHING_LOCAL = "Locales %1",
  SEARCHING_STATIC = "Estáticas %1",
  SEARCHING_ITEMS = "Items",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zonas",
  SEARCHING_DONE = "Hecho!",
  
  -- Shared objectives.
  PEER_TURNIN = "Espere a %h1 a que entregue %h2.",
  PEER_LOCATION = "Ayuda a %h1 a alcanzar un lugar en %h2.",
  PEER_ITEM = "Ayuda a %1 a adquirir %h2",
  PEER_OTHER = "Ayudar a %1 con %h2.",
  
  PEER_NEWER = "%h1 está utilizando una nueva versión de protocolo. Tal vez sea el momento de actualizarse.",
  PEER_OLDER = "%h1 está utilizando una versión mas antigua del protocolo.",
  
  UNKNOWN_MESSAGE = "Tipo de mensaje desconocido '%1' desde '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Objetivos Ocultos",
  HIDDEN_NONE = "No hay objetivos ocultos de usted.",
  DEPENDS_ON_SINGLE = "Depende de '%1'.",
  DEPENDS_ON_COUNT = "Depende de los objetivos ocultos %1.",
  FILTERED_LEVEL = "Filtrado por nivel.",
  FILTERED_ZONE = "Filtrado debido a la zona.",
  FILTERED_COMPLETE = "Filtrado debido a completados.",
  FILTERED_USER = "Usted pidió que este objetivo se ocultara.",
  FILTERED_UNKNOWN = "Desconozco cómo llevar a cabo.",
  
  HIDDEN_SHOW = "Mostrar.",
  DISABLE_FILTER = "Desactivar el filtro: %1",
  FILTER_DONE = "hecho",
  FILTER_ZONE = "zona",
  FILTER_LEVEL = "nivel",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_SINGLE = "1 %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %s2",
  
  NAG_MULTIPLE_NEW = "Usted tiene información sobre %h1 nuevas y %h2 actualizadas %h(%s3).",
  NAG_SINGLE_NEW = "Usted tiene información nueva sobre %h1.",
  NAG_ADDITIONAL = "Usted tiene información adicional sobre %h1.",
  
  NAG_NOT_NEW = "Usted no tiene ninguna información que no estén ya en la base de datos estáticos.",
  NAG_NEW = "Usted podría considerar la posibilidad de compartir sus datos para que otros puedan beneficiarse.",
  
  NAG_FP = "maestro de vuelo",
  NAG_QUEST = "misión",
  NAG_ROUTE = "ruta de vuelo",
  NAG_ITEM_OBJ = "item objetivo",
  NAG_OBJECT_OBJ = "objeto objetivo",
  NAG_MONSTER_OBJ = "monstruo objetivo",
  NAG_EVENT_OBJ = "evento objetivo",
  NAG_REPUTATION_OBJ = "reputación objetivo",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "progreso de %1:",
  TRAVEL_ESTIMATE = "Tiempo estimado de viaje:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visita %h1 en camino a:"
 }
