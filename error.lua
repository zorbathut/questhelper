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

local first_error = nil

QuestHelper_ErrorList = {}

local origItemRef = Swatter.origItemRef

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

function QuestHelper_ErrorCatcher.CondenseErrors()
  while next(startup_errors) do
    err = next(startup_errors)
    table.remove(startup_errors)
    
    local found = false
    
    for _, item in ipairs(QuestHelper_ErrorList) do
      if item.message == err.message and item.stack == err.stack and item.local_version == err.local_version and item.toc_version == err.toc_version and item.addons == err.addons then
        QuestHelper_ErrorCatcher.TextError("condensing " .. item.message)
        found = true
        item.count = item.count + 1
      end
    end
    
    if not found then
      QuestHelper_ErrorCatcher.TextError("inserting " .. item.message)
      table.insert(QuestHelper_ErrorList, err)
    end
  end
end

function QuestHelper_ErrorCatcher.OnError(o_msg, o_frame, o_stack, o_etype, ...)
  QuestHelper_ErrorCatcher.TextError("we can has error now? " .. o_msg)

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
    count = 0,
  }
  
  table.insert(startup_errors.errors, terror)
  
  if not first_error then first_error = terror end
  
  if completely_started then QuestHelper_ErrorCatcher.CondenseErrors() end
  
  QuestHelper_ErrorCatcher.TextError("passin' it on")
  return origHandler(o_msg, o_frame, o_stack, o_etype, unpack(arg))  -- pass it on
end

seterrorhandler(QuestHelper_ErrorCatcher.OnError)

function QuestHelper_ErrorCatcher.CompletelyStarted()
  QuestHelper_ErrorCatcher.TextError("we is completely started")
  
  completely_started = true
  QuestHelper_ErrorCatcher.CondenseErrors()
  
  if first_error then
    DEFAULT_CHAT_FRAME:AddMessage("shit is fucked, dawg")
  end
end

function QuestHelper_ErrorCatcher_CompletelyStarted()
  QuestHelper_ErrorCatcher.CompletelyStarted()
end
