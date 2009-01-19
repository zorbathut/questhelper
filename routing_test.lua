
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

  Public_NodeAdd(NewLoc(0, 39000, 17000))
  Public_NodeAdd(NewLoc(0, 40000, 17000))
  Public_NodeAdd(NewLoc(0, 40000, 15000))
  Public_NodeAdd(NewLoc(0, 35000, 21000))
  Public_NodeAdd(NewLoc(0, 35000, 20000))
  Public_NodeAdd(NewLoc(0, 35000, 22000)) -- HAVE SOME NODES, BITCH
end
