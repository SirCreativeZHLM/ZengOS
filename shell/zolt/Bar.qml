import Quickshell
import Quickshell.Io
import QtQuick

// Top bar: ZengOS menu on the left, clock in the middle, session actions on the right.
PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: 34
    color: Theme.bg

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        text: "ZengOS"
        color: Theme.ink
        font.family: Theme.face; font.pixelSize: 14; font.weight: Font.Bold
        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            onClicked: launcherIpc.running = true
        }
    }
    Process { id: launcherIpc; command: ["quickshell", "ipc", "call", "launcher", "toggle"] }

    Text {
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "ddd d MMM   h:mm AP")
        color: Theme.ink
        font.family: Theme.face; font.pixelSize: 14; font.weight: Font.Medium
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        Repeater {
            model: [
                { label: "Lock", cmd: ["loginctl", "lock-session"] },
                { label: "Restart", cmd: ["systemctl", "reboot"] },
                { label: "Shut down", cmd: ["systemctl", "poweroff"] }
            ]
            Rectangle {
                required property var modelData
                width: t.implicitWidth + 20; height: 24; radius: 12
                color: m.containsMouse ? Theme.surfaceHi : "transparent"
                Text { id: t; anchors.centerIn: parent; text: parent.modelData.label; color: Theme.inkDim; font.family: Theme.face; font.pixelSize: 13 }
                MouseArea { id: m; anchors.fill: parent; hoverEnabled: true; onClicked: Quickshell.execDetached(parent.modelData.cmd) }
            }
        }
    }
}
