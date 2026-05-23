-- # Server Autorun
local branch = "main"
if shared.isLoadingPreMainBranch == true then
    branch = "pre-main"
end

local domain = "https://raw.githubusercontent.com/mt7k/shiny-succostash/refs/heads/".. branch.. "/"
set_require_domain(domain)

local server_module = {}
local gameplay_module = {
    isGameActive = false
}

-- Type Aliases
type luauInstance = {}

-- Modules
local PLAYER_SETUP_CODES = require("deadline_monster_setup_codes.luau")
local SERVER_SOUNDS = require("deadline_monster_sounds.luau")
local SERVER_SOUNDS = require("deadline_monster_utility.luau")

-- Constants
local MAP_CONFIG = {gamemode = "NONE", is_day = false, lights_out = true, map = "test_nuristan", time = 0}
local MAP_PRESET = "darkworld"
local MONSTER_COUNT = 0
local ENEMY_BOT_COUNT = 20
-- local CHAT_COMMAND_PREFIX = ":"

-- Variables
local player_setup_ignore_list = {} --:: {[string]: {["primary" | "secondary"]: {string}}}

-- Functions
-- \\ Server Module
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
                print("setupIgnoreListContainsGun: found", setupCode, "in", playerName.. "'s", weaponCode, "setup ignore list")
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
            warn("resetSetupIgnoreList: reset", playerName.. "'s setup ignore list")
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
            local active_slot = player.get_active_slot()
            if active_slot then
                local player_weapon = player.get_weapon_data_from_character(active_slot)
                if player_weapon.xyz then

                end
            end
        end
    end
end

local function gameLoopStep()
    task.wait(15)
end

function gameplay_module.startGameLoop()
    if not gameplay_module.isGameActive then
        gameplay_module.isGameActive = true
        while gameplay_module.isGameActive do
            gameLoopStep()
        end
    end
end

function gameplay_module.attemptToEndGameLoop()
    gameplay_module.isGameActive = false
end

-- Event functions
local function onPlayerSpawned(name: string)
    print("player spawned:", name)
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
        end
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerDied(name, death_position, killer_data, stats_counted)
    local player = players.get(name)
    if player then
        if true then -- killer_data["type"] == "monster" then
            local death_sound_id = SERVER_SOUNDS:selectRandomIDFromCategory("death_monster")

            local death_sound_properties = {
                id = death_sound_id,
                volume = 2.75,
                speed = 1,
                max_distance = 20,
                min_distance = 0,
                position = death_position,
            }

            SERVER_SOUNDS:insertPhysicalSoundToWorkspace(death_sound_properties)
        end
    else
        warn("player could not be referenced:", name)
    end
end

local function onPlayerJoined(name)
    print("player joined:", name)
    local player = players.get(name)
    if player then
        server_module:setPlayerModelToTeamModel(player)
        server_module:getPlayerSetupIgnoreList(name)
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

-- Runtime
-- Character Property Changes
sharedvars.plr_explosion_blast_pressure = 0;
sharedvars.plr_explosion_damage_multiplier = 0;
sharedvars.plr_model = "main_backup"
sharedvars.plr_nv_color = Color3.fromRGB(224, 255, 255)
sharedvars.plr_fall_damage = false
sharedvars.plr_enable_markers = false
sharedvars.plr_jump_multiplier = 0.85
sharedvars.plr_jump_frequency = 0.25
sharedvars.plr_stamina_run_drain = 0.25
sharedvars.plr_stamina_regen = 0.05
sharedvars.plr_speed = 1.05
sharedvars.plr_weapon_clamp_stats_values = false

-- Game Property Changes
chat.set_join_message("The monster is hunting.")
chat.set_spawning_disabled_reason("Be patient.")
sharedvars.ac_movement = false
sharedvars.chat_announce_changes = false
sharedvars.chat_tips_enabled = false
sharedvars.chat_max_history = 200
sharedvars.editor_mount_anything = true
sharedvars.gm_team_balancing_threshold = 1000
sharedvars.sv_spawning_enabled = false
sharedvars.voxel_bullet_destruction_radius = 1
map.set_map_from_config(MAP_CONFIG)
map.set_preset(MAP_PRESET)
map.kill_map_lights()

-- Preload server audios
SERVER_SOUNDS:preloadAllAudio()

-- Cooldown before game starts
task.wait(10)

-- Start the game, spawn the monster(s).
sharedvars.sv_spawning_enabled = true
chat.set_spawning_disabled_reason("You cannot spawn right now.")

-- Spawn Entities
task.spawn(createEntities)

-- While Loop
task.spawn(gameplay_module.startGameLoop)

-- Events
on_player_spawned:Connect(onPlayerSpawned)
on_player_died:Connect(onPlayerDied)
on_player_joined:Connect(onPlayerJoined)
on_player_left:Connect(onPlayerLeft)
chat.player_chatted:Connect(playerChatted)

shared["server_module"] = server_module

return server_module