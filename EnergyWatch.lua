--[[

	EnergyWatch addon. 
	A mobile, configurable energy bar
	Author: OneWingedAngel

--]]


--[[ Globals --]]
EnergyWatchConfig = {}
--Namespace for addon functions
EnergyWatch = {}

--[[ Main addon frame creation and main local vars ]]--
local EnergyWatchAddon = CreateFrame("Frame", "EnergyWatchAddon", UIParent)

local DefaultConfig = {}
local RegisteredEvents = {}
EnergyWatchAddon:SetScript("OnEvent", function (self, event, ...) if (RegisteredEvents[event]) then return RegisteredEvents[event](self, event, ...) end end)

--[[ Event Handlers --]]

function RegisteredEvents:ADDON_LOADED(event, addon, ...)
	if (addon == "EnergyWatch") then
		SLASH_ENERGYWATCH1 = '/ew'
		SlashCmdList["ENERGYWATCH"] = function (msg, editbox)
			EnergyWatch.SlashCmdHandler(msg, editbox)	
		end

		--Use metatable to implement defaults, see http://www.lua.org/pil/13.4.1.html
		setmetatable(EnergyWatchConfig, {__index = DefaultConfig})

		EnergyWatchUI.CreateEnergyBar()
		EnergyWatchUI.CreateConfigMenu()
		--print("EnergyWatch " .. GetAddOnMetadata("EnergyWatch","Version") .. " Loaded. Type /ew for usage")
	end
end

--function RegisteredEvents:PLAYER_LOGIN(event)
--	--print("PLAYER_LOGIN fired")
--	EnergyWatch.InitializeBar()
--end

function RegisteredEvents:PLAYER_ENTERING_WORLD(event)
	--print("PLAYER_ENTERING_WORLD fired")
	EnergyWatch.InitializeBar()
end

function RegisteredEvents:ACTIVE_TALENT_GROUP_CHANGED(event)
	--print("ACTIVE_TALENT_GROUP_CHANGED fired")
	EnergyWatch.InitializeBar()
end

function RegisteredEvents:PLAYER_SPECIALIZATION_CHANGED(event)
	--print("PLAYER_SPECIALIZATION_CHANGED fired")
	EnergyWatch.InitializeBar()
end

function RegisteredEvents:UNIT_COMBO_POINTS(event, unit)
	if unit == "player" then
		EnergyWatch.UpdateSpecPoints()
		EnergyWatch.UpdateBar()
	end
end

function RegisteredEvents:UNIT_POWER(event, unit, power)
	--print("Added power " .. power .. " to " .. unit)
    if unit == "player" then
		if power == "SOUL_SHARDS" or 
		   power == "HOLY_POWER" or
		   power == "CHI" or
		   power == "DEMONIC_FURY" or
		   power == "BURNING_EMBERS" or
		   power == "ECLIPSE" or
		   power == "SHADOW_ORBS" then
			EnergyWatch.UpdateSpecPoints()
			EnergyWatch.UpdateBar()
		end
	end
end

function RegisteredEvents:UNIT_MAXPOWER(event, unit, power)
	--print("UNIT_MAXPOWER fired")
	if unit == "player" then
		EnergyWatch.UpdateMaxEnergy()
		EnergyWatch.UpdateBar()
	end
end

function RegisteredEvents:UPDATE_STEALTH(event)
	--print("caught stealth event")
	EnergyWatch.ShowOrHideBar()
end

function RegisteredEvents:PLAYER_REGEN_ENABLED(event)
	--print("regen enabled")
	EnergyWatch.ShowOrHideBar()
end

function RegisteredEvents:PLAYER_REGEN_DISABLED(event)
	--print("regen disabled")
	EnergyWatch.ShowOrHideBar()
end

function RegisteredEvents:UNIT_DISPLAYPOWER(event, unit)
	--print("Displaypower changed for " .. unit)
	--local powerType, powerTypeString = UnitPowerType("player")
	--print("Unit currently has " .. powerType .. " " .. powerTypeString)
	EnergyWatch.UpdatePowerType()
	EnergyWatch.UpdateSpecPoints()
	EnergyWatch.UpdateMaxEnergy()
	EnergyWatch.ShowOrHideBar()
end

for k, v in pairs(RegisteredEvents) do
	EnergyWatchAddon:RegisterEvent(k)
end

