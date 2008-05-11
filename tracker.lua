QuestHelper_File["tracker.lua"] = "Development Version"

local tracker = CreateFrame("Frame", "QuestHelperQuestWatchFrame", UIParent)

QuestHelper.tracker = tracker

tracker:Hide()
tracker:SetPoint("TOPRIGHT", QuestWatchFrame)
tracker:SetWidth(200)
tracker:SetHeight(100)
tracker.dw, tracker.dh = 200, 100

local unused_items = {}
local used_items = {}

local function itemupdate(item, delta)
  local done = true
  
  local a = item:GetAlpha()
  a = a + delta
  
  if a < 1 then
    item:SetAlpha(a)
    done = false
  else
    item:SetAlpha(1)
  end
  
  local t = item.t + delta
  
  if t < 1 then
    item.t = t
    local it = 1-t
    local sp = math.sqrt(t-t*t)
    item.x, item.y = item.sx*it+item.dx*t+(item.sy-item.dy)*sp, item.sy*it+item.dy*t+(item.dx-item.sx)*sp
    done = false
  else
    item.t = 1
    item.x, item.y = item.dx, item.dy
  end
  
  item:ClearAllPoints()
  item:SetPoint("TOPLEFT", tracker, "TOPLEFT", item.x, item.y)
  
  if done then
    item:SetScript("OnUpdate", nil)
  end
end

local function itemfadeout(item, delta)
  local a = item:GetAlpha()
  a = a - delta
  
  if a > 0 then
    item:SetAlpha(a)
  else
    item:SetAlpha(1)
    item:Hide()
    item:SetScript("OnUpdate", nil)
    return
  end
  
  local t = item.t + delta
  
  if t < 1 then
    item.t = t
    local it = 1-t
    local sp = math.sqrt(t-t*t)
    item.x, item.y = item.sx*it+item.dx*t+(item.sy-item.dy)*sp, item.sy*it+item.dy*t+(item.dx-item.sx)*sp
  else
    item.t = 1
    item.x, item.y = item.dx, item.dy
  end
  
  item:ClearAllPoints()
  item:SetPoint("TOPLEFT", tracker, "TOPLEFT", item.x, item.y)
end

local function addItem(name, obj, y, quest)
  local x = quest and 4 or 20
  local item = used_items[obj]
  if not item then
    item = next(unused_items)
    if item then
      unused_items[item] = nil
    else
      item = CreateFrame("Frame", nil, tracker)
      item.text = item:CreateFontString()
      item.text:SetShadowColor(0, 0, 0, .8)
      item.text:SetShadowOffset(1, -1)
      item.text:SetPoint("TOPLEFT", item)
    end
    
    if quest then
      item.text:SetFont(QuestHelper.font.serif, 12)
      item.text:SetTextColor(.82, .65, 0)
    else
      item.text:SetFont(QuestHelper.font.sans, 12)
      item.text:SetTextColor(.82, .82, .82)
    end
    
    used_items[obj] = item
    item.sx, item.sy, item.x, item.y, item.dx, item.dy, item.t = x+30, y, x, y, x, y, 0
    item:SetScript("OnUpdate", itemupdate)
    item:SetAlpha(0)
    item:Show()
  end
  
  item.used = true
  
  item.text:SetText(name)
  local w, h = item.text:GetWidth(), item.text:GetHeight()
  item:SetWidth(w)
  item:SetHeight(h)
  
  if item.dx ~= x or item.dy ~= y then
    item.sx, item.sy, item.dx, item.dy = item.x, item.y, x, y
    item.t = 0
    item:SetScript("OnUpdate", itemupdate)
  end
  
  return w+x+4, h
end

local resizing = false
local check_delay = 4
local seen = {}
local reverse_map = {}

