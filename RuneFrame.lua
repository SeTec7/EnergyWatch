--[[

	EnergyWatch-specific RuneFrame

--]]

local MAX_RUNES = 6

function EnergyWatchUI.CreateRuneFrame()
	local runeFrame = CreateFrame("Frame", "EWRuneFrame", EnergyWatchBar)
	runeFrame:SetFrameStrata("LOW")
	runeFrame:SetToplevel(true)
	runeFrame:SetSize(130, 18)
	runeFrame:SetPoint("TOP", EnergyWatchBar, "BOTTOM", 4, 4) --, 54, 34)
	
	-- Rune order is 1,2,5,6,3,4  which coresponds to Blood, Blood, Frost, Frost, Unholy, Unholy
	local button1 = CreateFrame("Button", "EWRuneButtonIndividual1", runeFrame, "RuneButtonIndividualTemplate")
	button1:SetPoint("LEFT", runeFrame, "LEFT", 0, 0)
	
	local button2 = CreateFrame("Button", "EWRuneButtonIndividual2", runeFrame, "RuneButtonIndividualTemplate")
	button2:SetPoint("LEFT", button1, "RIGHT", 3, 0)
	
	local button5 = CreateFrame("Button", "EWRuneButtonIndividual5", runeFrame, "RuneButtonIndividualTemplate")
	button5:SetPoint("LEFT", button2, "RIGHT", 3, 0)
	
	local button6 = CreateFrame("Button", "EWRuneButtonIndividual6", runeFrame, "RuneButtonIndividualTemplate")
	button6:SetPoint("LEFT", button5, "RIGHT", 3, 0)
	
	local button3 = CreateFrame("Button", "EWRuneButtonIndividual3", runeFrame, "RuneButtonIndividualTemplate")
	button3:SetPoint("LEFT", button6, "RIGHT", 3, 0)
	
	local button4 = CreateFrame("Button", "EWRuneButtonIndividual4", runeFrame, "RuneButtonIndividualTemplate")
	button4:SetPoint("LEFT", button3, "RIGHT", 3, 0)
	
	EnergyWatchUI.RuneFrame_OnLoad(runeFrame)
end

function EnergyWatchUI.RuneFrame_OnLoad (self)
	-- Disable rune frame if not a death knight.
	local _, class = UnitClass("player");
	
	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide();
	end
	
	self:RegisterEvent("RUNE_POWER_UPDATE");
	self:RegisterEvent("RUNE_TYPE_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	self:SetScript("OnEvent", EnergyWatchUI.RuneFrame_OnEvent);
end

function EnergyWatchUI.RuneFrame_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		for i=1,MAX_RUNES do
			local runeButton = _G["EWRuneButtonIndividual"..i];
			if runeButton then
				RuneButton_Update(runeButton, i, true);
			end
		end
	elseif ( event == "RUNE_POWER_UPDATE" ) then
		local runeIndex, isEnergize = ...;
		if runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES  then 
			local runeButton = _G["EWRuneButtonIndividual"..runeIndex];
			local cooldown = _G[runeButton:GetName().."Cooldown"];
			
			local start, duration, runeReady = GetRuneCooldown(runeIndex);
			
			if not runeReady  then
				if start then
					CooldownFrame_SetTimer(cooldown, start, duration, 1);
				end
				runeButton.energize:Stop();
			else
				cooldown:Hide();
				runeButton.shine:SetVertexColor(1, 1, 1);
				RuneButton_ShineFadeIn(runeButton.shine)
			end
			
			if isEnergize  then
				runeButton.energize:Play();
			end
		else 
			assert(false, "Bad rune index")
		end
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local runeIndex = ...;
		if ( runeIndex and runeIndex >= 1 and runeIndex <= MAX_RUNES ) then
			RuneButton_Update(_G["EWRuneButtonIndividual"..runeIndex], runeIndex);
		end
	end
end