-- Please see lang_enus.lua for reference.

QuestHelper_Translations.frFR =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Français",
  
  -- Messages used when starting.
  LOCALE_ERROR = "La langue de vos données sauvegardées ne correspond pas à la langue de votre client WoW.",
  ZONE_LAYOUT_ERROR = "Lancement refusé par crainte de corrompre vos données sauvegardées. "..
                      "Veuillez attendre la sortie d'un patch capable de prendre en charge la nouvelle zone.",
  DOWNGRADE_ERROR = "Vos données ne sont pas compatibles avec cette version de QuestHelper. "..
                    "Télécharger une version récente ou supprimer les variables sauvegardées.",
  HOME_NOT_KNOWN = "Vous n'avez pas d'auberge définie. Lors d'une prochaine visite à votre aubergiste; réinitialiser-là.",
  
  -- This text is only printed for the enUS client, don't worry about translating it.
  ALTERED_INDEX = "!!! QuestHelper_IndexLookup entry needs update: [%Q1] = {%2, %3, %4}",
  ALTERED_ZONE = "!!! QuestHelper_Zones entry needs update: [%1][%2] = %Q3 -- was %4",
  
  -- Route related text.
  ROUTES_CHANGED = "Les itinéraires de vol de votre personnage ont été modifiés.",
  HOME_CHANGED = "Votre auberge a été changée.",
  TALK_TO_FLIGHT_MASTER = "Parler au maître des vols local.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Merci.",
  WILL_RESET_PATH = "Réinitialisation des informations de route.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Langues disponibles:",
  LOCALE_CHANGED = "Langue changé en: %h1",
  LOCALE_UNKNOWN = "La langue %h1 est inconnue.",
  
  -- Words used for objectives.
  SLAY_VERB = "Tuer",
  ACQUIRE_VERB = "Obtenir",
  
  OBJECTIVE_REASON = "%1 %h2 pour la quête %h3.", -- %1 est un verbe, %2 est un nom (objet ou monstre)
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
  ENABLE = "Activée",
  DISABLE = "Désactivée",
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
  FILTERED_USER = "Vous avez demandé à caché cet objectif.",
  FILTERED_UNKNOWN = "Ne sais pas comment finaliser.",
  
  HIDDEN_SHOW = "Montrer.",
  DISABLE_FILTER = "Désactive le filtre: %1",
  FILTER_DONE = "fini",
  FILTER_ZONE = "zone",
  FILTER_LEVEL = "niveau",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_SINGLE = "1 %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %s2",
  
  NAG_MULTIPLE_NEW = "Vous avez des informations nouvelles pour %h1 et mises à jour pour %h2 %h(%s3).",
  NAG_SINGLE_NEW = "Vous avez des informations nouvelles pour %h1.",
  NAG_ADDITIONAL = "Vous avez des informations complémentaires pour %h1.",
  
  NAG_NOT_NEW = "Vous n'avez auncune information qui n'est pas déjà dans la base de données statique.",
  NAG_NEW = "Vous devez penser à partager vos données pour le bénéfice des autres joueurs.",
  
  NAG_FP = "maître des vols",
  NAG_QUEST = "quête",
  NAG_ROUTE = "plan de vol",
  NAG_ITEM_OBJ = "objectif d'item",
  NAG_OBJECT_OBJ = "objective d'objet",
  NAG_MONSTER_OBJ = "objectif de monstre",
  NAG_EVENT_OBJ = "objectif d'évènement",
  NAG_REPUTATION_OBJ = "objectif de réputation",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1 est en cours:",
  TRAVEL_ESTIMATE = "Temps de voyage estimé:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Visitez %h1 en route vers:"
 }
