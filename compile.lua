
loadfile("chain.lua")()

-- package.loadlib("/home/zorba/build/libcompile_core.so", "init")()
-- greet()

flist = io.popen("ls data/08"):read("*a")
for f in string.gmatch(flist, "[^\n]+") do
  print("data/08/" .. f)
end

