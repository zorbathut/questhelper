persistence =
{
	store = function (f, item)
		if f then
			persistence.write(f, item, 0);
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
        local order = {}
        for k, v in pairs(item) do
          table.insert(order, k)
        end
        table.sort(order)
        
				for _, v in pairs(order) do
					persistence.writeIndent(f, level+1);
					f:write("[");
					persistence.write(f, v, level+1);
					f:write("] = ");
					persistence.write(f, item[v], level+1);
					f:write(",\n");
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
