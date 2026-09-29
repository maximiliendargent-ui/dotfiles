-- Raccourcis façon Caelestia, adaptés à Noctalia et à la config CachyOS.
-- Chaque raccourci a une description : à chaque chargement de la config,
-- la liste est écrite dans ~/.cache/hypr-keybinds.tsv pour l'aide (Super + K).

local mainMod = "SUPER"
local noctCall = "noctalia msg "
local launchPrefix = "uwsm app -- " -- si tu n'utilises pas UWSM, mets ""
local HOME = os.getenv("HOME")

-- AZERTY : la rangée des chiffres produit & é " ' ... sans Shift,
-- on lie donc par code physique. Chiffre d -> keycode : 1..9 => 10..18, 0 => 19
local function digitCode(d)
    return "code:" .. (d == 0 and 19 or (9 + d))
end

local function app(cmd)  return hl.dsp.exec_cmd(launchPrefix .. cmd) end
local function noct(cmd) return hl.dsp.exec_cmd(noctCall .. cmd) end

local locked           = { locked = true }
local repeating        = { repeating = true }
local locked_repeating = { locked = true, repeating = true }

-- Aide des raccourcis ----------------------------------------------------------
local cheats = {}
local function section(name) cheats[#cheats + 1] = { "", name } end
local function note(key, desc) cheats[#cheats + 1] = { key, desc } end

-- bind(touche, description, action, options) : crée le raccourci et le note dans l'aide.
-- Une description à nil = raccourci non affiché (doublon ou touche multimédia).
local function bind(key, desc, action, flags)
    hl.bind(key, action, flags)
    if desc then note(key, desc) end
end

-----------------
---- LANCEUR ----
-----------------
section("Lanceur")

bind(mainMod .. " + SUPER_L", "Ouvrir le lanceur (appui simple)", noct("panel-toggle launcher"), { release = true })
bind(mainMod .. " + Space",   "Ouvrir le lanceur",                noct("panel-toggle launcher"))
bind(mainMod .. " + K",       "Afficher cette aide",
     hl.dsp.exec_cmd(launchPrefix .. "ghostty --class=dev.keybinds -e " .. HOME .. "/.local/bin/hypr-keybinds"))

----------------------
---- APPLICATIONS ----
----------------------
section("Applications")

bind(mainMod .. " + T",          "Terminal",                 app(TERMINAL))
bind(mainMod .. " + Return",     "Terminal",                 app(TERMINAL))
bind(mainMod .. " + W",          "Navigateur",               app(BROWSER))
bind(mainMod .. " + C",          "Éditeur de code",          app(EDITOR))
bind(mainMod .. " + E",          "Fichiers",                 app(FILE_MANAGER))
bind("CTRL + ALT + V",           "Réglages audio",           app("pwvucontrol"))
bind("CONTROL + SHIFT + Escape", "Moniteur système (btop)",  app(TERMINAL .. " -e btop"))
bind("XF86Calculator",           nil,                        app(CALCULATOR))

------------------
---- FENÊTRES ----
------------------
section("Fenêtres")

bind(mainMod .. " + Q",           "Fermer la fenêtre",                   hl.dsp.window.close())
bind(mainMod .. " + F",           "Plein écran",                         hl.dsp.window.fullscreen())
bind(mainMod .. " + ALT + F",     "Agrandir (garde la barre)",           hl.dsp.window.fullscreen({ mode = 1 }))
bind(mainMod .. " + ALT + Space", "Fenêtre flottante / en mosaïque",     hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + P",           "Épingler sur tous les espaces",       hl.dsp.window.pin())
bind("CTRL + SUPER + Backslash",  "Centrer la fenêtre",                  hl.dsp.window.center())
bind(mainMod .. " + J",           "Basculer la division (horiz./vert.)", hl.dsp.layout("togglesplit"))
bind(mainMod .. " + Escape",      "Forcer la fermeture (cliquer)",       hl.dsp.exec_cmd("hyprctl kill"))
bind(mainMod .. " + Tab",         "Sélecteur de fenêtres",               noct("window-switcher"))

-- Focus et déplacement avec les flèches
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    local key = dir:sub(1, 1):upper() .. dir:sub(2)
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir:sub(1, 1) }))
end
note(mainMod .. " + Flèches",         "Aller à la fenêtre voisine")
note(mainMod .. " + SHIFT + Flèches", "Déplacer la fenêtre")

-- Souris
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())
note(mainMod .. " + clic gauche", "Déplacer la fenêtre à la souris")
note(mainMod .. " + clic droit",  "Redimensionner à la souris")

-- Parcourir les fenêtres
bind("ALT + TAB",         "Fenêtre suivante",   hl.dsp.window.cycle_next(), repeating)
bind("SHIFT + ALT + TAB", "Fenêtre précédente", hl.dsp.window.cycle_next({ next = false }), repeating)

-----------------
---- GROUPES ----
-----------------
section("Groupes")

bind(mainMod .. " + Comma",         "Créer / dissoudre un groupe", hl.dsp.group.toggle())
bind(mainMod .. " + SHIFT + Comma", "Verrouiller le groupe",       hl.dsp.group.lock_active())
bind(mainMod .. " + U",             "Sortir la fenêtre du groupe", hl.dsp.window.move({ out_of_group = true }))
bind("CTRL + ALT + TAB",            "Onglet suivant du groupe",    hl.dsp.group.next(), repeating)
bind("CTRL + SHIFT + ALT + TAB",    "Onglet précédent du groupe",  hl.dsp.group.prev(), repeating)

----------------------------
---- ESPACES DE TRAVAIL ----
----------------------------
section("Espaces de travail")

