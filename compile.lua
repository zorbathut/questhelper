
loadfile("compile_chain.lua")()
loadfile("compile_debug.lua")()

package.loadlib("/home/zorba/build/libcompile_core.so", "init")()   -- this will fuck me someday

os.execute("rm -rf intermed")

greet()
slice_loc("testing")
if true then return end

-- package.loadlib("/home/zorba/build/libcompile_core.so", "init")()
-- greet()

local chainhead = ChainBlock_Create(nil,
  function () return {
    Data = function (self, key, subkey, value, Output)
      dat = loadfile(key)()
      for k, v in pairs(dat.QuestHelper_Errors) do
        for _, d in pairs(v) do
          d.key = k
          Output(d.local_version, nil, d, "error")
        end
      end
    end
  } end
)

local error_collater = ChainBlock_Create(chainhead,
  function (key) return {
    accum = {},
    
    Data = function (self, key, subkey, value, Output)
      assert(value.local_version)
      if not value.toc_version or value.local_version ~= value.toc_version then return end
      local signature
      if value.key ~= "crashes" then signature = value.key end
      if not signature then signature = value.message end
      local v = value.local_version
      if not self.accum[v] then self.accum[v] = {} end
      if not self.accum[v][signature] then self.accum[v][signature] = {count = 0, dats = {}, sig = signature, ver = v} end
      self.accum[v][signature].count = self.accum[v][signature].count + 1
      table.insert(self.accum[v][signature].dats, value)
    end,
    
    Finish = function (self, Output)
      for ver, chunk in pairs(self.accum) do
        local tbd = {}
        for _, v in pairs(chunk) do
          table.insert(tbd, v)
        end
        table.sort(tbd, function(a, b) return a.count > b.count end)
        for i, dat in pairs(tbd) do
          dat.count_pos = i
          Output("", nil, dat)
        end
      end
    end
  } end,
  nil, "error"
)

do
  local function acuv(tab, ites)
    local sit = ""
    for _, v in pairs(ites) do
      sit = sit .. string.format("%s: %s\n", tostring(v), tostring(tab[v]))
      tab[v] = nil
    end
    return sit
  end
  local function keez(tab)
    local rv = {}
    for k, _ in pairs(tab) do
      table.insert(rv, k)
    end
    return rv
  end
  
  local error_writer = ChainBlock_Create(error_collater,
    function (key) return {
      Data = function (self, key, subkey, value, Output)
        os.execute("mkdir -p intermed/error/" .. value.ver)
        fil = io.open(string.format("intermed/error/%s/%03d-%05d.txt", value.ver, value.count_pos, value.count), "w")
        fil:write(value.sig)
        fil:write("\n\n\n\n")
        
        for _, tab in pairs(value.dats) do
          local prefix = acuv(tab, {"message", "key", "toc_version", "local_version", "game_version", "locale", "timestamp", "mutation"})
          local postfix = acuv(tab, {"stack", "addons"})
          local midfix = acuv(tab, keez(tab))
          
          fil:write(prefix)
          fil:write("\n")
          fil:write(midfix)
          fil:write("\n")
          fil:write(postfix)
          fil:write("\n\n\n")
        end
        
        fil:close()
      end
    } end
  )
end

local count = 0

flist = io.popen("ls data/08"):read("*a")
local filz = {}
for f in string.gmatch(flist, "[^\n]+") do
  table.insert(filz, f)
  count = count + 1
  
  --if count == 10 then break end
end

for k, v in pairs(filz) do
  print(string.format("%d/%d: %s", k, #filz, v))
  chainhead:Insert("data/08/" .. v, nil, nil)
end

print("Finishing")
chainhead:Finish()
