QuestHelper_File["routing_loc.lua"] = "Development Version"
QuestHelper_Loadtime["routing_loc.lua"] = GetTime()

-- Okay, this is going to be revamped seriously later, but for now:
-- .c is continent, either 0, 3, or -77
-- .x is x-coordinate
-- .y is y-coordinate
-- that's it.

-- Also, we're gonna pull something similar as with Collect to wrap everything up and not pollute the global space. But for now we don't.

function NewLoc()
  return QuestHelper:CreateTable("location")
end