--[[ Addon functions --]]
function EnergyWatch.InitializeBar()
	--Get starting display values for energy bar
	local localizedClass, englishClass = UnitClass("player");

	EnergyWatchBar:SetAlpha(EnergyWatch.GetConfigValue("barAlpha"))
	--EnergyWatchBar:SetScale(EnergyWatch.GetConfigValue("barScale"))
	EnergyWatch.UpdatePowerType()
	EnergyWatch.UpdateMaxEnergy()
	EnergyWatch.UpdateEnergy()
	EnergyWatch.UpdateSpecPoints()
	EnergyWatch.ShowOrHideBar()
	
	--Consider these globals inside the addon, used to rate-limit OnUpdate script
	EnergyWatch.UPDATE_INTERVAL = 0.09
	EnergyWatch.TIME_SINCE_LAST_UPDATE = 0
	EnergyWatchAddon:SetScript("OnUpdate", EnergyWatch.OnUpdate)
end

function EnergyWatch.OnUpdate(self, elapsed)
	EnergyWatch.TIME_SINCE_LAST_UPDATE = EnergyWatch.TIME_SINCE_LAST_UPDATE + elapsed
	--print("time = " .. EnergyWatch.TIME_SINCE_LAST_UPDATE)
	while (EnergyWatch.TIME_SINCE_LAST_UPDATE > EnergyWatch.UPDATE_INTERVAL) do
		--print(EnergyWatch.TIME_SINCE_LAST_UPDATE)
		EnergyWatch.UpdateEnergy()
		EnergyWatch.UpdateBar()
		EnergyWatch.ShowOrHideBar()
		EnergyWatch.TIME_SINCE_LAST_UPDATE = EnergyWatch.TIME_SINCE_LAST_UPDATE - EnergyWatch.UPDATE_INTERVAL
	end

end

function EnergyWatch.UpdateEnergy()
	EnergyWatch.curEnergy = UnitPower("player", EnergyWatch.powerType)
	--print("Cur energy is " .. EnergyWatch.curEnergy)
end

function EnergyWatch.UpdateMaxEnergy()
	--print("Updating max energy")
	EnergyWatch.maxEnergy = UnitPowerMax("player", EnergyWatch.powerType)
	--print("maxEnergy is " ..EnergyWatch.maxEnergy)
	--print("powerType is " ..EnergyWatch.powerType)
	EnergyWatchStatusBar:SetMinMaxValues(0, EnergyWatch.maxEnergy)
end

function EnergyWatch.UpdateSpecPoints()
	local localizedClass, englishClass = UnitClass("player")
	local currentSpec = GetSpecialization()

	if englishClass == "DRUID" then
		if EnergyWatch.powerType == 3 then
			EnergyWatch.specPoints = GetComboPoints("player")
		elseif currentSpec == 1 then
			EnergyWatch.specPoints = UnitPower("player", SPELL_POWER_ECLIPSE)
		else
			EnergyWatch.specPoints = nil
		end
	elseif englishClass == "MONK" then
		EnergyWatch.specPoints = UnitPower("player", SPELL_POWER_CHI)
	elseif englishClass == "PALADIN" then
		EnergyWatch.specPoints = UnitPower("player", SPELL_POWER_HOLY_POWER)
	elseif englishClass == "PRIEST" then
		if currentSpec == 3 then --Shadow
			EnergyWatch.specPoints = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
		else
			EnergyWatch.specPoints = nil
		end
	elseif englishClass == "ROGUE" then
		EnergyWatch.specPoints = GetComboPoints("player")
	elseif englishClass == "WARLOCK" then
		if currentSpec == 1 then --Affliction
			EnergyWatch.specPoints = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
		elseif currentSpec == 2 then --Demonology
			EnergyWatch.specPoints = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
		elseif currentSpec == 3 then --Destruction
			EnergyWatch.specPoints = UnitPower("player", SPELL_POWER_BURNING_EMBERS)
		else
			EnergyWatch.specPoints = nil
		end
	else
		EnergyWatch.specPoints = nil
	end
end

function EnergyWatch.UpdatePowerType()
	EnergyWatch.powerType = UnitPowerType("player")
	local barColor = PowerBarColor[EnergyWatch.powerType]

	EnergyWatchStatusBar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
end

