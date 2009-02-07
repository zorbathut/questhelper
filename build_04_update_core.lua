
assert(arg[1])

-- we pretend to be WoW
function GetTime() end
QuestHelper_File = {}
QuestHelper_Loadtime = {}

loadfile("../questhelper/collect_upgrade.lua")() -- this is kind of unnecessary
loadfile("../questhelper/upgrade.lua")()

dat = loadfile(arg[1])
if not dat then io.stderr:write("  Did not load\n") return end

local chunk = {}
setfenv(dat, chunk)
if not pcall(dat) then io.stderr:write("  Did not run\n") return end

local csave = {}

for _, v in pairs({"QuestHelper_Collector", "QuestHelper_Collector_Version", "QuestHelper_UID", "QuestHelper_SaveDate"}) do
  if not chunk[v] then io.stderr:write(string.format("  Did not contain %s\n", v)) return end
end

for _, v in pairs({"QuestHelper_Collector", "QuestHelper_Collector_Version", "QuestHelper_UID", "QuestHelper_SaveDate", "QuestHelper_Errors"}) do
  csave[v] = chunk[v]
end

local neededutils = {"pairs", "type"}

for _, v in pairs(neededutils) do
  csave[v] = _G[v]
end

setfenv(QH_Collector_Upgrade, csave)
QH_Collector_Upgrade()

for _, v in pairs(neededutils) do
  csave[v] = nil
end

-- At some point we'll need to toss the private server filtering in here.

------------------
--
-- Here is a gigantic wad of code from the lua users wiki.

persistence =
{
	store = function (path, ...)
		local f = { write = function(self, dat) io.write(dat) end }
		if f then
			f:write("-- Persistent Data\n");
			f:write("return ");
			persistence.write(f, select(1,...), 0);
			for i = 2, select("#", ...) do
				f:write(",\n");
				persistence.write(f, select(i,...), 0);
			end;
			f:write("\n");
		else
			error(e);
		end;
	end;
	
	load = function (path)
		local f, e = loadfile(path);
		if f then
			return f();
		else
			return nil, e;
			--error(e);
		end;
	end;
	
	write = function (f, item, level)
		local t = type(item);
		persistence.writers[t](f, item, level);
	end;
	
	writeIndent = function (f, level)
		for i = 1, level do
			f:write("\t");
		end;
	end;
	
	writers = {
		["nil"] = function (f, item, level)
				f:write("nil");
			end;
		["number"] = function (f, item, level)
				f:write(tostring(item));
			end;
		["string"] = function (f, item, level)
				f:write(string.format("%q", item));
			end;
		["boolean"] = function (f, item, level)
				if item then
					f:write("true");
				else
					f:write("false");
				end
			end;
		["table"] = function (f, item, level)
				f:write("{\n");
				for k, v in pairs(item) do
					persistence.writeIndent(f, level+1);
					f:write("[");
					persistence.write(f, k, level+1);
					f:write("] = ");
					persistence.write(f, v, level+1);
					f:write(";\n");
				end
				persistence.writeIndent(f, level);
				f:write("}");
			end;
		["function"] = function (f, item, level)
				-- Does only work for "normal" functions, not those
				-- with upvalues or c functions
				local dInfo = debug.getinfo(item, "uS");
				if dInfo.nups > 0 then
					f:write("nil -- functions with upvalue not supported\n");
				elseif dInfo.what ~= "Lua" then
					f:write("nil -- function is not a lua function\n");
				else
					local r, s = pcall(string.dump,item);
					if r then
						f:write(string.format("loadstring(%q)", s));
					else
						f:write("nil -- function could not be dumped\n");
					end
				end
			end;
		["thread"] = function (f, item, level)
				f:write("nil --thread\n");
			end;
		["userdata"] = function (f, item, level)
				f:write("nil --userdata\n");
			end;
	}
}

---- Okay that's the end of the wad of code
  
persistence.store("tmpout.lua", csave)  -- The filename is an artifact of the code, I don't feel like fixing it
