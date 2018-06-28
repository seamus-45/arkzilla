import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Pane {
    id: settingsPane

    function saveSettings() {
        arkzilla.storePass = storePass.checked

        arkzilla.host = host.text
        arkzilla.login = login.text
        arkzilla.password = password.text
        arkzilla.remotePath = remotePath.text
        arkzilla.toolsPath = toolsPath.text
        arkzilla.darkTheme = darkTheme.checked

        arkzilla.syncLocalBackups()
        stackWindow.pop()
        toast.show(qsTr('Settings saved'))
    }

    StackView.onActivating: mainWindow.title = qsTr('Settings')
    StackView.onDeactivating: mainWindow.title = mainWindow.instanceName

    FolderDialog {
        id: folderDialog
        filter: ['ark-tools.jar']
        caption: qsTr('Please select ark-tools.jar location')
        onAccepted: toolsPath.text = filePath
    }

    Flickable {
        anchors.fill: parent
        contentHeight: gridLayout.height

        Keys.onEscapePressed: {
            stackWindow.pop()
        }

        GridLayout {
            id: gridLayout
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 3
            columnSpacing: 12
            width: (parent.width > 800) ? 800 : parent.width

            state: 'normal'

            SettingsSection {
                Layout.columnSpan: 3
                Layout.fillWidth: true
                text: qsTr('Remote server')
            }
            Rectangle {
                Layout.rowSpan: 7
                Layout.fillHeight: true
                width: 4
                color: Material.accent
            }
            Label {
                Layout.alignment: Qt.AlignRight
                anchors.baseline: host.baseline
                text: qsTr('Address:')
            }
            TextField {
                id: host
                text: arkzilla.host
                placeholderText: qsTr('example.org')
                selectByMouse: true
                Layout.fillWidth: true
            }
            Label {
                Layout.alignment: Qt.AlignRight
                anchors.baseline: login.baseline
                text: qsTr('Login:')
            }
            TextField {
                id: login
                text: arkzilla.login
                placeholderText: qsTr('anonymous')
                selectByMouse: true
                Layout.fillWidth: true
            }
            Label {
                Layout.alignment: Qt.AlignRight
                anchors.baseline: password.baseline
                text: qsTr('Password:')
            }
            TextField {
                id: password
                text: arkzilla.password
                placeholderText: qsTr('password')
                selectByMouse: true
                echoMode: TextInput.Password
                //passwordMaskDelay: 300
                Layout.fillWidth: true
            }
            CheckBox {
                id: storePass
                text: qsTr('Remember password')
                Layout.alignment: Qt.AlignRight
                Layout.columnSpan: 2
                onClicked: if (checked) { toast.show(qsTr('WARNING! Password will be stored in clear text!'), Material.color(Material.Red).toString(), 10000) }
            }
            Label {
                Layout.alignment: Qt.AlignRight
                anchors.baseline: remotePath.baseline
                text: qsTr('Remote folder:')
            }
            TextField {
                id: remotePath
                text: arkzilla.remotePath
                placeholderText: qsTr('/SavedArks')
                selectByMouse: true
                Layout.fillWidth: true
            }
            RowLayout {
                Layout.column: 2
                Layout.row: 7

                Switch {
                    id: enableSSL
                    Layout.fillWidth: true
                    text: qsTr('Enable SSL/TLS')
                    Layout.alignment: Qt.AlignLeft
                    enabled: false
                }
                Button {
                    id: testConnection
                    text: qsTr('Test connection')
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        if (!host.length) {
                            host.focus = true
                            return
                        }
                        testInProgress.running = true
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

            SettingsSection {
                Layout.columnSpan: 3
                Layout.fillWidth: true
                text: qsTr('Ark-tools')
            }
            Rectangle {
                Layout.fillHeight: true
                width: 4
                color: Material.accent
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
                    placeholderText: qsTr('ark-tools.jar')
                }
                Button {
                    text: qsTr('Choose')
                    anchors.baseline: parent.baseline
                    onClicked: {
                        folderDialog.open()
                    }
                }
            }

            SettingsSection {
                Layout.columnSpan: 3
                Layout.fillWidth: true
                text: qsTr('Theme')
            }
            Rectangle {
                Layout.fillHeight: true
                width: 4
                color: Material.accent
            }
            Switch {
                id: darkTheme
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignRight
                text: qsTr('Switch Light/Dark theme')
                checked: arkzilla.darkTheme
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 24
                Layout.columnSpan: 3
                Layout.alignment: Qt.AlignRight
                spacing: 12
                Button {
                    text: qsTr('Save')
                    onClicked: {
                        host.length ? saveSettings() : host.focus = true
                    }
                }
                Button {
                    text: qsTr('Cancel')
                    onClicked: stackWindow.pop()
                }
            }

            Component.onCompleted: {
                storePass.checked = arkzilla.storePass
                host.forceActiveFocus()
            }

            states: [
                State {
                    name: 'testing'; when: testInProgress.running
                    PropertyChanges { target: testConnection; enabled: false }
                    PropertyChanges { target: testConnection.contentItem; visible: false }
                },
                State {
                    name: 'normal'; when: !testInProgress.running
                    PropertyChanges { target: testConnection; enabled: true }
                    PropertyChanges { target: testConnection.contentItem; visible: true }
                }
            ]

            Connections {
                target: arkzilla

                onConnectionError: {
                    testInProgress.running = false
                    toast.show(qsTr('Connection fail: ') + error,
                            Material.color(Material.Red).toString())
                }

                onConnectionSuccess: {
                    testInProgress.running = false
                    toast.show(qsTr('Connection successful'),
                            Material.color(Material.Green).toString())
                }
            }
        }
    }
}
