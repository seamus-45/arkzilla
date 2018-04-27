import QtQuick 2.0

/**
  * adapted from StackOverflow:
  * http://stackoverflow.com/questions/26879266/make-toast-in-android-by-qml
  * @brief Manager that creates Toasts dynamically
  */
ListView {
    /**
      * Public
      */

    /**
      * @brief Shows a Toast
      *
      * @param {string} text Text to show
      * @param {string} color Background color for message, defaults to '#222222'
      * @param {real} duration Duration to show in milliseconds, defaults to 3000
      */
    function show(text, color, duration) {
        color = typeof color !== 'undefined' ? color : defaultColor;
        duration = typeof duration !== 'undefined' ? duration : defaultDuration;
        model.insert(0, {text: text, color: color, duration: duration});
    }

    /**
      * Private
      */

    readonly property real defaultDuration: 3000
    readonly property string defaultColor: '#222222'

    id: root

    z: Infinity
    spacing: 5
    anchors.fill: parent
    anchors.bottomMargin: 10
    verticalLayoutDirection: ListView.BottomToTop

    interactive: false

    displaced: Transition {
        NumberAnimation {
            properties: "y"
            easing.type: Easing.InOutQuad
        }
    }

    delegate: Toast {
        text: model.text
        color: model.color
        time: model.duration
    }

    model: ListModel {id: model}
}