for i = 1, 10 do
    local key = digitCode(i % 10)
    hl.bind(mainMod .. " + " .. key,       hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i }))
end
note(mainMod .. " + 1 … 0",       "Aller à l'espace 1 à 10")
note(mainMod .. " + ALT + 1 … 0", "Envoyer la fenêtre à l'espace 1 à 10")

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "-1" }))
bind("CTRL + SUPER + Right",    "Espace suivant",   hl.dsp.focus({ workspace = "+1" }), repeating)
bind("CTRL + SUPER + Left",     "Espace précédent", hl.dsp.focus({ workspace = "-1" }), repeating)
bind(mainMod .. " + Page_Down", nil,                hl.dsp.focus({ workspace = "+1" }), repeating)
bind(mainMod .. " + Page_Up",   nil,                hl.dsp.focus({ workspace = "-1" }), repeating)
note(mainMod .. " + molette", "Espace suivant / précédent")

hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(mainMod .. " + ALT + mouse_up",   hl.dsp.window.move({ workspace = "-1" }))
bind(mainMod .. " + ALT + Page_Down", nil, hl.dsp.window.move({ workspace = "+1" }), repeating)
bind(mainMod .. " + ALT + Page_Up",   nil, hl.dsp.window.move({ workspace = "-1" }), repeating)
bind("CTRL + SUPER + SHIFT + Right",  "Envoyer la fenêtre à l'espace suivant",   hl.dsp.window.move({ workspace = "+1" }), repeating)
bind("CTRL + SUPER + SHIFT + Left",   "Envoyer la fenêtre à l'espace précédent", hl.dsp.window.move({ workspace = "-1" }), repeating)

-- Scratchpad
bind(mainMod .. " + S",             "Afficher / cacher le scratchpad",  hl.dsp.workspace.toggle_special())
bind(mainMod .. " + ALT + S",       "Envoyer la fenêtre au scratchpad", hl.dsp.window.move({ workspace = "special" }))
bind("CTRL + SUPER + SHIFT + Up",   nil,                                hl.dsp.window.move({ workspace = "special" }))
bind("CTRL + SUPER + SHIFT + Down", "Sortir la fenêtre du scratchpad",  hl.dsp.window.move({ workspace = "e+0" }))

------------------------
---- SHELL NOCTALIA ----
------------------------
section("Système")

bind(mainMod .. " + L",         "Verrouiller l'écran",                noct("session lock"))
bind("CTRL + ALT + Delete",     "Menu d'alimentation",                noct("panel-toggle session"))
bind(mainMod .. " + SHIFT + L", "Mise en veille",                     hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), locked)
bind(mainMod .. " + N",         "Centre de contrôle / notifications", noct("panel-toggle control-center notifications"))
bind(mainMod .. " + Z",         "Réglages de Noctalia",               noct("settings-toggle"))
bind(mainMod .. " + SHIFT + W", "Changer de fond d'écran",            noct("panel-toggle wallpaper"))
bind(mainMod .. " + V",         "Historique du presse-papiers",       noct("panel-toggle clipboard"))
bind(mainMod .. " + Period",    "Emojis",                             noct("panel-toggle launcher /emo"))

-------------------
---- CAPTURES ----
-------------------
section("Captures")

bind("Print",                         "Capture de l'écran entier", noct("screenshot-fullscreen"))
bind(mainMod .. " + SHIFT + S",       "Capture d'une zone",        noct("screenshot-region"))
bind(mainMod .. " + SHIFT + ALT + S", nil,                         noct("screenshot-region"))
bind(mainMod .. " + SHIFT + C",       "Pipette à couleurs",        hl.dsp.exec_cmd("hyprpicker -a -n"))

-----------------------
---- SON ET MÉDIAS ----
-----------------------
section("Son et médias")

bind("XF86AudioRaiseVolume",    nil,                        noct("volume-up"),   locked_repeating)
bind("XF86AudioLowerVolume",    nil,                        noct("volume-down"), locked_repeating)
bind("XF86AudioMute",           nil,                        noct("volume-mute"), locked)
bind(mainMod .. " + SHIFT + M", "Couper / rétablir le son", noct("volume-mute"), locked)
bind("XF86AudioMicMute",        nil,                        noct("mic-mute"),    locked)

bind("XF86AudioPlay",        nil,                noct("media toggle"),   locked)
bind("XF86AudioPause",       nil,                noct("media toggle"),   locked)
bind("CTRL + SUPER + Space", "Lecture / pause",  noct("media toggle"),   locked)
bind("XF86AudioNext",        nil,                noct("media next"),     locked)
bind("CTRL + SUPER + Equal", "Piste suivante",   noct("media next"),     locked)
bind("XF86AudioPrev",        nil,                noct("media previous"), locked)
bind("CTRL + SUPER + Minus", "Piste précédente", noct("media previous"), locked)

bind("XF86MonBrightnessUp",   nil, noct("brightness-up"),   locked_repeating)
bind("XF86MonBrightnessDown", nil, noct("brightness-down"), locked_repeating)

-- Écriture de la liste pour l'aide ---------------------------------------------
local f = io.open(HOME .. "/.cache/hypr-keybinds.tsv", "w")
if f then
    for _, c in ipairs(cheats) do
        local key = c[1]:gsub("SUPER_L", ""):gsub("SUPER", "Super"):gsub("SHIFT", "Shift")
                        :gsub("CONTROL", "Ctrl"):gsub("CTRL", "Ctrl"):gsub("ALT", "Alt")
                        :gsub("%s*%+%s*$", "")
        f:write(key .. "\t" .. c[2] .. "\n")
    end
    f:close()
end
