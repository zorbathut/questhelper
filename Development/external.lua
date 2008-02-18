local function ProcessLightheadedQuests(faction, data)
  for name, comments in pairs(data) do
    local qid,sharable,level,reqlev,stype,sname,sid,etype,ename,eid,exp,rep,series = comments[1]:match("([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\030]-)\030")
    if etype == "npc" then
      local _, _, quest_name, quest_level = name:find("^(.+)\031(%d+)$")
      quest_level = tonumber(quest_level)
      if quest_name and quest_level and ename then
        local quest = GetQuest("enUS", faction, quest_level, quest_name, nil)
        if not quest.finish then quest.finish = {} end
        quest.finish[ename] = (quest.finish[ename] or 0) + 0.01
      end
    end
  end
end

local EQL3_zone_map = {}

local function GetZone(zone_name)
  for c, names in ipairs(QuestHelper_Ver01_Zones) do
    for z, name in ipairs(names) do
      if name == zone_name then
        return c, z
      end
    end
  end
  
  error("Don't know where "..zone_name.." is!")
end

local function GenerateEQL3ZoneMapping(eql3)
  for i, name in pairs(eql3.zoneData) do
    EQL3_zone_map[i] = {GetZone(name)}
  end
end

local function ProcessEQL3NPCData(eql3)
  for npc, data in pairs(eql3.npcData) do
    if data.zone and EQL3_zone_map[data.zone] then
      local c, z = unpack(EQL3_zone_map[data.zone])
      if data.coords then for i, pos in ipairs(data.coords) do
        local _, _, x, y = pos:find("([%d.]+),([%d.]+)")
        x, y = tonumber(x), tonumber(y)
        if x and y then
          local monster = GetObjective("enUS", "monster", npc)
          
          if not monster.pos then monster.pos = {} end
          table.insert(monster.pos, {QuestHelper_IndexLookup[QuestHelper_Ver01_Zones[c][z]], x/100, y/100, 1})
        end
      end end
    end
  end
end

local function ProcessEQL3ItemData(eql3)
  for item, drops in pairs(eql3.itemData) do
    for monster, amount in pairs(drops) do
      amount = (tonumber(amount) or 0.05)*0.2
      
      local item_obj = GetObjective("enUS", "item", item)
      local monster_obj = GetObjective("enUS", "monster", monster)
      
      if not item_obj.drop then item_obj.drop = {} end
      
      item_obj.drop[monster] = (item_obj.drop[monster] or 0)+amount
      monster_obj.looted = (monster_obj.looted or 0)+amount
    end
  end
end

local function LoadFile(filename, data)
  local loader = loadfile(filename)
  if loader then
    setfenv(loader, data)
    loader()
  else
    print("Unable to open file: "..filename)
  end
end

function ProcessExternal()
  local lh_map =
    {Alliance={["External/LH_AllianceQuests_20.lua"] = "LH_Alliance_20",
     ["External/LH_AllianceQuests_40.lua"] = "LH_Alliance_40",
     ["External/LH_AllianceQuests_60.lua"] = "LH_Alliance_60",
     ["External/LH_AllianceQuests_80.lua"] = "LH_Alliance_80"},
     Horde={["External/LH_HordeQuests_20.lua"] = "LH_Horde_20",
     ["External/LH_HordeQuests_40.lua"] = "LH_Horde_40",
     ["External/LH_HordeQuests_60.lua"] = "LH_Horde_60",
     ["External/LH_HordeQuests_80.lua"] = "LH_Horde_80"}}
  
  for faction, map in pairs(lh_map) do
    for file, key in pairs(map) do
      local data = {}
      LoadFile(file, data)
      if data[key] then
        ProcessLightheadedQuests(faction, data[key])
      else
        print("Missing Lightheaded data: "..key)
      end
    end
  end
  
  local eql3 = {}
  
  LoadFile("External/itemData.lua", eql3)
  LoadFile("External/npcData.lua", eql3)
  LoadFile("External/zoneData.lua", eql3)
  
  GenerateEQL3ZoneMapping(eql3)
  ProcessEQL3NPCData(eql3)
  ProcessEQL3ItemData(eql3)
end
