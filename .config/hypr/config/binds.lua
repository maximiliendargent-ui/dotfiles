-- Raccourcis façon Caelestia, adaptés à Noctalia et à la config CachyOS
-- (basé sur le binds.lua de CachyOS et le variables.lua de Caelestia)

local mainMod = "SUPER"
local noctCall = "noctalia msg "
local launchPrefix = "uwsm app -- " -- si tu n'utilises pas UWSM, mets ""

-- AZERTY : les touches de la rangée des chiffres produisent & é " ' ... sans Shift,
-- on les lie donc par code physique. Chiffre d -> keycode : 1..9 => 10..18, 0 => 19
local function digitCode(d)
    return "code:" .. (d == 0 and 19 or (9 + d))
end

local function app(cmd)  return hl.dsp.exec_cmd(launchPrefix .. cmd) end
local function noct(cmd) return hl.dsp.exec_cmd(noctCall .. cmd) end

local locked           = { locked = true }
local repeating        = { repeating = true }
local locked_repeating = { locked = true, repeating = true }

-----------------
---- LANCEUR ----
-----------------

-- Appui simple sur Super (comme Caelestia) + Super + Espace (comme CachyOS)
hl.bind(mainMod .. " + SUPER_L",  noct("panel-toggle launcher"), { release = true })
hl.bind(mainMod .. " + Space",    noct("panel-toggle launcher"))

----------------------
---- APPLICATIONS ----
----------------------

hl.bind(mainMod .. " + T",           app(TERMINAL))
hl.bind(mainMod .. " + Return",      app(TERMINAL))
hl.bind(mainMod .. " + W",           app(BROWSER))
hl.bind(mainMod .. " + C",           app(EDITOR))
hl.bind(mainMod .. " + E",           app(FILE_MANAGER))
hl.bind("CTRL + ALT + V",            app("pwvucontrol"))
hl.bind("CONTROL + SHIFT + Escape",  app(TERMINAL .. " -e btop"))
hl.bind("XF86Calculator",            app(CALCULATOR))

-----------------
---- FENÊTRES ----
-----------------

hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + ALT + F",     hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P",           hl.dsp.window.pin())
hl.bind("CTRL + SUPER + Backslash",  hl.dsp.window.center())
hl.bind(mainMod .. " + J",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + Escape",      hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + Tab",         noct("window-switcher"))

-- Focus et déplacement avec les flèches
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    local key = dir:sub(1, 1):upper() .. dir:sub(2)
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ direction = dir:sub(1, 1) }))
end

-- Déplacer / redimensionner à la souris
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Parcourir les fenêtres
hl.bind("ALT + TAB",         hl.dsp.window.cycle_next(), repeating)
hl.bind("SHIFT + ALT + TAB", hl.dsp.window.cycle_next({ next = false }), repeating)

