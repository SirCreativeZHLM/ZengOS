import Quickshell
import Quickshell.Io
import QtQuick

// Spotlight-style launcher. Toggle with:  quickshell ipc call launcher toggle   (bound to Super+Space)
Scope {
    id: root
    property bool open: false

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.open = !root.open }
    }

    PanelWindow {
        visible: root.open
        anchors { top: true; left: true; right: true; bottom: true }
        color: "#99000000"
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        MouseArea { anchors.fill: parent; onClicked: root.open = false }

        Rectangle {
            width: 640
            height: Math.min(520, 76 + list.count * 56)
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.22
            radius: 24
            color: Theme.surface

            TextInput {
                id: query
                x: 28; y: 20; width: parent.width - 56; height: 36
                font.family: Theme.face; font.pixelSize: 24
                color: Theme.ink
                focus: root.open
                onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                Keys.onEscapePressed: root.open = false
                Keys.onDownPressed: list.incrementCurrentIndex()
                Keys.onUpPressed: list.decrementCurrentIndex()
                Keys.onReturnPressed: list.launchCurrent()
            }
            ListView {
                id: list
                anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 72; bottom: parent.bottom; margins: 12 }
                clip: true
                currentIndex: 0
                model: DesktopEntries.applications.values.filter(e =>
                    !e.noDisplay && e.name.toLowerCase().includes(query.text.toLowerCase()))
                function launchCurrent() {
                    const e = model[currentIndex]
                    if (e) { e.execute(); root.open = false }
                }
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: list.width; height: 52; radius: 14
                    color: ListView.isCurrentItem ? Theme.surfaceHi : "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 16
                        text: parent.modelData.name
                        color: Theme.ink
                        font.family: Theme.face; font.pixelSize: 18
                    }
                    MouseArea { anchors.fill: parent; onClicked: { list.currentIndex = parent.index; list.launchCurrent() } }
                }
            }
        }
    }
}
