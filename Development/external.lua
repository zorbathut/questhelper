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
  local data = 
    {{
      [1]="Ashenvale",
      [2]="Azshara",
      [3]="Azuremyst Isle",
      [4]="Bloodmyst Isle",
      [5]="Darkshore",
      [6]="Darnassus",
      [7]="Desolace",
      [8]="Durotar",
      [9]="Dustwallow Marsh",
      [10]="Felwood",
      [11]="Feralas",
      [12]="Moonglade",
      [13]="Mulgore",
      [14]="Orgrimmar",
      [15]="Silithus",
      [16]="Stonetalon Mountains",
      [17]="Tanaris",
      [18]="Teldrassil",
      [19]="The Barrens",
      [20]="The Exodar",
      [21]="Thousand Needles",
      [22]="Thunder Bluff",
      [23]="Un'Goro Crater",
      [24]="Winterspring"
     },
     {
      [1]="Alterac Mountains",
      [2]="Arathi Highlands",
      [3]="Badlands",
      [4]="Blasted Lands",
      [5]="Burning Steppes",
      [6]="Deadwind Pass",
      [7]="Dun Morogh",
      [8]="Duskwood",
      [9]="Eastern Plaguelands",
      [10]="Elwynn Forest",
      [11]="Eversong Woods",
      [12]="Ghostlands",
      [13]="Hillsbrad Foothills",
      [14]="Ironforge",
      [15]="Loch Modan",
      [16]="Redridge Mountains",
      [17]="Searing Gorge",
      [18]="Silvermoon City",
      [19]="Silverpine Forest",
      [20]="Stormwind City",
      [21]="Stranglethorn Vale",
      [22]="Swamp of Sorrows",
      [23]="The Hinterlands",
      [24]="Tirisfal Glades",
      [25]="Undercity",
      [26]="Western Plaguelands",
      [27]="Westfall",
      [28]="Wetlands",
     },
     {
      [1]="Blade's Edge Mountains",
      [2]="Hellfire Peninsula",
      [3]="Nagrand",
      [4]="Netherstorm",
      [5]="Shadowmoon Valley",
      [6]="Shattrath City",
      [7]="Terokkar Forest",
      [8]="Zangarmarsh",
     }}
  for c, names in ipairs(data) do
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
          if not monster.pos then monster.pos = {} end
          table.insert(monster.pos, {c, z, x/100, y/100, 1})
        end
      end end
    end
  end
end

local function ProcessEQL3ItemData()
  for item, drops in pairs(eql3.itemData) do
    for monster, _ in pairs(drops) do
      local item = GetObjective("enUS", "item", item)
      if not item.drop then item.drop = {} end
      -- Making these tiny, because there isn't a loot entry for the monster.
      item.drop[monster] = (item.drop[monster] or 0)+0.001
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
