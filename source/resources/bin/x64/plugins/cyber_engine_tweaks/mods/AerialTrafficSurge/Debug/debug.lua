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
    self:ImGuiRelativePosition(-2247.4231, -406.2932, 24.5819)
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
    local ats_av_traffic_debug = fact_db:GetFactStr("ats_av_traffic_debug")
    local ats_av_traffic_start = fact_db:GetFactStr("ats_av_traffic_start")
    local ats_av_traffic_loop = fact_db:GetFactStr("ats_av_traffic_loop")
    local ats_av_traffic_reset = fact_db:GetFactStr("ats_av_traffic_reset")
    ImGui.Text("ats_av_traffic_debug : " .. ats_av_traffic_debug)
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
    if ImGui.Button("Start") then
        StartLoop()
        print("Loop Start")
    end
    ImGui.SameLine()
    if ImGui.Button("Stop") then
        StopLoop()
        print("Loop Stop")
    end

end

return Debug