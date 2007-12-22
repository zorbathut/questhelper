loadfile("../upgrade.lua")()
loadfile("dump.lua")()
loadfile("program.lua")()

for _, file in ipairs(arg) do
  _G.data = {}
  _G.file = file
  
  local data = loadfile(file)
  if data then
    setfenv(data, _G.data)
    data()
    
    NewData()
  else
    print("-- '"..file.."' couldn't be loaded!")
  end
end

Finished()
