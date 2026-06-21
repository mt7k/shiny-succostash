-- TODOS: finish sv replication
-- # Server Autorun
local branch = "main"
if shared.isLoadingPreMainBranch == true then
    branch = "pre-main"
end

local domain = "https://raw.githubusercontent.com/mt7k/shiny-succostash/refs/heads/".. branch.. "/"
set_require_domain(domain)

local server_module = {}
local gameplay_module = {}

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

-- Modules
local PLAYER_SETUP_CODES = require("deadline_monster_setup_codes.luau")
local SERVER_SOUNDS = require("deadline_monster_sounds.luau")
local UTILITY = require("deadline_monster_global_utility.luau")

-- Constants
local MAP_CONFIG = {gamemode = "NONE", is_day = false, lights_out = true, map = "test_nuristan", time = 0}
local MAP_PRESET = "darkworld"
local MONSTER_COUNT = 0
local ENEMY_BOT_COUNT = 0
local HORROR_SOUND_PROPERTIES = SERVER_SOUNDS:getPhysicalSoundPropertyTables()
local shared_restore_prefix = "RESTORE"
-- local CHAT_COMMAND_PREFIX = ":"

-- Variables
local player_setup_ignore_list = {} --:: {[string]: {["primary" | "secondary"]: {string}}}
local ambience_timers = {
    horror_ambience_blip = {
        timer = Timer.new(0):: Timer,
        time_range = NumberRange.new(90, 120),
        primed = false
    },
    physical_horror_ambience_no_loop = {
        timer = Timer.new(0):: Timer,
        time_range = NumberRange.new(30, 60),
        primed = false
    },
    physical_horror_blip_behind_player = {
        timer = Timer.new(0):: Timer,
        time_range = NumberRange.new(60, 180),
        primed = false
    },
    physical_horror_blip_hovering = {
        timer = Timer.new(0):: Timer,
        time_range = NumberRange.new(120, 240),
        primed = false
    },
    physical_horror_ambience_far_away = {
        timer = Timer.new(0):: Timer,
        time_range = NumberRange.new(45, 90),
        primed = false
    },
}:: {[string]: TimerSettings}

-- Functions
-- \\ Server Module
local function removeAllMapAmbience()
    -- Non-functional
    for name, preset in config.sound_presets do
        shared[shared_restore_prefix.. "_".. name] = preset
        for i, v in preset do
            preset[i] = nil
        end
    end
end

function server_module:getAllServerSharedVariables()
    local variables = {} :: {[string]: any}
    for i: string, v: any in shared do
        if i:find("sv_") ~= nil then
            local index_no_prefix = i:sub(4)
            variables[index_no_prefix] = v
        end
    end

    return variables
end

function server_module:giveAllServerSharedVariablesToPlayer(player: luauInstance)
    local variables = self:getAllServerSharedVariables()

    for i, v in variables do
        local event_args = {
            action = "setServerSharedVariable", 
            sv_name = i,
            sv_value = v
        } :: clientEventArguments

        player.fire_client(event_args)
    end
end

function server_module:setServerSharedVariable(name: string, value: any)
    local sv_name = "sv_".. name
    shared[sv_name] = value

    local event_args = {
        action = "setServerSharedVariable", 
        sv_name = name,
        sv_value = value
    } :: clientEventArguments

    for i, player in players.get_all() do
        if not player.is_bot() then
            player.fire_client(event_args)
        end
    end

    return shared[sv_name]
end

function server_module:getServerSharedVariable(name: string)
    local sv_name = "sv_".. name
    
    return shared[sv_name]
end

-- \\ Setup Handling Functions
local function addToSetupIgnoreList(playerName: string, weaponCode: string, setupCode: string)
    local t = player_setup_ignore_list[playerName]
    if t then
        local t_slot = t[weaponCode]
        if t_slot then
            table.insert(t_slot, setupCode)
        else
            warn("addToSetupIgnoreList: player_setup_ignore_list[".. playerName.. "][".. weaponCode.."] is nil")
        end
    else
        warn("addToSetupIgnoreList: player_setup_ignore_list[".. playerName.. "] is nil")
    end
end

local function setupIgnoreListContainsGun(playerName: string, weaponCode: string, setupCode: string)
    local contains = false
    local t = player_setup_ignore_list[playerName]
    if t then
        local t_slot = t[weaponCode]
        if t_slot then
            if table.find(t_slot, setupCode) then
                contains = true
            end
        else
            warn("addToSetupIgnoreList: player_setup_ignore_list[".. playerName.. "][".. weaponCode.."] is nil")
        end
        
    else
        warn("setupIgnoreListContainsGun: player_setup_ignore_list[".. playerName.. "] is nil")
    end

    return contains
