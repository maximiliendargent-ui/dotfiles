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
    -- btop et cava ouverts à la connexion, sur le même espace (flottants, placés par windowrules.lua)
    hl.exec_cmd("uwsm app -- ghostty --class=dev.btop -e btop")
    hl.exec_cmd("uwsm app -- ghostty --class=dev.cava -e cava")
end)
