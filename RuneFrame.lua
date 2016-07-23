--[[

	EnergyWatch-specific RuneFrame

--]]

local RUNETYPE_BLOOD = 1;
local RUNETYPE_UNHOLY = 2;
local RUNETYPE_FROST = 3;
local RUNETYPE_DEATH = 4;

local CURRENT_MAX_RUNES = 0;
local MAX_RUNE_CAPACITY = 7;
local POWER_TYPE_RUNES = 5;
local RUNES_DISPLAY_MODIFIER = 10;

local runeColor = {0.8, 0.1, 1};

function EnergyWatchUI.CreateRuneFrame()
	local runeFrame = CreateFrame("Frame", "EWRuneFrame", EnergyWatchBar)
	runeFrame:SetFrameStrata("LOW")
	runeFrame:SetToplevel(true)
	runeFrame:SetSize(130, 18)
	runeFrame:SetPoint("TOP", EnergyWatchBar, "BOTTOM", 4, 4) --, 54, 34)
	
	local button1 = CreateFrame("Button", "EWRuneButtonIndividual1", runeFrame, "RuneButtonIndividualTemplate")
	button1:SetPoint("LEFT", runeFrame, "LEFT", 0, 0)
	
	local button2 = CreateFrame("Button", "EWRuneButtonIndividual2", runeFrame, "RuneButtonIndividualTemplate")
	button2:SetPoint("LEFT", button1, "RIGHT", 3, 0)
	
	local button3 = CreateFrame("Button", "EWRuneButtonIndividual3", runeFrame, "RuneButtonIndividualTemplate")
	button3:SetPoint("LEFT", button2, "RIGHT", 3, 0)
	
	local button4 = CreateFrame("Button", "EWRuneButtonIndividual4", runeFrame, "RuneButtonIndividualTemplate")
	button4:SetPoint("LEFT", button3, "RIGHT", 3, 0)

	local button5 = CreateFrame("Button", "EWRuneButtonIndividual5", runeFrame, "RuneButtonIndividualTemplate")
	button5:SetPoint("LEFT", button4, "RIGHT", 3, 0)
	
	local button6 = CreateFrame("Button", "EWRuneButtonIndividual6", runeFrame, "RuneButtonIndividualTemplate")
	button6:SetPoint("LEFT", button5, "RIGHT", 3, 0)

	local button7 = CreateFrame("Button", "EWRuneButtonIndividual7", runeFrame, "RuneButtonIndividualTemplate")
	button7:SetPoint("LEFT", button6, "RIGHT", 3, 0)
	
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
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:SetScript("OnEvent", EnergyWatchUI.RuneFrame_OnEvent);
end

function EnergyWatchUI.RuneFrame_OnEvent (self, event, ...)
	if ( event == "UNIT_MAXPOWER") then
		EnergyWatchUI.RuneFrame_UpdateNumberOfShownRunes();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		EnergyWatchUI.RuneFrame_UpdateNumberOfShownRunes();
		for i=1, CURRENT_MAX_RUNES do
			EnergyWatchUI.RuneFrame_RunePowerUpdate(i, false);
		end
	elseif ( event == "RUNE_POWER_UPDATE") then
		local runeIndex, isEnergize = ...;
		EnergyWatchUI.RuneFrame_RunePowerUpdate(runeIndex, isEnergize)
		
	elseif ( event == "RUNE_TYPE_UPDATE" ) then
		local runeIndex = ...;
		if ( runeIndex and runeIndex >= 1 and runeIndex <= CURRENT_MAX_RUNES ) then
			RuneButton_Flash(_G["EWRuneButtonIndividual"..runeIndex]);
		end
	end
end

function EnergyWatchUI.RuneFrame_RunePowerUpdate(runeIndex, isEnergize)
	if runeIndex and runeIndex >= 1 and runeIndex <= CURRENT_MAX_RUNES  then 
		local runeButton = _G["EWRuneButtonIndividual"..runeIndex];
		local cooldown = runeButton.Cooldown;
			
		local start, duration, runeReady = GetRuneCooldown(runeIndex);
			
		if not runeReady  then
			if start then
				CooldownFrame_Set(cooldown, start, duration, true, true);
			end
			runeButton.energize:Stop();
		else
			cooldown:Hide();
			if (not isEnergize and not runeButton.energize:IsPlaying()) then 
				runeButton.shine:SetVertexColor(1, 1, 1);
				RuneButton_ShineFadeIn(runeButton.shine)
			end
		end
			
		if isEnergize  then
			runeButton.energize:Play();
		end
	else 
		assert(false, "Bad rune index")
	end
end

function EnergyWatchUI.RuneFrame_UpdateNumberOfShownRunes()
	CURRENT_MAX_RUNES = UnitPowerMax(RuneFrame:GetParent().unit, SPELL_POWER_RUNES);
	for i=1, MAX_RUNE_CAPACITY do
		local runeButton = _G["EWRuneButtonIndividual"..i];
		if(i <= CURRENT_MAX_RUNES) then
			runeButton:Show();
		else
			runeButton:Hide();
		end
		-- Shrink the runes sizes if you have all 7
		if (CURRENT_MAX_RUNES == MAX_RUNE_CAPACITY) then
			runeButton.Border:SetSize(21, 21);
			runeButton.rune:SetSize(21, 21);
			runeButton.Textures.Shine:SetSize(52, 31);
			runeButton.energize.RingScale:SetFromScale(0.6, 0.7);
			runeButton.energize.RingScale:SetToScale(0.7, 0.7);
			runeButton:SetSize(15, 15);
		else
			runeButton.Border:SetSize(24, 24);
			runeButton.rune:SetSize(24, 24);
			runeButton.Textures.Shine:SetSize(60, 35);
			runeButton.energize.RingScale:SetFromScale(0.7, 0.8);
			runeButton.energize.RingScale:SetToScale(0.8, 0.8);
			runeButton:SetSize(18, 18);
		end
	end
end