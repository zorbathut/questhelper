loadfile("../upgrade.lua")()
loadfile("dump.lua")()
loadfile("compiler.lua")()

for _, file in ipairs(arg) do
  CompileInputFile(file)
end

print(ScanAndDumpVariable(CompileFinish(), "QuestHelper_StaticData"))
