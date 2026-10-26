pragma Singleton
import QtQuick

QtObject {
    property bool dark: Qt.application.arguments.indexOf("--light") < 0

    readonly property color bg: dark ? "#000000" : "#F5F5F7"
    readonly property color surface: dark ? "#161618" : "#FFFFFF"
    readonly property color surfaceHi: dark ? "#232326" : "#EBEBEF"
    readonly property color ink: dark ? "#F5F5F7" : "#1D1D1F"
    readonly property color inkDim: dark ? "#98989F" : "#6E6E73"
    readonly property color accent: "#34D399"
    readonly property color accentInk: "#04210F"
    readonly property color danger: "#FF6B6B"

    readonly property string face: Qt.platform.os === "osx" ? ".AppleSystemUIFont" : "Inter"

    readonly property int radius: 18
    readonly property int spring: 420
}
