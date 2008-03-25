-- An array that keeps itself sorted.
local create = QuestHelper.create
local insert = table.insert
local erase = table.remove
local floor = math.floor
local sort = table.sort

-- The metatable for SortedList objects.
local SortedList = {}

function SortedList:onCreate(cmp)
  assert(type(cmp) == "function", "Expected function to perform less than comparisons.")
  rawset(self, "cmp", cmp)
end

-- Resorts the list.
function SortedList:sort()
  sort(self, rawget(self, "cmp"))
end

-- Inserts a value into the table.
-- Will try to insert as close to the back of the list as possible, to reduce the number of values
-- that need to be shifted.
-- Returns the index the value was inserted at.
function SortedList:insert(value)
  local cmp = rawget(self, "cmp")
  local mn, mx = 1, #self+1
  
  while mn ~= mx do
    local m = floor((mn+mx)*0.5)
    
    if cmp(value, rawget(self, m)) then
      mx = m
    else
      mn = m+1
    end
  end
  
  insert(self, mn, value)
  return mn
end

-- Inserts a value into the table, searching the indexes [mn,mx).
-- The inserted value must be greater or equal to the value at index mn, and less than the value at mx.
-- mx should be the a valid index, or one past the last valid.
-- Will try to insert as close to mx as possible, to reduce the number of values
-- that need to be shifted.
-- Returns the index the value was inserted at.
function SortedList:insert2(value, mn, mx)
  local cmp = rawget(self, "cmp")
  
  while mn ~= mx do
    local m = floor((mn+mx)*0.5)
    
    if cmp(value, rawget(self, m)) then
      mx = m
    else
      mn = m+1
    end
  end
  
  insert(self, mn, value)
  return mn
end

-- Erases a value from the table.
-- The thing you're erasing must exist.
-- Care is taken to remove the actual value and not mearly something equal to it.
-- Returns the upper bound of value, which you can use for reference if you intend to reinsert the value later.
function SortedList:erase(value)
  local cmp = rawget(self, "cmp")
  local mn, mx = 1, #self+1
  
  while mn ~= mx do
    local m = floor((mn+mx)*0.5)
    
    if cmp(value, rawget(self, m)) then
      mx = m
    else
      mn = m+1
    end
  end
  
  -- Subtracting 1, because it will be shifted by calling erase.
  local upper = mn-1
  
  while true do
    local k = rawget(self, mn)
    if k == value then
      erase(self, mn)
      return upper
    end
    
    assert(k, "Value should exist.")
    mn = mn - 1
  end
end

-- Returns lower and upper bound for value.
-- Lower bound is the first occurance of the variable, if it exists in the list.
-- Upper bound is the index of the lowest value greater than value.
-- If the lower and upper bound are equal, then value doesn't exist in the list.
function SortedList:find(value)
  local cmp = rawget(self, "cmp")
  local lmn, lmx = 1, #self+1
  local hmn, hmx = lmn, lmx
  
  while lmn ~= lmx do
    local m = floor((lmn+lmx)*0.5)
    local v = rawget(self, m)
    
    if cmp(v, value) then
      lmn = m+1
      hmn = lmn
    elseif cmp(value, v) then
      lmx = m
      hmx = m
    else
      lmx = m
      hmn = m+1
      
      while lmn ~= lmx do
        local m = floor((lmn+lmx)*0.5)
        local v = rawget(self, m)
        
        if cmp(rawget(self, m), value) then
          lmn = m+1
        else
          lmx = m
          
        end
      end
      
      while hmn ~= hmx do
        local m = floor((hmn+hmx)*0.5)
        
        if cmp(value, rawget(self, m)) then
          hmx = m
        else
          hmn = m+1
        end
      end
      
      return lmn, hmx
    end
  end
end

-- Returns lower bound for value. If value exists in the list, returned index will be its first occurance.
function SortedList:lower(value)
  local cmp = rawget(self, "cmp")
  local mn, mx = 1, #self+1
  
  while mn ~= mx do
    local m = floor((mn+mx)*0.5)
    
    if cmp(rawget(self, m), value) then
      mn = m+1
    else
      mx = m
    end
  end
  
  return mn
end

-- Returns upper bound for value. If values exists, it will be the index directly before this one.
function SortedList:upper(value)
  local cmp = rawget(self, "cmp")
  local mn, mx = 1, #self+1
  
  while mn ~= mx do
    local m = floor((mn+mx)*0.5)
    
    if cmp(value, rawget(self, m)) then
      mx = m
    else
      mn = m+1
    end
  end
  
  return mn
end

SortedList.__index = function(list, key)
  return rawget(list, key) or rawget(SortedList, key)
end

local function createSortedList(cmp)
  return create(SortedList, cmp)
end

QuestHelper.createSortedList = createSortedList
