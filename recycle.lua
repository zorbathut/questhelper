QuestHelper_File["recycle.lua"] = "Development Version"

QuestHelper.used_tables = 0
QuestHelper.free_tables = {}

local unused_meta = {__index=error, __newindex=error}

QuestHelper.used_textures = 0
QuestHelper.free_textures = {}

QuestHelper.used_text = 0
QuestHelper.free_text = {}

QuestHelper.used_frames = 0
QuestHelper.free_frames = {}

-- This little table rigs up a basic typing system to assist with debugging. It has weak-reference keys so it shouldn't ever lead to leaks of any kind.
QuestHelper.recycle_tabletyping = setmetatable({}, {__mode="k"})

function QuestHelper:CreateTable(tag)
  local tbl = next(self.free_tables)
  self.used_tables = self.used_tables + 1
  
  if not tbl then
    tbl = {}
  else
    self.free_tables[tbl] = nil
    setmetatable(tbl, nil)
  end
  
  --self.recycle_tabletyping[tbl] = tag or "untyped"
  self.recycle_tabletyping[tbl] = tag or string.gsub(debugstack(2, 1, 1), "\n.*", "")
  return tbl
end

function QuestHelper:ReleaseTable(tbl)
  assert(type(tbl) == "table")
  assert(not self.free_tables[tbl])
  
  for key in pairs(tbl) do
    tbl[key] = nil
  end
  
  self.used_tables = self.used_tables - 1
  self.free_tables[setmetatable(tbl, unused_meta)] = true
  self.recycle_tabletyping[tbl] = nil
end

function QuestHelper:DumpTableTypeFrequencies()
  local freq = {}
  for k, v in pairs(self.recycle_tabletyping) do
    freq[v] = (freq[v] or 0) + 1
  end
  
  local flist = {}
  for k, v in pairs(freq) do
    table.insert(flist, {count=v, name=k})
  end
  
  table.sort(flist, function(a, b) return a.count < b.count end)
  
  for k, v in pairs(flist) do
    self:TextOut(v.count .. ": " .. v.name)
  end
end

function QuestHelper:CreateFrame(parent)
  self.used_frames = self.used_frames + 1
  local frame = table.remove(self.free_frames)
  
  if frame then
    frame:SetParent(parent)
  else
    frame = CreateFrame("Button", string.format("QuestHelperFrame%d",self.used_frames), parent)
  end
  
  frame:SetFrameLevel((parent or UIParent):GetFrameLevel()+1)
  frame:SetFrameStrata("MEDIUM")
  frame:Show()
  
  return frame
end

local frameScripts =
 {
  "OnChar",
  "OnClick",
  "OnDoubleClick",
  "OnDragStart",
  "OnDragStop",
  "OnEnter",
  "OnEvent",
  "OnHide",
  "OnKeyDown",
  "OnKeyUp",
  "OnLeave",
  "OnLoad",
  "OnMouseDown",
  "OnMouseUp",
  "OnMouseWheel",
  "OnReceiveDrag",
  "OnShow",
  "OnSizeChanged",
  "OnUpdate",
  "PostClick",
  "PreClick"
 }

function QuestHelper:ReleaseFrame(frame)
  assert(type(frame) == "table")
  for i,t in ipairs(self.free_frames) do assert(t ~= frame) end
  
  for key in pairs(frame) do
    -- Remove all keys except 0, which seems to hold some special data.
    if key ~= 0 then
      frame[key] = nil
    end
  end
  
  for i, script in ipairs(frameScripts) do
    frame:SetScript(script, nil)
  end
  
  frame:Hide()
  frame:SetParent(QuestHelper)
  frame:ClearAllPoints()
  frame:SetMovable(false)
  frame:RegisterForDrag()
  frame:RegisterForClicks()
  frame:SetBackdrop(nil)
  frame:SetScale(1)
  frame:SetAlpha(1)
  
  self.used_frames = self.used_frames - 1
  table.insert(self.free_frames, frame)
end

function QuestHelper:CreateText(parent, text_str, text_size, text_font, r, g, b, a)
  self.used_text = self.used_text + 1
  local text = table.remove(self.free_text)
  
  if text then
    text:SetParent(parent)
  else
    text = parent:CreateFontString()
  end
  
  text:SetFont(text_font or QuestHelper.font.sans or ChatFontNormal:GetFont(), text_size or 12)
  text:SetDrawLayer("OVERLAY")
  text:SetJustifyH("CENTER")
  text:SetJustifyV("MIDDLE")
  text:SetTextColor(r or 1, g or 1, b or 1, a or 1)
  text:SetText(text_str or "")
  text:SetShadowColor(0, 0, 0, 0.3)
  text:SetShadowOffset(1, -1)
  text:Show()
  
  return text
