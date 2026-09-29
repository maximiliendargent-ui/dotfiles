// Carrousel de fonds d'écran : cartes inclinées, la carte du centre mise en avant.
// Flèches / molette pour naviguer, Entrée ou clic pour appliquer, Échap pour fermer.
// Le fond d'écran est appliqué par Noctalia (qui met à jour toutes les couleurs).
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
        property string currentPath: ""

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "wallpicker"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        function apply(path) {
            setter.command = ["noctalia", "msg", "wallpaper-set", path]
            setter.running = true
        }

        function selectCurrent() {
            if (folder.status !== FolderListModel.Ready || currentPath === "") return
            for (let i = 0; i < folder.count; i++) {
                if (folder.get(i, "filePath") === currentPath) {
                    list.currentIndex = i
                    list.positionViewAtIndex(i, ListView.Center)
                    return
                }
            }
        }

        // Applique le fond d'écran puis ferme le carrousel
        Process {
            id: setter
            onExited: Qt.quit()
        }

        // Récupère le fond d'écran actuel pour le présélectionner
        Process {
            command: ["noctalia", "msg", "wallpaper-get"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    win.currentPath = this.text.trim()
                    win.selectCurrent()
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

        ListView {
            id: list
            anchors.centerIn: parent
            width: parent.width
            height: win.cardH * 1.3
            orientation: ListView.Horizontal
            model: folder
            spacing: 10
            focus: true
            keyNavigationWraps: true
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: width / 2 - win.cardW / 2
            preferredHighlightEnd: width / 2 + win.cardW / 2
            highlightMoveDuration: 300
            Component.onCompleted: forceActiveFocus()

            Keys.onReturnPressed: win.apply(folder.get(currentIndex, "filePath"))
            Keys.onEnterPressed: win.apply(folder.get(currentIndex, "filePath"))
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
                readonly property bool isCurrent: ListView.isCurrentItem

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
                    onClicked: slot.isCurrent ? win.apply(slot.filePath) : list.currentIndex = slot.index
                }
            }
        }

        // Nom du fichier sélectionné
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: list.bottom
            anchors.topMargin: 20
            text: folder.count > 0 ? folder.get(list.currentIndex, "fileName") : "Aucune image dans ~/Pictures/Wallpapers"
            color: "white"
            font.pixelSize: 16
            font.family: "JetBrainsMono Nerd Font"
        }
    }
}