function EnergyWatch.UpdateBar()
	local text = ""
	local energyPercentage = floor((EnergyWatch.curEnergy / EnergyWatch.maxEnergy) * 100)

	if EnergyWatch.specPoints == nil then
		text = EnergyWatch.GetConfigValue("barText")
		text,_ = string.gsub(text,"&ep", energyPercentage)
		text,_ = string.gsub(text,"&em", EnergyWatch.CapDisplayOfNumericValue(EnergyWatch.maxEnergy))
		text,_ = string.gsub(text,"&e", EnergyWatch.CapDisplayOfNumericValue(EnergyWatch.curEnergy))
	else 
		text = EnergyWatch.GetConfigValue("barPointsText")
		text,_ = string.gsub(text,"&ep", energyPercentage)
		text,_ = string.gsub(text,"&em", EnergyWatch.CapDisplayOfNumericValue(EnergyWatch.maxEnergy))
		text,_ = string.gsub(text,"&e", EnergyWatch.CapDisplayOfNumericValue(EnergyWatch.curEnergy))
		text,_ = string.gsub(text,"&c", EnergyWatch.specPoints)
	end

	EnergyWatchStatusBar:SetValue(EnergyWatch.curEnergy)
	EnergyWatchText:SetText(text);
end

function EnergyWatch.ShowOrHideBar()
	if not EnergyWatch.PlayerHasAppropriatePowerType() then
		EnergyWatchBar:Hide()
		return
	end

	if EnergyWatch.GetConfigValue("showAlways") then
		--print("Set to always on")
		EnergyWatchBar:Show()
		return
	end
	
	if EnergyWatch.GetConfigValue("showNonDefault") then
		if not EnergyWatch.PowerTypeAtDefaultValue() then
			EnergyWatchBar:Show()
			return
		end
	end

	if EnergyWatch.GetConfigValue("showStealth") then
		--if EnergyWatch.IsStealthed() then
		if IsStealthed() then
			--print("I am stealthed")
			EnergyWatchBar:Show()
			return
		else
			--print("I am not stealthed")
			--EnergyWatchBar:Hide()
		end
	end
	
	if EnergyWatch.GetConfigValue("showCombat") then
		if UnitAffectingCombat("player") then
			--print("I am in combat")
			EnergyWatchBar:Show()
			return
		else
			--print("I am not in combat")
			--EnergyWatchBar:Hide()
		end
	end
	EnergyWatchBar:Hide()
end

function EnergyWatch.SetLock(newValue)
	EnergyWatch.SetConfigValue("locked", newValue)
	if newValue then
		print("Energy Watch bar position locked")
		EnergyWatchBar:EnableMouse(false)
	else
		print("Energy Watch bar position unlocked")
		EnergyWatchBar:EnableMouse(true)
	end
end

function EnergyWatch.PlayerHasAppropriatePowerType()
	if EnergyWatch.powerType == 0 and EnergyWatch.GetConfigValue("powerTypeMana") then
		return true
	elseif EnergyWatch.powerType == 1 and EnergyWatch.GetConfigValue("powerTypeRage") then
		return true
	elseif EnergyWatch.powerType == 2 and EnergyWatch.GetConfigValue("powerTypeFocus") then
		return true
	elseif EnergyWatch.powerType == 3 and EnergyWatch.GetConfigValue("powerTypeEnergy") then
		return true
	elseif EnergyWatch.powerType == 6 and EnergyWatch.GetConfigValue("powerTypeRunicPower") then
		return true
	else
		return false
	end
end

function EnergyWatch.PowerTypeAtDefaultValue()
	if EnergyWatch.powerType == 1 or	--Rage
	   EnergyWatch.powerType == 6 then	--Runic Power
		if EnergyWatch.curEnergy == 0 then
			return true
		end
	elseif EnergyWatch.curEnergy == EnergyWatch.maxEnergy then
		return true
	end

	return false
end

function EnergyWatch.IsStealthed()
	for i = 1, 40 do
		local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura("player", i)
		if (not icon) then
		--print("Found no icon for buffid "..i)
			return false
		end
		print(name.." "..rank.." "..icon)
		if icon == "Interface\\Icons\\Ability_Stealth" or 
		   icon == "Interface\\Icons\\Ability_Ambush" then
	   		--print("Unit is stealthed")
			return true
		end
	end
	--print("Unit is not stealthed")
	return false
end

