
-- This is a garbage file that I'm going to be using to test the new routing system.

PathNotifier, Distance

Public_Init(
  function(path) print("Path notified!") end,
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

QH_Timeslice_Add(public_process, "new_routing")
