-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Nom de la sortie : hyprctl monitors. HDMI-A-1 est aussi écrit dans workspaces.lua et windowrules.lua (grep -rn HDMI-A-1)
-- hl.monitor({
--     output    = "HDMI-A-1",
--     mode      = "1920x1080@60",
--     position  = "0x0",
--     scale     = "1",
-- })

hl.monitor({
    output    = "HDMI-A-1",
    mode      = "1920x1080@165",
    position  = "0x0",
    scale     = "1",
})
