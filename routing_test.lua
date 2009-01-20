
-- This is a garbage file that I'm going to be using to test the new routing system.

Public_SetStart(NewLoc(0, 37663, 19658)) -- Ironforge

function doit()
  Public_Init(
    function(path) RTO("Path notified!") end,
    function(loc1, loc2)
      -- Distance function
      if loc1.c == loc2.c then
        local dx = loc1.x - loc2.x
        local dy = loc1.y - loc2.y
        return math.sqrt(dx * dx + dy * dy)
      else
        return 1000000 -- one milllllion time units
      end
    end
  )

  QH_Timeslice_Add(Public_Process, "new_routing")

  local nta = {}
  local ntr = {}
  table.insert(nta,NewLoc(0, 39000, 17000))
  table.insert(nta,NewLoc(0, 40000, 17000))
  table.insert(nta,NewLoc(0, 40000, 15000))
  table.insert(nta,NewLoc(0, 35000, 21000))
  table.insert(nta,NewLoc(0, 35000, 20000))
  table.insert(nta,NewLoc(0, 35000, 22000))
  table.insert(nta,NewLoc(3, 35000, 22000))
  table.insert(nta,NewLoc(3, 35000, 29000))
  table.insert(nta,NewLoc(3, 40000, 29000))
  table.insert(nta,NewLoc(3, 40000, 26700))
  
  for x= 1, 1000 do
    local rem = (math.random() > 0.5)
    if rem and #ntr > 0 then
      local idx = math.floor(math.random() * #ntr) + 1
      RTO(string.format("|cffFF8080%d: Removing %d/%d %s", x, idx, #ntr, tostring(ntr[idx])))
      Public_NodeRemove(ntr[idx])
      table.insert(nta, table.remove(ntr, idx))
    elseif #nta > 0 then
      local idx = math.floor(math.random() * #nta) + 1
      RTO(string.format("|cffFF8080%d: Adding %d/%d %s", x, idx, #nta, tostring(nta[idx])))
      Public_NodeAdd(nta[idx])
      table.insert(ntr, table.remove(nta, idx))
    end
  end
  
  RTO("Done testing")
end
