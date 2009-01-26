QuestHelper_File["routing_loc.lua"] = "Development Version"
QuestHelper_Loadtime["routing_loc.lua"] = GetTime()

-- Okay, this is going to be revamped seriously later, but for now:
-- .c is continent, either 0, 3, or -77
-- .x is x-coordinate
-- .y is y-coordinate
-- that's it.

-- Also, we're gonna pull something similar as with Collect to wrap everything up and not pollute the global space. But for now we don't.

function NewLoc(c, x, y)
  QuestHelper: Assert(c)
  QuestHelper: Assert(x)
  QuestHelper: Assert(y)
  local tab = QuestHelper:CreateTable("location")
  tab.c = c
  tab.x = x
  tab.y = y
  return tab
end

function IsLoc(c)
  return c and c.c and c.x and c.y
end
