local function ProcessLightheadedQuests(faction, data)
  for name, comments in pairs(data) do
    local qid,sharable,level,reqlev,stype,sname,sid,etype,ename,eid,exp,rep,series = comments[1]:match("([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\031]*)\031([^\030]-)\030")
    if etype == "npc" then
      local _, _, quest_name, quest_level = name:find("^(.+)\031(%d+)$")
      quest_level = tonumber(quest_level)
      if quest_name and quest_level and ename then
        local quest = GetQuest("enUS", faction, quest_level, quest_name, nil)
        if not quest.finish then quest.finish = {} end
        quest.finish[ename] = (quest.finish[ename] or 0) + 1
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

local function GenerateEQL3ZoneMapping()
  for i, name in pairs(eql3.zoneData) do
    EQL3_zone_map[i] = {GetZone(name)}
  end
end

local function ProcessEQL3NPCData()
  for npc, data in pairs(eql3.npcData) do
    if data.zone and EQL3_zone_map[data.zone] then
      local c, z = unpack(EQL3_zone_map[data.zone])
      if data.coords then for i, pos in ipairs(data.coords) do
        local _, _, x, y = pos:find("([%d.]+),([%d.]+)")
        x, y = tonumber(x), tonumber(y)
        if x and y then
          local monster = GetObjective("enUS", "monster", npc)
          
          --monster.quest = true
          
          if not monster.pos then monster.pos = {} end
          table.insert(monster.pos, {c, z, x/100, y/100, 1})
        end
      end end
    end
  end
end

local function ProcessEQL3ItemData()
  for item, drops in pairs(eql3.itemData) do
    for monster, amount in pairs(drops) do
      amount = (tonumber(amount) or 0.05)*0.2
      
      local item_obj = GetObjective("enUS", "item", item)
      local monster_obj = GetObjective("enUS", "monster", monster)
      
      --item_obj.quest = true
      --monster_obj.quest = true
      
      if not item_obj.drop then item_obj.drop = {} end
      
      item_obj.drop[monster] = (item_obj.drop[monster] or 0)+amount
      monster_obj.looted = (monster_obj.looted or 0)+amount
    end
  end
end

function ProcessExternal()
  ProcessLightheadedQuests("Alliance", LightHeaded.LH_Alliance_20)
  ProcessLightheadedQuests("Alliance", LightHeaded.LH_Alliance_40)
  ProcessLightheadedQuests("Alliance", LightHeaded.LH_Alliance_60)
  ProcessLightheadedQuests("Alliance", LightHeaded.LH_Alliance_80)
  ProcessLightheadedQuests("Horde", LightHeaded.LH_Horde_20)
  ProcessLightheadedQuests("Horde", LightHeaded.LH_Horde_40)
  ProcessLightheadedQuests("Horde", LightHeaded.LH_Horde_60)
  ProcessLightheadedQuests("Horde", LightHeaded.LH_Horde_80)
  GenerateEQL3ZoneMapping()
  ProcessEQL3NPCData()
  ProcessEQL3ItemData()
end
