-- # Killer Bot Handling
local killbot_module = {}

-- Type Aliases
type luauInstance = {}
type clientEventArguments = {
    action: string,
}
type serverEventArguments = {
    action: string,
}
type Timer = {
    new: thread,
    expire: thread,
    expired: (boolean),
    timeout: number,
    next_time: number
}
type TimerSettings = {
    timer: Timer,
    time_range: NumberRange,
    primed: boolean
}
type killbot_properties = {
    loop: {
        currently_looping: boolean,
        
    },
    combat: {
        attacking: boolean,
    },
    detection: {
        detected_player: boolean,
        player_detected: string | nil,
    },
    movement: {
        moving: boolean,
        lingering: boolean,
        chasing: boolean,
        next_linger_delay: TimerSettings,
        next_position: Vector3
    },
    combat_properties: {
        weapon: string, -- "knife", "monster-instantkill" (maybe)
        weapon_range: number,
        damage_per_hit: number,
        next_hit_timer: TimerSettings,
    },
    detection_properties: {
        sight_distance: number,
        detection_angle_from_eyes: number,
    },
    movement_properties: {
        default_movement_speed: number,
        linger_movement_speed: number,
        chasing_movement_speed: number,
    },
}

-- Modules
local SERVER_SOUNDS = require("deadline_monster_sounds.luau")

-- Constants
local shared_restore_prefix = "RESTORE"

-- Variables
local current_killbots = {} --:: {[string]: killbot_properties}

-- Functions
local function createTimer(time_range: NumberRange)
    timer = {
        timer = Timer.new(0):: Timer,
        time_range = time_range,
    }
end

-- \\ Bot Functions
local function killBotLoop()
    
end

-- \\ Event functions
local function on_bot_spawned(bot: luauInstance)
    
end

local function on_bot_died(bot: luauInstance)

end

local function onPlayerSpawned(name: string)
    local player = players.get(name)
    if player then
        if player.is_bot() then
            task.spawn(on_bot_spawned, player)
        end
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerDied(name, death_position, killer_data, stats_counted)
    local player = players.get(name)
    if player then
        if player.is_bot() then
            task.spawn(on_bot_died, player)
        end
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerJoined(name)
    local player = players.get(name)
    if player then
        -- stuff
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerLeft(name)
    print("player left:", name)
end

-- Runtime
-- \\ Events
-- \\\\ Run on_player_joined on players that are in the game before this autorun executes
for i, player in players.get_all() do
    local name = player.name
    onPlayerJoined(name)
end

on_player_spawned:Connect(onPlayerSpawned)
on_player_died:Connect(onPlayerDied)
on_player_joined:Connect(onPlayerJoined)
on_player_left:Connect(onPlayerLeft)

shared["killbot_module"] = killbot_module

return killbot_module