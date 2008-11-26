QuestHelper_File["collect_patterns.lua"] = "Development Version"

local patterns = {}

function MakePattern(label, newpat)
  if not newpat then newpat = ".*" end
  if not patterns[label] then patterns[label] = "^" .. string.gsub(_G[label], "%%s", newpat) .. "$" end
end

function QH_Collect_Patterns_Init(QHCData, API)
  API.Patterns = patterns
  API.Patterns_Register = MakePattern
end
