QuestHelper_Translations.duNL =
 {
  -- Displayed by locale chooser.
  LOCALE_NAME = "Nederlands",
  
  -- Messages used when starting.
  LOCALE_ERROR = "Sorry, je locale data komt niet overheen met je World of warcraft client.",
  ZONE_LAYOUT_ERROR = "Ik kan niet opstarten, om niet je saved data kapot te maken. "..
                      "Wacht alsjeblieft voor een patch die wel deze layout aankan.",
  DOWNGRADE_ERROR = "Je opgeslaagde data is niet bruikbaar met deze versie van Questhelper. "..
                    "Gebruik de nieuwe versie of verwijder je saved variables.",
  HOME_NOT_KNOWN = "Je verblijfsplek is niet bekend, praat met een innkeeper, als je de kans hebt, om je verblijfsplaats te resetten.",
  
  -- This text is only printed for the enUS client, don't worry about translating it.
  ALTERED_INDEX = "!!! QuestHelper_IndexLookup entry needs update: [%Q1] = {%2, %3, %4}",
  ALTERED_ZONE = "!!! QuestHelper_Zones entry needs update: [%1][%2] = %Q3 -- was %4",
  
  -- Route related text.
  ROUTES_CHANGED = "De flight routes, voor dit personage, zijn verouderd.",
  HOME_CHANGED = "Je verblijfsplek is veranderd.",
  TALK_TO_FLIGHT_MASTER = "Praat alsjeblieft met de lokale flight master.",
  TALK_TO_FLIGHT_MASTER_COMPLETE = "Bedankt.",
  WILL_RESET_PATH = "Flight routes zijn gereset.",
  UPDATING_ROUTE = "Flight routes zijn vernieuwd.",
  
  -- Locale switcher.
  LOCALE_LIST_BEGIN = "Beschikbare talen:",
  LOCALE_CHANGED = "Taal veranderd in: %h1",
  LOCALE_UNKNOWN = "De taal %h1 is onbekend.",
  
  -- Words used for objectives.
  SLAY_VERB = "Dood",
  ACQUIRE_VERB = "Vind",
  
  OBJECTIVE_REASON = "%1 %h2 for quest %h3.", -- %1 is a verb, %2 is a noun (item or monster)
  OBJECTIVE_REASON_FALLBACK = "%h1 for quest %h2.",
  OBJECTIVE_REASON_TURNIN = "Quest inleveren %h1.",
  OBJECTIVE_PURCHASE = "Koop van %h1.",
  OBJECTIVE_TALK = "Praat met %h1.",
  OBJECTIVE_SLAY = "Vermoord %h1.",
  OBJECTIVE_LOOT = "Loot %h1.",
  
  ZONE_BORDER = "%1/%2 border",
  
  -- Stuff used in objective menus.
  PRIORITY = "Prioriteit",
  PRIORITY1 = "Hoogste",
  PRIORITY2 = "Hoog",
  PRIORITY3 = "Normaal",
  PRIORITY4 = "Laag",
  PRIORITY5 = "Laagste",
  SHARING = "Delen",
  ENABLE = "Aanzetten",
  DISABLE = "Uitzetten",
  IGNORE = "Negeren",
  
  IGNORED_PRIORITY_TITLE = "De geselecteerde prioriteit zal worden genegeerd.",
  IGNORED_PRIORITY_FIX = "Apply same priority to the blocking objectives.",
  IGNORED_PRIORITY_IGNORE = "Ik zet zelf wel de prioriteiten.",
  
  -- Custom objectives.
  RESULTS_TITLE = "Zoek resultaten",
  NO_RESULTS = "Sorry, geen resultaten gevonden!",
  CREATED_OBJ = "Gemaakt: %1",
  REMOVED_OBJ = "Verwijderd: %1",
  USER_OBJ = "Gebruikers Objective: %h1",
  UNKNOWN_OBJ = "Geen idee waar je naar toe moet..., sorry.",
  
  SEARCHING_STATE = "Aan het zoeken: %1",
  SEARCHING_LOCAL = "Local %1",
  SEARCHING_STATIC = "Static %1",
  SEARCHING_ITEMS = "Items",
  SEARCHING_NPCS = "NPCs",
  SEARCHING_ZONES = "Zones",
  SEARCHING_DONE = "Klaar!",
  
  -- Shared objectives.
  PEER_TURNIN = "Wacht op %h1 om %h2 in te leveren.",
  PEER_LOCATION = "Help %h1 reach a location in %h2.",
  PEER_ITEM = "Help %1 om %h2 te krijgen.",
  PEER_OTHER = "Help %1 met %h2.",
  
  PEER_NEWER = "%h1 gebruikt een nieuwere protocol versie, het is misschien handig om te upgraden.",
  PEER_OLDER = "%h1 gebruikt een oudere protocol versie.",
  
  UNKNOWN_MESSAGE = "Unknown message type '%1' from '%2'.",
  
  -- Hidden objectives.
  HIDDEN_TITLE = "Verborgen doelen",
  HIDDEN_NONE = "Er zijn geen doelen verborgen voor je.",
  DEPENDS_ON_SINGLE = "Hangt af van '%1'.",
  DEPENDS_ON_COUNT = "Hangt af van %1 verborgen doel.",
  FILTERED_LEVEL = "Gefilterd voor je level.",
  FILTERED_ZONE = "Gefilterd voor je zone.",
  FILTERED_COMPLETE = "Gefilterd omdat je het al voltooid heb.",
  FILTERED_USER = "Je vroeg of dit doel verborgen kon zijn.",
  FILTERED_UNKNOWN = "Geen idee hoe ik dit moet volooien.",
  
  HIDDEN_SHOW = "Laat zien.",
  DISABLE_FILTER = "Zet filter: %1 uit.",
  FILTER_DONE = "klaar",
  FILTER_ZONE = "zone",
  FILTER_LEVEL = "level",
  
  -- Nagging. (This is incomplete, only translating strings for the non-verbose version of the nag command that appears at startup.)
  NAG_SINGLE = "1 %2", -- %1 == count (will be 1), %2 == what
  NAG_PLURAL = "%1 %s2",
  
  NAG_MULTIPLE_NEW = "Je hebt informatie voor %h1 nieuw en %h2 geupdated %h(%s3).",
  NAG_SINGLE_NEW = "Je hebt nieuwe informatie voor %h1.",
  NAG_ADDITIONAL = "Je hebt meer informatie voor %h1.",
  
  NAG_NOT_NEW = "Je hebt (nog) geen informatie in de static database.",
  NAG_NEW = "Het zou sociaal zijn om je informatie te delen, zodat anderen er ook van kunnen profiteren.",
  
  NAG_FP = "flight master",
  NAG_QUEST = "quest",
  NAG_ROUTE = "flight route",
  NAG_ITEM_OBJ = "item objective",
  NAG_OBJECT_OBJ = "object objective",
  NAG_MONSTER_OBJ = "monster objective",
  NAG_EVENT_OBJ = "event objective",
  NAG_REPUTATION_OBJ = "reputation objective",
  
  -- Stuff used by dodads.
  PEER_PROGRESS = "%1's voortgang:",
  TRAVEL_ESTIMATE = "Geschatte vlieg tijd:",
  TRAVEL_ESTIMATE_VALUE = "%t1",
  WAYPOINT_REASON = "Bezoek %h1 en route to:",

  -- QuestHelper Map Button
  QH_BUTTON_TEXT = "QuestHelper",
  QH_BUTTON_TOOLTIP1 = "Linksklik: %1 route informatie.",
  QH_BUTTON_SHOW = "Laat zien",
  QH_BUTTON_HIDE = "Verberg",
 }
