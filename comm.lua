
-- We can't send more than 256 bytes per message.
local comm_version = 1
local max_msg_size = 256-4-1-1 -- To allow room for "QHpr\t" ... "\0"
local max_chunk_size = max_msg_size - 2 -- To allow room for prefix of "x:"

function QuestHelper:SendData(data,name)
  if QuestHelper_Pref.comm then
    if name then
      self:TextOut("SENT/"..name..":|cff00ff00"..data.."|r")
    else
      self:TextOut("SENT/PARTY:|cff00ff00"..data.."|r")
    end
  end
  
  if string.len(data) > max_msg_size then
    -- Large pieces of data are broken into pieces.
    local i = 1
    while true do
      local chunk = string.sub(data, i, i + max_chunk_size - 1)
      i = i + max_chunk_size
      if i > string.len(data) then
        -- End chunk
        ChatThrottleLib:SendAddonMessage("BULK", "QHpr", "X:"..chunk, name and "WHISPER" or "PARTY", name)
        break
      else
        ChatThrottleLib:SendAddonMessage("BULK", "QHpr", "x:"..chunk, name and "WHISPER" or "PARTY", name)
      end
    end
  else
    ChatThrottleLib:SendAddonMessage("BULK", "QHpr", data, name and "WHISPER" or "PARTY", name)
  end
end

local escapes =
 {
  "\\", "\\\\",
  "\n", "\\n",
  ":", "\\;"
 }

local function EscapeString(str)
  for i = 1,#escapes,2 do
    str = string.gsub(str, escapes[i], escapes[i+1])
  end
  
  return str
end

local function UnescapeString(str)
  for i = #escapes,1,-2 do
    str = string.gsub(str, escapes[i], escapes[i-1])
  end
  
  return str
end

local temp_table = {}
local function GetList(str)
  while table.remove(temp_table) do end
  for arg in string.gmatch(str, "([^:]*):?") do
    table.insert(temp_table, arg)
  end
  
  -- If i remove this assert, make sure I keep the side effect.
  assert(table.remove(temp_table) == "")
  
  return temp_table
end

--[[
  Message types:
    
    QuestHelper sends its addon messages with the prefix 'QHpr'
    
    syn:<VERSION>
      Sent to new users, letting them know we know nothing about them. VERSION is the communication they are using.
      Both clients normally send a syn: and bother respond to the other with hello:. If one client just reloaded,
      this will just be a syn: from the reloading client and a hello: from the existing client.
      
      As a special case, syn:0 indicates that the user has turned off objective sharing. Don't need to reply with
      hello in this case. You can, but of course, they won't see or care.
    
    hello:<VERSION>
      Sent in response to syn: VERSION is the communication version they are using.
    
    id:<ID>:<CATEGORY>:<WHAT>
      Lets other users know that they are sharing an objective under ID. CATEGORY and WHAT are escaped strings,
      to be passed to QuestHelper:GetObjective().
    
    dep:<ID>:<DEP1>:<DEP2>:...
      Lets other users know that one of their objectives depends on another. ID is the id of the objective, and
      is followed by the IDs of the objectives it depends on.
      For the sake of sanity, only quest objectives are allowed to have dependencies, and can't depend on
      other quest objectives.
    
    upd:<ID>:<PRI>:<HAVE>:<NEED>
      Lets other users know that something about one of their shared objectives has changed.
    
    rem:<ID>
      Lets other users know that they have removed an objective that they were previously sharing.
    
    x:<DATA>
      User wants to send a message larger than what blizzard will allow.
      DATA is appended to the previous data chunk.
      Will ignore if we don't know their version yet, since they might have been in the middle
      of sending something when we noticed it.
    
    X:<DATA>
      Same as x:, but this is the last chunk of data, and after this the combined data can be used as a message.

]]

local shared_objectives = {}
local users = {}
local shared_users = 0

local function CreateUser(name)
  if QuestHelper_Pref.comm then
    QuestHelper:TextOut("Created user: "..name)
  end
  
  user = QuestHelper:CreateTable()
  
  user.name=name
  user.version=0
  user.syn_req=false
  user.obj=QuestHelper:CreateTable()
  
  for i, obj in ipairs(shared_objectives) do -- Mark this user as knowing nothing about any of our objectives.
    assert(obj.peer)
    obj.peer[user] = 0
  end
  
  return user
end

local function SharedObjectiveReason(user, objective)
  if objective.cat == "quest" then
    return "Wait for "..QuestHelper:HighlightText(user.name).." to turn in "..QuestHelper:HighlightText(select(3, string.find(objective.obj, "^%d+/%d*/(.*)$")) or "something impossible").."."
  elseif objective.cat == "loc" then
    local _, _, c, z = string.find(objective.obj, "^(%d+),(%d+)")
    return "Help "..QuestHelper:HighlightText(user.name).." reach a location in "..QuestHelper:HighlightText(select(z,GetMapZones(c)) or "the black empty void").."."
  elseif objective.cat == "item" then
    return "Help "..QuestHelper:HighlightText(user.name).." to acquire "..QuestHelper:HighlightText(objective.obj).."."
  else
    return "Assist "..QuestHelper:HighlightText(user.name).." with "..QuestHelper:HighlightText(objective.obj).."."
  end
