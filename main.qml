import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: mainWindow
    visible: true

    width: 1200
    height: 800

    title: appName

    Material.theme: Material.Light
    Material.primary: Material.LightGreen
    Material.accent: Material.Green
    Material.elevation: 6

    FontLoader { id: faSolid; source: "fonts/fa-solid-900.ttf"}

    font.pixelSize: 18

    property string appName: 'ARKZilla'

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            IconButton {
                text: ""
                onClicked: stackWindow.pop()
                visible: (stackWindow.depth > 1) ? true : false
            }
            Item { Layout.fillWidth: true  }
            IconButton {
                text: ""
                onClicked: if (stackWindow.currentItem.name != 'settings') { stackWindow.push(settingsUI) }
            }
        }
        Label {
            anchors.centerIn: parent
            text: mainWindow.title
            elide: Label.ElideRight
        }
    }

    StackView {
        id: stackWindow
        anchors.fill: parent
        initialItem: ftpManagerUI

        Component.onCompleted: {
            if (!arkzilla.host.length) {
                stackWindow.push(settingsUI)
            }
        }

        Component { id: ftpManagerUI; FtpManagerUI {} }
        Component { id: settingsUI; SettingsUI {} }
    }

    ToastManager { id: toast  }
}
