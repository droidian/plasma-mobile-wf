// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mobileshell as MobileShell
import QtQuick.Shapes

Item {
    id: root

    property date currentDT: new Date()

    width: Screen.width
    height: 26

    visible: true

    Connections {
        target: SolidBattery.primary

        function  onChargeStateChanged() {
            if (SolidBattery.primary.chargeState === 1){
                animateCharging.start()
            }
        }
    }

    RowLayout {
        id: layout
        height: parent.height
        width: parent.width * 0.9
        anchors.centerIn: parent
        spacing: 2
        uniformCellSizes: false

        Text {
            id: timeItem
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            font.bold: true
            font.pixelSize: 20
            fontSizeMode: Text.Fit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            text: root.currentDT.toLocaleTimeString(Locale.ShortFormat)
            color: Kirigami.Theme.textColor
        }

        MobileShell.SignalStrengthIndicator {
            showLabel: false
            internetIndicator: internetIndicatorItem
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        }

        MobileShell.BluetoothIndicator {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        }

        MobileShell.InternetIndicator {
            id: internetIndicatorItem
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        }

        MobileShell.VolumeIndicator {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
        }

        Item {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.preferredWidth: height

            Shape {
                id: rootPath

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                property real radius: root.height / 2 - 4
                property alias strokeWidth: path.strokeWidth
                property real progress: SolidBattery.primary.chargePercent / 100

                width: radius * 2
                height: width

                ShapePath {
                    id: path_b
                    fillColor: "transparent"
                    strokeColor: Kirigami.Theme.disabledTextColor
                    strokeWidth: 1

                    startX: rootPath.radius
                    startY: strokeWidth

                    strokeStyle: ShapePath.DashLine
                    dashPattern: [ 2, 2 ]

                    PathArc {
                        x: radiusX * Math.sin(Math.PI * 2) + rootPath.radius
                        y: -radiusY * Math.cos(Math.PI * 2) + rootPath.radius
                        radiusX: rootPath.radius - rootPath.strokeWidth
                        radiusY: rootPath.radius - rootPath.strokeWidth
                        useLargeArc: x < rootPath.radius
                    }
                }

                ShapePath {
                    id: path
                    fillColor: "transparent"
                    strokeColor: rootPath.progress < .1 ? "red" : rootPath.progress < .3 ? "yellow" : "green"
                    strokeWidth: 1

                    startX: rootPath.radius
                    startY: strokeWidth

                    PathArc {
                        x: radiusX * Math.sin(Math.PI * 2 * rootPath.progress) + rootPath.radius
                        y: -radiusY * Math.cos(Math.PI * 2 * rootPath.progress) + rootPath.radius
                        radiusX: rootPath.radius - rootPath.strokeWidth
                        radiusY: rootPath.radius - rootPath.strokeWidth
                        useLargeArc: x < rootPath.radius
                    }

                    Behavior on strokeColor {
                        ColorAnimation { duration: 1000 }
                    }
                }

                Text {
                    id: batteryCapacity
                    anchors.centerIn: parent
                    font.bold: true
                    font.pixelSize: parent.radius
                    text: SolidBattery.primary.chargePercent;
                    color: Kirigami.Theme.textColor
                }

                NumberAnimation on progress {
                    id: animateCharging
                    loops: 1
                    from: 0.0
                    to: SolidBattery.primary.chargeState === 1 ? 1.0 
                            : SolidBattery.primary.chargePercent / 100;
                    duration: 3000

                    onFinished: {
                        if (SolidBattery.primary.chargeState === 1
                                || rootPath.progress != SolidBattery.primary.chargePercent / 100){
                            animateCharging.start()
                        }
                    }
                }
            }
        }

        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: {
                root.currentDT = new Date();
            }
        }
    }
}
