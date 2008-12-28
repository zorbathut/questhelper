QuestHelper_File["collect_object.lua"] = "Development Version"
QuestHelper_Loadtime["collect_object.lua"] = GetTime()

local debug_output = false
if QuestHelper_File["collect_object.lua"] == "Development Version" then debug_output = true end

local QHCO

local GetLoc
local Merger
local Patterns

local minetypes = {
  mine = UNIT_SKINNABLE_ROCK,
  herb = UNIT_SKINNABLE_HERB,
  eng = UNIT_SKINNABLE_BOLTS,
  skin = UNIT_SKINNABLE_LEATHER,
}

local function Tooltipy(self, ...)
  -- objects are a bitch since they have no unique ID or any standard way to detect them (that I know of).
  -- So we kind of guess at it.
  if self:GetAnchorType() == "ANCHOR_NONE" then
    if self:GetItem() or self:GetUnit() or self:GetSpell() then return end
    -- rglrglrglrglrglrgl
    
    local skintype = nil
    
    local lines = GameTooltip:NumLines()
    if lines > 2 then -- not a normal world item
      return
    elseif lines == 2 then -- see if we're mine or herb
      for k, v in pairs(minetypes) do
        if _G["GameTooltipTextLeft2"]:GetText() == v then
          skintype = k
        end
      end
      if not skintype then return end -- we are neither!
    else
      return
      -- It looks like a lot of UI mods just end up displaying zero-line tooltips. Argh. Tinytip seems to be the worst offender. Guess this goes bye-bye, so much for errorchecking.
      --QuestHelper: Assert(lines == 1, string.format("Zorba knew there was going to be bug here, but couldn't figure out how to check it more throughly. Please report this, and if possible, say what you just moved the mouse over! Thanks!")) -- I just know this is going to break in stupid ways later on
    end
    
    local name = _G["GameTooltipTextLeft1"]:GetText()
    
    if string.match(name, Patterns.CORPSE_TOOLTIP) then return end  -- no corpses plzkthx
    
    if not QHCO[name] then QHCO[name] = {} end
    local qhci = QHCO[name]
    
    for k, _ in pairs(minetypes) do
      if k == skintype then
        qhci[k .. "_yes"] = (qhci[k .. "_yes"] or 0) + 1
      else
        qhci[k .. "_no"] = (qhci[k .. "_no"] or 0) + 1
      end
    end
    
    -- We have no unique identifier, so I'm just going to record every position we see. That said, I wonder if it's a good idea to add a cooldown.
    -- Obviously, we also have no possible range data, so, welp.
    Merger.Add(qhci, GetLoc(), true)    
  end
end

function QH_Collect_Object_Init(QHCData, API)
  if not QHCData.object then QHCData.object = {} end
  QHCO = QHCData.object
  
  API.Registrar_TooltipHook(Tooltipy)
  
  Patterns = API.Patterns
  QuestHelper: Assert(Patterns)
  
  API.Patterns_Register("CORPSE_TOOLTIP", "[^%s]+")
  
  GetLoc = API.Callback_LocationBolusCurrent
  QuestHelper: Assert(GetLoc)
  
  Merger = API.Utility_Merger
  QuestHelper: Assert(Merger)
end
