-- This next bit of stuff is for fuzzy string comarisons.

local row, prow = {}, {}

local difftable = {}

for i = 65,90 do
  local a = {}
  difftable[i-64] = a
  for j = 65,90 do
    a[j-64] = i==j and 0 or 1
  end
end

local function setgroup(a, w)
  for i = 1,string.len(a)-1 do
    for j = i+1,string.len(a) do
      local c1, c2 = string.byte(a,i)-64, string.byte(a,j)-64
      
      difftable[c1][c2] = math.min(w, difftable[c1][c2])
      difftable[c2][c1] = math.min(w, difftable[c2][c1])
    end
  end
end

-- Characters that sound similar. At least in my opinion.
setgroup("BCDFGHJKLMNPQRSTVWXZ", 0.9)
setgroup("AEIOUY", 0.6)
setgroup("TD", 0.6)
setgroup("CKQ", 0.4)
setgroup("MN", 0.4)
setgroup("EIY", 0.3)
setgroup("UO", 0.2)
setgroup("SZ", 0.6)

local function diffness(a, b)
  if a >= 65 and a <=90 then
    if b >= 65 and b <= 90 then
      return difftable[a-64][b-64]
    else
      return 1
    end
  elseif b >= 65 and b <= 90 then
    return 1
  else
    return 0
  end
end

local function fuzzyCompare(a, b)
  local m, n = string.len(a), string.len(b)
  
  if n == 0 or m == 0 then
    return n == m and 0 or 1
  end
  
  for j = 1,n+1 do
    row[j] = j-1
  end
  
  for i = 1,m do
    row, prow = prow, row
    row[1] = i
    
    for j = 1,n do
      row[j+1] = math.min(prow[j+1]+1, row[j]+.4, prow[j]+diffness(string.byte(a,i), string.byte(b,j)))
    end
  end
  
  return row[n+1]/math.max(n,m)
end

-- Okay, addon related stuff here.

local function locationRead(command)
  -- string.find(command, "^%s*([^%d%.]+)([%d%.]+)%s+,?([%d%.]+)%s+$")
  local _, _, region, x, y = string.find(command, "^%s*([^%d%.]-)%s*([%d%.]+)%s*[,;:]?%s*([%d%.]+)%s*$")
  
  if region and x and y then
    x, y = tonumber(x), tonumber(y)
    if x and y then
      if region == "" then
        return "loc", string.format("%d,%d,%.3f,%.3f", QuestHelper.c, QuestHelper.z, x/100, y/100), 1
      else
        local bc, bz, bn, score
        
        for c=1,3 do
          local z = 1
          while true do
            local zone_name = select(z,GetMapZones(c))
            if zone_name then
              s = fuzzyCompare(region, string.upper(zone_name))
              if not score or s < score then
                bc, bz, bn, score = c, z, zone_name, s
              end
              z = z + 1
            else
              break
            end
          end
        end
        
        if bc and bz then
          return "loc", string.format("%d,%d,%.3f,%.3f", bc, bz, x/100, y/100), score
        end
      end
    end
  end
end

local function npcRead(command)
  local name, score
  local list = QuestHelper_Objectives["monster"]
  if list then for n in pairs(list) do
    local s = fuzzyCompare(command, string.upper(n))
    if not score or s < score then
      name, score = n, s
    end
  end end
  
  list = QuestHelper_StaticData[QuestHelper.locale].objective
  list = list and list.monster
  if list then for n in pairs(list) do
    local s = fuzzyCompare(command, string.upper(n))
    if not score or s < score then
      name, score = n, s
    end
  end end
  
  if score then
    return "monster", name, score
  end
end

local function itemRead(command)
  local name, score
  local list = QuestHelper_Objectives["item"]
  if list then for n in pairs(list) do
    local s = fuzzyCompare(command, string.upper(n))
    if not score or s < score then
      name, score = n, s
    end
  end end
  
  list = QuestHelper_StaticData[QuestHelper.locale].objective
  list = list and list.item
  if list then for n in pairs(list) do
    local s = fuzzyCompare(command, string.upper(n))
    if not score or s < score then
      name, score = n, s
    end
  end end
  
  if score then
    return "item", name, score
  end
end

local function improve(category, what, score, new_category, new_what, new_score)
  if new_score and (not score or new_score < score) then
    return new_category, new_what, new_score
  else
    return category, what, score
  end
end

local function findObjective(command_string)
  command_string = string.upper(command_string)
  local _, _, command, argument = string.find(command_string, "^%s*([^%s]-)%s+(.-)%s*$")
  if command and argument then
    if command == "ITEM" then
      return itemRead(argument)
    elseif command == "NPC" or command == "MONSTER" then
      return npcRead(argument)
    elseif command == "LOCATION" or command == "LOC" then
      return locationRead(argument)
    end
  end
  
  local cat, what, s = improve(nil, nil, nil, locationRead(command_string))
  cat, what, s = improve(cat, what, s, npcRead(command_string))
  return improve(cat, what, s, itemRead(command_string))
end

local function slashHelper(command_string)
  local cat, what = findObjective(command_string)
  
  if cat and what then
    local objective = QuestHelper:GetObjective(cat, what)
    
    if QuestHelper.user_objectives[objective] then
      QuestHelper:TextOut("Removed: "..QuestHelper.user_objectives[objective])
      QuestHelper:RemoveObjectiveWatch(objective, QuestHelper.user_objectives[objective])
      QuestHelper.user_objectives[objective] = nil
      return
    elseif objective:Known() then
      local name
      if cat == "loc" then
        local _, _, c, z, x, y = string.find(what, "^(%d+),(%d+),([%d%.]+),([%d%.]+)$")
        name = "User Objective: "..QuestHelper:HighlightText(select(z,GetMapZones(c))).."/"..QuestHelper:HighlightText(x*100)..","..QuestHelper:HighlightText(y*100)
      else
        name = "User Objective: "..QuestHelper:HighlightText(cat).."/"..QuestHelper:HighlightText(what)
      end
      
      QuestHelper.user_objectives[objective] = name
      QuestHelper:AddObjectiveWatch(objective, name)
      
      QuestHelper:TextOut("Created: "..name)
      return
    else
      QuestHelper:TextOut("I don't know how to do that, yet.")
      return
    end
  end
  
  QuestHelper:TextOut("I don't know what you want.")
end

SLASH_QuestHelper1 = "/qh"
SLASH_QuestHelper2 = "/find"

SlashCmdList["QuestHelper"] = slashHelper
