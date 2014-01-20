--[[

	UI element creation/tracking for EnergyWatch

--]]


--[[ Globals --]]
EnergyWatchUI = {}

EnergyWatchUI.Fonts = {}
EnergyWatchUI.Fonts["Arial Narrow"] = { filename = "Fonts\\ARIALN.TTF" }
EnergyWatchUI.Fonts["Friz Quadrata TT"] = { filename = "Fonts\\FRIZQT__.TTF" }
EnergyWatchUI.Fonts["Morpheus"] = { filename = "Fonts\\MORPHEUS.TTF" }
EnergyWatchUI.Fonts["Skurri"] = { filename = "Fonts\\SKURRI.TTF" }

EnergyWatchUI.Textures = {}
EnergyWatchUI.Textures["Default"] = { filename = "Interface\\TargetingFrame\\UI-StatusBar" }
EnergyWatchUI.Textures["Alternate 1"] = { filename = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar" }
EnergyWatchUI.Textures["Alternate 2"] = { filename = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill" }

EnergyWatchUI.SizeOffsets = {
	barBgWidth = -9,
	barBgHeight = -13,
	barTextWidth = -6,
	barTextHeight = -10,
	barStatusWidth = -11,
	barStatusHeight = -13,
}

EnergyWatchUI.ScaleRatios = {
	barBorderWidth = 1.05,
	barBorderHeight = 1.45,
}

for k,v in pairs(EnergyWatchUI.Fonts) do
	local fontObject = CreateFont("EnergyWatchFontDropDownMenu" .. k)
	fontObject:SetFont(v.filename, 12)
	v.object = fontObject
end

--[[ Main addon frame creation and main local vars ]]--

function EnergyWatchUI.CreateEnergyBar()
	local barWidth = EnergyWatch.GetConfigValue("barWidth");
	local barHeight = EnergyWatch.GetConfigValue("barHeight");

	local energyBar = CreateFrame("Frame", "EnergyWatchBar", UIParent)
	energyBar:SetSize(barWidth, barHeight)
	energyBar:SetMovable(true)

	energyBar:SetScript("OnMouseDown", function (self, button)
		if button == "LeftButton" then
 			self:StartMoving();
 		end
	end)
	energyBar:SetScript("OnMouseUp", function (self, button)
		if button == "LeftButton" then
 			self:StopMovingOrSizing();
			local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1)

			EnergyWatch.SetConfigValue("barPosX", xOffset)
			EnergyWatch.SetConfigValue("barPosY", yOffset)
			EnergyWatch.SetConfigValue("barPosPoint", point)
 		end
	end)

	if EnergyWatch.GetConfigValue("locked") then
		energyBar:EnableMouse(false)
	else 
		energyBar:EnableMouse(true)
	end

	energyBar:SetPoint(EnergyWatch.GetConfigValue("barPosPoint"), EnergyWatch.GetConfigValue("barPosX"), EnergyWatch.GetConfigValue("barPosY"))
	energyBar:Hide()

	local energyBarBackground = energyBar:CreateTexture("EnergyWatchBarBackground", "BACKGROUND")
	energyBarBackground:SetSize(barWidth + EnergyWatchUI.SizeOffsets.barBgWidth, barHeight + EnergyWatchUI.SizeOffsets.barBgHeight)
	energyBarBackground:SetTexture(0, 0, 0, .5)
	energyBarBackground:SetPoint("CENTER", 0, 0)

	local energyBarBorder = energyBar:CreateTexture("EnergyWatchBarBorder", "OVERLAY")
	energyBarBorder:SetWidth(EnergyWatchBarBackground:GetWidth() * EnergyWatchUI.ScaleRatios.barBorderWidth)
	energyBarBorder:SetHeight(EnergyWatchBarBackground:GetHeight() * EnergyWatchUI.ScaleRatios.barBorderHeight)
	energyBarBorder:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
	energyBarBorder:SetPoint("CENTER", 0, 0)

	local energyBarFont = CreateFont("EnergyWatchTextFont")
	energyBarFont:SetFont(EnergyWatchUI.Fonts[EnergyWatch.GetConfigValue("barFont")].filename, EnergyWatch.GetConfigValue("barFontSize"), "OUTLINE")

	local energyBarText = energyBar:CreateFontString("EnergyWatchText", "OVERLAY", "EnergyWatchTextFont")
	energyBarText:SetSize(barWidth + EnergyWatchUI.SizeOffsets.barTextWidth, barHeight + EnergyWatchUI.SizeOffsets.barTextHeight)
	energyBarText:SetPoint("CENTER", 0, 0)
	energyBar.text = energyBarText

	local energyBarStatus = CreateFrame("StatusBar", "EnergyWatchStatusBar", energyBar)
	energyBarStatus:SetSize(barWidth + EnergyWatchUI.SizeOffsets.barStatusWidth, barHeight + EnergyWatchUI.SizeOffsets.barStatusHeight)
	energyBarStatus:SetPoint("CENTER", 0, 0)
	energyBarStatus:SetFrameLevel(energyBarStatus:GetParent():GetFrameLevel())
	energyBar.statusBar = energyBarStatus

	local energyBarTexture = energyBarStatus:CreateTexture("EnergyWatchStatusBarTexture", "BACKGROUND")
	energyBarTexture:SetTexture(EnergyWatchUI.Textures[EnergyWatch.GetConfigValue("barTexture")].filename)
	
	energyBarStatus:SetStatusBarTexture(energyBarTexture)
	
	energyBar.textConfig = "barText"
	energyBar.textConfigPoints = "barPointsText"
end
	
function EnergyWatchUI.CreateHealthBar()
	local barWidth = EnergyWatch.GetConfigValue("barWidth");
	local barHeight = EnergyWatch.GetConfigValue("barHeight");
	
	local healthBar = CreateFrame("Frame", "EnergyWatchHealthBar", EnergyWatchBar)
	healthBar:SetSize(barWidth, barHeight)
	healthBar:SetMovable(false)
	
	healthBar:SetPoint("BOTTOM", EnergyWatchBar, "TOP", 0, -11)
	healthBar:Hide()
	
	local healthBarBackground = healthBar:CreateTexture("EnergyWatchHealthBarBackground", "BACKGROUND")
	healthBarBackground:SetSize(barWidth + EnergyWatchUI.SizeOffsets.barBgWidth, barHeight + EnergyWatchUI.SizeOffsets.barBgHeight)
	healthBarBackground:SetTexture(0, 0, 0, .5)
	healthBarBackground:SetPoint("CENTER", 0, 0)

	local healthBarBorder = healthBar:CreateTexture("EnergyWatchHealthBarBorder", "OVERLAY")
	healthBarBorder:SetWidth(EnergyWatchHealthBarBackground:GetWidth() * EnergyWatchUI.ScaleRatios.barBorderWidth)
	healthBarBorder:SetHeight(EnergyWatchHealthBarBackground:GetHeight() * EnergyWatchUI.ScaleRatios.barBorderHeight)
	healthBarBorder:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
	healthBarBorder:SetPoint("CENTER", 0, 0)

	local healthBarFont = CreateFont("EnergyWatchHealthTextFont")
	healthBarFont:SetFont(EnergyWatchUI.Fonts[EnergyWatch.GetConfigValue("barFont")].filename, EnergyWatch.GetConfigValue("barFontSize"), "OUTLINE")

	local healthBarText = healthBar:CreateFontString("EnergyWatchHealthText", "OVERLAY", "EnergyWatchTextFont")
	healthBarText:SetSize(barWidth + EnergyWatchUI.SizeOffsets.barTextWidth, barHeight + EnergyWatchUI.SizeOffsets.barTextHeight)
	healthBarText:SetPoint("CENTER", 0, 0)
	healthBar.text = healthBarText

	local healthBarStatus = CreateFrame("StatusBar", "EnergyWatchHealthStatusBar", healthBar)
	healthBarStatus:SetSize(barWidth + EnergyWatchUI.SizeOffsets.barStatusWidth, barHeight + EnergyWatchUI.SizeOffsets.barStatusHeight)
	healthBarStatus:SetPoint("CENTER", 0, 0)
	healthBarStatus:SetFrameLevel(healthBarStatus:GetParent():GetFrameLevel())
	healthBar.statusBar = healthBarStatus
	
	local healthBarTexture = healthBarStatus:CreateTexture("EnergyWatchHealthStatusBarTexture", "BACKGROUND")
	healthBarTexture:SetTexture(EnergyWatchUI.Textures[EnergyWatch.GetConfigValue("barTexture")].filename)
	
	healthBarStatus:SetStatusBarTexture(healthBarTexture)
	healthBarStatus:SetStatusBarColor(0.0, 1.0, 0.0);
	
	healthBar.textConfig = "healthBarText"
	
	local healthBarMyHealPredictionBar = healthBar:CreateTexture("EnergyWatchHealthBarMyHealPredictionBar", "BACKGROUND", MyHealPredictionBarTemplate)
	local healthBarOtherHealPredictionBar = healthBar:CreateTexture("EnergyWatchHealthBarOtherHealPredictionBar", "BACKGROUND", OtherHealPredictionBarTemplate)
	local healthBarHealAbsorbBar = healthBar:CreateTexture("EnergyWatchHealthBarHealAbsorbBar", "BACKGROUND", HealAbsorbBarTemplate)
	local healthBarHealAbsorbBarLeftShadow = healthBar:CreateTexture("EnergyWatchHealthBarHealAbsorbBarLeftShadow", "BACKGROUND", HealAbsorbBarLeftShadowTemplate)
	local healthBarHealAbsorbBarRightShadow = healthBar:CreateTexture("EnergyWatchHealthBarHealAbsorbBarRightShadow", "BACKGROUND", HealAbsorbBarRightShadowTemplate)

	local healthBarTotalAbsorbBar = healthBar:CreateTexture("EnergyWatchHealthBarTotalAbsorbBar", "ARTWORK", TotalAbsorbBarTemplate)
	local healthBarTotalAbsorbBarOverlay = healthBar:CreateTexture("EnergyWatchHealthBarTotalAbsorbBarOverlay", "ARTWORK", TotalAbsorbBarOverlayTemplate, 1)

	local healthBarOverAbsorbGlow = healthBar:CreateTexture("EnergyWatchHealthBarOverAbsorbGlow", "ARTWORK", OverAbsorbGlowTemplate, 1)
	local healthBarOverHealAbsorbGlow = healthBar:CreateTexture("EnergyWatchHealthBarOverHealAbsorbGlow", "ARTWORK", OverHealAbsorbGlowTemplate, 1)
	
	--for Blizzard function UnitFrameHealPredictionBars_Update
	healthBar.healthbar = healthBarStatus
	healthBar.unit = "player"
	healthBar.myHealPredictionBar = healthBarMyHealPredictionBar;
	healthBar.otherHealPredictionBar = healthBarOtherHealPredictionBar
	healthBar.totalAbsorbBar = healthBarTotalAbsorbBar;
	healthBar.totalAbsorbBarOverlay = healthBarTotalAbsorbBarOverlay;
	healthBar.overAbsorbGlow = healthBarOverAbsorbGlow;
	healthBar.overHealAbsorbGlow = healthBarOverHealAbsorbGlow;
	healthBar.healAbsorbBar = healthBarHealAbsorbBar;
	healthBar.healAbsorbBarLeftShadow = healthBarHealAbsorbBarLeftShadow;
	healthBar.healAbsorbBarRightShadow = healthBarHealAbsorbBarRightShadow;
	if ( healthBar.myHealPredictionBar ) then
		healthBar.myHealPredictionBar:ClearAllPoints();
	end
	if ( healthBar.otherHealPredictionBar ) then
		healthBar.otherHealPredictionBar:ClearAllPoints();
	end
	if ( healthBar.totalAbsorbBar ) then
		healthBar.totalAbsorbBar:ClearAllPoints();
	end
	if ( healthBar.totalAbsorbBarOverlay ) then
		healthBar.totalAbsorbBar.overlay = healthBar.totalAbsorbBarOverlay;
		healthBar.totalAbsorbBarOverlay:SetAllPoints(healthBar.totalAbsorbBar);
		healthBar.totalAbsorbBarOverlay.tileSize = 32;
	end
	if ( healthBar.overAbsorbGlow ) then
		healthBar.overAbsorbGlow:ClearAllPoints();
		healthBar.overAbsorbGlow:SetPoint("TOPLEFT", healthBar.statusBar, "TOPRIGHT", -7, 0);
		healthBar.overAbsorbGlow:SetPoint("BOTTOMLEFT", healthBar.statusBar, "BOTTOMRIGHT", -7, 0);
	end
	if ( healthBar.healAbsorbBar ) then
		healthBar.healAbsorbBar:ClearAllPoints();
		healthBar.healAbsorbBar:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);
	end
	if ( healthBar.overHealAbsorbGlow ) then
		healthBar.overHealAbsorbGlow:ClearAllPoints();
		healthBar.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", healthBar.statusBar, "BOTTOMLEFT", 7, 0);
		healthBar.overHealAbsorbGlow:SetPoint("TOPRIGHT", healthBar.statusBar, "TOPLEFT", 7, 0);
	end
	if ( healAbsorbBarLeftShadow ) then
		healthBar.healAbsorbBarLeftShadow:ClearAllPoints();
	end
	if ( healAbsorbBarRightShadow ) then
		healthBar.healAbsorbBarRightShadow:ClearAllPoints();
	end
	if (healthBar.statusBar) then
		healthBar.capNumericDisplay = true;
	end
