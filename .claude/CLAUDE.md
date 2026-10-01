# Mon système — contexte pour Claude Code

Réponds-moi en **français**. Je suis développeur, à l'aise avec le terminal, mais explique ce que tu fais
avant de modifier quelque chose.

## Règles importantes

- **Demande toujours confirmation** avant toute commande avec `sudo`, toute suppression, et toute
  modification de fichier système (hors de `~`).
- **Sauvegarde avant de modifier** un fichier de config : `cp fichier fichier.bak` (les `.bak` sont exclus
  de mon dépôt de dotfiles).
- Avant une opération risquée sur le système, propose un snapshot : `sudo snapper -c root create -d "..."`.
- **Ne modifie jamais les fichiers générés** (listés plus bas) : ils sont réécrits automatiquement.
- Après une modification réussie de ma config, propose de la sauvegarder avec `dots` (voir plus bas).
- Mon shell est **fish** : pas de heredoc (`<< EOF`), pas de `VAR=valeur` ; utilise `set`, ou lance
  `bash -c '...'` si besoin. Mets les URL contenant `?` entre guillemets.

## Matériel

- CachyOS (base Arch), noyau `linux-cachyos`, système de fichiers Btrfs avec snapper.
- CPU Intel i5-11400F, **GPU NVIDIA RTX 2060 SUPER (8 Go)**, pilote NVIDIA open 615, 16 Go de RAM.
- Écran `HDMI-A-1` en **1920x1080 à 165 Hz**.
- Clavier **AZERTY belge** (`be`).
- Connexion Wi-Fi : préférer le réseau `WiFi-5.0-E39E` (le répéteur `_EXT` est lent).

## Sessions

- Écran de connexion : **greetd + Noctalia Greeter** (config : `/etc/greetd/config.toml`,
  `/var/lib/noctalia-greeter/greeter.toml`, clavier `be` et Verr. Num. activés).
- Session principale : **« Hyprland (Noctalia) »**, via UWSM
  (`/usr/share/wayland-sessions/hyprland-uwsm-clean.desktop`, qui nettoie `graphical-session.target`
  avant de démarrer). **KDE Plasma** est une session secondaire (jeux / secours).
- `KillUserProcesses=yes` (`/etc/systemd/logind.conf.d/kill-user-processes.conf`).
- KDE fait aussi le ménage au démarrage : `~/.config/plasma-workspace/env/cleanup-graphical-session.sh`.
- KWallet est le gestionnaire de secrets : déverrouillé via `pam_kwallet5` dans `/etc/pam.d/greetd`
  et `/usr/lib/pam_kwallet_init` lancé au démarrage d'Hyprland. gnome-keyring est masqué
  (`~/.local/share/dbus-1/services/org.freedesktop.secrets.service` redirige vers `kwalletd6`).

## Hyprland (configuration en **Lua**, pas en hyprlang)

- Entrée : `~/.config/hypr/hyprland.lua`, qui charge `~/.config/hypr/config/*.lua` :
  `animations`, `autostart`, `colors`, `decorations`, `variables`, `inputs`, `binds`, `misc`, `monitors`,
  `windowrules`, `workspaces`, puis `noctalia_colors` (via `pcall`).
- Hyprland **recharge automatiquement** la config à l'enregistrement. Une erreur de syntaxe Lua empêche
  le rechargement et s'affiche en haut de l'écran : vérifie après chaque modification.
- Définitions de l'API Lua : `/usr/share/hypr/stubs/hl.meta.lua` (les paramètres des `hl.dsp.*` n'y sont
  pas détaillés). Exemple connu qui marche : `hl.dsp.window.resize({ x = 50, y = 0, relative = true })`.
  Pour un dispatcher dont les paramètres sont incertains, l'envelopper dans une fonction
  (`function() hl.dispatch(...) end`) pour ne pas bloquer le chargement de la config.
