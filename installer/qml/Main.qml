import QtQuick
import QtQuick.Window

Window {
    id: win
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 640
    visible: true
    title: "Install ZengOS"
    color: Theme.bg
    visibility: windowed ? Window.Windowed : Window.FullScreen

    readonly property var args: Qt.application.arguments
    readonly property bool windowed: args.indexOf("--windowed") >= 0 || shotPath !== ""
    readonly property string shotPath: {
        const i = args.indexOf("--screenshot")
        return i >= 0 ? args[i + 1] : ""
    }
    readonly property int startPage: {
        const i = args.indexOf("--page")
        return i >= 0 ? parseInt(args[i + 1]) : 0
    }

    // What the user has chosen. Sent to the backend as-is.
    property int page: 0
    property string edition: "normal"
    property bool addAV: false
    property bool addSuite: false
    property int diskIndex: 0
    property bool encrypt: true
    readonly property bool passwordsMatch: pass.text.length > 0 && pass.text === pass2.text
    readonly property bool accountOk: fullName.text.trim().length > 0 && passwordsMatch
    readonly property var disk: Backend.disks.length > 0 ? Backend.disks[Math.min(diskIndex, Backend.disks.length - 1)] : null
    readonly property int lastPage: 4

    function gb(bytes) { return (bytes / 1e9 >= 1000 ? (bytes / 1e12).toFixed(1) + " TB" : Math.round(bytes / 1e9) + " GB") }

    function username() {
        const n = fullName.text.trim().toLowerCase().split(/\s+/)[0] || "user"
        return n.replace(/[^a-z0-9_-]/g, "") || "user"
    }

    function startInstall() {
        page = 4
        Backend.install({
            edition: edition,
            addons: [].concat(addAV && Backend.addons.zengav ? ["zengav"] : [], addSuite && Backend.addons.zengsuite ? ["zengsuite"] : []),
            disk: disk ? disk.path : "",
            encrypt: encrypt,
            confirm_erase: true,
            fullname: fullName.text.trim(),
            username: username(),
            password: pass.text,
            hostname: "zengos"
        })
    }

    onPageChanged: if (page === 3) fullName.forceFocus()

    Component.onCompleted: {
        page = startPage
        if (startPage === 2) { /* disks render from backend */ }
        if (startPage === 3) { fullName.text = "Alex Rivera"; pass.text = "hunter22"; pass2.text = "hunter22" }
        if (startPage === 4) { Backend.install({}) }
        if (shotPath !== "") shotTimer.start()
    }
    Timer {
        id: shotTimer
        interval: win.startPage === 4 ? 4800 : 900
        onTriggered: win.contentItem.grabToImage(function (r) { r.saveToFile(win.shotPath); Qt.quit() })
    }

    Rectangle { anchors.fill: parent; color: Theme.bg; z: -1 }

    // Reusable page frame: heading, subheading, content slot.
    component Page: Item {
        id: pg
        required property int index
        property string heading
        property string sub
        default property alias body: slot.data
        readonly property bool current: win.page === index
        anchors.fill: parent
        visible: opacity > 0.01
        opacity: current ? 1 : 0
        property real shift: current ? 0 : (win.page > index ? -40 : 40)
        Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
        Behavior on shift { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }

        Column {
            id: col
            width: Math.min(680, parent.width - 96)
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.max(56, (parent.height - 120 - height) / 2) + pg.shift
            spacing: 14
            Text {
                width: parent.width
                text: pg.heading
                wrapMode: Text.WordWrap
                font.family: Theme.face
                font.pixelSize: 52
                font.weight: Font.Bold
                font.letterSpacing: -1.6
                lineHeight: 0.98
                color: Theme.ink
                Accessible.role: Accessible.Heading
            }
            Text {
                width: parent.width
                text: pg.sub
                wrapMode: Text.WordWrap
                font.family: Theme.face
                font.pixelSize: 20
                lineHeight: 1.3
                color: Theme.inkDim
            }
            Item { width: 1; height: 14 }
            Column { id: slot; width: parent.width; spacing: 10 }
        }
    }

    // 0 ── Welcome
    Page {
        index: 0
        heading: "Screw Windows."
        sub: "Welcome to ZengOS. This takes about ten minutes, and nothing changes on your computer until you say so."
        Item { width: 1; height: 8 }
        Pill { text: "Get started"; onClicked: win.page = 1 }
    }

    // 1 ── Edition and apps
    Page {
        index: 1
        heading: "Pick your ZengOS."
        sub: "Both run the Zolt desktop. You can add anything else later with the package manager."
        Choice {
            width: parent.width
            title: "ZengOS"
            detail: "Zolt desktop, Files, Terminal, Firefox and media viewers."
            note: "Recommended"
            selected: win.edition === "normal"
            onPicked: win.edition = "normal"
        }
        Choice {
            width: parent.width
            title: "ZengOS Mini"
            detail: "Zolt desktop and a terminal. Nothing else."
            note: "Smallest"
            selected: win.edition === "mini"
            onPicked: win.edition = "mini"
        }
        Item { width: 1; height: 6 }
        Toggle {
            width: parent.width
            title: "ZengAV"
            detail: "Antivirus you run when you want. No background process."
            enabled: Backend.addons.zengav === true
            note: enabled ? "" : "Not on this disc"
            checked: win.addAV && enabled
            onToggled: win.addAV = !win.addAV
        }
        Toggle {
            width: parent.width
            title: "ZengSuite"
            detail: "The Zeng family of apps."
            enabled: Backend.addons.zengsuite === true
            note: enabled ? "" : "Coming soon"
            checked: win.addSuite && enabled
            onToggled: win.addSuite = !win.addSuite
        }
    }

    // 2 ── Disk
    Page {
        index: 2
        heading: "Where should it go?"
        sub: "ZengOS uses the whole disk. Everything on it will be erased."
        Repeater {
            model: Backend.disks
            Choice {
                required property var modelData
                required property int index
                width: parent.width
                title: modelData.name
                detail: modelData.path + (modelData.removable ? "  ·  Removable" : "")
                note: win.gb(modelData.size)
                selected: win.diskIndex === index
                onPicked: win.diskIndex = index
            }
        }
        Text {
            visible: Backend.disks.length === 0
            width: parent.width
            text: "No disks found. Connect one and press Refresh."
            font.family: Theme.face; font.pixelSize: 17; color: Theme.inkDim
        }
        Item { width: 1; height: 6 }
        Toggle {
            width: parent.width
            title: "Encrypt the disk"
            detail: "Protects your files if the computer is lost. Asks for your password at startup."
            checked: win.encrypt
            onToggled: win.encrypt = !win.encrypt
        }
    }

    // 3 ── Account
    Page {
        index: 3
        heading: "Who are you?"
        sub: "This creates your account on the new system."
        Field { id: fullName; width: parent.width; label: "Full name"; onAccepted: pass.forceFocus() }
        Field { id: pass; width: parent.width; label: "Password"; password: true; onAccepted: pass2.forceFocus() }
        Field {
            id: pass2
            width: parent.width
            label: "Confirm password"
            password: true
            invalid: pass2.text.length > 0 && !win.passwordsMatch
            onAccepted: if (win.accountOk) win.startInstall()
        }
    }

    // 4 ── Install
    Page {
        index: 4
        heading: Backend.error !== "" ? "Something went wrong." : (Backend.finished ? "ZengOS is ready." : "Installing ZengOS.")
        sub: Backend.error !== "" ? Backend.error
             : (Backend.finished ? "Restart to start using your new system." : Backend.message + "…")
        Item {
            visible: Backend.error === ""
            width: parent.width
            height: 10
            Rectangle { anchors.fill: parent; radius: 5; color: Theme.surfaceHi }
            Rectangle {
                height: parent.height; radius: 5
                width: parent.width * Backend.progress
                color: Theme.accent
                Behavior on width { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
            }
        }
        Item { width: 1; height: 10 }
        Pill {
            visible: Backend.finished
            text: "Restart now"
            onClicked: Backend.reboot()
        }
        Pill {
            visible: Backend.error !== ""
            primary: false
            text: "Back"
            onClicked: win.page = 3
        }
    }

    // Bottom bar: back, progress dashes, next.
    Item {
        id: bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 112
        opacity: win.page > 0 && win.page < win.lastPage ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 240 } }

        Pill {
            anchors.left: parent.left
            anchors.leftMargin: 48
            anchors.verticalCenter: parent.verticalCenter
            primary: false
            text: "Back"
            onClicked: win.page = Math.max(0, win.page - 1)
        }
        Steps {
            anchors.centerIn: parent
            count: win.lastPage
            current: Math.max(0, win.page - 1)
        }
        Pill {
            anchors.right: parent.right
            anchors.rightMargin: 48
            anchors.verticalCenter: parent.verticalCenter
            text: win.page === 3 ? "Install" : "Continue"
            enabled: win.page === 2 ? win.disk !== null : (win.page === 3 ? win.accountOk : true)
            onClicked: win.page === 3 ? win.startInstall() : win.page++
        }
    }

    Shortcut { sequence: "Escape"; enabled: win.page > 0 && win.page < win.lastPage; onActivated: win.page-- }
}
