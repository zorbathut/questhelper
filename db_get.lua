QuestHelper_File["db_get.lua"] = "Development Version"
QuestHelper_Loadtime["db_get.lua"] = GetTime()

-- yoink
--[[
local QHDB_temp = QHDB
QHDB = nil
local QHDB = QHDB_temp]]
QuestHelper: Assert(#QHDB == 4)

local weak_v = { __mode = 'v' }
local weak_k = { __mode = 'k' }

local cache = {}

local frequencies = setmetatable({}, weak_k)

-- guhhh just want this to work
local freq_group = setmetatable({}, weak_k)
local freq_id = setmetatable({}, weak_k)

local function DBC_Get(group, id)
  if not cache[group] then return end
  return cache[group][id]
end

local function DBC_Put(group, id, item)
  if not cache[group] then cache[group] = setmetatable({}, weak_v) end
  QuestHelper: Assert(not cache[group][id])
  cache[group][id] = item
  
  --DB_how_many_are_used()
end

local function mark(tab, tomark)
  for k, v in pairs(tab) do
    if type(v) == "table" then
      mark(v, tomark)
    end
  end
  tab.__owner = tomark
end

local initted = false
function DB_Init()
  QuestHelper: Assert(not initted)
  for _, db in ipairs(QHDB) do
    for _, v in pairs(db) do
      --print("db", not not v.__dictionary, not not v.__tokens)
      if v.__dictionary and v.__tokens then
        local redictix = v.__dictionary
        if not redictix:find("\"") then redictix = redictix .. "\"" end
        if not redictix:find(",") then redictix = redictix .. "," end
        if not redictix:find("\\") then redictix = redictix .. "\\" end
        local tokens = loadstring("return {" .. QH_LZW_Decompress_Dicts_Arghhacky(v.__tokens, redictix) .. "}")()
        QuestHelper: Assert(tokens)
        
        local _, _, prep = QH_LZW_Prepare_Arghhacky(v.__dictionary, tokens)
        QuestHelper: Assert(prep)
        
        QuestHelper: Assert(type(prep) == "table")
        
        v.__tokens = prep
      end
    end
  end
  initted = true
end

function DB_Ready()
  return initted
end

function DB_GetItem(group, id, silent, register)
  QuestHelper: Assert(initted)

  QuestHelper: Assert(group, string.format("%s %s", tostring(group), tostring(id)))
  QuestHelper: Assert(id, string.format("%s %s", tostring(group), tostring(id)))
  local ite = DBC_Get(group, id)
  if not ite then
    if type(id) == "string" then QuestHelper: Assert(not id:match("__.*")) end
    
    --QuestHelper:TextOut(string.format("%s %d", group, id))
    
    for _, db in ipairs(QHDB) do
      --print(db, db[group], db[group] and db[group][id], type(group), type(id))
      if db[group] and db[group][id] then
        if not ite then ite = QuestHelper:CreateTable("db") end
        
        local srctab
        
        if type(db[group][id]) == "string" then
          QuestHelper: Assert(db[group].__tokens == nil or type(db[group].__tokens) == "table")
          srctab = loadstring("return {" .. QH_LZW_Decompress_Dicts_Prepared_Arghhacky(db[group][id], db[group].__dictionary, nil, db[group].__tokens) .. "}")()
        elseif type(db[group][id]) == "table" then
          srctab = db[group][id]
        else
          QuestHelper: Assert()
        end
        
        for k, v in pairs(srctab) do
          QuestHelper: Assert(not ite[k])
          ite[k] = v
        end
      end
    end
    --print("dbe", ite)
    
    if ite then
      mark(ite, ite)
      
      DBC_Put(group, id, ite)
      
      freq_group[ite] = group
      freq_id[ite] = id
    else
      if not silent then
        QuestHelper:TextOut(string.format("Tried to get %s/%s, failed", tostring(group), tostring(id)))
      end
    end
  end
  
  if ite then
    frequencies[ite] = (frequencies[ite] or 0) + (register and 1 or 1000000000) -- effectively infinity
  end
  
  return ite
end

local function incinerate(ite, crunchy)
  if not crunchy[ite] then
    crunchy[ite] = true
    
    for k, v in pairs(ite) do
      if type(k) == "table" then incinerate(k, crunchy) end
      if type(v) == "table" then incinerate(v, crunchy) end
    end
  end
end

function DB_ReleaseItem(ite)
  frequencies[ite] = frequencies[ite] - 1
  
  if frequencies[ite] == 0 then
    --print("incinerating", freq_group[ite], freq_id[ite])
    cache[freq_group[ite]][freq_id[ite]] = nil
    freq_group[ite] = nil
    freq_id[ite] = nil
    
    local incin = QuestHelper:CreateTable("incinerate")
    incinerate(ite, incin)
    for k, _ in pairs(incin) do
      QuestHelper:ReleaseTable(k)
    end -- burn baby burn
    QuestHelper:ReleaseTable(incin)
  end
end

function DB_ListItems(group)
  local tab = {}
  for _, db in ipairs(QHDB) do
    if db[group] then for k, _ in pairs(db[group]) do
      if type(k) ~= "string" or not k:match("__.*") then
        tab[k] = true
      end
    end end
  end
  
  local rv = {}
  for k, _ in pairs(tab) do
    table.insert(rv, k)
  end
  
  return rv
end

function DB_how_many_are_used()
  local count = 0
  for k, v in pairs(cache) do
    for k2, v2 in pairs(v) do
      count = count + 1
    end
  end
  print(count)
end

function DB_DumpItems()
  local dt = {}
  for k, v in pairs(freq_group) do
    dt[string.format("%s/%s", freq_group[k], tostring(freq_id[k]))] = true
  end
  return dt
end
