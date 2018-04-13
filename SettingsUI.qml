import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

Pane {
    anchors.fill: parent

    Settings {
        id: settings
        property alias host: host.text
        property alias login: login.text
        property alias password: password.text
        property alias remotePath: remotePath.text
        property alias enableSSL: enableSSL.position
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
            placeholderText: qsTr("example.org")
            selectByMouse: true
            Layout.minimumWidth: 400
        }
        Label {
            text: qsTr("Login:")
        }
        TextField {
            id: login
            placeholderText: qsTr("anonymous")
            selectByMouse: true
            Layout.minimumWidth: 400
        }
        Label {
            text: qsTr("Password:")
        }
        TextField {
            id: password
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
        Button {
            text: qsTr("Test connection")
            Layout.alignment: Qt.AlignRight
            onClicked: {
                arkzilla.testConnection()
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
                    if (!storePass.checked)
                        settings.password = ''
                }
            }
            Button {
                text: qsTr("Cancel")
                onClicked: stackWindow.pop()
            }
        }

        Component.onCompleted: {
            if (settings.password.length > 0)
                storePass.checked = true
        }

        Connections {
            target: arkzilla

            onTestResult: {
                console.log('test result: ' + testResult)
            }
        }
    }
} 
