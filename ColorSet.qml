import QtQuick 2.7
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3

RowLayout {
    spacing: 2
    property variant colors
    property variant colorsMap: ["","#ff0000","#0000ff","#00ff00","#ffff00","#00ffff","#ff00ff","#c0ffba","#c8caca","#786759","#ffb46c","#fffa8a","#ff756c","#7b7b7b","#3b3b3b","#593a2a","#224900","#812118","#ffffff","#ffa8a8","#592b2b","#ffb694","#88532f","#cacaa0","#94946c","#e0ffe0","#799479","#224122","#d9e0ff","#394263","#e4d9ff","#403459","#ffe0ba","#948575","#594e41","#595959","#ffffff","#b79683","#eadad5","#d0a794","#c3b39f","#887666","#a0664b","#cb7956","#bc4f00","#79846c","#909c79","#a5a48b","#74939c","#787496","#b0a2c0","#6281a7","#485c75","#5fa4ea","#4568d4","#ededed","#515151"]
    Repeater {
        model: colors ? 6 : 0
        delegate: Rectangle {
            width: textMetrics.width + label.padding * 2
            height: label.height
            border.width: 1
            border.color: 'black'
            visible: colors[index] != 0
            color: colorsMap[colors[index]]
            Label {
                id: label
                padding: 2
                width: textMetrics.width + padding * 2
                horizontalAlignment: Text.AlignHCenter
                color: 'white'
                layer.enabled: true
                layer.effect: DropShadow { radius: 2; verticalOffset: 1; horizontalOffset: 1 }
                text: index + ' ' + colors[index]
            }
            TextMetrics {
                id: textMetrics
                font: label.font
                text: '0 00'
            }
        }
    }
}
