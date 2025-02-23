local SplinePoint = {}
SplinePoint.__index = SplinePoint

function SplinePoint.new(position)
    local instance = setmetatable({}, SplinePoint)
    instance.type = "SplinePoint"
    instance.automaticTangents = 1
    instance.continuousTangents = 1
    instance.id = 0
    instance.position = position
    instance.rotation = {["$type"] = "Quaternion", i = 0, j = 0, k = 0, r = 1}
    instance.tangents = {Elements = {{["$type"] = "Vector3", X = 0, Y = 0, Z = 0}, {["$type"] = "Vector3", X = 0, Y = 0, Z = 0}}}
    return instance
end

local JSONGenerator = {}
JSONGenerator.__index = JSONGenerator

function JSONGenerator.new()
    local instance = setmetatable({}, JSONGenerator)
    instance.points = {}
    return instance
end

function JSONGenerator:add_spline_point(position)
    table.insert(self.points, SplinePoint.new(position))
end

function JSONGenerator:to_json()
    local json_parts = {""}
    table.insert(json_parts, '"points":[')
    for i, point in ipairs(self.points) do
        local point_json = string.format(
            '{"$type":"%s","automaticTangents":%d,"continuousTangents":%d,"id":%d,"position":{"$type":"Vector3","X":%f,"Y":%f,"Z":%f},"rotation":{"$type":"Quaternion","r":%d,"i":%d,"j":%d,"k":%d},"tangents":{"Elements":[{"$type":"Vector3","X":%d,"Y":%d,"Z":%d},{"$type":"Vector3","X":%d,"Y":%d,"Z":%d}]}}%s',
            point.type,
            point.automaticTangents,
            point.continuousTangents,
            point.id,
            point.position.X, point.position.Y, point.position.Z,
            point.rotation.r, point.rotation.i, point.rotation.j, point.rotation.k,
            point.tangents.Elements[1].X, point.tangents.Elements[1].Y, point.tangents.Elements[1].Z,
            point.tangents.Elements[2].X, point.tangents.Elements[2].Y, point.tangents.Elements[2].Z,
            i < #self.points and "," or ""
        )
        table.insert(json_parts, point_json)
    end
    table.insert(json_parts, "],")
    return table.concat(json_parts)
end


local Debug = {}
Debug.__index = Debug

function Debug:New()
    local obj = {}

    -- set parameters
    obj.is_set_observer = false
    obj.is_im_gui_locked_number = false
    obj.spline_base_pos = { x = 0, y = 0, z = 0 }
    obj.spline_destination_pos = { x = 0, y = 0, z = 0 }
    obj.spline_pos = { x = 0, y = 0, z = 0 }
    obj.spline_pos_dest = { x = 0, y = 0, z = 0 }
    obj.is_recording = false
    obj.spline_count = 0
    obj.spline_debug_file = nil
    obj.spline_generator = nil

    return setmetatable(obj, self)
end

function Debug:ImGuiMain()

    ImGui.Begin("ATS DEBUG WINDOW")
    ImGui.Text("Version : " .. ATS.version)

    self:SetObserver()
    self:ImGuiInputSplineBasePosition()
    self:ImGuiSplineDestinationPosition()
    self:ImGuiSplineRelativePosition()
    self:ImGuiPlayerPosition()
    self:ImGuiFactValue()
    self:ImGuiLockedNumber()
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

function Debug:ImGuiInputSplineBasePosition()
    ImGui.Text("Spline Base Position : ")
    local value, used = ImGui.InputFloat("BaseX", self.spline_base_pos.x)
    self.spline_base_pos.x = value
    local value, used = ImGui.InputFloat("BaseY", self.spline_base_pos.y)
    self.spline_base_pos.y = value
    local value, used = ImGui.InputFloat("BaseZ", self.spline_base_pos.z)
    self.spline_base_pos.z = value
end

function Debug:ImGuiSplineDestinationPosition()
    ImGui.Text("Spline Destination Position : ")
    local value, used = ImGui.InputFloat("DestX", self.spline_destination_pos.x)
    self.spline_destination_pos.x = value
    local value, used = ImGui.InputFloat("DestY", self.spline_destination_pos.y)
    self.spline_destination_pos.y = value
    local value, used = ImGui.InputFloat("DestZ", self.spline_destination_pos.z)
    self.spline_destination_pos.z = value
end

function Debug:ImGuiSplineRelativePosition()
    local x, y, z = self.spline_base_pos.x, self.spline_base_pos.y, self.spline_base_pos.z
    local player = Game.GetPlayer()
    if player == nil then
        return
    end
    local player_pos = player:GetWorldPosition()
    if player_pos == nil then
        return
    end
    self.spline_pos.x = player_pos.x - x
    self.spline_pos.y = player_pos.y - y
    self.spline_pos.z = player_pos.z - z
    ImGui.Text("Spline Relative Position : " .. self.spline_pos.x .. ", " .. self.spline_pos.y .. ", " .. self.spline_pos.z)
    self.spline_pos_dest.x = player_pos.x - self.spline_destination_pos.x
    self.spline_pos_dest.y = player_pos.y - self.spline_destination_pos.y
    self.spline_pos_dest.z = player_pos.z - self.spline_destination_pos.z
    ImGui.Text("Spline Relative Destination Position : " .. self.spline_pos_dest.x .. ", " .. self.spline_pos_dest.y .. ", " .. self.spline_pos_dest.z)
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

function Debug:ImGuiLockedNumber()
    self.is_im_gui_locked_number = ImGui.Checkbox("[ImGui] Open Locked Number", self.is_im_gui_locked_number)
    if self.is_im_gui_locked_number then
        ImGui.Text("Locked numbers : ")
        local fact_db = Game.GetQuestsSystem()
        for i = 1, ATS.max_number_of_av do
            ImGui.Text("[" .. i .. "]" .. fact_db:GetFactStr("ats_av_traffic_lock_" .. i))
        end
    end
end

function Debug:ImGuiExcuteFunction()
    if ImGui.Button("Spline Start/Stop") then
        if self.is_recording then
            self.spline_debug_file = io.open("spline.json", "w")
            self.spline_generator:add_spline_point({["$type"] = "Vector3", X = self.spline_destination_pos.x - self.spline_base_pos.x, Y = self.spline_destination_pos.y - self.spline_base_pos.y, Z = self.spline_destination_pos.z - self.spline_base_pos.z})
            self.spline_debug_file:write(self.spline_generator:to_json())
            io.close(self.spline_debug_file)
            self.is_recording = false
        else
            self.spline_count = 0
            self.spline_generator = JSONGenerator.new()
            self.spline_generator:add_spline_point({["$type"] = "Vector3", X = 0, Y = 0, Z = 0})
            self.is_recording = true
        end
    end
    if self.is_recording then
        ImGui.Text("Recording : On")
        ImGui.Text("Current Spline Count : " .. self.spline_count)
    else
        ImGui.Text("Recording : Off")
    end
    if ImGui.Button("Spline Point") then
        self.spline_generator:add_spline_point({["$type"] = "Vector3", X = self.spline_pos.x, Y = self.spline_pos.y, Z = self.spline_pos.z})
        self.spline_count = self.spline_count + 1
    end
    if ImGui.Button("Start") then
        StartLoop()
        print("Loop Start")
    end
    ImGui.SameLine()
    if ImGui.Button("Stop") then
        StopLoop()
        print("Loop Stop")
    end
    if ImGui.Button("Delete Settings") then
        io.open(ATS.setting_path, "w"):close()
        print("Delete Settings")
    end

end

return Debug