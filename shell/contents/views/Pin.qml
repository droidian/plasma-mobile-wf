/*
 *   SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
 *   SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0 as PlasmaCore
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import MeeGo.QOfono 0.2
import "../components"

PlasmaCore.ColorScope {
    id: root

    anchors.fill: parent
    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    visible: simManager.pinRequired != OfonoSimManager.NoPin
    property OfonoSimManager simManager: ofonoSimManager

    property string pin: ""
    property var lastKey: ""

    property var puk: ""
    property var newPin: ""

    property bool pinsNotEqual: false

    Connections {
        target: simManager
        function onEnterPinComplete(error, errorString) {
            if(error === 0) root.visible = false
        }
    }

    OfonoManager {
        id: ofonoManager
    }

    OfonoSimManager {
        id: ofonoSimManager
        modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
    }

    Rectangle {
        id: pinScreen
        anchors.fill: parent

        MouseArea { //Catch input
            anchors.fill: parent
        }

        color: Qt.rgba(250, 250, 250, 0.85)

        function backspace() {
            root.lastKey = ""
            root.pin = root.pin.substr(0, root.pin.length - 1)
        }

        function clear() {
            root.lastKey = ""
            root.pin = ""
        }

        function enter() {
            lastKey = ""
            pinsNotEqual = false
            if(simManager.pinRequired === 9) {
                if(puk === "") {
                    root.puk = root.pin
                    root.pin = ""
                    return
                } else if(root.newPin !== "") {
                    if(root.newPin === root.pin) {
                        simManager.resetPin(simManager.pinRequired, root.puk, root.pin)
                        clear()
                        root.puk = ""
                        root.newPin = ""
                    } else {
                        root.newPin = ""
                        pinsNotEqual = true
                    }
                } else {
                    root.newPin = root.pin
                    root.pin = ""
                    return
                }
            }
            simManager.enterPin(simManager.pinRequired, root.pin);
            clear()
        }

        function keyPress(data) {
            root.lastKey = data;
            root.pin += data

            letterTimer.restart();
        }

        Keys.onPressed: {
            if (event.modifiers === Qt.NoModifier) {
                if (event.key === Qt.Key_Backspace) {
                    pinScreen.backspace();
                } else if (event.key === Qt.Key_Return) {
                    pinScreen.enter();
                } else if("0123456789".includes(event.text)) {
                    pinScreen.keyPress(event.text);
                }
            }
        }

        // trigger turning letter into dot after 500 milliseconds
        Timer {
            id: letterTimer
            interval: 500
            running: false
            repeat: false
            onTriggered: {
                root.lastKey = "";
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 2*units.gridUnit
            anchors.bottomMargin: units.gridUnit
            spacing: units.gridUnit

            // pin dot display
            Item {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true

                // label ("wrong pin", "enter pin")
                Label {
                    id: simLabel
                    visible: root.pin.length === 0
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 18
                    color: "#616161"
                    text: {
                        switch (simManager.pinRequired) {
                            case OfonoSimManager.NoPin: return i18n("No pin (error)");
                            case OfonoSimManager.SimPin: return i18n("Enter Sim PIN");
                            case OfonoSimManager.SimPin2: return i18n("Enter Sim PIN 2");
                            case OfonoSimManager.SimPuk: {
                                if(root.puk === "") return i18n("Enter Sim PUK");
                                else if(pinsNotEqual) return i18n("Pins don't match. Try again");
                                else if(root.newPin === "") return i18n("Choose new Pin");
                                else return i18n("Confirm new Pin");
                            }
                            case OfonoSimManager.SimPuk2: return i18n("Enter Sim PUK 2");
                            default: return i18n("Unknown PIN type: %1", simManager.pinRequired);
                        }
                    }
                }
                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: simLabel.bottom
                    anchors.topMargin: units.gridUnit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 12
                    color: "#616161"
                    visible: (simManager.pinRequired !== OfonoSimManager.SimPuk) || root.puk === ""
                    text: simManager.pinRetries && simManager.pinRetries[simManager.pinRequired] ? i18np("%1 attempt left", "%1 attempts left", simManager.pinRetries[simManager.pinRequired]) : ""
                }

                // dot display and letter
                RowLayout {
                    id: dotDisplay
                    anchors.centerIn: parent
                    height: units.gridUnit * 2.5 // maintain height when letter is shown
                    spacing: 6

                    Repeater {
                        model: root.pin.length
                        delegate: Rectangle { // dot
                            visible: index !== root.pin.length-1 || root.lastKey === "" // hide dot if number is shown
                            Layout.preferredWidth: units.gridUnit * 0.5
                            Layout.preferredHeight: Layout.preferredWidth
                            Layout.alignment: Qt.AlignVCenter
                            radius: width
                            color: "#424242"
                        }
                    }
                    Label { // number/letter
                        visible: root.lastKey !== "" // hide label if no label needed
                        Layout.alignment: Qt.AlignHCenter
                        color: "#424242"
                        text: root.lastKey
                        font.pointSize: 20
                    }
                }
            }

            // separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#eeeeee"
            }

            // number keys
            GridLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.leftMargin: units.gridUnit * 0.5
                Layout.rightMargin: units.gridUnit * 0.5
                Layout.maximumWidth: units.gridUnit * 22
                Layout.maximumHeight: (root.height > root.width) ? units.gridUnit * 17.5 : units.gridUnit * 12.5
                columns: 3

                Repeater {
                    model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "R", "0", "E"]

                    delegate: Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            id: keyRect
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            radius: 5
                            color: "white"
                            visible: modelData.length > 0

                            AbstractButton {
                                anchors.fill: parent
                                onPressed: parent.color = "#e0e0e0"
                                onReleased: parent.color = "white"
                                onClicked: {
                                    if (modelData === "R") {
                                        pinScreen.backspace();
                                    } else if (modelData === "E") {
                                        pinScreen.enter();
                                    } else {
                                        pinScreen.keyPress(modelData);
                                    }
                                }
                                onPressAndHold: {
                                    if (modelData === "R") {
                                        clear();
                                    }
                                }
                            }
                        }

                        DropShadow {
                            anchors.fill: keyRect
                            source: keyRect
                            cached: true
                            horizontalOffset: 0
                            verticalOffset: 1
                            radius: 4
                            samples: 6
                            color: "#e0e0e0"
                        }

                        PlasmaComponents.Label {
                            visible: modelData !== "R" && modelData !== "E"
                            text: modelData
                            anchors.centerIn: parent
                            font.pointSize: 18
                            color: "#424242"
                        }

                        PlasmaCore.IconItem {
                            visible: modelData === "R"
                            anchors.centerIn: parent
                            source: "edit-clear"
                        }

                        PlasmaCore.IconItem {
                            visible: modelData === "E"
                            anchors.centerIn: parent
                            source: "go-next"
                        }
                    }
                }
            }
            Item {
                height: units.gridUnit * 0.5
            }
        }
    }
}
