import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.1


Dialog {
    id: dialog

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: parent.width * 0.75
    height: parent.height * 0.75
    padding: 0

    focus: true
    modal: true

    property alias caption: dialogTitle.text
    property alias filter: folderModel.nameFilters
    property string filePath: ''

    onAccepted: {
        var index = folderView.currentIndex
        filePath = folderModel.get(index, 'filePath')
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label {
                padding: 16
                text: ""
            }
            Column {
                Layout.fillWidth: true
                Label {
                    id: dialogTitle
                    text: qsTr('Choose a file..')
                    font.bold: true
                }
                Label {
                    text: folderModel.currentFolder
                }
            }
            IconButton {
                text: ""
                onClicked: { folderModel.folder = folderModel.parentFolder }
            }
        }
    }

    footer: DialogButtonBox {
        Button {
            text: qsTr("Select")
            flat: true
            enabled: (folderView.currentIndex >= 0 ) ? true : false
            onClicked: dialog.accept()
        }
        Button {
            text: qsTr("Cancel")
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    ListView {
        id: folderView
        anchors.fill: parent
        clip: true
        focus: true
        activeFocusOnTab: true

        model: folderModel
        delegate: itemDelegate

        Keys.onReturnPressed: {
            if (folderModel.isFolder(currentIndex)) {
                var dir = folderModel.folder + '/' + folderModel.get(currentIndex, 'fileName')
                folderModel.folder = dir
            } else {
                if (currentIndex >= 0) {
                    dialog.accept()
                }
            }
        }
        Keys.onPressed: if (event.key == Qt.Key_Backspace) { folderModel.folder = folderModel.parentFolder }

        FolderListModel {
            id: folderModel
            sortField: FolderListModel.Name
            showDirsFirst: true

            // due to strange bug, with showDirsFirst enabled "folder" not binded properly
            property string currentFolder

            Component.onCompleted: {
                this.currentFolder = String(this.folder).replace('file://','')
            }

            onFolderChanged: {
                this.currentFolder = String(this.folder).replace('file://','')
                folderView.currentIndex = -1
            }
        }

        highlightFollowsCurrentItem: false
        highlight: Rectangle {
            y: folderView.currentItem ? folderView.currentItem.y : 0
            height: folderView.currentItem ?folderView.currentItem.height : 0
            width: folderView.width
            color: Material.color(Material.LightGreen);
            opacity: 0.5
        }

        Component {
            id: itemDelegate
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: itemLabel.height

                Row {
                    anchors.fill: parent

                    Label {
                        anchors.baseline: itemLabel.baseline
                        padding: 16
                        text: fileIsDir ? '' : ''
                        color: fileIsDir ? Material.color(Material.Orange) : Material.color(Material.Grey)
                    }
                    Label {
                        id: itemLabel
                        padding: 8
                        text: fileName
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        folderView.focus = true
                        if (folderModel.isFolder(index)) {
                            var dir = folderModel.folder + '/' + fileName
                            folderModel.folder = dir
                        } else {
                            folderView.currentIndex = index
                        }
                    }
                }
            }
        }

        Component.onCompleted: { folderView.currentIndex = -1 }
    }
}
