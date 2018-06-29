import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

ToolButton {
    focusPolicy: Qt.NoFocus
    property string color: Material.foreground

    contentItem: Label {
        font { family: faSolid.name; pixelSize: 20 }
        text: parent.text
        color: parent.color
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
