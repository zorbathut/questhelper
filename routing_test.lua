
-- This is a garbage file that I'm going to be using to test the new routing system.

-- This is for updating the minimap.
--minimap_dodad:SetObjective(route[1])
-- This is for the map path.
--map_walker:RouteChanged()

local meta = {desc = "Test"}

local function MakeTest(c, x, y, title)
  return {desc = title or "Test", why = meta, loc = NewLoc(c, x, y)}
end

Public_SetStart(MakeTest(0, 37663, 19658, "Start")) -- Ironforge

local temp_walker = QuestHelper:CreateWorldMapWalker()

QuestHelper:TextOut("PIINIT")

Public_Init(
  function(path) RTO(string.format("Path notified! New weight is %f", path.distance)) temp_walker:RouteChanged(path) end,
  function(loc1, loc2)
    -- Distance function
    if loc1.loc.c == loc2.loc.c then
      local dx = loc1.loc.x - loc2.loc.x
      local dy = loc1.loc.y - loc2.loc.y
      return math.sqrt(dx * dx + dy * dy)
    else
      return 1000000 -- one milllllion time units
    end
  end,
  function()
    local c, x, y = QuestHelper:RetrieveRawLocation()
    if c and x and y then
      Public_SetStart(MakeTest(c, x, y, "Start"))
    end
  end
)

QuestHelper:TextOut("TSLA")

QH_Timeslice_Add(Public_Process, "new_routing")

QuestHelper:TextOut("shoop da woop")

function doit()

  local nta = {}
  local ntr = {}
  table.insert(nta,MakeTest(0, 39000, 17000, "Pre1"))
  table.insert(nta,MakeTest(0, 40000, 17000, "Pre2"))
  table.insert(nta,MakeTest(0, 40000, 15000, "Pre3"))
  table.insert(nta,MakeTest(0, 35000, 21000, "Pre4"))
  table.insert(nta,MakeTest(0, 35000, 20000, "Pre5"))
  table.insert(nta,MakeTest(0, 35000, 22000, "Pre6"))
  table.insert(nta,MakeTest(3, 35000, 22000, "Pre7"))
  table.insert(nta,MakeTest(3, 35000, 29000, "Pre8"))
  table.insert(nta,MakeTest(3, 40000, 29000, "Pre9"))
  table.insert(nta,MakeTest(3, 40000, 26700, "Pre10"))
  
  for _, v in pairs(nta) do
    Public_NodeAdd(v)
  end
  
    --[[
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
  
  RTO("Done testing")]]
end

function addmore()
  for k = 1, 8 do
    Public_NodeAdd(MakeTest(0, math.random() * 50000, math.random() * 30000, "Random"))
  end
end
