source /usr/share/cachyos-fish-config/cachyos-config.fish

# Éditeur par défaut (Ctrl + G dans Claude Code, git…)
set -gx EDITOR code-wait

# bat et fzf en couleurs ANSI : ils suivent la palette de Ghostty (donc le fond d'écran)
set -gx BAT_THEME ansi
set -gx FZF_DEFAULT_OPTS "--color=16"

# Accueil : fastfetch avec la vignette du personnage du fond d'écran (préparée et mise en cache par
# ~/.local/bin/fastfetch-perso). Sans vignette (fond sans personnage, pas encore préparée, terminal
# sans images), logo de config.jsonc.
function fish_greeting
    set -l fond (noctalia msg wallpaper-get 2>/dev/null)
    set -l vignette ~/.cache/fastfetch-perso/(path basename -- "$fond").png
    if contains -- "$TERM" xterm-ghostty xterm-kitty; and test -s "$vignette"
        fastfetch --logo-type kitty --logo $vignette --logo-height 16
    else
        fastfetch
        # Premier terminal après un nouveau fond : la vignette se prépare en arrière-plan pour les suivants
        if test -f "$fond"; and not test -e "$vignette"; and not test -L "$vignette"
            ~/.local/bin/fastfetch-perso $fond &>/dev/null &
            disown
        end
    end
end
starship init fish | source
