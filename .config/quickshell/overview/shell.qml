// Vue d'ensemble des espaces de travail pour Hyprland, comme le coin actif de niri :
// pousser la souris dans le coin haut gauche affiche les 9 espaces avec un aperçu de leurs fenêtres.
// Clic sur un espace ou une fenêtre pour y aller ; Échap, clic à côté ou retour dans le coin pour fermer.
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
    readonly property string fontName: "JetBrainsMono Nerd Font"
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

    // Hors d'Hyprland (essais) : fenêtres lues dans le fichier JSON désigné par OVERVIEW_MOCK
    readonly property bool onHyprland: !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
    property var mock: []

    readonly property int currentWs:
        onHyprland && Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    function show() {
        if (onHyprland) Hyprland.refreshToplevels()
        open = true
    }

    // Le coin ne réagit pas par-dessus une fenêtre en plein écran (jeux, vidéos)
    function cornerHit() {
        if (onHyprland && Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.hasFullscreen) return
        show()
    }

    function goTo(ws) {
        Quickshell.execDetached(["hyprctl", "eval", "hl.dispatch(hl.dsp.focus({ workspace = " + ws + " }))"])
        open = false
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
                title: t.title, cls: o.class || "", floating: !!o.floating, toplevel: t.wayland
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
                        border.width: 2
                        border.color: current ? root.c.primary
                            : cellMouse.containsMouse ? root.c.outline : root.c.outline_variant
                        clip: true

                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.goTo(cell.ws)
                        }

                        Repeater {
                            model: root.open ? root.windowsOn(cell.ws) : []

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

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (tile.modelData.toplevel) {
                                            tile.modelData.toplevel.activate()
                                            root.open = false
                                        } else {
                                            root.goTo(cell.ws)
                                        }
                                    }
                                }
                            }
                        }

                        // Numéro de l'espace
                        Rectangle {
                            x: 2; y: 2
                            width: 26; height: 22
                            color: cell.current ? root.c.primary : root.c.surface_container_high
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
