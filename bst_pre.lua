--[[

-- Crazy profiling madness
-- sed -i s/{/QH_RegisterTable{/g `ls | grep lua | grep -v static`

QHT_Types = setmetatable({}, {__mode="k"})

function QH_RegisterTable(tab, tag)
  assert(not QHT_Types[tab])
  QHT_Types[tab] = tag or string.gsub(debugstack(2, 1, 1), "\n.*", "")
  return tab
end
function QH_CTprint(sum)
  local typ = {}
  for k, v in pairs(sum) do
    table.insert(typ, {k = k, v = v})
  end
  
  table.sort(typ, function(a, b) return a.v < b.v end)
  
  for _, v in pairs(typ) do
    print(v.v, v.k)
  end
end
function QH_CTacu()
  local sum = {}
  for k, v in pairs(QHT_Types) do
    sum[v] = (sum[v] or 0) + 1
  end
  
  return sum
end

function QH_CheckTables()
  local before = QH_CTacu()
  collectgarbage("collect")
  local after = QH_CTacu()
  
  local sum = {}
  for k, v in pairs(before) do sum[k] = (before[k] or 0) - (after[k] or 0) end
  for k, v in pairs(after) do sum[k] = (before[k] or 0) - (after[k] or 0) end
  QH_CTprint(sum)
end

]]

QuestHelper_File = {}
QuestHelper_Loadtime = {}
QuestHelper_File["bst_pre.lua"] = "Development Version"
QuestHelper_Loadtime["bst_pre.lua"] = GetTime()
