import QtQuick 2.0
import QtQuick.Controls 2.2

Item {
    id: rootItem
    height: 48
    width: parent.width

    property bool refresh: state == "pulled" ? true : false
    property string text
    property string color: '#999'
    property int size: 18

    Row {
        id: pullLabel

        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        spacing: 6

        Text {
            id: refreshIcon
            anchors.verticalCenter: parent.verticalCenter
            text: ''
            font.family: faSolid.name
            font.pixelSize: rootItem.size
            color: rootItem.color

            Behavior on rotation { NumberAnimation { duration: 200 } }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: rootItem.text
            font.pixelSize: rootItem.size
            color: rootItem.color
        }
        Behavior on opacity  { NumberAnimation { duration: 200 } }
    }

    states: [
        State {
            name: "normal"; when: ftpView.contentY >= -pullLabel.height/2
            PropertyChanges { target: pullLabel; opacity: 0; }
            PropertyChanges { target: refreshIcon; rotation: 0; }
        },
        State {
            name: "pulled"; when: ftpView.contentY < -pullLabel.height/2
            PropertyChanges { target: pullLabel; opacity: 1; }
            PropertyChanges { target: refreshIcon; rotation: 180; }
        }
    ]
}
