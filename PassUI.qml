import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Dialog {
    id: dialog

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    focus: true
    modal: true
    title: qsTr('Enter password')
    standardButtons: Dialog.Ok | Dialog.Cancel
    width: 300

    ColumnLayout {
        spacing: 20
        anchors.fill: parent
        TextField {
            focus: true
            placeholderText: qsTr('password')
            selectByMouse: true
            echoMode: TextField.Password
            Layout.fillWidth: true
            Keys.onReturnPressed: { length ? dialog.accept() : focus = true }
        }
    }
}
