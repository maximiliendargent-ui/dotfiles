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
- Connexion Wi-Fi : préférer le réseau `WiFi-5.0-E39E` (le répéteur `_EXT` est lent) ; bascule par
  `nmcli connection up WiFi-5.0-E39E`. La ligne Internet plafonne vers 40 Mbit/s (4 à 4,5 Mo/s).
  Économie d'énergie Wi-Fi désactivée sur ce profil (`802-11-wireless.powersave 2`), à cause de la
  gigue en vocal.
- Profil d'alimentation : `balanced` via `power-profiles-daemon` (`powerprofilesctl set balanced`), pour
  limiter la chauffe du CPU (ventirad trop juste : 89 °C en charge légère).

## Sessions

- Écran de connexion : **greetd + écran de shell-maison** (Quickshell dans un Hyprland minimal ; sources
  `~/Projects/shell-maison/greeter/`, installées dans `/etc/greetd/shell-maison/` par
  `sudo ~/Projects/shell-maison/greeter/installer`, qui règle `command` dans `/etc/greetd/config.toml`).
  Sessions proposées : « Hyprland (Maison) » (défaut) et KDE Plasma ; fond au hasard flouté. Piège : greetd
  colle les arguments de `Greetd.launch` dans un `sh -c` (passer la ligne Exec en un seul morceau) et il faut
  `XDG_SESSION_TYPE=wayland` dans son env pour que `pam_kwallet5` déverrouille KWallet.
- Session principale : **« Hyprland (Maison) »**, via UWSM
  (`/usr/share/wayland-sessions/hyprland-maison-uwsm-clean.desktop`, qui nettoie `graphical-session.target`
  avant `uwsm start -D Hyprland:maison`). **KDE Plasma** est une session secondaire (jeux / secours).
- Noctalia et niri sont **désinstallés** (2026-10-22). La session KDE tourne sans shell perso (Plasma seul ;
  restes Noctalia supprimés le 2026-10-22).
- `KillUserProcesses=yes` (`/etc/systemd/logind.conf.d/kill-user-processes.conf`).
- KDE fait aussi le ménage au démarrage : `~/.config/plasma-workspace/env/cleanup-graphical-session.sh`.
- KDE reprend le look et les raccourcis d'Hyprland : `~/.config/kwinrulesrc` (sans bordure, sauf Ghostty
  qui garde sa barre de titre sur KDE), `~/.config/kwinrc` (9 bureaux), `~/.config/kglobalshortcutsrc` + lanceurs
  `~/.local/share/applications/net.local.*.desktop`.
- KWallet est le gestionnaire de secrets : déverrouillé via `pam_kwallet5` dans `/etc/pam.d/greetd`
  et `/usr/lib/pam_kwallet_init` lancé au démarrage d'Hyprland. gnome-keyring est masqué
  (`~/.local/share/dbus-1/services/org.freedesktop.secrets.service` redirige vers `kwalletd6`).

## Hyprland (configuration en **Lua**, pas en hyprlang)

- Entrée : `~/.config/hypr/hyprland.lua`, qui charge `~/.config/hypr/config/*.lua` :
  `animations`, `autostart`, `colors`, `decorations`, `environment`, `inputs`, `binds`, `misc`, `monitors`,
  `windowrules`, `workspaces`, puis `noctalia_colors` (via `pcall` ; fichier généré par matugen, nom hérité de Noctalia).
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
- Clavier : **pas** de `caps:shiftlock` dans `inputs.lua` (Verr. Maj façon Windows) : appuyer sur Verr. Maj
  pendant Deadlock fait planter le client Steam et fige le jeu (2026-10-20). Ne pas le remettre.
- Environnement de session : `~/.config/uwsm/env` (variables NVIDIA, `QT_QPA_PLATFORMTHEME=qt6ct`) et
  `env-hyprland` (sans `SDL_VIDEODRIVER` : le vieux SDL2 de certains jeux plante sur une liste) ; une modification demande de se déconnecter/reconnecter.
- Style : coins carrés (`rounding = 0`), espacements 5/10, bordures dont les couleurs suivent le fond
  d'écran (fichier généré `noctalia_colors.lua`).
- `autostart.lua` lance shell-maison (`qs -c shell-maison`), hypridle, `awww-daemon` puis `bin/fond` (fond au
  hasard), cliphist et la vue d'ensemble ; `binds.lua` appelle les scripts `bin/` du dépôt et
  `qs -c shell-maison ipc call …`.
- btop et cava : terminaux Ghostty en tuiles (classes `dev.btop` et `dev.cava`), à lancer à la main
  (plus de démarrage automatique depuis le 2026-10-07, pour limiter la chauffe du CPU).
