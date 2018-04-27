import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: mainWindow
    visible: true

    width: 1200
    height: 800

    title: qsTr("ARKZilla")

    Material.theme: Material.Light
    Material.primary: Material.LightGreen
    Material.accent: Material.Green
    Material.elevation: 6

    FontLoader { id: faSolid; source: "fonts/fa-solid-900.ttf"}

    font.pixelSize: 18

    header: ToolBar {
        id: toolBar
        RowLayout {
            anchors.fill: parent
            IconButton {
                text: ""
                onClicked: stack.pop()
            }
            Label {
                text: mainWindow.title
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            IconButton {
                text: ""
                onClicked: {
                    passUI.open()
                }
            }
        }
    }

    StackView {
        id: stackWindow
        initialItem: SettingsUI
        anchors.fill: parent
        SettingsUI {}
        FtpManagerUI {}
        onCompleted:{
            stackWindow.pop()
        }
    }

    ToastManager {
        id: toast
    }

    PassUI {
        id: passUI
    }

}
