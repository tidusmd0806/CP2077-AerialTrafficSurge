local Debug = {}
Debug.__index = Debug

function Debug:New()
    local obj = {}

    -- set parameters
    obj.is_set_observer = false

    return setmetatable(obj, self)
end

function Debug:ImGuiMain()

    ImGui.Begin("ATS DEBUG WINDOW")
    ImGui.Text("Version : " .. ATS.version)

    self:SetObserver()
    self:SetLogLevel()
    self:SelectPrintDebug()
    self:ImGuiRelativePosition(-1457.9430, -439.4917, 32.0327)
    self:ImGuiPlayerPosition()
    self:ImGuiFactValue()
    self:ImGuiExcuteFunction()

    ImGui.End()

end

function Debug:SetObserver()

    if not self.is_set_observer then
        -- reserved
    end
    self.is_set_observer = true

    if self.is_set_observer then
        ImGui.Text("Observer : On")
    end

end

function Debug:SetLogLevel()
    function GetKeyFromValue(table_, target_value)
        for key, value in pairs(table_) do
            if value == target_value then
                return key
            end
        end
        return nil
    end
    function GetKeys(table_)
        local keys = {}
        for key, _ in pairs(table_) do
            table.insert(keys, key)
        end
        return keys
     end
    local selected = false
    if ImGui.BeginCombo("LogLevel", GetKeyFromValue(LogLevel, MasterLogLevel)) then
		for _, key in ipairs(GetKeys(LogLevel)) do
			if GetKeyFromValue(LogLevel, MasterLogLevel) == key then
				selected = true
			else
				selected = false
			end
			if(ImGui.Selectable(key, selected)) then
				MasterLogLevel = LogLevel[key]
			end
		end
		ImGui.EndCombo()
	end
end

function Debug:SelectPrintDebug()
    PrintDebugMode = ImGui.Checkbox("Print Debug Mode", PrintDebugMode)
end

function Debug:ImGuiRelativePosition(x, y, z)
    local player = Game.GetPlayer()
    if player == nil then
        return
    end
    local player_pos = player:GetWorldPosition()
    if player_pos == nil then
        return
    end
    ImGui.Text("relative position : " .. player_pos.x - x .. " ," .. player_pos.y - y .. ", " .. player_pos.z - z)
end

function Debug:ImGuiFactValue()
    local fact_db = Game.GetQuestsSystem()
    if fact_db == nil then
        return
    end
    local ats_av_traffic_start = fact_db:GetFactStr("ats_av_traffic_start")
    local ats_av_traffic_loop = fact_db:GetFactStr("ats_av_traffic_loop")
    local ats_av_traffic_reset = fact_db:GetFactStr("ats_av_traffic_reset")
    ImGui.Text("ats_av_traffic_start : " .. ats_av_traffic_start)
    ImGui.Text("ats_av_traffic_loop : " .. ats_av_traffic_loop)
    ImGui.Text("ats_av_traffic_reset : " .. ats_av_traffic_reset)

end

function Debug:ImGuiPlayerPosition()
    local player = Game.GetPlayer()
    if player == nil then
        return
    end
    local player_pos = player:GetWorldPosition()
    local player_angle = player:GetWorldOrientation():ToEulerAngles()
    if player_pos == nil or player_angle == nil then
        return
    end
    ImGui.Text("player position : " .. player_pos.x .. " ," .. player_pos.y .. ", " .. player_pos.z)
    ImGui.Text("player angle : " .. player_angle.roll .. " ," .. player_angle.pitch .. ", " .. player_angle.yaw)
end

function Debug:ImGuiExcuteFunction()
    if ImGui.Button("TF1") then
        -- local player_pos = Game.GetPlayer():GetWorldPosition()
        -- local player_angle = Game.GetPlayer():GetWorldOrientation():ToEulerAngles()
        -- local loc_pos = Vector4.new(player_pos.x, player_pos.y, player_pos.z, 1)
        -- local loc_angle = EulerAngles.new(player_angle.roll, player_angle.pitch, player_angle.yaw)
        -- Game.GetTeleportationFacility():Teleport(Game.GetPlayer(), Vector4.new(-1381.9889, 1271.9109, 123.064896, 1), EulerAngles.new(0, 0, 0))
        -- Cron.After(6, function()
        --     print("Teleport")
        --     Game.GetTeleportationFacility():Teleport(Game.GetPlayer(), loc_pos, loc_angle)
        -- end)
        print("Excute Test Function 1")
    end
    ImGui.SameLine()
    if ImGui.Button("TF2") then
        print("Excute Test Function 2")
    end

end

return Debug