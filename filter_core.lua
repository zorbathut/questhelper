QuestHelper_File["filter_core.lua"] = "Development Version"
QuestHelper_Loadtime["filter_core.lua"] = GetTime()

function QH_MakeFilter(func)
  return {
    Process = func
  }
end
