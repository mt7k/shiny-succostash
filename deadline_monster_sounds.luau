local Players = game:GetService("Players")
--# Sound IDs Module
local server_sound_module = {}

-- Type Aliases
type luauInstance = {
    name: string,
}
type clientEventArguments = {
    action: string,
}
type serverEventArguments = {
    action: string,
}
type physicalSoundProperties = {
    id: number,
    volume: number,
    speed: number,
    max_distance: number,
    min_distance: number,
    sound_loop: boolean,
    position: Vector3,
    weldTo: BasePart | nil,
}
type snapshotPlayerPivots = {
    char_position: Vector3,
    camera_cframe: CFrame,
}

-- Constants
local IDs = {
    slowed_horror_ambience_loop = {
        8601687897
    },
    horror_ambience_blip = {
        107688529939258,
        86235856688933,
    },
    physical_horror_ambience_no_loop = {
        9114228832,
        9112775414,
        9112795463,
        9112795583,
        138347177735590,
        1840844303,
        130812982962354,
    },
    physical_horror_blip_behind_player = {
        119222436395249,

    },
    physical_horror_blip_hovering = {
        94419645391952,
    },
    physical_horror_ambience_far_away = {
        112720265172389,
        1104659813,
        72420282821989,
        105519980274696,
    },
    painful_scream = {
        91948204995130,
        79393083436423,
        137835939293260,
        81157569915784,
    },
    death_monster = {
        9114542183,
        9113540587,
        9113540935,
        9119558965,
        9113542948,
    }
}
local HORROR_SOUND_RADIUS_RANGES = {
    ambience = NumberRange.new(100, 1000),
    behind_player = NumberRange.new(5, 25),
    hovering = NumberRange.new(300, 1200),
}
local HORROR_SOUND_PROPERTIES: {physicalSoundProperties} = {
    slowed_horror_ambience_loop = {
        volume = 1,
        speed = 1,
        max_distance = 5 * HORROR_SOUND_RADIUS_RANGES["ambience"].Max,
        min_distance = 45 * HORROR_SOUND_RADIUS_RANGES["ambience"].Min,
        sound_loop = true
    },
    horror_ambience_blip = {
        volume = 1,
        speed = 1,
        max_distance = 5 * HORROR_SOUND_RADIUS_RANGES["ambience"].Max,
        min_distance = 45 * HORROR_SOUND_RADIUS_RANGES["ambience"].Min,
    },
    physical_horror_ambience_no_loop = {
        volume = 1,
        speed = 1,
        max_distance = HORROR_SOUND_RADIUS_RANGES["ambience"].Max,
        min_distance = 2 * HORROR_SOUND_RADIUS_RANGES["ambience"].Min,
    },
    physical_horror_blip_behind_player = {
        volume = 0.25,
        speed = 1,
        max_distance = HORROR_SOUND_RADIUS_RANGES["behind_player"].Max,
        min_distance = HORROR_SOUND_RADIUS_RANGES["behind_player"].Min,
    },
    physical_horror_blip_hovering = {
        volume = 0.5,
        speed = 1,
        max_distance = HORROR_SOUND_RADIUS_RANGES["behind_player"].Max + 200,
        min_distance = HORROR_SOUND_RADIUS_RANGES["behind_player"].Min,
    },
    physical_horror_ambience_far_away = {
        volume = 0.75,
        speed = 1,
        max_distance = 10 * HORROR_SOUND_RADIUS_RANGES["ambience"].Max,
        min_distance = 75 * HORROR_SOUND_RADIUS_RANGES["ambience"].Min,
    },
    painful_scream = {
        volume = 2.5,
        speed = 0.95,
        max_distance = 40,
        min_distance = 10,
    },
    death_monster = {
        volume = 2,
        speed = 1,
        max_distance = 20,
        min_distance = 5,
    },
}

-- Variables
local last_player_pivots = {}:: {[string]: snapshotPlayerPivots}
local random_sound_ignore_list = {}:: {[string]: {number}}

-- Functions
-- \\ Utility
local function debrisAddItem(inst: Instance, delay: number)
    if not delay then
        delay = 5
    end

    task.delay(delay, function()
        inst.destroy()
    end)
end
-- \\ Sound Prep Functions
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

-- \\ Sound Selection Functions
local function getSoundIgnoreListCategory(soundCategory: string): string
    local t_category = random_sound_ignore_list[soundCategory]
    if not t_category then
        random_sound_ignore_list[soundCategory] = {}
    end
    
    return random_sound_ignore_list[soundCategory]
end

local function addToSoundIgnoreList(soundCategory: string, soundID: number)
    local t_category = getSoundIgnoreListCategory(soundCategory)
    table.insert(t_category, soundID)
end

local function soundIgnoreListContainsID(soundCategory: string, soundID: string)
    local contains = false
    local t_category = getSoundIgnoreListCategory(soundCategory)
    if table.find(t_category, soundID) then
        contains = true
    end

    return contains
end

local function resetSoundIgnoreList(soundCategory: string)
    if soundCategory then
        random_sound_ignore_list[soundCategory] = {}
    else
        random_sound_ignore_list = {}
    end
end

