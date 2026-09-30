source /usr/share/cachyos-fish-config/cachyos-config.fish

# Éditeur par défaut (Ctrl + G dans Claude Code, git…)
set -gx EDITOR code-wait

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
starship init fish | source
