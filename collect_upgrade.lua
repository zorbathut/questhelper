QuestHelper_File["collect_upgrade.lua"] = "Development Version"
QuestHelper_Loadtime["collect_upgrade.lua"] = GetTime()

function QH_Collector_Upgrade(chunk)
  QuestHelper: Assert(not chunk.compressed)
  
  if chunk.version == 1 then
    -- We basically just want to clobber all our old route data, it's not worth storing - it's all good data, it's just that we don't want to preserve relics of the old location system.
    for _, v in pairs(chunk) do
      v.traveled = nil
    end
    
    chunk.version = 2
  end
  
  if chunk.version == 2 then
    -- Originally I split the zones based on locale. Later I just split everything based on locale. Discarding old data rather than doing the gymnastics needed to preserve it.
    -- This is turning into a routine. :D
    for _, v in pairs(chunk) do
      v.zone = nil
    end
    
    chunk.version = 3
  end
  
  if chunk.version == 3 then
    -- Screwed up the item collection code in instances. Obliterate old data, try again.
    for locale, data in pairs(chunk) do
      if data.item then
        for id, dat in pairs(data.item) do
          dat.equip_no = nil
          dat.equip_yes = nil
        end
      end
    end
    
    chunk.version = 4
  end
  
  if chunk.version == 4 then
    -- Munged the shops rather badly. Whoopsydaisy.
    for locale, data in pairs(chunk) do
      if data.monster then
        local nv = {}
        for id, dat in pairs(data.monster) do
          if type(dat) == "table" then
            nv[id] = dat
          end
        end
        data.monster = nv
      end
    end
    
    chunk.version = 5
  end
end

function QH_Collector_UpgradeAll(Collector)
-- So, I screwed up the compression code, and there's no way to know what version was compressed . . . except that we thankfully didn't change the version number on that change. Any untagged compression will therefore be the version number that this was loaded with.
  for _, v in pairs(Collector) do
    if not v.version then
      QuestHelper: Assert(QuestHelper_Collector_Version)  -- This is going to fail somehow. I just know it. Seriously, this right here will be proof that, today, the gods hate me.
      v.version = QuestHelper_Collector_Version
    end
    
    if not v.compressed then
      QH_Collector_Upgrade(v)
    end
  end
  
  -- The whole "upgrade" concept really needs to be reinvented. So let's reinvent it. Each segment is now its own little world, and we don't really need a global version number at all.
  for _, v in pairs(Collector) do
    
  end
end
