FileUtil = {}

--[[ Note:
     
     fileHash and forEachFile will probably need replacements for other operating systems. ]]

--[[ Warning:
     
     Pretty much all these functions can be made to do something malicious if given bad file names;
     don't use input from untrusted sources. ]]

FileUtil.fileHash = function(filename)
  local stream = io.popen(string.format("sha1sum %q", filename))
  local line = stream:read()
  io.close(stream)
  if line then
    return select(3, string.find(line, "^([abcdef%d]+)  "..filename.."$"))
  end
end

FileUtil.fileExists = function(filename)
  local stream = io.open(filename, "r")
  if stream then
    local exists = stream:read() ~= nil
    io.close(stream)
    return exists
  end
  return false
end

FileUtil.copyFile = function(in_name, out_name)
  if in_name ~= out_name then
    local in_stream, out_stream = io.open(in_name, "r"), io.open(out_name, "w")
    out_stream:write(in_stream:read("*a"))
    io.close(in_stream)
    io.close(out_stream)
  end
end

FileUtil.forEachFile = function(directory, func)
  local stream = io.popen(string.format("ls -f1 %q", directory))
  if not stream then stream = io.popen(string.format("DIR //B %q", directory)) end
  
  if stream then
    while true do
      local filename = stream:read()
      if not filename then break end
      filename = directory.."/"..filename
      if string.sub(filename, 1, 1) ~= "." and FileUtil.fileExists(filename) then
        func(filename)
      end
    end

    io.close(stream)
  end
end