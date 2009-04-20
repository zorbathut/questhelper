QuestHelper_File["db_get.lua"] = "Development Version"
QuestHelper_Loadtime["db_get.lua"] = GetTime()

-- yoink
--[[
local QHDB_temp = QHDB
QHDB = nil
local QHDB = QHDB_temp]]
QuestHelper: Assert(#QHDB == 4)

local weak_v = { __mode = 'v' }

local cache = {}

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

function DB_GetItem(group, id, silent)
  QuestHelper: Assert(group, string.format("%s %s", tostring(group), tostring(id)))
  QuestHelper: Assert(id, string.format("%s %s", tostring(group), tostring(id)))
  local ite = DBC_Get(group, id)
  if ite then return ite end
  
  if type(id) == "string" then QuestHelper: Assert(not id:match("__.*")) end
  
  --QuestHelper:TextOut(string.format("%s %d", group, id))
  
  local ite
  --print("dbs")
  for _, db in ipairs(QHDB) do
    --print(db, db[group], db[group] and db[group][id], type(group), type(id))
    if db[group] and db[group][id] then
      print(group, id)
      if not ite then ite = QuestHelper:CreateTable("db") end
      
      local redictix = db[group].__dictionary
      if not redictix:find("\"") then redictix = redictix .. "\"" end
      if not redictix:find(",") then redictix = redictix .. "," end
      if not redictix:find("\\") then redictix = redictix .. "\\" end
      local tokens = loadstring("return {" .. QH_LZW_Decompress_Dicts_Arghhacky(db[group].__tokens, redictix) .. "}")()
      QuestHelper: Assert(tokens)
      
      local srctab
      
      if type(db[group][id]) == "string" then
        srctab = loadstring("return {" .. QH_LZW_Decompress_Dicts_Arghhacky(db[group][id], db[group].__dictionary, nil, tokens) .. "}")()
      elseif type(db[group][id]) == "table" then
        srctab = db[group][id]
      else
        print(type(db[group][id]))
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
  else
    if not silent then
      QuestHelper:TextOut(string.format("Tried to get %s/%s, failed", tostring(group), tostring(id)))
    end
  end
  
  return ite
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
