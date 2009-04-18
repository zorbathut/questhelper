QuestHelper_File["arrow.lua"] = "Development Version"
QuestHelper_Loadtime["arrow.lua"] = GetTime()

--[[ This entire file is pretty liberally ganked from TomTom (and then modified) under the following license:

-------------------------------------------------------------------------
  Copyright (c) 2006-2007, James N. Whitehead II
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * The name or alias of the copyright holder may not be used to endorse 
        or promote products derived from this software without specific prior
        written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------

Thanks, James! <3   ]]

local function ColorGradient(perc, ...)
	local num = select("#", ...)
	local hexes = type(select(1, ...)) == "string"

	if perc == 1 then
		return select(num-2, ...), select(num-1, ...), select(num, ...)
	end

	num = num / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2
	r1, g1, b1 = select((segment*3)+1, ...), select((segment*3)+2, ...), select((segment*3)+3, ...)
	r2, g2, b2 = select((segment*3)+4, ...), select((segment*3)+5, ...), select((segment*3)+6, ...)

	if not r2 or not g2 or not b2 then
		return r1, g1, b1
	else
		return r1 + (r2-r1)*relperc,
		g1 + (g2-g1)*relperc,
		b1 + (b2-b1)*relperc
	end
end

local wayframe = CreateFrame("Button", nil, UIParent)
wayframe:SetHeight(42)
wayframe:SetWidth(56)
wayframe:SetPoint("CENTER", 0, 0)
wayframe:EnableMouse(true)
wayframe:SetMovable(true)
wayframe:Hide()

wif = wayframe

-- Frame used to control the scaling of the title and friends
local titleframe = CreateFrame("Frame", nil, wayframe)

wayframe.title = titleframe:CreateFontString("OVERLAY", nil, "GameFontHighlightSmall")
wayframe.status = titleframe:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
wayframe.tta = titleframe:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
wayframe.title:SetPoint("TOP", wayframe, "BOTTOM", 0, 0)
wayframe.status:SetPoint("TOP", wayframe.title, "BOTTOM", 0, 0)
wayframe.tta:SetPoint("TOP", wayframe.status, "BOTTOM", 0, 0)

local OnUpdate

local function OnDragStart(self, button)
	if not locky then  -- TODO TWEAKERY
		self:StartMoving()
	end
end

local function OnDragStop(self, button)
	self:StopMovingOrSizing()
end

local function OnEvent(self, event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" and true then -- TODO TWEAKERY
		self:Show()
    OnUpdate(self, nil)
	end
end

wayframe:SetScript("OnDragStart", OnDragStart)
wayframe:SetScript("OnDragStop", OnDragStop)
wayframe:RegisterForDrag("LeftButton")
wayframe:RegisterEvent("ZONE_CHANGED_NEW_AREA")
wayframe:SetScript("OnEvent", OnEvent)

wayframe.arrow = wayframe:CreateTexture("OVERLAY")
wayframe.arrow:SetTexture("Interface\\Addons\\QuestHelper\\arrow_image")
wayframe.arrow:SetAllPoints()

local active_point, arrive_distance, showDownArrow, point_title
active_point = {}

local function wpupdate(c, z, x, y, desc)
  active_point.c, active_point.z, active_point.x, active_point.y = c, z, x, y
  wayframe.title:SetText(desc)
  wayframe:Show()
  OnUpdate(self, nil)
end

QuestHelper:AddWaypointCallback(wpupdate)

local status = wayframe.status
local tta = wayframe.tta
local arrow = wayframe.arrow
local count = 0
local last_distance = 0
local tta_throttle = 0
local speed = 0
local speed_count = 0

OnUpdate = function(self, elapsed)
	if not active_point.c or QuestHelper.collect_rc ~= active_point.c or QuestHelper.collect_delayed or QuestHelper.InBrokenInstance then
		self:Hide()
		return
	end

  local dist, dx, dy = QuestHelper.Astrolabe:ComputeDistance(QuestHelper.collect_rc, QuestHelper.collect_rz, QuestHelper.collect_rx, QuestHelper.collect_ry, active_point.c, active_point.z, active_point.x, active_point.y)
  
  if dist then
    status:SetText(QHFormat("DISTANCE", math.floor(dist + 0.5)))
  else
    status:SetText("")
  end
  
	local cell

	-- Showing the arrival arrow?
  --[[
	if dist and dist <= 10 then
		if not showDownArrow then
			arrow:SetHeight(70)
			arrow:SetWidth(53)
			arrow:SetTexture("Interface\\AddOns\\TomTom\\Images\\Arrow-UP")
			arrow:SetVertexColor(0, 1, 0)
			showDownArrow = true
		end

		count = count + 1
		if count >= 55 then
			count = 0
		end

		cell = count
		local column = cell % 9
		local row = floor(cell / 9)

		local xstart = (column * 53) / 512
		local ystart = (row * 70) / 512
		local xend = ((column + 1) * 53) / 512
		local yend = ((row + 1) * 70) / 512
		arrow:SetTexCoord(xstart,xend,ystart,yend)
	else
		if showDownArrow then
			arrow:SetHeight(56)
			arrow:SetWidth(42)
			arrow:SetTexture("Interface\\AddOns\\TomTom\\Images\\Arrow")
			showDownArrow = false
		end]]

		local angle = atan2(dy, dx) / 360 * (math.pi * 2) - math.pi / 2 -- degrees. seriously what
    if angle < 0 then angle = angle + math.pi * 2 end
		local player = GetPlayerFacing()
		angle = angle - player

		local perc = math.abs((math.pi - math.abs(angle)) / math.pi)

		local gr,gg,gb = 0, 1, 0
		local mr,mg,mb = 1, 1, 0
		local br,bg,bb = 1, 0, 0
		local r,g,b = ColorGradient(perc, br, bg, bb, mr, mg, mb, gr, gg, gb)		
		arrow:SetVertexColor(r,g,b)

		cell = floor(angle / (math.pi * 2) * 108 + 0.5) % 108
		local column = cell % 9
		local row = floor(cell / 9)

		local xstart = (column * 56) / 512
		local ystart = (row * 42) / 512
		local xend = ((column + 1) * 56) / 512
		local yend = ((row + 1) * 42) / 512
		arrow:SetTexCoord(xstart,xend,ystart,yend)
	--end

	-- Calculate the TTA every second  (%01d:%02d)

  --[[
  if elapsed then
    tta_throttle = tta_throttle + elapsed

    if tta_throttle >= 1.0 then
      -- Calculate the speed in yards per sec at which we're moving
      local current_speed = (last_distance - dist) / tta_throttle

      if last_distance == 0 then
        current_speed = 0
      end

      if speed_count < 2 then
        speed = (speed + current_speed) / 2
        speed_count = speed_count + 1
      else
        speed_count = 0
        speed = current_speed
      end

      if speed > 0 then
        local eta = math.abs(dist / speed)
        tta:SetFormattedText("%01d:%02d", eta / 60, eta % 60) 
      else
        tta:SetText("")
      end
      
      last_distance = dist
      tta_throttle = 0
    end
  end
  ]]
end

wayframe:SetScript("OnUpdate", OnUpdate)
