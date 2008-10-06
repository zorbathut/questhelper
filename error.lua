QuestHelper_File = {}
QuestHelper_File["error.lua"] = "Development Version"
--[[
  Much of this code is ganked wholesale from Swatter, and is Copyright (C) 2006 Norganna.
]]

local local_version = QuestHelper_File["error.lua"]
local toc_version = GetAddOnMetadata("QuestHelper", "Version")

local origHandler = geterrorhandler()

local QuestHelper_ErrorCatcher = { }

local startup_errors = {}
local completely_started = false
local yelled_at_user = false

local first_error = nil

QuestHelper_Errors = {}
QuestHelper_Errors.crashes = {}

function QuestHelper_ErrorCatcher.TextError(text)
  DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff8080QuestHelper Error Handler: |r%s", text))
end


-- ganked verbatim from Swatter
function QuestHelper_ErrorCatcher.GetAddOns()
	local addlist = ""
	for i = 1, GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)

		local loaded = IsAddOnLoaded(i)
		if (loaded) then
			if not name then name = "Anonymous" end
			name = name:gsub("[^a-zA-Z0-9]+", "")
			local version = GetAddOnMetadata(i, "Version")
			local class = getglobal(name)
			if not class or type(class)~='table' then class = getglobal(name:lower()) end
			if not class or type(class)~='table' then class = getglobal(name:sub(1,1):upper()..name:sub(2):lower()) end
			if not class or type(class)~='table' then class = getglobal(name:upper()) end
			if class and type(class)=='table' then
				if (class.version) then
					version = class.version
				elseif (class.Version) then
					version = class.Version
				elseif (class.VERSION) then
					version = class.VERSION
				end
			end
			local const = getglobal(name:upper().."_VERSION")
			if (const) then version = const end

			if type(version)=='table' then
				if (nLog) then
					nLog.AddMessage("!swatter", "Swatter.lua", N_INFO, "version is a table", name, table.concat(version,":"))
				end
				version = table.concat(version,":")
			end

			if (version) then
				addlist = addlist.."  "..name..", v"..version.."\n"
			else
				addlist = addlist.."  "..name.."\n"
			end
		end
	end
	return addlist
end


-- here's the logic
function QuestHelper_ErrorCatcher.CondenseErrors()
  while next(startup_errors) do
    _, err = next(startup_errors)
    table.remove(startup_errors)
    
    local found = false
    
    for _, item in ipairs(QuestHelper_Errors.crashes) do
      if item.message == err.message and item.stack == err.stack and item.local_version == err.local_version and item.toc_version == err.toc_version and item.addons == err.addons and item.game_version == err.game_version and item.locale == err.locale then
        found = true
        item.count = item.count + 1
      end
    end
    
    if not found then
      table.insert(QuestHelper_Errors.crashes, err)
    end
  end
end

function QuestHelper_ErrorCatcher_ExplicitError(o_msg, o_frame, o_stack, ...)
  msg = o_msg or ""
  stack = o_stack or debugstack(2, 20, 20)

  -- We toss it into StartupErrors, and then if we're running properly, we'll merge it into the main DB.
  local ts = date("%Y-%m-%d %H:%M:%S");
  local addons = QuestHelper_ErrorCatcher.GetAddOns()
  local terror = {
    timestamp = ts,
    addons = addons,
    message = msg,
    stack = stack,
    local_version = local_version,
    toc_version = toc_version,
    game_version = GetBuildInfo(),
    locale = GetLocale(),
    count = 0,
  }
  
  table.insert(startup_errors, terror)
  
  if not first_error then first_error = terror end
  
  if completely_started then QuestHelper_ErrorCatcher.CondenseErrors() end
  
  if not yelled_at_user then
    message("QuestHelper has broken. You may have to restart WoW. Type \"/qh error\" for a detailed error message.")
    yelled_at_user = true
  end
end

function QuestHelper_ErrorCatcher.OnError(o_msg, o_frame, o_stack, o_etype, ...)
  if string.find(o_msg, "QuestHelper") then
    QuestHelper_ErrorCatcher_ExplicitError(o_msg, o_frame, o_stack)
  end
  
  return origHandler(o_msg, o_frame, o_stack, o_etype, unpack(arg or {}))  -- pass it on
end

seterrorhandler(QuestHelper_ErrorCatcher.OnError) -- at this point we can catch errors

function QuestHelper_ErrorCatcher.CompletelyStarted()
  completely_started = true
  QuestHelper_ErrorCatcher.CondenseErrors()
end

function QuestHelper_ErrorCatcher_CompletelyStarted()
  QuestHelper_ErrorCatcher.CompletelyStarted()
end



-- and here is the GUI

local QHE_Gui = {}

function QHE_Gui.ErrorUpdate()
  QHE_Gui.ErrorTextinate()
  QHE_Gui.Error.Box:SetText(QHE_Gui.Error.curError)
  QHE_Gui.Error.Scroll:UpdateScrollChildRect()
	QHE_Gui.Error.Box:ClearFocus()
end

function QHE_Gui.ErrorTextinate()
  if first_error then
    QHE_Gui.Error.curError = string.format("msg: %s\ntoc: %s\nv: %s\ngame: %s\nlocale: %s\ntimestamp: %s\n\n%s\naddons:\n%s", first_error.message, first_error.toc_version, first_error.local_version, first_error.game_version, first_error.locale, first_error.timestamp, first_error.stack, first_error.addons)
  else
    QHE_Gui.Error.curError = "None"
  end
end

function QHE_Gui.ErrorClicked()
	if (QHE_Gui.Error.selected) then return end
	QHE_Gui.Error.Box:HighlightText()
	QHE_Gui.Error.selected = true
