
loadfile("chain.lua")()

-- package.loadlib("/home/zorba/build/libcompile_core.so", "init")()
-- greet()

local chainhead = ChainBlock_Create(function () return {
    Data = function (key, subkey, value)
      print(key)
    end
  } end,
  nil, nil)

flist = io.popen("ls data/08"):read("*a")
for f in string.gmatch(flist, "[^\n]+") do
  chainhead:Insert("data/08/" .. f, nil, nil)
end

chainhead:Finish()
