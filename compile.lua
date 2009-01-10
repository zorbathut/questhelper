
loadfile("compile_chain.lua")()

-- package.loadlib("/home/zorba/build/libcompile_core.so", "init")()
-- greet()

local chainhead = ChainBlock_Create(nil,
  function () return {
    Data = function (self, key, subkey, value, Output)
      dat = loadfile(key)()
      for k, v in pairs(dat.QuestHelper_Errors) do
        for _, d in pairs(v) do
          d.key = k
          Output(d.local_version, nil, d)
        end
      end
    end
  } end,
  nil, nil)

local error_collater = ChainBlock_Create(chainhead,
  function (key) print("constructed " .. tostring(key)) return {
    Data = function (self, key, subkey, value, Output)
      print(value)
    end
  } end,
  nil, nil)

flist = io.popen("ls data/08"):read("*a")
for f in string.gmatch(flist, "[^\n]+") do
  chainhead:Insert("data/08/" .. f, nil, nil)
end

chainhead:Finish()
