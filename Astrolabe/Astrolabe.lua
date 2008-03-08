--[[
Name: Astrolabe
Revision: $Rev: 68 $
$Date: 2008-02-25 21:43:22 -0500 (Mon, 25 Feb 2008) $
Author(s): Esamynn (esamynn at wowinterface.com)
Inspired By: Gatherer by Norganna
             MapLibrary by Kristofer Karlsson (krka at kth.se)
Documentation: http://wiki.esamynn.org/Astrolabe
SVN: http://svn.esamynn.org/astrolabe/
Description:
	This is a library for the World of Warcraft UI system to place
	icons accurately on both the Minimap and on Worldmaps.  
	This library also manages and updates the position of Minimap icons 
	automatically.  

Copyright (C) 2006-2008 James Carrothers

License:
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

Note:
	This library's source code is specifically designed to work with
	World of Warcraft's interpreted AddOn system.  You have an implicit
	licence to use this library with these facilities since that is its
	designated purpose as per:
	http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

-- WARNING!!!
-- DO NOT MAKE CHANGES TO THIS LIBRARY WITHOUT FIRST CHANGING THE LIBRARY_VERSION_MAJOR
-- STRING (to something unique) OR ELSE YOU MAY BREAK OTHER ADDONS THAT USE THIS LIBRARY!!!
local LIBRARY_VERSION_MAJOR = "Astrolabe-0.4 QuestHelperPTR"
local LIBRARY_VERSION_MINOR = tonumber(string.match("$Revision: 68 $", "(%d+)") or 1)

if not DongleStub then error(LIBRARY_VERSION_MAJOR .. " requires DongleStub.") end
if not DongleStub:IsNewerVersion(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR) then return end

local Astrolabe = {};

-- define local variables for Data Tables (defined at the end of this file)
local WorldMapSize, MinimapSize, ValidMinimapShapes;

function Astrolabe:GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end


--------------------------------------------------------------------------------------------------------------
-- Config Constants
--------------------------------------------------------------------------------------------------------------

local configConstants = { 
	MinimapUpdateMultiplier = true, 
}

-- this constant is multiplied by the current framerate to determine
-- how many icons are updated each frame
Astrolabe.MinimapUpdateMultiplier = 1;


--------------------------------------------------------------------------------------------------------------
-- Working Tables
--------------------------------------------------------------------------------------------------------------

Astrolabe.LastPlayerPosition = { 0, 0, 0, 0 };
Astrolabe.MinimapIcons = {};
Astrolabe.IconsOnEdge = {};
Astrolabe.IconsOnEdge_GroupChangeCallbacks = {};

Astrolabe.UpdateTimer = 0;
Astrolabe.ForceNextUpdate = false;
Astrolabe.IconsOnEdgeChanged = false;

-- This variable indicates whether we know of a visible World Map or not.  
-- The state of this variable is controlled by the AstrolabeMapMonitor library.  
Astrolabe.WorldMapVisible = false;

local AddedOrUpdatedIcons = {}
local MinimapIconsMetatable = { __index = AddedOrUpdatedIcons }


--------------------------------------------------------------------------------------------------------------
-- Local Pointers for often used API functions
--------------------------------------------------------------------------------------------------------------

local twoPi = math.pi * 2;
local atan2 = math.atan2;
local sin = math.sin;
local cos = math.cos;
local abs = math.abs;
local sqrt = math.sqrt;
local min = math.min
local yield = coroutine.yield


--------------------------------------------------------------------------------------------------------------
-- Internal Utility Functions
--------------------------------------------------------------------------------------------------------------

local function assert(level,condition,message)
	if not condition then
		error(message,level)
	end
end

local function argcheck(value, num, ...)
	assert(1, type(num) == "number", "Bad argument #2 to 'argcheck' (number expected, got " .. type(level) .. ")")

	for i=1,select("#", ...) do
		if type(value) == select(i, ...) then return end
	end

	local types = strjoin(", ", ...)
	local name = string.match(debugstack(2,2,0), ": in function [`<](.-)['>]")
	error(string.format("Bad argument #%d to 'Astrolabe.%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end

local function getContPosition( zoneData, z, x, y )
	if ( z ~= 0 ) then
		zoneData = zoneData[z];
		x = x * zoneData.width + zoneData.xOffset;
		y = y * zoneData.height + zoneData.yOffset;
	else
		x = x * zoneData.width;
		y = y * zoneData.height;
	end
	return x, y;
end


--------------------------------------------------------------------------------------------------------------
-- General Utility Functions
--------------------------------------------------------------------------------------------------------------

function Astrolabe:ComputeDistance( c1, z1, x1, y1, c2, z2, x2, y2 )
	--[[
	argcheck(c1, 2, "number");
	assert(3, c1 >= 0, "ComputeDistance: Illegal continent index to c1: "..c1);
	argcheck(z1, 3, "number", "nil");
	argcheck(x1, 4, "number");
	argcheck(y1, 5, "number");
	argcheck(c2, 6, "number");
	assert(3, c2 >= 0, "ComputeDistance: Illegal continent index to c2: "..c2);
	argcheck(z2, 7, "number", "nil");
	argcheck(x2, 8, "number");
	argcheck(y2, 9, "number");
	--]]
	
	z1 = z1 or 0;
	z2 = z2 or 0;
	
	local dist, xDelta, yDelta;
	if ( c1 == c2 and z1 == z2 ) then
		-- points in the same zone
		local zoneData = WorldMapSize[c1];
		if ( z1 ~= 0 ) then
			zoneData = zoneData[z1];
		end
		xDelta = (x2 - x1) * zoneData.width;
		yDelta = (y2 - y1) * zoneData.height;
	
	elseif ( c1 == c2 ) then
		-- points on the same continent
		local zoneData = WorldMapSize[c1];
		x1, y1 = getContPosition(zoneData, z1, x1, y1);
		x2, y2 = getContPosition(zoneData, z2, x2, y2);
		xDelta = (x2 - x1);
		yDelta = (y2 - y1);
	
	elseif ( c1 and c2 ) then
		local cont1 = WorldMapSize[c1];
		local cont2 = WorldMapSize[c2];
		if ( cont1.parentContinent == cont2.parentContinent ) then
			x1, y1 = getContPosition(cont1, z1, x1, y1);
			x2, y2 = getContPosition(cont2, z2, x2, y2);
			if ( c1 ~= cont1.parentContinent ) then
				x1 = x1 + cont1.xOffset;
				y1 = y1 + cont1.yOffset;
			end
			if ( c2 ~= cont2.parentContinent ) then
				x2 = x2 + cont2.xOffset;
				y2 = y2 + cont2.yOffset;
			end
			
			xDelta = x2 - x1;
			yDelta = y2 - y1;
		end
	
	end
	if ( xDelta and yDelta ) then
		dist = sqrt(xDelta*xDelta + yDelta*yDelta);
	end
	return dist, xDelta, yDelta;
end

function Astrolabe:TranslateWorldMapPosition( C, Z, xPos, yPos, nC, nZ )
	--[[
	argcheck(C, 2, "number");
	argcheck(Z, 3, "number", "nil");
	argcheck(xPos, 4, "number");
	argcheck(yPos, 5, "number");
	argcheck(nC, 6, "number");
	argcheck(nZ, 7, "number", "nil");
	--]]
	
	Z = Z or 0;
	nZ = nZ or 0;
	if ( nC < 0 ) then
		return;
	end
	
	local zoneData;
	if ( C == nC and Z == nZ ) then
		return xPos, yPos;
	
	elseif ( C == nC ) then
		-- points on the same continent
		zoneData = WorldMapSize[C];
		xPos, yPos = getContPosition(zoneData, Z, xPos, yPos);
		if ( nZ ~= 0 ) then
			zoneData = WorldMapSize[C][nZ];
			xPos = xPos - zoneData.xOffset;
			yPos = yPos - zoneData.yOffset;
		end
	
	elseif ( C and nC ) and ( WorldMapSize[C].parentContinent == WorldMapSize[nC].parentContinent ) then
		-- different continents, same world
		zoneData = WorldMapSize[C];
		local parentContinent = zoneData.parentContinent;
		xPos, yPos = getContPosition(zoneData, Z, xPos, yPos);
		if ( C ~= parentContinent ) then
			-- translate up to world map if we aren't there already
			xPos = xPos + zoneData.xOffset;
			yPos = yPos + zoneData.yOffset;
			zoneData = WorldMapSize[parentContinent];
		end
		if ( nC ~= parentContinent ) then
			-- translate down to the new continent
			zoneData = WorldMapSize[nC];
			xPos = xPos - zoneData.xOffset;
			yPos = yPos - zoneData.yOffset;
			if ( nZ ~= 0 ) then
				zoneData = zoneData[nZ];
				xPos = xPos - zoneData.xOffset;
				yPos = yPos - zoneData.yOffset;
			end
		end
	
	else
		return;
	end
	
	return (xPos / zoneData.width), (yPos / zoneData.height);
end

--*****************************************************************************
-- This function will do its utmost to retrieve some sort of valid position 
-- for the specified unit, including changing the current map zoom (if needed).  
-- Map Zoom is returned to its previous setting before this function returns.  
--*****************************************************************************
function Astrolabe:GetUnitPosition( unit, noMapChange )
	local x, y = GetPlayerMapPosition(unit);
	if ( x <= 0 and y <= 0 ) then
		if ( noMapChange ) then
			-- no valid position on the current map, and we aren't allowed
			-- to change map zoom, so return
			return;
		end
		local lastCont, lastZone = GetCurrentMapContinent(), GetCurrentMapZone();
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition(unit);
		if ( x <= 0 and y <= 0 ) then
			SetMapZoom(GetCurrentMapContinent());
			x, y = GetPlayerMapPosition(unit);
			if ( x <= 0 and y <= 0 ) then
				-- we are in an instance or otherwise off the continent map
				return;
			end
		end
		local C, Z = GetCurrentMapContinent(), GetCurrentMapZone();
		if ( C ~= lastCont or Z ~= lastZone ) then
			SetMapZoom(lastCont, lastZone); -- set map zoom back to what it was before
		end
		return C, Z, x, y;
	end
	return GetCurrentMapContinent(), GetCurrentMapZone(), x, y;
end

--*****************************************************************************
-- This function will do its utmost to retrieve some sort of valid position 
-- for the specified unit, including changing the current map zoom (if needed).  
-- However, if a monitored WorldMapFrame (See AstrolabeMapMonitor.lua) is 
-- visible, then will simply return nil if the current zoom does not provide 
-- a valid position for the player unit.  Map Zoom is returned to its previous 
-- setting before this function returns, if it was changed.  
--*****************************************************************************
function Astrolabe:GetCurrentPlayerPosition()
	local x, y = GetPlayerMapPosition("player");
	if ( x <= 0 and y <= 0 ) then
		if ( self.WorldMapVisible ) then
			-- we know there is a visible world map, so don't cause 
			-- WORLD_MAP_UPDATE events by changing map zoom
			return;
		end
		local lastCont, lastZone = GetCurrentMapContinent(), GetCurrentMapZone();
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition("player");
		if ( x <= 0 and y <= 0 ) then
			SetMapZoom(GetCurrentMapContinent());
			x, y = GetPlayerMapPosition("player");
			if ( x <= 0 and y <= 0 ) then
				-- we are in an instance or otherwise off the continent map
				return;
			end
		end
		local C, Z = GetCurrentMapContinent(), GetCurrentMapZone();
		if ( C ~= lastCont or Z ~= lastZone ) then
			SetMapZoom(lastCont, lastZone); --set map zoom back to what it was before
		end
		return C, Z, x, y;
	end
	return GetCurrentMapContinent(), GetCurrentMapZone(), x, y;
end


--------------------------------------------------------------------------------------------------------------
-- Working Table Cache System
--------------------------------------------------------------------------------------------------------------

local tableCache = {};
tableCache["__mode"] = "v";
setmetatable(tableCache, tableCache);

local function GetWorkingTable( icon )
	if ( tableCache[icon] ) then
		return tableCache[icon];
	else
		local T = {};
		tableCache[icon] = T;
		return T;
	end
end


--------------------------------------------------------------------------------------------------------------
-- Minimap Icon Placement
--------------------------------------------------------------------------------------------------------------

--*****************************************************************************
-- local variables specifically for use in this section
--*****************************************************************************
local minimapRotationEnabled = false;
local minimapShape = false;

-- I don't cache the actual direction information because I don't want to 
-- encur the work required to retrieve it unless I'm actually going to use the information.  
local MinimapCompassRing = MiniMapCompassRing;


local function placeIconOnMinimap( minimap, minimapZoom, mapWidth, mapHeight, icon, dist, xDist, yDist )
	local mapDiameter;
	if ( Astrolabe.minimapOutside ) then
		mapDiameter = MinimapSize.outdoor[minimapZoom];
	else
		mapDiameter = MinimapSize.indoor[minimapZoom];
	end
	local mapRadius = mapDiameter / 2;
	local xScale = mapDiameter / mapWidth;
	local yScale = mapDiameter / mapHeight;
	local iconDiameter = ((icon:GetWidth() / 2) + 3) * xScale;
	local iconOnEdge = nil;
	local isRound = true;
	
	if ( minimapRotationEnabled ) then
		-- for the life of me, I cannot figure out why the following 
		-- math works, but it does
		local dir = atan2(xDist, yDist) + MinimapCompassRing:GetFacing();
		xDist = dist * sin(dir);
		yDist = dist * cos(dir);
	end
	
	if ( minimapShape and not (xDist == 0 or yDist == 0) ) then
		isRound = (xDist < 0) and 1 or 3;
		if ( yDist < 0 ) then
			isRound = minimapShape[isRound];
		else
			isRound = minimapShape[isRound + 1];
		end
	end
	
	-- for non-circular portions of the Minimap edge
	if not ( isRound ) then
		dist = (abs(xDist) > abs(yDist)) and abs(xDist) or abs(yDist);
	end

	if ( (dist + iconDiameter) > mapRadius ) then
		-- position along the outside of the Minimap
		iconOnEdge = true;
		local factor = (mapRadius - iconDiameter) / dist;
		xDist = xDist * factor;
		yDist = yDist * factor;
	end
	
	if ( Astrolabe.IconsOnEdge[icon] ~= iconOnEdge ) then
		Astrolabe.IconsOnEdge[icon] = iconOnEdge;
		Astrolabe.IconsOnEdgeChanged = true;
	end
	
	icon:ClearAllPoints();
	icon:SetPoint("CENTER", minimap, "CENTER", xDist/xScale, -yDist/yScale);
end

function Astrolabe:PlaceIconOnMinimap( icon, continent, zone, xPos, yPos )
	-- check argument types
	argcheck(icon, 2, "table");
	assert(3, icon.SetPoint and icon.ClearAllPoints, "Usage Message");
	argcheck(continent, 3, "number");
	argcheck(zone, 4, "number", "nil");
	argcheck(xPos, 5, "number");
	argcheck(yPos, 6, "number");
	
	local lC, lZ, lx, ly = unpack(self.LastPlayerPosition);
	local dist, xDist, yDist = self:ComputeDistance(lC, lZ, lx, ly, continent, zone, xPos, yPos);
	if not ( dist ) then
		--icon's position has no meaningful position relative to the player's current location
		return -1;
	end
	local iconData = GetWorkingTable(icon);
	if ( self.MinimapIcons[icon] ) then
		self.MinimapIcons[icon] = nil;
	end
	AddedOrUpdatedIcons[icon] = iconData
	
	iconData.continent = continent;
	iconData.zone = zone;
	iconData.xPos = xPos;
	iconData.yPos = yPos;
	iconData.dist = dist;
	iconData.xDist = xDist;
	iconData.yDist = yDist;
	
	minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
	
	-- check Minimap Shape
	minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
	
	-- place the icon on the Minimap and :Show() it
	local map = Minimap
	placeIconOnMinimap(map, map:GetZoom(), map:GetWidth(), map:GetHeight(), icon, dist, xDist, yDist);
	icon:Show()
	
	return 0;
end

function Astrolabe:RemoveIconFromMinimap( icon )
	if not ( self.MinimapIcons[icon] ) then
		return 1;
	end
	AddedOrUpdatedIcons[icon] = nil
	self.MinimapIcons[icon] = nil;
	self.IconsOnEdge[icon] = nil;
	icon:Hide();
	return 0;
end

function Astrolabe:RemoveAllMinimapIcons()
	self:DumpNewIconsCache()
	local minimapIcons = self.MinimapIcons;
	local IconsOnEdge = self.IconsOnEdge;
	for k, v in pairs(minimapIcons) do
		minimapIcons[k] = nil;
		IconsOnEdge[k] = nil;
		k:Hide();
	end
end

local lastZoom; -- to remember the last seen Minimap zoom level

-- local variables to track the status of the two update coroutines
local fullUpdateInProgress = true
local resetIncrementalUpdate = false
local resetFullUpdate = false

-- Incremental Update Code
do
	-- local variables to track the incremental update coroutine
	local incrementalUpdateCrashed = true
	local incrementalUpdateThread
	
	local function UpdateMinimapIconPositions( self )
		yield()
		
		while ( true ) do
			self:DumpNewIconsCache() -- put new/updated icons into the main datacache
			
			resetIncrementalUpdate = false -- by definition, the incremental update is reset if it is here
			
			local C, Z, x, y = self:GetCurrentPlayerPosition();
			if ( C and C >= 0 ) then
				local Minimap = Minimap;
				local lastPosition = self.LastPlayerPosition;
				local lC, lZ, lx, ly = unpack(lastPosition);
				
				minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
				
				-- check current frame rate
				local numPerCycle = min(50, GetFramerate() * (self.MinimapUpdateMultiplier or 1))
				
				-- check Minimap Shape
				minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
				
				if ( lC == C and lZ == Z and lx == x and ly == y ) then
					-- player has not moved since the last update
					if ( lastZoom ~= Minimap:GetZoom() or self.ForceNextUpdate or minimapRotationEnabled ) then
						local currentZoom = Minimap:GetZoom();
						lastZoom = currentZoom;
						local mapWidth = Minimap:GetWidth();
						local mapHeight = Minimap:GetHeight();
						numPerCycle = numPerCycle * 2
						local count = 0
						for icon, data in pairs(self.MinimapIcons) do
							placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, data.dist, data.xDist, data.yDist);
							
							count = count + 1
							if ( count > numPerCycle ) then
								count = 0
								yield()
								-- check if the incremental update cycle needs to be reset 
								-- because a full update has been run
								if ( resetIncrementalUpdate ) then
									break;
								end
							end
						end
						self.ForceNextUpdate = false;
					end
				else
					local dist, xDelta, yDelta = self:ComputeDistance(lC, lZ, lx, ly, C, Z, x, y);
					if ( dist ) then
						local currentZoom = Minimap:GetZoom();
						lastZoom = currentZoom;
						local mapWidth = Minimap:GetWidth();
						local mapHeight = Minimap:GetHeight();
						local count = 0
						for icon, data in pairs(self.MinimapIcons) do
							local xDist = data.xDist - xDelta;
							local yDist = data.yDist - yDelta;
							local dist = sqrt(xDist*xDist + yDist*yDist);
							placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, dist, xDist, yDist);
							
							data.dist = dist;
							data.xDist = xDist;
							data.yDist = yDist;
							
							count = count + 1
							if ( count >= numPerCycle ) then
								count = 0
								yield()
								-- check if the incremental update cycle needs to be reset 
								-- because a full update has been run
								if ( resetIncrementalUpdate ) then
									break;
								end
							end
						end
					else
						self:RemoveAllMinimapIcons()
					end
					
					if not ( resetIncrementalUpdate ) then
						lastPosition[1] = C;
						lastPosition[2] = Z;
						lastPosition[3] = x;
						lastPosition[4] = y;
					end
				end
			else
				if not ( self.WorldMapVisible ) then
					self.processingFrame:Hide();
				end
			end
			
			-- if we've been reset, then we want to start the new cycle immediately
			if not ( resetIncrementalUpdate ) then
				yield()
			end
		end
	end
	
	function Astrolabe:UpdateMinimapIconPositions()
		if ( fullUpdateInProgress ) then
			-- if we're in the middle a a full update, we want to finish that first
			self:CalculateMinimapIconPositions()
		else
			if ( incrementalUpdateCrashed ) then
				incrementalUpdateThread = coroutine.wrap(UpdateMinimapIconPositions)
				incrementalUpdateThread(self) --initialize the thread
			end
			incrementalUpdateCrashed = true
			incrementalUpdateThread()
			incrementalUpdateCrashed = false
		end
	end
end

-- Full Update Code
do
	-- local variables to track the full update coroutine
	local fullUpdateCrashed = true
	local fullUpdateThread
	
	local function CalculateMinimapIconPositions( self )
		yield()
		
		while ( true ) do
			self:DumpNewIconsCache() -- put new/updated icons into the main datacache
			
			resetFullUpdate = false -- by definition, the full update is reset if it is here
			fullUpdateInProgress = true -- set the flag the says a full update is in progress
			
			local C, Z, x, y = self:GetCurrentPlayerPosition();
			if ( C and C >= 0 ) then
				minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
				
				-- check current frame rate
				local numPerCycle = GetFramerate() * (self.MinimapUpdateMultiplier or 1) * 2
				
				-- check Minimap Shape
				minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
				
				local currentZoom = Minimap:GetZoom();
				lastZoom = currentZoom;
				local Minimap = Minimap;
				local mapWidth = Minimap:GetWidth();
				local mapHeight = Minimap:GetHeight();
				local count = 0
				for icon, data in pairs(self.MinimapIcons) do
					local dist, xDist, yDist = self:ComputeDistance(C, Z, x, y, data.continent, data.zone, data.xPos, data.yPos);
					if ( dist ) then
						placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, dist, xDist, yDist);
						
						data.dist = dist;
						data.xDist = xDist;
						data.yDist = yDist;
					else
						self:RemoveIconFromMinimap(icon)
					end
					
					count = count + 1
					if ( count >= numPerCycle ) then
						count = 0
						yield()
						-- check if we need to restart due to the full update being reset
						if ( resetFullUpdate ) then
							break;
						end
					end
				end
				
				if not ( resetFullUpdate ) then
					local lastPosition = self.LastPlayerPosition;
					lastPosition[1] = C;
					lastPosition[2] = Z;
					lastPosition[3] = x;
					lastPosition[4] = y;
					
					resetIncrementalUpdate = true
				end
			else
				if not ( self.WorldMapVisible ) then
					self.processingFrame:Hide();
				end
			end
			
			-- if we've been reset, then we want to start the new cycle immediately
			if not ( resetFullUpdate ) then
				fullUpdateInProgress = false
				yield()
			end
		end
	end
	
	function Astrolabe:CalculateMinimapIconPositions( reset )
		if ( fullUpdateCrashed ) then
			fullUpdateThread = coroutine.wrap(CalculateMinimapIconPositions)
			fullUpdateThread(self) --initialize the thread
		elseif ( reset ) then
			resetFullUpdate = true
		end
		fullUpdateCrashed = true
		fullUpdateThread()
		fullUpdateCrashed = false
		
		-- return result flag
		if ( fullUpdateInProgress ) then
			return 1 -- full update started, but did not complete on this cycle
		
		else
			if ( resetIncrementalUpdate ) then
				return 0 -- update completed
			else
				return -1 -- full update did no occur for some reason
			end
		
		end
	end
end

function Astrolabe:GetDistanceToIcon( icon )
	local data = self.MinimapIcons[icon];
	if ( data ) then
		return data.dist, data.xDist, data.yDist;
	end
end

function Astrolabe:IsIconOnEdge( icon )
	return self.IconsOnEdge[icon];
end

function Astrolabe:GetDirectionToIcon( icon )
	local data = self.MinimapIcons[icon];
	if ( data ) then
		local dir = atan2(data.xDist, -(data.yDist))
		if ( dir > 0 ) then
			return twoPi - dir;
		else
			return -dir;
		end
	end
end

function Astrolabe:Register_OnEdgeChanged_Callback( func, ident )
	-- check argument types
	argcheck(func, 2, "function");
	
	self.IconsOnEdge_GroupChangeCallbacks[func] = ident;
end

--*****************************************************************************
-- INTERNAL USE ONLY PLEASE!!!
-- Calling this function at the wrong time can cause errors
--*****************************************************************************
function Astrolabe:DumpNewIconsCache()
	local MinimapIcons = self.MinimapIcons
	for icon, data in pairs(AddedOrUpdatedIcons) do
		MinimapIcons[icon] = data
		AddedOrUpdatedIcons[icon] = nil
	end
	-- we now need to restart any updates that were in progress
	resetIncrementalUpdate = true
	resetFullUpdate = true
end


--------------------------------------------------------------------------------------------------------------
-- World Map Icon Placement
--------------------------------------------------------------------------------------------------------------

function Astrolabe:PlaceIconOnWorldMap( worldMapFrame, icon, continent, zone, xPos, yPos )
	-- check argument types
	argcheck(worldMapFrame, 2, "table");
	assert(3, worldMapFrame.GetWidth and worldMapFrame.GetHeight, "Usage Message");
	argcheck(icon, 3, "table");
	assert(3, icon.SetPoint and icon.ClearAllPoints, "Usage Message");
	argcheck(continent, 4, "number");
	argcheck(zone, 5, "number", "nil");
	argcheck(xPos, 6, "number");
	argcheck(yPos, 7, "number");
	
	local C, Z = GetCurrentMapContinent(), GetCurrentMapZone();
	local nX, nY = self:TranslateWorldMapPosition(continent, zone, xPos, yPos, C, Z);
	
	-- anchor and :Show() the icon if it is within the boundry of the current map, :Hide() it otherwise
	if ( nX and nY and (0 < nX and nX <= 1) and (0 < nY and nY <= 1) ) then
		icon:ClearAllPoints();
		icon:SetPoint("CENTER", worldMapFrame, "TOPLEFT", nX * worldMapFrame:GetWidth(), -nY * worldMapFrame:GetHeight());
		icon:Show();
	else
		icon:Hide();
	end
	return nX, nY;
end


--------------------------------------------------------------------------------------------------------------
-- Handler Scripts
--------------------------------------------------------------------------------------------------------------

function Astrolabe:OnEvent( frame, event )
	if ( event == "MINIMAP_UPDATE_ZOOM" ) then
		-- update minimap zoom scale
		local Minimap = Minimap;
		local curZoom = Minimap:GetZoom();
		if ( GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") ) then
			if ( curZoom < 2 ) then
				Minimap:SetZoom(curZoom + 1);
			else
				Minimap:SetZoom(curZoom - 1);
			end
		end
		if ( GetCVar("minimapZoom")+0 == Minimap:GetZoom() ) then
			self.minimapOutside = true;
		else
			self.minimapOutside = false;
		end
		Minimap:SetZoom(curZoom);
		
		-- re-calculate all Minimap Icon positions
		if ( frame:IsVisible() ) then
			self:CalculateMinimapIconPositions(true);
		end
	
	elseif ( event == "PLAYER_LEAVING_WORLD" ) then
		frame:Hide();
		self:RemoveAllMinimapIcons(); --dump all minimap icons
	
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		frame:Show();
		if not ( frame:IsVisible() ) then
			-- do the minimap recalculation anyways if the OnShow script didn't execute
			-- this is done to ensure the accuracy of information about icons that were 
			-- inserted while the Player was in the process of zoning
			self:CalculateMinimapIconPositions(true);
		end
	
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		frame:Hide();
		frame:Show();
	
	end
end

function Astrolabe:OnUpdate( frame, elapsed )
	-- on-edge group changed call-backs
	if ( self.IconsOnEdgeChanged ) then
		self.IconsOnEdgeChanged = false;
		for func in pairs(self.IconsOnEdge_GroupChangeCallbacks) do
			pcall(func);
		end
	end
	
	self:UpdateMinimapIconPositions();
end

function Astrolabe:OnShow( frame )
	-- set the world map to a zoom with a valid player position
	if not ( self.WorldMapVisible ) then
		SetMapToCurrentZone();
	end
	local C, Z = Astrolabe:GetCurrentPlayerPosition();
	if ( C and C >= 0 ) then
		SetMapZoom(C, Z);
	else
		frame:Hide();
		return
	end
	
	-- re-calculate minimap icon positions
	self:CalculateMinimapIconPositions(true);
end

-- called by AstrolabMapMonitor when all world maps are hidden
function Astrolabe:AllWorldMapsHidden()
	if ( IsLoggedIn() ) then
		self.processingFrame:Hide();
		self.processingFrame:Show();
	end
end


--------------------------------------------------------------------------------------------------------------
-- Library Registration
--------------------------------------------------------------------------------------------------------------

local function activate( newInstance, oldInstance )
	if ( oldInstance ) then -- this is an upgrade activate
		if ( oldInstance.DumpNewIconsCache ) then
			oldInstance:DumpNewIconsCache()
		end
		for k, v in pairs(oldInstance) do
			if ( type(v) ~= "function" and (not configConstants[k]) ) then
				newInstance[k] = v;
			end
		end
		Astrolabe = oldInstance;
	else
		local frame = CreateFrame("Frame");
		newInstance.processingFrame = frame;
		
		newInstance.ContinentList = { GetMapContinents() };
		for C in pairs(newInstance.ContinentList) do
			local zones = { GetMapZones(C) };
			newInstance.ContinentList[C] = zones;
			for Z in ipairs(zones) do
				SetMapZoom(C, Z);
				zones[Z] = GetMapInfo();
			end
		end
	end
	configConstants = nil -- we don't need this anymore
	
	local frame = newInstance.processingFrame;
	frame:Hide();
	frame:SetParent("Minimap");
	frame:UnregisterAllEvents();
	frame:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	frame:RegisterEvent("PLAYER_LEAVING_WORLD");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	frame:SetScript("OnEvent",
		function( frame, event, ... )
			Astrolabe:OnEvent(frame, event, ...);
		end
	);
	frame:SetScript("OnUpdate",
		function( frame, elapsed )
			Astrolabe:OnUpdate(frame, elapsed);
		end
	);
	frame:SetScript("OnShow",
		function( frame )
			Astrolabe:OnShow(frame);
		end
	);
	
	setmetatable(Astrolabe.MinimapIcons, MinimapIconsMetatable)
end

DongleStub:Register(Astrolabe, activate)


--------------------------------------------------------------------------------------------------------------
-- Data
--------------------------------------------------------------------------------------------------------------

-- diameter of the Minimap in game yards at
-- the various possible zoom levels
MinimapSize = {
	indoor = {
		[0] = 300, -- scale
		[1] = 240, -- 1.25
		[2] = 180, -- 5/3
		[3] = 120, -- 2.5
		[4] = 80,  -- 3.75
		[5] = 50,  -- 6
	},
	outdoor = {
		[0] = 466 + 2/3, -- scale
		[1] = 400,       -- 7/6
		[2] = 333 + 1/3, -- 1.4
		[3] = 266 + 2/6, -- 1.75
		[4] = 200,       -- 7/3
		[5] = 133 + 1/3, -- 3.5
	},
}

ValidMinimapShapes = {
	-- { upper-left, lower-left, upper-right, lower-right }
	["SQUARE"]                = { false, false, false, false },
	["CORNER-TOPLEFT"]        = { true,  false, false, false },
	["CORNER-TOPRIGHT"]       = { false, false, true,  false },
	["CORNER-BOTTOMLEFT"]     = { false, true,  false, false },
	["CORNER-BOTTOMRIGHT"]    = { false, false, false, true },
	["SIDE-LEFT"]             = { true,  true,  false, false },
	["SIDE-RIGHT"]            = { false, false, true,  true },
	["SIDE-TOP"]              = { true,  false, true,  false },
	["SIDE-BOTTOM"]           = { false, true,  false, true },
	["TRICORNER-TOPLEFT"]     = { true,  true,  true,  false },
	["TRICORNER-TOPRIGHT"]    = { true,  false, true,  true },
	["TRICORNER-BOTTOMLEFT"]  = { true,  true,  false, true },
	["TRICORNER-BOTTOMRIGHT"] = { false, true,  true,  true },
}

-- distances across and offsets of the world maps
-- in game yards
WorldMapSize={
	[0]={
		parentContinent=0,
		height=29687.905754037,
		width=44531.829079386,
		xOffset=0,
		yOffset=0
	},
	-- Kalimdor
	{ --[1]
		parentContinent=0,
		height=24532.386305342,
		width=36798.575359196,
		xOffset=-8310.7681251506,
		yOffset=1815.1526779896,
		zoneData={
			Ashenvale={
				height=3843.6221240668,
				width=5766.4721345318,
				xOffset=15366.085464037,
				yOffset=8126.713908302
			},
			Aszhara={
				height=3381.1375417611,
				width=5070.6607909343,
				xOffset=20343.001112696,
				yOffset=7457.9865704082
			},
			AzuremystIsle={
				height=2714.4913210941,
				width=4070.6906964145,
				xOffset=9966.2687707248,
				yOffset=5460.1363642328
			},
			Barrens={
				height=6756.0262118665,
				width=10132.991892526,
				xOffset=14443.200306691,
				yOffset=11187.028824652
			},
			BloodmystIsle={
				height=2174.9266959146,
				width=3262.3849216671,
				xOffset=9541.2823400603,
				yOffset=3424.7874945181
			},
			Darkshore={
				height=4366.5208580781,
				width=6549.7786993784,
				xOffset=14124.460994588,
				yOffset=4466.4194003486
			},
			Darnassis={
				height=705.70567333749,
				width=1058.295414503,
				xOffset=14127.764461188,
				yOffset=2561.4983426369
			},
			Desolace={
				height=2997.8168958386,
				width=4495.6807641679,
				xOffset=12832.838238721,
				yOffset=12347.40725372
			},
			Durotar={
				height=3524.8821845629,
				width=5287.3216195345,
				xOffset=19028.462850265,
				yOffset=10991.202322091
			},
			Dustwallow={
				height=3499.8843197438,
				width=5249.8238057236,
				xOffset=18040.995039434,
				yOffset=14832.740411762
			},
			Felwood={
				height=3833.2069308505,
				width=5749.8056974767,
				xOffset=15424.41602703,
				yOffset=5666.3780364908
			},
			Feralas={
				height=4633.1790221484,
				width=6949.7633153294,
				xOffset=11624.545875445,
				yOffset=15166.064469702
			},
			Moonglade={
				height=1539.5340849777,
				width=2308.2595360225,
				xOffset=18447.230749133,
				yOffset=4308.088968855
			},
			Mulgore={
				height=3424.8865656049,
				width=5137.3285497961,
				xOffset=15018.179654394,
				yOffset=13072.383186255
			},
			Ogrimmar={
				height=935.38490326594,
				width=1402.5566566014,
				xOffset=20746.505238887,
				yOffset=10525.673518549
			},
			Silithus={
				height=2322.839113481,
				width=3483.2173086784,
				xOffset=14528.61227756,
				yOffset=18757.611512067
			},
			StonetalonMountains={
				height=3256.142265387,
				width=4883.1707520626,
				xOffset=13820.303151922,
				yOffset=9882.9053934294
			},
			Tanaris={
				height=4599.8510918672,
				width=6899.7677118672,
				xOffset=17284.771342056,
				yOffset=18674.279935689
			},
			Teldrassil={
				height=3393.6373989167,
				width=5091.4964777226,
				xOffset=13251.572482646,
				yOffset=968.61735516915
			},
			TheExodar={
				height=704.66477748195,
				width=1056.7335776056,
				xOffset=10532.616161646,
				yOffset=6276.0414889321
			},
			ThousandNeedles={
				height=2933.2357486749,
				width=4399.8514848436,
				xOffset=17499.347178305,
				yOffset=16766.01014304
			},
			ThunderBluff={
				height=695.80884172607,
				width=1043.7133825394,
				xOffset=16549.379527388,
				yOffset=13649.447910209
			},
			UngoroCrater={
				height=2466.584659935,
				width=3699.8762907414,
				xOffset=16532.712325456,
				yOffset=18765.943589995
			},
			Winterspring={
				height=4733.1764490779,
				width=7099.7596971444,
				xOffset=17382.684367348,
				yOffset=4266.424746788
			}
		}
	},
	-- Eastern Kingdoms
	{ --[2]
		parentContinent=0,
		height=27148.788838114,
		width=40739.819885956,
		xOffset=14405.315901167,
		yOffset=290.31301262213,
		zoneData={
			Alterac={
				height=1866.6051075802,
				width=2799.9074768874,
				xOffset=17388.054754586,
				yOffset=9676.0229433151
			},
			Arathi={
				height=2399.9201947932,
				width=3599.8833455792,
				xOffset=19037.998868622,
				yOffset=11309.303140362
			},
			Badlands={
				height=1658.2796911743,
				width=2487.4141150676,
				xOffset=20250.460598416,
				yOffset=17065.360766225
			},
			BlastedLands={
				height=2233.256957668,
				width=3349.8863326024,
				xOffset=19412.986991739,
				yOffset=21742.290454656
			},
			BurningSteppes={
				height=1952.0180513059,
				width=2929.069190361,
				xOffset=18438.020163075,
				yOffset=18206.991582306
			},
			DeadwindPass={
				height=1666.6120304509,
				width=2499.916827822,
				xOffset=19004.667048101,
				yOffset=21042.313350678
			},
			DunMorogh={
				height=3283.2233801922,
				width=4924.8372997317,
				xOffset=16369.338161122,
				yOffset=15052.929180051
			},
			Duskwood={
				height=1799.9394470626,
				width=2699.9105427257,
				xOffset=17338.056075437,
				yOffset=20892.318758519
			},
			EasternPlaguelands={
				height=2581.1609508738,
				width=3870.7027279512,
				xOffset=20356.705380502,
				yOffset=7376.1017840774
			},
			Elwynn={
				height=2314.5060525489,
				width=3470.7183837918,
				xOffset=16635.996183008,
				yOffset=19115.294770034
			},
			EversongWoods={
				height=3283.2231955353,
				width=4924.8357787708,
				xOffset=20258.793262132,
				yOffset=2534.594351595
			},
			Ghostlands={
				height=2199.9271264612,
				width=3299.8883568216,
				xOffset=21054.599621539,
				yOffset=5309.5008930332
			},
			Hilsbrad={
				height=2133.2625673851,
				width=3199.8926386196,
				xOffset=17104.7313083,
				yOffset=10775.987091928
			},
			Hinterlands={
				height=2566.5805869696,
				width=3849.871297415,
				xOffset=19746.309303217,
				yOffset=9709.3562586347
			},
			Ironforge={
				height=527.58723202438,
				width=790.59825666048,
				xOffset=18884.929631646,
				yOffset=15745.063063869
			},
			LochModan={
				height=1839.522762795,
				width=2758.2416902046,
				xOffset=20165.045068556,
				yOffset=15663.324752514
			},
			Redridge={
				height=1447.8682815595,
				width=2170.7619255211,
				xOffset=19742.142916867,
				yOffset=19750.689760337
			},
			SearingGorge={
				height=1487.4490149567,
				width=2231.1745411242,
				xOffset=18494.267763133,
				yOffset=17275.772582088
			},
			SilvermoonCity={
				height=806.74473609632,
				width=1211.4198304889,
				xOffset=22171.977996344,
				yOffset=3422.5214932016
			},
			Silverpine={
				height=2799.9063484681,
				width=4199.8617791937,
				xOffset=14721.475452167,
				yOffset=9509.3629799951
			},
			Stormwind={
				height=896.32482121162,
				width=1344.2262629965,
				xOffset=16790.437078494,
				yOffset=19454.550546513
			},
			Stranglethorn={
				height=4254.0270120791,
				width=6381.0360698854,
				xOffset=15950.603307922,
				yOffset=22344.353324778
			},
			Sunwell={
				height=2218.6753752397,
				width=3326.9824253266,
				xOffset=21073.342739257,
				yOffset=7.5944928467189
			},
			SwampOfSorrows={
				height=1529.1154299153,
				width=2293.6707632538,
				xOffset=20394.20434829,
				yOffset=20796.488798923
			},
			Tirisfal={
				height=3012.3996704574,
				width=4518.5988427234,
				xOffset=15138.13116769,
				yOffset=7338.6010643351
			},
			Undercity={
				height=640.08259952902,
				width=959.34298465489,
				xOffset=17298.198598077,
				yOffset=9298.0902817507
			},
			WesternPlaguelands={
				height=2866.5714856792,
				width=4299.8573077542,
				xOffset=17754.709121328,
				yOffset=7809.4184721594
			},
			Westfall={
				height=2333.2555508232,
				width=3499.8812228458,
				xOffset=15154.797392786,
				yOffset=20575.6623558
			},
			Wetlands={
				height=2756.1584779339,
				width=4135.2782506098,
				xOffset=18560.932837938,
				yOffset=13323.819539016
			}
		}
	},
	-- Outland
	{ --[3]
		parentContinent=3,
		height=11642.355227091,
		width=17463.532840637,
		zoneData={
			BladesEdgeMountains={
				height=3616.553353534,
				width=5424.8480359831,
				xOffset=4150.0681571398,
				yOffset=1412.9822662419
			},
			Hellfire={
				height=3443.6428904027,
				width=5164.4216154555,
				xOffset=7456.2232362532,
				yOffset=4339.9735287947
			},
			Nagrand={
				height=3683.2183862039,
				width=5524.8272951764,
				xOffset=2700.1214002002,
				yOffset=5779.5122120738
			},
			Netherstorm={
				height=3716.5477089102,
				width=5574.8278886627,
				xOffset=7512.4703866336,
				yOffset=365.09928584643
			},
			ShadowmoonValley={
				height=3666.5479170429,
				width=5499.8274326446,
				xOffset=8770.7654221369,
				yOffset=7769.0342591251
			},
			ShattrathCity={
				height=870.80630218923,
				width=1306.2103868475,
				xOffset=6860.565394342,
				yOffset=7295.0861454479
			},
			TerokkarForest={
				height=3599.8897120384,
				width=5399.8323053618,
				xOffset=5912.5212846648,
				yOffset=6821.1461126371
			},
			Zangarmarsh={
				height=3351.9786851139,
				width=5026.9255540439,
				xOffset=3520.9306855711,
				yOffset=3885.8213887912
			}
		}
	}
}


local zeroData;
zeroData = { xOffset = 0, height = 0, yOffset = 0, width = 0, __index = function() return zeroData end };
setmetatable(zeroData, zeroData);
setmetatable(WorldMapSize, zeroData);

for continent, zones in pairs(Astrolabe.ContinentList) do
	local mapData = WorldMapSize[continent];
	for index, mapName in pairs(zones) do
		if not ( mapData.zoneData[mapName] ) then
			--WE HAVE A PROBLEM!!!
			ChatFrame1:AddMessage("Astrolabe is missing data for "..select(index, GetMapZones(continent))..".");
			mapData.zoneData[mapName] = zeroData;
		end
		mapData[index] = mapData.zoneData[mapName];
		mapData.zoneData[mapName] = nil;
	end
end


-- register this library with AstrolabeMapMonitor, this will cause a full update if PLAYER_LOGIN has already fired
local AstrolabeMapMonitor = DongleStub("AstrolabeMapMonitor");
AstrolabeMapMonitor:RegisterAstrolabeLibrary(Astrolabe, LIBRARY_VERSION_MAJOR);
