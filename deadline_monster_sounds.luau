--# Sound IDs Module
local server_sound_module = {}

-- Type Aliases
type physicalSoundProperties = {
    id: number,
    volume: number,
    speed: number,
    max_distance: number,
    min_distance: number,
    position: Vector3,
    weldTo: BasePart | nil,
}

-- Constants
local IDs = {
    painful_scream = {
        
    },
    death_monster = {
        --[[ V1
        9113543849,
        9113547393,
        9113541344,
        9113545651,]]
        -- V2
        9114542183,
        9113540587,
        9113540935,
        9119558965,
        9113542948,
    }
}

-- Variables
local current_sounds = {}:: {[string]: Part}

-- Functions
local function debrisAddItem(inst: Instance, delay: number)
    if not delay then
        delay = 5
    end

    task.delay(delay, function()
        inst.destroy()
    end)
end

function server_sound_module:preloadAllAudio()
    for _, selected_category in IDs do
        for _, selected_id in selected_category do
            local properties = {
                id = selected_id,
                volume = 0,
                speed = 100,
                max_distance = 20,
                min_distance = 0,
                position = Vector3.new(),
            }

            self:insertPhysicalSoundToWorkspace(properties)
        end
    end
end

function server_sound_module:selectRandomIDFromCategory(category: string)
    local sounds = IDs[category]
    if not sounds then
        return warn("server_sound_module:selectRandomIDFromCategory: category", category, "not found in IDs")
    end

    local random_number = math.random(1, #sounds)
    local chosen_sound = sounds[random_number]

    return chosen_sound
end

function server_sound_module:insertPhysicalSoundToWorkspace(properties: physicalSoundProperties)
    local part: Part = create_instance("Part")
    part.BrickColor = BrickColor.White()
    part.Transparency = 1
    part.Reflectance = 1
    part.Anchored = properties.weldTo == nil
    part.Massless = true
    part.AudioCanCollide = false
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Position = properties.position
    part.Size = Vector3.new()
    part.Shape = Enum.PartType.Ball

    if properties.weldTo then
        local weld: WeldConstraint = create_instance("WeldConstraint")
        weld.Part0 = part
        weld.Part1 = properties.weldTo
        weld.Parent = part
    end

    local sound_instance: Sound = sound.create()
    sound_instance.SoundId = "rbxassetid://".. properties.id
    sound_instance.Volume = properties.volume
    sound_instance.PlaybackSpeed = properties.speed
    sound_instance.RollOffMaxDistance = properties.max_distance
    sound_instance.RollOffMinDistance = properties.min_distance
    sound_instance.RollOffMode = Enum.RollOffMode.Linear
    -- sound_instance.AcousticSimulationEnabled = true -- soon

    if not sound_instance.IsLoaded then
        local threshold = 60
        repeat
            task.wait()
            threshold -= 1
        until threshold <= 0 or sound_instance.IsLoaded
    end

    local sound_length = (sound_instance.TimeLength * 2) / properties.speed
    
    sound_instance:play()
    debrisAddItem(part, sound_length)

    part.Parent = get_map_root()
    current_sounds[sound_instance.Name] = sound_instance
end

return server_sound_module