end

local function ReleaseUser(user)
  for id, objective in pairs(user.obj) do
    QuestHelper:SetObjectiveProgress(objective, user.name, nil, nil)
    QuestHelper:RemoveObjectiveWatch(objective, SharedObjectiveReason(user, objective))
    user.obj[id] = nil
  end
  
  for i, obj in ipairs(shared_objectives) do
    assert(obj.peer)
    obj.peer[user] = nil
  end
  
  if QuestHelper_Pref.comm then
    QuestHelper:TextOut("Released user: "..user.name)
  end
  
  QuestHelper:ReleaseTable(user.obj)
  QuestHelper:ReleaseTable(user)
end

function QuestHelper:DoShareObjective(objective)
  for i = 1, #shared_objectives do assert(objective ~= shared_objectives[i]) end -- Just testing.
  
  assert(objective.peer == nil)
  objective.peer = self:CreateTable()
  
  for name, user in pairs(users) do
    -- Peers know nothing about this objective.
    objective.peer[user] = 0
  end
  
  for o in pairs(objective.before) do
    if o.peer then
      for u, l in pairs(o.peer) do
        -- Peers don't know about this dependency.
        o.peer[u] = math.min(l, 1)
      end
    end
  end
  
  table.insert(shared_objectives, objective)
end

function QuestHelper:DoUnshareObjective(objective)
  for i = 1, #shared_objectives do
    if objective == shared_objectives[i] then
      local need_announce = false
      
      assert(objective.peer)
      
      for user, level in pairs(objective.peer) do
        if level > 0 then
          need_announce = true
        end
        
        objective.peer[user] = nil
      end
      
      self:ReleaseTable(objective.peer)
      objective.peer = nil
      
      if need_announce then
        self:SendData("rem:"..objective.id)
      end
      
      table.remove(shared_objectives, i)
      return
    end
  end
  
  assert(false) -- Should have found the objective.
end

function QuestHelper:HandleRemoteData(data, name)
  if QuestHelper_Pref.share then
    local user = users[name]
    if not user then
      user = CreateUser(name)
      users[name] = user
    end
    
    local _, _, message_type, message_data = string.find(data, "^(.-):(.*)$")
    
    if message_type == "x" then
      if user.version > 0 then
        --self:TextOut("RECV/"..name..":<chunk>")
        user.xmsg = (user.xmsg or "")..message_data
      else
        --self:TextOut("RECV/"..name..":<ignored chunk>")
      end
      return
    elseif message_type == "X" then
      if user.version > 0 then
        --self:TextOut("RECV/"..name..":<chunk end>")
        _, _, message_type, message_data = string.find((user.xmsg or "")..message_data, "^(.-):(.*)$")
        user.xmsg = nil
      else
        --self:TextOut("RECV/"..name..":<ignored chunk end>")
        return
      end
    end
    
    if QuestHelper_Pref.comm then
      self:TextOut("RECV/"..name..":|cff00ff00"..data.."|r")
    end
    
    if message_type == "syn" then
      -- User has just noticed us. Is either new, or reloaded their UI.
      
      local new_version = tonumber(message_data) or 0
      
      if new_version == 0 and user.version > 0 then
        shared_users = shared_users - 1
      elseif new_version > 0 and user.version == 0 then
        shared_users = shared_users + 1
      end
      
      self.sharing = shared_users > 0
      user.version = new_version
      
      for i, obj in ipairs(shared_objectives) do -- User apparently knows nothing about us.
        assert(obj.peer)
        obj.peer[user] = 0
      end
      
      for id, obj in pairs(user.obj) do -- And apparently all their objective ids are now null and void.
        self:SetObjectiveProgress(obj, user.name, nil, nil)
        self:RemoveObjectiveWatch(obj, SharedObjectiveReason(user, obj))
        user.obj[id] = nil
      end
      
      -- Say hello to the new user.
      if user.version > 0 then
        self:SendData("hello:"..comm_version, name)
      end
    elseif message_type == "hello" then
      local new_version = tonumber(message_data) or 0
      
      if new_version == 0 and user.version > 0 then
        shared_users = shared_users - 1
      elseif new_version > 0 and user.version == 0 then
        shared_users = shared_users + 1
      end
      
      self.sharing = shared_users > 0
      user.version = new_version
      
      if user.version > comm_version then
        self:TextOut(self:HighlightText(name).." is using a newer protocol version. It might be time to upgrade.")
      elseif user.version < comm_version then
        self:TextOut(self:HighlightText(name).." is using an older protocol version.")
      end
      
    elseif message_type == "id" then
      local list = GetList(message_data)
      local id, cat, what = tonumber(list[1]), list[2], list[3]
      if id and cat and what and not user.obj[id] then
        user.obj[id] = self:GetObjective(UnescapeString(cat), UnescapeString(what))
        self:AddObjectiveWatch(user.obj[id], SharedObjectiveReason(user, user.obj[id]))
      end
    elseif message_type == "dep" then
      local list = GetList(message_data)
      local id = tonumber(list[1])
      local obj = id and user.obj[id]
      if obj and obj.cat == "quest" then
        for i = 2, #list do
          local depid = tonumber(list[i])
          local depobj = depid and user.obj[depid]
          if depobj and depobj.cat ~= "quest" then
            self:ObjectiveObjectDependsOn(obj, depobj)
            
            if depobj.cat == "item" then
              if not depobj.quest then
                depobj.quest = obj
              end
            end
          end
        end
      end
    elseif message_type == "upd" then
      local _, _, id, priority, have, need = string.find(message_data, "^(%d+):(%d+):([^:]*):(.*)")
      id, priority = tonumber(id), tonumber(priority)
      
      if id and priority and have and need then
        local obj = user.obj[id]
        if obj then
          have, need = UnescapeString(have), UnescapeString(need)
          have, need = tonumber(have) or have, tonumber(need) or need
          if have == "" or need == "" then have, need = nil, nil end
          self:SetObjectivePriority(obj, priority)
          self:SetObjectiveProgress(obj, user.name, have, need)
        end
      end
    elseif message_type == "rem" then
      local id = tonumber(message_data)
      local obj = id and user.obj[id]
      if obj then
        self:SetObjectiveProgress(obj, name, nil, nil)
        self:RemoveObjectiveWatch(obj, SharedObjectiveReason(user, obj))
        user.obj[id] = nil
      end
    else
      self:TextOut("Unknown message type '"..message_type.."' from '"..name.."'.")
    end
  end
