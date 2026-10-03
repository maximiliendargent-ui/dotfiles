-- Look and feel configuration

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        extend_border_grab_area = 10,
        resize_on_border = true,
        col = {
            active_border = {
                colors = { CACHYLGREEN, CACHYDGREEN },
                angle = 45,
            },
            inactive_border = CACHYGRAY,
        },
    },
    group = {
        col = {
            border_active = CACHYLBLUE,
            border_inactive = CACHYGRAY,
            border_locked_active = CACHYDBLUE,
            border_locked_inactive = CACHYGRAY,
        },
        groupbar = {
            -- Onglets pleins, carrés, dans la police de la barre (couleurs : noctalia_colors.lua)
            font_family = "JetBrainsMono Nerd Font",
            font_size = 10,
            height = 22,
            gradients = true,
            gradient_rounding = 0,
            rounding = 0,
            indicator_height = 0,
            gaps_in = 2,
            gaps_out = 2,
            col = {
                active = CACHYLGREEN,
                inactive = CACHYGRAY,
                locked_active = CACHYDBLUE,
                locked_inactive = CACHYGRAY,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 0,
        active_opacity = 1,
        inactive_opacity = 1,
        fullscreen_opacity = 1,
        blur = {
            enabled = false,
            size = 5,
            passes = 4,
            special = true,
        },
        -- Ombre douce, réservée aux fenêtres flottantes (règle dans windowrules.lua)
        shadow = {
            enabled = true,
            range = 24,
            render_power = 3,
            color = "rgba(00000099)",
        },
    },
})
