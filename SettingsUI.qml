import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Pane {

    property string name: 'settings'
    property string title: qsTr('Settings')

    function saveSettings() {
        arkzilla.storePass = storePass.checked

        arkzilla.host = host.text
        arkzilla.login = login.text
        arkzilla.password = password.text
        arkzilla.remotePath = remotePath.text

        stackWindow.pop()
        toast.show(qsTr('Settings saved'))
    }

    StackView.onRemoved: mainWindow.title = stackWindow.currentItem.title
    StackView.onActivated: mainWindow.title = title

    GridLayout {
        columns: 2
        columnSpacing: 10
        anchors.centerIn: parent

        Label {
            text: qsTr("Server address:")
        }
        TextField {
            id: host
            text: arkzilla.host
            placeholderText: qsTr("example.org")
            selectByMouse: true
            Layout.minimumWidth: 400
        }
        Label {
            text: qsTr("Login:")
        }
        TextField {
            id: login
            text: arkzilla.login
            placeholderText: qsTr("anonymous")
            selectByMouse: true
            Layout.minimumWidth: 400
        }
        Label {
            text: qsTr("Password:")
        }
        TextField {
            id: password
            text: arkzilla.password
            placeholderText: qsTr("password")
            selectByMouse: true
            echoMode: TextInput.Password
            //passwordMaskDelay: 300
            Layout.minimumWidth: 400
        }
        CheckBox {
            id: storePass
            text: qsTr("Remember password")
            Layout.alignment: Qt.AlignRight
            Layout.columnSpan: 2
            onClicked: if (checked) { toast.show(qsTr('WARNING! Password will be stored in clear text!'), Material.color(Material.Red).toString(), 10000) }
        }
        Label {
            text: qsTr("Remote path:")
        }
        TextField {
            id: remotePath
            text: arkzilla.remotePath
            placeholderText: qsTr("/SavedArks")
            selectByMouse: true
            Layout.minimumWidth: 400
        }
        Switch {
            id: enableSSL
            text: qsTr("Enable SSL/TLS")
            Layout.alignment: Qt.AlignLeft
            enabled: false
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignRight
            Button {
                id: testConnection
                text: qsTr("Test connection")
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    if (!host.length) {
                        host.focus = true
                        return
                    }
                    testInProgress.running = true
                    testConnection.contentItem.visible = false
                    arkzilla.testConnection(host.text, login.text, password.text)
                }
                BusyIndicator {
                    id: testInProgress
                    running: false
                    implicitHeight: parent.height * 0.75
                    implicitWidth: parent.width * 0.75
                    anchors.centerIn: parent
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignRight
            Button {
                text: qsTr("Save")
                onClicked: {
                    host.length ? saveSettings() : host.focus = true
                }
            }
            Button {
                text: qsTr("Cancel")
                onClicked: stackWindow.pop()
            }
        }

        Component.onCompleted: {
            storePass.checked = arkzilla.storePass
            host.forceActiveFocus()
        }

        Connections {
            target: arkzilla

            onConnectionSuccess: {
                testInProgress.running = false
                testConnection.contentItem.visible = true
                toast.show(qsTr('Connection successful'),
                           Material.color(Material.Green).toString())
            }

            onConnectionError: {
                testInProgress.running = false
                testConnection.contentItem.visible = true
                toast.show(qsTr('Connection fail: ') + error,
                           Material.color(Material.Red).toString())
            }
        }
    }
}
