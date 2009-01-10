
loadfile("compile_chain.lua")()
loadfile("compile_debug.lua")()

package.loadlib("/home/zorba/build/libcompile_core.so", "init")()   -- this will fuck me someday

os.execute("rm -rf intermed")

math.umod = function (val, med)
  if val < 0 then
    return math.mod(val + math.ceil(-val / med + 10) * med, med)
  else
    return math.mod(val, med)
  end
end

local zone_image_chunksize = 1024
local zone_image_descale = 4
local zone_image_outchunk = zone_image_chunksize / zone_image_descale

local chainhead = ChainBlock_Create(nil,
  function () return {
    zonecolors = {},
    
    Data = function (self, key, subkey, value, Output)
      dat = loadfile(key)()
      for k, v in pairs(dat.QuestHelper_Errors) do
        for _, d in pairs(v) do
          d.key = k
          Output(d.local_version, nil, d, "error")
        end
      end
      
      for verchunk, v in pairs(dat.QuestHelper_Collector) do
        if string.find(verchunk, "enUS") then -- hacky hacky
          -- zones!
          if v.zone then for zname, zdat in pairs(v.zone) do
            for _, key in pairs({"border", "update"}) do
              if zdat[key] then for idx, chunk in pairs(zdat[key]) do
                if math.mod(#chunk, 11) ~= 0 then print("Non-splittable chunk, " .. tostring(#chunk)) break end -- hmmmm
                assert(math.mod(#chunk, 11) == 0, tostring(#chunk))
                for point = 1, #chunk, 11 do
                  local pos = {slice_loc(string.sub(chunk, point, point + 10))}
                  if not self.zonecolors[zname] then
                    local r, g, b = math.ceil(math.random(32, 255)), math.ceil(math.random(32, 255)), math.ceil(math.random(32, 255))
                    self.zonecolors[zname] = r * 65536 + g * 256 + b
                  end
                  pos.zonecolor = self.zonecolors[zname]
                  if pos[1] and pos[2] and pos[3] then  -- These might be invalid if there are nils embedded in the string. They might still be useful with only one or two nils, but I've got a bunch of data and don't really need more.
                    Output(string.format("%d@%d@%d", pos[1], math.floor(pos[2] / zone_image_chunksize), math.floor(pos[3] / zone_image_chunksize)), nil, pos, "zone")
                  end
                end
              end end
            end
          end end
        end
      end
    end
  } end
)

--[[
*****************************************************************
Zone collation
]]

do
  local zone_collector = ChainBlock_Create(chainhead,
    function (key) return {
      imagepiece = Image(zone_image_outchunk, zone_image_outchunk),
      
      Data = function(self, key, subkey, value, Output)
        self.imagepiece:set(math.floor(math.umod(value[2], zone_image_chunksize) / zone_image_descale), math.floor(math.umod(value[3], zone_image_chunksize) / zone_image_descale), value.zonecolor)
      end,
      
      Finish = function(self, Output)
        Output("", nil, {loc = key, image = imagepiece})
      end,
    } end,
    nil, "zone"
  )
end

--[[
*****************************************************************
Error collation
]]

do
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
end

local count = 0

flist = io.popen("ls data/08"):read("*a")
local filz = {}
for f in string.gmatch(flist, "[^\n]+") do
  table.insert(filz, f)
  count = count + 1
  
  if count == 10 then break end
end

for k, v in pairs(filz) do
  print(string.format("%d/%d: %s", k, #filz, v))
  chainhead:Insert("data/08/" .. v, nil, nil)
end

print("Finishing")
chainhead:Finish()
