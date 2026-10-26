import Quickshell
import QtQuick

// Bottom dock: pinned apps that grow under the pointer. Hides until the pointer reaches the edge.
PanelWindow {
    id: dock
    anchors { bottom: true; left: true; right: true }
    implicitHeight: 112
    exclusiveZone: 0
    color: "transparent"
    mask: Region { item: shelf }

    readonly property var apps: [
        { name: "Files", glyph: "Fi", cmd: ["thunar"] },
        { name: "Terminal", glyph: ">_", cmd: ["foot"] },
        { name: "Firefox", glyph: "Fx", cmd: ["firefox"] },
        { name: "Launcher", glyph: "Z", cmd: ["quickshell", "ipc", "call", "launcher", "toggle"] }
    ]

    property bool shown: hover.containsMouse

    MouseArea { id: hover; anchors.fill: shelf; hoverEnabled: true }

    Rectangle {
        id: shelf
        anchors.horizontalCenter: parent.horizontalCenter
        width: row.width + 28
        height: 78
        radius: 26
        y: dock.shown ? parent.height - height - 14 : parent.height - 6
        color: Theme.surface
        Behavior on y { SpringAnimation { spring: 5; damping: 0.7; mass: 0.5 } }

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 12
            Repeater {
                model: dock.apps
                Item {
                    required property var modelData
                    id: cell
                    width: 54 * scaleFor.value; height: 54 * scaleFor.value
                    anchors.bottom: parent.bottom
                    QtObject {
                        id: scaleFor
                        // Magnify when the pointer is over (or near) this icon.
                        property real value: tile.containsMouse ? 1.35 : 1
                        Behavior on value { SpringAnimation { spring: 6; damping: 0.6; mass: 0.4 } }
                    }
                    Rectangle {
                        anchors.fill: parent
                        radius: width * 0.28
                        color: Theme.surfaceHi
                        Text {
                            anchors.centerIn: parent
                            text: cell.modelData.glyph
                            color: Theme.accent
                            font.family: Theme.face; font.pixelSize: parent.width * 0.46; font.weight: Font.Bold
                        }
                    }
                    MouseArea {
                        id: tile
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Quickshell.execDetached(cell.modelData.cmd)
                    }
                }
            }
        }
    }
}
