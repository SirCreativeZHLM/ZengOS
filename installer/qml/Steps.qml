import QtQuick

// Row of progress dashes along the bottom: finished and current steps are filled.
Row {
    id: root
    property int count: 5
    property int current: 0
    spacing: 8
    Repeater {
        model: root.count
        Rectangle {
            required property int index
            width: index === root.current ? 28 : 8
            height: 8
            radius: 4
            color: index <= root.current ? Theme.accent : Theme.surfaceHi
            Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
}
