import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Pane {
    padding: 0

    PassUI { id: passUI; onAccepted: backupView.syncRemote() }

    FastBlur {
        anchors.fill: backupView

        source: backupView
        radius: 5
        z: 10
        visible: backupView.state == 'syncing'

        BusyIndicator { anchors.centerIn: parent }
        MouseArea { anchors.fill: parent; hoverEnabled: true; }
    }

    ListView {
        id: backupView
        anchors.fill: parent
        anchors.margins: 20

        state: 'syncing'

        function syncRemote() {
            if (!arkzilla.password.length && arkzilla.login != 'anonymous') {
                passUI.open()
            } else {
                backupView.state = 'syncing'
                arkzilla.syncRemoteBackups()
            }
        }

        model: backupModel

        delegate: backupDelegate

        PullToRefresh {
            id: refreshHeader
            text: qsTr('Refresh')
            y: -backupView.contentY - height
            visible: backupView.state == 'normal'
        }

        Label {
            id: refreshLabel
            anchors.centerIn: parent
            text: qsTr('Pull to refresh')
            visible: (backupView.count == 0 && backupView.state == 'normal') ? true : false
        }

        onDragEnded: if (refreshHeader.refresh && backupView.state == 'normal') { syncRemote() }

        Component.onCompleted: {
            arkzilla.syncLocalBackups()
        }

        states: [
            State { name: 'syncing' },
            State { name: 'processing' },
            State { name: 'normal'
                PropertyChanges { target: backupView.currentItem; restoreEntryValues: false; indeterminate: false }
                PropertyChanges { target: backupView.currentItem; restoreEntryValues: false; progress: 0 }
                PropertyChanges { target: backupView.currentItem; restoreEntryValues: false; statusText: '' }
            }
        ]
    }

    Component {
        id: backupDelegate

        Rectangle {
            id: outerContainer
            anchors.horizontalCenter: parent.horizontalCenter
            height: innerContainer.height + 6
            width: (parent.width > 600) ? 600 : parent.width
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

                    Label {
                        id: labelStatus
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: Material.accent
                        font.pixelSize: 16
                    }

                    IconButton {
                        id: buttonRemove
                        text: ''
                        ToolTip.text: qsTr('Remove downloaded backup data')
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        color: Material.color(Material.Red)
                        visible: isLocal ? true : false
                        enabled: backupView.state == 'normal'
                        opacity: backupView.state == 'processing' ? 0.5 : 1
                        onClicked: {
                            backupView.state = 'processing'
                            labelStatus.text = 'Removing'
                            backupView.currentIndex = index
                            arkzilla.remove(model.backup)
                        }
                    }

                    IconButton {
                        id: buttonDownload
                        text: ''
                        ToolTip.text: qsTr('Download remote backup')
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        color: Material.color(Material.Green)
                        visible: !isLocal
                        enabled: backupView.state == 'normal'
                        opacity: backupView.state == 'processing' ? 0.5 : 1
                        onClicked: {
                            backupView.state = 'processing'
                            labelStatus.text = 'Downloading'
                            backupView.currentIndex = index
                            arkzilla.download(model.backup)
                        }
                    }

                    IconButton {
                        id: buttonOpen
                        text: ''
                        ToolTip.text: qsTr('Unpack and open backup with ark-tools')
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        color: Material.color(Material.Orange)
                        visible: isLocal
                        enabled: backupView.state == 'normal'
                        opacity: backupView.state == 'processing' ? 0.5 : 1
                        onClicked: {
                            backupView.state = 'processing'
                            labelStatus.text = 'Unpacking'
                            backupView.currentIndex = index
                            indeterminate = true
                            arkzilla.unpack(model.backup)
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
        readonly property int backupRole: Qt.UserRole + 4

        onBackupStateProgress: {
            backupView.currentItem.progress = percent
        }

        onBackupStateFinished: {
            backupView.state = 'normal'
        }

        onDownloadComplete: {
            var index = backupModel.index(backupView.currentIndex, undefined)
            backupModel.setData(index, true, localRole)
            toast.show(backupModel.data(index, backupRole) + qsTr(': download complete'))
        }

        onDownloadError: {
            toast.show(error, Material.color(Material.Red).toString())
        }

        onRemoveComplete: {
            var index = backupModel.index(backupView.currentIndex, undefined)
            backupModel.setData(index, false, localRole)
            toast.show(backupModel.data(index, backupRole) + qsTr(': successfuly removed'))
        }

        onRemoveError: {
            toast.show(error, Material.color(Material.Red).toString())
        }

        onSyncLocalError: {
            toast.show(error, Material.color(Material.Red).toString())
        }

        onSyncRemoteError: {
            toast.show(error, Material.color(Material.Red).toString())
            arkzilla.syncLocalBackups()
        }

        onUnpackComplete: {
            var index = backupModel.index(backupView.currentIndex, undefined)
            var backup = backupModel.data(index, backupRole)
            stackWindow.push(tamedUI, {backup: backup})
        }

        onUnpackError: {
            toast.show(error, Material.color(Material.Red).toString())
        }

        onJavaNotFound: {
            toast.show(qsTr('Java Runtime Environment not found. Please download ') +
                '(<a href="https://java.com/download">https://java.com/download</a>)' +
                qsTr(', install and restart ') + mainWindow.appName, undefined, 10000)
        }
    }
}
