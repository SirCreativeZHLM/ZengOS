import QtQuick

// Single-line text field with a floating label.
Item {
    id: root
    property string label
    property alias text: input.text
    property bool password: false
    property bool invalid: false
    signal accepted

    implicitHeight: 64

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: input.activeFocus ? Theme.surfaceHi : Theme.surface
        Behavior on color { ColorAnimation { duration: 140 } }
        Rectangle {
            visible: root.invalid
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 2
            border.color: Theme.danger
        }
    }
    Text {
        id: caption
        x: 22
        text: root.label
        font.family: Theme.face
        font.pixelSize: input.text.length > 0 || input.activeFocus ? 12 : 17
        color: Theme.inkDim
        y: input.text.length > 0 || input.activeFocus ? 9 : (parent.height - height) / 2
        Behavior on y { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on font.pixelSize { NumberAnimation { duration: 160 } }
    }
    TextInput {
        id: input
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 22
        anchors.rightMargin: 22
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        font.family: Theme.face
        font.pixelSize: 18
        color: Theme.ink
        selectionColor: Theme.accent
        selectedTextColor: Theme.accentInk
        echoMode: root.password ? TextInput.Password : TextInput.Normal
        clip: true
        onAccepted: root.accepted()
    }
    function forceFocus() { input.forceActiveFocus() }
    Accessible.role: Accessible.EditableText
    Accessible.name: label
}
