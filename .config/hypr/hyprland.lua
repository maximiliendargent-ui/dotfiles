-- CachyOS Hyprland Configuration

require("config.animations")
require("config.autostart")
require("config.colors")
require("config.decorations")
require("config.environment")
require("config.inputs")
require("config.binds")
require("config.misc")
require("config.monitors")
require("config.windowrules")
require("config.workspaces")
pcall(require, "config.noctalia_colors")

-- Session « Hyprland (Maison) » (~/.config/uwsm/env-maison) : réglages du shell en construction
if os.getenv("SHELL_MAISON") then
    dofile(os.getenv("HOME") .. "/Projects/shell-maison/hypr/maison.lua")
end