- L'espace `gaming` est réservé aux jeux (règles dans `windowrules.lua`) : il ne doit pas être `default`
  dans `workspaces.lua`, sinon tout y démarre.
- Mod Organizer 2 a sa propre règle dans `windowrules.lua` (flottant, exclu de la règle des jeux) : traité
  comme un jeu, il boucle avec Hyprland sur la taille de fenêtre et sature le CPU (100 °C jeu fermé).

## shell-maison (shell de bureau en **Quickshell**)

- Dépôt séparé `~/Projects/shell-maison` (GitHub `shell-maison`, privé ; son `README.md` liste chaque composant),
  lié dans `~/.config/quickshell/shell-maison`. Relancer : `qs -c shell-maison` (Quickshell recharge les `.qml`
  modifiés tout seul).
- Composants : barre à gauche masquée (espaces, heure, Wallhaven, Claude, mises à jour), île en haut au centre
  (centre de contrôle, musique, son, système, Wi-Fi, Bluetooth, météo, calendrier, notifications, session),
  bulles de notification, OSD du volume, agent Polkit, verrouillage (`Lock.qml`, pile PAM `pam/lock` du dépôt,
  sans délai après un échec), veille (`hypr/hypridle.conf` : verrouillage à 10 min, écran éteint à 15 min),
  lumière nocturne (hyprsunset) et veille bloquée (`systemd-inhibit`), emojis, presse-papiers (cliphist),
  Wallhaven (`Wallhaven.qml`), captures (`bin/capture zone|ecran` : grim, slurp, satty ; Entrée copie,
  Ctrl + S enregistre dans `~/Pictures/Screenshots`), mises à jour (`bin/mises-a-jour`).
- Commandes : `qs -c shell-maison ipc call <cible> <fonction>` (`island toggle <onglet>`, `lock lock`,
  `system nightlight|caffeine`, `bar toggle`, `wallhaven toggle`…). Essais sans risque :
  `qs -c shell-maison ipc call lock test`, `ISLAND_TEST=<onglet>`, `BAR_TEST=1`,
  `GREETER_TEST=1 qs -p greeter/shell.qml`.
