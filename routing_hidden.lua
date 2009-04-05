QuestHelper_File["routing_hidden.lua"] = "Development Version"
QuestHelper_Loadtime["routing_hidden.lua"] = GetTime()


function QH_Hidden_Menu()
  local menu = QuestHelper:CreateMenu()
  QuestHelper:CreateMenuTitle(menu, QHText("HIDDEN_TITLE"))
  
  local part_of_cluster = {}
  
  local ignore_reasons = {}
  
  QH_Route_TraverseClusters(
    function (clust)
      local igcount = {}
      
      for _, v in ipairs(clust) do
        part_of_cluster[v] = true
        
        QH_Route_IgnoredReasons_Node(v, function (reason)
          igcount[reason] = (igcount[reason] or 0) + 1
        end)
      end
      
      QH_Route_IgnoredReasons_Cluster(clust, function (reason)
        igcount[reason] = #clust
      end)
      
      for k, v in pairs(igcount) do
        if not ignore_reasons[clust[1]] then ignore_reasons[clust[1]] = {} end
        table.insert(ignore_reasons[clust[1]], {reason = k, partial = (v ~= #clust), v = v, cs = #clust})
      end
      
      if not ignore_reasons[clust[1]] then
        if QH_Route_Ignored_Cluster(clust) then
          ignore_reasons[clust[1]] = {{}} -- no known reason, but still non-zero reasons
        end
      end
    end
  )
  
  QH_Route_TraverseNodes(
    function (node)
      if part_of_cluster[node] then return end
      
      QH_Route_IgnoredReasons_Node(node, function(reason)
        if not ignore_reasons[node] then ignore_reasons[node] = {} end
        table.insert(ignore_reasons, {reason = reason, partial = false})
      end)
    end
  )
  
  local ignore_sorty = {}
  
  for k, v in pairs(ignore_reasons) do
    table.insert(ignore_sorty, {objective = k, ignores = v})
  end
  
  table.sort(ignore_sorty, function (a, b)
    if a.objective.type_quest and b.objective.type_quest then
      --if a.objective.type_quest.level ~= b.objective.type_quest.level then return a.objective.type_quest.level < b.objective.type_quest.level end
      return a.objective.type_quest.title < b.objective.type_quest.title
    elseif a.objective.type_quest then return true
    elseif b.objective.type_quest then return false
    else
      -- meh
      return false
    end
  end)
  -- we'll sort this eventually
  
  for _, v in ipairs(ignore_sorty) do
    local ignored = QuestHelper:CreateMenuItem(menu, v.objective.map_desc[1])
    
    local ignored_menu = QuestHelper:CreateMenu()
    ignored:SetSubmenu(ignored_menu)
    
    QuestHelper:CreateMenuItem(ignored_menu, QHText("HIDDEN_SHOW"))
    
    for _, ign in ipairs(v.ignores) do
      local thisitem = QuestHelper:CreateMenuItem(ignored_menu, ign.reason.friendly_reason)
      
      local deign_menu = QuestHelper:CreateMenu()
      thisitem:SetSubmenu(deign_menu)
      
      QuestHelper:CreateMenuItem(deign_menu, QHText("HIDDEN_EXCEPTION"))
      QuestHelper:CreateMenuItem(deign_menu, QHFormat("DISABLE_FILTER", ign.reason.friendly_name))
    end
  end
  
  menu:ShowAtCursor()
end
