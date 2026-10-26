import QtQuick

// Primary or quiet pill button. Responds on press, not release.
Item {
    id: root
    property alias text: label.text
    property bool primary: true
    signal clicked

    implicitWidth: Math.max(150, label.implicitWidth + 64)
    implicitHeight: 56
    opacity: enabled ? 1 : 0.4
    scale: area.pressed && enabled ? 0.97 : 1
    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.primary ? (area.containsMouse ? Qt.lighter(Theme.accent, 1.1) : Theme.accent) : (area.containsMouse ? Qt.lighter(Theme.surfaceHi, 1.25) : Theme.surfaceHi)
        Behavior on color { ColorAnimation { duration: 140 } }
    }
    Text {
        id: label
        anchors.centerIn: parent
        font.family: Theme.face
        font.pixelSize: 18
        font.weight: Font.DemiBold
        color: root.primary ? Theme.accentInk : Theme.ink
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.enabled) root.clicked()
    }
    Accessible.role: Accessible.Button
    Accessible.name: label.text
}