- Déconnexion : `uwsm stop` (repli `loginctl terminate-session` si la session n'est pas lancée par UWSM).
- Les **couleurs de tout le bureau suivent le fond d'écran** (je ne veux pas de palette fixe) :
  `bin/fond <image>` (ou sans argument : au hasard ; `fond get` : fond actuel) applique le fond avec **awww** puis
  lance **matugen** (`couleurs/matugen.toml`, modèles dans `couleurs/modeles/`) : Ghostty, btop, cava, GTK 3/4,
  schéma KDE `noctalia`, qt6ct, VS Code, Zen (`~/.cache/shell-maison/zen-browser/`), Pywalfox, Vesktop, dossiers
  Papirus (en arrière-plan), bordures Hyprland (`noctalia_colors.lua`), menu (`colors.json`), page d'accueil
  (`colors.css`). Pour changer ces couleurs, modifier le **modèle**, jamais le fichier généré.
- Fonds d'écran : `~/Pictures/Wallpapers`.

## Mes outils perso

- `~/Config/` : raccourcis (liens symboliques) vers tous les dossiers de config modifiables, avec un
  `README.md` qui explique chacun. Mettre à jour ses liens et son README quand une config est ajoutée ou déplacée.
- `~/.config/bureau.code-workspace` : configs du bureau dans VS Code (fichiers générés en lecture seule), ouvert
  sur l'espace 2 à la connexion par `autostart.lua`.
- `~/.local/bin/hypr-keybinds` : aide des raccourcis (Super + K), lit `hyprctl binds -j` (Hyprland seulement).
- `~/.local/share/keybind-editor/kbe` : éditeur de raccourcis (Super + Shift + K, Hyprland seulement).
- Carrousel de fonds d'écran en **Quickshell 0.3.1** (QML) : `~/.config/quickshell/wallpicker/shell.qml`,
  lancé par `~/.local/bin/wallpicker-toggle` (Super + Ctrl + Espace et Super + Shift + W). Il applique le
  fond via `bin/fond` de shell-maison.
- Bouton **Claude** dans la barre de shell-maison (`Bar.qml`, icône `claude.svg` du dépôt) : ouvre `claude`
  dans Ghostty, dans le dossier `~/.config`
  (pas `~`, pour lequel Claude Code redemande la confiance à chaque lancement).
- `~/.local/bin/jackify` : lance Jackify (installateur de modpacks Wabbajack) depuis sa version extraite
  `~/Applications/Jackify-app` (ne pas renommer ce dossier) ; `Jackify.AppImage` est trop lente à se
  monter ici, et l'entrée de menu créée par Jackify est refusée par UWSM. Les liens `nxm://` de Nexus
  passent par `net.local.nxm.desktop` → `jackify` (l'entrée de Jackify plante, faute de PySide6 dans le
  Python du système). Journaux : `~/Jackify/logs/`.
- `~/.local/bin/steam-open` : ouvre la fenêtre de Steam (`steam://open/main`) ; `steam` seul ne fait rien
  quand Steam tourne déjà. Utilisé par `~/.local/share/applications/steam.desktop`.
- `~/.local/bin/reboot-windows` : redémarre une seule fois sous Windows (`efibootmgr --bootnext` via
  `pkexec`, le démarrage suivant revient à Limine). Entrée Windows du menu Quickshell.
- `~/.local/bin/code-wait` : `code --wait` sans les avertissements de `~/.config/code-flags.conf` (sert d'`EDITOR`).
- `~/.local/bin/auto-update` : à l'ouverture de session (autostart `auto-update.desktop`), s'il y a des
  mises à jour (pacman, AUR, Flatpak), notification avec bouton « Mettre à jour » qui lance
  `bin/mises-a-jour` de shell-maison (paru + Flatpak dans Ghostty).
- Menu façon Omarchy en **Quickshell** : `~/.config/quickshell/menu/shell.qml`, lancé par `~/.local/bin/menu-toggle`
  (Super seul, Super + Espace). Couleurs via le modèle matugen `menu_colors` → `colors.json` (généré). L'entrée
  Manager ouvre la fenêtre Manager (paquets). Update = `paru -Syu --noconfirm` + `flatpak update -y`
  (snapshots via `snap-pac`). Applis triées par usage : `~/.local/state/quickshell-menu/usage.json`.
- Vue d'ensemble des espaces de travail en **Quickshell** (Hyprland) : `~/.config/quickshell/overview/shell.qml`,
  lancée par `autostart.lua` (`qs -c overview`), coin actif en haut à gauche, couleurs du menu ; glisser une
  fenêtre sur un autre espace l'y envoie, glisser le numéro d'un espace sur un autre les échange. Bascule :
  `qs -c overview ipc call overview toggle`. Sous KDE, même coin via KWin (`[Effect-overview]` dans `kwinrc`).
- Fenêtre **Manager** en Quickshell (paquets officiels + AUR) :
  `~/.config/quickshell/manager/shell.qml`, données via `~/.local/bin/manager-data` (JSON), ouverte par
  `~/.local/bin/manager-open [add|installed]`. Mots de passe via l'agent Polkit de shell-maison (`pkexec`).
  Couleurs partagées avec le menu (`menu/colors.json`).

## Applis et thèmes

- Terminal **Ghostty** (`~/.config/ghostty/config`), shell fish (`~/.config/fish/config.fish`),
  prompt **Starship** (`~/.config/starship.toml`, couleurs ANSI pour suivre Ghostty), accueil
  **fastfetch** (`~/.config/fastfetch/config.jsonc`, couleurs ANSI aussi).
- Ghostty : `performable:ctrl+v=paste_from_clipboard` → Ctrl + V colle le texte ; sans texte (image), la
  touche passe à l'appli (Claude Code colle alors l'image). Ne pas retirer `performable:`.
- Navigateurs : Firefox (Pywalfox, navigateur par défaut) et Zen ; éditeur VS Code officiel (`code`) ;
  Discord : Vesktop (thème généré par matugen) ; Vesktop et le Discord officiel quittent vraiment à la fermeture
  de la fenêtre (réduction en arrière-plan désactivée dans leur `settings.json`).
- Fichiers : **yazi** dans Ghostty, lancé par `~/.local/bin/yazi-open` (classe `dev.yazi`, fenêtre
  flottante, Super + E ; rend Ctrl + V, Ctrl + Maj + N et Ctrl + Tab à yazi, raccourcis dans
  `~/.config/yazi/keymap.toml`), thème `flavors/ansi.yazi` (couleurs ANSI : suit Ghostty en direct, sans
  redémarrer yazi) ;
  `net.local.yazi.desktop` ouvre les dossiers (`inode/directory`) et sert d'entrée de menu, en fenêtre
  normale (classe `dev.yazi.tuile` par `YAZI_CLASS`, hors de la règle flottante) ; l'entrée « Yazi File Manager » du
  paquet est masquée par `~/.local/share/applications/yazi.desktop`. Dolphin reste installé (« Afficher dans le dossier » des applis l'appelle encore).
  Le sélecteur de fichiers des applis (« Ouvrir… ») est yazi via `xdg-desktop-portal-termfilechooser`
  (`~/.config/xdg-desktop-portal-termfilechooser/config`, même fenêtre Ghostty que `yazi-open`).
- Page d'accueil et nouveaux onglets de Firefox et Zen : `~/.config/startpage/index.html` (accueil
  déclaré dans le `user.js` de chaque profil ; nouveaux onglets par `autoconfig.js` + `newtab.cfg`,
  sources dans `~/.config/startpage/newtab/`, copiés dans `/usr/lib/firefox` et `/opt/zen-browser-bin`,
  à recopier si une mise à jour les retire).
- `EDITOR=code-wait` (dans `config.fish`) : Ctrl + G dans Claude Code ouvre le prompt dans VS Code.
- Icônes : **Papirus-Dark** (`kdeglobals`, `qt6ct.conf`, gsettings), dossiers colorés par matugen.
- Thème Qt : **qt6ct-kde**, schéma de couleurs KDE `noctalia` (généré par matugen, nom hérité). Les applis GTK 4 ne rechargent leurs
  couleurs qu'au démarrage (limite de GTK).
- Curseur choisi avec `nwg-look`.
- Démarrage automatique commun à tous les bureaux : `~/.config/autostart/` (Steam, fenêtre ouverte à la connexion).
- Skyrim SE (Anniversary Edition, 1.7.104) : jeu en **anglais**, sous Proton 11.0 dans Steam, 74 contenus
  Creation Club (menu Creations, compte Bethesda.net). **Modpack perso** en construction (Tuxborn essayé
  puis supprimé le 2026-10-06) : Mod Organizer 2 portable dans `~/Games/Skyrim-Modpack`, entrée Steam
  **« Skyrim Modpack »** créée par Jackify, sous **GE-Proton10-14** (installé à la main dans
  `compatibilitytools.d` ; Proton 11 casse le système de fichiers virtuel de MO2), jeu lancé par SKSE
  depuis MO2. Les mods se téléchargent à la main sur Nexus (« Mod manager download », compte gratuit) et
  s'installent par les scripts de `~/.local/share/skyrim-modpack-outils/` (`installe_*.py`, MO2 fermé ;
  recherche Nexus et liste de référence Gate to Sovngarde au même endroit).
