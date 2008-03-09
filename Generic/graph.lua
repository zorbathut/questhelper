-- Functions we use here.
local create = QuestHelper.create
local createSortedList = QuestHelper.createSortedList
local release = QuestHelper.release
local insert = table.insert
local erase = table.remove

-- The metatables for Graph and Node objects.
local Graph, Node = {}, {}

function Node:onCreate()
  rawset(self, "links", create())
end

function Node:onRelease()
  release(rawget(self, "links"))
end

-- Links this node to another.
function Node:link(node, dist)
  rawset(rawget(self, "links"), node, dist)
end

local function nodeCmp(a, b)
  return a.f > b.f
end

function Graph:onCreate(heuristic)
  assert(type(heuristic) == "function", "Expected a heuristic function.")
  rawset(self, "heuristic", heuristic)
  rawset(self, "open", createSortedList(nodeCmp))
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
    --  nil - Hasn't yet been considered.
    --  1 - It's been placed in the open table.
    --  2 - We know how to reach this node.
    rawset(n, "s", nil)
  end
end

-- The same node must not be added multiple times.
function Graph:start(node, dist)
  assert(not rawget(node, "s")) -- Should only be added once.
  rawset(node, "g", dist or 0)
  rawset(node, "s", 1)
  insert(rawget(self, "open"), node)
end

function Graph:dest(dest)
  local open = rawget(self, "open")
  local heuristic = rawget(self, "heuristic")
  
  if rawget(dest, "s") == 2 then
    -- We've already reached this node.
    return dest
  end
  
  for i = 1,#open do
    local n = rawget(open, i)
    local g, h = rawget(n, "g"), heuristic(n, dest)
    rawset(n, "h", h)
    rawset(n, "f", g+h)
  end
  
  open:sort()
  
  while #open > 0 do
    local node = erase(open)
    rawset(node, "s", 2)
    
    if node == dest then
      return node
    end
    
    local g = rawget(node, "g")
    
    for n, d in pairs(rawget(node, "links")) do
      local s = rawget(n, "s")
      if s == 1 then
        -- Is already in the open list, possibly we found a shorter route to it.
        local ng = g+d
        local h = rawget(n, "h")
        local f = ng+h
        if f < rawget(n, "f") then
          -- Found a shorter path to this node.
          local mn, mx = open:find(n)
          for i = mn, mn do
            if rawget(open, i) == n then
              erase(open, i)
              rawset(n, "g", ng)
              rawset(n, "f", f)
              rawset(n, "parent", node)
              open:insert2(n, i, #open)
              break
            end
          end
        end
      elseif not s then
        -- Haven't considered this node yet.
        local h = heuristic(n, dest)
        local ng = g+d
        rawset(n, "g", ng)
        rawset(n, "f", ng+h)
        rawset(n, "h", h)
        rawset(n, "parent", node)
        open:insert(n)
      end -- else the node in question is ignored.
    end
  end
end

Node.__newindex = function()
  assert(false, "Shouldn't assign values.")
end

Graph.__newindex = Node.__newindex

Node.__index = function(node, key)
  return rawget(Node, key)
end

Graph.__index = function(_, key)
  return rawget(Graph, key)
end

local function createGraph(heuristic)
  return create(Graph, heuristic)
end

QuestHelper.createGraph = createGraph
