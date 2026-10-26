import QtQuick

// A labelled switch row.
Item {
    id: root
    property string title
    property string detail
    property bool checked: false
    signal toggled

    implicitHeight: 88
    scale: area.pressed ? 0.985 : 1
    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: area.containsMouse ? Theme.surfaceHi : Theme.surface
        Behavior on color { ColorAnimation { duration: 140 } }
    }
    Column {
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.right: track.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        Text {
            width: parent.width
            text: root.title
            elide: Text.ElideRight
            font.family: Theme.face; font.pixelSize: 19; font.weight: Font.DemiBold
            color: Theme.ink
        }
        Text {
            width: parent.width
            text: root.detail
            elide: Text.ElideRight
            font.family: Theme.face; font.pixelSize: 15
            color: Theme.inkDim
        }
    }
    Rectangle {
        id: track
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        width: 56; height: 32; radius: 16
        color: root.checked ? Theme.accent : Theme.surfaceHi
        Behavior on color { ColorAnimation { duration: 180 } }
        Rectangle {
            width: 26; height: 26; radius: 13
            y: 3
            x: root.checked ? parent.width - width - 3 : 3
            color: root.checked ? Theme.accentInk : Theme.inkDim
            Behavior on x { SpringAnimation { spring: 4; damping: 0.45; mass: 0.5 } }
            Behavior on color { ColorAnimation { duration: 180 } }
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
    Accessible.role: Accessible.CheckBox
    Accessible.name: title
    Accessible.checked: checked
}
