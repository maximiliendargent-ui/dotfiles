source /usr/share/cachyos-fish-config/cachyos-config.fish

# Éditeur par défaut (Ctrl + G dans Claude Code, git…)
set -gx EDITOR code-wait

# bat et fzf en couleurs ANSI : ils suivent la palette de Ghostty (donc le fond d'écran)
set -gx BAT_THEME ansi
set -gx FZF_DEFAULT_OPTS "--color=16"

# Accueil : fastfetch avec le fond d'écran courant en vignette (protocole graphique kitty).
# Hors Ghostty/kitty ou sans Noctalia, on garde le logo ASCII de config.jsonc.
function fish_greeting
    set -l fond (noctalia msg wallpaper-get 2>/dev/null)
    if contains -- "$TERM" xterm-ghostty xterm-kitty; and test -f "$fond"
        fastfetch --logo-type kitty --logo $fond --logo-width 36
    else
        fastfetch
    end
end
starship init fish | source
