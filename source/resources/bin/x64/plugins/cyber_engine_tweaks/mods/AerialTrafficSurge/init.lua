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
    version = "1.2.0",
    is_ready = false,
    is_debug_mode = false,
    is_update_version = false,
    native_settings_required_version = 1.96,
    delay_updating_native_settings = 0.1,
    max_number_of_av = 50,
    default_setting_table = {
        version = "",
        game_version = "",
        number_of_av = 50,
    },
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

    -- Settings live in the per-save fact DB; this table is just the in-memory UI mirror.
    ATS.setting_table = { version = ATS.version, game_version = "", number_of_av = ATS.default_setting_table.number_of_av }

    CheckNativeSettings()

    GameUI.Observe("SessionStart", function()
        if ATS.is_debug_mode then
            Game.GetQuestsSystem():SetFactStr("ats_av_traffic_debug", 1)
        elseif Game.GetQuestsSystem():GetFactStr("ats_av_traffic_debug") == 1 then
            Game.GetQuestsSystem():SetFactStr("ats_av_traffic_debug", 0)
        end

        local saved_version = Game.GetQuestsSystem():GetFactStr("ats_av_traffic_version")
        local current_version = VersionToInt(ATS.version)
        if saved_version ~= current_version then
            Game.GetQuestsSystem():SetFactStr("ats_av_traffic_version", current_version)
            ATS.is_update_version = true
        end

        local saved_number_of_av = Game.GetQuestsSystem():GetFactStr("ats_av_traffic_number_of_av")
        if ATS.is_update_version then
            -- New save or version change: seed the fact from the current setting.
            if saved_number_of_av ~= ATS.setting_table.number_of_av then
                Game.GetQuestsSystem():SetFactStr("ats_av_traffic_number_of_av", ATS.setting_table.number_of_av)
            end
        elseif saved_number_of_av ~= ATS.setting_table.number_of_av then
            -- Per-save fact is the source of truth: sync the UI to it.
            ATS.setting_table.number_of_av = saved_number_of_av
            if ATS.is_valid_native_settings then
                UpdateNativeSettingsPage()
            end
        end

        local game_version_str = Game.GetSystemRequestsHandler():GetGameVersion()
        ATS.setting_table.game_version = game_version_str
        local saved_game_version = Game.GetQuestsSystem():GetFactStr("ats_av_traffic_game_version")
        local current_game_version = VersionToInt(game_version_str)
        if saved_game_version ~= current_game_version then
            Game.GetQuestsSystem():SetFactStr("ats_av_traffic_game_version", current_game_version)
            ATS.is_update_version = true
        end

        if ATS.is_update_version or not IsTrafficLoop() then
            ATS.is_update_version = false
            StartLoop()
        end
    end)

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
    ManageNumberOfAV()
    Game.GetQuestsSystem():SetFactStr("ats_av_traffic_start", 1)
end

function StopLoop()
    Game.GetQuestsSystem():SetFactStr("ats_av_traffic_reset", 1)
end

function ManageNumberOfAV()
    local selected_numbers = {}
    local count = ATS.max_number_of_av - ATS.setting_table.number_of_av
    local range = ATS.max_number_of_av
    local total_lock_count = 0

    if count < range / 2 then
        for i = 1, range do
            selected_numbers[i] = false
        end
        while total_lock_count < count do
            local random_number = math.random(1, range)
            if not selected_numbers[random_number] then
                selected_numbers[random_number] = true
                total_lock_count = total_lock_count + 1
            end
        end
    else
        total_lock_count = range
        for i = 1, range do
            selected_numbers[i] = true
        end
        while total_lock_count > count do
            local random_number = math.random(1, range)
            if selected_numbers[random_number] then
                selected_numbers[random_number] = false
                total_lock_count = total_lock_count - 1
            end
        end
    end

    for i = 1, range do
        if not selected_numbers[i] then
            Game.GetQuestsSystem():SetFactStr("ats_av_traffic_lock_" .. i, 0)
        else
            Game.GetQuestsSystem():SetFactStr("ats_av_traffic_lock_" .. i, 1)
        end
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

function VersionToInt(version)
    local parts = {}
    for part in version:gmatch("%d+") do
        table.insert(parts, tonumber(part))
    end
    local result = 0
    for i, part in ipairs(parts) do
        result = result * 100 + part
    end
    return result
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
    option_table = ATS.native_settings_mod.addRangeInt("/ATS/general", GetLocalizedText(LocKeyToString("ats-general-number-of-av-item")), GetLocalizedText(LocKeyToString("ats-general-number-of-av-description")), 0, ATS.max_number_of_av, 1, ATS.setting_table.number_of_av, ATS.default_setting_table.number_of_av, function(value)
        ATS.setting_table.number_of_av = value
        Cron.After(ATS.delay_updating_native_settings, function()
			UpdateNativeSettingsPage()
		end)
	end)
	table.insert(ATS.option_table_list, option_table)

    option_table = ATS.native_settings_mod.addButton("/ATS/general", GetLocalizedText(LocKeyToString("ats-general-apply-settings")), GetLocalizedText(LocKeyToString("ats-general-apply-settings-description")), GetLocalizedText(LocKeyToString("ats-general-apply-settings-button-label")), 45, function()
        Game.GetQuestsSystem():SetFactStr("ats_av_traffic_number_of_av", ATS.setting_table.number_of_av)
        StartLoop()
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
    ATS.setting_table = ATS.default_setting_table
    ATS.setting_table.version = ATS.version
end

function ATS:GetVersion()
    return ATS.version
end

function ATS:ToggleDebugMode()
    ATS.is_debug_mode = not ATS.is_debug_mode
end

function ATS:SetNumberOfAV(number)
    if type(number) ~= "number" or number < 0 or number > ATS.max_number_of_av or math.floor(number) ~= number then
        print("SetNumberOfAV must be an integer from 0 to " .. ATS.max_number_of_av)
        return
    end
    ATS.setting_table.number_of_av = number
    Cron.After(ATS.delay_updating_native_settings, function()
        UpdateNativeSettingsPage()
    end)
end

function ATS:GetNumberOfAV()
    return Game.GetQuestsSystem():GetFactStr("ats_av_traffic_number_of_av")
end

return ATS