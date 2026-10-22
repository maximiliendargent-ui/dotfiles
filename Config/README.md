# ~/Config — toute ma config au même endroit

Ce dossier ne contient **que des raccourcis** (liens symboliques) vers les vrais fichiers.
Modifier un fichier ici modifie le vrai. Rien n'a été déplacé : les applis, `dots` et GitHub
ne voient aucune différence. Supprimer ce dossier ne casse rien.

## Le bureau en 4 couches

1. **Gestionnaire de fenêtres** (`hyprland`) : place les fenêtres, raccourcis, écran.
2. **Shell de bureau** (`shell-maison`) : barre, île, notifications, verrouillage, écran de connexion, fond d'écran, couleurs.
3. **Outils perso** (`quickshell`, `scripts`, `lanceurs`) : menu, vue d'ensemble, carrousel, Manager.
4. **Applis** (`terminal`, `fish`, `prompt.toml`, `fichiers`…).

## Les dossiers

| Raccourci | Vrai emplacement | Ce qu'on y règle |
|---|---|---|
| `hyprland/` | `~/.config/hypr` | Hyprland (rechargé à l'enregistrement) |
| `shell-maison/` | `~/Projects/shell-maison` | Shell de bureau en Quickshell (dépôt à part, voir son `README.md`) : `modules/` (un dossier par élément visible), `services/` (données), `components/` (briques), scripts `bin/`, couleurs `couleurs/` (modèles matugen), écran de connexion `greeter/` |
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
| `autostart.lua` | Applis lancées au démarrage d'Hyprland (dont shell-maison, hypridle, fond d'écran) |
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

## Ne pas modifier (générés par matugen à chaque fond d'écran, `shell-maison/bin/fond`)

- `hyprland/config/noctalia_colors.lua` (le nom date de Noctalia)
- `quickshell/menu/colors.json`
- `page-accueil/colors.css`

Pour changer ces couleurs, modifier le **modèle** dans `shell-maison/couleurs/modeles/`.

## Hors de ce dossier

- Fichiers système (`sudo`) : écran de connexion `/etc/greetd/` (installé depuis `shell-maison/greeter/`), sessions `/usr/share/wayland-sessions/`.
- KDE : `~/.config/kwinrc`, `kwinrulesrc`, `kglobalshortcutsrc` (KDE les réécrit lui-même).

## Sauvegarder

```fish
dots add -u
dots commit -m "..."
dots push
```
