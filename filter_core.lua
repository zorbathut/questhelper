QuestHelper_File["filter_core.lua"] = "Development Version"
QuestHelper_Loadtime["filter_core.lua"] = GetTime()

function QH_MakeFilter(name, func, params)
  QuestHelper: Assert(params.friendly_reason)
  QuestHelper: Assert(params.friendly_name)
  return {
    Process = func,
    name = name,
    friendly_reason = params.friendly_reason,
    friendly_name = params.friendly_name,
  }
end
