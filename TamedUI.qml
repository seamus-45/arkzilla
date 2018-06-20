import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Pane {
    padding: 0

    property alias backup: classesView.backup

    Column {
        anchors.fill: parent

        ListView {
            id: classesView
            width: parent.width * 0.25
            height: parent.height

            property string backup

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
                        text: name
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: classesView.currentIndex = index
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

            Keys.onEscapePressed: {
                stackWindow.pop()
            }

            Component.onCompleted: {
                classesView.currentIndex = -1
                arkzilla.loadClasses(classesView.backup)
            }

            Connections {
                target: arkzilla

                onLoadClassesError: {
                    toast.show(error, Material.color(Material.Red).toString())
                }
            }
        }

    }
}
