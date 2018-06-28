import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Pane {
    padding: 0

    property alias backup: classesView.backup

    ListView {
        id: classesView
        width: parent.width * 0.25
        height: parent.height

        property string backup

        function getCls() {
            var index = classesModel.index(classesView.currentIndex, undefined)
            return classesModel.data(index, Qt.UserRole + 1)
        }

        clip: true
        focus: true
        activeFocusOnTab: true

        ScrollIndicator.vertical: ScrollIndicator { }

        model: classesModel

        delegate: Component {
            Item {
                width: parent.width
                height: labelName.height

                Label {
                    id: labelName
                    padding: 12
                    text: model.name
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        classesView.currentIndex = index
                        tamedView.currentIndex = -1
                        arkzilla.loadTamed(classesView.backup, model.cls)
                    }
                }
            }
        }

        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            width: classesView.width
            height: classesView.currentItem ? classesView.currentItem.height : 0
            y: classesView.currentItem ? classesView.currentItem.y : 0
            color: Material.accent
            opacity: 0.5
        }

        Rectangle {
            width: parent.height
            height: 8
            rotation: 90
            anchors.left: parent.right
            transformOrigin: Item.TopLeft

            gradient: Gradient {
                GradientStop { color: Qt.rgba(0, 0, 0, 0.15); position: 0 }
                GradientStop { color: Qt.rgba(0, 0, 0, 0.05); position: 0.5 }
                GradientStop { color: Qt.rgba(0, 0, 0, 0); position: 1 }
            }
        }

        Keys.onEscapePressed: { stackWindow.pop() }
        Keys.onReturnPressed: { tamedView.currentIndex = -1; arkzilla.loadTamed(classesView.backup, getCls()) }
        Keys.onSpacePressed: { tamedView.currentIndex = -1; arkzilla.loadTamed(classesView.backup, getCls()) }
        Keys.onRightPressed: { tamedView.currentIndex = -1; arkzilla.loadTamed(classesView.backup, getCls()) }

        Component.onCompleted: {
            arkzilla.loadClasses(classesView.backup)
        }
    }

    ListView {
        id: tamedView
        anchors.left: classesView.right
        anchors.right: parent.right
        height: parent.height

        property int padding: 5
        property variant row

        clip: true
        focus: true
        activeFocusOnTab: true

        ScrollIndicator.vertical: ScrollIndicator { }

        model: tamedModel

        header: tamedHeader
        headerPositioning: ListView.OverlayHeader

        footer: tamedFooter
        footerPositioning: ListView.OverlayFooter

        delegate: tamedDelegate

        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            width: tamedView.width
            height: tamedView.currentItem ? tamedView.currentItem.height : 0
            y: tamedView.currentItem ? tamedView.currentItem.y : 0
            color: Material.accent
            opacity: 0.5
        }

        Keys.onEscapePressed: { stackWindow.pop() }
        Keys.onLeftPressed: { currentIndex = -1; classesView.focus = true }

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                var index = tamedModel.index(tamedView.currentIndex, undefined)
                row = tamedModel.data(index, Qt.UserRole + 9)
            }
        }
    }

    Component {
        id: tamedFooter
        Pane {
            id: tamedPane
            width: parent.width
            visible: (tamedView.currentIndex >= 0) ? true : false
            z: 2

            property variant row: tamedView.row

            function epochDays(time) {
                var epoch = new Date(time*1000)
                var days = Math.floor(epoch/8.64e7)
                var hours = epoch.getHours()
                var mins = epoch.getMinutes()
                var seconds = epoch.getSeconds()
                return days + ', ' + hours + ':' + mins + ':' + seconds
            }

            Column {
                anchors.fill: parent

                GridLayout {
                    width: parent.width
                    columns: 2
                    columnSpacing: 20

                    FooterSection { text: qsTr('Wild Stats') }
                    FooterSection {
                        ToolTip.visible: hovered
                        ToolTip.timeout: 5000
                        ToolTip.delay: 1000
                        ToolTip.text: qsTr('Copy painting command')
                        text: qsTr(' Colors')
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var colors = row.colorSetIndices
                                var cmd = ''
                                for (var key in colors) {
                                    if (colors[key])
                                        cmd ? cmd += '| ' : ''
                                        cmd += 'SetTargetDinoColor ' + key + ' ' + colors[key]
                                }
                                arkzilla.clipboardText(cmd)
                                toast.show(qsTr('Copied to clipboard'))
                            }
                        }
                    }
                    WildLevels { levels: row ? row.wildLevels : undefined }
                    ColorSet { colors: row ? row.colorSetIndices : 0 }

                    RowLayout {
                        spacing: 20

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            columns: 2

                            FooterSection { Layout.columnSpan:2; text: qsTr('Levels') }
                            Label { Layout.fillWidth: true; text: qsTr('Full:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.baseLevel + row.extraLevel : '' }
                            Label { text: qsTr('Wild:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.baseLevel : '' }
                            Label { text: qsTr('Extra:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.extraLevel : '' }
                            Label { text: qsTr('Exp:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.experience : '' }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            columns: 2

                            FooterSection { Layout.columnSpan:2; text: qsTr('Taming') }
                            Label { Layout.fillWidth: true; text: qsTr('Tamer:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.tamer : '' }
                            Label { text: qsTr('Tamed at:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? epochDays(row.tamedAtTime): '' }
                            Label { text: qsTr('Tamed on:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.tamedOnServerName : '' }
                            Label { text: qsTr('Effectivness:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.tamingEffectivness : '' }
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            columns: 2

                            FooterSection {
                                Layout.columnSpan: 2
                                ToolTip.visible: hovered
                                ToolTip.timeout: 5000
                                ToolTip.delay: 1000
                                ToolTip.text: qsTr('Copy teleport command')
                                text: qsTr(' Location')
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var cmd = 'admincheat SetPlayerPos ' + row.location.x + ' ' + row.location.y + ' ' + row.location.z
                                        arkzilla.clipboardText(cmd)
                                        toast.show(qsTr('Copied to clipboard'))
                                    }
                                }
                            }
                            Label { Layout.fillWidth: true; text: qsTr('Lat:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.location.lat : '' }
                            Label { text: qsTr('Lon:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.location.lon : '' }
                            Label { text: qsTr('X:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.location.x : '' }
                            Label { text: qsTr('Y:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.location.y : '' }
                            Label { text: qsTr('Z:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.location.z : '' }
                        }
                    }

                    GridLayout {
                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                        columns: 2

                        FooterSection { Layout.columnSpan: 2; text: qsTr('Other') }
                        Label { Layout.fillWidth: true; text: qsTr('ID:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.id : '' }
                        Label { text: qsTr('Owner:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.ownerName : '' }
                        Label { text: qsTr('Imprinter:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.imprinter : '' }
                        Label { text: qsTr('Imprinting:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? row.imprintingQuality : '' }
                        Label { text: qsTr('Last stasis:'); font.bold: true } Label { Layout.alignment: Qt.AlignRight; text: row ? epochDays(row.lastEnterStasisTime) : '' }
                    }
                }
            }
        }
    }

    Component {
        id: tamedHeader

        ToolBar {
            id: filterBar
            width: parent.width
            padding: ListView.view.padding
            background: Rectangle { color: Material.background }
            z: 2

            property alias levelWidth: filterLevel.width
            property alias nameWidth: filterName.width
            property alias tribeWidth: filterTribe.width
            property alias latWidth: filterLat.width
            property alias lonWidth: filterLon.width
            property alias tribeImplicitWidth: filterTribe.implicitWidth
            property alias nameImplicitWidth: filterName.implicitWidth
            property alias levelImplicitWidth: filterLevel.implicitWidth
            property alias latImplicitWidth: filterLat.implicitWidth
            property alias lonImplicitWidth: filterLon.implicitWidth
            property alias headerSpacing: buttons.spacing

            RowLayout {
                id: buttons
                width: parent.width

                SortFilterItem {
                    id: filterLevel
                    text: 'Level'
                    sort: true
                    onCheckStateChanged: {
                        if (checkState != Qt.Unchecked) {
                            tamedModel.setSortOrder(Qt.UserRole + 6, checkState - 1)
                        }
                    }
                }
                SortFilterItem {
                    id: filterName
                    Layout.minimumWidth: implicitWidth
                    Layout.fillWidth: true
                    text: 'Name'
                    sort: true
                    filter: true
                    onCheckStateChanged: {
                        if (checkState != Qt.Unchecked) {
                            tamedModel.setSortOrder(Qt.UserRole + 1, checkState - 1)
                        }
                    }
                    onFilterTextChanged: {
                        if (tamedView.currentIndex) { tamedView.currentIndex = -1 }
                        if (filterText.length && filterTribe.filterText.length) { filterTribe.clear() }
                        tamedModel.setFilterString(Qt.UserRole + 1, filterText)
                    }
                }
                SortFilterItem {
                    id: filterTribe
                    Layout.minimumWidth: implicitWidth
                    Layout.fillWidth: true
                    text: 'Tribe'
                    sort: true
                    filter: true
                    onCheckStateChanged: {
                        if (checkState != Qt.Unchecked) {
                            tamedModel.setSortOrder(Qt.UserRole + 3, checkState - 1)
                        }
                    }
                    onFilterTextChanged: {
                        if (tamedView.currentIndex) { tamedView.currentIndex = -1 }
                        if (filterText.length && filterName.filterText.length) { filterName.clear() }
                        tamedModel.setFilterString(Qt.UserRole + 3, filterText)
                    }
                }
                SortFilterItem {
                    id: filterLat
                    text: 'Lat'
                }
                SortFilterItem {
                    id: filterLon
                    text: 'Lon'
                }
            }
            ButtonGroup {
                buttons: buttons.children
            }
        }
    }

    Component {
        id: tamedDelegate

        Item {
            height: tamedRow.height
            width: parent.width
            Row {
                id: tamedRow
                leftPadding: tamedView.padding
                rightPadding: tamedView.padding
                topPadding: 1
                bottomPadding: 1
                spacing: tamedView.headerItem.headerSpacing

                Label {
                    width: tamedView.headerItem.levelWidth
                    padding: tamedView.padding
                    text: model.level
                    onWidthChanged: { tamedView.headerItem.levelImplicitWidth = Math.max(tamedView.headerItem.levelImplicitWidth, implicitWidth) }
                }
                Label {
                    width: tamedView.headerItem.nameWidth
                    leftPadding: tamedView.padding + font.pixelSize
                    topPadding: tamedView.padding
                    bottomPadding: tamedView.padding
                    rightPadding: tamedView.padding
                    text: model.name
                    background: Label {
                        padding: tamedView.padding
                        font.family: faSolid.name
                        font.pixelSize: parent.font.pixelSize
                        color: model.female ? Material.color(Material.Red) : Material.color(Material.Blue)
                        text: model.female ? '' : ''
                    }
                    onWidthChanged: { tamedView.headerItem.nameImplicitWidth = Math.max(tamedView.headerItem.nameImplicitWidth, implicitWidth) }
                }
                Label {
                    width: tamedView.headerItem.tribeWidth
                    padding: tamedView.padding
                    opacity: model.tribe ? 1.0 : 0.5
                    text: model.tribe ? model.tribe : qsTr('None')
                    onWidthChanged: { tamedView.headerItem.tribeImplicitWidth = Math.max(tamedView.headerItem.tribeImplicitWidth, implicitWidth) }
                }
                Label {
                    width: tamedView.headerItem.latWidth
                    padding: tamedView.padding
                    text: model.location.lat.toFixed(1)
                    onWidthChanged: { tamedView.headerItem.latImplicitWidth = Math.max(tamedView.headerItem.latImplicitWidth, implicitWidth) }
                }
                Label {
                    width: tamedView.headerItem.lonWidth
                    padding: tamedView.padding
                    text: model.location.lon.toFixed(1)
                    onWidthChanged: { tamedView.headerItem.lonImplicitWidth = Math.max(tamedView.headerItem.lonImplicitWidth, implicitWidth) }
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tamedView.currentIndex = index
                }
            }
        }
    }

    Connections {
        target: arkzilla

        onLoadClassesError: {
            toast.show(error, Material.color(Material.Red).toString())
        }

        onLoadTamedError: {
            toast.show(error, Material.color(Material.Red).toString())
        }

        onLoadTamedComplete:{
            tamedView.currentIndex = 0
            tamedView.focus = true
        }
    }
}
