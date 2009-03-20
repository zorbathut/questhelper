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
        
        -- First we test to see if it's a trivial flat layout
        local isflat = true
        do
          local idx = 1
          for k, v in ipairs(item) do
            if k ~= idx then isflat = false break end
            idx = idx + 1
          end
        end
        
        local order = {}
        for k, v in pairs(item) do
          table.insert(order, k)
        end
        
        if #order ~= #item then isflat = false end
        
        if isflat then
          -- We're flat! Special case.
          --f:write("--[[isflat]]")
          for k, v in ipairs(item) do
            if k ~= 1 then
              f:write(", ")
            end
            
            persistence.write(f, v, level+1)
          end
        else
          --f:write(string.format("--[[notflat %d/%d]]", #order, #item))
          table.sort(order, function (a, b)
            if type(a) == type(b) then return a < b end
            return type(a) < type(b)
          end)
          
          local first = true
          for _, v in pairs(order) do
            if not first then f:write(",\n") end
            first = false
            persistence.writeIndent(f, level+1);
            
            if type(v) == "string" and v:match("[a-z]+") then
              f:write(v)
            else
              f:write("[");
              persistence.write(f, v, level+1);
              f:write("]");
            end
            f:write(" = ");
            
            persistence.write(f, item[v], level+1);
          end
          f:write("\n")
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
