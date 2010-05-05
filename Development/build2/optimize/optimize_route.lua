#!/usr/bin/lua

require("luarocks.require")
require("pluto")
require("gzio")
local d, e = loadfile("../compile_chain.lua")
print(e)
if not d then d, e = loadfile("compile_chain.lua") end
print(e)
d()

ChainBlock_Init("/nfs/build/optimize", "optimize_route.lua", function () 
  os.execute("rm -rf intermed")
  os.execute("mkdir intermed")

  os.execute("rm -rf final")
  os.execute("mkdir final") end, ...)

local printworking = false

local fil = gzio.open("dumpdata.gz", "r")
local str = fil:read("*a")
fil:close()
local dats = pluto.unpersist({}, str)

local function parse2uns(str, ofs)
  local a, b = str:byte(ofs, ofs + 1)
  return a + b * 256
end

local instpacks = {}

for _, v in pairs(dats) do
  local dts = v.data
  
  local instructions = {}

  local clustsizes = {}

  local nodes_right_now = 1
  local loops = 0
  local moves = 0
  local cps = 1
  while cps <= #dts do
    local inst = dts:sub(cps, cps)
    cps = cps + 1
    
    if inst == "#" then
      local chunky = {}
      for i = 1, nodes_right_now * nodes_right_now do
        table.insert(chunky, parse2uns(dts, cps + i * 2 - 2))
      end
      cps = cps + 2 * nodes_right_now * nodes_right_now
      
      table.insert(instructions, function(env)
          if printworking then print("working", inst) end
          env.Unstorage_SetDists(chunky)
        end
      )
    elseif inst == "A" then
      local nod = parse2uns(dts, cps)
      nodes_right_now = nodes_right_now + 1
      cps = cps + 2
      
      assert(dts:sub(cps, cps) == "X")
      cps = cps + 1
      
      local chunky = {}
      for i = 1, nodes_right_now * 2 - 1 do
        table.insert(chunky, parse2uns(dts, cps + i * 2 - 2))
      end
      cps = cps + 2 * (nodes_right_now * 2 - 1)
      
      assert(dts:sub(cps, cps) == "X")
      cps = cps + 1
      
      table.insert(instructions, function(env)
          if printworking then print("working", inst) end
          env.Unstorage_Add(nod)
          env.Unstorage_SetDistsX(nod, chunky)
          env.Unstorage_Nastyscan()
        end
      )
    elseif inst == "-" then
      local nod = parse2uns(dts, cps)
      cps = cps + 2
      moves = moves + 1
      
      local chunky = {}
      for i = 1, nodes_right_now do
        table.insert(chunky, parse2uns(dts, cps + i * 2 - 2))
      end
      cps = cps + 2 * nodes_right_now
      
      table.insert(instructions, function(env)
          if printworking then print("working", inst) end
          env.Unstorage_SetDistsLine(nod, chunky)
        end
      )
    elseif inst == "R" then
      local nod = parse2uns(dts, cps)
      cps = cps + 2
      
      table.insert(instructions, function(env)
          if printworking then print("working", inst) end
          env.Unstorage_Remove(nod)
        end
      )
    elseif inst == "C" then
      local nod = parse2uns(dts, cps)
      cps = cps + 2
      local ct = parse2uns(dts, cps)
      cps = cps + 2
      
      clustsizes[nod] = ct
      local chunky = {}
      for i = 1, ct do
        table.insert(chunky, parse2uns(dts, cps + i * 2 - 2))
      end
      cps = cps + 2 * ct
      
      table.insert(instructions, function(env)
          if printworking then print("working", inst) end
          env.Unstorage_ClusterAdd(nod, chunky)
        end
      )
    elseif inst == "D" then
      local nod = parse2uns(dts, cps)
      cps = cps + 2
      nodes_right_now = nodes_right_now - clustsizes[nod]
      
      table.insert(instructions, function(env)
          if printworking then print("working", inst) end
          env.Unstorage_ClusterRemove(nod)
        end
      )
    elseif inst == ">" then
      local a = parse2uns(dts, cps)
      cps = cps + 2
      local b = parse2uns(dts, cps)
      cps = cps + 2
      
      table.insert(instructions, function(env)
          if printworking then print("working", inst) end
          env.Unstorage_Link(a, b)
        end
      )
    elseif inst == "L" then
      local ct = math.sqrt(parse2uns(dts, cps))
      cps = cps + 2
      
      loops = loops + ct
      
      table.insert(instructions, function(env, lep)
          if printworking then print("working", inst, ct) end
          for i = 1, ct do
            env.QH_Route_Core_Process()
            lep.loopid = lep.loopid + 1
          end
        end
      )
    else
      print("Invalid instruction", inst)
      assert(false)
    end
    
    --print(inst)
    assert(dts:sub(cps, cps) == inst)
    cps = cps + 1
  end
  
  print(v.src, #dts, loops, moves, #instructions)
  
  if loops < 10 then continue end
  
  table.insert(instpacks, instructions)
end


params = {
  PheremoneDePreservation = 0.015,
  PheremonePreservation = 0.985, -- must be within 0 and 1 exclusive
  AntCount = 20, -- number of ants to run before doing a pheremone pass

    -- Weighting for the various factors
  WeightFactor = 0.8,
  DistanceFactor = -1.666,
  DistanceDeweight = 1.5, -- Add this to all distances to avoid sqrt(-1) deals
  
  -- Small amount to add to all weights to ensure it never hits, and to make sure things can still be chosen after a lot of iterations
  UniversalBonus = 0.06,
  
  -- Weight added is 1/([0-1] + BestWorstAdjustment)
  BestWorstAdjustment = 5.5,
}

fil, err = loadfile("routing_core.lua")



local function MakeLoc(c, x, y, title)
  return {desc = title or "Test", why = meta, loc = {c = c, x = x, y = y}}
end

local function GetValue(params, itix)
  local ct = os.time()
  local aculen = 0
  
  local inst = instpacks[itix]
  

  local env = {}
  setfenv(fil, env)
  
  env.QuestHelper_File = {}
  env.QuestHelper_Loadtime = {}
  env.GetTime = function () return 0 end
  env.QuestHelper = {Assert = function (self, v, d) assert(v) end}
  env.NewRoute = function () return {} end
  env.QH_Timeslice_Yield = function () end
  env.math = math
  env.tostring = tostring
  env.RTO = print
  env.ipairs = ipairs
  env.pairs = pairs
  env.string = string
  env.table = table
  env.print = print
  env.debug = debug -- :ughh:
  
  fil()
  
  env.Unstorage_Magic(params)
  
  local lopid = {loopid = 0}
  
  local lastlen = 0
  local lastloop = 0
  env.QH_Route_Core_Init(
    function(path)
      aculen = aculen + lastlen * (lopid.loopid - lastloop)
      lastlen = path.distance
      lastloop = lopid.loopid
    end,
    function() end,
    function() return {} end
  )
  
  for _, v in ipairs(inst) do
    v(env, lopid)
  end
  
  print(aculen, os.time() - ct)
  return aculen
end



local chainhead = ChainBlock_Create("work", nil,
  function () return {
    Data = function (self, key, subkey, value, Output)
      Output(tostring(value.fn), nil, {sig = value.sig, val = GetValue(value.params, value.item)})
    end
  } end
)

local dumper = ChainBlock_Create("dumper", {chainhead},
  function (key) return {
    acu = {},
    
    Data = function (self, key, subkey, value, Output)
      self.acu[value.sig] = (self.acu[value.sig] or 0) + value.val
    end,
    Finish = function (self)
      local st = pluto.persist({}, self.acu)
      local dt = gzio.open(key, "w")
      dt:write(st)
      dt:close()
    end
  } end
)

if ChainBlock_Work() then return end



--[[local function GetSeriousValue(params)
  local acu = 0
  local passes = 10
  for k = 1, passes do
    acu = acu + GetValue(params)
  end
  return acu / passes
end]]

local iterations = 0
local best_params = params
while true do
  for k, v in pairs(best_params) do
    print(string.format("  %s: %f", k, v))
  end
  
  local these_params = {}
  local fn = "data_" .. tostring(iterations) .. ".gz"
  
  for i = 1, 10 do
    local tparams = {}
    if i == 1 then
      tparams = best_params
    else
      for k, v in pairs(best_params) do
        tparams[k] = v * (math.random() / 5 + 0.9)
      end
    end
    
    tparams.AntCount = 20
    tparams.PheremonePreservation = 1 - tparams.PheremoneDePreservation
    
    for k = 1, #instpacks do
      chainhead:Insert(string.format("%d", i), nil, {fn = fn, sig = i, params = tparams, item = k})
    end
    
    table.insert(these_params, tparams)
  end
  
  chainhead:Finish()
  os.execute("rm -rf temp")
  os.execute("mkdir temp")
  
  local fil = gzio.open(fn, "r")
  local str = fil:read("*a")
  fil:close()
  local dats = pluto.unpersist({}, str)
  print(#dats)
  assert(#dats == 10)
  
  local bsv = dats[1]
  local tbsv = 1
  for i = 1, 10 do
    print(dats[i])
    if dats[i] < bsv then
      bsv = dats[i]
      tbsv = i
    end
  end
  
  best_params = these_params[tbsv]
  
  iterations = iterations + 1
end
