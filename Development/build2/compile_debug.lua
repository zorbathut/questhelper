
-- This is pretty much a copy of code from inside build_04_update_core.lua

local persistence_loc

persistence_loc =
{
	store = function (path, ...)
		local f = { write = function(self, dat) io.write(dat) end }
		if f then
			persistence_loc.write(f, select(1,...), 0);
			for i = 2, select("#", ...) do
				f:write(", ");
				persistence_loc.write(f, select(i,...), 0);
			end;
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
		persistence_loc.writers[t](f, item, level);
	end;
	
	writeIndent = function (f, level)
    f:write(" ")
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
				f:write("{");
				for k, v in pairs(item) do
					persistence_loc.writeIndent(f, level+1);
					f:write("[");
					persistence_loc.write(f, k, level+1);
					f:write("] = ");
					persistence_loc.write(f, v, level+1);
					f:write(";");
				end
				persistence_loc.writeIndent(f, level);
				f:write("}");
			end;
		["function"] = function (f, item, level)
				-- Does only work for "normal" functions, not those
				-- with upvalues or c functions
				local dInfo = debug.getinfo(item, "uS");
				if dInfo.nups > 0 then
					f:write("nil --[[functions with upvalue not supported]]\n");
				elseif dInfo.what ~= "Lua" then
					f:write("nil --[[function is not a lua function]]\n");
				else
					local r, s = pcall(string.dump,item);
					if r then
						f:write(string.format("loadstring(%q)", s));
					else
						f:write("nil --[[function could not be dumped]]\n");
					end
				end
			end;
		["thread"] = function (f, item, level)
				f:write("nil --[[thread]]\n");
			end;
		["userdata"] = function (f, item, level)
				f:write("nil --[[userdata]]\n");
			end;
	}
}

---- Okay that's the end of the wad of code

function dbgout(item)
  persistence_loc.store("tmpout.lua", item)  -- The filename is an artifact of the code, I don't feel like fixing it
  io.write("\n")
end
