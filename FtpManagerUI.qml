import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Pane {
    anchors.fill: parent
    padding: 0

    FastBlur {
        id: refreshOverlay
        anchors.fill: layout

        source: layout
        radius: 5
        z: 10
        visible: ftpView.loading

        BusyIndicator { anchors.centerIn: parent }
        MouseArea { anchors.fill: parent; hoverEnabled: true; onClicked: ftpView.loading = false }
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

            property bool loading: false

            delegate: itemDelegate

            PullToRefresh {
                id: refreshHeader
                text: qsTr('Refresh')
                y: -ftpView.contentY - height
            }

            Label {
                id: refreshLabel
                anchors.centerIn: parent
                text: qsTr('Pull to refresh')
                visible: (ftpView.count == 0 && ftpView.loading == false) ? true : false
            }

            onDragEnded: if(refreshHeader.refresh) {ftpView.loading = true}
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
                        id: buttonDelete
                        text: ''
                        color: Material.color(Material.Red)
                        visible: model.local ? true : false
                    }

                    Item { Layout.fillWidth: true  }

                    IconButton {
                        id: buttonDownload
                        text: ''
                        color: Material.color(Material.Green)
                        visible: !model.local
                    }

                    IconButton {
                        id: buttonOpen
                        text: ''
                        color: Material.color(Material.Orange)
                        visible: model.local
                    }
                }
            }
        }
    }
}
