-- Please see enus.lua for reference.

QuestHelper_Translations.frFR =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Français",
  
  -- Messages used when starting.
  LOCALE_ERROR = "La langue de vos données sauvegardées ne correspond pas à la langue de votre client WoW. Pour utiliser QuestHelper vous devez soit remettre la langue que vous aviez avant, ou supprimer les données en tapant %h(/qh purge).",
  ZONE_LAYOUT_ERROR = "Lancement refusé par crainte de corrompre vos données sauvegardées. Veuillez attendre la sortie d'un patch capable de prendre en charge la nouvelle zone.",
  DOWNGRADE_ERROR = "Vos données ne sont pas compatibles avec cette version de QuestHelper. Téléchargez une nouvelle version, ou supprimez les variables sauvegardées.",
  HOME_NOT_KNOWN = "Vous n'avez pas de foyer défini. Lors d'une prochaine visite à votre aubergiste; réinitialisez-le.",
  PRIVATE_SERVER = "QuestHelper ne supporte pas les serveurs privés.",
  PLEASE_RESTART = "Erreur au lancement de QuestHelper. Veuillez redémarrer World of Warcraft et essayer encore.",
  NOT_UNZIPPED_CORRECTLY = "QuestHelper n'a pas été installé correctement. Nous recommandons d'utiliser le Curse Client ou 7zip pour l'installation. Assurez vous que les sous-dossiers sont extraits",
  PLEASE_DONATE = "%h(QuestHelper survit pour le moment grâce à vos dons !) Toute contribution sera appréciée, et quelques dollars par mois me permettront d'assurer les mises à jour et le bon fonctionnement. Entrez %h(/qh donate) pour plus d'informations. ",
  HOW_TO_CONFIGURE = "QuestHelper n'a pas encore une page de configuration fonctionelle, mais peut être configuré en tapant %h(/qh settings). L'aide est disponible en utilisant %h(/qh help).",
  TIME_TO_UPDATE = "Il est possible qu'une %h(nouvelle version de QuestHelper) soit disponible. Les nouvelles versions incluent généralement de nouvelles caractéristiques, de nouvelles bases de données de quêtes, et des corrections pour les bugs. Merci de mettre à jour!",
  
  -- Route related text.
  ROUTES_CHANGED = "Les itinéraires de vol de votre personnage ont été modifiés.",
  HOME_CHANGED = "Votre foyer a été changé.",
  TALK_TO_FLIGHT_MASTER = "Parler au maître de vol local.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Merci.",
  WILL_RESET_PATH = "Réinitialisation des informations de route.",
  UPDATING_ROUTE = "Route actualisée.",
  
  -- Special tracker text
  QH_LOADING = "Chargement de questHelper (%1%%)...",
  QUESTS_HIDDEN_1 = "Les quêtes peuvent êtres cachées",
  QUESTS_HIDDEN_2 = "(\"/qh hidden\" pour lister)",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Langues disponibles:",
  LOCALE_CHANGED = "Langue changée en: %h1",
  LOCALE_UNKNOWN = "La langue %h1 est inconnue.",
  
  -- Words used for objectives.
  SLAY_VERB = "Tuer",
  ACQUIRE_VERB = "Obtenir",
  
  OBJECTIVE_REASON = "%1 %h2 pour la quête %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 pour la quête %h2.",
  OBJECTIVE_REASON_TURNIN = "Valider la quête %h1.",
  OBJECTIVE_PURCHASE = "A acheter auprès de %h1.",
  OBJECTIVE_TALK = "Parler à %h1.",
  OBJECTIVE_SLAY = "Tuer %h1.",
  OBJECTIVE_LOOT = "Ramasser %h1.",
  
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
  SHARING_DISABLE = "Ne pas partager",
  IGNORE = "Ignore",
  
  IGNORED_PRIORITY_TITLE = "La priorité sélectionnée sera ignorée.",
  IGNORED_PRIORITY_FIX = "Appliquer la même priorité aux objectifs bloquant.",
  IGNORED_PRIORITY_IGNORE = "Je définirais les priorités moi-même.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Résultats de la recherche",
  NO_RESULTS = "Il n'y en a aucun!",
  CREATED_OBJ = "Création: %1",
  REMOVED_OBJ = "Supprimé: %1",
  USER_OBJ = "Objectif utilisateur: %h1",
  UNKNOWN_OBJ = "Destination inconnue pour cet objectif.",
  INACCESSIBLE_OBJ = "QuestHelper n'a pas été capable de trouver une destination pour %h1. Nous avons ajouté une destination impossible à rejoindre dans la liste d'objectifs. Si vous trouvez une version utile de cet objet, soumettez vos données! (%h(/qh submit))",
  
  SEARCHING_STATE = "Recherche: %1",
  SEARCHING_LOCAL = "Local %1",
  SEARCHING_STATIC = "Statique %1",
  SEARCHING_ITEMS = "Objets",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zones",
  SEARCHING_DONE = "Terminé !",
  
  -- Shared objectives.
  PEER_TURNIN = "Attendre %h1 pour valider %h2.",
  PEER_LOCATION = "Aider %h1 à rallier la position %h2.",
  PEER_ITEM = "Aider %1 à obtenir %h2.",
  PEER_OTHER = "Aider %1 à faire %h2.",
  
  PEER_NEWER = "%h1 utilise une nouvelle version. Pensez à faire une mise à jour.",
  PEER_OLDER = "%h1 utilise une ancienne version.",
  
  UNKNOWN_MESSAGE = "Type de message inconnu '%1' de '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Objectifs cachés",
  HIDDEN_NONE = "Il n'y a aucun objectif caché.",
  DEPENDS_ON_SINGLE = "Dépend de '%1'.",
  DEPENDS_ON_COUNT = "Dépend de %1 objectifs cachés.",
  FILTERED_LEVEL = "Filtré à cause du niveau.",
  FILTERED_ZONE = "Filtré à cause de la zone.",
  FILTERED_COMPLETE = "Filtré car terminé.",
  FILTERED_BLOCKED = "Filtré car dépend d'un objectif qui n'a pas été réalisé",
  FILTERED_UNWATCHED = "Filtré car l'objectif n'est pas suivi dans le journal de quêtes",
  FILTERED_USER = "Vous avez demandé à cacher cet objectif.",
  FILTERED_UNKNOWN = "Ne sais pas comment le terminer.",
  
  HIDDEN_SHOW = "Montrer.",
  DISABLE_FILTER = "Désactiver le filtre : %1",
  FILTER_DONE = "terminé",
  FILTER_ZONE = "zone",
  FILTER_LEVEL = "niveau",
  FILTER_BLOCKED = "bloqué",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_MULTIPLE_NEW = "Vous avez %h(des nouvelles informations) pour %h1 et %h(des mises à jour) pour %h2.",
  NAG_SINGLE_NEW = "Vous avez %h(une nouvelle information) sur %h1.",
  NAG_ADDITIONAL = "Vous avez %h(des informations complémentaires) pour %h1.",
  NAG_POLLUTED = "La base de donnée a été infectée par des données provenant d'un serveur privé ou de test, et sera remis à zéro lors du redémarrage.",
  
  NAG_NOT_NEW = "Vous n'avez aucune information qui n'est pas déjà dans la base de données statique.",
  NAG_NEW = "Vous devriez penser à partager vos données pour le bénéfice des autres joueurs.",
  NAG_INSTRUCTIONS = "Tapez %h(/qh submit) pour savoir comment soumettre des informations.",
  
  NAG_SINGLE_FP = "un maitre de vol",
  NAG_SINGLE_QUEST = "une quête",
  NAG_SINGLE_ROUTE = "un chemin de vol",
  NAG_SINGLE_ITEM_OBJ = "un objectif d'article",
  NAG_SINGLE_OBJECT_OBJ = "un objectif d'objet",
  NAG_SINGLE_MONSTER_OBJ = "un objectif de monstre",
  NAG_SINGLE_EVENT_OBJ = "un objectif d'évènement",
  NAG_SINGLE_REPUTATION_OBJ = "un objectif de réputation",
  NAG_SINGLE_PLAYER_OBJ = "un objectif de joueur",
  
  NAG_MULTIPLE_FP = "%1 maîtres de vol",
  NAG_MULTIPLE_QUEST = "%1 quêtes",
  NAG_MULTIPLE_ROUTE = "%1 chemins de vol",
  NAG_MULTIPLE_ITEM_OBJ = "%1 objectifs d'objet",
  NAG_MULTIPLE_OBJECT_OBJ = "%1 objectifs d'article",
  NAG_MULTIPLE_MONSTER_OBJ = "%1 objectifs de monstre",
  NAG_MULTIPLE_EVENT_OBJ = "%1 objectifs d'évènement",
  NAG_MULTIPLE_REPUTATION_OBJ = "%1 objectifs de réputation",
  NAG_MULTIPLE_PLAYER_OBJ = "%1 objectifs de joueur",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 est en cours:",
  TRAVEL_ESTIMATE = "Temps de voyage estimé:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visiter %h1 sur la route de:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Clic Gauche: %1 information de route.",
  QH_BUTTON_TOOLTIP2 = "Clic Droit : Montrer le menu d'option.",
  QH_BUTTON_SHOW = "Montrer",
  QH_BUTTON_HIDE = "Cacher",

  MENU_CLOSE = "Fermer le menu",
  MENU_SETTINGS = "Options",
  MENU_ENABLE = "Activer",
  MENU_DISABLE = "Désactiver",
  MENU_OBJECTIVE_TIPS = "%1 les bulles d'aide pour les objectifs",
  MENU_TRACKER_OPTIONS = "Liste de quêtes",
  MENU_QUEST_TRACKER = "%1 la liste de quête",
  MENU_TRACKER_LEVEL = "%1 l'affichage des niveaux de quête",
  MENU_TRACKER_QCOLOUR = "%1 la colorisation des quêtes selon la difficulté",
  MENU_TRACKER_OCOLOUR = "%1 la colorisation des objectifs",
  MENU_TRACKER_SCALE = "Échelle de la liste de quêtes",
  MENU_TRACKER_RESET = "Réinitialiser la position de la liste de quêtes",
  MENU_FLIGHT_TIMER = "%1 Temps de vol",
  MENU_ANT_TRAILS = "%1 les chemins pointillés",
  MENU_WAYPOINT_ARROW = "%1 le compas",
  MENU_MAP_BUTTON = "%1 le bouton sur la carte",
  MENU_ZONE_FILTER = "%1 le filtre de zone",
  MENU_DONE_FILTER = "%1 le filtrage des quêtes terminée",
  MENU_BLOCKED_FILTER = "%1 le filtrage des quêtes bloquées",
  MENU_WATCHED_FILTER = "%1 le filtrage des quêtes suivies",
  MENU_LEVEL_FILTER = "%1 le filtrage par niveau",
  MENU_LEVEL_OFFSET = "Limite pour le filtre de niveau",
  MENU_ICON_SCALE = "Échelle des icônes",
  MENU_FILTERS = "Filtres",
  MENU_PERFORMANCE = "Charge attribuée au calcul des routes",
  MENU_LOCALE = "Langue",
  MENU_PARTY = "Groupe",
  MENU_PARTY_SHARE = "%1 le partage d'objectif",
  MENU_PARTY_SOLO = "%1 la prise en compte du groupe",
  MENU_HELP = "Aide",
  MENU_HELP_SLASH = "Commandes Slash",
  MENU_HELP_CHANGES = "Journal des modifications",
  MENU_HELP_SUBMIT = "Envoi de données",
  
  -- Added to tooltips of items/npcs that are watched by QuestHelper but don't have any progress information.
  -- Otherwise, the PEER_PROGRESS text is added to the tooltip instead.
  TOOLTIP_WATCHED = "Suivi par QuestHelper",
  TOOLTIP_QUEST = "Pour la quête %h1",
  TOOLTIP_PURCHASE = "Acheter %h1",
  TOOLTIP_SLAY = "A tuer pour %h1",
  TOOLTIP_LOOT = "Ramasser %h1"
 }

