import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3

CheckBox {
    id: control
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    spacing: 0
    tristate: true
    autoExclusive: true
    focusPolicy: Qt.NoFocus

    property int innerPadding: 5
    property bool filter: false
    property bool sort: false
    property alias filterText: filter.text

    function clear() { filter.clear() }

    contentItem: Rectangle {
        color: 'transparent'

        Label {
            width: parent.width - control.indicator.width
            height: parent.height
            padding: control.innerPadding
            text: control.text
            verticalAlignment: Text.AlignVCenter
            font: control.font
            visible: !control.filter
        }

        TextInput {
            id: filter
            width: parent.width - control.indicator.width
            height: parent.height
            padding: control.innerPadding
            verticalAlignment: Text.AlignVCenter
            font: control.font
            visible: control.filter
            clip: true
            activeFocusOnTab: true
            selectByMouse: true
            color: Material.foreground
            selectionColor: Material.accent
            selectedTextColor: 'white'
            cursorDelegate: Rectangle {
                width: 2
                color: Material.accent
                visible: parent.activeFocus && parent.selectedText == ""
                SequentialAnimation on opacity {
                    running: parent.visible
                    loops: Animation.Infinite;
                    NumberAnimation { to: 1; duration: 500; easing.type: "InQuad"}
                    NumberAnimation { to: 0; duration: 500; easing.type: "OutQuad"}
                }
            }

            Text {
                anchors.fill: parent
                padding: control.innerPadding
                verticalAlignment: Text.AlignVCenter
                font: control.font
                color: Material.foreground
                opacity: 0.35
                visible: !parent.text
                text: control.text
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.activeFocus ? 2 : 1
                color: parent.activeFocus ? Material.accent : Material.foreground
                opacity: parent.activeFocus ? 1 : 0.35
            }
        }

        Component.onCompleted: {
            textMetrics.text = control.text
            implicitWidth = textMetrics.width + control.innerPadding * 2 + control.indicator.width
            implicitHeight = textMetrics.height + control.innerPadding * 2
        }
    }

    indicator: Rectangle {
        implicitWidth: control.font.pixelSize + control.innerPadding
        height: control.contentItem.height
        x: control.width - width - control.spacing
        y: control.height / 2 - height / 2
        color: 'transparent'
        visible: control.sort
        Text {
            anchors.fill: parent
            text: (checkState == Qt.PartiallyChecked || checkState == Qt.Unchecked ) ? '' : ''
            color: Material.foreground
            opacity: checkState != Qt.Unchecked ? 1.0 : 0.35
            font.pixelSize: control.font.pixelSize
            font.family: faSolid.name
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    background: Rectangle {
        anchors.fill: parent
        visible: control.down
        opacity: 0.3
        color: Material.accent
    }

    TextMetrics {
        id: textMetrics
        font: control.font
    }
}
