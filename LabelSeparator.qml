import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

MenuSeparator {
    padding: 0
    topPadding: 6
    bottomPadding: 6

    property string text
    property string color: Material.primary

    contentItem: Label {
        color: parent.color
        text: parent.text.toUpperCase()
    }
}
