QuestHelper_File["collect_merger.lua"] = "Development Version"


local function Add(self, data)
  table.insert(self, data)
  for i = #self - 1, 1, -1 do
    if string.len(self[i]) > string.len(self[i + 1]) then break end
    self[i] = self[i] .. table.remove(self, i + 1)
  end
end
local function Finish(self, data)
  for i = #self - 1, 1, -1 do
    self[i] = self[i] .. table.remove(self)
  end
  return self[1] or ""
end

function QH_Collect_Merger_Init(_, API)
  API.Utility_Merger = {Add = Add, Finish = Finish}
end
