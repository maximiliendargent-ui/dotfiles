// Vue d'ensemble des espaces de travail pour Hyprland, comme le coin actif de niri :
// pousser la souris dans le coin haut gauche affiche les 9 espaces avec un aperçu de leurs fenêtres.
// Clic sur un espace ou une fenêtre pour y aller ; Échap, clic à côté ou retour dans le coin pour fermer.
// Glisser une fenêtre sur un autre espace l'y envoie ; glisser le numéro (ou le fond) d'un espace sur un autre les échange.
// Pousser la souris dans le coin haut droit ouvre le menu de session de Noctalia (éteindre, redémarrer…),
// au milieu du bord haut son centre de contrôle.
// Couleurs : celles du menu (menu/colors.json, généré par Noctalia à partir du fond d'écran).
// Lancement : au démarrage d'Hyprland (autostart.lua, qs -c overview), reste en arrière-plan.
// Depuis un raccourci ou un script : qs -c overview ipc call overview toggle

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland

ShellRoot {
    id: root

    // Réglages
    readonly property string home: Quickshell.env("HOME")
    readonly property string fontName: "Maple Mono NF"
    readonly property int count: 9      // espaces affichés
    readonly property int columns: 3
    readonly property int margin: 60    // autour de la grille
    readonly property int gap: 24       // entre deux espaces

    // Couleurs par défaut, remplacées par colors.json
    property var c: ({
        surface: "#1b211f", surface_container: "#252b2a", surface_container_high: "#303634",
        on_surface: "#dde4e1", on_surface_variant: "#bec9c5", primary: "#83d5c6", on_primary: "#003731",
        outline: "#899390", outline_variant: "#3f4946"
    })

    property bool open: false
    property bool armed: false  // la souris a quitté le coin depuis l'ouverture : y revenir ferme
    onOpenChanged: armed = false
    property int dropWs: 0      // espace survolé pendant un glisser-déposer
    property int rev: 0         // incrémenté pour reconstruire les aperçus après un déplacement

    // Hors d'Hyprland (essais) : fenêtres lues dans le fichier JSON désigné par OVERVIEW_MOCK
    readonly property bool onHyprland: !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
    // Session « Hyprland (Maison) » (SHELL_MAISON, ~/.config/uwsm/env-maison) : barre et bords du haut gérés par
    // ~/Projects/shell-maison ; ici, seul le coin haut gauche reste
    readonly property bool maison: !!Quickshell.env("SHELL_MAISON")
    property var mock: []

    readonly property int currentWs:
        onHyprland && Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    // Espace gaming : barre de Noctalia masquée (elle ne ressort plus au bord gauche), réaffichée en le quittant
    readonly property bool onGaming:
        onHyprland && !!Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.name === "gaming"
    onOnGamingChanged: if (!maison) Quickshell.execDetached(["noctalia", "msg", onGaming ? "bar-hide" : "bar-show"])

    function show() {
        if (onHyprland) Hyprland.refreshToplevels()
        open = true
    }

    // Coin et bords inactifs par-dessus une fenêtre en plein écran (vidéos) et sur l'espace gaming
    function hotZonesOff() {
        const ws = onHyprland ? Hyprland.focusedWorkspace : null
        return onGaming || (!!ws && ws.hasFullscreen)
    }

    function cornerHit() {
        if (hotZonesOff()) return
        show()
    }

    // Bords actifs : ouvrent un panneau de Noctalia, refermé quand la souris en sort
    // (noctalia-panel-hover ; mêmes exceptions que le coin)
    function edgeHit(panel) {
        if (hotZonesOff()) return
        Quickshell.execDetached([home + "/.local/bin/noctalia-panel-hover", panel])
    }

    // Avec une adresse : focus sur cette fenêtre (toplevel.activate() est ignoré tant que la vue a le clavier)
    function goTo(ws, addr) {
        const target = addr ? "{ window = \"address:" + addr + "\" }" : "{ workspace = " + ws + " }"
        Quickshell.execDetached(["hyprctl", "eval", "hl.dispatch(hl.dsp.focus(" + target + "))"])
        open = false
    }

    // Glisser-déposer : envoie ces fenêtres sur un espace, sans quitter la vue
    function moveLua(wins, ws) {
        return wins.map(w => "hl.dispatch(hl.dsp.window.move({ workspace = " + ws
            + ", window = \"address:" + w.address + "\", follow = false }))").join(" ")
    }
    function drop(lua) {
        dropWs = 0
        if (lua) Quickshell.execDetached(["hyprctl", "eval", lua])
        refresh.restart()
    }

    // Laisse à Hyprland le temps de déplacer, puis relit les positions et reconstruit les aperçus
    Timer {
        id: refresh
        interval: 200
        onTriggered: {
            if (root.onHyprland) Hyprland.refreshToplevels()
            root.rev++
        }
    }

    // Fenêtres d'un espace, en coordonnées de l'écran ; les flottantes au-dessus
    function windowsOn(ws) {
        if (!onHyprland) return mock.filter(w => w.ws === ws)
        const out = []
        for (const t of Hyprland.toplevels.values) {
            const o = t.lastIpcObject
            if (!o || !o.at || !o.size || !t.workspace || t.workspace.id !== ws) continue
            const m = t.monitor
            out.push({
                x: o.at[0] - (m ? m.x : 0), y: o.at[1] - (m ? m.y : 0), w: o.size[0], h: o.size[1],
                title: t.title, cls: o.class || "", floating: !!o.floating, toplevel: t.wayland,
                address: o.address
            })
        }
        return out.sort((a, b) => a.floating - b.floating)
    }

    // Les applis sont chargées en arrière-plan au premier accès : on les demande dès le démarrage
    readonly property var entries: DesktopEntries.applications.values

    function iconFor(cls) {
        const e = entries.length ? DesktopEntries.heuristicLookup(cls) : null
        return Quickshell.iconPath(e && e.icon ? e.icon : "application-x-executable", "application-x-executable")
    }

    FileView {
        path: root.home + "/.config/quickshell/menu/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.c = Object.assign({}, root.c, JSON.parse(text())) } catch (e) {}
        }
    }

    FileView {
        path: Quickshell.env("OVERVIEW_MOCK") || ""
        printErrors: false
        onLoaded: {
            try { root.mock = JSON.parse(text()) } catch (e) {}
        }
    }

    IpcHandler {
        target: "overview"
        function toggle(): void { if (root.open) root.open = false; else root.show() }
    }

    // ---- Coin actif : 1 pixel en haut à gauche ----

    PanelWindow {
        visible: !root.open
        anchors { top: true; left: true }
        implicitWidth: 1
        implicitHeight: 1
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "overview-corner"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.cornerHit()
        }
    }

    // ---- Coin actif : 1 pixel en haut à droite, ouvre le menu de session ----

    PanelWindow {
        visible: !root.open && !root.maison
        anchors { top: true; right: true }
        implicitWidth: 1
        implicitHeight: 1
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "session-edge"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.edgeHit("session")
        }
    }

    // ---- Bord actif : 1 pixel de haut au milieu du bord haut, ouvre le centre de contrôle ----

    PanelWindow {
        visible: !root.open && !root.maison
        anchors { top: true }
        implicitWidth: 400
        implicitHeight: 1
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "control-center-edge"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.edgeHit("control-center")
        }
    }

    // ---- Vue d'ensemble ----

    PanelWindow {
        id: win

        readonly property int rows: Math.ceil(root.count / root.columns)
        // Chaque espace est une réduction de l'écran : même échelle en largeur et en hauteur
        readonly property real cellScale: Math.min(
            (width - 2 * root.margin - (root.columns - 1) * root.gap) / root.columns / width,
            (height - 2 * root.margin - (rows - 1) * root.gap) / rows / height)

        visible: root.open
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "overview"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Rectangle { anchors.fill: parent; color: root.c.surface; opacity: 0.9 }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.open = false

            HoverHandler {
                onPointChanged: {
                    const p = point.position
                    if (p.x > 40 || p.y > 40) root.armed = true
                    else if (root.armed && p.x < 2 && p.y < 2) root.open = false
                }
            }

            MouseArea { anchors.fill: parent; onClicked: root.open = false }

            Grid {
                id: grid

                // Numéro de l'espace sous un point d'un élément (0 : aucun)
                function wsAt(item, x, y) {
                    const p = item.mapToItem(grid, x, y)
                    const cellAt = grid.childAt(p.x, p.y)
                    return cellAt && cellAt.ws ? cellAt.ws : 0
                }

                anchors.centerIn: parent
                columns: root.columns
                spacing: root.gap

                Repeater {
                    model: root.count

                    Rectangle {
                        id: cell

                        required property int index
                        readonly property int ws: index + 1
                        readonly property bool current: ws === root.currentWs

                        width: Math.round(win.width * win.cellScale)
                        height: Math.round(win.height * win.cellScale)
                        color: root.c.surface_container
                        property bool dragging: false  // une de ses fenêtres est en cours de glissement

                        border.width: root.dropWs === ws ? 4 : 2
                        border.color: current || root.dropWs === ws ? root.c.primary
                            : cellMouse.containsMouse ? root.c.outline : root.c.outline_variant
                        clip: !dragging
                        z: dragging ? 1 : 0

                        // Fond et numéro de l'espace. Clic : y aller ; relâché sur un autre espace : échanger leurs fenêtres
                        function dragOver(area, mouse) {
                            if (!area.pressed) return
                            const to = grid.wsAt(area, mouse.x, mouse.y)
                            root.dropWs = to === ws ? 0 : to
                        }
                        function dragEnd(area, mouse) {
                            const to = grid.wsAt(area, mouse.x, mouse.y)
                            if (to === ws) root.goTo(ws)
                            else if (to) root.drop(root.moveLua(root.windowsOn(ws), to)
                                + " " + root.moveLua(root.windowsOn(to), ws))
                            else root.dropWs = 0
                        }

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onPositionChanged: mouse => cell.dragOver(cellMouse, mouse)
                            onReleased: mouse => cell.dragEnd(cellMouse, mouse)
                        }

                        Repeater {
                            model: root.open ? (root.rev, root.windowsOn(cell.ws)) : []

                            Rectangle {
                                id: tile

                                required property var modelData

                                x: Math.round(modelData.x * win.cellScale)
                                y: Math.round(modelData.y * win.cellScale)
                                width: Math.round(modelData.w * win.cellScale)
                                height: Math.round(modelData.h * win.cellScale)
                                color: root.c.surface_container_high
                                border.width: 1
                                border.color: root.c.outline_variant
                                z: tileMouse.pressed ? 1 : 0

                                // Aperçu en direct ; tant qu'il n'y a pas d'image : icône et titre
                                ScreencopyView {
                                    id: view
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    captureSource: tile.modelData.toplevel
                                    live: root.open
                                    visible: hasContent
                                }

                                Column {
                                    visible: !view.hasContent
                                    anchors.centerIn: parent
                                    width: parent.width - 12
                                    spacing: 6

                                    IconImage {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        implicitSize: Math.max(16, Math.min(40, tile.height - 40))
                                        source: root.iconFor(tile.modelData.cls)
                                    }
                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        text: tile.modelData.title
                                        color: root.c.on_surface_variant
                                        font.family: root.fontName
                                        font.pixelSize: 11
                                    }
                                }

                                // Clic : aller à la fenêtre ; glissée sur un autre espace : l'y envoyer
                                MouseArea {
                                    id: tileMouse
                                    anchors.fill: parent
                                    property point grab  // point saisi, pour que l'aperçu suive la souris

                                    onPressed: mouse => grab = Qt.point(mouse.x, mouse.y)
                                    onPositionChanged: mouse => {
                                        const dx = mouse.x - grab.x, dy = mouse.y - grab.y
                                        if (!cell.dragging && Math.abs(dx) + Math.abs(dy) < 8) return
                                        cell.dragging = true
                                        tile.x += dx
                                        tile.y += dy
                                        const ws = grid.wsAt(tileMouse, grab.x, grab.y)
                                        root.dropWs = ws === cell.ws ? 0 : ws
                                    }
                                    onReleased: mouse => {
                                        const ws = grid.wsAt(tileMouse, mouse.x, mouse.y)
                                        if (ws === cell.ws && !cell.dragging) return root.goTo(cell.ws, tile.modelData.address)
                                        cell.dragging = false
                                        root.drop(ws && ws !== cell.ws ? root.moveLua([tile.modelData], ws) : "")
                                    }
                                }
                            }
                        }

                        // Numéro de l'espace : poignée pour échanger deux espaces (le fond est souvent couvert)
                        Rectangle {
                            x: 2; y: 2
                            width: 26; height: 22
                            color: cell.current ? root.c.primary : root.c.surface_container_high
                            MouseArea {
                                id: badgeMouse
                                anchors.fill: parent
                                cursorShape: Qt.OpenHandCursor
                                onPositionChanged: mouse => cell.dragOver(badgeMouse, mouse)
                                onReleased: mouse => cell.dragEnd(badgeMouse, mouse)
                            }
                            Text {
                                anchors.centerIn: parent
                                text: cell.ws
                                color: cell.current ? root.c.on_primary : root.c.on_surface
                                font.family: root.fontName
                                font.pixelSize: 13
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
