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
    runtime_loop: {
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
        next_position: Vector3 | nil
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
type killbot_runtimes = {
    [string]: {
        currently_looping: boolean,
        can_loop: boolean,
    }
}

-- Modules
local UTILITY_MODULE = require("deadline_monster_global_utility.luau")
local SERVER_SOUNDS = require("deadline_monster_sounds.luau")

-- Variables
local current_killbots: {[string]: killbot_properties} = {}
local killbot_loop_status: killbot_runtimes = {}

-- \\ Bot Functions
local function getKillBotTable(bot: luauInstance)
    local bot_name = bot.name
    return current_killbots[bot_name]
end

local function setCombatProperties(weapon: string)
    local return_table = {
        weapon = weapon
    }

    if weapon == "knife" then
        return_table.weapon_range = 3
        return_table.damage_per_hit = 75
        return_table.next_hit_timer = UTILITY_MODULE:createTimerSettings(NumberRange.new(0.75, 2))
    end

    return return_table
end

local function setupKillBotTable(bot: luauInstance)
    local bot_name = bot.name
    local next_linger_range = NumberRange.new(2, 10)
    if getKillBotTable(bot) == nil or getKillBotTable(bot) == {} then
        local new_killbot_tbl: killbot_properties = {
            runtime_loop = {
                currently_looping = false,
            },
            combat = {
                attacking = false,
            },
            detection = {
                detected_player = false,
                player_detected = nil,
            },
            movement = {
                moving = false,
                lingering = false,
                chasing = false,
                next_linger_delay = UTILITY_MODULE:createTimerSettings(next_linger_range),
                next_position = nil
            },
            combat_properties = setCombatProperties("knife"),
            detection_properties = {
                sight_distance = 70,
                detection_angle_from_eyes = 105,
            },
            movement_properties = {
                default_movement_speed = 1,
                linger_movement_speed = 0.75,
                chasing_movement_speed = 1.10,
            },
        }
        local new_loop_status = {
            currently_looping = false,
            can_loop = false,
        }

        current_killbots[bot_name] = new_killbot_tbl
        killbot_loop_status[bot_name] = new_loop_status
    else
        warn("bot", bot, "already has a table; remove it before setting up")
    end

    return current_killbots[bot_name], killbot_loop_status[bot_name]
end

local function botCheckForNearbyPlayer(bot: luauInstance)
    local killbot_table = getKillBotTable(bot)
    local sightDistance = killbot_table.detection_properties.sight_distance
    local foundPlayer = nil
    local closestDistanceOfFoundPlayer = nil

    for i, potentialPlayer in players.get_alive() do
        local playerPosition: Vector3 = potentialPlayer.get_position()
        if playerPosition then
            local botPosition: Vector3 = bot.get_position()
            local distance: number = (botPosition - playerPosition).Magnitude
            
            if distance < sightDistance then
                if closestDistanceOfFoundPlayer == nil or closestDistanceOfFoundPlayer < distance then
                    foundPlayer = potentialPlayer
                    closestDistanceOfFoundPlayer = distance
                end
            end
        end
    end

    return foundPlayer
end

local function botIdle(bot: luauInstance)
    local killbot_table = getKillBotTable(bot)
    bot.bot.set_behavior("BaseBehavior")
    local linger_timer = killbot_table.movement.next_linger_delay
    if linger_timer.timer:expired() then
        local new_linger_timeout = math.random(linger_timer.time_range.Min, linger_timer.time_range.Max)
        killbot_table.movement.next_linger_delay.timer.timeout = new_linger_timeout
        killbot_table.movement.next_linger_delay.timer:reset()

        local random_position_offset = Vector3.new(math.random(), 0, math.random())
        killbot_table.movement.next_position = bot.get_position + random_position_offset
        bot.bot.set_move_destination(killbot_table.movement.next_position)
    end
end

local function killbotLoop(bot: luauInstance)
    local bot_name = bot.name
    local loop_status = killbot_loop_status[bot_name]
    loop_status.currently_looping = true

    repeat
        if bot.is_alive() then
            local foundPlayer = botCheckForNearbyPlayer(bot)
            if foundPlayer then
                -- figure out what to do here
                bot.bot.set_behavior("PathfindToNearestPlayerBehavior")
            else
                -- perform fail case for kill bot
                botIdle(bot)
            end
        else
            loop_status.can_loop = false
        end

        task.wait(1/3)
    until loop_status.can_loop == false

    loop_status.currently_looping = false
end

local function startKillbotLoop(bot: luauInstance)
    local bot_name = bot.name
    local killbot_table = getKillBotTable(bot)
    local loop_status = killbot_loop_status[bot_name]

    if killbot_table then
        if loop_status then
            print("startKillbotLoop(", bot, "): changing loop status")
            loop_status.can_loop = true
            task.spawn(killbotLoop, bot)
        else
            warn("startKillbotLoop: killbot_loop_status[bot_name] for", bot, "returned nil")
        end
    else
        warn("startKillbotLoop: getKillBotTable for", bot, "returned nil")
    end
end

local function attemptToEndKillbotLoop(bot: luauInstance)
    local bot_name = bot.name
    local killbot_table = getKillBotTable(bot)
    local loop_status = killbot_loop_status[bot_name]
    if killbot_table then
        if loop_status then
            loop_status.can_loop = false
        else
            warn("attemptToEndKillbotLoop: killbot_loop_status[bot_name] for", bot, "returned nil")
        end
    else
        warn("attemptToEndKillbotLoop: getKillBotTable for", bot, "returned nil")
    end
end


local function setupKillBotOnSpawn(bot: luauInstance)
    local bot_name = bot.name
    local killbot_table = current_killbots[bot_name] or setupKillBotTable(bot)

    -- give bot weapon
    print("setupKillBotOnSpawn(", bot, "): giving bot weapon")
    if killbot_table.combat_properties then
        if killbot_table.combat_properties.weapon == "knife" then
            local slot_code = "primary"
            local weapon_code = "M11_EOD"
            local setup_data = "[]" -- empty JSON array means no setup
            bot.set_weapon(slot_code, weapon_code, setup_data)
        -- elseif killbot_table.combat_properties.weapon == "monster-instakill" then
            -- do stuff
        end

        -- reset all bot timers if needed
        if killbot_table.combat_properties.next_hit_timer then
            killbot_table.combat_properties.next_hit_timer.primed = true
            killbot_table.combat_properties.next_hit_timer.timer:reset()
        end
    else
        warn("hey you broke something in ".. bot_name.. "'s killbot_table (killbot_table.combat_properties = nil)")
    end

    print("setupKillBotOnSpawn(", bot, "): resetting movement states")
    -- reset any movement states
    if killbot_table.movement then
        killbot_table.movement.moving = false
        killbot_table.movement.lingering = false
        killbot_table.movement.chasing = false
        killbot_table.movement.next_linger_delay = nil -- do something here
        killbot_table.movement.next_position = nil
    end

    print("setupKillBotOnSpawn(", bot, "): resetting detection states")
    -- reset any detection states
    if killbot_table.detection then
        killbot_table.detection.detected_player = false
        killbot_table.detection.player_detected = nil
    end

    print("setupKillBotOnSpawn(", bot, "): resetting combat states")
    -- reset any combat states
    if killbot_table.combat then
        killbot_table.combat.attacking = false
    end

    -- configure bot properties
    bot.bot.set_behavior("BaseBehavior")

    print("setupKillBotOnSpawn(", bot, "): activating killbot loop")
    if killbot_table.runtime_loop then
        killbot_table.runtime_loop.currently_looping = true
    end

    startKillbotLoop(bot)
end

-- \\ Event functions
local function on_bot_spawned(bot: luauInstance)
    local bot_name = bot.name
    if current_killbots[bot_name] then
        print("on_bot_spawned(", bot, ")")
        setupKillBotOnSpawn(bot)
    end
end

local function on_bot_died(bot: luauInstance)
    local bot_name = bot.name
    if current_killbots[bot_name] then
        print("on_bot_died(", bot, ")")
        attemptToEndKillbotLoop(bot)
    end
end

local function on_bot_joined(bot: luauInstance)
    -- create the killbot
    print("on_bot_joined(", bot, ")")
    setupKillBotTable(bot)
    bot.set_model("mistake_mistake_set")
end

local function onPlayerSpawned(name: string)
    local player = players.get(name)
    if player then
        if player.is_bot() then
            on_bot_spawned(player)
        end
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerDied(name, death_position, killer_data, stats_counted)
    local player = players.get(name)
    if player then
        if player.is_bot() then
            on_bot_died(player)
        end
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerJoined(name)
    local player = players.get(name)
    if player then
        -- stuff
        if player.is_bot() then
            on_bot_joined(player)
        end
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