function server_sound_module:getRandomSoundID(soundCategory: string): (string, string)
    soundCategory = soundCategory:lower()

    local soundID = nil
    local t_category = getSoundIgnoreListCategory(soundCategory)
    local random_number = math.random(1, #t_category)
    local chosenID = t_category[random_number]
    
    if #t_category >= #IDs[soundCategory] then
        resetSoundIgnoreList(soundCategory)
    end

    local success = false
    local index = 0
    
    repeat
        if chosenID then
            if soundIgnoreListContainsID(soundCategory, chosenID) == false then
                addToSoundIgnoreList(soundCategory, chosenID)
                success = true
                soundID = chosenID
            else
                random_number = math.random(1, #t_category)
                chosenID = t_category[random_number]
            end
        else
            error("Something went seriously wrong while looking for a random sound ID")
        end

        index += 1
    until success == true or index > 30

    return soundID
end

-- \\ Sound Playback Functions
local function createSoundPart(properties: physicalSoundProperties)
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

    part.Parent = get_map_root()

    return part
end

local function createSound(properties)
    local sound_instance: Sound = sound.create()
    sound_instance.SoundId = "rbxassetid://".. properties.id
    sound_instance.Volume = properties.volume
    sound_instance.PlaybackSpeed = properties.speed
    sound_instance.RollOffMaxDistance = properties.max_distance
    sound_instance.RollOffMinDistance = properties.min_distance or 0
    sound_instance.RollOffMode = Enum.RollOffMode.Linear
    sound_instance.Looped = properties.sound_loop or false
    -- sound_instance.AcousticSimulationEnabled = true -- soon

    if not sound_instance.IsLoaded then
        local threshold = 60
        repeat
            task.wait()
            threshold -= 1
        until threshold <= 0 or sound_instance.IsLoaded
    end

    return sound_instance
end

function server_sound_module:insertPhysicalSoundToWorkspace(properties: physicalSoundProperties)
    local sound_part: Part = createSoundPart(properties)
    local sound_instance: Sound = createSound(properties)

    local sound_length = (sound_instance.TimeLength * 2) / properties.speed

    sound_instance:play()
    debrisAddItem(sound_part, sound_length)

    return sound_part, sound_instance
end

local function getRandomAlivePlayer()
    local plrs = players.get_all()
    local random_index = math.random(1, #plrs)
    local hauntedPlayer: luauInstance = plrs[random_index]
    local random_threshold = 30

    if not hauntedPlayer.is_alive() then
        repeat
            random_index = math.random(1, #plrs)
            hauntedPlayer = plrs[random_index]
            if not hauntedPlayer.is_alive() then
                hauntedPlayer = nil
            end

            random_threshold -= 1
        until random_threshold == 0 or hauntedPlayer ~= nil
    end

    return hauntedPlayer
end

local function find_position_for_ambience(): Vector3
    local finalPosition: Vector3
    local hauntedPlayer: luauInstance = getRandomAlivePlayer()
    
    local x_coefficient, z_coefficient = math.random(-1, 1) > 0 and 1 or -1, math.random(-1, 1) > 0 and 1 or -1
    local rand_x = x_coefficient * math.random(HORROR_SOUND_RADIUS_RANGES["ambience"].Min, HORROR_SOUND_RADIUS_RANGES["ambience"].Max)
    local rand_z = z_coefficient * math.random(HORROR_SOUND_RADIUS_RANGES["ambience"].Min, HORROR_SOUND_RADIUS_RANGES["ambience"].Max)

    finalPosition = hauntedPlayer.get_position() + Vector3.new(rand_x, rand_z)

    return finalPosition
end

local function get_last_player_pivot(player: luauInstance)
    local event_args = { action = "getSnapshotPlayerPivot" } :: clientEventArguments
    player.fire_client(event_args)

    local threshold = 60
    local updated = false
    local last_pivot = last_player_pivots[player.name]
    repeat
        if last_player_pivots[player.name] ~= last_pivot then
            updated = true
            last_pivot = last_player_pivots[player.name]
        end

        threshold -= 1
        task.wait(0.25)
    until threshold == 0 or updated

    return last_pivot
end

local function find_position_for_sound_behind_player(): Vector3
    local finalPosition: Vector3
    local hauntedPlayer: luauInstance = getRandomAlivePlayer()

    local camera_cframe: CFrame
    if not last_player_pivots[hauntedPlayer.name] then
        local pivot: snapshotPlayerPivots = get_last_player_pivot()
        if pivot then
            camera_cframe = pivot.camera_cframe
        end
    end

    local distance = math.random(HORROR_SOUND_RADIUS_RANGES["behind_player"].Min, HORROR_SOUND_RADIUS_RANGES["behind_player"].Max)
    finalPosition = hauntedPlayer.get_position() + camera_cframe.LookVector * distance

    return finalPosition
end

function server_sound_module:createAmbience(ambience_category: string, properties: physicalSoundProperties?)
    if not properties then
        properties = HORROR_SOUND_PROPERTIES[ambience_category]
        if not properties then
            warn("createAmbience: Physical sound properties table of category", ambience_category, "not found")
        end
    end

    local finalPosition: Vector3 = Vector3.new()
    if ambience_category:find("ambience") ~= nil then
        finalPosition = find_position_for_ambience()
    elseif ambience_category:find("behind_player") ~= nil then
        finalPosition = find_position_for_sound_behind_player()
    end

    properties.position = finalPosition

    local sound_part: Part = createSoundPart(properties)
    local sound_instance: Sound = createSound(properties)

    local sound_length = (sound_instance.TimeLength * 1.1) / properties.speed

    sound_instance:play()
    debrisAddItem(sound_part, sound_length)
end

function server_sound_module:getPhysicalSoundPropertyTables()
    return HORROR_SOUND_PROPERTIES
end

local function onClientEvent(playerName: string, data: {any | serverEventArguments?})
    -- local playerInstance = players.get(playerName)
    local args = data[1]:: snapshotPlayerPivots -- why? idk

    if args.action == "giveSnapshotPlayerPivot" then
        last_player_pivots[playerName] = args.snapshot
    end
end

on_client_event:Connect(onClientEvent)

return server_sound_module