function tracker:update(delta)
  if not delta then
    -- This is called without a value when the questlog is updated.
    -- We'll make sure we update the display on the next update.
    check_delay = 5
    return
  end
  
  if resizing then
    local t = self.t+delta
    
    if t > 1 then
      self:SetWidth(self.dw)
      self:SetHeight(self.dh)
      resizing = false
    else
      self.t = t
      local it = 1-t
      self:SetWidth(self.sw*it+self.dw*t)
      self:SetHeight(self.sh*it+self.dh*t)
    end
  end
  
  check_delay = check_delay + delta
  if check_delay > 5 then
    check_delay = 0
    
    local quests = QuestHelper.quest_log
    local added = 0
    local x, y = 4, 4
    local gap = 0
    
    for obj, item in pairs(used_items) do
      item.used = false
    end
    
    for i, foo in ipairs(QuestHelper.route) do
      for obj in pairs(foo.before) do
        local info = quests[obj]
        
        if info and not seen[info] then
          seen[info] = true
          added = added + 1
          
          local w, h = addItem(GetQuestLogTitle(info.index), obj, -(y+gap), true)
          x = math.max(x, w)
          y = y + h + gap
          
          gap = 2
          
          if info.goal then
            for i, subinfo in pairs(info.goal) do
              reverse_map[subinfo.objective] = GetQuestLogLeaderBoard(i, info.index)
            end
          
            for i, subobj in ipairs(QuestHelper.route) do
              local name = reverse_map[subobj]
              if name then
                added = added + 1
                w, h = addItem(name, subobj, -y, false)
                x = math.max(x, w)
                y = y + h
              end
            end
            
            for key in pairs(reverse_map) do
              reverse_map[key] = nil
            end
          end
        end
        
        if added > 8 then
          break
        end
      end
      
      if added > 8 then
        break
      end
      
      local info = quests[foo]
      if info and not seen[info] then
        -- Since we should have ran into the quest's objective first, we'll assume this quest doesn't have any.
        seen[info] = true
        added = added + 1
        
        local w, h = addItem(GetQuestLogTitle(info.index), foo, -(y+gap), true)
        x = math.max(x, w)
        y = y + h + gap
        gap = 2
      end
      
      if added > 8 then
        break
      end
    end
    
    for obj, item in pairs(used_items) do
      if not item.used then
        unused_items[item] = true
        used_items[obj] = nil
        item.used = false
        item.t = 0
        item.sx, item.sy = item.x, item.y
        item.dx, item.dy = item.x+30, item.y
        item:SetScript("OnUpdate", itemfadeout)
      end
    end
    
    for key in pairs(seen) do
      seen[key] = false
    end
    
    y = y+4
    
    if x ~= tracker.dw or y ~= tracker.dy then
      tracker.t = 0
      tracker.sw, tracker.sh = tracker:GetWidth(), tracker:GetHeight()
      tracker.dw, tracker.dh = x, y
      resizing = true
    end
    
    added = 0
  end
end

tracker:SetScript("OnUpdate", tracker.update)

-------------------------------------------------------------------------------------------------
-- This batch of stuff is to make sure the original tracker (and any modifications) stay hidden

local orig_TrackerOnShow = QuestWatchFrame:GetScript("OnShow")
local orig_TrackerBackdropOnShow   -- bEQL (and perhaps other mods) add a backdrop to the tracker
local TrackerBackdropFound = false

local function TrackerBackdropOnShow(self, ...)
  if QuestHelper_Pref.track then
    TrackerBackdropFound:Hide()
  end

  if orig_TrackerBackdropOnShow then
    orig_TrackerBackdropOnShow(self, ...)
  end
end

function tracker:HideDefaultTracker()
  -- The easy part: hide the original tracker
  QuestWatchFrame:Hide()

  -- The harder part: check if a known backdrop is present (but we don't already know about it).
  -- If it is, make sure it's hidden, and hook its OnShow to make sure it stays that way.
  -- Unfortunately, I can't figure out a good time to check for this once, so we'll just have
  -- to keep checking.  Hopefully, this won't happen too often.
  if not TrackerBackdropFound then
    if QuestWatchFrameBackdrop then
      -- Found bEQL's QuestWatchFrameBackdrop...
      TrackerBackdropFound = QuestWatchFrameBackdrop
    end

    if TrackerBackdropFound then
      -- OK, we found something - so hide it, and make sure it doesn't rear its ugly head again
      TrackerBackdropFound:Hide()

      orig_TrackerBackdropOnShow = TrackerBackdropFound:GetScript("OnShow")
      TrackerBackdropFound:SetScript("OnShow", TrackerBackdropOnShow)
    end
  end
end

function tracker:ShowDefaultTracker()
  assert(not QuestHelper_Pref.track)

  QuestWatchFrame:Show()

  if TrackerBackdropFound then
    TrackerBackdropFound:Show()
  end
end

local function QuestWatchFrameOnShow(self, ...)
  if QuestHelper_Pref.track then
    tracker:HideDefaultTracker()
  end

  if orig_TrackerOnShow then
    orig_TrackerOnShow(self, ...)
  end
end

QuestWatchFrame:SetScript("OnShow", QuestWatchFrameOnShow)
