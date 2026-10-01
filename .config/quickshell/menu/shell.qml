// Menu façon Omarchy : liste verticale de catégories (applis, actions, réglages, maintenance).
// Taper pour chercher (à la racine : dans tout le menu), ↑/↓ pour choisir, Entrée pour ouvrir,
// Échap ou Retour arrière (champ vide) pour revenir, clic à côté pour fermer.
// Couleurs : colors.json, généré par Noctalia à partir du fond d'écran (modèle menu_colors).
// Lancement : ~/.local/bin/menu-toggle (qs -c menu)

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        id: win

        // Réglages
        readonly property string home: Quickshell.env("HOME")
        readonly property string fontName: "JetBrainsMono Nerd Font"
        readonly property int boxWidth: 320
        readonly property int rowH: 34
        readonly property int maxRows: 18
        readonly property int maxRecent: 15

        // Couleurs par défaut, remplacées par colors.json
        property var c: ({
            surface: "#1b211f", surface_container: "#252b2a", surface_container_high: "#303634",
            on_surface: "#dde4e1", on_surface_variant: "#bec9c5", primary: "#83d5c6", outline: "#899390"
        })

        property var stack: []          // sous-menus ouverts
        property var shown: []          // lignes affichées
        property var recentIds: []      // applis lancées depuis ce menu
        property var noctaliaRecent: [] // historique du lanceur Noctalia
        property var usage: ({})        // nombre de lancements depuis ce menu, par appli
        property var noctaliaUsage: ({}) // nombre de lancements depuis le lanceur Noctalia

        // Les applis sont chargées en arrière-plan au premier accès : on recalcule quand elles arrivent
        readonly property var entries: DesktopEntries.applications.values
        onEntriesChanged: refreshTimer.restart()
        Timer { id: refreshTimer; interval: 50; onTriggered: win.refresh(true) }

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "menu"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // ---- Fichiers ----

        FileView {
            path: win.home + "/.config/quickshell/menu/colors.json"
            watchChanges: true
            onFileChanged: reload()
            onLoaded: {
                try { win.c = Object.assign({}, win.c, JSON.parse(text())) } catch (e) {}
            }
        }

        FileView {
            id: recentFile
            path: win.home + "/.local/state/quickshell-menu/recent.json"
            blockWrites: true
            printErrors: false
            onLoaded: {
                try { win.recentIds = JSON.parse(text()) } catch (e) {}
            }
        }

        FileView {
            path: win.home + "/.local/state/noctalia/recently_used.json"
            onLoaded: {
                try {
                    win.noctaliaRecent = (JSON.parse(text()).Applications || [])
                        .map(p => p.split("/").pop().replace(/\.desktop$/, ""))
                } catch (e) {}
            }
        }

        FileView {
            id: usageFile
            path: win.home + "/.local/state/quickshell-menu/usage.json"
            blockWrites: true
            printErrors: false
            onLoaded: {
                try { win.usage = JSON.parse(text()); refreshTimer.restart() } catch (e) {}
            }
        }

        FileView {
            path: win.home + "/.local/state/noctalia/usage_counts.json"
            printErrors: false
            onLoaded: {
                try {
                    const counts = JSON.parse(text()).Applications || {}
                    const out = {}
                    for (const p in counts)
                        out[p.split("/").pop().replace(/\.desktop$/, "")] = counts[p]
                    win.noctaliaUsage = out
                    refreshTimer.restart()
                } catch (e) {}
            }
        }

        // ---- Actions ----

        function run(args) {
            Quickshell.execDetached(args)
            Qt.quit()
        }
        // Laisse le menu disparaître avant d'agir (captures, pipette…)
        function runLater(cmd) { run(["sh", "-c", "sleep 0.3; " + cmd]) }
        function msg(...args) { run(["noctalia", "msg"].concat(args)) }
        function app(...args) { run(["uwsm", "app", "--"].concat(args)) }
        function url(u) { run(["xdg-open", u]) }
        function edit(p) { app("code", p) }
        function term(script) {
            app("ghostty", "--class=dev.menu", "-e", "bash", "-c",
                script + '; echo; read -rp "Press Enter to close…"')
        }

        // ---- Applis ----

        function normId(id) { return id.replace(/\.desktop$/, "") }

        function useCount(e) {
            const id = normId(e.id)
            return (usage[id] || 0) + (noctaliaUsage[id] || 0)
        }

        // Les plus utilisées d'abord, puis par ordre alphabétique
        function allApps() {
            return entries
                .filter(e => !e.noDisplay)
                .sort((a, b) => useCount(b) - useCount(a) || a.name.localeCompare(b.name))
        }

        // Applis masquées des catégories et de All, mais trouvables par la recherche
        readonly property var hiddenIds: ["bssh", "bvnc", "avahi-discover", "assistant", "designer", "linguist", "qdbusviewer"]

        function listedApps() {
            return allApps().filter(e => !hiddenIds.includes(normId(e.id)))
        }

        function appItem(e) {
            return {
                name: e.name,
                image: e.icon ? Quickshell.iconPath(e.icon, true) : "",
                glyph: "",
                run: () => win.launchApp(e)
            }
        }

        function launchApp(e) {
            const id = normId(e.id)
            const ids = [id].concat(recentIds.filter(x => x !== id)).slice(0, maxRecent)
            recentFile.setText(JSON.stringify(ids))
            const counts = Object.assign({}, usage)
            counts[id] = (counts[id] || 0) + 1
            usageFile.setText(JSON.stringify(counts))
            app(id + ".desktop")
        }

        // Une seule catégorie par appli : la première qui correspond, dans cet ordre
        readonly property var catOrder: [
            ["Games", ["Game"]],
            ["Development", ["Development"]],
            ["Graphics", ["Graphics"]],
            ["Multimedia", ["AudioVideo", "Audio", "Video"]],
            ["Office", ["Office", "FileManager"]],
            ["Internet", ["Network"]],
            ["System", ["Settings", "System", "Utility"]]
        ]

        function categoryOf(e) {
            for (const [name, cats] of catOrder)
                if (e.categories.some(k => cats.includes(k))) return name
            return ""
        }

        function appsIn(name) {
            return listedApps().filter(e => categoryOf(e) === name).map(appItem)
        }

        // Sous-sections de System : d'abord par appli, puis selon ses catégories, sinon Tools
        readonly property var systemSectionById: ({
            "nvidia-settings": "Hardware", "org.cachyos.KernelManager": "Hardware",
            "org.cachyos.scx-manager": "Hardware", "org.kde.partitionmanager": "Hardware",
            "org.kde.kinfocenter": "Hardware", "lstopo": "Hardware",
            "btop": "Monitoring", "org.kde.plasma-systemmonitor": "Monitoring", "org.kde.filelight": "Monitoring",
            "btrfs-assistant": "Maintenance", "limine-snapper-restore": "Maintenance", "arch-update": "Maintenance",
            "cachyos-pi": "Maintenance", "com.shellyorg.shelly": "Maintenance", "cachyos-hello": "Maintenance"
        })

        function systemSection(e) {
            const known = systemSectionById[normId(e.id)]
            if (known) return known
            const c = e.categories
            if (c.includes("TerminalEmulator")) return "Terminals"
            if (c.includes("HardwareSettings")) return "Hardware"
            if (c.includes("Monitor")) return "Monitoring"
            if (c.includes("Settings")) return "Settings"
            return "Tools"
        }

        function systemApps(section) {
            return listedApps().filter(e => categoryOf(e) === "System" && systemSection(e) === section).map(appItem)
        }

        function recentApps() {
            const apps = allApps()
            const ids = recentIds.concat(noctaliaRecent.filter(x => !recentIds.includes(x)))
            return ids.map(id => apps.find(e => normId(e.id) === id))
                .filter(e => e).slice(0, maxRecent).map(appItem)
        }

        // ---- Contenu du menu ----

        readonly property var root: [
            // Applis
            { name: "All", glyph: "", apps: () => listedApps().map(appItem) },
            { name: "Recent", glyph: "", apps: () => recentApps() },
            { name: "Internet", glyph: "", apps: () => appsIn("Internet") },
            { name: "Multimedia", glyph: "", apps: () => appsIn("Multimedia") },
            { name: "Games", glyph: "", apps: () => appsIn("Games") },
            { name: "Office", glyph: "", apps: () => appsIn("Office") },
            { name: "Graphics", glyph: "", apps: () => appsIn("Graphics") },
            { name: "Development", glyph: "", apps: () => appsIn("Development") },

            // Actions et style
            { name: "Trigger", glyph: "", children: [
                { name: "Screenshot region", glyph: "", run: () => runLater("noctalia msg screenshot-region") },
                { name: "Screenshot screen", glyph: "", run: () => runLater("noctalia msg screenshot-fullscreen") },
                { name: "Annotate screen", glyph: "", run: () => runLater("noctalia msg screenshot-annotate") },
                { name: "Color picker", glyph: "", run: () => runLater("hyprpicker -a") },
                { name: "Night light", glyph: "", run: () => msg("nightlight-force-toggle") },
                { name: "Caffeine", glyph: "", run: () => msg("caffeine-toggle") },
                { name: "Toggle bar", glyph: "", run: () => msg("bar-toggle") }
            ] },
            { name: "Style", glyph: "", children: [
                { name: "Wallpaper carousel", glyph: "", run: () => run([home + "/.local/bin/wallpicker-toggle"]) },
                { name: "Wallpaper panel", glyph: "", run: () => msg("panel-toggle", "wallpaper") },
                { name: "Hyprland look", glyph: "", run: () => edit(home + "/.config/hypr/config/decorations.lua") }
            ] },
            // Réglages : Setup, Settings et System réunis, en sous-sections
            { name: "System", glyph: "\uf013", children: [
                { name: "Connections", glyph: "\uf1eb", children: [
                    { name: "Audio", glyph: "\uf028", run: () => msg("panel-toggle", "control-center", "audio") },
                    { name: "Wi-Fi", glyph: "\uf1eb", run: () => msg("panel-toggle", "control-center", "network") },
                    { name: "Bluetooth", glyph: "\uf293", run: () => msg("panel-toggle", "control-center", "bluetooth") }
                ] },
                { name: "Settings", glyph: "\uf1de", apps: () => systemApps("Settings"), children: [
                    { name: "Keybindings editor", glyph: "\uf11c", run: () => app("ghostty", "--class=dev.keybinds", "-e",
                        home + "/.local/share/keybind-editor/kbe", home + "/.config/hypr/config/binds.lua") },
                    { name: "Config files", glyph: "", children: [
                        { name: "Hyprland", glyph: "", run: () => edit(home + "/.config/hypr") },
                        { name: "Noctalia", glyph: "", run: () => edit(home + "/.config/noctalia/config.toml") },
                        { name: "Ghostty", glyph: "", run: () => edit(home + "/.config/ghostty/config") },
                        { name: "Fish", glyph: "", run: () => edit(home + "/.config/fish/config.fish") },
                        { name: "Starship", glyph: "", run: () => edit(home + "/.config/starship.toml") },
                        { name: "This menu", glyph: "", run: () => edit(home + "/.config/quickshell/menu/shell.qml") },
                        { name: "CLAUDE.md", glyph: "", run: () => edit(home + "/.claude/CLAUDE.md") }
                    ] }
                ] },
                { name: "Hardware", glyph: "\uf2db", apps: () => systemApps("Hardware") },
                { name: "Monitoring", glyph: "\uf080", apps: () => systemApps("Monitoring") },
                { name: "Maintenance", glyph: "\uf0ad", apps: () => systemApps("Maintenance"), children: [
                    { name: "Mirrors", glyph: "\uf0ac", run: () => term("sudo cachyos-rate-mirrors") }
                ] },
                { name: "Terminals", glyph: "\uf120", apps: () => systemApps("Terminals") },
                { name: "Tools", glyph: "\uf1b2", apps: () => systemApps("Tools") }
            ] },

            // Maintenance
            // Paquets (officiels + AUR) et plugins Noctalia : fenêtre Manager (~/.config/quickshell/manager)
            { name: "Manager", glyph: "", run: () => app(home + "/.local/bin/manager-open") },
            // Tout mettre à jour sans confirmation (snapshots automatiques via snap-pac)
            { name: "Update", glyph: "", run: () => term(
                'paru -Syu --noconfirm && flatpak update -y && echo && echo "✓ Done" ' +
                '|| { echo; echo "✗ Update failed: read the message above"; }') },

            // Aide
            { name: "Learn", glyph: "", children: [
                { name: "Keybindings", glyph: "", run: () => app("ghostty", "--class=dev.keybinds", "-e", home + "/.local/bin/hypr-keybinds") },
                { name: "Hyprland wiki", glyph: "", run: () => url("https://wiki.hypr.land") },
                { name: "Arch wiki", glyph: "", run: () => url("https://wiki.archlinux.org") },
                { name: "CachyOS wiki", glyph: "", run: () => url("https://wiki.cachyos.org") },
                { name: "Noctalia docs", glyph: "", run: () => url("https://docs.noctalia.dev/noctalia/") },
                { name: "Quickshell docs", glyph: "", run: () => url("https://quickshell.org/docs/") }
            ] },
            { name: "About", glyph: "", run: () => term("fastfetch") }
        ]

        // Toutes les actions finales (pour la recherche depuis la racine)
        function leaves(items) {
            let out = []
            for (const it of items) {
                if (it.children) out = out.concat(leaves(it.children))
                else if (it.run) out.push(it)
            }
            return out
        }

        // ---- Navigation ----

        // keepIndex : garde la ligne choisie (rafraîchissement en arrière-plan)
        function refresh(keepIndex) {
            const q = search.text.trim().toLowerCase()
            const node = stack.length ? stack[stack.length - 1] : null
            let items = !node ? root : (node.children || []).concat(node.apps ? node.apps() : [])
            if (q !== "") {
                if (!node)
                    items = root.concat(leaves(root)).concat(allApps().map(appItem))
                items = items.filter(it => it.name.toLowerCase().includes(q))
            }
            const idx = list.currentIndex
            shown = items
            list.currentIndex = keepIndex ? Math.min(Math.max(idx, 0), items.length - 1) : 0
        }

        function open(it) {
            if (!it) return
            if (it.run) { it.run(); return }
            stack = stack.concat([it])
            search.text = ""
            refresh()
        }

        function back() {
            if (stack.length === 0) { Qt.quit(); return }
            stack = stack.slice(0, -1)
            search.text = ""
            refresh()
        }

        Component.onCompleted: refresh()

        // ---- Interface ----

        // Clic à côté du menu : fermer
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }

        Rectangle {
            id: box
            anchors.centerIn: parent
            width: win.boxWidth
            height: content.implicitHeight + 28
            color: win.c.surface
            border.color: win.c.primary
            border.width: 2

            // Empêche les clics dans le menu de le fermer
            MouseArea { anchors.fill: parent }

            Column {
                id: content
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                spacing: 8

                // Champ de recherche
                Rectangle {
                    width: parent.width
                    height: 36
                    color: win.c.surface_container

                    TextInput {
                        id: search
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        verticalAlignment: TextInput.AlignVCenter
                        color: win.c.on_surface
                        selectionColor: win.c.primary
                        font.family: win.fontName
                        font.pixelSize: 14
                        focus: true
                        clip: true
                        onTextChanged: win.refresh()
                        Component.onCompleted: forceActiveFocus()

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Down || (event.key === Qt.Key_J && event.modifiers & Qt.ControlModifier)) {
                                list.incrementCurrentIndex()
                            } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_K && event.modifiers & Qt.ControlModifier)) {
                                list.decrementCurrentIndex()
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                win.open(win.shown[list.currentIndex])
                            } else if (event.key === Qt.Key_Escape) {
                                if (search.text !== "") search.text = ""
                                else win.back()
                            } else if (event.key === Qt.Key_Backspace && search.text === "" && win.stack.length) {
                                win.back()
                            } else {
                                return
                            }
                            event.accepted = true
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: search.text === ""
                            text: win.stack.length ? win.stack[win.stack.length - 1].name + "…" : "Go…"
                            color: win.c.on_surface_variant
                            opacity: 0.6
                            font: search.font
                        }
                    }
                }

                ListView {
                    id: list
                    width: parent.width
                    height: Math.max(1, Math.min(count, win.maxRows)) * win.rowH
                    model: win.shown
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    highlightMoveDuration: 0
                    keyNavigationWraps: true

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool selected: ListView.isCurrentItem

                        width: list.width
                        height: win.rowH
                        color: selected ? win.c.surface_container_high : "transparent"

                        Item {
                            id: iconBox
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            width: 20
                            height: 20

                            Image {
                                id: appIcon
                                anchors.fill: parent
                                visible: status === Image.Ready
                                source: row.modelData.image || ""
                                sourceSize: Qt.size(40, 40)
                                asynchronous: true
                                smooth: true
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: !appIcon.visible
                                text: row.modelData.glyph || ""
                                color: win.c.primary
                                font.family: win.fontName
                                font.pixelSize: 15
                            }
                        }

                        Text {
                            anchors { left: iconBox.right; leftMargin: 14; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                            text: row.modelData.name
                            elide: Text.ElideRight
                            color: row.selected ? win.c.primary : win.c.on_surface
                            font.family: win.fontName
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = row.index
                            onClicked: win.open(row.modelData)
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: list.count === 0
                        text: "Nothing found"
                        color: win.c.on_surface_variant
                        font.family: win.fontName
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
