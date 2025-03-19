import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell
import org.kde.kirigami as Kirigami
import QtQuick.Controls

Window {
    id: lsWindow

    property var lockText: "Locking..."

    width: Screen.width
    height: Screen.height

    LayerShell.Window.scope: "LockScreen Splash"
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone

    color: "black"

    Kirigami.Icon {
        id: lockIcon
        anchors.centerIn: parent

        implicitWidth: 160
        implicitHeight: 160
        source: "file:/usr/share/icons/vendor/scalable/emblems/emblem-vendor.svg"
    }

    Label {
        anchors.top: lockIcon.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        font.pixelSize: 24
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        text: lsWindow.lockText
    }
}