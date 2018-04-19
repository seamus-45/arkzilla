import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Pane {
    anchors.fill: parent

    function saveSettings() {
        arkzilla.host = host.text
        arkzilla.login = login.text
        arkzilla.password = storePass.checked ? password.text : ''
        arkzilla.remotePath = remotePath.text
    }

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
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            Layout.columnSpan: 2
            Label {
                text: qsTr("WARNING! Password will be stored as the plain text.")
                visible:  storePass.checked
                color: "#f00"
                font.pixelSize: 16
            }
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
                    if (!host.length) {
                        host.focus = true
                        return
                    }
                    saveSettings()
                }
            }
            Button {
                text: qsTr("Cancel")
                onClicked: stackWindow.pop()
            }
        }

        Component.onCompleted: {
            storePass.checked = password.length
        }

        Connections {
            target: arkzilla

            onTestResult: {
                testInProgress.running = false
                testConnection.contentItem.visible = true
                if (testResult) {
                    toast.show(
                        qsTr('Connection successful'),
                        Material.color(Material.Green).toString()
                    )
                } else {
                    toast.show(
                        qsTr('Connection fail'),
                        Material.color(Material.Red).toString()
                    )
                }
            }
        }
    }
}