end

local function resetSetupIgnoreList(playerName: string, weaponCode: string)
    if weaponCode then
        local t = player_setup_ignore_list[playerName]
        if t then
            t[weaponCode] = {}
        else
            warn("resetSetupIgnoreList: player_setup_ignore_list[".. playerName.. "] is nil")
        end
    else
        if player_setup_ignore_list[playerName] then
            player_setup_ignore_list[playerName] = {}
        else
            warn("resetSetupIgnoreList: player_setup_ignore_list[".. playerName.. "] is nil")
        end
    end
end

local function getRandomSetupCode(slot_code: string, player: luauInstance | string): (string, string)
    slot_code = slot_code:lower()

    local setup_code = nil
    local weapon_code = nil

    local setups_table = PLAYER_SETUP_CODES[slot_code]
    if setups_table then
        local random_number = math.random(1, #setups_table)
        local setup = setups_table[random_number]
        
        if player then
            local ignore_list = server_module:getPlayerSetupIgnoreList(player)
            if #ignore_list[slot_code] >= #PLAYER_SETUP_CODES[slot_code] then
                resetSetupIgnoreList(player, slot_code)
            end

            local success = false
            local index = 0
            
            repeat
                if setup then
                    setup_code = setup["SetupCode"]
                    weapon_code = setup["WeaponCode"]

                    if setupIgnoreListContainsGun(player, slot_code, setup["SetupCode"]) == false then
                        addToSetupIgnoreList(player, slot_code, setup["SetupCode"])
                        success = true
                    else
                        random_number = math.random(1, #setups_table)
                        setup = setups_table[random_number]
                    end
                else
                    error("Something went seriously wrong while looking for a random setup code")
                end

                index += 1
            until success == true or index > 30
        else
            if setup then
                setup_code = setup["SetupCode"]
                weapon_code = setup["WeaponCode"]
            else
                error("Something went seriously wrong while looking for a random setup code")
            end
        end
    else
        error("Weapon table \""..  slot_code.. "\" not found in PLAYER_SETUP_CODES")
    end

    return setup_code, weapon_code
end

function server_module:getPlayerSetupIgnoreList(playerName: string)
    -- IF NOT found, create it
    local t = nil
    if player_setup_ignore_list[playerName] then
        t = player_setup_ignore_list[playerName]
    else
        player_setup_ignore_list[playerName] = {
            primary = {},
            secondary = {}
        }
        t = player_setup_ignore_list[playerName]
    end

    return t
end

function server_module:setSlotToSetupFromCode(player: luauInstance, slot_code: string, weapon_code: string, setup_string: string)
    local setup = weapons.get_setup_from_code(setup_string)
    local setup_data = "[]" -- blank JSON array to fall back on if setup code is invalid

    if setup.status ~= "_" then
        warn("setup", setup, "is not valid")
    else
        setup_data = setup.data.data
    end

    player.set_weapon(slot_code, weapon_code, setup_data)
end

function server_module:setPlayerModelToTeamModel(player: luauInstance)
    local team = player.get_team()
    local model_set = "main"
    if team == "attacker" then
        model_set = "orchids_pbr_set"
    elseif team == "defender" then
        model_set = "main_backup"
    end

    player.set_model(model_set)
end

local function on_bot_spawned(player: string)
    -- player.bot.set_behavior("FireAtNearestPlayerBehavior")
    player.equip_weapon("primary", true)
end

function server_module.sendSpookyFace()
    -- does not work due to chat filtering
    --[[
    split = FACES["Two"]:split("\n")
    for i, line in split do
        chat.send_announcement(line, Color3.fromRGB(255, 0, 0))
    end
    ]]
end

local function createEntities()
    -- Monster Spawning
    if MONSTER_COUNT > 0 then
        for i = 1, MONSTER_COUNT, 1 do
            spawning.monster()
        end
    end

    -- Bot spawning
    if ENEMY_BOT_COUNT > 0 then
        for i = 1, ENEMY_BOT_COUNT, 1 do
            spawning.bot()
        end
    end
    
    -- Bot property changes
    for _, player in players.get_all() do
        if player.is_bot() then
            player.set_team('attacker')
        end
    end
end

-- \\ Gameplay Module
function gameplay_module:reloadAllBotWeapons()
    for _, player in players.get_all() do
        if player.is_bot() then
            task.spawn(function()
                local active_slot = player.get_active_slot()
                if active_slot then
                    local player_weapon = player.get_weapon_data_from_character(active_slot)
                    local server_ammo_table = player_weapon.ammo
                    local client_ammo_table = player_weapon.client_data.ammo
                    if server_ammo_table.rounds_in_magazine <= 0 then
                        if not server_ammo_table.is_round_chambered and server_ammo_table.is_round_chambered_spent then
                            local most_filled_magazine_index: string
                            local magazine_count = (function()
                                local count = 0
                                for i: string, mag: number in server_ammo_table.loose_magazines do
                                    count += 1
                                    
                                    if most_filled_magazine_index then
                                        if server_ammo_table.loose_magazines[most_filled_magazine_index] < mag then
                                            most_filled_magazine_index = i
                                        end
                                    else
                                        most_filled_magazine_index = i
                                    end
                                end

                                return count
                            end)

                            if magazine_count > 0 then
                                -- initiate reload sequence
                                local next_magazine = most_filled_magazine_index
                                local current_magazine = server_ammo_table.rounds_in_magazine

                                task.wait(2.5)

                                server_ammo_table.rounds_in_magazine = server_ammo_table.loose_magazines[next_magazine]
                                server_ammo_table.loose_magazines[next_magazine] = current_magazine

                                client_ammo_table.rounds_in_magazine = server_ammo_table.loose_magazines[next_magazine]
                                client_ammo_table.loose_magazines[next_magazine] = current_magazine
                            end
                        end
                    end
                end
            end)
        end
    end
end

local function GameLoopStartingVariableChanges()
    sharedvars.sv_spawning_enabled = false
    chat.set_spawning_disabled_reason("Be patient.")
end

local function gameLoop()
    while server_module:getServerSharedVariable("isGameActive") do
        GameLoopStartingVariableChanges()

        task.wait(15) -- Cooldown before game starts

        sharedvars.sv_spawning_enabled = true
        chat.set_spawning_disabled_reason("You cannot spawn right now.")

        task.wait(100)
    end
end

local function checkSoundTimer(category: string)
    if ambience_timers[category] then
        local soundTimer = ambience_timers[category]

        print("----------------\ncategory:", category)
        print(ambience_timers[category], "\nexpired =", soundTimer.timer:expired(), "\nprimed =", soundTimer.primed)
        if soundTimer.timer:expired() == true and soundTimer.primed == true then
            ambience_timers[category].primed = false
            print("\nnew primed =", soundTimer.primed)

            local audioDuration = SERVER_SOUNDS:createAmbience(category)
            local new_timeout = math.random(soundTimer.time_range.Min, soundTimer.time_range.Max)
            ambience_timers[category].timer.timeout = new_timeout

            print("timeout:", new_timeout)
            print("audio duration:", audioDuration)
            print("total wait time:", new_timeout + audioDuration)
            task.wait(new_timeout + audioDuration)
            
            ambience_timers[category].timer:reset()
        end

        ambience_timers[category].primed = true
    end
end

local function ambienceLoop()
    while server_module:getServerSharedVariable("isAmbienceActive") do
        for category: string, _ in ambience_timers do
            task.spawn(checkSoundTimer, category)
        end

        task.wait(2)
    end
end

function gameplay_module.startGameLoop()
    if not server_module:getServerSharedVariable("isGameActive") then
        server_module:setServerSharedVariable("isGameActive", true)
        gameLoop()
    end
end

function gameplay_module.attemptToEndAmbienceLoop()
    server_module:setServerSharedVariable("isAmbienceActive", false)
end

function gameplay_module.startAmbienceLoop()
    if not server_module:getServerSharedVariable("isAmbienceActive") then
        server_module:setServerSharedVariable("isAmbienceActive", true)
        ambienceLoop()
    end
end

function gameplay_module.attemptToEndGameLoop()
    server_module:setServerSharedVariable("isGameActive", false)
end

-- Event functions
local function onPlayerSpawned(name: string)
    local player = players.get(name)
    if player then
        -- local team = player.get_team()
        server_module:setPlayerModelToTeamModel(player)

        local primary_setup_code, primary_weapon_code = getRandomSetupCode("primary", name)
        local secondary_setup_code, secondary_weapon_code = getRandomSetupCode("secondary", name)

        server_module:setSlotToSetupFromCode(player, "primary", primary_weapon_code, primary_setup_code)
        server_module:setSlotToSetupFromCode(player, "secondary", secondary_weapon_code, secondary_setup_code)

        if player.is_bot() then
            task.spawn(on_bot_spawned, player)
        else
            server_module:giveAllServerSharedVariablesToPlayer(player)
        end
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerDied(name, death_position, killer_data, stats_counted)
    local player = players.get(name)
    if player then
        if killer_data["type"] == "monster" then
            local death_sound_properties = HORROR_SOUND_PROPERTIES["death_monster"]
            death_sound_properties["id"] = SERVER_SOUNDS:getRandomSoundID("death_monster")
            death_sound_properties["position"] = death_position

            SERVER_SOUNDS:insertPhysicalSoundToWorkspace(death_sound_properties)
        end
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerJoined(name)
    local player = players.get(name)
    if player then
        server_module:setPlayerModelToTeamModel(player)
        server_module:getPlayerSetupIgnoreList(name)
        if not player.is_bot() then
            server_module:giveAllServerSharedVariablesToPlayer(player)
        end
    else
        warn("player could not be referenced:", name)
    end

    chat.send_ingame_notification(string.format("%s has joined the server.", name))
end

local function onPlayerLeft(name)
    print("player left:", name)
    chat.send_ingame_notification(string.format("%s has left the server.", name))
end

local function playerChatted(sender, channel, content)
    print(sender, channel, content)
end

local function onClientEvent(playerName: string, data: {any | serverEventArguments?})
    local playerInstance = players.get(playerName)
    local args = data[1] -- why? idk

    if args.action == "fetchCurrentServerVariables" then
        server_module:giveAllServerSharedVariablesToPlayer(playerInstance)
    end
end

-- Runtime
-- \\ Removing Sound Presets (doesnt work right now)
removeAllMapAmbience()

-- Character Property Changes
-- \\ Appearance
sharedvars.plr_model = "main_backup"
sharedvars.plr_nv_color = Color3.fromRGB(224, 255, 255)
sharedvars.plr_enable_markers = false
-- \\ Movement
sharedvars.plr_fall_damage = false
sharedvars.plr_jump_multiplier = 0.875
sharedvars.plr_jump_frequency = 0.5
sharedvars.plr_speed = 1.05
-- \\ Movement Restrictions
sharedvars.plr_stamina_regen = 0.25
sharedvars.plr_stamina_jump_drain = 1.25
sharedvars.plr_stamina_lean_drain = 0.325
sharedvars.plr_stamina_run_drain = 0.25
sharedvars.plr_stamina_shake_multiplier = 0.75
sharedvars.plr_max_stamina = 240
sharedvars.plr_vault_stamina_drain = 1.75
-- \\ Utility Modifications
sharedvars.plr_grenade_throw_strength = 0.95
sharedvars.plr_shove_headshot_damage = 105
-- \\ Weapon Modifications
sharedvars.plr_drum_magazines = 3
sharedvars.plr_magazines = 7
-- \\ Weapon Performance
sharedvars.plr_max_arm_stamina = 75
sharedvars.plr_arm_stamina_drain = 6
sharedvars.plr_arm_stamina_drain_hold_breath = 6
sharedvars.plr_arm_stamina_regen = 9
sharedvars.plr_arm_stamina_regen_crouch = 3.75
sharedvars.plr_explosion_blast_pressure = 0
sharedvars.plr_explosion_damage_multiplier = 0
sharedvars.plr_weapon_clamp_stats_values = false
-- \\ Miscellaneous
sharedvars.plr_instant_lobby_return_time = 30
sharedvars.plr_enable_gangsta_control = false

-- Game Property Changes
-- \\ Anti-cheat
sharedvars.ac_movement = false
-- \\ Messages & Chat
chat.set_join_message("The monster is hunting.")
chat.set_spawning_disabled_reason("Be patient.")
sharedvars.chat_announce_changes = false
sharedvars.chat_tips_enabled = false
sharedvars.chat_max_history = 200
-- \\ Gameplay Restrictions
sharedvars.editor_mount_anything = true
sharedvars.gm_team_balancing_threshold = 1000
sharedvars.sv_spawning_enabled = false
-- \\ Environment
map.set_map_from_config(MAP_CONFIG)
map.set_preset(MAP_PRESET)
map.kill_map_lights()
sharedvars.voxel_bullet_destruction_radius = 1
-- \\ Custom Server Variables
server_module:setServerSharedVariable("monsterShieldsEnabled", true)
server_module:setServerSharedVariable("isGameActive", false)

-- Preload server audios
SERVER_SOUNDS:preloadAllAudio()

-- Start the game, spawn the monster(s).
-- \\ Spawn Entities
task.spawn(createEntities)

-- \\ Runtime Loops
task.spawn(gameplay_module.startGameLoop)
task.spawn(gameplay_module.startAmbienceLoop)

-- Events
-- \\ Run on_player_joined on players that are in the game before this autorun executes
for i, player in players.get_all() do
    local name = player.name
    onPlayerJoined(name)
end

on_player_spawned:Connect(onPlayerSpawned)
on_player_died:Connect(onPlayerDied)
on_player_joined:Connect(onPlayerJoined)
on_player_left:Connect(onPlayerLeft)
chat.player_chatted:Connect(playerChatted)
on_client_event:Connect(onClientEvent)

shared["server_module"] = server_module

return server_module