import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Pane {
    padding: 0

    PassUI { id: passUI; onAccepted: backupView.syncRemote() }

    FastBlur {
        anchors.fill: layout

        source: layout
        radius: 5
        z: 10
        visible: backupView.state == "syncing"

        BusyIndicator { anchors.centerIn: parent }
        MouseArea { anchors.fill: parent; hoverEnabled: true; }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 20

        ListView {
            id: backupView
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 600
            Layout.fillHeight: true
            Layout.fillWidth: true

            state: "syncing"

            function syncRemote() {
                if (!arkzilla.password.length && arkzilla.login != 'anonymous') {
                    passUI.open()
                } else {
                    backupView.state = "syncing"
                    arkzilla.syncRemoteBackups()
                }
            }

            delegate: itemDelegate
            model: backupModel

            PullToRefresh {
                id: refreshHeader
                text: qsTr('Refresh')
                y: -backupView.contentY - height
                visible: backupView.state == "normal"
            }

            Label {
                id: refreshLabel
                anchors.centerIn: parent
                text: qsTr('Pull to refresh')
                visible: (backupView.count == 0 && backupView.state == "normal") ? true : false
            }

            onDragEnded: if (refreshHeader.refresh && backupView.state == "normal") { syncRemote() }

            Component.onCompleted: {
                arkzilla.syncLocalBackups()
            }

            states: [
                State { name: "syncing" },
                State { name: "processing" },
                State { name: "normal"
                    PropertyChanges { target: backupView.currentItem; restoreEntryValues: false; indeterminate: false }
                    PropertyChanges { target: backupView.currentItem; restoreEntryValues: false; progress: 0 }
                    PropertyChanges { target: backupView.currentItem; restoreEntryValues: false; statusText: '' }
                }
            ]
        }
    }

    Component {
        id: itemDelegate

        Rectangle {
            id: outerContainer

            anchors.left: parent.left
            anchors.right: parent.right

            height: innerContainer.height + 6
            color: Material.background

            property alias progress: progressBar.value
            property alias indeterminate: progressBar.indeterminate
            property alias statusText: labelStatus.text
            property bool isLocal: model.local

            Rectangle {
                id: innerContainer

                anchors.left: parent.left
                anchors.right: parent.right

                height: itemRow.height
                color: parent.color

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 3
                    verticalOffset: 3
                    radius: 8
                    samples: 15
                    color: '#80000000'
                }

                RowLayout {
                    id: itemRow

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 3

                    clip: true
                    z: 2

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.margins: 2
                        width: 10
                        color: isLocal ? Material.color(Material.Green) : Material.color(Material.Red)
                    }

                    Column {
                        Label { id: labelDate; text: model.date }
                        Label { id: labelName; text: model.name }
                    }

                    IconButton {
                        id: buttonRemove
                        text: ''
                        ToolTip.text: qsTr("Remove downloaded backup data")
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        color: Material.color(Material.Red)
                        visible: isLocal ? true : false
                        enabled: backupView.state == "normal"
                        opacity: backupView.state == "processing" ? 0.5 : 1
                        onClicked: {
                            backupView.state = "processing"
                            labelStatus.text = "Removing"
                            backupView.currentIndex = index
                            arkzilla.remove(model.filename)
                        }
                    }

                    Label {
                        id: labelStatus
                        Layout.fillWidth: true
                        leftPadding: buttonRemove.visible ? 0 : 16
                        font.pixelSize: 16
                        color: Material.color(Material.Grey)
                    }

                    IconButton {
                        id: buttonDownload
                        text: ''
                        ToolTip.text: qsTr("Download remote backup")
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        color: Material.color(Material.Green)
                        visible: !isLocal
                        enabled: backupView.state == "normal"
                        opacity: backupView.state == "processing" ? 0.5 : 1
                        onClicked: {
                            backupView.state = "processing"
                            labelStatus.text = "Downloading"
                            backupView.currentIndex = index
                            arkzilla.download(model.filename)
                        }
                    }

                    IconButton {
                        id: buttonOpen
                        text: ''
                        ToolTip.text: qsTr("Unpack and open backup with ark-tools")
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        color: Material.color(Material.Orange)
                        visible: isLocal
                        enabled: backupView.state == "normal"
                        opacity: backupView.state == "processing" ? 0.5 : 1
                        onClicked: {
                            backupView.state = "processing"
                            labelStatus.text = "Unpacking"
                            backupView.currentIndex = index
                            indeterminate = true
                            arkzilla.unpack(model.filename)
                        }
                    }
                }

                ProgressBar {
                    id: progressBar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    indeterminate: false
                    from: 0
                    to: 100
                    value: 0
                    visible: ((value > 0) || indeterminate) ? true : false
                    opacity: 0.5
                    z: 1
                }
            }
        }
    }

    Connections {
        target: arkzilla

        readonly property int localRole: Qt.UserRole + 1
        readonly property int nameRole: Qt.UserRole + 2
        readonly property int dataRole: Qt.UserRole + 3
        readonly property int fnameRole: Qt.UserRole + 4

        onSyncError: {
            toast.show(error, Material.color(Material.Red).toString())
            arkzilla.syncLocalBackups()
        }

        onSyncComplete: {
            backupView.state = "normal"
        }

        onDownloadError: {
            toast.show(error, Material.color(Material.Red).toString())
            backupView.state = "normal"
        }

        onDownloadComplete: {
            var index = backupModel.index(backupView.currentIndex, undefined)
            backupModel.setData(index, true, localRole)
            toast.show(backupModel.data(index, fnameRole) + qsTr(': download complete'))
            backupView.state = "normal"
        }

        onDownloadProgress: {
            backupView.currentItem.progress = percent
        }

        onRemoveError: {
            toast.show(error, Material.color(Material.Red).toString())
            backupView.state = "normal"
        }

        onRemoveComplete: {
            var index = backupModel.index(backupView.currentIndex, undefined)
            backupModel.setData(index, false, localRole)
            toast.show(backupModel.data(index, fnameRole) + qsTr(': successfuly removed'))
            backupView.state = "normal"
        }

        onRemoveProgress: {
            backupView.currentItem.progress = percent
        }

        onUnpackError: {
            toast.show(error, Material.color(Material.Red).toString())
            backupView.state = "normal"
        }

        onUnpackComplete: {
            var index = backupModel.index(backupView.currentIndex, undefined)
            var filename = backupModel.data(index, fnameRole)
            backupView.state = "normal"
        }

        onJavaNotFound: {
            toast.show(qsTr('Java Runtime Environment not found. Please download and install it: ') +
                '<a href="https://java.com/download">https://java.com/download</a>', undefined, 10000)
            backupView.state = "normal"
        }
    }
}
