local function BufferAdd(self, text)
  table.insert(self, text)
  for i=#self-1, 1, -1 do
    if string.len(self[i]) > string.len(self[i+1]) then break end
    self[i] = self[i]..table.remove(self,i+1)
  end
end

local function BufferDump(self)
  for i=#self-1, 1, -1 do
    self[i] = self[i]..table.remove(self)
  end
  return self[1]
end

local function BufferAppend(self, buffer)
  while true do
    local chunk = table.remove(buffer, 1)
    if chunk then
      BufferAdd(self, chunk)
    else
      break
    end
  end
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
  local mn, mx = 1, #table_list+1
  while mn ~= mx do
    local m = math.floor((mn+mx)*0.5)
    local ltbl = table_list[m]
    local cmp = TableCompare(ltbl, tbl)
    if cmp == -1 then
      mx = m
    elseif cmp == 1 then
      mn = m+1
    else
      return ltbl, table_dat[ltbl]
    end
  end
  
  -- TODO: Can write this once
  assert(mn == #table_list+1 or TableCompare(table_list[mn], tbl) == -1)
  
  table.insert(table_list, mn, tbl)
  local dat = {}
  table_dat[tbl] = dat
  return tbl, dat
end

local function ScanTable(tbl)
  local tbl2, dat = FindSameTable(tbl)
  
  if not dat.ref then
    dat.ref = 1
    for i, j in pairs(tbl2) do
      if type(j) == "table" then
        tbl[i] = ScanTable(j)
      end
    end
  else
    dat.ref = dat.ref + 1
  end
  
  return tbl2, dat
end

local DumpRecurse

local last_id = 1

local function WriteDupVariables(prebuf, var, dup)
  if not dup.id then
    local buf = CreateBuffer()
    local ref = dup.ref
    dup.ref = 0 -- Do that we don't try to write DAT[???] = DAT[???] over and over again.
    DumpRecurse(buf, prebuf, var, 0)
    dup.ref = ref
    if last_id == 1 then
      prebuf:add("local DAT={}\n")
    end
    
    dup.id = last_id
    last_id = last_id + 1
    prebuf:add("DAT["..dup.id.."]="..buf:dump().."\n")
  end
end

local function isArray(obj)
  local c = 0
  for i, j in pairs(obj) do c = c + 1 end
  return c == #obj
end

local function isSafeString(obj)
  return type(obj) == "string" and string.len(obj) > 0 and string.find(obj, "^[%a_][%a%d_]*$")
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
        DumpRecurse(buffer, prebuf, j, depth+1)
        if next(variable,i) then
          buffer:add(","..(type(variable[i+1])=="table"and"\n"..("  "):rep(depth) or " "))
        end
      end
    else
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
        
        buffer:add((type(j)=="table"and"\n"..("  "):rep(depth+1) or ""))
        
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

function DumpVariable(variable, name)
  if type(variable) == "table" then variable = ScanTable(variable) end
  local buffer, prebuf = CreateBuffer(), CreateBuffer()
  DumpRecurse(buffer, prebuf, variable, 0)
  
  
  buffer:add("\n")
  
  if last_id ~= 1 then
    buffer:add("DAT=nil\n")
    last_id = 1
  end
  
  prebuf:add("\n")
  prebuf:add(name)
  prebuf:add("=")
  prebuf:add(buffer:dump())
  
  local result = prebuf:dump()
  
  table_list = {}
  table_dat = {}
  return result
end
