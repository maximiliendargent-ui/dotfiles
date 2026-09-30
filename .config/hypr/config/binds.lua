-- Raccourcis inspirés d'Omarchy, adaptés à Noctalia, à la config CachyOS et à l'AZERTY belge.
-- Chaque raccourci est écrit en toutes lettres pour être modifiable avec l'éditeur (Super + Shift + K).
-- Description = "Section: texte" : l'aide (Super + K) les range par section.
-- Chiffres et touches Moins/Égal liés par code physique (AZERTY) : 1..9 => code:10..18, 0 => code:19,
-- Moins => code:20, Égal => code:21.

-- État interne de quelques bascules
local gaps_off = false

-----------------
---- LANCEUR ----
-----------------
hl.bind("SUPER + SUPER_L",     hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), { release = true, description = "Lanceur: Ouvrir le lanceur (appui seul sur Super)" })
hl.bind("SUPER + Space",       hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), { description = "Lanceur: Ouvrir le lanceur" })
hl.bind("SUPER + ALT + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), { description = "Lanceur: Ouvrir le lanceur (applications)" })
hl.bind("SUPER + CTRL + E",    hl.dsp.exec_cmd("noctalia msg panel-toggle launcher /emo"), { description = "Lanceur: Emojis" })
hl.bind("SUPER + Period",      hl.dsp.exec_cmd("noctalia msg panel-toggle launcher /emo"), { description = "Lanceur: Emojis" })
hl.bind("SUPER + K",           hl.dsp.exec_cmd("uwsm app -- ghostty --class=dev.keybinds -e " .. os.getenv("HOME") .. "/.local/bin/hypr-keybinds"), { description = "Lanceur: Aide des raccourcis" })
hl.bind("SUPER + SHIFT + K",   hl.dsp.exec_cmd("uwsm app -- ghostty --class=dev.keybinds -e " .. os.getenv("HOME") .. "/.local/share/keybind-editor/kbe " .. os.getenv("HOME") .. "/.config/hypr/config/binds.lua"), { description = "Lanceur: Éditeur de raccourcis" })

----------------------
---- APPLICATIONS ----
----------------------
hl.bind("SUPER + T",               hl.dsp.exec_cmd("uwsm app -- ghostty"), { description = "Applications: Terminal" })
hl.bind("SUPER + Return",          hl.dsp.exec_cmd("uwsm app -- ghostty"), { description = "Applications: Terminal" })
hl.bind("SUPER + ALT + Return",    hl.dsp.exec_cmd("uwsm app -- ghostty -e tmux new -A -s main"), { description = "Applications: Terminal tmux" })
hl.bind("SUPER + W",               hl.dsp.exec_cmd("uwsm app -- firefox"), { description = "Applications: Navigateur" })
hl.bind("SUPER + SHIFT + Return",  hl.dsp.exec_cmd("uwsm app -- firefox"), { description = "Applications: Navigateur" })
hl.bind("SUPER + SHIFT + ALT + B", hl.dsp.exec_cmd("uwsm app -- firefox --private-window"), { description = "Applications: Navigation privée" })
hl.bind("SUPER + C",               hl.dsp.exec_cmd("uwsm app -- code"), { description = "Applications: Éditeur de code" })
hl.bind("SUPER + E",               hl.dsp.exec_cmd("uwsm app -- dolphin"), { description = "Applications: Fichiers" })
hl.bind("SUPER + SHIFT + F",       hl.dsp.exec_cmd("uwsm app -- dolphin"), { description = "Applications: Fichiers" })
hl.bind("SUPER + SHIFT + N",       hl.dsp.exec_cmd("uwsm app -- ghostty -e nvim"), { description = "Applications: Neovim" })
hl.bind("SUPER + SHIFT + D",       hl.dsp.exec_cmd("uwsm app -- ghostty -e lazydocker"), { description = "Applications: Docker (LazyDocker)" })
hl.bind("SUPER + CTRL + T",        hl.dsp.exec_cmd("uwsm app -- ghostty -e btop"), { description = "Applications: Moniteur système (btop)" })
hl.bind("CTRL + SHIFT + Escape",   hl.dsp.exec_cmd("uwsm app -- ghostty -e btop"), { description = "Applications: Moniteur système (btop)" })
hl.bind("SUPER + CTRL + Q",        hl.dsp.exec_cmd("uwsm app -- gnome-calculator"), { description = "Applications: Calculatrice" })
hl.bind("XF86Calculator",          hl.dsp.exec_cmd("uwsm app -- gnome-calculator"))

------------
---- IA ----
------------
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("uwsm app -- google-chrome-stable --app=https://claude.ai"), { description = "IA: Claude" })

