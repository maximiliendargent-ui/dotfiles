// Carrousel de fonds d'écran : cartes inclinées, la carte du centre mise en avant.
// Flèches / molette pour naviguer : le fond est appliqué dès qu'on s'arrête sur une carte.
// Espace pour un fond au hasard, Entrée, Échap ou clic pour fermer.
// Le fond d'écran est appliqué par bin/fond de shell-maison (awww + matugen, qui met à jour toutes les couleurs).
// Lancement : qs -c wallpicker

import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        id: win

        // Réglages
        readonly property string wallDir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
        readonly property real cardW: 300
        readonly property real cardH: 380
        readonly property real skew: 0.22   // inclinaison des cartes
        readonly property int previewDelay: 400   // ms d'arrêt sur une carte avant d'appliquer
        property string currentPath: ""
        property bool ready: false   // fond actuel connu : on peut appliquer en naviguant

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "wallpicker"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Fond et couleurs : bin/fond de shell-maison (awww + matugen)
        readonly property string fond: Quickshell.env("HOME") + "/.config/quickshell/shell-maison/bin/fond"

        function apply(path) {
            if (!ready || !path || path === currentPath) return
            currentPath = path
            Quickshell.execDetached([win.fond, path])
        }

        // Applique la carte sélectionnée sans attendre, puis ferme le carrousel
        function applyAndQuit() {
            previewTimer.stop()
            if (folder.count > 0) apply(folder.get(list.currentIndex, "filePath"))
            Qt.quit()
        }

        // Saute à une carte au hasard, différente de la carte sélectionnée
        function selectRandom() {
            if (folder.count < 2) return
            let i = Math.floor(Math.random() * (folder.count - 1))
            if (i >= list.currentIndex) i++
            list.currentIndex = i
        }

        function selectCurrent() {
            if (folder.status !== FolderListModel.Ready || currentPath === "") return
            for (let i = 0; i < folder.count; i++) {
                if (folder.get(i, "filePath") === currentPath) {
                    list.currentIndex = i
                    list.positionViewAtIndex(i, PathView.Center)
                    return
                }
            }
        }

        // Applique le fond d'écran quand on s'arrête sur une carte
        Timer {
            id: previewTimer
            interval: win.previewDelay
            onTriggered: if (folder.count > 0) win.apply(folder.get(list.currentIndex, "filePath"))
        }

        // Récupère le fond d'écran actuel pour le présélectionner
        Process {
            command: [win.fond, "get"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    win.currentPath = this.text.trim()
                    win.selectCurrent()
                    win.ready = true
                }
            }
        }

        FolderListModel {
            id: folder
            folder: "file://" + win.wallDir
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
            showDirs: false
            sortField: FolderListModel.Name
            onStatusChanged: win.selectCurrent()
        }

        // Fond sombre : un clic à côté ferme le carrousel
        Rectangle {
            anchors.fill: parent
            color: "#d0000000"
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }
        }

        // Carrousel circulaire : après la dernière carte, on retombe sur la première
        PathView {
            id: list

            readonly property real step: win.cardW + 10   // écart entre deux cartes
            // Nombre impair de cartes affichées, assez pour dépasser l'écran des deux côtés
            readonly property int shown: Math.max(1, Math.min(folder.count, 2 * Math.ceil(width / step / 2) + 3))

            anchors.centerIn: parent
            width: parent.width
            height: win.cardH * 1.3
            model: folder
            focus: true
            pathItemCount: shown
            cacheItemCount: 4
            highlightRangeMode: PathView.StrictlyEnforceRange
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightMoveDuration: 300
            path: Path {
                startX: list.width / 2 - list.shown * list.step / 2
                startY: list.height / 2
                PathLine {
                    x: list.width / 2 + list.shown * list.step / 2
                    y: list.height / 2
                }
            }
            Component.onCompleted: forceActiveFocus()

            onCurrentIndexChanged: previewTimer.restart()

            Keys.onLeftPressed: decrementCurrentIndex()
            Keys.onRightPressed: incrementCurrentIndex()
            Keys.onReturnPressed: win.applyAndQuit()
            Keys.onEnterPressed: win.applyAndQuit()
            Keys.onSpacePressed: win.selectRandom()
            Keys.onEscapePressed: Qt.quit()

            WheelHandler {
                onWheel: event => {
                    if (event.angleDelta.y < 0) list.incrementCurrentIndex()
                    else list.decrementCurrentIndex()
                }
            }

            delegate: Item {
                id: slot
                required property string filePath
                required property int index
                readonly property bool isCurrent: PathView.isCurrentItem

                width: win.cardW
                height: list.height
                z: isCurrent ? 10 : 0

                Item {
                    id: card
                    anchors.centerIn: parent
                    width: win.cardW
                    height: win.cardH
                    scale: slot.isCurrent ? 1.15 : 0.85
                    opacity: slot.isCurrent ? 1.0 : 0.45
                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 300 } }

                    // Inclinaison de la carte (parallélogramme)
                    transform: Matrix4x4 {
                        matrix: Qt.matrix4x4(1, -win.skew, 0, win.skew * win.cardH / 2,
                                             0, 1, 0, 0,
                                             0, 0, 1, 0,
                                             0, 0, 0, 1)
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "#222222"
                        border.width: slot.isCurrent ? 3 : 0
                        border.color: "white"
                        clip: true

                        // Image « redressée » dans la carte inclinée, pour ne pas être déformée
                        Image {
                            width: parent.width + win.skew * parent.height
                            height: parent.height
                            x: -win.skew * parent.height / 2
                            source: "file://" + slot.filePath
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            sourceSize.height: win.cardH * 1.5
                            transform: Matrix4x4 {
                                matrix: Qt.matrix4x4(1, win.skew, 0, -win.skew * win.cardH / 2,
                                                     0, 1, 0, 0,
                                                     0, 0, 1, 0,
                                                     0, 0, 0, 1)
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: card
                    onClicked: slot.isCurrent ? win.applyAndQuit() : list.currentIndex = slot.index
                }
            }
        }

        // Nom du fichier sélectionné
        Text {
            id: fileName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: list.bottom
            anchors.topMargin: 20
            text: folder.count > 0 ? folder.get(list.currentIndex, "fileName") : "Aucune image dans ~/Pictures/Wallpapers"
            color: "white"
            font.pixelSize: 16
            font.family: "Maple Mono NF"
        }

        // Rappel des touches
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: fileName.bottom
            anchors.topMargin: 14
            text: "←  →  naviguer (appliqué à l'arrêt)    ·    Espace  aléatoire    ·    Entrée / Échap  fermer"
            color: "white"
            opacity: 0.55
            font.pixelSize: 13
            font.family: "Maple Mono NF"
        }
    }
}
