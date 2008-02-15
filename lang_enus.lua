-- Note: This file is used as fallback for locales that don't exist.

-- If the client is using this locale, then strings from this table will always be used, regardless of
-- the locale selected for displayed text.
QuestHelper_ForcedTranslations.enUS = 
 {
 -- Must match the line in objective text of the quest log. Extracted from '???: x/y', to determine the name of the monster to slay.
  ["SLAIN_PATTERN"] = "(.*)%sslain$"
 }

QuestHelper_Translations.enUS =
 {
  ["LOCALE_ERROR"] = "The locale of your saved data doesn't match the locale of your WoW client.",
  ["ZONE_LAYOUT_ERROR"] = "I'm refusing to run, out of fear of corrupting your saved data. "..
                          "Please wait for a patch that will be able to handle the new zone layout.",
  ["DOWNGRADE_ERROR"] = "Your saved data isn't compatible with this version of QuestHelper. "..
                        "Use a new version, or delete your saved variables.",
  ["HOME_NOT_KNOWN"] = "Your home isn't known. When you get a chance, please talk to your innkeeper and reset it."
 }

QuestHelper_TranslationFunctions.enUS =
 {
  [""] = tostring -- We shall interpret arguments as strings by default.
 }