-- Groupes de fenêtres
hl.bind("CTRL + ALT + TAB",           hl.dsp.group.next(), repeating)
hl.bind("CTRL + SHIFT + ALT + TAB",   hl.dsp.group.prev(), repeating)
hl.bind(mainMod .. " + Comma",        hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + Comma", hl.dsp.group.lock_active())
hl.bind(mainMod .. " + U",            hl.dsp.window.move({ out_of_group = true }))

-------------------------------
---- ESPACES DE TRAVAIL ----
-------------------------------

-- Super + chiffre : aller à l'espace ; Super + Alt + chiffre : y envoyer la fenêtre
for i = 1, 10 do
    local key = digitCode(i % 10)
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + ALT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Espace précédent / suivant
hl.bind(mainMod .. " + mouse_down",   hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + mouse_up",     hl.dsp.focus({ workspace = "-1" }))
hl.bind("CTRL + SUPER + Right",       hl.dsp.focus({ workspace = "+1" }), repeating)
hl.bind("CTRL + SUPER + Left",        hl.dsp.focus({ workspace = "-1" }), repeating)
hl.bind(mainMod .. " + Page_Down",    hl.dsp.focus({ workspace = "+1" }), repeating)
hl.bind(mainMod .. " + Page_Up",      hl.dsp.focus({ workspace = "-1" }), repeating)

-- Envoyer la fenêtre à l'espace précédent / suivant
hl.bind(mainMod .. " + ALT + mouse_down",   hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + ALT + mouse_up",     hl.dsp.window.move({ workspace = "-1" }))
hl.bind(mainMod .. " + ALT + Page_Down",    hl.dsp.window.move({ workspace = "+1" }), repeating)
hl.bind(mainMod .. " + ALT + Page_Up",      hl.dsp.window.move({ workspace = "-1" }), repeating)
hl.bind("CTRL + SUPER + SHIFT + Right",     hl.dsp.window.move({ workspace = "+1" }), repeating)
hl.bind("CTRL + SUPER + SHIFT + Left",      hl.dsp.window.move({ workspace = "-1" }), repeating)

-- Espace spécial (scratchpad)
hl.bind(mainMod .. " + S",               hl.dsp.workspace.toggle_special())
hl.bind(mainMod .. " + ALT + S",         hl.dsp.window.move({ workspace = "special" }))
hl.bind("CTRL + SUPER + SHIFT + Up",     hl.dsp.window.move({ workspace = "special" }))
hl.bind("CTRL + SUPER + SHIFT + Down",   hl.dsp.window.move({ workspace = "e+0" }))

--------------------------
---- SHELL NOCTALIA ----
--------------------------

hl.bind(mainMod .. " + L",         noct("session lock"))
hl.bind("CTRL + ALT + Delete",     noct("panel-toggle session"))
hl.bind(mainMod .. " + N",         noct("panel-toggle control-center notifications"))
hl.bind(mainMod .. " + K",         noct("panel-toggle control-center"))
hl.bind(mainMod .. " + Z",         noct("settings-toggle"))
hl.bind(mainMod .. " + SHIFT + W", noct("panel-toggle wallpaper"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), locked)

-- Presse-papiers et emojis
hl.bind(mainMod .. " + V",      noct("panel-toggle clipboard"))
hl.bind(mainMod .. " + Period", noct("panel-toggle launcher /emo"))

-------------------
---- CAPTURES ----
-------------------

hl.bind("Print",                         noct("screenshot-fullscreen"))
hl.bind(mainMod .. " + SHIFT + S",       noct("screenshot-region"))
hl.bind(mainMod .. " + SHIFT + ALT + S", noct("screenshot-region"))
hl.bind(mainMod .. " + SHIFT + C",       hl.dsp.exec_cmd("hyprpicker -a -n"))

------------------------
---- SON ET MÉDIAS ----
------------------------

hl.bind("XF86AudioRaiseVolume",    noct("volume-up"),   locked_repeating)
hl.bind("XF86AudioLowerVolume",    noct("volume-down"), locked_repeating)
hl.bind("XF86AudioMute",           noct("volume-mute"), locked)
hl.bind(mainMod .. " + SHIFT + M", noct("volume-mute"), locked)
hl.bind("XF86AudioMicMute",        noct("mic-mute"),    locked)

hl.bind("XF86AudioPlay",           noct("media toggle"),   locked)
hl.bind("XF86AudioPause",          noct("media toggle"),   locked)
hl.bind("CTRL + SUPER + Space",    noct("media toggle"),   locked)
hl.bind("XF86AudioNext",           noct("media next"),     locked)
hl.bind("CTRL + SUPER + Equal",    noct("media next"),     locked)
hl.bind("XF86AudioPrev",           noct("media previous"), locked)
hl.bind("CTRL + SUPER + Minus",    noct("media previous"), locked)

-- Luminosité
hl.bind("XF86MonBrightnessUp",   noct("brightness-up"),   locked_repeating)
hl.bind("XF86MonBrightnessDown", noct("brightness-down"), locked_repeating)
