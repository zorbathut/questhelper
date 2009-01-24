-- Please see enus.lua for reference.

QuestHelper_Translations.ptPT =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Português",
  
  -- Messages used when starting.
  LOCALE_ERROR = "A localização dos teus dados (língua), não coincide com a localização desta instalação do WoW. Para usar o QuestHelper precisas de reverter para a localização original, ou apagar os dados escrevendo %h(/qh purge).",
  ZONE_LAYOUT_ERROR = "Recuso-me a trabalhar, com medo de corromper os teus dados guardados. Por favor aguarda por uma actualização que seja capaz de lidar com a nova estrutura da zona.",
  DOWNGRADE_ERROR = "Os dados guardados não são compatíveis com esta versão do QuestHelper. Usa uma nova versão, ou apaga os dados da pasta 'SavedVariables'.",
  HOME_NOT_KNOWN = "O teu alojamento não é conhecido. Quando puderes, fala com um hospedeiro de uma estalagem e reactiva-o.",
  PRIVATE_SERVER = "O QuestHelper não suporta servidores privados.",
  PLEASE_RESTART = "Ouve um erro ao iniciar o QuestHelper. Por favor saia totalmente do World of Warcraft e volte a tentar.",
  NOT_UNZIPPED_CORRECTLY = "O QuestHelper foi instalado incorrectamente. Nós recomendamos o uso do Curse Client ou do 7zip para instalar. Reveja se as sub-directórias foram extraídas.",
  PLEASE_DONATE = "%h(O QuestHelper sobrevive das tuas doações!) Qualquer contributo é apreciado, e apenas alguns euros por mês garantem que eu o mantenha actualizado e a trabalhar. Escreva %h(/qh donate) para mais informação.",
  HOW_TO_CONFIGURE = nil,
  TIME_TO_UPDATE = nil,
  
  -- Route related text.
  ROUTES_CHANGED = "As rotas de voo para o teu personagem foram alteradas.",
  HOME_CHANGED = "O teu alojamento foi modificado.",
  TALK_TO_FLIGHT_MASTER = "Por favor fala com o mestre de voo.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Obrigado.",
  WILL_RESET_PATH = "Reescrevendo informação das rotas.",
  UPDATING_ROUTE = "Reescrevendo rota.",
  
  -- Special tracker text
  QH_LOADING = "QuestHelper está carregando (%1%%)...",
  QUESTS_HIDDEN_1 = "Quests podem estar escondida.",
  QUESTS_HIDDEN_2 = "(\"/qh hidden\" para listar(escondidas)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Localizações Disponíveis:",
  LOCALE_CHANGED = "Localização alterada para: %h1",
  LOCALE_UNKNOWN = "Localização %h1 não é conhecida.",
  
  -- Words used for objectives.
  SLAY_VERB = "Matar",
  ACQUIRE_VERB = "Obter",
  
  OBJECTIVE_REASON = "%1 %h2 para a missão %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 para a missão %h2.",
  OBJECTIVE_REASON_TURNIN = "Entregar a missão %h1.",
  OBJECTIVE_PURCHASE = "Aquirir de %h1.",
  OBJECTIVE_TALK = "Falar com %h1.",
  OBJECTIVE_SLAY = "Matar %h1.",
  OBJECTIVE_LOOT = "Pilhar %h1.",
  
  ZONE_BORDER = "%1/%2 fronteira",
  
  -- Stuff used in objective menus.
  PRIORITY = "Prioridade",
  PRIORITY1 = "Altíssima",
  PRIORITY2 = "Alta",
  PRIORITY3 = "Normal",
  PRIORITY4 = "Baixa",
  PRIORITY5 = "Baixíssima",
  SHARING = "Partilhando",
  SHARING_ENABLE = "Partilhar",
  SHARING_DISABLE = "Não Partilhar",
  IGNORE = "Ignorar",
  
  IGNORED_PRIORITY_TITLE = "A prioridade seleccionada iria ser ignorada.",
  IGNORED_PRIORITY_FIX = "Aplicar a mesma prioridade aos objectivos sobrepostos.",
  IGNORED_PRIORITY_IGNORE = "Eu mesmo irei configurar as prioridades.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Resultados de Procura",
  NO_RESULTS = "Não existe nada!",
  CREATED_OBJ = "Criado: %1",
  REMOVED_OBJ = "Removido: %1",
  USER_OBJ = "Objectivo do Personagem: %h1",
  UNKNOWN_OBJ = "Não sei para onde deves ir para esse objectivo.",
  INACCESSIBLE_OBJ = "O QuestHelper não foi capaz de encontrar uma localização útil para %h1. Nós adicionamos uma localização \"quase impossível de encontrar\" à tua lista de objectivos. Se encontrares uma versão útil deste objecto, por favor envia os teus dados!",
  
  SEARCHING_STATE = "Procurando: %1",
  SEARCHING_LOCAL = "Local %1",
  SEARCHING_STATIC = "Estático %1",
  SEARCHING_ITEMS = "Itens",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zonas",
  SEARCHING_DONE = "Terminado!",
  
  -- Shared objectives.
  PEER_TURNIN = "Aguardar que %h1 entregue %h2.",
  PEER_LOCATION = "Ajudar %h1 a alcançar uma localização em %h2.",
  PEER_ITEM = "Ajudar %1 a obter %h2.",
  PEER_OTHER = "Acompanhar %1 com %h2.",
  
  PEER_NEWER = "%h1 está a usar uma nova versão de protocolo. Está na altura de actualizares o QuestHelper.",
  PEER_OLDER = "%h1 está a usar uma versão antiga de protocolo.",
  
  UNKNOWN_MESSAGE = "Tipo de mensagem desconhecido '%1' de '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Objectivos Ocultos",
  HIDDEN_NONE = "Não existem objectivos teus ocultos.",
  DEPENDS_ON_SINGLE = "Depende de '%1'.",
  DEPENDS_ON_COUNT = "Depende de %1 objectivos ocultos.",
  FILTERED_LEVEL = "Filtrado devido ao nível.",
  FILTERED_ZONE = "Filtrado devido à zona.",
  FILTERED_COMPLETE = "Filtrado pois está completado.",
  FILTERED_BLOCKED = "Filtrado devido a um objectivo anterior incompleto.",
  FILTERED_UNWATCHED = "Filtrado por não estar a ser Monitorizado pelo Quest Log",
  FILTERED_USER = "Pediste para esconder este objectivo.",
  FILTERED_UNKNOWN = "Não sei como se completa.",
  
  HIDDEN_SHOW = "Mostrar.",
  DISABLE_FILTER = "Desligar filtro: %1",
  FILTER_DONE = "terminado",
  FILTER_ZONE = "zona",
  FILTER_LEVEL = "nível",
  FILTER_BLOCKED = "bloqueado",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Tu tens %h(nova informação) sobre %h1, e %h(informação actualizada) sobre %h2.",
  NAG_SINGLE_NEW = "Tu tens %h(nova informação) em %h1.",
  NAG_ADDITIONAL = "Tu tens %h(informação adicional) sobre %h1.",
  NAG_POLLUTED = "A tua base de dados foi poluida por informação de um servidor privado ou de testes, e será apagada ao reiniciar.",
  
  NAG_NOT_NEW = "Não possuis nenhuma informação que ainda não exista na base de dados estática.",
  NAG_NEW = "Deverias considerar partilhar os teus dados, de modo a que outros deles podessem beneficiar.",
  NAG_INSTRUCTIONS = "Escreve %h(/qh submit) para instruções de como submeter os dados.",
  
  NAG_SINGLE_FP = "um mestre de voo",
  NAG_SINGLE_QUEST = "uma missão",
  NAG_SINGLE_ROUTE = "uma rota de voo",
  NAG_SINGLE_ITEM_OBJ = "um objectivo de item",
  NAG_SINGLE_OBJECT_OBJ = "um objectivo de objecto",
  NAG_SINGLE_MONSTER_OBJ = "um objectivo de monstro",
  NAG_SINGLE_EVENT_OBJ = "um objectivo de evento",
  NAG_SINGLE_REPUTATION_OBJ = "um objectivo de reputação",
  NAG_SINGLE_PLAYER_OBJ = "um objectivo do jogador",
  
  NAG_MULTIPLE_FP = "%1 mestres de voo",
  NAG_MULTIPLE_QUEST = "%1 missões",
  NAG_MULTIPLE_ROUTE = "%1 rotas de voo",
  NAG_MULTIPLE_ITEM_OBJ = "%1 objectivos de itens",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 objectivos de objectos",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 objectivos de monstros",
  NAG_MULTIPLE_EVENT_OBJ = "%1 objectivos de eventos",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 objectivos para reputação",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 objectivos de jogadores",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 progresso:",
  TRAVEL_ESTIMATE = "Tempo estimado de viagem:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visitar %h1 em caminho para:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Clique Esquerdo: %1 informação de rotas.",
  QH_BUTTON_TOOLTIP2 = "Clique Direito: Mostrar menu de Opções.",
  QH_BUTTON_SHOW = "Mostar",
  QH_BUTTON_HIDE = "Ocultar",

  MENU_CLOSE = "Fechar Menu",
  MENU_SETTINGS = "Opções",
  MENU_ENABLE = "Ligar",
  MENU_DISABLE = "Desligar",
  MENU_OBJECTIVE_TIPS = "%1 Dicas nos Objectivos",
  MENU_TRACKER_OPTIONS = "Monitor de Missões",
  MENU_QUEST_TRACKER = "%1 Monitor de Missões",
  MENU_TRACKER_LEVEL = "%1 Níveis das Missões",
  MENU_TRACKER_QCOLOUR = "%1 Cor da Dificuldade das Missões",
  MENU_TRACKER_OCOLOUR = "%1 Cor do Progresso nas Missões",
  MENU_TRACKER_SCALE = "Escala do Monitor",
  MENU_TRACKER_RESET = "Restaurar Posição",
  MENU_FLIGHT_TIMER = "%1 Tempo de Voo",
  MENU_ANT_TRAILS = "%1 Linhas Tracejadas",
  MENU_WAYPOINT_ARROW = "%1 Seta de Direcção",
  MENU_MAP_BUTTON = "%1 Botão no Mapa",
  MENU_ZONE_FILTER = "%1 Filtro de Zona",
  MENU_DONE_FILTER = "%1 Filtro de Termidadas",
  MENU_BLOCKED_FILTER = "%1 Filtro de Bloqueadas",
  MENU_WATCHED_FILTER = "%1 Filtros Vigiados",
  MENU_LEVEL_FILTER = "%1 Filtro de Nível",
  MENU_LEVEL_OFFSET = "Margem do Filtro de Nível",
  MENU_ICON_SCALE = "Escala dos Icones",
  MENU_FILTERS = "Filtros",
  MENU_PERFORMANCE = "Esforço ao Traçar Rotas",
  MENU_LOCALE = "Local",
  MENU_PARTY = "Grupo",
  MENU_PARTY_SHARE = "%1 Partilha de Objectivos",
  MENU_PARTY_SOLO = "%1 Ignorar Grupo",
  MENU_HELP = "Ajuda",
  MENU_HELP_SLASH = "Comandos de Barra",
  MENU_HELP_CHANGES = "Lista de Alterações",
  MENU_HELP_SUBMIT = "Submetendo Dados",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Monitorado pelo QuestHelper",
  TOOLTIP_QUEST = "Para a Missão %h1.",
  TOOLTIP_PURCHASE = "Adquirir %h1.",
  TOOLTIP_SLAY = "Matar para %h1.",
  TOOLTIP_LOOT = "Pilhar por %h1."
 }