------------------
---- FENÊTRES ----
------------------
hl.bind("SUPER + Q",            hl.dsp.window.close(), { description = "Fenêtres: Fermer la fenêtre" })
hl.bind("CTRL + ALT + Delete",  function()
    for _, w in ipairs(hl.get_windows()) do
        hl.dispatch(hl.dsp.window.close({ window = w }))
    end
end, { description = "Fenêtres: Fermer toutes les fenêtres" })
hl.bind("SUPER + SHIFT + Escape", hl.dsp.exec_cmd("hyprctl kill"), { description = "Fenêtres: Forcer la fermeture (cliquer sur la fenêtre)" })
hl.bind("SUPER + F",            hl.dsp.window.fullscreen(), { description = "Fenêtres: Plein écran" })
hl.bind("SUPER + ALT + F",      hl.dsp.window.fullscreen({ mode = 1 }), { description = "Fenêtres: Pleine largeur (garde la barre)" })
hl.bind("SUPER + SHIFT + T",    hl.dsp.window.float({ action = "toggle" }), { description = "Fenêtres: Flottante / en mosaïque" })
hl.bind("SUPER + O",            function()
    local w = hl.get_active_window()
    if not w then return end
    if not w.floating then hl.dispatch(hl.dsp.window.float({ action = "toggle" })) end
    hl.dispatch(hl.dsp.window.pin())
end, { description = "Fenêtres: Flottante et épinglée sur tous les espaces" })
hl.bind("SUPER + P",            function() hl.dispatch(hl.dsp.window.pseudo()) end, { description = "Fenêtres: Mode pseudo (taille naturelle)" })
hl.bind("SUPER + J",            hl.dsp.layout("togglesplit"), { description = "Fenêtres: Basculer la division (horizontale / verticale)" })
hl.bind("SUPER + L",            function()
    local cur = hl.get_config("general:layout")
    hl.config({ general = { layout = (cur == "scrolling") and "dwindle" or "scrolling" } })
end, { description = "Fenêtres: Disposition mosaïque / défilement" })
hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.center(), { description = "Fenêtres: Centrer la fenêtre" })

