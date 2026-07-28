local sharedvar_module = {}

local CHANGED_VARIABLES = {
    -- Bot Property Changes
    bot_target_reach_distance = 3,
    sv_bot_auto_spawning_enabled = false,

    -- Character Property Changes
    -- \\ Appearance
    plr_model = "main_backup",
    plr_nv_color = Color3.fromRGB(224, 255, 255),
    plr_enable_markers = false,
    -- \\ Movement
    plr_fall_damage = false,
    plr_jump_multiplier = 0.875,
    plr_jump_frequency = 0.5,
    plr_speed = 1.05,
    -- \\ Movement Restrictions
    plr_stamina_regen = 0.25,
    plr_stamina_jump_drain = 1.25,
    plr_stamina_lean_drain = 0.325,
    plr_stamina_run_drain = 0.25,
    plr_stamina_shake_multiplier = 0.75,
    plr_max_stamina = 240,
    plr_vault_stamina_drain = 1.75,
    -- \\ Utility Modifications
    plr_grenade_throw_strength = 0.95,
    plr_shove_headshot_damage = 105,
    -- \\ Weapon Modifications
    plr_drum_magazines = 3,
    plr_magazines = 7,
    plr_spare_rounds = 60,
    -- \\ Weapon Performance
    plr_max_arm_stamina = 75,
    plr_arm_stamina_drain = 6,
    plr_arm_stamina_drain_hold_breath = 6,
    plr_arm_stamina_regen = 9,
    plr_arm_stamina_regen_crouch = 3.75,
    plr_explosion_blast_pressure = 0,
    plr_explosion_damage_multiplier = 0,
    plr_weapon_clamp_stats_values = false,
    -- \\ Miscellaneous
    plr_instant_lobby_return_time = 30,
    plr_enable_gangsta_control = false,

    -- Game Property Changes
    -- \\ Anti-cheat
    ac_movement = false,
    -- \\ Chat
    chat_announce_changes = false,
    chat_tips_enabled = false,
    chat_max_history = 200,
    -- \\ Gameplay Restrictions
    editor_mount_anything = true,
    gm_team_balancing_threshold = 1000,
    sv_spawning_enabled = false,
    -- \\ Miscellaneous
    sv_force_tracers = true,
    voxel_bullet_destruction_radius = 1,
}

function sharedvar_module:setSharedVariables()
    for name, value in CHANGED_VARIABLES do
        sharedvars[name] = value
    end
end

return sharedvar_module