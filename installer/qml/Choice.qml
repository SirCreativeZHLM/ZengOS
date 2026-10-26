import QtQuick

// A selectable row: title, one line of detail, and an optional trailing note.
Item {
    id: root
    property string title
    property string detail
    property string note
    property bool selected: false
    signal picked

    implicitHeight: 88
    scale: area.pressed ? 0.985 : 1
    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: root.selected ? Theme.surfaceHi : (area.containsMouse ? Qt.lighter(Theme.surface, 1.12) : Theme.surface)
        Behavior on color { ColorAnimation { duration: 140 } }
    }
    Rectangle {
        id: dot
        x: 24
        anchors.verticalCenter: parent.verticalCenter
        width: 24; height: 24; radius: 12
        color: root.selected ? Theme.accent : "transparent"
        border.width: root.selected ? 0 : 2
        border.color: Theme.inkDim
        Rectangle {
            anchors.centerIn: parent
            width: 8; height: 8; radius: 4
            color: Theme.accentInk
            visible: root.selected
        }
    }
    Column {
        anchors.left: dot.right
        anchors.leftMargin: 20
        anchors.right: noteText.left
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
    Text {
        id: noteText
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        text: root.note
        font.family: Theme.face; font.pixelSize: 15
        color: Theme.inkDim
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.picked()
    }
    Accessible.role: Accessible.RadioButton
    Accessible.name: title
    Accessible.checked: selected
}
