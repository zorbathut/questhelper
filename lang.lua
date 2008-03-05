-- These tables will be filled in later by their specific files.
QuestHelper_ZoneTranslations = {}
QuestHelper_Translations = {}
QuestHelper_ForcedTranslations = {}
QuestHelper_TranslationFunctions = {}

local empty_table = {}

local trans_table, trans_table_force, trans_func, trans_func_fb

-- Sets the locale used by QuestHelper. It needn't match the game's locale.
function QHFormatSetLocale(loc)
  trans_table_force = QuestHelper_ForcedTranslations[GetLocale()] or empty_table
  trans_table_fb = QuestHelper_Translations["enUS"] or empty_table
  trans_table = QuestHelper_Translations[loc] or trans_table_fb
  trans_func, trans_func_fb = QuestHelper_TranslationFunctions[loc], QuestHelper_TranslationFunctions["enUS"]
  trans_func = trans_func or trans_func_fb
end

local sub_array = nil
local function doSub(op, index)
  local i = tonumber(index)
  if i then
    -- Pass the selected argument through a function and insert the result.
    return (trans_func[op] or trans_func_fb[op] or QuestHelper.nop)(sub_array[i]) or "[???]"
  end
  return op..index
end

local next_free = 1

local doTranslation = nil

local function doNest(op, text)
  next_free = next_free + 1
  sub_array[next_free] = doTranslation(string.sub(text, 2, -2))
  return string.format("%%%s%d", op, next_free)
end

doTranslation = function(text)
  local old_next_free = next_free
  text = string.gsub(string.gsub(text, "%%(%a*)(%b())", doNest), "%%(%a*)(%d*)", doSub)
  next_free = old_next_free
  return text
end

function QHFormatArray(text, array)
  if not trans_table then
    QHFormatSetLocale(GetLocale())
  end
  
  local old_array = sub_array -- Remember old value, so we can restore it incase this was called recursively.
  sub_array = array
  
  local old_next_free = next_free
  next_free = #array
  
  local trans = trans_table_force[text]  or trans_table[text]
  
  if not trans then
    trans = string.format("|cffff0000[%s|||r%s|cffff0000]|r", text, trans_table_fb[text] or "???")
  end
  
  text = doTranslation(trans)
  
  sub_array = old_array
  next_free = old_next_free
  
  return text
end

local arguments = {}

function QHFormat(text, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12)
  -- This isn't a vardiac function, because that would create a table to store the arguments in, and I'm trying to avoid
  -- creating any garbage here, by reusing the same table for the arguments. Although I'll admit that this isn't nearly
  -- as effecient. Or pretty. Or stable. Let the foot shooting begin.
  
  arguments[1] = a1   arguments[2]  =  a2   arguments[3]  =  a3   arguments[4]  =  a4
  arguments[5] = a5   arguments[6]  =  a6   arguments[7]  =  a7   arguments[8]  =  a8
  arguments[9] = a9   arguments[10] = a10   arguments[11] = a11   arguments[12] = a12
  
  return QHFormatArray(text, arguments)
end

-- Translates a string, without any substitutions.
function QHText(text)
  return QHFormatArray(text, empty_table)
end
