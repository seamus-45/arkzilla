import QtQuick 2.7
import QtQuick.Controls.Material 2.2

/**
 * adapted from StackOverflow:
 * http://stackoverflow.com/questions/26879266/make-toast-in-android-by-qml
 */

/**
  * @brief An Android-like timed message text in a box
  */
Rectangle {

    /**
      * Public
      */

    property real time
    property string text

    signal animationEnded()

    /**
      * Private
      */

    readonly property real margin: 20
    readonly property real fadeTime: 300

    id: root

    anchors {
        left: parent.left
        right: parent.right
        margins: margin
    }

    height: message.height + margin
    radius: margin / 2

    opacity: 0

    Text {
        id: message
        text: parent.text
        textFormat: Text.StyledText
        color: Material.background
        linkColor: Material.color(Material.Cyan)
        font.pixelSize: mainWindow.font.pixelSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: margin / 2
        }
        onLinkActivated: Qt.openUrlExternally(link)
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    SequentialAnimation on opacity {
        id: animation
        running: false


        NumberAnimation {
            to: .9
            duration: fadeTime
        }

        PauseAnimation {
            duration: time - 2 * fadeTime
        }

        NumberAnimation {
            to: 0
            duration: fadeTime
        }

        onRunningChanged: if (!running) { root.animationEnded() }
    }

    Component.onCompleted: {
        animation.start()
    }
}
