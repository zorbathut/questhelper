-- These tables will be filled in later by their specific files.
QuestHelper_Translations = {}
QuestHelper_TranslationFunctions = {}

local empty_table = {}

local function nop() -- A dummy function that does nothing, used by QHFormatArray
  return nil
end

local trans_table, trans_func, trans_func_fb

-- Sets the locale used by QuestHelper. It needn't match the game's locale.
function QHFormatSetLocale(loc)
  trans_table = QuestHelper_Translations[loc] or QuestHelper_Translations["enUS"]
  trans_func, trans_func_fb = QuestHelper_TranslationFunctions[locale], QuestHelper_TranslationFunctions["enUS"]
  trans_func = trans_func or trans_func_fb
end

function QHFormatArray(text, array)
  if not trans_table then
    QHFormatSetLocale(GetLocale())
  end
  
  text = string.gsub(trans_table[text] or text, "%%([^%d]*)(%d*)", function (op, index)
    local i = tonumber(index)
    if i then
      -- Pass the selected argument through a function and insert the result.
      return (trans_func[op] or trans_func_fb[op] or nop)(array[i]) or "[???]"
    end
    return op..index
  end)
  
  return text
end

function QHFormat(text, ...)
  -- This unfortunately creates a new table every time it's called, but there doesn't seem to be a way around that.
  -- So, try to have this invoked as little as possible; call it once and cache the result or something.
  return QHFormatArray(text, arg)
end

-- Translates a string, without any substitutions.
function QHText(text)
  return QHFormatArray(text, empty_table)
end
