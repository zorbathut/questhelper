#!/usr/bin/lua

params = {
  PheremonePreservation = 0.78, -- must be within 0 and 1 exclusive
  AntCount = 20, -- number of ants to run before doing a pheremone pass

    -- Weighting for the various factors
  WeightFactor = 0.794,
  DistanceFactor = -3.2582,
  DistanceDeweight = 1.658, -- Add this to all distances to avoid sqrt(-1) deals
  
  -- Small amount to add to all weights to ensure it never hits, and to make sure things can still be chosen after a lot of iterations
  UniversalBonus = 0.24,
  
  -- Weight added is 1/([0-1] + BestWorstAdjustment)
  BestWorstAdjustment = 0.0159,
  
  -- How much do we want to factor in the "reverse path" weights
  AsymmetryFactor = 0.319,
  SymmetryFactor = 0.436,
}
  
fil = loadfile("routing_core.lua")

local locs = {{c = 3, x = 6148.707357, y = 5091.281657}, {c = 3, x = 9324.505029, y = 6163.559766}, {c = 3, x = 9290.955946, y = 6120.975098}, {c = 3, x = 9243.106376, y = 6477.550084}, {c = 3, x = 10365.644857, y = 6503.041829}, {c = 3, x = 8147.979297, y = 5676.278516}, {c = 3, x = 8278.651440, y = 6115.253888}, {c = 3, x = 9701.470252, y = 5429.488469}, {c = 3, x = 10379.974494, y = 6634.162282}, {c = 3, x = 9189.003791, y = 6563.805779}, {c = 3, x = 8649.705715, y = 5726.509235}, {c = 3, x = 9473.352180, y = 8645.523079}, {c = 3, x = 9677.333618, y = 8414.165283}, {c = 3, x = 8760.858226, y = 7924.901148}, {c = 3, x = 9013.065085, y = 8814.483284}, {c = 3, x = 9674.244010, y = 8409.742839}, {c = 3, x = 9513.802786, y = 8060.689325}, {c = 3, x = 9058.408033, y = 8793.569718}, {c = 3, x = 7798.000890, y = 9571.495972}, {c = 3, x = 7794.069459, y = 9572.858443}, {c = 3, x = 7587.950966, y = 9559.507710}, {c = 3, x = 7675.680767, y = 9571.430476}, {c = 3, x = 7585.729297, y = 9566.052865}, {c = 3, x = 8683.762444, y = 9564.317903}, {c = 3, x = 7611.548187, y = 9546.419312}, {c = 3, x = 8411.285648, y = 7932.874888}, {c = 3, x = 7507.377181, y = 7453.321354}, {c = 3, x = 8484.006100, y = 8811.209176}, {c = 3, x = 8483.132253, y = 8810.124242}, {c = 3, x = 7933.429399, y = 8650.160156}, {c = 3, x = 8655.075141, y = 8791.576931}, {c = 3, x = 7373.858545, y = 8823.803223}, {c = 3, x = 9048.977614, y = 8745.243765}, {c = 3, x = 8891.459501, y = 9242.205308}, {c = 3, x = 8909.817727, y = 9332.126321}, {c = 3, x = 8969.741602, y = 9312.919287}, {c = 3, x = 8944.376648, y = 9426.356812}, {c = 3, x = 7932.564331, y = 8665.130664}, {c = 3, x = 8282.388607, y = 9574.142513}, {c = 3, x = 7591.332919, y = 9573.745872}, {c = 3, x = 4493.332031, y = 5555.407138}, {c = 3, x = 4506.751332, y = 5553.642756}, {c = 3, x = 6742.723929, y = 6096.852942}, {c = 3, x = 7493.965862, y = 6073.316797}, }

local function MakeLoc(c, x, y, title)
  return {desc = title or "Test", why = meta, loc = {c = c, x = x, y = y}}
end

local function GetValue(params)
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
  
  fil()
  
  for k, v in pairs(params) do
    env[k] = v
  end
  
  local bestlen
  local pass = 0
  env.Public_Init(
    function(path) --[[print(string.format("Path notified! New weight is %f at %d", path.distance, pass))]] bestlen = path.distance end,
    function(loc1, loc2)
      -- Distance function
      if loc1.loc.c == loc2.loc.c then
        local dx = loc1.loc.x - loc2.loc.x
        local dy = loc1.loc.y - loc2.loc.y
        return math.sqrt(dx * dx + dy * dy)
      else
        return 1000000 -- one milllllion time units
      end
    end,
    function() end
  )
  
  env.Public_SetStart(MakeLoc(3, 7532, 7678))
  
  for k, v in pairs(locs) do
    env.Public_NodeAdd(MakeLoc(v.c, v.x, v.y))
  end
  
  --local v = os.time()
  for k = 1, (1000 / params.AntCount) do
    pass = k
    env.ProcessOnePass()
  end
  --local d = os.time()
  --print(d - v)
  
  return bestlen
end

local function GetSeriousValue(params)
  local acu = 0
  local passes = 10
  for k = 1, passes do
    acu = acu + GetValue(params)
  end
  return acu / passes
end

local best_params = params
while true do
  local bsf = GetSeriousValue(best_params)
  local bsf_p = best_params
  print(string.format("Starting with value %f:", bsf))
  for k, v in pairs(bsf_p) do
    print(string.format("  %s: %f", k, v))
  end
  best_params = bsf_p
  
  for i = 0, 10 do
    local tparams = {}
    for k, v in pairs(best_params) do
      tparams[k] = v * (math.random() / 5 + 0.9)
    end
    
    local tsf = GetSeriousValue(tparams)
    
    if tsf < bsf then
      bsf = tsf
      bsf_p = tparams
    end
  end
  
  best_params = bsf_p
end