- **`binds.lua`** : raccourcis inspirés d'Omarchy, chacun écrit en toutes lettres
  (`hl.bind("SUPER + T", ..., { description = "Section: texte" })`). Le format `"Section: texte"` est
  obligatoire : mon aide (Super + K) les range par section. Chiffres et touches Moins/Égal liés par code
  physique à cause de l'AZERTY : 1..9 → `code:10`..`code:18`, 0 → `code:19`, Moins → `code:20`,
  Égal → `code:21`. Ne pas changer Super + E, T, Z, W, C, F.
- Les applis sont lancées avec le préfixe `uwsm app -- `.
- Environnement de session : `~/.config/uwsm/env` (variables NVIDIA, `QT_QPA_PLATFORMTHEME=qt6ct`) ;
  une modification demande de se déconnecter/reconnecter.
- Style : coins carrés (`rounding = 0`), espacements 5/10, bordures dont les couleurs suivent le fond
  d'écran (fichier généré `noctalia_colors.lua`).

## Noctalia (shell, **v5** : réécrit en C++, plus basé sur Quickshell)

- Config : `~/.config/noctalia/config.toml`. Les réglages faits dans l'interface sont dans
  `~/.local/state/noctalia/settings.toml` et **l'emportent** sur `config.toml`.
- Recharger : `noctalia msg config-reload`. Aide complète : `noctalia msg --help`.
- Commandes utiles : `noctalia msg panel-toggle <launcher|control-center [audio|bluetooth|network|notifications]|clipboard|session|wallpaper>`,
  `wallpaper-set <chemin>`, `wallpaper-get`, `templates-apply`, `bar-toggle`, `nightlight-toggle`,
  `caffeine-toggle`, `settings-toggle`, `session lock`, `screenshot-region`, `greeter-sync`.
- Les **couleurs de tout le bureau suivent le fond d'écran** (je ne veux pas de palette fixe).
  Modèles actifs : `builtin_ids` (ghostty, btop, gtk3, gtk4, kcolorscheme, qt), `community_ids`
  (vscode, zen-browser, pywalfox) et un modèle perso `hyprland_borders`
  (`~/.config/noctalia/templates/hyprland-borders.lua` → `~/.config/hypr/config/noctalia_colors.lua`).
- Fonds d'écran : `~/Pictures/Wallpapers`. Captures : copiées dans le presse-papiers, enregistrées
  seulement sur demande (Ctrl + S), dans `~/Pictures/Screenshots`.
- Agent Polkit de Noctalia activé (`polkit_agent = true`).
- Plugins activés (gérés dans la fenêtre Manager, enregistrés dans `settings.toml`) : `noctalia/bongocat`,
  `noctalia/wallhaven`.

## Mes outils perso

- `~/.local/bin/hypr-keybinds` : aide des raccourcis (Super + K), lit `hyprctl binds -j`.
- `~/.local/share/keybind-editor/kbe` : éditeur de raccourcis (Super + Shift + K).
- Carrousel de fonds d'écran en **Quickshell 0.3.1** (QML) : `~/.config/quickshell/wallpicker/shell.qml`,
  lancé par `~/.local/bin/wallpicker-toggle` (Super + Ctrl + Espace et Super + Shift + W). Il applique le
  fond via `noctalia msg wallpaper-set`.
- Bouton **Claude** dans la barre Noctalia (`[widget.claude]` dans `config.toml`, icône
  `~/.config/noctalia/icons/claude.svg`) : ouvre `claude` dans Ghostty, dans le dossier `~/.config`
  (pas `~`, pour lequel Claude Code redemande la confiance à chaque lancement).
