--------------------------------------------------------
-- CopyRight (C) 2025, tidusmd. All rights reserved.
-- This mod is under the MIT License.
-- https://opensource.org/licenses/mit-license.php
--------------------------------------------------------
Log = require("log.lua")
Cron = require("External/Cron.lua")

local Debug = require('debug.lua')

ATS = {
    description = "Aerial Traffic Surge",
    version = "1.0.0",
    is_ready = false,
    is_debug_mode = true,
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

return ATS