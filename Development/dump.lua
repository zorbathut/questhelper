local function BufferAdd(self, text)
  table.insert(self, tostring(text))
  for i=#self-1, 1, -1 do
    if string.len(self[i]) > string.len(self[i+1]) then break end
    self[i] = self[i]..table.remove(self,i+1)
  end
end

local function BufferDump(self)
  for i=#self-1, 1, -1 do
    self[i] = self[i]..table.remove(self)
  end
  return self[1] or ""
end

local function BufferAppend(self, buffer)
  for i=1,#buffer do
    BufferAdd(self, buffer[i])
  end
  while table.remove(buffer) do end
end

function CreateBuffer()
  return {add=BufferAdd, dump=BufferDump, append=BufferAppend}
end

local function TableCompare(tbl_a, tbl_b)
  local ak, av = next(tbl_a)
  local bk, bv = next(tbl_b)
  
  while ak and bk do
    if type(ak) < type(bk) then return -1 end
    if type(ak) > type(bk) then return 1 end
    if ak < bk then return -1 end
    if ak > bk then return 1 end
    
    if type(av) < type(bv) then return -1 end
    if type(av) > type(bv) then return 1 end
    if type(av) == "table" then
      local cmp = TableCompare(av, bv)
      if cmp ~= 0 then return cmp end
    elseif type(av) == "boolean" then
      if av == bv then return 0
      elseif av then return 1
      else return -1 end
    else
      if av < bv then return -1 end
      if av > bv then return 1 end
    end
    
    ak, av = next(tbl_a, ak)
    bk, bv = next(tbl_b, bk)
  end
  
  if type(ak) < type(bk) then return -1 end
  if type(ak) > type(bk) then return 1 end
  return 0
end

local table_list = {}
local table_dat = {}

local function FindSameTable(tbl)
  local sz = 0
  local key = nil
  while true do
    key = next(tbl, key)
    if not key then break end
    sz = sz + 1
  end
  
  local list = table_list[sz]
  if not list then
    list = {}
    table_list[sz] = list
  end
  
  local mn, mx = 1, #list+1
  while mn ~= mx do
    local m = math.floor((mn+mx)*0.5)
    local ltbl = list[m]
    local cmp = TableCompare(ltbl, tbl)
    if cmp == -1 then
      mx = m
    elseif cmp == 1 then
      mn = m+1
    else
      return ltbl, table_dat[ltbl]
    end
  end
  
  table.insert(list, mn, tbl)
  local dat = {}
  table_dat[tbl] = dat
  return tbl, dat
end

function ScanVariable(tbl)
  if type(tbl) == "table" then
    local tbl2, dat = FindSameTable(tbl)
    
    if not dat.ref then
      dat.ref = 1
      
      for i, j in pairs(tbl2) do
        tbl2[i] = ScanVariable(j)
      end
    else
      dat.ref = dat.ref + 1
    end
    
    return tbl2, dat
  end
  
  return tbl, nil
end

local DumpRecurse

local last_id = 0

local function WriteDupVariables(prebuf, var, dup)
  if not dup.id then
    local buf = CreateBuffer()
    local ref = dup.ref
    dup.ref = 0 -- Do that we don't try to write DAT[???] = DAT[???] over and over again.
    
    if last_id == 0 then
      last_id = 1
      prebuf:add("local DAT={}\n")
    end
    
    DumpRecurse(buf, prebuf, var, 1)
    dup.ref = ref
    
    dup.id = last_id
    last_id = last_id + 1
    
    prebuf:add("DAT[")
    prebuf:add(tostring(dup.id))
    prebuf:add("]=")
    prebuf:append(buf)
    prebuf:add("\n")
  end
end

local function isArray(obj)
  if type(obj) == "table" then
    local c = 0
    for i, j in pairs(obj) do c = c + 1 end
    return c == #obj
  end
  return false
end

local reserved_words =
 {
  ["and"] = true,
  ["break"] = true,
  ["do"] = true,
  ["else"] = true,
  ["elseif"] = true,
  ["end"] = true,
  ["false"] = true,
  ["for"] = true,
  ["function"] = true,
  ["if"] = true,
  ["in"] = true,
  ["local"] = true,
  ["nil"] = true,
  ["not"] = true,
  ["or"] = true,
  ["repeat"] = true,
  ["return"] = true,
  ["then"] = true,
  ["true"] = true,
  ["until"] = true,
  ["while"] = true
 }