function EnergyWatch.CapDisplayOfNumericValue(value)
	local strLen = strlen(value);
	local retString = value;
	if (EnergyWatch.GetConfigValue("capLargeNumbers")) then
		if ( strLen > 7 ) then
			retString = string.sub(value, 1, -7)..SECOND_NUMBER_CAP;
		elseif ( strLen > 4 ) then
			retString = string.sub(value, 1, -4)..'.'..string.sub(value, -3, -3)..FIRST_NUMBER_CAP;
		end
	end
	return retString;
end

function EnergyWatch.pairsSortedByKeys (t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end

function EnergyWatch.SlashCmdHandler(msg, editbox)
	--print("command is " .. msg .. "\n")
	if (string.lower(msg) == "config") then
		InterfaceOptionsFrame_OpenToCategory("EnergyWatch")
	elseif (string.lower(msg) == "dumpconfig") then
		print("With defaults")
		for k,v in pairs(DefaultConfig) do
			print("  " .. k,EnergyWatch.GetConfigValue(k))
		end
		print("Direct table")
		for k,v in pairs(EnergyWatchConfig) do
			print("  " .. k,v)
		end
	elseif (string.lower(msg) == "lock") then
		EnergyWatch.SetLock(true)
	elseif (string.lower(msg) == "unlock") then
		EnergyWatch.SetLock(false)
	elseif (string.lower(msg) == "reset") then
		EnergyWatch.SetConfigToDefaults()
	elseif (string.lower(msg) == "perf") then
		EnergyWatch.PrintPerformanceData()
	elseif (string.lower(msg) == "foo") then
		print(EnergyWatchText:GetStringHeight())
		print(EnergyWatchText:GetFont())
	else
		EnergyWatch.ShowHelp()
	end
end

function EnergyWatch.ShowHelp()
	print("Slash commands (/ew):")
	print(" /ew lock: Locks Energy Watch bar's position")
	print(" /ew unlock: Locks Energy Watch bar's position")
	print(" /ew config: Open addon config menu (also found in Addon tab in Blizzard's Interface menu)")
	print(" /ew reset:  Resets your config to defaults")
end

function EnergyWatch.PrintPerformanceData()
	UpdateAddOnMemoryUsage()
	local mem = GetAddOnMemoryUsage("EnergyWatch")
	print("EnergyWatch is currently using " .. mem .. " kbytes of memory")
	collectgarbage(collect)
	UpdateAddOnMemoryUsage()
	mem = GetAddOnMemoryUsage("EnergyWatch")
	print("EnergyWatch is currently using " .. mem .. " kbytes of memory after garbage collection")

end

--[[ Configuration methods --]]
function EnergyWatch.GetConfigValue(key)
	return EnergyWatchConfig[key]
end

function EnergyWatch.SetConfigValue(key, value)
	if (DefaultConfig[key] == value) then
		EnergyWatchConfig[key] = nil
	else 
		EnergyWatchConfig[key] = value
	end
end

function EnergyWatch.SetConfigToDefaults()
	print("Resetting config to defaults")
	EnergyWatchConfig = {}
	setmetatable(EnergyWatchConfig, {__index = DefaultConfig})

	EnergyWatchBar:ClearAllPoints()
	EnergyWatchBar:SetPoint(EnergyWatch.GetConfigValue("barPosPoint"), EnergyWatch.GetConfigValue("barPosX"), EnergyWatch.GetConfigValue("barPosY"))
	EnergyWatchBar:SetAlpha(EnergyWatch.GetConfigValue("barAlpha"))
	--EnergyWatchBar:SetScale(EnergyWatch.GetConfigValue("barScale"))
	EnergyWatchBar:EnableMouse(true)
	EnergyWatch.ShowOrHideBar()
end

--[[ "Global" Vars --]]

DefaultConfig = {
	showAlways = true,
	showStealth = true,
	showCombat = true,
	showNonDefault = true,
	powerTypeMana = true,
	powerTypeRage = true,
	powerTypeFocus = true,
	powerTypeEnergy = true,
	powerTypeRunicPower = true,
	barText = "&e/&em",
	barPointsText = "&e/&em (&c)",
	barFontSize = 12,
	barFont = "Friz Quadrata TT",
	barTexture = "Default",
	barAlpha = 1.0,
	barScale = 1.0,
	barWidth = 116,
	barHeight = 26,
	barPosX = 0,
	barPosY = 80,
	barPosPoint = "CENTER",
	locked = false,
	capLargeNumbers = true
}