end

--[[ Config UI --]]
function EnergyWatchUI.CreateConfigMenu()
	local addonName, addonTitle, addonNotes = GetAddOnInfo('EnergyWatch')
	
	local configPanel = CreateFrame("Frame", "EnergyWatchConfigFrame", UIParent)
	configPanel.name = addonTitle
	configPanel.okay = function (self) return end
	configPanel.cancel = function (self) return end

	local configPanelText = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	configPanelText:SetPoint('TOPLEFT', 16, -16)
	configPanelText:SetText(addonTitle)

	local configPanelDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	configPanelDesc:SetPoint('TOPLEFT', configPanelText, 'BOTTOMLEFT', 0, -8)
	configPanelDesc:SetPoint('RIGHT', configPanel, -32, 0)
	configPanelDesc:SetWidth(600)
	configPanelDesc:SetJustifyH('LEFT')
	configPanelDesc:SetJustifyV('TOP')
	configPanelDesc:SetText(addonNotes)

	local lockBar = EnergyWatchUI.CreateCheckButton("Lock Position", configPanel,"Lock Bar Position", "locked", EnergyWatchUI.LockBarButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	lockBar:SetPoint('TOPLEFT', configPanelDesc, 'BOTTOMLEFT', 0, -10)

	local powerTypeOptionDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	powerTypeOptionDesc:SetPoint('TOPLEFT', lockBar, 'BOTTOMLEFT', -2, -10)
	powerTypeOptionDesc:SetText("Show Energy Watch when your character is using:")

	local powerTypeEnergy = EnergyWatchUI.CreateCheckButton("Energy", configPanel,"Show Energy Watch when your character is using Energy", "powerTypeEnergy", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	powerTypeEnergy:SetPoint('TOPLEFT', powerTypeOptionDesc, 'BOTTOMLEFT', 0, 0)

	local powerTypeFocus = EnergyWatchUI.CreateCheckButton("Focus", configPanel,"Show Energy Watch when your character is using Focus", "powerTypeFocus", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	powerTypeFocus:SetPoint('TOPLEFT', powerTypeEnergy, 'TOPRIGHT', 100, 0)

	local powerTypeMana = EnergyWatchUI.CreateCheckButton("Mana", configPanel,"Show Energy Watch when your character is using Mana", "powerTypeMana", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	powerTypeMana:SetPoint('TOPLEFT', powerTypeFocus, 'TOPRIGHT', 100, 0)

	local powerTypeRage = EnergyWatchUI.CreateCheckButton("Rage", configPanel,"Show Energy Watch when your character is using Rage", "powerTypeRage", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	powerTypeRage:SetPoint('TOPLEFT', powerTypeEnergy, 'BOTTOMLEFT', 0, 0)

	local powerTypeRunicPower = EnergyWatchUI.CreateCheckButton("Runic Power", configPanel,"Show Energy Watch when your character is using Runic Power", "powerTypeRunicPower", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	powerTypeRunicPower:SetPoint('TOPLEFT', powerTypeFocus, 'BOTTOMLEFT', 0, 0)

	local showOptionDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	showOptionDesc:SetPoint('TOPLEFT', powerTypeRage, 'BOTTOMLEFT', -0, -10)
	showOptionDesc:SetText("Show Energy Watch in these situations:")

	local showOptionHint = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	showOptionHint:SetPoint('TOPLEFT', showOptionDesc, 'BOTTOMLEFT', 2, -2)
	showOptionHint:SetText("Bar will only show if your character is currently using a power type selected above")

	local showAlways = EnergyWatchUI.CreateCheckButton("Always", configPanel,"Always show Energy Watch", "showAlways", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	showAlways:SetPoint('TOPLEFT', showOptionHint, 'BOTTOMLEFT', 0, 0)

	local showStealth = EnergyWatchUI.CreateCheckButton("In Stealth", configPanel,"Show Energy Watch while stealthed", "showStealth", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	showStealth:SetPoint('TOPLEFT', showAlways, 'BOTTOMLEFT', 10, 0)
	EnergyWatchUI.SetupInverseDependentControl(showAlways, showStealth)

	local showCombat = EnergyWatchUI.CreateCheckButton("In Combat", configPanel,"Show Energy Watch while in combat", "showCombat", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	showCombat:SetPoint('TOPLEFT', showStealth, 'BOTTOMLEFT', 0, 0)
	EnergyWatchUI.SetupInverseDependentControl(showAlways, showCombat)

	local showNonDefault = EnergyWatchUI.CreateCheckButton("When Energy Not Full/Empty", configPanel,"Show Energy Watch when your power type is not at default\n(0 for Rage/Runic Power, Max for others)", "showNonDefault", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	showNonDefault:SetPoint('TOPLEFT', showStealth, 'TOPRIGHT', 100, 0)
	EnergyWatchUI.SetupInverseDependentControl(showAlways, showNonDefault)

	local appearanceDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	appearanceDesc:SetPoint('TOPLEFT', showCombat, 'BOTTOMLEFT', -12, -10)
	appearanceDesc:SetText("Appearance:")

	local barAlphaDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	barAlphaDesc:SetPoint('TOPLEFT', appearanceDesc, 'BOTTOMLEFT', 2, -10)
	barAlphaDesc:SetText("Bar Alpha (Opacity): ")

	local barAlphaSlider = EnergyWatchUI.CreateSlider("BarAlphaSlider", configPanel, "barAlpha", EnergyWatchUI.BarAlphaSliderChanged, EnergyWatchUI.BarAlphaSliderEditBoxChanged, 0.0, 1.0, "0.0", "1.0", 0.01, "OptionsSliderTemplate")
	barAlphaSlider:SetPoint('TOPLEFT', barAlphaDesc, 'BOTTOMLEFT', 10, 0)

	local barHeightDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	barHeightDesc:SetPoint('TOPLEFT', barAlphaSlider, 'BOTTOMLEFT', -10, -10)
	barHeightDesc:SetText("Bar Height: ")

	local barHeightSlider = EnergyWatchUI.CreateSlider("barHeightSlider", configPanel, "barHeight", EnergyWatchUI.BarHeightSliderChanged, EnergyWatchUI.BarHeightSliderEditBoxChanged, 25, 50, "25", "50", 1, "OptionsSliderTemplate")
	barHeightSlider:SetPoint('TOPLEFT', barHeightDesc, 'BOTTOMLEFT', 10, 0)

	local barWidthDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	barWidthDesc:SetPoint('TOPLEFT', barHeightSlider, 'BOTTOMLEFT', -10, -10)
	barWidthDesc:SetText("Bar Width: ")

	local barWidthSlider = EnergyWatchUI.CreateSlider("barWidthSlider", configPanel, "barWidth", EnergyWatchUI.BarWidthSliderChanged, EnergyWatchUI.BarWidthSliderEditBoxChanged, 100, 300, "100", "300", 1, "OptionsSliderTemplate")
	barWidthSlider:SetPoint('TOPLEFT', barWidthDesc, 'BOTTOMLEFT', 10, 0)

	local barFontSizeDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	barFontSizeDesc:SetPoint('TOPLEFT', barWidthSlider, 'BOTTOMLEFT', -10, -10)
	barFontSizeDesc:SetText("Font Size: ")

	local barFontSizeSlider = EnergyWatchUI.CreateSlider("barFontSlider", configPanel, "barFontSize", EnergyWatchUI.BarFontSizeSliderChanged, EnergyWatchUI.BarFontSizeSliderEditBoxChanged, 4, 24, "4", "24", 1, "OptionsSliderTemplate")
	barFontSizeSlider:SetPoint('TOPLEFT', barFontSizeDesc, 'BOTTOMLEFT', 10, 0)

   	local barTextureDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	barTextureDesc:SetPoint('TOPLEFT', barAlphaDesc, 'TOPLEFT', 225, 0)
	barTextureDesc:SetText("Texture: ")

	local barTextureDropDown = EnergyWatchUI.CreateDropDown("barTextureDropDown", configPanel, "barTexture", 150, EnergyWatchUI.Textures, EnergyWatchUI.BarTextureDropDownChanged, "UIDropDownMenuTemplate")
	barTextureDropDown:SetPoint('TOPLEFT', barTextureDesc, 'BOTTOMLEFT', 0, 0)
    
	local barFontDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	barFontDesc:SetPoint('TOPLEFT', barHeightDesc, 'TOPLEFT', 225, 0)
	barFontDesc:SetText("Font: ")

	local barFontDropDown = EnergyWatchUI.CreateDropDown("barFontDropDown", configPanel, "barFont", 150, EnergyWatchUI.Fonts, EnergyWatchUI.BarFontDropDownChanged, "UIDropDownMenuTemplate")
	barFontDropDown:SetPoint('TOPLEFT', barFontDesc, 'BOTTOMLEFT', 0, 0)
	
	local miscDesc = configPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	miscDesc:SetPoint('TOPLEFT', barFontSizeSlider, 'BOTTOMLEFT', -10, -15)
	miscDesc:SetText("Miscellaneous options:")
	
	local capLargeNumbers = EnergyWatchUI.CreateCheckButton("Abbreviate Long Numbers", configPanel,"Show large numbers in abbreviated form, e.g. 54.7k", "capLargeNumbers", EnergyWatchUI.BooleanCheckButtonClicked, 'InterfaceOptionsCheckButtonTemplate')
	capLargeNumbers:SetPoint('TOPLEFT', miscDesc, 'BOTTOMLEFT', 0, 0)
	
	local textConfigPanel = CreateFrame("Frame", "EnergyWatchResourceBarConfigFrame", configPanel)
	textConfigPanel.name = "Bar Text"
	textConfigPanel.parent = "EnergyWatch"
	textConfigPanel.okay = function (self) return end
	textConfigPanel.cancel = function (self) return end
	
	local textConfigPanelTitle = textConfigPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	textConfigPanelTitle:SetPoint('TOPLEFT', 16, -16)
	textConfigPanelTitle:SetText(textConfigPanel.name)

	local textConfigPanelDesc = textConfigPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	textConfigPanelDesc:SetHeight(32)
	textConfigPanelDesc:SetPoint('TOPLEFT', textConfigPanelTitle, 'BOTTOMLEFT', 0, -8)
	textConfigPanelDesc:SetPoint('RIGHT', textConfigPanel, -32, 0)
	textConfigPanelDesc:SetNonSpaceWrap(true)
	textConfigPanelDesc:SetJustifyH('LEFT')
	textConfigPanelDesc:SetJustifyV('TOP')
	textConfigPanelDesc:SetText("These options allow you to control the appearance of EnergyWatch's resource bar")

	local textEditDesc = textConfigPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	textEditDesc:SetPoint('TOPLEFT', textConfigPanelDesc, 'BOTTOMLEFT', 0, 0)
	textEditDesc:SetText("Resource Bar Text")

	local textEditBox = EnergyWatchUI.CreateEditBox("ResourceText", textConfigPanel, "Normal", "Text to show normally", "barText", EnergyWatchUI.TextEditBoxChanged, EnergyWatchBar, "InputBoxTemplate")
	textEditBox:SetPoint('TOPLEFT', textEditDesc, 'BOTTOMLEFT', 80, 0)

	local pointsTextEditBox = EnergyWatchUI.CreateEditBox("ResourcePointsText", textConfigPanel, "With Points", "Text to show when you are playing a class/form that has Combo Points/Soul Shards/Holy Power", "barPointsText", EnergyWatchUI.TextEditBoxChanged, EnergyWatchBar, "InputBoxTemplate")
	pointsTextEditBox:SetPoint('TOPLEFT', textEditBox, 'BOTTOMLEFT', 0, 0)

	local healthTextEditDesc = textConfigPanel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	healthTextEditDesc:SetPoint('TOPLEFT', pointsTextEditBox, 'BOTTOMLEFT', -80, -10)
	healthTextEditDesc:SetText("Health Bar Text")
	
	local healthTextEditBox = EnergyWatchUI.CreateEditBox("HealthText", textConfigPanel, "Normal", "Text to show normally", "healthBarText", EnergyWatchUI.TextEditBoxChanged, EnergyWatchHealthBar, "InputBoxTemplate")
	healthTextEditBox:SetPoint('TOPLEFT', healthTextEditDesc, 'BOTTOMLEFT', 80, 0)
	
	local textEditHint = textConfigPanel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	textEditHint:SetPoint('TOPLEFT', healthTextEditBox, 'BOTTOMLEFT', -80, 0)
	textEditHint:SetText("&e = Energy, &em = Max Energy, &ep = Energy Percentage &c = Class Points")
	
	InterfaceOptions_AddCategory(configPanel)
	InterfaceOptions_AddCategory(textConfigPanel)
end

function EnergyWatchUI.TextEditBoxChanged(self, isUserInput)
	if isUserInput then
		--print("Caught change, changing " .. self.configKey .. " to " .. self:GetText())
		EnergyWatch.SetConfigValue(self.configKey, self:GetText())
		EnergyWatch.UpdateBar(self.bar)
	end
end

function EnergyWatchUI.BooleanCheckButtonClicked(self)
	if self:GetChecked() then
		EnergyWatch.SetConfigValue(self.configKey, true)
	else 
		EnergyWatch.SetConfigValue(self.configKey, false)
	end
	if ( self.dependentControls ) then
		if ( self:GetChecked() ) then
			for i, control in pairs(self.dependentControls) do
				control:Enable()
			end
		else
			for i, control in pairs(self.dependentControls) do
				control:Disable()
			end
		end
	end
	if ( self.inverseDependentControls ) then
		if ( self:GetChecked() ) then
			for i, control in pairs(self.inverseDependentControls) do
				control:Disable()
			end
		else
			for i, control in pairs(self.inverseDependentControls) do
				control:Enable()
			end
		end
	end
	EnergyWatch.ShowOrHideBar()
end

function EnergyWatchUI.LockBarButtonClicked(self)
	EnergyWatch.SetLock(self:GetChecked())
end

function EnergyWatchUI.BarAlphaSliderChanged(self, value)
	EnergyWatchUI.SliderChanged(self, value)

	EnergyWatchUI.UpdateAlpha(value)
end

function EnergyWatchUI.BarAlphaSliderEditBoxChanged(self, isUserInput)
    if isUserInput then
        local value = self:GetNumber()
        EnergyWatchUI.SliderEditBoxChanged(self, value)

		EnergyWatchUI.UpdateAlpha(value)
    end
end

function EnergyWatchUI.UpdateAlpha(value)
    EnergyWatchBar:SetAlpha(value)
	--EnergyWatchHealthBar:SetAlpha(value)
end

function EnergyWatchUI.BarScaleSliderChanged(self, value)
	EnergyWatchUI.SliderChanged(self, value)

	EnergyWatchUI.UpdateScale(value)
end

function EnergyWatchUI.BarScaleSliderEditBoxChanged(self, isUserInput)
    if isUserInput then
        local value = self:GetNumber()
        EnergyWatchUI.SliderEditBoxChanged(self, value)

        EnergyWatchUI.UpdateScale(value)
    end
end

function EnergyWatchUI.UpdateScale(value)
    EnergyWatchBar:SetScale(value)
	EnergyWatchHealthBar:SetScale(value)
end

function EnergyWatchUI.BarWidthSliderChanged(self, value)
	EnergyWatchUI.SliderChanged(self, value)

	EnergyWatchUI.UpdateWidth(value)
end

function EnergyWatchUI.BarWidthSliderEditBoxChanged(self, isUserInput)
    if isUserInput then
        local value = self:GetNumber()
        EnergyWatchUI.SliderEditBoxChanged(self, value)

        EnergyWatchUI.UpdateWidth(value)
    end
end

function EnergyWatchUI.UpdateWidth(value)
	EnergyWatchBar:SetWidth(value)
	EnergyWatchBarBackground:SetWidth(value + EnergyWatchUI.SizeOffsets.barBgWidth)
	EnergyWatchBarBorder:SetWidth(EnergyWatchBarBackground:GetWidth() * EnergyWatchUI.ScaleRatios.barBorderWidth)
	EnergyWatchText:SetWidth(value + EnergyWatchUI.SizeOffsets.barTextWidth)
	EnergyWatchStatusBar:SetWidth(value + EnergyWatchUI.SizeOffsets.barStatusWidth)
	
	EnergyWatchHealthBar:SetWidth(value)
	EnergyWatchHealthBarBackground:SetWidth(value + EnergyWatchUI.SizeOffsets.barBgWidth)
	EnergyWatchHealthBarBorder:SetWidth(EnergyWatchHealthBarBackground:GetWidth() * EnergyWatchUI.ScaleRatios.barBorderWidth)
	EnergyWatchHealthText:SetWidth(value + EnergyWatchUI.SizeOffsets.barTextWidth)
	EnergyWatchHealthStatusBar:SetWidth(value + EnergyWatchUI.SizeOffsets.barStatusWidth)
end

function EnergyWatchUI.BarHeightSliderChanged(self, value)
	EnergyWatchUI.SliderChanged(self, value)

	EnergyWatchUI.UpdateHeight(value)
end

function EnergyWatchUI.BarHeightSliderEditBoxChanged(self, isUserInput)
    if isUserInput then
        local value = self:GetNumber()
        EnergyWatchUI.SliderEditBoxChanged(self, value)

        EnergyWatchUI.UpdateHeight(value)
    end
end

function EnergyWatchUI.UpdateHeight(value)
	EnergyWatchBar:SetHeight(value)
	EnergyWatchBarBackground:SetHeight(value + EnergyWatchUI.SizeOffsets.barBgHeight)
	EnergyWatchBarBorder:SetHeight(EnergyWatchBarBackground:GetHeight() * EnergyWatchUI.ScaleRatios.barBorderHeight)
	EnergyWatchText:SetHeight(value + EnergyWatchUI.SizeOffsets.barTextHeight)
	EnergyWatchStatusBar:SetHeight(value + EnergyWatchUI.SizeOffsets.barStatusHeight)
	
	EnergyWatchHealthBar:SetHeight(value)
	EnergyWatchHealthBarBackground:SetHeight(value + EnergyWatchUI.SizeOffsets.barBgHeight)
	EnergyWatchHealthBarBorder:SetHeight(EnergyWatchHealthBarBackground:GetHeight() * EnergyWatchUI.ScaleRatios.barBorderHeight)
	EnergyWatchHealthText:SetHeight(value + EnergyWatchUI.SizeOffsets.barTextHeight)
	EnergyWatchHealthStatusBar:SetHeight(value + EnergyWatchUI.SizeOffsets.barStatusHeight)
end

function EnergyWatchUI.BarFontSizeSliderChanged(self, value)
	EnergyWatchUI.SliderChanged(self, value)

	EnergyWatchUI:UpdateBarFont()
end

function EnergyWatchUI.BarFontSizeSliderEditBoxChanged(self, isUserInput)
    if isUserInput then
        local value = self:GetNumber()
        EnergyWatchUI.SliderEditBoxChanged(self, value)

        EnergyWatchUI:UpdateBarFont()
    end
end

function EnergyWatchUI.BarFontDropDownChanged(self, arg1, arg2, checked)
	EnergyWatch.SetConfigValue(arg1.configKey, arg2)
	_G[arg1:GetName() .. 'Text']:SetText(EnergyWatch.GetConfigValue(arg1.configKey))
	_G[arg1:GetName() .. 'Text']:SetFontObject(EnergyWatchUI.Fonts[EnergyWatch.GetConfigValue(arg1.configKey)].object)

	EnergyWatchUI.UpdateBarFont()
end

function EnergyWatchUI.UpdateBarFont(self)
	EnergyWatchText:SetFont(EnergyWatchUI.Fonts[EnergyWatch.GetConfigValue("barFont")].filename, EnergyWatch.GetConfigValue("barFontSize"),"OUTLINE")
	EnergyWatchHealthText:SetFont(EnergyWatchUI.Fonts[EnergyWatch.GetConfigValue("barFont")].filename, EnergyWatch.GetConfigValue("barFontSize"),"OUTLINE")
end

function EnergyWatchUI.BarTextureDropDownChanged(self, arg1, arg2, checked)
	EnergyWatch.SetConfigValue(arg1.configKey, arg2)
	_G[arg1:GetName() .. 'Text']:SetText(EnergyWatch.GetConfigValue(arg1.configKey))

	EnergyWatchUI.UpdateBarTexture()
end

function EnergyWatchUI.UpdateBarTexture()
	EnergyWatchStatusBarTexture:SetTexture(EnergyWatchUI.Textures[EnergyWatch.GetConfigValue("barTexture")].filename)
	EnergyWatchHealthStatusBarTexture:SetTexture(EnergyWatchUI.Textures[EnergyWatch.GetConfigValue("barTexture")].filename)
end

function EnergyWatchUI.SliderChanged(self, value)
    --print("Caught change, changing " .. self.configKey .. " to " .. value)
    if self:IsEnabled() then  --dirty hack to avoid updating the config values when moving slider due to edit box change
        EnergyWatch.SetConfigValue(self.configKey, value)
        self.editBox:SetNumber(value)

        --GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        --GameTooltip:SetText(string.format("%.2f", value), nil, nil, nil, 1, 1)
        --GameTooltip:Show()
    end
end

function EnergyWatchUI.SliderEditBoxChanged(self, value)
    --print("Caught change, changing " .. self.configKey .. " to " .. value)
	EnergyWatch.SetConfigValue(self.configKey, value)
    self.slider:Disable()
    self.slider:SetValue(value)
    self.slider:Enable()

	--GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	--GameTooltip:SetText(string.format("%.2f", value), nil, nil, nil, 1, 1)
	--GameTooltip:Show()
end

--UI Element Factory Functions--

function EnergyWatchUI.CreateCheckButton(name, parent, tooltipText, configKey, onClickFunc, template)
	local button = CreateFrame('CheckButton', parent:GetName() .. name, parent, template)
	button.configKey = configKey
	_G[button:GetName() .. 'Text']:SetText(name)
	button:SetChecked(EnergyWatch.GetConfigValue(configKey))
	button:SetScript('OnClick', onClickFunc)

	button:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltipText, nil, nil, nil, 1, 1)
		GameTooltip:Show() end)
	button:SetScript('OnLeave', function(self) GameTooltip:Hide() end)

	return button
end

function EnergyWatchUI.CreateEditBox(name, parent, text, tooltipText, configKey, onTextChangeFunc, bar, template)
	local editBox = CreateFrame("EditBox",  parent:GetName() .. name, parent, template)
	editBox.configKey = configKey
	editBox.bar = bar
	editBox:SetAutoFocus(false)
	editBox:SetSize(200, 32)
	editBox:SetMaxLetters(128)
	editBox:SetText(EnergyWatch.GetConfigValue(configKey))
	editBox:SetCursorPosition(0)
	editBox:SetScript("OnTextChanged", onTextChangeFunc)

	local editBoxLabel = editBox:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	editBoxLabel:SetText(text .. ":")
	editBoxLabel:SetPoint('RIGHT', editBox, 'LEFT', -5, 0)

	editBox:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(tooltipText, nil, nil, nil, 1, 1)
		GameTooltip:Show() end)
	editBox:SetScript('OnLeave', function(self) GameTooltip:Hide() end)

	return editBox
end

function EnergyWatchUI.CreateSlider(name, parent, configKey, onSliderChangedFunc, onEditBoxChangedFunc, minVal, maxVal, lowText, highText, valStep, template)
	local slider = CreateFrame("Slider", parent:GetName() .. name, parent, template)
	slider.configKey = configKey
	slider:SetMinMaxValues(minVal, maxVal)
	slider:SetValueStep(valStep)
	slider:SetValue(EnergyWatch.GetConfigValue(configKey))
	_G[slider:GetName() .. "Low"]:SetText(lowText)
	_G[slider:GetName() .. "High"]:SetText(highText)
	slider:SetScript("OnValueChanged", onSliderChangedFunc)

    local editBox = CreateFrame("EditBox",  slider:GetName() .. name, slider, "InputBoxTemplate")
	editBox.configKey = configKey
	editBox:SetAutoFocus(false)
	editBox:SetSize(40, 32)
	editBox:SetMaxLetters(4)
	editBox:SetNumber(EnergyWatch.GetConfigValue(configKey))
	editBox:SetCursorPosition(0)
	editBox:SetScript("OnTextChanged", onEditBoxChangedFunc)
    editBox:SetPoint('LEFT', slider, 'RIGHT', 10, 0)

    editBox.slider = slider
    slider.editBox = editBox
    
	--slider:SetScript('OnEnter', function(self)
	--	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	--	GameTooltip:SetText(string.format("%.2f", slider:GetValue()), nil, nil, nil, 1, 1)
	--	GameTooltip:Show() end)
	--slider:SetScript('OnLeave', function(self) GameTooltip:Hide() end)
    
    return slider
end

function EnergyWatchUI.CreateDropDown(name, parent, configKey, dropDownWidth, menuTable, onSelectFunc, template)
	local dropDown = CreateFrame('Button', parent:GetName() .. name, parent, template)
	--dropDown:SetWidth(dropDownWidth)
	dropDown.configKey = configKey
	_G[dropDown:GetName() .. 'Text']:SetText(EnergyWatch.GetConfigValue(configKey))
	_G[dropDown:GetName() .. 'Text']:SetFontObject(EnergyWatchUI.Fonts[EnergyWatch.GetConfigValue("barFont")].object)

	local initializeDropDown = function(self, level)
		if not level then return end
		if level == 1 then
			for k,v in EnergyWatch.pairsSortedByKeys(menuTable) do
				local info = {}
				info.text = k
				info.arg1 = dropDown
				info.arg2 = k
				info.func = onSelectFunc
				info.fontObject = v.object
				info.notCheckable = true
				info.checked = function() return EnergyWatch.GetConfigValue(configKey) == k end
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end

	UIDropDownMenu_Initialize(dropDown, initializeDropDown)
	UIDropDownMenu_SetWidth(dropDown, dropDownWidth)

	return dropDown
end

function EnergyWatchUI.SetupDependentControl (dependency, control)
	if ( not dependency ) then
		return
	end
	
	assert(control)
	
	dependency.dependentControls = dependency.dependentControls or {}
	tinsert(dependency.dependentControls, control)

	if ( control.type ~= CONTROLTYPE_DROPDOWN ) then
		control.Disable = function (self) getmetatable(self).__index.Disable(self) _G[self:GetName().."Text"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end
		control.Enable = function (self) getmetatable(self).__index.Enable(self) _G[self:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end
		if dependency:GetChecked() then
			control:Enable()
		else
			control:Disable()
		end
	else
		control.Disable = function (self) UIDropDownMenu_DisableDropDown(self) end
		control.Enable = function (self) UIDropDownMenu_EnableDropDown(self) end
	end

end

function EnergyWatchUI.SetupInverseDependentControl (dependency, control)
	if ( not dependency ) then
		return
	end
	
	assert(control)
	
	dependency.inverseDependentControls = dependency.inverseDependentControls or {}
	tinsert(dependency.inverseDependentControls, control)

	if ( control.type ~= CONTROLTYPE_DROPDOWN ) then
		control.Disable = function (self) getmetatable(self).__index.Disable(self) _G[self:GetName().."Text"]:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end
		control.Enable = function (self) getmetatable(self).__index.Enable(self) _G[self:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end
		if dependency:GetChecked() then
			control:Disable()
		else
			control:Enable()
		end
	else
		control.Disable = function (self) UIDropDownMenu_DisableDropDown(self) end
		control.Enable = function (self) UIDropDownMenu_EnableDropDown(self) end
	end

end