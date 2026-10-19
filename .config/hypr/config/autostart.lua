-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    hl.exec_cmd("noctalia")
    -- Nouveau fond d'écran à chaque connexion : réessaie jusqu'à ce que Noctalia réponde (10 s max)
    hl.exec_cmd("sh -c 'for i in $(seq 50); do noctalia msg wallpaper-random >/dev/null 2>&1 && break; sleep 0.2; done'")
    hl.exec_cmd("xhost +SI:localuser:root")
    -- Vue d'ensemble des espaces de travail (coin haut gauche) : ~/.config/quickshell/overview
    hl.exec_cmd("qs -c overview")
    -- Configs du bureau dans VS Code sur l'espace 2 (~/.config/bureau.code-workspace).
    -- VS Code se détache de son lanceur, donc pas de règle d'exec : on attend sa fenêtre (30 s max) et on la déplace.
    hl.exec_cmd([[sh -c 'uwsm app -- code ~/.config/bureau.code-workspace; for i in $(seq 150); do a=$(hyprctl clients -j | jq -r ".[]|select(.class==\"com.microsoft.VSCode\")|.address" | head -1); [ -n "$a" ] && { hyprctl dispatch "hl.dsp.window.move({ workspace = 2, window = \"address:$a\", follow = false })"; break; }; sleep 0.2; done']])
end)