hl.bind("SUPER + Left",          hl.dsp.focus({ direction = "left" }),  { description = "Fenêtres: Aller à la fenêtre de gauche" })
hl.bind("SUPER + Right",         hl.dsp.focus({ direction = "right" }), { description = "Fenêtres: Aller à la fenêtre de droite" })
hl.bind("SUPER + Up",            hl.dsp.focus({ direction = "up" }),    { description = "Fenêtres: Aller à la fenêtre du dessus" })
hl.bind("SUPER + Down",          hl.dsp.focus({ direction = "down" }),  { description = "Fenêtres: Aller à la fenêtre du dessous" })
hl.bind("SUPER + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }), { description = "Fenêtres: Déplacer à gauche" })
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "r" }), { description = "Fenêtres: Déplacer à droite" })
hl.bind("SUPER + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }), { description = "Fenêtres: Déplacer en haut" })
hl.bind("SUPER + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }), { description = "Fenêtres: Déplacer en bas" })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { description = "Fenêtres: Déplacer à la souris" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { description = "Fenêtres: Redimensionner à la souris" })

-- Redimensionnement au clavier (Moins = code:20, Égal = code:21)
hl.bind("SUPER + code:20",         function() hl.dispatch(hl.dsp.window.resize({ x = -50,  y = 0,   relative = true })) end, { repeating = true, description = "Fenêtres: Réduire la largeur" })
hl.bind("SUPER + code:21",         function() hl.dispatch(hl.dsp.window.resize({ x = 50,   y = 0,   relative = true })) end, { repeating = true, description = "Fenêtres: Augmenter la largeur" })
hl.bind("SUPER + SHIFT + code:20", function() hl.dispatch(hl.dsp.window.resize({ x = 0,    y = -50, relative = true })) end, { repeating = true, description = "Fenêtres: Réduire la hauteur" })
hl.bind("SUPER + SHIFT + code:21", function() hl.dispatch(hl.dsp.window.resize({ x = 0,    y = 50,  relative = true })) end, { repeating = true, description = "Fenêtres: Augmenter la hauteur" })
hl.bind("SUPER + ALT + code:20",   function() hl.dispatch(hl.dsp.window.resize({ x = -10,  y = 0,   relative = true })) end, { repeating = true, description = "Fenêtres: Réduire la largeur (petit pas)" })
hl.bind("SUPER + ALT + code:21",   function() hl.dispatch(hl.dsp.window.resize({ x = 10,   y = 0,   relative = true })) end, { repeating = true, description = "Fenêtres: Augmenter la largeur (petit pas)" })
hl.bind("SUPER + CTRL + code:20",  function() hl.dispatch(hl.dsp.window.resize({ x = -150, y = 0,   relative = true })) end, { repeating = true, description = "Fenêtres: Réduire la largeur (grand pas)" })
hl.bind("SUPER + CTRL + code:21",  function() hl.dispatch(hl.dsp.window.resize({ x = 150,  y = 0,   relative = true })) end, { repeating = true, description = "Fenêtres: Augmenter la largeur (grand pas)" })

hl.bind("ALT + TAB",         hl.dsp.window.cycle_next(),                 { repeating = true, description = "Fenêtres: Fenêtre suivante" })
hl.bind("SHIFT + ALT + TAB", hl.dsp.window.cycle_next({ next = false }), { repeating = true, description = "Fenêtres: Fenêtre précédente" })

hl.bind("SUPER + CTRL + Z", function()
    local z = hl.get_config("cursor:zoom_factor") + 0.5
    hl.config({ cursor = { zoom_factor = (z > 3.0) and 3.0 or z } })
end, { repeating = true, description = "Fenêtres: Zoomer sur l'écran" })
hl.bind("SUPER + CTRL + ALT + Z", function()
    hl.config({ cursor = { zoom_factor = 1.0 } })
end, { description = "Fenêtres: Annuler le zoom" })

-----------------
---- GROUPES ----
-----------------
hl.bind("SUPER + G",                 hl.dsp.group.toggle(),                           { description = "Groupes: Créer / dissoudre un groupe" })
hl.bind("SUPER + ALT + G",           hl.dsp.window.move({ out_of_group = true }),     { description = "Groupes: Sortir la fenêtre du groupe" })
hl.bind("SUPER + CTRL + G",          hl.dsp.group.lock_active(),                      { description = "Groupes: Verrouiller le groupe" })
hl.bind("SUPER + ALT + Tab",         hl.dsp.group.next(), { repeating = true,           description = "Groupes: Onglet suivant" })
hl.bind("SUPER + ALT + SHIFT + Tab", hl.dsp.group.prev(), { repeating = true,           description = "Groupes: Onglet précédent" })
hl.bind("SUPER + CTRL + Right",      hl.dsp.group.next(), { repeating = true,           description = "Groupes: Onglet suivant" })
hl.bind("SUPER + CTRL + Left",       hl.dsp.group.prev(), { repeating = true,           description = "Groupes: Onglet précédent" })

----------------------------
---- ESPACES DE TRAVAIL ----
----------------------------
hl.bind("SUPER + code:10", hl.dsp.focus({ workspace = 1 }),  { description = "Espaces de travail: Aller à l'espace 1" })
hl.bind("SUPER + code:11", hl.dsp.focus({ workspace = 2 }),  { description = "Espaces de travail: Aller à l'espace 2" })
hl.bind("SUPER + code:12", hl.dsp.focus({ workspace = 3 }),  { description = "Espaces de travail: Aller à l'espace 3" })
hl.bind("SUPER + code:13", hl.dsp.focus({ workspace = 4 }),  { description = "Espaces de travail: Aller à l'espace 4" })
hl.bind("SUPER + code:14", hl.dsp.focus({ workspace = 5 }),  { description = "Espaces de travail: Aller à l'espace 5" })
hl.bind("SUPER + code:15", hl.dsp.focus({ workspace = 6 }),  { description = "Espaces de travail: Aller à l'espace 6" })
hl.bind("SUPER + code:16", hl.dsp.focus({ workspace = 7 }),  { description = "Espaces de travail: Aller à l'espace 7" })
hl.bind("SUPER + code:17", hl.dsp.focus({ workspace = 8 }),  { description = "Espaces de travail: Aller à l'espace 8" })
hl.bind("SUPER + code:18", hl.dsp.focus({ workspace = 9 }),  { description = "Espaces de travail: Aller à l'espace 9" })
hl.bind("SUPER + code:19", hl.dsp.focus({ workspace = 10 }), { description = "Espaces de travail: Aller à l'espace 10" })

hl.bind("SUPER + SHIFT + code:10", hl.dsp.window.move({ workspace = 1 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 1" })
hl.bind("SUPER + SHIFT + code:11", hl.dsp.window.move({ workspace = 2 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 2" })
hl.bind("SUPER + SHIFT + code:12", hl.dsp.window.move({ workspace = 3 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 3" })
hl.bind("SUPER + SHIFT + code:13", hl.dsp.window.move({ workspace = 4 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 4" })
hl.bind("SUPER + SHIFT + code:14", hl.dsp.window.move({ workspace = 5 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 5" })
hl.bind("SUPER + SHIFT + code:15", hl.dsp.window.move({ workspace = 6 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 6" })
hl.bind("SUPER + SHIFT + code:16", hl.dsp.window.move({ workspace = 7 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 7" })
hl.bind("SUPER + SHIFT + code:17", hl.dsp.window.move({ workspace = 8 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 8" })
hl.bind("SUPER + SHIFT + code:18", hl.dsp.window.move({ workspace = 9 }),  { description = "Espaces de travail: Envoyer la fenêtre à l'espace 9" })
hl.bind("SUPER + SHIFT + code:19", hl.dsp.window.move({ workspace = 10 }), { description = "Espaces de travail: Envoyer la fenêtre à l'espace 10" })

hl.bind("SUPER + SHIFT + ALT + code:10", hl.dsp.window.move({ workspace = 1,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 1 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:11", hl.dsp.window.move({ workspace = 2,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 2 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:12", hl.dsp.window.move({ workspace = 3,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 3 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:13", hl.dsp.window.move({ workspace = 4,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 4 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:14", hl.dsp.window.move({ workspace = 5,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 5 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:15", hl.dsp.window.move({ workspace = 6,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 6 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:16", hl.dsp.window.move({ workspace = 7,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 7 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:17", hl.dsp.window.move({ workspace = 8,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 8 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:18", hl.dsp.window.move({ workspace = 9,  follow = false }), { description = "Espaces de travail: Envoyer à l'espace 9 sans suivre" })
hl.bind("SUPER + SHIFT + ALT + code:19", hl.dsp.window.move({ workspace = 10, follow = false }), { description = "Espaces de travail: Envoyer à l'espace 10 sans suivre" })

hl.bind("SUPER + Tab",          hl.dsp.focus({ workspace = "e+1" }),      { description = "Espaces de travail: Espace suivant" })
hl.bind("SUPER + SHIFT + Tab",  hl.dsp.focus({ workspace = "e-1" }),      { description = "Espaces de travail: Espace précédent" })
hl.bind("SUPER + CTRL + Tab",   hl.dsp.focus({ workspace = "previous" }), { description = "Espaces de travail: Dernier espace visité" })
hl.bind("SUPER + mouse_down",   hl.dsp.focus({ workspace = "e+1" }),      { description = "Espaces de travail: Espace suivant (molette)" })
hl.bind("SUPER + mouse_up",     hl.dsp.focus({ workspace = "e-1" }),      { description = "Espaces de travail: Espace précédent (molette)" })

hl.bind("SUPER + S",                  hl.dsp.workspace.toggle_special(),               { description = "Espaces de travail: Afficher / cacher le scratchpad" })
hl.bind("SUPER + ALT + S",            hl.dsp.window.move({ workspace = "special" }),   { description = "Espaces de travail: Envoyer la fenêtre au scratchpad" })
hl.bind("CTRL + SUPER + SHIFT + Down", hl.dsp.window.move({ workspace = "e+0" }),      { description = "Espaces de travail: Sortir la fenêtre du scratchpad" })

-----------------
---- SYSTÈME ----
-----------------
hl.bind("SUPER + Escape",      hl.dsp.exec_cmd("noctalia msg panel-toggle session"), { description = "Système: Menu système (veille, redémarrage…)" })
hl.bind("SUPER + CTRL + L",    hl.dsp.exec_cmd("noctalia msg session lock"),         { description = "Système: Verrouiller l'écran" })
hl.bind("SUPER + SHIFT + L",   hl.dsp.exec_cmd("systemctl suspend-then-hibernate"),  { locked = true, description = "Système: Mise en veille" })
hl.bind("SUPER + N",           hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"),           { description = "Système: Centre de contrôle" })
hl.bind("SUPER + CTRL + A",    hl.dsp.exec_cmd("noctalia msg panel-toggle control-center audio"),     { description = "Système: Panneau son" })
hl.bind("SUPER + CTRL + B",    hl.dsp.exec_cmd("noctalia msg panel-toggle control-center bluetooth"), { description = "Système: Panneau Bluetooth" })
hl.bind("SUPER + CTRL + W",    hl.dsp.exec_cmd("noctalia msg panel-toggle control-center network"),   { description = "Système: Panneau réseau" })
hl.bind("SUPER + CTRL + N",    hl.dsp.exec_cmd("noctalia msg nightlight-toggle"),    { description = "Système: Veilleuse (lumière chaude)" })
hl.bind("SUPER + CTRL + I",    hl.dsp.exec_cmd("noctalia msg caffeine-toggle"),      { description = "Système: Bloquer / autoriser la mise en veille" })
hl.bind("SUPER + SHIFT + Space", hl.dsp.exec_cmd("noctalia msg bar-toggle"),         { description = "Système: Masquer / afficher la barre" })
hl.bind("SUPER + Z",           hl.dsp.exec_cmd("noctalia msg settings-toggle"),      { description = "Système: Réglages de Noctalia" })
hl.bind("SUPER + V",           hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"), { description = "Système: Historique du presse-papiers" })
hl.bind("SUPER + CTRL + V",    hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"), { description = "Système: Historique du presse-papiers" })

---------------
---- STYLE ----
---------------
hl.bind("SUPER + CTRL + Space",         hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/wallpicker-toggle"), { description = "Style: Carrousel de fonds d'écran" })
hl.bind("SUPER + SHIFT + W",            hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/wallpicker-toggle"), { description = "Style: Carrousel de fonds d'écran" })
hl.bind("SUPER + CTRL + SHIFT + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"), { description = "Style: Sélecteur de fonds d'écran Noctalia" })
hl.bind("SUPER + BackSpace", function()
    hl.dispatch(hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))
end, { description = "Style: Transparence de la fenêtre" })
hl.bind("SUPER + SHIFT + BackSpace", function()
    gaps_off = not gaps_off
    hl.config({ general = { gaps_in = gaps_off and 0 or 5, gaps_out = gaps_off and 0 or 10 } })
end, { description = "Style: Masquer / afficher les espacements" })

-----------------------
---- NOTIFICATIONS ----
-----------------------
hl.bind("SUPER + Comma",               hl.dsp.exec_cmd("noctalia msg notification-clear-active"),  { description = "Notifications: Fermer les notifications" })
hl.bind("SUPER + CTRL + Comma",        hl.dsp.exec_cmd("noctalia msg notification-dnd-toggle"),    { description = "Notifications: Ne pas déranger" })
hl.bind("SUPER + ALT + Comma",         hl.dsp.exec_cmd("noctalia msg notification-invoke-latest"), { description = "Notifications: Ouvrir la dernière notification" })
hl.bind("SUPER + SHIFT + ALT + Comma", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center notifications"), { description = "Notifications: Historique" })

------------------
---- CAPTURES ----
------------------
hl.bind("Print",               hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen"), { description = "Captures: Écran entier" })
hl.bind("SUPER + SHIFT + S",   hl.dsp.exec_cmd("noctalia msg screenshot-region"),     { description = "Captures: Zone de l'écran" })
hl.bind("SUPER + Print",       hl.dsp.exec_cmd("hyprpicker -a -n"),                   { description = "Captures: Pipette à couleurs" })
hl.bind("SUPER + SHIFT + C",   hl.dsp.exec_cmd("hyprpicker -a -n"),                   { description = "Captures: Pipette à couleurs" })

----------------
---- MÉDIAS ----
----------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("noctalia msg volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("noctalia msg mic-mute"),    { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("noctalia msg media toggle"), { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("noctalia msg media toggle"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("noctalia msg media next"),     { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("noctalia msg media previous"), { locked = true })
hl.bind("ALT + XF86AudioPlay",         hl.dsp.exec_cmd("noctalia msg media next"),     { locked = true, description = "Médias: Piste suivante (Alt + Lecture)" })
hl.bind("ALT + SHIFT + XF86AudioPlay", hl.dsp.exec_cmd("noctalia msg media previous"), { locked = true, description = "Médias: Piste précédente (Alt + Shift + Lecture)" })
hl.bind("SUPER + SHIFT + M",    hl.dsp.exec_cmd("noctalia msg volume-mute"), { locked = true, description = "Médias: Couper / rétablir le son" })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("noctalia msg brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down"), { locked = true, repeating = true })
hl.bind("SUPER + CTRL + SHIFT + A", hl.dsp.exec_cmd("uwsm app -- ghostty --class=dev.ai -e claude"), { description = "IA: Agent Claude Code" })
