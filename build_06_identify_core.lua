
assert(arg[1])

dat = loadfile(arg[1])
if not dat then io.stderr:write("  Did not load\n") return 1 end

rv, data = pcall(dat)
if not rv then io.stderr:write("  Did not run\n") return 1 end

io.stdout:write(data.QuestHelper_UID .. "\n" .. tostring(data.QuestHelper_SaveDate))
