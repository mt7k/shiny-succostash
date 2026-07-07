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

local CONFIG = {
    -- Chat
    set_join_message = "The monster is hunting.",
    spawn_disabled_reason_intermission = "Be patient.",

    -- Prefixes
    chat_command_prefix = ":",
    shared_restore_prefix = "RESTORE",

    -- TimerSettings
    ambience_timer_ranges = {
        horror_ambience_blip = NumberRange.new(30, 120),
        physical_horror_ambience_no_loop = NumberRange.new(30, 60),
        physical_horror_blip_behind_player = NumberRange.new(60, 180),
        physical_horror_blip_hovering = NumberRange.new(120, 240),
        physical_horror_ambience_far_away = NumberRange.new(45, 90),
    },

    -- Map
    map_config = {gamemode = "NONE", is_day = false, lights_out = true, map = "misc_standard_issue", time = 0},
    map_preset = "darkworld",
    kill_map_lights = true,

    -- Entities
    monster_count = 0,
    enemy_bot_count = 0,

    -- Server Variable Defaults
    monsterShieldsEnabled = false
}
return CONFIG