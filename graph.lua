local function Graph_Search(self, first, last)
  if first ~= last then
    local heuristic = self.h
    local open = self.open
    while #open > 0 do table.remove(open) end
    for _, n in ipairs(self.nodes) do n.s = 0 end
    
    table.insert(open, first)
    
    first.g = 0
    first.s = 2
    
    while #open > 0 do
      local current = table.remove(open)
      
      if current == last then
        first.p = nil
        return true
      end
      
      current.s = 2
      local cd = current.g
      
      for n, d in pairs(current.n) do
        if n.s == 0 then
          -- Haven't visited this node yet.
          n.g = cd+d
          n.s = 1
          n.p = current
          n.h = heuristic(n, last)
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
          
          table.insert(open, mn, n)
          n.f = f
        elseif n.s == 1 then
          local g = cd+d
          local f = g+n.h
          if f < n.f then
            n.g = g
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
            n.f = f
          end
        end
      end
    end
  end
  last.p = nil
  return first == last
end

local function sanity(list, node)
  local last = nil
  local contains = false
  for i, n in ipairs(list) do
    if not (not last or last >= n.f) then
      for i, n in ipairs(list) do
        QuestHelper:TextOut(i..") "..n.f)
      end
      QuestHelper:Error("Order "..i.."/"..#list.." ("..n.f..")")
    end
    assert(not last or last >= n.f)
    last = n.f
    if n == node then
      contains = true
    end
  end
  if node and not contains then QuestHelper:Error("Missing") end
end

local function Graph_Node_Link(self, next_node, distance)
  if type(distance) ~= "number" or distance < 0 then QuestHelper:Error("Boom!") end
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

local function Graph_SetHeuristic(self, heuristic)
  self.h = heuristic
end

local function Graph_AddRouteStartNode(self, n, g, end_list) 
  local heuristic = self.h
  local open = self.open
  
  n.p = nil
  
  if n.s == 3 then
    n.s = 4
    n.h = n.e*n.w
  elseif n.s == 0 then
    n.s = 1
    
    local e = end_list[1]
    n.h = (heuristic(n, e)+e.e)*e.w
    for i = 2,#end_list do
      e = end_list[i]
      n.h = math.min(n.h, (heuristic(n, e)+e.e)*e.w)
    end
  else
    local of = n.f
    if g+n.h < of then
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
      
      table.remove(open, mn)
    else
      return -- Don't want to insert the node a second time.
    end
  end
  
  local f = g+n.h
  
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
  
  n.g = g
  n.f = f
end

local function Graph_DoRouteSearch(self, end_list)
  local heuristic = self.h
  local open = self.open
  local end_count = #end_list
  
  while #open > 0 do
    local current = table.remove(open)
    
    if current.s == 3 or current.s == 4 then
      current.s = 2
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
          n.h = n.e*n.w
          n.g = cd+d
        else
          n.s = 1
          n.g = cd+d
          
          local e = end_list[1]
          n.h = (heuristic(n, e)+e.e)*e.w
          
          for i = 2,end_count do
            e = end_list[i]
            n.h = math.min(n.h, (heuristic(n, e)+e.e)*e.w)
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
        local g = cd+d
        local f = g+n.h
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
          
          n.f = f
          table.insert(open, mn, n)
        end
      end
    end
  end
end

local function Graph_PrepareSearch(self)
  local open = self.open
  while #open > 0 do table.remove(open) end
  for _, n in ipairs(self.nodes) do
    n.s = 0
  end
end

local function Graph_AddStartNode(self, n, g, end_list) 
  local heuristic = self.h
  local open = self.open
  
  n.p = n
  
  if n.s == 3 then
    n.s = 4
    n.h = n.e*n.w
  elseif n.s == 0 then
    n.s = 1
    
    local e = end_list[1]
    n.h = (heuristic(n, e)+e.e)*e.w
    for i = 2,#end_list do
      e = end_list[i]
      n.h = math.min(n.h, (heuristic(n, e)+e.e)*e.w)
    end
  else
    local of = n.f
    if g+n.h < of then
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
      
      table.remove(open, mn)
    else
      return -- Don't want to insert the node a second time.
    end
  end
  
  local f = g+n.h
  
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
  
  n.g = g
  n.f = f
end

local function Graph_DoSearch(self, end_list)
  local heuristic = self.h
  local open = self.open
  local end_count = #end_list
  
  while #open > 0 do
    local current = table.remove(open)
    
    if current.s == 3 or current.s == 4 then
      current.s = 2
      return current
    end
    
    current.s = 2
    
    local cd = current.g
    
    for n, d in pairs(current.n) do
      if n.s == 0 or n.s == 3 then
        -- Haven't visited this node yet.
        n.p = current.p
        local f
        
        if n.s == 3 then
          n.s = 4
          n.h = n.e*n.w
          n.g = cd+d
        else
          n.s = 1
          n.g = cd+d
          
          local e = end_list[1]
          n.h = (heuristic(n, e)+e.e)*e.w
          
          for i = 2,end_count do
            e = end_list[i]
            n.h = math.min(n.h, (heuristic(n, e)+e.e)*e.w)
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
        local g = cd+d
        local f = g+n.h
        if f < n.f then
          n.p = current.p
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
          
          n.f = f
          table.insert(open, mn, n)
        end
      end
    end
  end
end

local removed = {}

local function Graph_DoFullSearch(self, end_list)
  local heuristic = self.h
  local open = self.open
  local end_count = #end_list
  
  while #open > 0 do
    local current = table.remove(open)
    
    if current.s == 3 or current.s == 4 then
      if end_count == 1 then
        for i = 1,#removed do
          table.insert(end_list, table.remove(removed))
        end
        return
      end
      
      for i = 1,end_count do
        if end_list[i] == current then
          table.insert(removed, table.remove(end_list, i))
          break
        end
      end
      
      end_count = end_count - 1
    end
    
    current.s = 2
    
    local cd = current.g
    
    for n, d in pairs(current.n) do
      if n.s == 0 or n.s == 3 then
        -- Haven't visited this node yet.
        n.p = current.p
        local f
        
        if n.s == 3 then
          n.s = 4
          n.h = n.e*n.w
          n.g = cd+d
        else
          n.s = 1
          n.g = cd+d
          
          local e = end_list[1]
          n.h = (heuristic(n, e)+e.e)*e.w
          for i = 2,end_count do
            e = end_list[i]
            n.h = math.min(n.h, (heuristic(n, e)+e.e)*e.w)
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
        local g = cd+d
        local f = g+n.h
        if f < n.f then
          n.p = current.p
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
          
          n.f = f
          table.insert(open, mn, n)
        end
      end
    end
  end
  
  for i, n in ipairs(end_list) do
    QuestHelper:TextOut(i..") Failed to reach: "..n.name..", s="..n.s)
  end
  
  for i = 1,#removed do
    table.insert(end_list, table.remove(removed))
  end
  
  for i, n in ipairs(end_list) do
    QuestHelper:TextOut(i..") End node: "..n.name..", s="..n.s)
  end
  
  QuestHelper:Error("Boom!")
  
  for i = 1,#removed do
    table.insert(end_list, table.remove(removed))
  end
end

local function propLinks(node)
  if node.s ~= 1 then
    node.s = 1
    for n in pairs(node.n) do
      propLinks(n)
    end
  end
end

function Graph_SanityCheck(self)
  for i = 1,#self.nodes do
    for _, n in ipairs(self.nodes) do
      n.s = 0
    end
    
    propLinks(self.nodes[i])
    
    for _, n in ipairs(self.nodes) do
      if n.s ~= 1 then
        QuestHelper:TextOut((n.name or "unknown").." isn't reachable from "..(self.nodes[i].name or "unknown"))
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
  
  graph.SetHeuristic = Graph_SetHeuristic
  graph.PrepareSearch = Graph_PrepareSearch
  
  graph.AddRouteStartNode = Graph_AddRouteStartNode
  graph.DoRouteSearch = Graph_DoRouteSearch
  graph.Search = Graph_Search
  graph.SanityCheck = Graph_SanityCheck
  
  -- These don't deal with finding paths and instead only care about finding distances.
  graph.AddStartNode = Graph_AddStartNode
  graph.DoSearch = Graph_DoSearch
  graph.DoFullSearch = Graph_DoFullSearch
  
  return graph
end

QuestHelper.world_graph = QuestHelper:CreateGraph()
