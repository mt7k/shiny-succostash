-- # Client Autorun
local client_module = {}
local gui_module = {}
local navigation_module = {}

-- Constants
local AMS_DISTANCE = 7.5
local SWITCH_SOUNDS = false :: boolean
local ONLY_SWAP_VALID_SOUNDS = false :: boolean

-- Variables
local anti_monster_device: Part
local renderstep_connection: RBXScriptConnection
local amd_connection: RBXScriptConnection

-- Methods
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
        local gunInfoWindow = iris.Window({"GUN_INFORMATION"})
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
function client_module:createNewShield(): Part
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

-- Renderstep function for the AMS_update renderstep loop
-- Updates the AMD position
local function AMS_update(delta_time)
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

--  Method for the framework.on_spawned event
function client_module.on_spawned()
    print("spawned")
    anti_monster_device = client_module:createNewShield()
    amd_connection = time.renderstep("AMS_update", AMS_update)
end

--  Method for the framework.on_died event
function client_module.on_died()
    print("died")
    if anti_monster_device ~= nil then
        anti_monster_device.destroy()
    end

    if amd_connection ~= nil then
        amd_connection:Disconnect()
        amd_connection = nil
    end
end

local function renderstepFunction(delta_time)
    -- UI stuff
    if framework.character.is_alive() then
        gui_module.draw()
    -- else
        -- ui for when the character is despawned
    end
end

-- Runtime
-- \\ Replace/Swap Gun Sounds
client_module:replace_gun_sounds("QBZ", "AK308", false)
client_module:replace_gun_sounds("P320", "UMP9", false)
client_module:replace_gun_sounds("HK416", "M4A1", false)
client_module:replace_gun_sounds("AK_762", "FAL", false)

-- \\ Connect Events
renderstep_connection = time.renderstep("Monster Client Renderstep", renderstepFunction)
framework.on_spawned:Connect(client_module.on_spawned)
framework.on_died:Connect(client_module.on_died)

shared["client_module"] = client_module
shared["gui_module"] = gui_module
shared["navigation_module"] = navigation_module

return client_module, gui_module, navigation_module