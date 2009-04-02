QuestHelper_File["graph_flightpath.lua"] = "Development Version"
QuestHelper_Loadtime["graph_flightpath.lua"] = GetTime()

-- Name to Name, gives {time, accurate}
QH_Flight_Distances = {}

function QH_redo_flightpath()
  
  -- First, let's figure out if the player can fly.
  -- The logic we're using: if he has 225 or 300, then he can fly in Outland. If he's got Cold Weather Flying and those levels, he can fly in Northrend.
  do
    local ridingLevel = (select(4,GetAchievementInfo(892)) and 300) or (select(4,GetAchievementInfo(890)) and 225) or (select(4,GetAchievementInfo(889)) and 150) or (select(4,GetAchievementInfo(891)) and 75) or 0 -- this is thanks to Maldivia, who is a fucking genius
    local has_cwf = not not GetSpellInfo(GetSpellInfo(54197))
    
    if ridingLevel >= 225 then
      QH_Graph_Flyplaneset(3) -- Outland
    end
    
    if ridingLevel >= 225 and has_cwf then
      QH_Graph_Flyplaneset(4) -- Northrend
    end
  end
  
  local flightids = DB_ListItems("flightmasters")
  local flightdb = {}
  
  local has = {}
  
  for k, v in pairs(flightids) do
    flightdb[v] = DB_GetItem("flightmasters", v)
    if QuestHelper_KnownFlightRoutes[flightdb[v].name] then
      has[k] = true
    end
  end
  
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
            if not adjacency[k] then adjacency[k] = {} end
            if not adjacency[dest] then adjacency[dest] = {} end
            QuestHelper: Assert(not (adjacency[k][dest] and adjacency[k][dest].time))
            adjacency[k][dest] = {time = route.distance, dist = route.distance, original = true}
            
            -- no such thing as strongly asymmetric routes
            -- note that we're only hitting up adjacency here, because we don't have "time info"
            if not adjacency[dest][k] then
              adjacency[dest][k] = {dist = route.distance * 1.1, original = true} -- It's original because, in theory, we may end up basing other links on this one. It's still not time-authoritative, though.
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
  end
  
  for _, pivot in ipairs(imp_flat) do
    QH_Timeslice_Yield()
    for _, i in ipairs(imp_flat) do
      for _, j in ipairs(imp_flat) do
        if adjacency[i][pivot] and adjacency[pivot][j] then
          local cst = adjacency[i][pivot].dist + adjacency[pivot][j].dist
          if not adjacency[i][j] or adjacency[i][j].dist > cst then
            if not adjacency[i][j] then adjacency[i][j] = {} end
            adjacency[i][j].dist = cst
            adjacency[i][j].original = nil
          end
        end
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
  
  -- reset!
  QH_Flight_Distances = {}
  
  for src, t in pairs(adjacency) do
    QH_Timeslice_Yield()
    for dest, dat in pairs(t) do
      do
        local fms = flightmasters[src]
        local fmd = flightmasters[dest]
        if fms and fmd then
          fms = fms.loc[1]
          fmd = fmd.loc[1]
          
          QuestHelper: Assert(fms.c and (fms.c == fmd.c))
          QuestHelper: Assert(fms.rc and (fms.rc == fmd.rc))
        end
      end
      
      do
        local sname = flightdb[src].name
        local dname = flightdb[dest].name
        
        if not QH_Flight_Distances[sname] then QH_Flight_Distances[sname] = {} end
        QuestHelper: Assert(not QH_Flight_Distances[sname][dname])
        QH_Flight_Distances[sname][dname] = {adjacency[src][dest].dist, not adjacency[src][dest].original}
      end
      
      if dat.original and not (src > dest and adjacency[dest][src] and adjacency[dest][src].original) then
        local fms = flightmasters[src]
        local fmd = flightmasters[dest]
        if fms and fmd then
          fms = fms.loc[1]
          fmd = fmd.loc[1]
          
          QuestHelper: Assert(fms.c and (fms.c == fmd.c))
          QuestHelper: Assert(fms.rc and (fms.rc == fmd.rc))
          
          local snode = {x = fms.x, y = fms.y, c = fms.c, p = QuestHelper_IndexLookup[fms.rc][fms.rz], map_desc = {QHFormat("WAYPOINT_REASON", QHFormat("FLIGHT_POINT", flightdb[dest].name))}, condense_class = "flightpath"}
          local dnode = {x = fmd.x, y = fmd.y, c = fmd.c, p = QuestHelper_IndexLookup[fmd.rc][fmd.rz], map_desc = {QHFormat("WAYPOINT_REASON", QHFormat("FLIGHT_POINT", flightdb[src].name))}, condense_class = "flightpath"}
          
          local ret = adjacency[dest][src] and adjacency[dest][src].original and adjacency[dest][src].dist
          QH_Graph_Plane_Makelink("flightpath", snode, dnode, dat.dist, ret)
        end
      end
    end
  end
end