end

function QuestHelper:ReleaseText(text)
  assert(type(text) == "table")
  for i,t in ipairs(self.free_text) do assert(t ~= text) end
  
  for key in pairs(text) do
    -- Remove all keys except 0, which seems to hold some special data.
    if key ~= 0 then
      text[key] = nil
    end
  end
  
  text:Hide()
  text:SetParent(UIParent)
  text:ClearAllPoints()
  self.used_text = self.used_text - 1
  table.insert(self.free_text, text)
end

function QuestHelper:CreateTexture(parent, r, g, b, a)
  self.used_textures = self.used_textures + 1
  local tex = table.remove(self.free_textures)
  
  if tex then
    tex:SetParent(parent)
  else
    tex = parent:CreateTexture()
  end
  
  if not tex:SetTexture(r, g, b, a) and
     not tex:SetTexture("Interface\\Icons\\Temp.blp") then
    tex:SetTexture(1, 0, 1, 0.5)
  end
  
  tex:ClearAllPoints()
  tex:SetTexCoord(0, 1, 0, 1)
  tex:SetVertexColor(1, 1, 1, 1)
  tex:SetDrawLayer("ARTWORK")
  tex:SetBlendMode("BLEND")
  tex:SetWidth(12)
  tex:SetHeight(12)
  tex:Show()
  
  return tex
end

function QuestHelper:CreateIconTexture(parent, id)
  local icon = self:CreateTexture(parent, "Interface\\AddOns\\QuestHelper\\Art\\Icons.tga")
  
  local w, h = 1/8, 1/8
  local x, y = ((id-1)%8)*w, math.floor((id-1)/8)*h
  
  icon:SetTexCoord(x, x+w, y, y+h)
  
  return icon
end

function QuestHelper:CreateDotTexture(parent)
  local icon = self:CreateIconTexture(parent, 13)
  icon:SetWidth(5)
  icon:SetHeight(5)
  icon:SetVertexColor(0, 0, 0, 0.35)
  return icon
end

function QuestHelper:CreateGlowTexture(parent)
  local tex = self:CreateTexture(parent, "Interface\\Addons\\QuestHelper\\Art\\Glow.tga")
  
  local angle = math.random()*6.28318530717958647692528676655900576839433879875021164
  local x, y = math.cos(angle)*0.707106781186547524400844362104849039284835937688474036588339869,
               math.sin(angle)*0.707106781186547524400844362104849039284835937688474036588339869
  
  -- Randomly rotate the texture, so they don't all look the same.
  tex:SetTexCoord(x+0.5, y+0.5, y+0.5, 0.5-x, 0.5-y, x+0.5, 0.5-x, 0.5-y)
  tex:ClearAllPoints()
  
  return tex
end

function QuestHelper:ReleaseTexture(tex)
  assert(type(tex) == "table")
  for i,t in ipairs(self.free_textures) do assert(t ~= tex) end
  
  for key in pairs(tex) do
    -- Remove all keys except 0, which seems to hold some special data.
    if key ~= 0 then
      tex[key] = nil
    end
  end
  
  tex:Hide()
  tex:SetParent(UIParent)
  tex:ClearAllPoints()
  self.used_textures = self.used_textures - 1
  table.insert(self.free_textures, tex)
end

QuestHelper.recycle_active_cached_tables = {}
QuestHelper.recycle_decache_queue = {}

function QuestHelper:CacheRegister(obj)
  if not self.recycle_active_cached_tables[obj] then
    self.recycle_active_cached_tables[obj] = true
    table.insert(self.recycle_decache_queue, obj)
  end
end

function QuestHelper:CacheCleanup(obj)
  local target = self.recycle_decache_queue[1]
  
  if not target then return end
  table.remove(self.recycle_decache_queue, 1)
  self.recycle_active_cached_tables[target] = nil
  
  if target.distance_cache then
    for k, v in pairs(target.distance_cache) do
      self:ReleaseTable(v)
    end
    self:ReleaseTable(target.distance_cache)
    target.distance_cache = self:CreateTable("objective.distance_cache cleaned")
  end
end

function QuestHelper:DumpCacheData(obj)
  local caches = 0
  local cached = 0
  for k, v in pairs(self.recycle_decache_queue) do
    caches = caches + 1
    if v.distance_cache then
      for q, w in pairs(v.distance_cache) do
        cached = cached + 1
      end
    end
  end
  
  self:TextOut(caches .. " queued caches with a total of " .. cached .. " cached items")
end
