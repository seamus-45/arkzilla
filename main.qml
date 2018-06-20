import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: mainWindow
    visible: true

    width: 1200
    height: 800

    title: instanceName

    Material.theme: arkzilla.darkTheme ? Material.Dark : Material.Light
    Material.primary: Material.Green
    Material.accent: Material.LightGreen
    Material.elevation: 6

    FontLoader { id: faSolid; source: "fonts/fa-solid-900.ttf"}

    font.pixelSize: 18

    readonly property string appName: 'ARKZilla'
    readonly property string instanceName: arkzilla.host.length ? appName + ' (' + arkzilla.host + ')' : appName

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            IconButton {
                text: ""
                color: 'white'
                onClicked: stackWindow.pop()
                visible: (stackWindow.depth > 1) ? true : false
            }
            Item { Layout.fillWidth: true  }
            IconButton {
                text: ""
                color: 'white'
                ToolTip.text: qsTr("Open settings")
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                visible: mainWindow.title != qsTr('Settings')
                onClicked: stackWindow.push(settingsUI)
            }
        }
        Label {
            anchors.centerIn: parent
            text: mainWindow.title
            color: 'white'
            elide: Label.ElideRight
        }
    }

    StackView {
        id: stackWindow
        anchors.fill: parent
        initialItem: backupUI

        Component.onCompleted: {
            if (!arkzilla.host.length) {
                stackWindow.push(settingsUI)
            }
        }

        Component { id: backupUI; BackupUI {} }
        Component { id: tamedUI; TamedUI {} }
        Component { id: settingsUI; SettingsUI {} }
    }

    ToastManager { id: toast  }
}
