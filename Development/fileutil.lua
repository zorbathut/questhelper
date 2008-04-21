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

local home = os.getenv("HOME")

FileUtil.fileName = function(filename)
  local home_path = select(3, string.find(filename, "^~(.*)$"))
  
  if home_path then
    return (is_windows and (os.getenv("HOMEDRIVE")..os.getenv("HOMEPATH")) or os.getenv("HOME"))..home_path
  end
  
  return filename
end


FileUtil.quoteFileWindows = function (filename)
  -- Escapes filenames in Windows, and converts slashes to backslashes.
  
  filename = FileUtil.fileName(filename)
  
  if filename == "" then return "\"\"" end
  
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
end

FileUtil.quoteFileNix = function (filename)
  -- Escapes filenames in *nix, and converts backslashes  to slashes.
  -- Also used directly for URLs, which are always *nix style paths
  
  filename = FileUtil.fileName(filename)
  
  if filename == "" then return "\"\"" end
  
  local result = ""
  for i=1,string.len(filename) do
    local c = string.sub(filename, i, i)
    if c == "\\" then
      c = "/"
    elseif string.find(c, "[^/%.%-%a%d]") then
      c = "\\"..c
    end
    
    result = result .. c
  end
  
  return result
end

FileUtil.quoteFile = is_windows and FileUtil.quoteFileWindows or FileUtil.quoteFileNix

local function escapeForPattern(text)
  return string.gsub(text, "[%%%^%$%.%+%*%-%?%[%]]", function (x) return "%"..x end)
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
    return select(3, string.find(line, string.format("^([abcdef%%d]+)  %s$", escapeForPattern(filename))))
  end
end

FileUtil.fileExists = function(filename)
  local stream = io.open(FileUtil.fileName(filename), "r")
  if stream then
    local exists = stream:read() ~= nil
    io.close(stream)
    return exists
  end
  return false
end

FileUtil.isDirectory = function(filename)
  -- TODO: Windows version of this.
  local stream = io.popen(string.format("file -b %s", FileUtil.quoteFile(filename)), "r")
  if stream then
    local result = stream:read("*line")
    io.close(stream)
    return result == "directory"
  end
  error("Failed to execute 'file' command.")
end

-- Extra strings passed to copyFile are pattern/replacement pairs, applied to
-- each line of the file being copied.
FileUtil.copyFile = function(in_name, out_name, ...)
  local extra = select("#", ...)
  
  if FileUtil.isDirectory(out_name) then
    -- If out_name is a directory, change it to a filename.
    out_name = string.format("%s/%s", out_name, select(3, string.find(in_name, "([^/\\]*)$")))
  end
  
  if extra > 0 then
    assert(extra%2==0, "Odd number of arguments.")
    local src = io.open(in_name, "rb")
    if src then
      local dest = io.open(out_name, "wb")
      if dest then
        while true do
          local original = src:read("*line")
          if not original then break end
          local eol
          original, eol = select(3, string.find(original, "^(.-)(\r?)$")) -- Try to keep the CR in CRLF codes intact.
          local replacement = original
          for i = 1,extra,2 do
            local a, b = select(i, ...)
            replacement = string.gsub(replacement, a, b)
          end
          
          -- If we make a line blank, and it wasn't blank before, we omit the line.
          if original == replacement or replacement ~= "" then
            dest:write(replacement, eol, "\n")
          end
        end
        io.close(dest)
      else
        print("Failed to copy "..in_name.." to "..out_name)
      end
      io.close(src)
    else
      print("Failed to copy "..in_name.." to "..out_name)
    end
  elseif os.execute(string.format(is_windows and "COPY %s %s" or "cp %s %s", FileUtil.quoteFile(in_name), FileUtil.quoteFile(out_name))) ~= 0 then
    print("Failed to copy "..in_name.." to "..out_name)
  end
end

FileUtil.forEachFile = function(directory, func)
  if directory == "" then
    directory = "."
  end
  
  local stream = io.popen(string.format(is_windows and "DIR /B %s" or "ls -1 %s", FileUtil.quoteFile(directory)))
  
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
  local ext = select(3, string.find(filename, ".*%.(.-)$"))
  if ext and not string.find(ext, "[/\\]") then
    return ext
  end
  return ""
end

FileUtil.updateSVNRepo = function(url, directory)
  -- Check for the SVN entries file, which should exist regardless of OS; fileExists doesn't work for directories under Windows.
  if FileUtil.fileExists(directory.."/.svn/entries") then
    if os.execute(string.format("svn up -q %s", FileUtil.quoteFile(directory))) ~= 0 then
      print("Failed to update svn repository: "..directory.." ("..url..")")
    end
  else
    -- quoteFile on Windows results in invalid URLs, so just wrap it in quotes and be done with it
    if os.execute(string.format("svn co -q %s %s", is_windows and "\""..url.."\"" or FileUtil.quoteFile(url), FileUtil.quoteFile(directory))) ~= 0 then
      print("Failed to up fetch svn repository: "..directory.." ("..url..")")
    end
  end
end

FileUtil.createDirectory = function(directory)
  if os.execute(string.format(is_windows and "MD %s" or "mkdir -p %s", FileUtil.quoteFile(directory))) ~= 0 then
    print("Failed to create directory: "..directory)
  end
end

FileUtil.unlinkDirectory = function(directory)
  if os.execute(string.format(is_windows and "RMDIR /S /Q %s" or "rm -rf %s", FileUtil.quoteFile(directory))) ~= 0 then
    print("Failed to unlink directory: "..directory)
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
    print("Failed to create zip archive: "..archive)
  end
end

FileUtil.create7zArchive = function(directory, archive)
  if os.execute(string.format("7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on %s %s", FileUtil.quoteFile(archive), FileUtil.quoteFile(directory))) ~= 0 then
    print("Failed to create 7z archive: "..archive)
  end
end