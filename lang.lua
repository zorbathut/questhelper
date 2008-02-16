-- These tables will be filled in later by their specific files.
QuestHelper_Translations = {}
QuestHelper_ForcedTranslations = {}
QuestHelper_TranslationFunctions = {}

local empty_table = {}

local function nop() -- A dummy function that does nothing, used by QHFormatArray
  return nil -- By returning nil, doSub will instead insert the string [???].
end

local trans_table, transt_table_force, trans_func, trans_func_fb

-- Sets the locale used by QuestHelper. It needn't match the game's locale.
function QHFormatSetLocale(loc)
  trans_table_force = QuestHelper_ForcedTranslations[GetLocale()] or empty_table
  trans_table_fb = QuestHelper_Translations["enUS"]
  trans_table = QuestHelper_Translations[loc] or transt_table_fb
  trans_func, trans_func_fb = QuestHelper_TranslationFunctions[locale], QuestHelper_TranslationFunctions["enUS"]
  trans_func = trans_func or trans_func_fb
end

local sub_array = nil
local function doSub(op, index)
  local i = tonumber(index)
  if i then
    -- Pass the selected argument through a function and insert the result.
    return (trans_func[op] or trans_func_fb[op] or nop)(sub_array[i]) or "[???]"
  end
  return op..index
end

function QHFormatArray(text, array)
  if not trans_table then
    QHFormatSetLocale(GetLocale())
  end
  
  sub_array = array
  
  text = string.gsub(trans_table_force[text] or trans_table[text] or trans_table_fb[text] or text, "%%([^%d]*)(%d*)", doSub)
  
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