- Limites de la machine pour le pack : 16 Go de RAM (un pack trop lourd fait tuer le jeu par
  `systemd-oomd`) et processeur à 100 °C en charge ; fermer Firefox et Discord avant de jouer ; DLSS par la
  touche Fin en jeu (Community Shaders → Upscaling). Ne jamais lancer deux Skyrim à la fois, ni couper le
  jeu pendant qu'il télécharge des contenus Creation Club ; télécharger ceux-ci depuis le Skyrim d'origine,
  pas depuis MO2 (sinon ils atterrissent dans `overwrite`).
- Google Drive : montage rclone du distant `gdrive:` sur `~/GoogleDrive`
  (`~/.config/systemd/user/rclone-gdrive.service`, cache VFS complet, 5 Go max ;
  client_id OAuth personnel, créé dans la console Google Cloud). Ne pas utiliser `kio-gdrive`.

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
- Exclus : `*.bak`, `.config/hypr/config/noctalia_colors.lua`,
  `.config/quickshell/menu/colors.json`, `.config/startpage/colors.css`.
- shell-maison a son propre dépôt (`~/Projects/shell-maison`, `git push` direct), hors de `dots`.
- Les fichiers système (`/etc/greetd` (l'écran de connexion vient de `shell-maison/greeter/`), `/etc/pam.d/greetd`,
  `/etc/systemd/logind.conf.d`, `/usr/share/wayland-sessions/hyprland-maison-uwsm-clean.desktop`, les copies de
  `autoconfig.js` et `newtab.cfg` dans `/usr/lib/firefox` et `/opt/zen-browser-bin`) ne sont **pas** dans ce dépôt.

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
- ajoute un outil perso (script dans `~/.local/bin`, composant Quickshell ou de shell-maison) ;
- change de matériel (carte graphique, écran, clavier) ;
- change une préférence ou une règle de fonctionnement ;
- modifie ma méthode de sauvegarde des dotfiles.

Seules exceptions : un raccourci ajouté ou modifié dans `binds.lua` (il se décrit lui-même), un
ajustement de valeur (tailles, vitesses, espacements, police), un changement de fond d'écran,
l'installation d'une appli secondaire.

Garde ce fichier concis : c'est une carte de mon système et de mes règles, pas une documentation
complète.
