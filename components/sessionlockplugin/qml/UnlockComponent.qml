// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {

	function clearPassword() {
		pwfield.clear();
	}

	Connections {
        target: SessionLock

        function onFailed() {
        	animateWrongPassword.start();
            pwfield.clear();
        }
    }

    Connections {
        target: kbd

        function onAddString(msg) {
            pwfield.insert(pwfield.cursorPosition, msg)
        }

        function onRemove() {
            pwfield.remove(pwfield.cursorPosition-1, pwfield.cursorPosition)
        }
    }

    PropertyAnimation {
    	id: animateWrongPassword;
    	target: pwfield;
    	properties: "bgColor";
    	to: pwfield.bgColor == "#ff0000" ? "transparent" : "red";
    	duration: 600;

    	onFinished: {
    		if(pwfield.bgColor == "#ff0000")
    			animateWrongPassword.start();
    	}
    }

    ColumnLayout{
    	id: content
    	anchors.fill: parent
    	spacing: 5

    	RowLayout {
    		Layout.alignment: Qt.AlignCenter
    		Layout.fillWidth: true
	        Layout.preferredHeight: content.height * 0.14
	        Layout.topMargin: content.spacing
			Layout.bottomMargin: content.spacing

			Button {
				id: kbdSelect
				Layout.alignment: Qt.AlignCenter
				Layout.preferredHeight: content.height * 0.14
				Layout.preferredWidth: content.width * 0.18

	            icon.name: !kbd.isDialPad ? "input-dialpad-symbolic" : "input-keyboard-virtual-symbolic"

	            background: Rectangle {
			        width: kbdSelect.width
			        height: kbdSelect.height
			        color: "transparent"
			    }

	            onClicked: kbd.isDialPad = !kbd.isDialPad;
	        }


	        TextField {
				id: pwfield
			    
			    property color bgColor: "transparent"

			    Layout.alignment: Qt.AlignCenter
				Layout.preferredWidth: content.width * 0.6
				Layout.preferredHeight: content.height * 0.14

			    horizontalAlignment: TextInput.AlignHCenter
				verticalAlignment: TextInput.AlignVCenter
			    
			    passwordMaskDelay: 400

			    placeholderText: "Enter Passsword"

			    font.family: Kirigami.Theme.defaultFont.family
		        font.pointSize: 16
			    echoMode: TextInput.Password

			    cursorVisible: false

			    background: Rectangle {
			        width: pwfield.width
			        height: pwfield.height
			        color: pwfield.bgColor
			        border.color: Kirigami.Theme.highlightColor
			    }
			}

	        KbdButton {
		    	id: btnUnlock
		    	text: '\u27A2'
		    	enabled: pwfield.length > 0
		    	noBorder: true
		    	Layout.alignment: Qt.AlignCenter
				Layout.preferredWidth: content.width * 0.18
				Layout.preferredHeight: content.height * 0.14

				contentItem: Text {
					text: btnUnlock.text
					fontSizeMode: Text.Fit
			        font.pointSize: 32
			        font.bold: true
					color: btnUnlock.enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}

				onClicked: {
					SessionLock.requestUnlock(pwfield.text);
				}
			}
    	}

		Keyboard {
			id: kbd

			Layout.alignment: Qt.AlignCenter
	        Layout.preferredWidth: parent.width
	        Layout.fillWidth: true
	        Layout.fillHeight: true
	    }
    }
}