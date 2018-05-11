import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Pane {
    id: settingsPane
    property string name: 'settings'
    property string title: qsTr('Settings')

    function saveSettings() {
        arkzilla.storePass = storePass.checked

        arkzilla.host = host.text
        arkzilla.login = login.text
        arkzilla.password = password.text
        arkzilla.remotePath = remotePath.text
        arkzilla.toolsPath = toolsPath.text

        stackWindow.pop()
        toast.show(qsTr('Settings saved'))
    }

    StackView.onRemoved: mainWindow.title = stackWindow.currentItem.title
    StackView.onActivated: mainWindow.title = title

    FolderDialog {
        id: folderDialog
        filter: ['ark-tools.jar']
        caption: qsTr('Please select ark-tools.jar location')
        onAccepted: toolsPath.text = filePath
    }

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: gridLayout.height

        GridLayout {
            id: gridLayout
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.max((settingsPane.height - height) / 2, 0)
            columns: 3
            columnSpacing: 12
            width: (parent.width > 800) ? Math.min(parent.width*0.66, 800) : parent.width

            LabelSeparator {
                Layout.columnSpan: 3
                Layout.fillWidth: true
                text: qsTr('Remote server')
            }
            Rectangle {
                Layout.rowSpan: 7
                Layout.fillHeight: true
                width: 4
                color: Material.color(Material.Green)
            }
            Label {
                Layout.alignment: Qt.AlignRight
                anchors.baseline: host.baseline
                text: qsTr("Address:")
            }
            TextField {
                id: host
                text: arkzilla.host
                placeholderText: qsTr("example.org")
                selectByMouse: true
                Layout.fillWidth: true
            }
            Label {
                Layout.alignment: Qt.AlignRight
                anchors.baseline: login.baseline
                text: qsTr("Login:")
            }
            TextField {
                id: login
                text: arkzilla.login
                placeholderText: qsTr("anonymous")
                selectByMouse: true
                Layout.fillWidth: true
            }
            Label {
                Layout.alignment: Qt.AlignRight
                anchors.baseline: password.baseline
                text: qsTr("Password:")
            }
            TextField {
                id: password
                text: arkzilla.password
                placeholderText: qsTr("password")
                selectByMouse: true
                echoMode: TextInput.Password
                //passwordMaskDelay: 300
                Layout.fillWidth: true
            }
            CheckBox {
                id: storePass
                text: qsTr("Remember password")
                Layout.alignment: Qt.AlignRight
                Layout.columnSpan: 2
                onClicked: if (checked) { toast.show(qsTr('WARNING! Password will be stored in clear text!'), Material.color(Material.Red).toString(), 10000) }
            }
            Label {
                Layout.alignment: Qt.AlignRight
                anchors.baseline: remotePath.baseline
                text: qsTr("Remote folder:")
            }
            TextField {
                id: remotePath
                text: arkzilla.remotePath
                placeholderText: qsTr("/SavedArks")
                selectByMouse: true
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.column: 2
                Layout.row: 7

                Switch {
                    id: enableSSL
                    Layout.fillWidth: true
                    text: qsTr("Enable SSL/TLS")
                    Layout.alignment: Qt.AlignLeft
                    enabled: false
                }
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

            LabelSeparator {
                Layout.columnSpan: 3
                Layout.fillWidth: true
                text: qsTr('Ark-tools')
            }
            Rectangle {
                Layout.fillHeight: true
                width: 4
                color: Material.color(Material.Green)
            }
            Label {
                id: toolsLabel
                Layout.alignment: Qt.AlignRight
                text: qsTr('Path:')
            }
            RowLayout {
                Layout.fillWidth: true
                anchors.baseline: toolsLabel.baseline
                TextField {
                    id: toolsPath
                    Layout.fillWidth: true
                    anchors.baseline: parent.baseline
                    text: arkzilla.toolsPath
                    placeholderText: qsTr("ark-tools.jar")
                }
                Button {
                    text: qsTr('Choose')
                    anchors.baseline: parent.baseline
                    onClicked: {
                        folderDialog.open()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 24
                Layout.columnSpan: 3
                Layout.alignment: Qt.AlignRight
                spacing: 12
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
}