local function isSafeString(obj)
  return type(obj) == "string" and not reserved_words[obj] and obj:find("^[%a_][%w_]*$")
end

DumpRecurse = function(buffer, prebuf, variable, depth)
  if type(variable) == "string" then
    return buffer:add(("%q"):format(variable))
  elseif type(variable) == "number" then
    return buffer:add(tostring(variable+0))
  elseif type(variable) == "nil" then
    return buffer:add("nil")
  elseif type(variable) == "boolean" then
    return buffer:add(variable and "true" or "false")
  elseif type(variable) == "table" then
    local dup = table_dat[variable]
    
    if dup and dup.ref > 1 then
      WriteDupVariables(prebuf, variable, dup)
      buffer:add("DAT["..dup.id.."]")
      return
    end
    
    buffer:add("{")
    
    if isArray(variable) then
      for i, j in ipairs(variable) do
        if isArray(j) then
          buffer:add("\n"..("  "):rep(depth))
        end
        
        DumpRecurse(buffer, prebuf, j, depth+1)
        if i ~= #variable then
          buffer:add(", ")
        end
      end
    else
      buffer:add("\n"..("  "):rep(depth))
      
      local sort_table = {}
      
      for key in pairs(variable) do
        table.insert(sort_table, key)
      end
      
      table.sort(sort_table, function (a, b)
        if type(a) < type(b) then return true end
        return type(a) == type(b) and (tostring(a) or "") < (tostring(b) or "")
      end)
      
      for index, i in ipairs(sort_table) do
        local j = variable[i]
        
        if isSafeString(i) then
          buffer:add(i.."=")
        else
          buffer:add("[")
          DumpRecurse(buffer, prebuf, i, depth+1)
          buffer:add("]=")
        end
        
        --buffer:add((type(j)=="table"and"\n"..("  "):rep(depth+1) or ""))
        
        DumpRecurse(buffer, prebuf, j, depth+1)
        
        if index~=#sort_table then
          buffer:add(",\n"..("  "):rep(depth))
        end
      end
    end
    
    buffer:add("}")
  else
    return buffer:add("nil --[[ UNHANDLED TYPE: '"..type(variable).."' ]]")
  end
end

function DumpVariable(buffer, prebuf, variable, name)
  buffer:add(name)
  buffer:add("=")
  DumpRecurse(buffer, prebuf, variable, 1)
  buffer:add("\n")
end

function DumpingComplete(buffer, prebuf)
  if last_id ~= 0 then
    buffer:add("DAT=nil\n")
    last_id = 0
    prebuf:add("\n")
  end
  
  prebuf:append(buffer)
  
  local result = prebuf:dump()
  
  table_list = {}
  table_dat = {}
  return result
end

function ScanAndDumpVariable(variable, name, no_scan)
  local buffer, prebuf = CreateBuffer(), CreateBuffer()
  
  if name then
    DumpVariable(buffer, prebuf, no_scan and variable or ScanVariable(variable), name)
  else
    -- If no name is specified, dump each variable in sequence.
    local sort_table = {}
    
    for key, var in pairs(variable) do
      table.insert(sort_table, key)
      
      if not no_scan then
        ScanVariable(var)
      end
    end
    
    table.sort(sort_table, function (a, b)
      if type(a) < type(b) then return true end
      return type(a) == type(b) and (tostring(a) or "") < (tostring(b) or "")
    end)
    
    for index, i in ipairs(sort_table) do
      if isSafeString(i) then
        buffer:add(i)
        buffer:add("=")
      else
        -- A variable that doesn't have a normal name. Why this would be is a mystery.
        buffer:add("_G[")
        DumpRecurse(buffer, prebuf, i, 0)
        buffer:add("]=")
      end
      
      DumpRecurse(buffer, prebuf, variable[i], 1)
      buffer:add("\n")
    end
  end
  
  return DumpingComplete(buffer, prebuf)
end
