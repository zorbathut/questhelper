
require "compile_achievement_db"

local valid_crits_proto = {0, 43, 54, 68, 70, 72, 109, 110}
local valid_crits = {}
for _, v in ipairs(valid_crits_proto) do
  valid_crits[v] = true
end

local achievements_out = {achievements = {}, monsters = {}}

for _, v in pairs(achievements) do
  for achid, data in pairs(v) do
    local allowed_crits = 0
    local denied_crits = 0
    local semiallowed_crits = 0
    
    for _, dat in ipairs(data) do
      if dat.type == 0 then
        semiallowed_crits = semiallowed_crits + 1
      elseif valid_crits[dat.type] then
        allowed_crits = allowed_crits + 1
      else
        denied_crits = denied_crits + 1
      end
    end
    
    if #data == 0 then continue end
    if denied_crits ~= 0 then continue end
    --print(data.name, allowed_crits, denied_crits)
    
    if allowed_crits > 0 then
      achievements_out.achievements[achid] = true
    end
    
    for _, dat in ipairs(data) do
      if dat.type == 0 then
        achievements_out.monsters[dat.asset] = true
      end
    end
  end
end

achievements = achievements_out
