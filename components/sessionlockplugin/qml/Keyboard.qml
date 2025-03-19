// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property double commonSpacing:  5
    property bool   shift:          false
    property bool   isDialPad:      true

    signal addString(msg: string)
    signal remove()
    
    Loader {
        id: kbdLayout
        source: root.isDialPad ? "KbdLayout_NumPad.qml" : "KbdLayout_EN.qml"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: root.commonSpacing

        //First row
        RowLayout {
            spacing: root.commonSpacing
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Repeater {
                model: shift ? kbdLayout.item.row1_model_shift : kbdLayout.item.row1_model
                delegate: KbdButton {
                    text: shift && capitalization ? displayText.toUpperCase() : displayText
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    checked: displayText == "\u21E7" && root.shift

                    onClicked: {
                        if(text == '\u21E7') {
                         shift = !shift
                         } else if(text == '\u21D0') {
                            root.remove();
                            return;
                        } else {
                            root.addString(text);
                        }
                    }
                }
            }
        }

        PageIndicator {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.preferredHeight: !root.isDialPad ? 2 : 0
            Layout.bottomMargin: root.commonSpacing
            count: symbolSwipe.count
            currentIndex: symbolSwipe.currentIndex
            visible: !root.isDialPad

            delegate: Rectangle {
                implicitWidth: root.width/symbolSwipe.count
                implicitHeight: !root.isDialPad ? 2 : 0
                color: index === symbolSwipe.currentIndex ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                required property int index
            }
        }

        SwipeView {
            id: symbolSwipe
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            interactive: !root.isDialPad

            ColumnLayout {
                spacing: root.commonSpacing
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    spacing: root.commonSpacing
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Repeater {
                        model: kbdLayout.item.row2_model
                        delegate: KbdButton {
                            text: shift && capitalization ? displayText.toUpperCase() : displayText
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            checked: displayText == "\u21E7" && root.shift

                            onClicked: {
                                if(text == '\u21E7') {
                                   shift = !shift
                                } else if(text == '\u21D0') {
                                    root.remove();
                                    return;
                                } else {
                                    root.addString(text);
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: root.commonSpacing
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Repeater {
                        model: kbdLayout.item.row3_model
                        delegate: KbdButton {
                            text: shift && capitalization ? displayText.toUpperCase() : displayText
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumWidth: root.isDialPad ? root.width : (root.width / 10) - root.commonSpacing
                            checked: displayText == "\u21E7" && root.shift

                            onClicked: {
                                if(text == '\u21E7') {
                                   shift = !shift
                                } else if(text == '\u21D0') {
                                    root.remove();
                                    return;
                                } else {
                                    root.addString(text);
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: root.commonSpacing
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Repeater {
                        model: kbdLayout.item.row4_model
                        delegate: KbdButton {
                            text: shift && capitalization ? displayText.toUpperCase() : displayText
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            checked: displayText == "\u21E7" && root.shift

                            onClicked: {
                                if(text == '\u21E7') {
                                   shift = !shift
                                } else if(text == '\u21D0') {
                                    root.remove();
                                    return;
                                } else {
                                    root.addString(text);
                                }
                            }
                        }
                    }
                }
            }
            ColumnLayout {
                spacing: root.commonSpacing
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    spacing: root.commonSpacing
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Repeater {
                        model: kbdLayout.item.row2B_model
                        delegate: KbdButton {
                            text: shift && capitalization ? displayText.toUpperCase() : displayText
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            checked: displayText == "\u21E7" && root.shift

                            onClicked: {
                                if(text == '\u21E7') {
                                   shift = !shift
                                } else if(text == '\u21D0') {
                                    root.remove();
                                    return;
                                } else {
                                    root.addString(text);
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: root.commonSpacing
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Repeater {
                        model: kbdLayout.item.row3B_model
                        delegate: KbdButton {
                            text: shift && capitalization ? displayText.toUpperCase() : displayText
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumWidth: (root.width / 10) - root.commonSpacing
                            checked: displayText == "\u21E7" && root.shift

                            onClicked: {
                                if(text == '\u21E7') {
                                   shift = !shift
                                } else if(text == '\u21D0') {
                                    root.remove();
                                    return;
                                } else {
                                    root.addString(text);
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    spacing: root.commonSpacing
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Repeater {
                        model: kbdLayout.item.row4B_model
                        delegate: KbdButton {
                            text: shift && capitalization ? displayText.toUpperCase() : displayText
                            Layout.alignment: Qt.AlignCenter
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            checked: displayText == "\u21E7" && root.shift

                            onClicked: {
                                if(text == '\u21E7') {
                                   shift = !shift
                                } else if(text == '\u21D0') {
                                    root.remove();
                                    return;
                                } else {
                                    root.addString(text);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}