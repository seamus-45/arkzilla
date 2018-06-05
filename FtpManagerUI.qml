import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Pane {
    padding: 0

    property string name: 'ftpview'
    property string title: arkzilla.host.length ? mainWindow.appName + ' (' + arkzilla.host + ')' : mainWindow.appName

    StackView.onRemoved: mainWindow.title = stackWindow.currentItem.title
    StackView.onActivated: mainWindow.title = title

    PassUI { id: passUI; onAccepted: ftpView.updateModel() }

    FastBlur {
        anchors.fill: layout

        source: layout
        radius: 5
        z: 10
        visible: ftpView.syncing

        BusyIndicator { anchors.centerIn: parent }
        MouseArea { anchors.fill: parent; hoverEnabled: true; }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 20

        ListView {
            id: ftpView
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 600
            Layout.fillHeight: true
            Layout.fillWidth: true

            property bool syncing: false
            property bool processing: false

            function updateModel() {
                if (!arkzilla.password.length && arkzilla.login != 'anonymous') {
                    passUI.open()
                } else {
                    ftpView.syncing = true
                    arkzilla.syncModel()
                }
            }

            delegate: itemDelegate
            model: ListModel {}

            PullToRefresh {
                id: refreshHeader
                text: qsTr('Refresh')
                y: -ftpView.contentY - height
                visible: !ftpView.processing
            }

            Label {
                id: refreshLabel
                anchors.centerIn: parent
                text: qsTr('Pull to refresh')
                visible: (ftpView.count == 0 && ftpView.syncing == false) ? true : false
            }

            onDragEnded: if (refreshHeader.refresh && !ftpView.processing) { updateModel() }

            Component.onCompleted: {
                ftpView.syncing = true
                arkzilla.syncWithLocal()
            }
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

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.margins: 2
                        width: 10
                        color: model.local ? Material.color(Material.Green) : Material.color(Material.Red)
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
                        visible: model.local ? true : false
                        enabled: !ftpView.processing
                        opacity: ftpView.processing ? 0.5 : 1
                        onClicked: {
                            ftpView.currentIndex = index
                            ftpView.processing = true
                            arkzilla.remove(model.filename)
                        }
                    }

                    Item { Layout.fillWidth: true; visible: !progressBar.visible  }

                    ProgressBar {
                        id: progressBar
                        leftPadding: 10
                        Layout.fillWidth: true
                        indeterminate: false
                        from: 0
                        to: 100
                        value: 0
                        visible: ((value > 0) || indeterminate) ? true : false
                    }

                    IconButton {
                        id: buttonDownload
                        text: ''
                        ToolTip.text: qsTr("Download remote backup")
                        ToolTip.delay: 1000
                        ToolTip.timeout: 5000
                        ToolTip.visible: hovered
                        color: Material.color(Material.Green)
                        visible: !model.local
                        enabled: !ftpView.processing
                        opacity: ftpView.processing ? 0.5 : 1
                        onClicked: {
                            ftpView.currentIndex = index
                            ftpView.processing = true
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
                        visible: model.local
                        enabled: !ftpView.processing
                        opacity: ftpView.processing ? 0.5 : 1
                        onClicked: {
                            ftpView.currentIndex = index
                            ftpView.processing = true
                            indeterminate = true
                            arkzilla.unpack(model.filename)
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: arkzilla

        onSyncError: {
            toast.show(error, Material.color(Material.Red).toString())
            arkzilla.syncWithLocal()
        }

        onSyncComplete: {
            ftpView.model.clear()
            model.forEach(function(elem) {
                ftpView.model.append(elem)
            })
            ftpView.syncing = false
        }

        onDownloadError: {
            ftpView.currentItem.progress = 0
            ftpView.processing = false
            toast.show(error, Material.color(Material.Red).toString())
        }

        onDownloadComplete: {
            ftpView.currentItem.progress = 0
            ftpView.processing = false
            ftpView.model.setProperty(ftpView.currentIndex, 'local', true)
            toast.show(ftpView.model.get(ftpView.currentIndex).filename + qsTr(': download complete'))
        }

        onDownloadProgress: {
            ftpView.currentItem.progress = percent
        }

        onRemoveError: {
            ftpView.currentItem.progress = 0
            ftpView.processing = false
            toast.show(error, Material.color(Material.Red).toString())
        }

        onRemoveComplete: {
            ftpView.currentItem.progress = 0
            ftpView.processing = false
            ftpView.model.setProperty(ftpView.currentIndex, 'local', false)
            toast.show(ftpView.model.get(ftpView.currentIndex).filename + qsTr(': successfuly removed'))
        }

        onRemoveProgress: {
            ftpView.currentItem.progress = percent
        }

        onUnpackError: {
            ftpView.currentItem.indeterminate = false
            ftpView.processing = false
            toast.show(error, Material.color(Material.Red).toString())
        }

        onUnpackComplete: {
            var filename = ftpView.model.get(ftpView.currentIndex).filename
            ftpView.currentItem.indeterminate = false
            ftpView.processing = false
        }

        onJavaNotFound: {
            ftpView.currentItem.indeterminate = false
            ftpView.processing = false
            toast.show(qsTr('Java Runtime Environment not found. Please download and install it: ') +
                '<a href="https://java.com/download">https://java.com/download</a>', undefined, 10000)
        }
    }
}
