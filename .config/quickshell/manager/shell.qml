// Fenêtre « Manager » : paquets (officiels + AUR), en interface graphique.
// Données : ~/.local/bin/manager-data (JSON). Couleurs : ../menu/colors.json (généré par matugen, shell-maison).
// Lancement : ~/.local/bin/manager-open [add|installed]

import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    // ---- Petits composants (les couleurs sont passées par « c ») ----

    component Label: Text {
        property var c
        color: c.on_surface
        font.family: "Maple Mono NF"
        font.pixelSize: 13
    }

    component Pill: Rectangle {
        property var c
        property string label
        property color fg
        implicitWidth: pillText.implicitWidth + 12
        implicitHeight: 20
        Text {
            id: pillText
            anchors.centerIn: parent
            text: parent.label
            color: parent.fg
            font.family: "Maple Mono NF"
            font.pixelSize: 11
            font.bold: true
        }
    }

    component Btn: Rectangle {
        id: btn
        property var c
        property string label
        property color bg: c.surface_container_high
        property color fg: c.on_surface
        signal clicked()
        implicitWidth: btnText.implicitWidth + 28
        implicitHeight: 34
        color: !enabled ? c.surface_container : area.containsMouse ? Qt.lighter(bg, 1.15) : bg
        opacity: enabled ? 1 : 0.5
        Text {
            id: btnText
            anchors.centerIn: parent
            text: btn.label
            color: btn.fg
            font.family: "Maple Mono NF"
            font.pixelSize: 13
            font.bold: true
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: btn.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (btn.enabled) btn.clicked()
        }
    }

    component SearchField: Rectangle {
        id: field
        property var c
        property string placeholder
        property alias text: input.text
        property alias input: input
        signal keyPressed(var event)
        implicitHeight: 36
        color: c.surface_container
        border.color: input.activeFocus ? c.primary : "transparent"
        border.width: 1
        Text {
            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
            text: ""
            color: field.c.on_surface_variant
            font.family: "Maple Mono NF"
        }
        TextInput {
            id: input
            anchors { fill: parent; leftMargin: 34; rightMargin: 12 }
            verticalAlignment: TextInput.AlignVCenter
            color: field.c.on_surface
            selectionColor: field.c.primary
            font.family: "Maple Mono NF"
            font.pixelSize: 14
            clip: true
            Keys.onPressed: event => field.keyPressed(event)
            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: input.text === ""
                text: field.placeholder
                color: field.c.on_surface_variant
                opacity: 0.6
                font: input.font
            }
        }
    }

    component Tab: Rectangle {
        id: tab
        property var c
        property string label
        property bool active
        signal clicked()
        implicitWidth: tabText.implicitWidth + 32
        implicitHeight: 44
        color: tabArea.containsMouse && !active ? c.surface_container : "transparent"
        Text {
            id: tabText
            anchors.centerIn: parent
            text: tab.label
            color: tab.active ? tab.c.primary : tab.c.on_surface_variant
            font.family: "Maple Mono NF"
            font.pixelSize: 14
            font.bold: tab.active
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 2
            color: tab.c.primary
            visible: tab.active
        }
        MouseArea { id: tabArea; anchors.fill: parent; hoverEnabled: true; onClicked: tab.clicked() }
    }

    component Toggle: Rectangle {
        id: sw
        property var c
        property bool checked
        property bool busy
        signal toggled()
        implicitWidth: 42
        implicitHeight: 22
        color: checked ? c.primary : c.surface_container_highest
        opacity: busy ? 0.5 : 1
        Rectangle {
            width: 16; height: 16
            y: 3
            x: sw.checked ? parent.width - width - 3 : 3
            color: sw.checked ? sw.c.on_primary : sw.c.on_surface_variant
            Behavior on x { NumberAnimation { duration: 120 } }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (!sw.busy) sw.toggled()
        }
    }

    FloatingWindow {
        id: win
        title: "Manager"
        implicitWidth: 1100
        implicitHeight: 700
        color: c.surface

        readonly property string home: Quickshell.env("HOME")
        readonly property string dataCmd: home + "/.local/bin/manager-data"
        property string page: "packages"

        // Couleurs par défaut, remplacées par colors.json
        property var c: ({
            surface: "#1b211f", surface_container: "#252b2a", surface_container_high: "#303634",
            surface_container_highest: "#3a403e", on_surface: "#dde4e1", on_surface_variant: "#bec9c5",
            primary: "#83d5c6", on_primary: "#003730", tertiary: "#accae5", on_tertiary: "#133348",
            secondary_container: "#334b46", on_secondary_container: "#cde8e1",
            error: "#ffb4ab", on_error: "#690005", outline: "#899390", outline_variant: "#3f4946"
        })

        onVisibleChanged: if (!visible) Qt.quit()

        // Test : MANAGER_SNAPSHOT=<fichier.png> enregistre une image de la fenêtre puis la ferme
        Timer {
            running: !!Quickshell.env("MANAGER_SNAPSHOT")
            interval: 6000
            onTriggered: root.grabToImage(r => { r.saveToFile(Quickshell.env("MANAGER_SNAPSHOT")); Qt.quit() })
        }

        FileView {
            path: win.home + "/.config/quickshell/menu/colors.json"
            watchChanges: true
            onFileChanged: reload()
            onLoaded: {
                try { win.c = Object.assign({}, win.c, JSON.parse(text())) } catch (e) {}
            }
        }

        Shortcut { sequence: "Ctrl+Q"; onActivated: Qt.quit() }

        Rectangle {
            id: root
            anchors.fill: parent
            color: win.c.surface

        // ---- En-tête : onglets ----
        Rectangle {
            id: header
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 44
            color: win.c.surface_container

            Row {
                anchors { left: parent.left; leftMargin: 8; bottom: parent.bottom }
                Tab { c: win.c; label: "  Packages"; active: win.page === "packages"; onClicked: win.page = "packages" }
            }
            Label {
                c: win.c
                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                text: "Ctrl+Q: close"
                color: win.c.on_surface_variant
                font.pixelSize: 11
                opacity: 0.7
            }
        }

        // =====================================================================
        // Onglet Packages
        // =====================================================================
        Item {
            id: pk
            anchors { left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom; margins: 16 }
            visible: win.page === "packages"

            property string mode: Quickshell.env("MANAGER_MODE") === "installed" ? "installed" : "add"
            property var official: []
            property var officialNames: ({})
            property var installedPkgs: []
            property var aur: []
            property string aurQuery: ""
            property var results: []
            property var details: null
            property bool busy: false
            property string action: ""      // texte de l'action en cours
            property string status: ""      // "", "ok", "fail"
            property string log: ""
            property bool confirmRemove: false

            function query() { return pkSearch.text.trim().toLowerCase() }

            function rank(name, q) {
                return name === q ? 0 : name.startsWith(q) ? 1 : 2
            }

            function refresh() {
                const q = query()
                let res = []
                if (mode === "add") {
                    if (q.length >= 2) {
                        const off = official.filter(p => p.name.includes(q))
                            .sort((a, b) => rank(a.name, q) - rank(b.name, q) || a.name.length - b.name.length)
                            .slice(0, 150)
                        const au = aurQuery === q ? aur.filter(p => !officialNames[p.name]) : []
                        res = off.concat(au)
                    }
                } else {
                    res = installedPkgs.filter(p => q === "" || p.name.includes(q) || p.desc.toLowerCase().includes(q))
                }
                const keep = list.currentIndex >= 0 && results[list.currentIndex] ? results[list.currentIndex].name : ""
                results = res
                const idx = res.findIndex(p => p.name === keep)
                list.currentIndex = idx >= 0 ? idx : (res.length ? 0 : -1)
                loadDetails()
            }

            function selected() { return list.currentIndex >= 0 ? results[list.currentIndex] : null }

            function loadDetails() {
                confirmRemove = false
                detailsTimer.restart()
            }

            function run(args, label) {
                busy = true
                status = ""
                action = label
                log = ""
                actionProc.command = [win.dataCmd].concat(args)
                actionProc.running = true
            }

            Component.onCompleted: {
                officialProc.running = true
                installedProc.running = true
                pkSearch.text = Quickshell.env("MANAGER_QUERY") || ""
                pkSearch.input.forceActiveFocus()
            }

            Process {
                id: officialProc
                command: [win.dataCmd, "official"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            const list = JSON.parse(this.text)
                            const names = {}
                            for (const p of list) names[p.name] = true
                            pk.official = list
                            pk.officialNames = names
                            pk.refresh()
                        } catch (e) {}
                    }
                }
            }

            Process {
                id: installedProc
                command: [win.dataCmd, "installed"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        try { pk.installedPkgs = JSON.parse(this.text); pk.refresh() } catch (e) {}
                    }
                }
            }

            // Recherche AUR : attend une courte pause dans la frappe
            Timer {
                id: aurTimer
                interval: 400
                onTriggered: {
                    const q = pk.query()
                    if (pk.mode !== "add" || q.length < 2 || q === pk.aurQuery) return
                    if (aurProc.running) { restart(); return }
                    aurProc.pending = q
                    aurProc.command = [win.dataCmd, "aur-search", q]
                    aurProc.running = true
                }
            }

            Process {
                id: aurProc
                property string pending: ""
                stdout: StdioCollector {
                    onStreamFinished: {
                        try { pk.aur = JSON.parse(this.text) } catch (e) { pk.aur = [] }
                        pk.aurQuery = aurProc.pending
                        pk.refresh()
                    }
                }
            }

            Timer {
                id: detailsTimer
                interval: 150
                onTriggered: {
                    const p = pk.selected()
                    if (!p) { pk.details = null; return }
                    pk.details = { name: p.name, desc: p.desc, loading: true }
                    detailsProc.command = [win.dataCmd, "info", p.kind, p.name]
                    detailsProc.running = true
                }
            }

            Process {
                id: detailsProc
                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            const d = JSON.parse(this.text)
                            const p = pk.selected()
                            if (p && d.name === p.name) pk.details = Object.assign({ kind: p.kind }, d)
                        } catch (e) {}
                    }
                }
            }

            Process {
                id: actionProc
                stdout: SplitParser { onRead: line => pk.log += line + "\n" }
                stderr: SplitParser { onRead: line => pk.log += line + "\n" }
                onExited: code => {
                    pk.busy = false
                    pk.status = code === 0 ? "ok" : "fail"
                    officialProc.running = true
                    installedProc.running = true
                    pk.aurQuery = ""
                    aurTimer.restart()
                }
            }

            // ---- Barre du haut : mode + recherche ----
            Row {
                id: pkTop
                anchors { left: parent.left; top: parent.top }
                spacing: 8
                Btn {
                    c: win.c
                    label: "Add"
                    bg: pk.mode === "add" ? win.c.primary : win.c.surface_container_high
                    fg: pk.mode === "add" ? win.c.on_primary : win.c.on_surface
                    onClicked: { pk.mode = "add"; pk.refresh(); pkSearch.input.forceActiveFocus() }
                }
                Btn {
                    c: win.c
                    label: "Installed"
                    bg: pk.mode === "installed" ? win.c.primary : win.c.surface_container_high
                    fg: pk.mode === "installed" ? win.c.on_primary : win.c.on_surface
                    onClicked: { pk.mode = "installed"; pk.refresh(); pkSearch.input.forceActiveFocus() }
                }
            }

            SearchField {
                id: pkSearch
                c: win.c
                anchors { left: pkTop.right; leftMargin: 12; right: parent.right; top: parent.top }
                placeholder: pk.mode === "add" ? "Search a package to install (official + AUR)…" : "Filter installed packages…"
                onTextChanged: { pk.refresh(); aurTimer.restart() }
                onKeyPressed: event => {
                    if (event.key === Qt.Key_Down) { list.incrementCurrentIndex(); pk.loadDetails() }
                    else if (event.key === Qt.Key_Up) { list.decrementCurrentIndex(); pk.loadDetails() }
                    else if (event.key === Qt.Key_Escape) { if (pkSearch.text !== "") pkSearch.text = ""; else Qt.quit() }
                    else return
                    event.accepted = true
                }
            }

            Label {
                id: legend
                c: win.c
                anchors { left: parent.left; top: pkTop.bottom; topMargin: 10 }
                text: "Official = Arch / CachyOS, checked  ·  AUR = community, check the votes"
                color: win.c.on_surface_variant
                font.pixelSize: 11
            }

            // ---- Liste des résultats ----
            Rectangle {
                id: listBox
                anchors { left: parent.left; top: legend.bottom; topMargin: 8; bottom: logBox.visible ? logBox.top : parent.bottom; bottomMargin: logBox.visible ? 10 : 0 }
                width: parent.width * 0.56
                color: win.c.surface_container

                ListView {
                    id: list
                    anchors { fill: parent; margins: 4 }
                    model: pk.results
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    highlightMoveDuration: 0
                    currentIndex: -1

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool selected: ListView.isCurrentItem
                        width: list.width
                        height: 56
                        color: selected ? win.c.surface_container_highest : rowArea.containsMouse ? win.c.surface_container_high : "transparent"

                        Rectangle { width: 3; height: parent.height; color: win.c.primary; visible: row.selected }

                        Row {
                            id: line1
                            anchors { left: parent.left; leftMargin: 12; top: parent.top; topMargin: 8 }
                            spacing: 8
                            Pill {
                                c: win.c
                                readonly property bool isAur: row.modelData.kind === "aur" || row.modelData.aur === true
                                label: isAur ? "AUR" : "Official"
                                color: isAur ? win.c.tertiary : win.c.primary
                                fg: isAur ? win.c.on_tertiary : win.c.on_primary
                            }
                            Label { c: win.c; text: row.modelData.name; font.bold: true }
                            Label { c: win.c; text: " installed"; color: win.c.primary; font.pixelSize: 11; visible: row.modelData.installed && pk.mode === "add"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Label {
                            c: win.c
                            anchors { right: parent.right; rightMargin: 12; top: parent.top; topMargin: 9 }
                            visible: row.modelData.kind === "aur"
                            text: row.modelData.votes < 10 ? " " + row.modelData.votes + " votes" : " " + row.modelData.votes
                            color: row.modelData.votes < 10 ? win.c.error : win.c.on_surface_variant
                            font.pixelSize: 11
                        }
                        Label {
                            c: win.c
                            anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; top: line1.bottom; topMargin: 4 }
                            text: row.modelData.desc
                            elide: Text.ElideRight
                            color: win.c.on_surface_variant
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: { list.currentIndex = row.index; pk.loadDetails() }
                        }
                    }

                    Label {
                        c: win.c
                        anchors.centerIn: parent
                        width: parent.width - 40
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        visible: list.count === 0
                        color: win.c.on_surface_variant
                        text: pk.mode === "add"
                            ? (pk.official.length === 0 ? "Loading packages…"
                               : pk.query().length < 2 ? "Type at least 2 letters to search."
                               : aurProc.running ? "Searching…" : "Nothing found.")
                            : (pk.installedPkgs.length === 0 ? "Loading…" : "Nothing found.")
                    }
                }
            }

            // ---- Fiche du paquet ----
            Rectangle {
                id: detailBox
                anchors { left: listBox.right; leftMargin: 12; right: parent.right; top: listBox.top; bottom: listBox.bottom }
                color: win.c.surface_container

                Label {
                    c: win.c
                    anchors.centerIn: parent
                    visible: !pk.details
                    text: "Select a package"
                    color: win.c.on_surface_variant
                }

                Flickable {
                    id: detailFlick
                    anchors { fill: parent; margins: 18; bottomMargin: 70 }
                    visible: !!pk.details
                    contentHeight: detailCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: detailCol
                        width: detailFlick.width
                        spacing: 10
                        readonly property var d: pk.details || ({})
                        readonly property bool isAur: d.source === "AUR" || d.kind === "aur"

                        Label { c: win.c; text: detailCol.d.name || ""; font.pixelSize: 20; font.bold: true; width: parent.width; elide: Text.ElideRight }
                        Row {
                            spacing: 8
                            Pill {
                                c: win.c
                                label: detailCol.isAur ? "AUR · community" : "Official" + (detailCol.d.repo ? " · " + detailCol.d.repo : "")
                                color: detailCol.isAur ? win.c.tertiary : win.c.primary
                                fg: detailCol.isAur ? win.c.on_tertiary : win.c.on_primary
                            }
                            Pill {
                                c: win.c
                                visible: !!detailCol.d.installed
                                label: " installed"
                                color: win.c.secondary_container
                                fg: win.c.on_secondary_container
                            }
                            Pill {
                                c: win.c
                                visible: !!detailCol.d.outOfDate
                                label: "out of date"
                                color: win.c.error
                                fg: win.c.on_error
                            }
                        }
                        Label {
                            c: win.c
                            width: parent.width
                            text: detailCol.d.desc || ""
                            wrapMode: Text.WordWrap
                            font.pixelSize: 14
                        }
                        Label {
                            c: win.c
                            visible: !!detailCol.d.loading
                            text: "Loading details…"
                            color: win.c.on_surface_variant
                        }

                        Repeater {
                            model: [
                                ["Version", detailCol.d.version],
                                ["Website", detailCol.d.url],
                                ["Size", detailCol.d.size],
                                ["Votes", detailCol.d.votes !== undefined ? String(detailCol.d.votes) : ""],
                                ["Popularity", detailCol.d.popularity !== undefined ? String(detailCol.d.popularity) : ""],
                                ["Maintainer", detailCol.d.maintainer],
                                ["Depends on", detailCol.d.depends]
                            ].filter(r => r[1])
                            delegate: Row {
                                required property var modelData
                                width: detailCol.width
                                spacing: 10
                                Label { c: win.c; width: 110; text: modelData[0]; color: win.c.on_surface_variant; font.pixelSize: 12 }
                                Label {
                                    c: win.c
                                    width: parent.width - 120
                                    text: modelData[0] === "Website" ? "<a href=\"" + modelData[1] + "\">" + modelData[1] + "</a>" : modelData[1]
                                    textFormat: modelData[0] === "Website" ? Text.StyledText : Text.PlainText
                                    linkColor: win.c.primary
                                    onLinkActivated: link => Qt.openUrlExternally(link)
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 4
                                    elide: Text.ElideRight
                                    font.pixelSize: 12
                                }
                            }
                        }

                        // Avertissements
                        Label {
                            c: win.c
                            width: parent.width
                            visible: detailCol.isAur && detailCol.d.votes !== undefined && detailCol.d.votes < 10
                            text: "  Few votes: few people use this package. Check it before installing."
                            color: win.c.error
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12
                        }
                        Label {
                            c: win.c
                            width: parent.width
                            visible: !!detailCol.d.requiredBy && detailCol.d.installed
                            text: "  Needed by: " + (detailCol.d.requiredBy || "")
                            color: win.c.error
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            font.pixelSize: 12
                        }
                    }
                }

                // Bouton d'action
                Btn {
                    id: actionBtn
                    c: win.c
                    visible: !!pk.details && !pk.details.loading
                    anchors { right: parent.right; bottom: parent.bottom; margins: 18 }
                    readonly property bool inst: !!(pk.details && pk.details.installed)
                    enabled: !pk.busy
                    label: inst ? (pk.confirmRemove ? "Click again to remove" : "  Remove") : "  Install"
                    bg: inst ? win.c.error : win.c.primary
                    fg: inst ? win.c.on_error : win.c.on_primary
                    onClicked: {
                        const d = pk.details
                        if (inst) {
                            if (!pk.confirmRemove) { pk.confirmRemove = true; confirmTimer.restart(); return }
                            pk.confirmRemove = false
                            pk.run(["remove", d.name], "Removing " + d.name)
                        } else {
                            pk.run(["install", d.source === "AUR" || d.kind === "aur" ? "aur" : "official", d.name], "Installing " + d.name)
                        }
                    }
                    Timer { id: confirmTimer; interval: 4000; onTriggered: pk.confirmRemove = false }
                }
                Label {
                    c: win.c
                    visible: actionBtn.visible
                    anchors { left: parent.left; right: actionBtn.left; rightMargin: 12; verticalCenter: actionBtn.verticalCenter; leftMargin: 18 }
                    text: "Your password will be asked in a window."
                    color: win.c.on_surface_variant
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            // ---- Journal de l'installation / suppression ----
            Rectangle {
                id: logBox
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 170
                visible: pk.busy || pk.status !== ""
                color: win.c.surface_container

                Label {
                    id: logTitle
                    c: win.c
                    anchors { left: parent.left; top: parent.top; margins: 10 }
                    text: pk.busy ? "  " + pk.action + "…"
                        : pk.status === "ok" ? "  Done: " + pk.action.toLowerCase()
                        : "  Failed: " + pk.action.toLowerCase() + " (see the messages below)"
                    color: pk.status === "fail" ? win.c.error : win.c.primary
                    font.bold: true
                }
                Label {
                    c: win.c
                    anchors { right: parent.right; top: parent.top; margins: 10 }
                    visible: !pk.busy
                    text: ""
                    color: win.c.on_surface_variant
                    MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: pk.status = "" }
                }
                Flickable {
                    id: logFlick
                    anchors { left: parent.left; right: parent.right; top: logTitle.bottom; bottom: parent.bottom; margins: 10 }
                    contentHeight: logText.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    Label {
                        id: logText
                        c: win.c
                        width: logFlick.width
                        text: pk.log
                        wrapMode: Text.WrapAnywhere
                        color: win.c.on_surface_variant
                        font.pixelSize: 11
                        onTextChanged: logFlick.contentY = Math.max(0, implicitHeight - logFlick.height)
                    }
                }
            }
        }

        }
    }
}