end

function QHE_Gui.ErrorDone()
	QHE_Gui.Error:Hide()
end


-- Create our error message frame. Most of this is also ganked from Swatter.
QHE_Gui.Error = CreateFrame("Frame", "QHE_GUIErrorFrame", UIParent)
QHE_Gui.Error:Hide()
QHE_Gui.Error:SetPoint("CENTER", "UIParent", "CENTER")
QHE_Gui.Error:SetFrameStrata("TOOLTIP")
QHE_Gui.Error:SetHeight(300)
QHE_Gui.Error:SetWidth(600)
QHE_Gui.Error:SetBackdrop({
	bgFile = "Interface/Tooltips/ChatBubble-Background",
	edgeFile = "Interface/Tooltips/ChatBubble-BackDrop",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 32, right = 32, top = 32, bottom = 32 }
})
QHE_Gui.Error:SetBackdropColor(0.2,0,0, 1)
QHE_Gui.Error:SetScript("OnShow", QHE_Gui.ErrorShow)
QHE_Gui.Error:SetMovable(true)

QHE_Gui.ProxyFrame = CreateFrame("Frame", "QHE_GuiProxyFrame")
QHE_Gui.ProxyFrame:SetParent(QHE_Gui.Error)
QHE_Gui.ProxyFrame.IsShown = function() return QHE_Gui.Error:IsShown() end
QHE_Gui.ProxyFrame.escCount = 0
QHE_Gui.ProxyFrame.timer = 0
QHE_Gui.ProxyFrame.Hide = (
	function( self )
		local numEscapes = QHE_Gui.numEscapes or 1
		self.escCount = self.escCount + 1
		if ( self.escCount >= numEscapes ) then
			self:GetParent():Hide()
			self.escCount = 0
		end
		if ( self.escCount == 1 ) then
			self.timer = 0
		end
	end
)
QHE_Gui.ProxyFrame:SetScript("OnUpdate",
	function( self, elapsed )
		local timer = self.timer + elapsed
		if ( timer >= 1 ) then
			self.escCount = 0
		end
		self.timer = timer
	end
)
table.insert(UISpecialFrames, "QHE_GuiProxyFrame")

QHE_Gui.Drag = CreateFrame("Button", nil, QHE_Gui.Error)
QHE_Gui.Drag:SetPoint("TOPLEFT", QHE_Gui.Error, "TOPLEFT", 10,-5)
QHE_Gui.Drag:SetPoint("TOPRIGHT", QHE_Gui.Error, "TOPRIGHT", -10,-5)
QHE_Gui.Drag:SetHeight(8)
QHE_Gui.Drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")

QHE_Gui.Drag:SetScript("OnMouseDown", function() QHE_Gui.Error:StartMoving() end)
QHE_Gui.Drag:SetScript("OnMouseUp", function() QHE_Gui.Error:StopMovingOrSizing() end)

QHE_Gui.Error.Done = CreateFrame("Button", "", QHE_Gui.Error, "OptionsButtonTemplate")
QHE_Gui.Error.Done:SetText("Close")
QHE_Gui.Error.Done:SetPoint("BOTTOMRIGHT", QHE_Gui.Error, "BOTTOMRIGHT", -10, 10)
QHE_Gui.Error.Done:SetScript("OnClick", QHE_Gui.ErrorDone)

QHE_Gui.Error.Mesg = QHE_Gui.Error:CreateFontString("", "OVERLAY", "GameFontNormalSmall")
QHE_Gui.Error.Mesg:SetJustifyH("LEFT")
QHE_Gui.Error.Mesg:SetPoint("TOPRIGHT", QHE_Gui.Error.Prev, "TOPLEFT", -10, 0)
QHE_Gui.Error.Mesg:SetPoint("LEFT", QHE_Gui.Error, "LEFT", 15, 0)
QHE_Gui.Error.Mesg:SetHeight(20)
QHE_Gui.Error.Mesg:SetText("Select All and Copy the above error message to report this bug.")

QHE_Gui.Error.Scroll = CreateFrame("ScrollFrame", "QHE_GUIErrorInputScroll", QHE_Gui.Error, "UIPanelScrollFrameTemplate")
QHE_Gui.Error.Scroll:SetPoint("TOPLEFT", QHE_Gui.Error, "TOPLEFT", 20, -20)
QHE_Gui.Error.Scroll:SetPoint("RIGHT", QHE_Gui.Error, "RIGHT", -30, 0)
QHE_Gui.Error.Scroll:SetPoint("BOTTOM", QHE_Gui.Error.Done, "TOP", 0, 10)

QHE_Gui.Error.Box = CreateFrame("EditBox", "QHE_GUIErrorEditBox", QHE_Gui.Error.Scroll)
QHE_Gui.Error.Box:SetWidth(500)
QHE_Gui.Error.Box:SetHeight(85)
QHE_Gui.Error.Box:SetMultiLine(true)
QHE_Gui.Error.Box:SetAutoFocus(false)
QHE_Gui.Error.Box:SetFontObject(GameFontHighlight)
QHE_Gui.Error.Box:SetScript("OnEscapePressed", QHE_Gui.ErrorDone)
QHE_Gui.Error.Box:SetScript("OnTextChanged", QHE_Gui.ErrorUpdate)
QHE_Gui.Error.Box:SetScript("OnEditFocusGained", QHE_Gui.ErrorClicked)

QHE_Gui.Error.Scroll:SetScrollChild(QHE_Gui.Error.Box)

function QuestHelper_ErrorCatcher_ReportError()
  QHE_Gui.Error.selected = false
	QHE_Gui.ErrorUpdate()
	QHE_Gui.Error:Show()
end