end

function QuestHelper:PumpCommMessages()
  if shared_users > 0 and QuestHelper_Pref.share then
    local best_level, best_count, best_obj = 3, 255, nil
    
    for i, o in pairs(shared_objectives) do
      local level, count = 255, 0
      
      for u, l in pairs(o.peer) do
        if u.version > 0 then
          level = math.min(l, level)
          count = count + 1
        end
      end
      
      if level < best_level or (level == best_level and count > best_count) then
        best_level, best_count, best_obj = level, count, o
      end
    end
    
    if best_obj then
      if best_level == 0 then
        self:SendData("id:"..best_obj.id..":"..EscapeString(best_obj.cat)..":"..EscapeString(best_obj.obj))
        best_level = 1
      elseif best_level == 1 then
        if next(best_obj.after, nil) then
          local data, meaningful = "dep:"..best_obj.id, false
          for o in pairs(best_obj.after) do
            if o.peer then
              data = data .. ":" .. o.id
              meaningful = true
            end
          end
          if meaningful then
            self:SendData(data)
          end
        end
        best_level = 2
      elseif best_level == 2 then
        local prog = best_obj.progress and best_obj.progress[UnitName("player")]
        if prog then
          self:SendData("upd:"..best_obj.id..":"..best_obj.priority..":"..EscapeString(prog[1])..":"..EscapeString(prog[2]))
        else
          self:SendData("upd:"..best_obj.id..":"..best_obj.priority.."::")
        end
        best_level = 3
      end
      
      for u in pairs(best_obj.peer) do -- All peers have just seen this.
        if u.version > 0 then
          best_obj.peer[u] = math.max(best_obj.peer[u], best_level)
        end
      end
    end
  end
end

function QuestHelper:HandlePartyChange()
  if QuestHelper_Pref.share then
    for name, user in pairs(users) do
      user.seen = false
    end
    
    for i = 1,4 do
      if UnitExists("party"..i) then
        local name = UnitName("party"..i)
        if name ~= UNKNOWNOBJECT then
          local user = users[name]
          if not user then
            user = CreateUser(name)
            users[name] = user
          end
          
          if not user.syn_req then
            self:SendData("syn:"..comm_version, name)
            user.syn_req = true
          end
          
          user.seen = true
        end
      end
    end
    
    local count = 0
    
    for name, user in pairs(users) do
      if not user.seen then
        ReleaseUser(user)
        users[name] = nil
      elseif user.version > 0 then
        count = count + 1
      end
    end
    
    shared_users = count
    self.sharing = count > 0
  end
end

function QuestHelper:EnableSharing()
  if not QuestHelper_Pref.share then
    QuestHelper_Pref.share = true
    self:HandlePartyChange()
  end
end

function QuestHelper:DisableSharing()
  if QuestHelper_Pref.share then
    QuestHelper_Pref.share = false
    for name, user in pairs(users) do
      if user.version > 0 then self:SendData("syn:0", name) end
      ReleaseUser(user)
      users[name] = nil
    end
    shared_users = 0
    self.sharing = false
  end
end
