// SPDX-FileCopyrightText: 2014 Aaron Seigo <aseigo@kde.org>
// SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

// This file is based on CallPage.qml from plasma-dialer

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as Components
import org.kde.telephony

Item {
	id: root

	anchors.fill: parent

	property bool callIncoming: ActiveCallModel.incoming
    property bool callActive: ActiveCallModel.active
    property int callDuration: ActiveCallModel.duration
    property string callCommunicationWith: ActiveCallModel.communicationWith

	visible: callActive

	function secondsToTimeString(seconds) {
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds - (h * 3600)) / 60);
        var s = seconds - h * 3600 - m * 60;
        if (m < 10)
            m = '0' + m;

        if (s < 10)
            s = '0' + s;

        if (h === 0)
            return '' + m + ':' + s;

        return '' + h + ':' + m + ':' + s;
    }

    function selectModem() {
        const deviceUniList = DeviceUtils.deviceUniList;
        if (deviceUniList.length === 0) {
            console.warn("Modem devices not found");
            return "";
        }
        if (deviceUniList.length === 1)
            return deviceUniList[0];

        console.log("TODO: select device uni");
    }

    ColumnLayout{
	    spacing: 2
	    anchors.fill: parent

	    Components.Avatar {
	    	Layout.topMargin: root.height * 0.1
	    	Layout.fillWidth: true
			Layout.preferredWidth: root.width * 0.3
			Layout.preferredHeight: root.width * 0.3
			name: ContactUtils.displayString(callCommunicationWith)
			imageMode: Components.Avatar.ImageMode.AlwaysShowInitials
		}

		// time spent on call
        Label {
        	Layout.topMargin: 30
            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 2
            text: ContactUtils.displayString(callCommunicationWith)
        }

	    // time spent on call
        Label {
        	Layout.topMargin: 15
            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.4
            text: {
                if (callDuration > 0)
                    return secondsToTimeString(callDuration);

                if (callIncoming)
                    return i18n("Incoming...");

                return '';
            }
            visible: text !== ""
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

	    RowLayout {
	    	Layout.fillWidth: true
	    	Layout.minimumHeight: root.height * 0.08
	    	Layout.bottomMargin: 80

	    	Item {
	    		Layout.fillWidth: true
	    		Layout.minimumHeight: parent.height

	    		Button {
		    		anchors.centerIn: parent
		    		height: parent.height
		    		width: height
		    		icon.name: "call-end-symbolic"
		    		icon.height: width
		    		icon.width: width
		    		icon.color: "red"
		    		opacity: pressed ? 0.5 : 1

		    		background: Rectangle {
		    			radius: height
		    			anchors.fill: parent
		    			color: "transparent"
		    			border.color: "red"
						border.width: 2
		    		}

		    		onClicked: CallUtils.hangUp(root.selectModem(), ActiveCallModel.activeCallUni());
		    	}
	    	}

	    	Item {
	    		Layout.fillWidth: true
	    		Layout.minimumHeight: parent.height
            	visible: ActiveCallModel.incoming && root.callDuration < 1

	    		Button {
		    		anchors.centerIn: parent
		    		height: parent.height
		    		width: height
		    		icon.name: "call-start-symbolic"
		    		icon.height: width
		    		icon.width: width
		    		icon.color: "green"
		    		opacity: pressed ? 0.5 : 1

		    		background: Rectangle {
		    			radius: height
		    			anchors.fill: parent
		    			color: "transparent"
		    			border.color: "green"
						border.width: 2
		    		}

		    		onClicked: CallUtils.accept(root.selectModem(), ActiveCallModel.activeCallUni());
		    	}
	    	}
	    }
	}
}