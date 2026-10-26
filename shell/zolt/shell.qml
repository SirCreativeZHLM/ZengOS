//@ pragma UseQApplication
import Quickshell
import QtQuick

// Zolt: the ZengOS desktop shell. One bar and one dock per screen, one launcher.
ShellRoot {
    Variants {
        model: Quickshell.screens
        Scope {
            required property var modelData
            Bar { screen: modelData }
            Dock { screen: modelData }
        }
    }
    Launcher {}
}
