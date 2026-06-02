-- # Client Autorun
local client_module = {}
local gui_module = {}
local navigation_module = {}

-- Type Aliases
type luauInstance = {}
type clientEventArguments = {
    action: string,
}
type serverEventArguments = {
    action: string,
}

-- Constants
local AMS_DISTANCE = 7.5
local SWITCH_SOUNDS = false :: boolean
local ONLY_SWAP_VALID_SOUNDS = false :: boolean

-- Variables
local anti_monster_device: Part
local anti_monster_model: Model
local renderstep_connection: RBXScriptConnection
local amd_connection: RBXScriptConnection
local current_custom_keybinds = {

}

config.keybinds.toggle_godmode = table.clone(config.keybinds.move_forward)
config.keybinds.toggle_godmode.name = "Toggle godmode"
config.keybinds.toggle_godmode.description = "Toggles godmode"
config.settings_layout.custom = {
  { text= "Custom keybinds", type = "text" },
  { keybind = "toggle_godmode", type = "keybind" }
}

-- Methods
local function getServerSharedVariable(name: string)
    local sv_name = "sv_".. name
    local return_value = shared[sv_name]
    if not return_value then
        warn("getServerSharedVariable: server variable \"".. name.. "\" was not found")
    end
    
    return shared[sv_name]
end

-- \\ navigation_module Methods
local function __isChildOfRestrictedFolder(instanceToLook)
    local isNotAChildOfWorkspace, _result = pcall(function(thisInstance)
        local potentialWorkspaceChild = thisInstance.Parent
    end, instanceToLook)

    return not isNotAChildOfWorkspace
end

local function __searchInstanceParentsToFindIgnoreFolder(instanceAtStep)
    if __isChildOfRestrictedFolder(instanceAtStep) then return end
    local thisInstanceParent = instanceAtStep.Parent
    if not thisInstanceParent then return end

    if thisInstanceParent.Name == "ignore" and thisInstanceParent.is_a("Folder") then
        if not __isChildOfRestrictedFolder(thisInstanceParent) then return end
        return thisInstanceParent
    end

    return __searchInstanceParentsToFindIgnoreFolder(thisInstanceParent)
end

function navigation_module:getIgnoreFolderUsingTaggedChildren()
    for indexOfTagList, tagString in pairs(tags.get_tags()) do
        for indexOfInstance, instance in pairs(tags.get_tagged(tagString)) do
            local potentialIgnoreFolderCanidate = __searchInstanceParentsToFindIgnoreFolder(instance)
            if not potentialIgnoreFolderCanidate then continue end
            return potentialIgnoreFolderCanidate
        end
    end
end

-- \\ gui_module Methods
function gui_module.draw()
    iris:Connect(function()
        iris.Window({
            [Iris.Args.Window.Title] = "GUN_INFORMATION",
            [Iris.Args.Window.NoTitleBar] = true,
            [Iris.Args.Window.NoBackground] = true,
            [Iris.Args.Window.NoCollapse] = true,
            [Iris.Args.Window.NoClose] = true,
            [Iris.Args.Window.NoMove] = true,
            [Iris.Args.Window.NoScrollbar] = true,
            [Iris.Args.Window.NoResize] = true,
        })
            iris.Text({"GUN_INFO_NAME"})
        iris.End()
    end)
end

-- \\ client_module Methods
-- Replaces (or swaps) one set of gun sound's with another
function client_module:replace_gun_sounds(destination: string, target: string, swap: boolean)
    if swap == nil then
        swap = false
    end

    for name: string, value: any in config.gunshots do
        local is_sound_from_target = name:find(target)
        if is_sound_from_target then
            local target_prefix_length = target:len()
            local original_destination_sound_name = destination.. name:sub(target_prefix_length + 1)

            local original_target_sound = value
            local original_dest_sound = config.gunshots[original_destination_sound_name]

            local is_dest_sound_valid = ONLY_SWAP_VALID_SOUNDS and original_dest_sound ~= nil or true
            if is_dest_sound_valid then
                if SWITCH_SOUNDS then
                    config.gunshots[name] = original_dest_sound
                end

                config.gunshots[original_destination_sound_name] = original_target_sound
            end
        end
    end

    if SWITCH_SOUNDS then
        print("Swapped", destination, "gun sounds with", target, "gun sounds")
    else
        print("Replaced", destination, "gun sounds with", target, "gun sounds")
    end
end

