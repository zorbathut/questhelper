QuestHelper_File["graph_flightpath.lua"] = "Development Version"
QuestHelper_Loadtime["graph_flightpath.lua"] = GetTime()

function QH_redo_flightpath()
  local flightids = DB_ListItems("flightmasters")
  local flightdb = {}
  
  local has = {}
  
  for k, v in pairs(flightids) do
    flightdb[v] = DB_GetItem("flightmasters", v)
    if QuestHelper_KnownFlightRoutes[flightdb[v].name] then
      has[k] = true
    end
  end
  
  local adjacency_time = {}
  local adjacency = {}
  
  local important = {}
  
  QH_Timeslice_Yield()
  
  for k, v in pairs(has) do
    local tdb = DB_GetItem("flightpaths", k)
    if tdb then for dest, dat in pairs(tdb) do
      if has[dest] then
        for _, route in ipairs(dat) do
          local passes = true
          if route.path then for _, intermed in ipairs(route.path) do
            if not has[intermed] then passes = false break end
          end end
          
          if passes then
            --QuestHelper:TextOut(string.format("Found link between %s and %s, cost %f", flightdb[k].name, flightdb[dest].name, route.distance))
            if not adjacency_time[k] then adjacency_time[k] = {} adjacency[k] = {} end
            if not adjacency_time[dest] then adjacency_time[dest] = {} adjacency[dest] = {} end
            QuestHelper: Assert(not adjacency_time[k][dest])
            adjacency_time[k][dest] = route.distance
            adjacency[k][dest] = route.distance
            
            -- no such thing as strongly asymmetric routes
            -- note that we're only hitting up adjacency here, because we don't have "time info"
            if not adjacency[dest][k] then
              adjacency[dest][k] = route.distance * 1.1
            end
            
            important[k] = true
            important[dest] = true
            break
          end
        end
      end
    end end
  end
  
  QH_Timeslice_Yield()
  
  local imp_flat = {}
  local flightmasters = {}
  for k, v in pairs(important) do
    table.insert(imp_flat, k)
    if flightdb[k].mid then
      flightmasters[k] = DB_GetItem("monster", flightdb[k].mid)
      if not flightmasters[k].loc then QuestHelper:TextOut(string.format("Missing flightmaster location for node %d/%s", k, tostring(flightdb[k].name)))  flightmasters[k] = nil end
    else
      QuestHelper:TextOut(string.format("Missing flightmaster for node %d/%s", k, tostring(flightdb[k].name)))
    end
  end
  table.sort(imp_flat)
  
  for _, v in ipairs(imp_flat) do
    adjacency[v] = adjacency[v] or {}
    adjacency_time[v] = adjacency_time[v] or {}
  end
  
  for _, pivot in ipairs(imp_flat) do
    QH_Timeslice_Yield()
    for _, i in ipairs(imp_flat) do
      for _, j in ipairs(imp_flat) do
        if adjacency[i][pivot] and adjacency[pivot][j] then
          local cst = adjacency[i][pivot] + adjacency[pivot][j]
          adjacency[i][j] = math.min(adjacency[i][j] or 1000000, cst)
        end
      end
    end
  end
  
  QH_Timeslice_Yield()
  
  for src, t in pairs(adjacency) do
    for dest, cost in pairs(t) do
      if not adjacency_time[src][dest] then
        adjacency_time[src][dest] = cost
      end
    end
  end
  
  QH_Timeslice_Yield()
  
  do
    local clustaken = {}
    
    for src, t in pairs(adjacency) do
      if not clustaken[src] then
        local tcst = {}
        local tcct = 0
        local ctd = {}
        table.insert(ctd, src)
        
        while #ctd > 0 do
          local ite = table.remove(ctd)
          QuestHelper: Assert(not clustaken[ite] or tcst[ite])
          
          if not tcst[ite] then
            clustaken[ite] = true
            tcst[ite] = true
            for _, dst in pairs(imp_flat) do
              if adjacency[ite][dst] and not tcst[dst] then
                table.insert(ctd, dst)
              end
            end
            
            tcct = tcct + 1
          end
        end
        
        QuestHelper: TextOut(string.format("Starting with %d, cluster of %d", src, tcct))
      end
    end
  end
  
  QH_Graph_Plane_Destroylinks("flightpath")
  
  -- Right now we're converting this into the equivalent of running-speed, which means each second needs to be multiplied by 7 to get yard-equivalents
  for src, t in pairs(adjacency) do
    QH_Timeslice_Yield()
    for dest, cost in pairs(t) do
      if not (src > dest and adjacency[dest][src]) then
        local fms = flightmasters[src]
        local fmd = flightmasters[dest]
        if fms and fmd then
          fms = fms.loc[1]
          fmd = fmd.loc[1]
          local snode = {x = fms.x, y = fms.y, c = fms.c, p = QuestHelper_IndexLookup[fms.rc][fms.rz], map_desc = {string.format("Flightpath to %s", flightdb[dest].name)}}
          local dnode = {x = fmd.x, y = fmd.y, c = fmd.c, p = QuestHelper_IndexLookup[fmd.rc][fmd.rz], map_desc = {string.format("Flightpath to %s", flightdb[dest].name)}}
          QH_Graph_Plane_Makelink("flightpath", snode, dnode, cost * 7, adjacency[dest][src] * 7)
        end
      end
    end
  end
end
