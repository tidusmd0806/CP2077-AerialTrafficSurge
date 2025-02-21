--------------------------------------------------------
-- CopyRight (C) 2025, tidusmd. All rights reserved.
-- This mod is under the MIT License.
-- https://opensource.org/licenses/mit-license.php
--------------------------------------------------------
Cron = require("External/Cron.lua")
GameUI = require("External/GameUI.lua")

local Debug = require('Debug/debug.lua')

ATS = {
    -- static --
    description = "Aerial Traffic Surge",
    version = "1.0.0",
    is_ready = false,
    is_debug_mode = false,
    is_update_version = false,
    setting_path = "user_settings.json",
    native_settings_required_version = 1.96,
    delay_updating_native_settings = 0.1,
    default_number_of_av = 15,
    max_number_of_av = 15,
    -- dynamic --
    debug_obj = nil,
    setting_table = {},
    native_settings_mod = nil,
    is_valid_native_settings = false,
    option_table_list = {},
}

registerForEvent("onTweak",function ()
    if not TweakDB:GetRecord("Vehicle.av_rayfield_excalibur_traffic") then
        TweakDB:CloneRecord("Vehicle.av_rayfield_excalibur_traffic", "Vehicle.av_rayfield_excalibur")
    end
    TweakDB:SetFlat("Vehicle.av_rayfield_excalibur_traffic.entityTemplatePath", "ats\\ent_av\\av_rayfield_excalibur__basic_01_traffic.ent")

    if not TweakDB:GetRecord("Vehicle.av_militech_manticore_traffic") then
        TweakDB:CloneRecord("Vehicle.av_militech_manticore_traffic", "Vehicle.av_militech_manticore")
    end
    TweakDB:SetFlat("Vehicle.av_militech_manticore_traffic.entityTemplatePath", "ats\\ent_av\\av_militech_manticore_basic_01_traffic.ent")

    if not TweakDB:GetRecord("Vehicle.av_zetatech_atlus_traffic") then
        TweakDB:CloneRecord("Vehicle.av_zetatech_atlus_traffic", "Vehicle.av_zetatech_atlus")
    end
    TweakDB:SetFlat("Vehicle.av_zetatech_atlus_traffic.entityTemplatePath", "ats\\ent_av\\av_zetatech_atlus_basic_02_traffic.ent")

    if not TweakDB:GetRecord("Vehicle.Vehicle.av_zetatech_surveyor_traffic") then
        TweakDB:CloneRecord("Vehicle.av_zetatech_surveyor_traffic", "Vehicle.av_zetatech_surveyor")
    end
    TweakDB:SetFlat("Vehicle.av_zetatech_surveyor_traffic.entityTemplatePath", "ats\\ent_av\\av_zetatech_surveyor_basic_01_traffic.ent")
end)

registerForEvent('onInit', function()

    ATS.debug_obj = Debug:New()

    GameUI.Observe("SessionStart", function()
        if ATS.is_debug_mode then
            Game.GetQuestsSystem():SetFactStr("ats_av_traffic_debug", 1)
        elseif Game.GetQuestsSystem():GetFactStr("ats_av_traffic_debug") == 1 then
            Game.GetQuestsSystem():SetFactStr("ats_av_traffic_debug", 0)
        end

        -- Create setting file
        if io.open(ATS.setting_path, "a") then
            io.close()
        end

        LoadSettings()
        CompareVersion()
        SetParameter()

        if ATS.is_update_version or not IsTrafficLoop() then
            StartLoop()
        end

    end)

    CheckNativeSettings()

    if ATS.is_valid_native_settings then
		CreateNativeSettingsBasePage()
	end

    print('[ATS][Info] Finished initializing Aerial Traffic Surge Mod.')
end)

registerForEvent("onDraw", function()
    if ATS.is_debug_mode then
        ATS.debug_obj:ImGuiMain()
    end
end)

registerForEvent('onUpdate', function(delta)
    Cron.Update(delta)
end)

function IsTrafficLoop()
    return Game.GetQuestsSystem():GetFactStr("ats_av_traffic_loop") == 1
end

function StartLoop()
    Game.GetQuestsSystem():SetFactStr("ats_av_traffic_start", 1)
end

function StopLoop()
    Game.GetQuestsSystem():SetFactStr("ats_av_traffic_reset", 1)
end

function LoadSettings()
    ATS.setting_table = ReadJson(ATS.setting_path)
end