-- Creates a transparent shield that gives players a way to directly look at the monster without it disappearing
-- and lets players approach the monster (as long as the shield covers them)
function client_module:createNewLegacyShield(): Part
    if anti_monster_device then
        anti_monster_device.destroy()
    end

    local ams: Part = create_instance("Part")
    ams.Name = "Anti-Monster Shield"
    ams.Transparency = 0
    ams.Material = Enum.Material.ForceField
    ams.Color = Color3.fromRGB(255, 255, 255)
    ams.CastShadow = false
    ams.Anchored = true
    ams.CanCollide = false
    ams.CanQuery = true -- This needs to be enabled
    ams.CanTouch = false
    ams.CollisionGroup = "wall"

    -- Flat Shield
    ams.Shape = Enum.PartType.Block
    ams.Size = Vector3.new(75, 75, 0.125)

    --[[ Spherical Shield 
        ams.Shape = Enum.PartType.Ball
        ams.Size = Vector3.new(15, 15, 15)
    ]]

    ams.Parent = get_map_root() -- navigation_module:getIgnoreFolderUsingTaggedChildren()
    
    return ams
end

function client_module:createNewShieldModel(): Model
    if anti_monster_device then
        anti_monster_device.destroy()
    end

    local panel_thickness = 0.125
    local panel_width = 1
    local panel_radius = 3
    local panel_adjusted_width = panel_width + 2 * panel_thickness

    local ams_parts = {}:: {[string]: Part}
    local front_panel: Part
    local back_panel: Part
    local top_panel: Part
    local bottom_panel: Part
    local left_panel: Part
    local right_panel: Part
    
    local ams: Model = create_instance("Model")
    ams.Name = "Anti-Monster Shield Model"

    for i = 1, 6, 1 do
        local shield_part: Part = create_instance("Part")
        ams_parts[i] = shield_part

        shield_part.Name = "Anti-Monster Shield Panel"
        shield_part.CollisionGroup = "wall"
        shield_part.Transparency = 0
        shield_part.Material = Enum.Material.ForceField
        shield_part.Shape = Enum.PartType.Block
        shield_part.Position = Vector3.new()
        shield_part.Size = Vector3.new(panel_adjusted_width, panel_adjusted_width, panel_thickness)
        shield_part.Color = Color3.fromRGB(255, 255, 255)
        shield_part.CastShadow = false
        shield_part.Anchored = true
        shield_part.CanCollide = false
        shield_part.CanQuery = true -- This needs to be enabled
        shield_part.CanTouch = false
    end

    front_panel = ams_parts[1]
    front_panel.Name = front_panel.Name.. " (Front)"
    front_panel.Orientation = Vector3.new(0, 0, 0)
    front_panel:PivotTo(front_panel:GetPivot().LookVector * panel_radius + panel_thickness)

    back_panel = ams_parts[2]
    back_panel.Name = back_panel.Name.. " (Back)"
    back_panel.Orientation = Vector3.new(180, 0, 180)
    back_panel:PivotTo(back_panel:GetPivot().LookVector * panel_radius + panel_thickness)

    top_panel = ams_parts[3]
    top_panel.Name = top_panel.Name.. " (Top)"
    top_panel.Orientation = Vector3.new(90, 0, 0)
    top_panel:PivotTo(top_panel:GetPivot().LookVector * panel_radius + panel_thickness)

    bottom_panel = ams_parts[4]
    bottom_panel.Name = bottom_panel.Name.. " (Bottom)"
    bottom_panel.Orientation = Vector3.new(-90, 0, 0)
    bottom_panel:PivotTo(bottom_panel:GetPivot().LookVector * panel_radius + panel_thickness)

    left_panel = ams_parts[5]
    left_panel.Name = left_panel.Name.. " (Left)"
    left_panel.Orientation = Vector3.new(0, 90, 0)
    left_panel:PivotTo(left_panel:GetPivot().LookVector * panel_radius + panel_thickness)

    right_panel = ams_parts[6]
    right_panel.Name = right_panel.Name.. " (Right)"
    right_panel.Orientation = Vector3.new(0, -90, 0)
    right_panel:PivotTo(right_panel:GetPivot().LookVector * panel_radius + panel_thickness)

    for _, part: Part in ams_parts do
        part.Parent = ams
    end

    ams.Parent = get_map_root() -- navigation_module:getIgnoreFolderUsingTaggedChildren()
    
    return ams
end

