-- Please see lang_enus.lua for reference.

QuestHelper_Translations["frFR"] =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Français",
  
  -- Messages used when starting.
  LOCALE_ERROR = "La langue de vos données sauvegardées ne correspond pas à la langue de votre client WoW.",
  ZONE_LAYOUT_ERROR = "Lancement refusé par crainte de corrompre vos données sauvegardées. Veuillez attendre la sortie d'un patch capable de prendre en charge la nouvelle zone.",
  DOWNGRADE_ERROR = "Vos données ne sont pas compatibles avec cette version de QuestHelper. Télécharger une version récente ou supprimer les variables sauvegardées.",
  HOME_NOT_KNOWN = "Vous n'avez pas d'auberge définie. Lors d'une prochaine visite à votre aubergiste; réinitialiser-là.",
  
  -- Route related text.
  ROUTES_CHANGED = "Les itinéraires de vol de votre personnage ont été modifiés.",
  HOME_CHANGED = "Votre auberge a été changée.",
  TALK_TO_FLIGHT_MASTER = "Parler au maître de vol local.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Merci.",
  WILL_RESET_PATH = "Réinitialisation des informations de route.",
  UPDATING_ROUTE = "Route actualisée",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Langues disponibles:",
  LOCALE_CHANGED = "Langue changé en: %h1",
  LOCALE_UNKNOWN = "La langue %h1 est inconnue.",
  
  -- Words used for objectives.
  SLAY_VERB = "Tuer",
  ACQUIRE_VERB = "Obtenir",
  
  OBJECTIVE_REASON = "%1 %h2 pour la quête %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 pour la quête %h2.",
  OBJECTIVE_REASON_TURNIN = "Poursuivre avec la quête %h1.",
  OBJECTIVE_PURCHASE = "A acheter auprès de %h1.",
  OBJECTIVE_TALK = "Parler à %h1.",
  OBJECTIVE_SLAY = "Tuez %h1.",
  OBJECTIVE_LOOT = "Loot %h1.",
  
  ZONE_BORDER = "%1/%2 bordure",
  
  -- Stuff used in objective menus.
  PRIORITY = "Priorité",
  PRIORITY1 = "La plus haute",
  PRIORITY2 = "Haute",
  PRIORITY3 = "Normale",
  PRIORITY4 = "Basse",
  PRIORITY5 = "La plus basse",
  SHARING = "Partage",
  SHARING_ENABLE = "Partager",
  SHARING_DISABLE = "Ne pas Partager",
  IGNORE = "Ignore",
  
  IGNORED_PRIORITY_TITLE = "La priorité sélectionnée sera ignorée.",
  IGNORED_PRIORITY_FIX = "Applique la même priorité au objectifs bloquant.",
  IGNORED_PRIORITY_IGNORE = "Je définirais les priorités moi-même.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Résultats de la recherche",
  NO_RESULTS = "Il n'y en a aucun!",
  CREATED_OBJ = "Créé: %1",
  REMOVED_OBJ = "Supprimé: %1",
  USER_OBJ = "Objectifs utilisateur: %h1",
  UNKNOWN_OBJ = "Destination inconnue pour cet objectif.",
  
  SEARCHING_STATE = "Recherche: %1",
  SEARCHING_LOCAL = "Local %1",
  SEARCHING_STATIC = "Statique %1",
  SEARCHING_ITEMS = "Objets",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zones",
  SEARCHING_DONE = "Ok!",
  
  -- Shared objectives.
  PEER_TURNIN = "Attendez pour %h1 pour poursuivre avec %h2.",
  PEER_LOCATION = "Aider %h1 à rallier la position %h2.",
  PEER_ITEM = "Aider %1 à obtenir %h2.",
  PEER_OTHER = "Assister %1 avec %h2.",
  
  PEER_NEWER = "%h1 utilise une nouvelle version. Penser à faire une mise à jour.",
  PEER_OLDER = "%h1 utilise une ancienne version.",
  
  UNKNOWN_MESSAGE = "Type de message inconnu '%1' de '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Objectifs cachés",
  HIDDEN_NONE = "Il n'y a aucun objectifs cachés par vous.",
  DEPENDS_ON_SINGLE = "Dépends de '%1'.",
  DEPENDS_ON_COUNT = "Dépends de %1 objectifs cachés.",
  FILTERED_LEVEL = "Filtré a cause du niveau.",
  FILTERED_ZONE = "Filtré à cquse de la zone.",
  FILTERED_COMPLETE = "Filtré car complété.",
  FILTERED_BLOCKED = "Filtré car un objectif précédent n'a pas été complété",
  FILTERED_USER = "Vous avez demandé à caché cet objectif.",
  FILTERED_UNKNOWN = "Ne sais pas comment finaliser.",
  
  HIDDEN_SHOW = "Montrer.",
  DISABLE_FILTER = "Désactive le filtre: %1",
  FILTER_DONE = "fini",
  FILTER_ZONE = "zone",
  FILTER_LEVEL = "niveau",
  FILTER_BLOCKED = "bloqué",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Vous avez des informations nouvelles pour %h1 et mises à jour pour %h2 %h(%s3).",
  NAG_SINGLE_NEW = "Vous avez des informations nouvelles pour %h1.",
  NAG_ADDITIONAL = "Vous avez des informations complémentaires pour %h1.",
  
  NAG_NOT_NEW = "Vous n'avez auncune information qui n'est pas déjà dans la base de données statique.",
  NAG_NEW = "Vous devez penser à partager vos données pour le bénéfice des autres joueurs.",
  NAG_INSTRUCTIONS = nil,
  
  NAG_SINGLE_FP = "Un maitre de vol",
  NAG_SINGLE_QUEST = "une quete",
  NAG_SINGLE_ROUTE = "Chemin de vol",
  NAG_SINGLE_ITEM_OBJ = "Objectif d'article",
  NAG_SINGLE_OBJECT_OBJ = "Objectif d'objet",
  NAG_SINGLE_MONSTER_OBJ = "Objectif de monstre",
  NAG_SINGLE_EVENT_OBJ = "Objectif d'évènement",
  NAG_SINGLE_REPUTATION_OBJ = "Objectif de réputation",
  
  NAG_MULTIPLE_FP = "%1 maitres de vol",
  NAG_MULTIPLE_QUEST = "%1 quetes",
  NAG_MULTIPLE_ROUTE = nil,
  NAG_MULTIPLE_ITEM_OBJ = nil,
  NAG_MULTIPLE_OBJECT_OBJ = nil,
  NAG_MULTIPLE_MONSTER_OBJ = nil,
  NAG_MULTIPLE_EVENT_OBJ = nil,
  NAG_MULTIPLE_REPUTATION_OBJ = nil,
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 est en cours:",
  TRAVEL_ESTIMATE = "Temps de voyage estimé:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visitez %h1 en route vers:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Clique gauche: %1 information de route",
  QH_BUTTON_TOOLTIP2 = "Clique Droit : Montrer le menu d'option",
  QH_BUTTON_SHOW = "Montrer",
  QH_BUTTON_HIDE = "Cacher",

  MENU_CLOSE = "Fermer le Menu",
  MENU_SETTINGS = "Options",
  MENU_ENABLE = "Activer",
  MENU_DISABLE = "Desactiver",
  MENU_OBJECTIVE_TIPS = nil,
  MENU_TRACKER_OPTIONS = nil,
  MENU_QUEST_TRACKER = "%1 Suivi de Quête",
  MENU_TRACKER_LEVEL = "%1 Niveaux de Quête",
  MENU_TRACKER_QCOLOUR = "%1 Couleurs de difficulté des quêtes",
  MENU_TRACKER_OCOLOUR = "%1 Couleurs des Objectifs en Cours",
  MENU_TRACKER_SCALE = nil,
  MENU_TRACKER_RESET = "Reset position",
  MENU_FLIGHT_TIMER = "%1 Temps de vol",
  MENU_ANT_TRAILS = nil,
  MENU_WAYPOINT_ARROW = nil,
  MENU_MAP_BUTTON = "%1 Bouton de la Carte",
  MENU_ZONE_FILTER = nil,
  MENU_DONE_FILTER = "%1 Filtre effectué",
  MENU_BLOCKED_FILTER = "%1 Filtre Bloqué",
  MENU_LEVEL_FILTER = "%1 Filtre de Niveau",
  MENU_LEVEL_OFFSET = nil,
  MENU_ICON_SCALE = "Position d'iconnes",
  MENU_FILTERS = "Filtres",
  MENU_PERFORMANCE = nil,
  MENU_LOCALE = "Langue",
  MENU_PARTY = "Groupe",
  MENU_PARTY_SHARE = "%1 Partage d'Objectif",
  MENU_PARTY_SOLO = "%1 Ignorer le Groupe",
  MENU_HELP = "Aide",
  MENU_HELP_SLASH = "Commandes Slash",
  MENU_HELP_CHANGES = "Changer les log",
  MENU_HELP_SUBMIT = "Envoi de données",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Vu par QuestHelper",
  TOOLTIP_QUEST = "Pour la quete %h1",
  TOOLTIP_PURCHASE = "Acheter %h1",
  TOOLTIP_SLAY = "Tuer pour %h1",
  TOOLTIP_LOOT = "Butin pour %h1"
 }