function CompareVersion()
    if ATS.setting_table == nil or ATS.setting_table.version ~= ATS.version then
        ATS.is_update_version = true
        if ATS.setting_table.version == nil then
            table.insert(ATS.setting_table, {version = ATS.version})
        else
            ATS.setting_table.version = ATS.version
        end
        WriteJson(ATS.setting_path, ATS.setting_table)
    end
end

function SetParameter()
    if ATS.setting_table.number_of_av == nil then
        table.insert(ATS.setting_table, {number_of_av = ATS.default_number_of_av})
    end
end

function CheckNativeSettings()
    ATS.native_settings_mod = GetMod("nativeSettings")
    if ATS.native_settings_mod == nil then
		ATS.is_valid_native_settings = false
        return
	end
    if ATS.native_settings_mod.version < ATS.native_settings_required_version then
        ATS.is_valid_native_settings = false
        print("[ATS][Error] requires Native Settings version " .. ATS.native_settings_required_version .. " or higher.")
        return
    end
    ATS.is_valid_native_settings = true
end

--- Create Native Settings Base Page.
function CreateNativeSettingsBasePage()
	if not ATS.is_valid_native_settings then
		return
	end
	ATS.native_settings_mod.addTab("/ATS", GetLocalizedText(LocKeyToString("ats-top-title")))
	ATS.native_settings_mod.registerRestoreDefaultsCallback("/ATS", true, function()
		print('[ATS][Info] Restore All Settings')
		ResetParameters()
		Cron.After(ATS.delay_updating_native_settings, function()
			UpdateNativeSettingsPage()
		end)
	end)
	CreateNativeSettingsSubCategory()
	CreateNativeSettingsPage()
end

--- Create Native Settings Sub Category
function CreateNativeSettingsSubCategory()
	if not ATS.is_valid_native_settings then
		return
	end
	ATS.native_settings_mod.addSubcategory("/ATS/general", GetLocalizedText(LocKeyToString("ats-general-subtitle")))
end

--- Clear Native Settings Sub Category
function ClearAllNativeSettingsSubCategory()
	if not ATS.is_valid_native_settings then
		return
	end
	ATS.native_settings_mod.removeSubcategory("/ATS/general")
end

--- Create Setting items.
function CreateNativeSettingsPage()
	if not ATS.is_valid_native_settings then
		return
	end
	ATS.option_table_list = {}
	local option_table

	-- general
    option_table = ATS.native_settings_mod.addRangeInt("/ATS/general", GetLocalizedText(LocKeyToString("ats-general-number-of-av-item")), GetLocalizedText(LocKeyToString("ats-general-number-of-av-description")), 0, ATS.max_number_of_av, 1, ATS.setting_table.number_of_av, ATS.default_number_of_av, function(value)
        ATS.setting_table.number_of_av = value
        WriteJson(ATS.setting_path, ATS.setting_table)
        Cron.After(ATS.delay_updating_native_settings, function()
			UpdateNativeSettingsPage()
		end)
	end)
	table.insert(ATS.option_table_list, option_table)
end

--- Clear setting items.
function ClearNativeSettingsPage()
	if not ATS.is_valid_native_settings then
		return
	end
	for _, option_table in ipairs(ATS.option_table_list) do
		ATS.native_settings_mod.removeOption(option_table)
	end
	ATS.option_table_list = {}

	ClearAllNativeSettingsSubCategory()
end

--- Update setting items.
function UpdateNativeSettingsPage()
	ClearNativeSettingsPage()
	CreateNativeSettingsSubCategory()
	CreateNativeSettingsPage()
end

--- Reset parameters.
function ResetParameters()
	if not ATS.is_valid_native_settings then
		return
	end
end

--- Read json file.
function ReadJson(fill_path)
    local success, result = pcall(function()
       local file = io.open(fill_path, "r")
       if file then
            local contents = file:read("*a")
            local data = json.decode(contents)
            file:close()
            return data
       else
            return {}
       end
    end)
    if not success then
        return {}
    end
    return result
end

--- Write json file.
function WriteJson(fill_path, write_data)
local success, result = pcall(function()
    local file = io.open(fill_path, "w")
    if file then
        local contents = json.encode(write_data)
        file:write(contents)
        file:close()
        return true
    else
        return false
    end
end)
if not success then
    return false
end
return result
end

function ATS:GetVersion()
    return ATS.version
end

function ATS:ToggleDebugMode()
    ATS.is_debug_mode = not ATS.is_debug_mode
end

return ATS