source /usr/share/cachyos-fish-config/cachyos-config.fish

# Éditeur par défaut (Ctrl + G dans Claude Code, git…)
set -gx EDITOR code-wait

# bat et fzf en couleurs ANSI : ils suivent la palette de Ghostty (donc le fond d'écran)
set -gx BAT_THEME ansi
set -gx FZF_DEFAULT_OPTS "--color=16"

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
starship init fish | source
