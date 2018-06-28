import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

Label {
    Layout.fillWidth: true
    topPadding: 12
    bottomPadding: 4

    font.capitalization: Font.AllUppercase
    font.bold: true
    color: Material.primary

    background: Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        color: Material.primary
    }
}
