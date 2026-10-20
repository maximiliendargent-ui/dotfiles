# ~/Config — toute ma config au même endroit

Ce dossier ne contient **que des raccourcis** (liens symboliques) vers les vrais fichiers.
Modifier un fichier ici modifie le vrai. Rien n'a été déplacé : les applis, `dots` et GitHub
ne voient aucune différence. Supprimer ce dossier ne casse rien.

## Le bureau en 4 couches

1. **Gestionnaire de fenêtres** (`hyprland`, `niri`) : place les fenêtres, raccourcis, écran.
2. **Shell de bureau** (`noctalia`) : barre, panneaux, notifications, fond d'écran, couleurs.
3. **Outils perso** (`quickshell`, `scripts`, `lanceurs`) : menu, vue d'ensemble, carrousel, Manager.
4. **Applis** (`terminal`, `fish`, `prompt.toml`, `fichiers`…).

## Les dossiers

| Raccourci | Vrai emplacement | Ce qu'on y règle |
|---|---|---|
| `hyprland/` | `~/.config/hypr` | Hyprland (rechargé à l'enregistrement) |
| `niri/` | `~/.config/niri` | Session niri : `config.kdl` (apparence, règles, démarrage), `binds.kdl` (raccourcis) |
| `noctalia/` | `~/.config/noctalia` | Barre, widgets, panneaux (`config.toml`), modèles de couleurs (`templates/`) |
| `noctalia-interface.toml` | `~/.local/state/noctalia/settings.toml` | Ce qui est réglé dans l'interface de Noctalia : **l'emporte sur `config.toml`** |
| `quickshell/` | `~/.config/quickshell` | Menu (`menu/`), vue d'ensemble (`overview/`), carrousel (`wallpicker/`), Manager (`manager/`) |
| `scripts/` | `~/.local/bin` | Petits scripts lancés par les raccourcis et le menu |
| `lanceurs/` | `~/.local/share/applications` | Entrées de menu (`.desktop`) |
| `demarrage/` | `~/.config/autostart` | Applis lancées à la connexion, sur tous les bureaux |
| `session/` | `~/.config/uwsm` | Variables d'environnement (NVIDIA, Qt) : se déconnecter pour appliquer |
| `terminal/` | `~/.config/ghostty` | Ghostty : police, transparence, touches |
| `fish/` | `~/.config/fish` | Shell : alias, variables, fonctions (`dots`) |
| `prompt.toml` | `~/.config/starship.toml` | Prompt Starship |
| `fastfetch/` | `~/.config/fastfetch` | Accueil affiché à l'ouverture du terminal |
| `fichiers/` | `~/.config/yazi` | Gestionnaire de fichiers yazi : touches (`keymap.toml`), options (`yazi.toml`) |
| `page-accueil/` | `~/.config/startpage` | Page d'accueil et nouvel onglet de Firefox et Zen |

### Détail de `hyprland/config/`

| Fichier | Rôle |
|---|---|
| `binds.lua` | Raccourcis clavier (format `"Section: texte"`, chiffres en `code:10`…) |
| `autostart.lua` | Applis lancées au démarrage d'Hyprland |
| `decorations.lua` | Bordures, ombres, flou, transparence |
| `animations.lua` | Animations |
| `inputs.lua` | Clavier, souris, pavé tactile |
| `monitors.lua` | Résolution et fréquence de l'écran |
| `windowrules.lua` | Comportement par appli (flottante, espace `gaming`…) |
| `workspaces.lua` | Espaces de travail |
| `misc.lua` | Réglages divers |
| `colors.lua` | Couleurs fixes |
| `environment.lua` | Variables d'environnement propres à Hyprland |
| `../hyprland.lua` | Charge tous les fichiers ci-dessus |

## Ne pas modifier (générés par Noctalia à chaque fond d'écran)

- `hyprland/config/noctalia_colors.lua`
- `niri/noctalia.kdl`
- `quickshell/menu/colors.json`
- `page-accueil/colors.css`
- `fichiers/theme.toml` et `fichiers/flavors/`

Pour changer ces couleurs, modifier le **modèle** dans `noctalia/templates/`.

## Hors de ce dossier

- Fichiers système (`sudo`) : écran de connexion `/etc/greetd/`, sessions `/usr/share/wayland-sessions/`.
- KDE : `~/.config/kwinrc`, `kwinrulesrc`, `kglobalshortcutsrc` (KDE les réécrit lui-même).

## Sauvegarder

```fish
dots add -u
dots commit -m "..."
dots push
```
