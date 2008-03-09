-- Functions we use here.
local create = QuestHelper.create
local createSortedList = QuestHelper.createSortedList
local release = QuestHelper.release
local insert = table.insert
local erase = table.remove

-- The metatables for Graph and Node objects.
local Graph, Node = {}, {}

function Node:onCreate()
  rawset(self, "_link", create())
end

function Node:onRelease()
  release(rawget(self, "_link"))
end

-- Links this node to another.
function Node:link(node, dist)
  rawset(rawget(self, "_link"), node, dist)
end

local function nodeCmpA(a, b)
  -- In A*f is the traveled distance plus the estimated remaining distance.
  return rawget(a, "_f") > rawget(b, "_f")
end

local function nodeCmpD(a, b)
  -- In Dijkstra is the distance traveled so far.
  return rawget(a, "g") > rawget(b, "g")
end

function Graph:onCreate(heuristic)
  rawset(self, "heuristic", heuristic)
  rawset(self, "open", createSortedList(heuristic and nodeCmpA or nodeCmpD))
  rawset(self, "nodes", create())
end

function Graph:onRelease()
  release(rawget(self, "open"))
  local nodes = rawget(self, "nodes")
  for node in pairs(nodes) do release(node) end
  release(nodes)
end

function Graph:createNode()
  local node = create(Node)
  rawget(self, "nodes")[node] = true
  return node
end

function Graph:releaseNode(node)
  release(node)
  rawget(self, "nodes")[node] = nil
end

-- Prepares the graph for searching.
function Graph:clear()
  local open = rawget(self, "open")
  while erase(open) do end
  
  for n in pairs(rawget(self, "nodes")) do
    -- Remove state from node.
    -- Possible values for s:
    --  nil/false - Hasn't yet been considered.
    --  1         - It's been placed in the open table.
    --  other     - We know how to reach this node.
    rawset(n, "_s", nil)
  end
end

-- The same node must not be added multiple times.
function Graph:start(node, dist)
  assert(not rawget(node, "_s")) -- Should only be added once.
  rawset(node, "g", dist or 0)
  rawset(node, "_s", 1)
  if rawget(self, "heuristic") then
    -- Just append the node to the end of the list, it will be sorted when
    -- we have a node with which to apply the heuristic.
    insert(rawget(self, "open"), node)
  else
    -- Insert in the correct position now; with no heuristic to change things
    -- the list won't need to be resorted later.
    rawget(self, "open"):insert(node)
  end
end

function Graph:dest(dest)
  local open = rawget(self, "open")
  
  if rawget(dest, "_s") == 2 then
    -- We've already reached this node.
    return dest
  end
  
  local heuristic = rawget(self, "heuristic")
  
  if heuristic then
    -- A* Pathing
    
    for i = 1,#open do
      local n = rawget(open, i)
      local g, h = rawget(n, "g"), heuristic(n, dest)
      rawset(n, "_h", h)
      rawset(n, "_f", g+h)
    end
    
    open:sort()
    
    while #open > 0 do
      local node = erase(open)
      rawset(node, "_s", 2)
      
      local g = rawget(node, "g")
      
      for n, d in pairs(rawget(node, "_link")) do
        local s = rawget(n, "_s")
        if s == 1 then
          -- Is already in the open list, possibly we found a shorter route to it.
          local ng = g+d
          local h = rawget(n, "_h")
          local f = ng+h
          if f < rawget(n, "_f") then
            -- Found a shorter path to this node.
            local i = open:lower(n)
            while rawget(open, i) ~= n do i = i + 1 end
            erase(open, i)
            rawset(n, "g", ng)
            rawset(n, "_f", f)
            rawset(n, "parent", node)
            open:insert2(n, i, #open+1)
          end
        elseif not s then
          -- Haven't considered this node yet.
          local h = heuristic(n, dest)
          local ng = g+d
          rawset(n, "g", ng)
          rawset(n, "_f", ng+h)
          rawset(n, "_h", h)
          rawset(n, "_s", 1)
          rawset(n, "parent", node)
          open:insert(n)
        end -- else the node in question is ignored.
      end
      
      if node == dest then
        -- We could have checked for this before the above loop, but then we'd have missed some links
        -- if this was to be called multiple times.
        return node
      end
    end
  else
    -- Dijkstra's algorithm
    -- Same as above, but we don't need to resort the list (already sorted), and only consider the distance traveled.
    
    while #open > 0 do
      local node = erase(open)
      rawset(node, "_s", 2)
      
      local g = rawget(node, "g")
      
      for n, d in pairs(rawget(node, "_link")) do
        local s = rawget(n, "_s")
        if s == 1 then
          -- Is already in the open list, possibly we found a shorter route to it.
          local ng = g+d
          if ng < rawget(n, "g") then
            -- Found a shorter path to this node.
            local i = open:lower(n)
            while rawget(open, i) ~= n do i = i + 1 end
            erase(open, i)
            rawset(n, "g", ng)
            rawset(n, "parent", node)
            open:insert2(n, i, #open+1)
          end
        elseif not s then
          -- Haven't considered this node yet.
          rawset(n, "g", g+d)
          rawset(n, "_s", 1)
          rawset(n, "parent", node)
          open:insert(n)
        end -- else the node in question is ignored.
      end
      
      if node == dest then
        -- We could have checked for this before the above loop, but then we'd have missed some links
        -- if this was to be called multiple times.
        return node
      end
    end
  end
end

Graph.__newindex = function()
  assert(false, "Shouldn't assign values.")
end

Node.__index = function(node, key)
  return rawget(node, key) or rawget(Node, key)
end

Graph.__index = function(_, key)
  return rawget(Graph, key)
end

local function createGraph(heuristic)
  return create(Graph, heuristic)
end

QuestHelper.createGraph = createGraph
