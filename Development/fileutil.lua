FileUtil = {}

--[[ Note:
     
     fileHash and forEachFile will probably need replacements for other operating systems. ]]

--[[ Warning:
     
     Pretty much all these functions can be made to do something malicious if given bad file names;
     don't use input from untrusted sources. ]]

-- Our horrible test to check if you're using Windows or not.
local is_windows = os.getenv("HOMEDRIVE") ~= nil or
                   os.getenv("WINDIR") ~= nil or
                   os.getenv("OS") == "Windows_NT"

print(is_windows and "Is Windows!" or "Not Windows!")

FileUtil.quoteFile = is_windows and function(filename)
  -- Escapes file names in Windows, and converts slashes to backslashes.
  local result = ""
  for i=1,string.len(filename) do
    local c = string.sub(filename, i, i)
    if c == "/" then
      c = "\\"
    elseif string.find(c, "[^\\%.%a%d]") then
      c = "^"..c
    end
    
    result = result .. c
  end
  return result
end or function(filename)
  -- Escapes file names in *nix, and converts backslashes  to slashes.
  local result = ""
  for i=1,string.len(filename) do
    local c = string.sub(filename, i, i)
    if c == "\\" then
      c = "/"
    elseif string.find(c, "[^/%.%a%d]") then
      c = "\\"..c
    end
    
    result = result .. c
  end
  
  return result
end

FileUtil.fileHash = function(filename)
  local stream = io.popen(string.format("sha1sum %s", FileUtil.quoteFile(filename)))
  
  if not stream then
    print("Failed to calculate hash: "..filename)
    return nil
  end
  
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
  if os.execute(string.format(is_windows and "COPY %s %s" or "cp %s %s", FileUtil.quoteFile(in_name), FileUtil.quoteFile(out_name))) ~= 0 then
    print("Failed to copy "..in_name.." to "..out_name)
  end
end

FileUtil.forEachFile = function(directory, func)
  if directory == "" then
    directory = "."
  end
  
  local stream = io.popen(string.format(is_windows and "DIR //B %s" or "ls -f1 %s", FileUtil.quoteFile(directory)))
  
  if not stream then
    print("Failed to read directory contents: "..directory)
    return
  end
  
  while true do
    local filename = stream:read()
    if not filename then break end
    filename = directory.."/"..filename
    
    if FileUtil.fileExists(filename) then
      func(filename)
    end
  end
  
  io.close(stream)
end

FileUtil.extension = function(filename)
  local ext = select(2, string.find(filename, "%.(.-)$"))
  if ext and not string.find(ext, "[/\\]") then
    return ext
  end
  return ""
end

FileUtil.createDirectory = function(directory)
  if os.execute(string.format(is_windows and "MD %s" or "mkdir -p %s", FileUtil.quoteFile(directory))) ~= 0 then
    print("Failed to create directory: "..directory)
  end
end

FileUtil.unlinkFile = function(filename)
  if os.execute(string.format(is_windows and "DEL /Q %s" or "rm -rf %s", FileUtil.quoteFile(filename))) ~= 0 then
    print("Failed to unlink file: "..filename)
  end
end

FileUtil.convertImage = function(source, dest)
  if os.execute(string.format("convert -background None %s %s", FileUtil.quoteFile(source), FileUtil.quoteFile(dest))) ~= 0 then
    print("Failed to convert: "..source)
  end
end

FileUtil.createZipArchive = function(directory, archive)
  if os.execute(string.format("zip -rq9 %s %s", FileUtil.quoteFile(archive), FileUtil.quoteFile(directory))) ~= 0 then
    print("Failed to create archive: "..archive)
  end
end
