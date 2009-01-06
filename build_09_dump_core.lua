
assert(arg[1])

dat = loadfile(arg[1])
if not dat then io.stderr:write("  Did not load\n") return end

rv, data = pcall(dat)
if not rv then io.stderr:write("  Did not run\n") return 1 end

-- At some point we'll need to toss the private server filtering in here.

------------------
--
-- Here is a gigantic wad of code from the lua users wiki.

persistence =
{
	store = function (path, ...)
		local f = { write = function(self, dat) io.write(dat) end }
		if f then
			persistence.write(f, select(1,...));
		else
			error(e);
		end;
	end;
	
	write = function (f, item)
		local t = type(item);
		persistence.writers[t](f, item);
	end;
	
	writers = {
		["nil"] = function (f, item, level)
				f:write("Ii");
			end;
		["number"] = function (f, item, level)
				f:write(string.format("N%sn", tostring(item)));
			end;
		["string"] = function (f, item, level)
				f:write(string.format("SN%dn", item:len()) .. item .. "s");
			end;
		["boolean"] = function (f, item, level)
				if item then
					f:write("BTb");
				else
					f:write("BFb");
				end
			end;
		["table"] = function (f, item, level)
        local ct = 0
        for k, v in pairs(item) do ct = ct + 1 end
        f:write(string.format("TN%dn", ct))
				for k, v in pairs(item) do
					persistence.write(f, k);
					persistence.write(f, v);
				end
        f:write("t");
			end;
	}
}

---- Okay that's the end of the wad of code
  
persistence.store("tmpout.lua", data)  -- The filename is an artifact of the code, I don't feel like fixing it
