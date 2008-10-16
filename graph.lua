QuestHelper_File["graph.lua"] = "Development Version"

local floor = math.floor

local function Graph_Search(self, first, last)
  if first ~= last then
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
          local g = cd+d
          n.g = g
          n.s = 1
          n.p = current
          
          local mn, mx = 1, #open+1
          
          while mn ~= mx do
            local m = floor((mn+mx)*0.5)
            
            if open[m].g > g then
              mn = m+1
            else
              mx = m
            end
          end
          
          table.insert(open, mn, n)
        elseif n.s == 1 then
          local g = cd+d
          if g < n.g then
            n.g = g
            n.p = current
            local mn, mx = 1, #open
            
            while mn ~= mx do
              local m = floor((mn+mx)*0.5)
              if open[m].g > g then
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
              local m = floor((mn+mx)*0.5)
              
              if open[m].g > g then
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
  return first == last
end

local function sanity(list, node)
  local last = nil
  local contains = false
  for i, n in ipairs(list) do
    if not (not last or last >= n.g) then
      for i, n in ipairs(list) do
        QuestHelper:TextOut(i..") "..n.g)
      end
      QuestHelper:Error("Order "..i.."/"..#list.." ("..n.g..")")
    end
    assert(not last or last >= n.g)
    last = n.g
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

local function Graph_CreateNode(self)
  local node = QuestHelper:CreateTable("graph_createnode")
  node.Link = Graph_Node_Link
  node.n = QuestHelper:CreateTable("graph_createnode.n")
  node.r = QuestHelper:CreateTable("graph_createnode.r")
  table.insert(self.nodes, node)
  return node
end

local function Graph_DestroyNode(self, node)
  for i = 1,#self.nodes do
    if self.nodes[i] == node then
      table.remove(self.nodes, i)
      QuestHelper:ReleaseTable(node.n)
      QuestHelper:ReleaseTable(node.r)
      QuestHelper:ReleaseTable(node)
      break
    end
  end
end

local function Graph_Reset(self)
  while #self.nodes > 0 do
    local node = table.remove(self.nodes)
    QuestHelper:ReleaseTable(node.n)
    QuestHelper:ReleaseTable(node.r)
    QuestHelper:ReleaseTable(node)
  end
end

local function Graph_AddRouteStartNode(self, n, g, end_list) 
  local open = self.open
  
  n.p = nil
  
  if n.s == 3 then
    n.s = 4
  elseif n.s == 0 then
    n.s = 1
  else
    local og = n.g
    if g < og then
      local mn, mx = 1, #open
      
      while mn ~= mx do
        local m = floor((mn+mx)*0.5)
        if open[m].g > og then
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
  
  local mn, mx = 1, #open+1
  
  while mn ~= mx do
    local m = floor((mn+mx)*0.5)
    
    QuestHelper: Assert(open[m].g and g, string.format("nil-with-number issue, %s %s and %d inside %d %d", tostring(open[m].g), tostring(g), m, mn, mx))
    if open[m].g > g then
      mn = m+1
    else
      mx = m
    end
  end
  
  table.insert(open, mn, n)
  
  n.g = g
end

local function Graph_DoRouteSearch(self, end_list)
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
        local g = cd+d
        n.p = current
        n.g = g
        
        n.s = n.s == 3 and 4 or 1
        
        local mn, mx = 1, #open+1
        
        while mn ~= mx do
          local m = floor((mn+mx)*0.5)
          
          if open[m].g > g then
            mn = m+1
          else
            mx = m
          end
        end
        
        table.insert(open, mn, n)
      elseif n.s == 1 or n.s == 4 then
        local g = cd+d
        local og = n.g
        if g < og then
          n.p = current
          
          local mn, mx = 1, #open
          
          while mn ~= mx do
            local m = floor((mn+mx)*0.5)
            if open[m].g > og then
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
            local m = floor((mn+mx)*0.5)
            
            if open[m].g > g then
              mn = m+1
            else
              mx = m
            end
          end
          
          n.g = g
          table.insert(open, mn, n)
        end
      end
    end
  end
end

local function Graph_PrepareSearch(self)
  local open = self.open
  for n in pairs(open) do open[n] = nil end
  for _, n in pairs(self.nodes) do
    n.s = 0
  end
end

local function Graph_AddStartNode(self, n, g, end_list) 
  local open = self.open
  
  n.p = n
  
  if n.s == 3 then
    n.s = 4
  elseif n.s == 0 then
    n.s = 1
  else
    local og = n.g
    if g < og then
      local mn, mx = 1, #open
      
      while mn ~= mx do
        local m = floor((mn+mx)*0.5)
        if open[m].g > og then
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
  
  local mn, mx = 1, #open+1
  
  while mn ~= mx do
    local m = floor((mn+mx)*0.5)
    
    if open[m].g > g then
      mn = m+1
    else
      mx = m
    end
  end
  
  table.insert(open, mn, n)
  
  n.g = g
end

local function Graph_DoSearch(self, end_list)
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
        local g = cd+d
        n.g = g
        n.p = current.p
        
        n.s = n.s == 3 and 4 or 1
        
        local mn, mx = 1, #open+1
        
        while mn ~= mx do
          local m = floor((mn+mx)*0.5)
          
          if open[m].g > g then
            mn = m+1
          else
            mx = m
          end
        end
        
        table.insert(open, mn, n)
      elseif n.s == 1 or n.s == 4 then
        local g = cd+d
        local og = n.g
        if g < og then
          n.p = current.p
          
          local mn, mx = 1, #open
          
          while mn ~= mx do
            local m = floor((mn+mx)*0.5)
            if open[m].g > og then
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
            local m = floor((mn+mx)*0.5)
            
            if open[m].g > g then
              mn = m+1
            else
              mx = m
            end
          end
          
          n.g = g
          table.insert(open, mn, n)
        end
      end
    end
  end
end

local removed = {}

local function Graph_DoFullSearch(self, end_list)
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
        local g = cd+d
        n.g = g
        n.p = current.p
        
        n.s = n.s == 3 and 4 or 1
        
        local mn, mx = 1, #open+1
        
        while mn ~= mx do
          local m = floor((mn+mx)*0.5)
          
          if open[m].g > g then
            mn = m+1
          else
            mx = m
          end
        end
        
        table.insert(open, mn, n)
      elseif n.s == 1 or n.s == 4 then
        local g = cd+d
        local og = n.g
        if g < og then
          n.p = current.p
          
          local mn, mx = 1, #open
          
          while mn ~= mx do
            local m = floor((mn+mx)*0.5)
            if open[m].g > og then
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
            local m = floor((mn+mx)*0.5)
            
            if open[m].g > g then
              mn = m+1
            else
              mx = m
            end
          end
          
          n.g = g
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
  local graph = self:CreateTable("graph")
  graph.nodes = self:CreateTable("graph.nodes")
  graph.end_nodes = self:CreateTable("graph.end_nodes")
  graph.open = self:CreateTable("graph.open")
  
  graph.CreateNode = Graph_CreateNode
  graph.DestroyNode = Graph_DestroyNode
  graph.Reset = Graph_Reset
  
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

function QuestHelper:ReleaseGraph(graph)
  graph:Reset()
  self:ReleaseTable(graph.nodes)
  self:ReleaseTable(graph.end_nodes)
  self:ReleaseTable(graph.open)
  self:ReleaseTable(graph)
end

QuestHelper.world_graph = QuestHelper:CreateGraph()
