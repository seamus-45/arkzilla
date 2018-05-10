import QtQuick 2.7
import QtQuick.Controls 2.2

ToolButton {
    property string color

    contentItem: Label {
        font { family: faSolid.name; pixelSize: 20 }
        text: parent.text
        color: parent.color
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