-- Renderstep function for the AMS_update renderstep loop
-- Updates the AMD position
local function new_AMS_update(delta_time)
    if framework.character.is_alive() then
        local root_position: Vector3 = framework.character.get_position()
        local new_model_cframe: CFrame = CFrame.new(root_position)
        anti_monster_model:PivotTo(new_model_cframe)
        print((root_position - anti_monster_model:GetPivot().Position).Magnitude)
    end
end

local function legacy_AMS_update(delta_time)
    if framework.character.is_alive() then
        if anti_monster_device ~= nil then
            local camera_cframe: CFrame = framework.character.get_camera_cframe()
            local amd_new_cframe: CFrame = camera_cframe + camera_cframe.LookVector * AMS_DISTANCE
            local amd_new_position: Vector3 = amd_new_cframe.Position
            local amd_ori_rx, amd_ori_ry, amd_ori_rz: number = amd_new_cframe:ToOrientation()
            local amd_ori_dx, amd_ori_dy, amd_ori_dz: number = math.deg(amd_ori_rx), math.deg(amd_ori_ry), math.deg(amd_ori_rz)
            local amd_new_ori: Vector3 = Vector3.new(amd_ori_dx, amd_ori_dy, amd_ori_dz)

            anti_monster_device.Position = amd_new_position
            anti_monster_device.Orientation = amd_new_ori

            --[[ Spherical Shield
                local camera_cframe: CFrame = framework.character.get_camera_cframe()
                local amd_new_cframe: CFrame = camera_cframe
                local amd_new_position: Vector3 = amd_new_cframe.Position

                anti_monster_device.Position = amd_new_position
            ]]
        end
    end
end

local function setupShieldIfNeeded()
    if anti_monster_device == nil then
        anti_monster_device = client_module:createNewLegacyShield()
    end

    if amd_connection == nil then
        amd_connection = time.renderstep("AMS_update", new_AMS_update)
    end
end

local function disableShieldIfNeeded()
    if anti_monster_device ~= nil then
        anti_monster_device.destroy()
        anti_monster_device = nil
    end

    if amd_connection ~= nil then
        amd_connection:Disconnect()
        amd_connection = nil
    end
end

--  Method for the framework.on_spawned event
function client_module.on_spawned()
    print("spawned")
    if getServerSharedVariable("monsterShieldsEnabled") == true then
        amd_connection = time.renderstep("AMS_update", new_AMS_update)
    end

    gui_module.draw()
end

--  Method for the framework.on_died event
function client_module.on_died()
    print("died")
    disableShieldIfNeeded()
end

local function renderstepFunction(delta_time)
    -- UI stuff
    if framework.character.is_alive() then
        if getServerSharedVariable("monsterShieldsEnabled") == true then
            setupShieldIfNeeded()
        else
            disableShieldIfNeeded()
        end
    else
        disableShieldIfNeeded()
    end
end

local function onServerEvent(data: {any | clientEventArguments?})
    local args = data[1] -- why? idk
    local return_value: any

    if args.action == "setServerSharedVariable" then
        local index = "sv_".. args.sv_name
        shared[index] = args.sv_value

        return_value = shared[index]
    end
    
    return return_value
end

local function fetchCurrentServerVariables()
    local event_args = {
        action = "fetchCurrentServerVariables"
    }
    fire_server(event_args)
end

local function customKeybind_moveForward()
    print("stopped pressing W")
end

local function bind_user_setting(func: thread, inputType: InputType, name: string)
    -- ClientInputGroup:bind_user_setting(func, inputType, name)
    current_custom_keybinds[name] = true
end

-- Runtime
-- Get server variables
fetchCurrentServerVariables()

-- \\ Replace/Swap Gun Sounds
client_module:replace_gun_sounds("QBZ", "AK308", false)
client_module:replace_gun_sounds("P320", "UMP9", false)
client_module:replace_gun_sounds("HK416", "M4A1", false)
client_module:replace_gun_sounds("AK_762", "FAL", false)

-- \\ Connect Events
-- \\\\ Constant events
renderstep_connection = time.renderstep("Monster Client Renderstep", renderstepFunction)

-- \\\\ Game Events
framework.on_spawned:Connect(client_module.on_spawned)
framework.on_died:Connect(client_module.on_died)

-- \\\\ Server Events
on_server_event:Connect(onServerEvent)

-- \\\\ Keybind Events
bind_user_setting(customKeybind_moveForward, InputType.Ended, "custom_keybind1")

shared["client_module"] = client_module
shared["gui_module"] = gui_module
shared["navigation_module"] = navigation_module

return client_module, gui_module, navigation_module