- `~/.local/bin/code-wait` : `code --wait` sans les avertissements de `~/.config/code-flags.conf` (sert d'`EDITOR`).
- Menu façon Omarchy en **Quickshell** : `~/.config/quickshell/menu/shell.qml`, lancé par `~/.local/bin/menu-toggle`
  (Super seul). Couleurs via le modèle Noctalia `menu_colors` → `colors.json` (généré). L'entrée
  Manager ouvre la fenêtre Manager (paquets et plugins). Update = `paru -Syu --noconfirm` + `flatpak update -y`
  (snapshots via `snap-pac`).
- Fenêtre **Manager** en Quickshell (paquets officiels + AUR, plugins Noctalia) :
  `~/.config/quickshell/manager/shell.qml`, données via `~/.local/bin/manager-data` (JSON), ouverte par
  `~/.local/bin/manager-open [packages|plugins] [add|installed]`. Un clic sur un plugin ouvre sa fiche
  (README du catalogue, via `manager-data plugin-info`). Mots de passe via l'agent Polkit de
  Noctalia (`pkexec`). Couleurs partagées avec le menu (`menu/colors.json`).

## Applis et thèmes

- Terminal **Ghostty** (`~/.config/ghostty/config`), shell fish (`~/.config/fish/config.fish`),
  prompt **Starship** (`~/.config/starship.toml`, couleurs ANSI pour suivre Ghostty).
- Ghostty : `performable:ctrl+v=paste_from_clipboard` → Ctrl + V colle le texte ; sans texte (image), la
  touche passe à l'appli (Claude Code colle alors l'image). Ne pas retirer `performable:`.
- Navigateurs : Firefox (Pywalfox) et Zen ; éditeur VS Code officiel (`code`) ; fichiers : Dolphin.
- `EDITOR=code-wait` (dans `config.fish`) : Ctrl + G dans Claude Code ouvre le prompt dans VS Code.
- Thème Qt : **qt6ct-kde**, schéma de couleurs KDE `Noctalia`. Les applis GTK 4 ne rechargent leurs
  couleurs qu'au démarrage (limite de GTK).
- Curseur choisi avec `nwg-look`.

## Paquets

- `pacman` et `paru` (AUR). Préférer les dépôts `cachyos-*` quand un choix est proposé.
- Utiliser `--needed`. **Jamais** de `pacman -Sy` seul (mises à jour partielles) : `sudo pacman -Syu`.
- Miroirs lents : `sudo cachyos-rate-mirrors`.

## Dotfiles

- Dépôt Git « bare » : `~/.dotfiles`, avec la fonction fish
  `dots` = `git --git-dir=$HOME/.dotfiles --work-tree=$HOME`. Distant : `maximiliendargent-ui/dotfiles`
  (privé, GitHub).
- Après une modification : `dots add -u` (fichiers déjà suivis), `dots add <nouveau fichier>`,
  `dots commit -m "..."`, `dots push`.
- Exclus : `*.bak`, `.config/hypr/config/noctalia_colors.lua`, `.config/quickshell/menu/colors.json`.
- Les fichiers système (`/etc/greetd`, `/etc/pam.d/greetd`, `/etc/systemd/logind.conf.d`,
  `/usr/share/wayland-sessions/hyprland-uwsm-clean.desktop`, `/var/lib/noctalia-greeter`) ne sont **pas**
  dans ce dépôt.

## Maintenance de ce fichier

**Chaque fois que tu modifies un fichier de config, propose-moi dans la même tâche la mise à jour
de ce fichier** (la ligne exacte à ajouter ou corriger). **Ne l'applique qu'après mon accord**, puis
sauvegarde-le avec `dots` en même temps que la config. À la fin de chaque tâche qui a modifié mon
système, vérifie aussi que le reste de ce fichier est encore exact.

À mettre à jour quand je :
- change d'outil principal (terminal, shell, éditeur, gestionnaire de fichiers, navigateur,
  shell de bureau, gestionnaire de fenêtres) ;
- ajoute, renomme, déplace ou supprime un fichier de config, un dossier important (fonds d'écran,
  captures) ou un fichier de `~/.config/hypr/config/` ;
- change le format des descriptions de raccourcis ou la façon de lier les touches ;
- ajoute un outil perso (script dans `~/.local/bin`, composant Quickshell, plugin Noctalia) ;
- change de matériel (carte graphique, écran, clavier) ;
- change une préférence ou une règle de fonctionnement ;
- modifie ma méthode de sauvegarde des dotfiles.

Seules exceptions : un raccourci ajouté ou modifié dans `binds.lua` (il se décrit lui-même), un
ajustement de valeur (tailles, vitesses, espacements, police), un changement de fond d'écran,
l'installation d'une appli secondaire.

Garde ce fichier concis : c'est une carte de mon système et de mes règles, pas une documentation
complète.
