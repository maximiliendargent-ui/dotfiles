-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
    -- Shell de bureau : ~/.config/quickshell/shell-maison (barre, île, notifications, verrouillage…)
    local maison = os.getenv("HOME") .. "/.config/quickshell/shell-maison/"
    hl.exec_cmd("qs -c shell-maison")
    -- Verrouillage et extinction de l'écran après inactivité
    hl.exec_cmd("hypridle -c " .. maison .. "hypr/hypridle.conf")
    -- Nouveau fond d'écran au hasard et couleurs assorties (bin/fond), une fois le démon awww prêt
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sh -c 'until awww query >/dev/null 2>&1; do sleep 0.2; done; " .. maison .. "bin/fond'")
    -- Historique du presse-papiers (Clipboard.qml de shell-maison) : texte et images
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("xhost +SI:localuser:root")
    -- Vue d'ensemble des espaces de travail (coin haut gauche) : ~/.config/quickshell/overview
    hl.exec_cmd("qs -c overview")
    -- Dossier ~/.config dans VS Code sur l'espace 2 : ~/.local/bin/open-bureau
    hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/open-bureau")
end)
