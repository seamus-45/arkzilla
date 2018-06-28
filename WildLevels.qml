import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

RowLayout {
    spacing: 2
    property variant levels
    property variant levelsMap: {'HP': 'health', 'St': 'stamina', 'Ox': 'oxygen', 'Fo': 'food', 'We': 'weight', 'Dm': 'melee', 'Sp': 'speed', 'To': 'torpor'}

    function cellColor(lvl) {
        var maxHueValue = 150 / 6 * 1.4
        var hue = Math.min(0.3, 0.3 * lvl / maxHueValue)
        return Qt.hsla(hue, 1, 0.7, 1)
    }

    Repeater {
        model: ['HP', 'St', 'Ox', 'Fo', 'We', 'Dm', 'Sp', 'To']
        delegate: Label {
            padding: 2
            color: 'black'
            text: levels ? qsTr(modelData) + ': ' + levels[levelsMap[modelData]] : 0
            background: Rectangle {
                anchors.fill: parent
                border.width: 1
                border.color: 'black'
                color: levels ? cellColor(levels[levelsMap[modelData]]) : 'transparent'
            }
        }
    }
}
