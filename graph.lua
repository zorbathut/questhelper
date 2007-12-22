
local function sanity(list)
  local last = nil
  for i, n in ipairs(list) do
    assert(not last or last >= n.f)
    last = n.f
  end
end

local function Graph_Node_Link(self, next_node, distance)
  if self ~= next_node then
    self.n[next_node] = distance
    table.insert(next_node.r, self)
  end
end

local function Graph_Node_Reset(self)
  for _, n in ipairs(self.r) do n.n[self] = nil end
  while #self.n > 0 do table.remove(self.n) end
  while #self.r > 0 do table.remove(self.r) end
end

local function Graph_CreateNode(self)
  local node = table.remove(self.unused)
  if not node then
    node = {}
    node.Link = Graph_Node_Link
    node.Reset = Graph_Node_Reset
    node.n = {}
    node.r = {}
  end
  table.insert(self.nodes, node)
  return node
end

local function Graph_DestroyNode(self, node)
  for i = 1,#self.nodes do
    if self.nodes[i] == node then
      table.remove(self.nodes, i)
      node:Reset()
      table.insert(self.unused, node)
      break
    end
  end
end

local function Graph_Reset(self)
  while #self.nodes > 0 do
    local node = table.remove(self.nodes)
    node:Reset()
    table.insert(self.unused, node)
  end
end

-- Tries to find a path from first to last.
-- heuristic is a function that takes two nodes and estimates how long a path between them would be.
-- If a path is found, last.p will be set to the second last node, it's .p will be set to the third
-- last node, and so on and so forth until you get to first, which will have .p set to nil. So, basically
-- you end up with a reversed linked list.

local function Graph_Search(self, first, last, heuristic)
  if first ~= last then
    local open = self.open
    while #open > 0 do table.remove(open) end
    for _, n in ipairs(self.nodes) do n.s = 0 end
    
    table.insert(open, first)
    
    last.s = 3
    
    while #open > 0 do
      local current = table.remove(open)
      current.s = 2
      local cd = current.g
      
      for n, d in pairs(current.n) do
        if n.s == 0 then
          -- Haven't visited this node yet.
          n.g = cd+d
          if n == last then
            first.p = nil
            n.p = current
            return
          end
          
          n.s = 1
          n.p = current
          n.h = heuristic(n, last)
          local f = n.g+n.h
          n.f = f
          
          local mn, mx = 1, #open+1
          
          while mn ~= mx do
            local m = math.floor((mn+mx)*0.5)
            
            if open[m].f > f then
              mn = m+1
            else
              mx = m
            end
          end
          
          table.insert(open, mn, n)
        elseif n.s == 1 then
          n.g = cd+d
          local f = n.g+n.h
          if f < n.f then
            n.p = current
            local of = n.f
            n.f = f
            local mn, mx = 1, #open
            
            while mn ~= mx do
              local m = math.floor((mn+mx)*0.5)
              if open[m].f > of then
                mn = m+1
              else
                mx = m
              end
            end
            
            while open[mn] ~= n do
              mn = mn + 1
            end
            mx = #open
            table.remove(open, mn)
            
            while mn ~= mx do
              local m = math.floor((mn+mx)*0.5)
              
              if open[m].f > f then
                mn = m+1
              else
                mx = m
              end
            end
            
            table.insert(open, mn, n)
          end
        end
      end
    end
  end
  last.p = nil
end

-- Same as above, but allows multiple starting or ending locations.
--
-- Starting nodes should have .g set to their distance before reaching that node.
-- Ending nodes should have .e set the the distance remaining after that node.
--
-- Returns the closest end node that result in the shortast total distance.
-- That node will have .g set to the total distance from start to end, ignoring .e, and .p set to the node before it.
-- Recursively follow the previous nodes for the path.
local function Graph_MultiSearch(self, start_list, end_list, heuristic)
  local open = self.open
  local end_count = #end_list
  if end_count == 0 then return end
  while #open > 0 do table.remove(open) end
  for _, n in ipairs(self.nodes) do n.s = 0 end
  
  for i, node in ipairs(end_list) do
    node.s = 3 -- We'll check for this to determine if we've found an end node.
  end
  
  for i, n in ipairs(start_list) do
    n.p = nil
    
    if n.s == 3 then
      n.s = 4
      n.h = n.e
    else
      n.s = 1
      
      local e = end_list[1]
      n.h = heuristic(n, e)+e.e
      for i = 2,end_count do
        e = end_list[i]
        n.h = math.min(n.h, heuristic(n, e)+e.e)
      end
    end
    
    local f = n.g+n.h
    n.f = f
    
    local mn, mx = 1, #open+1
    
    while mn ~= mx do
      local m = math.floor((mn+mx)*0.5)
      
      if open[m].f > f then
        mn = m+1
      else
        mx = m
      end
    end
    
    table.insert(open, mn, n)
  end
  
  while #open > 0 do
    local current = table.remove(open)
    
    if current.s == 3 or current.s == 4 then
      return current
    end
    
    current.s = 2
    local cd = current.g
    
    for n, d in pairs(current.n) do
      if n.s == 0 or n.s == 3 then
        -- Haven't visited this node yet.
        n.p = current
        local f
        
        if n.s == 3 then
          n.s = 4
          n.h = n.e
          n.g = cd+d
        else
          n.s = 1
          n.g = cd+d
          
          local e = end_list[1]
          n.h = heuristic(n, e)+e.e
          for i = 2,end_count do
            e = end_list[i]
            n.h = math.min(n.h, heuristic(n, e)+e.e)
          end
        end
        
        local f = n.g+n.h
        
        local mn, mx = 1, #open+1
        
        while mn ~= mx do
          local m = math.floor((mn+mx)*0.5)
          
          if open[m].f > f then
            mn = m+1
          else
            mx = m
          end
        end
        
        n.f = f
        
        table.insert(open, mn, n)
        
      elseif n.s == 1 or n.s == 4 then
        n.g = cd+d
        local f = n.g+n.h
        if f < n.f then
          n.p = current
          local of = n.f
          
          local mn, mx = 1, #open
          
          while mn ~= mx do
            local m = math.floor((mn+mx)*0.5)
            if open[m].f > of then
              mn = m+1
            else
              mx = m
            end
          end
          
          while open[mn] ~= n do
            assert(open[mn])
            mn = mn + 1
          end
          
          n.f = f
          mx = #open
          
          table.remove(open, mn)
          
          while mn ~= mx do
            local m = math.floor((mn+mx)*0.5)
            
            if open[m].f > f then
              mn = m+1
            else
              mx = m
            end
          end
          
          table.insert(open, mn, n)
        end
      end
    end
  end
end

function QuestHelper:CreateGraph()
  local graph = {}
  graph.unused = {}
  graph.nodes = {}
  graph.end_nodes = {}
  graph.open = {}
  graph.CreateNode = Graph_CreateNode
  graph.DestroyNode = Graph_DestroyNode
  graph.Reset = Graph_Reset
  graph.Search = Graph_Search
  graph.MultiSearch = Graph_MultiSearch
  graph.Reset = Graph_Reset
  return graph
end

QuestHelper.world_graph = QuestHelper:CreateGraph()
