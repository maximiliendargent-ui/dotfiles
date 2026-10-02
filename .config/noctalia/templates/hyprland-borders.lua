-- Généré par Noctalia à partir du fond d'écran : ne pas modifier à la main
hl.config({
    general = {
        col = {
            active_border = {
                colors = {
                    "rgba({{colors.primary.default.hex_stripped}}ff)",
                    "rgba({{colors.tertiary.default.hex_stripped}}ff)",
                },
                angle = 45,
            },
            inactive_border = "rgba({{colors.outline.default.hex_stripped}}aa)",
        },
    },
    group = {
        col = {
            border_active = "rgba({{colors.primary.default.hex_stripped}}ff)",
            border_inactive = "rgba({{colors.outline.default.hex_stripped}}aa)",
            border_locked_active = "rgba({{colors.tertiary.default.hex_stripped}}ff)",
            border_locked_inactive = "rgba({{colors.outline.default.hex_stripped}}aa)",
        },
        groupbar = {
            text_color = "rgba({{colors.on_primary.default.hex_stripped}}ff)",
            text_color_inactive = "rgba({{colors.on_surface_variant.default.hex_stripped}}ff)",
            text_color_locked_active = "rgba({{colors.on_tertiary.default.hex_stripped}}ff)",
            text_color_locked_inactive = "rgba({{colors.on_surface_variant.default.hex_stripped}}ff)",
            col = {
                active = "rgba({{colors.primary.default.hex_stripped}}ff)",
                inactive = "rgba({{colors.surface_container_high.default.hex_stripped}}ff)",
                locked_active = "rgba({{colors.tertiary.default.hex_stripped}}ff)",
                locked_inactive = "rgba({{colors.surface_container_high.default.hex_stripped}}ff)",
            },
        },
    },
})
