import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Dialog {
    id: dialog

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 300
    focus: true
    modal: true

    title: qsTr('Enter password')

    TextField {
        id: password

        width: parent.width
        focus: true
        selectByMouse: true
        echoMode: TextField.Password

        placeholderText: qsTr('password')
        Keys.onReturnPressed: { length ? dialog.accept() : focus = true }
    }

    footer: DialogButtonBox {
        Button {
            text: qsTr('Accept')
            flat: true
            onClicked: if (!password.text.length) { password.focus = true } else { dialog.accept() }
        }
        Button {
            text: qsTr('Cancel')
            flat: true
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
        }
    }

    onAccepted: { arkzilla.password = password.text; }
}
