// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import QtQuick.Effects
import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.private.mobileshell as MobileShell
import org.kde.plasma.workspace.components 2.0 as PW
import org.kde.ksysguard.sensors 1.0 as Sensors
import org.kde.plasma.private.mobileshell.wlrdpmsplugin as DpmsPlugin

Item {
    id: root

    property var notificationsModel: NotificationManager.Notifications {
                                        showExpired: true
                                        showDismissed: true
                                        sortMode: NotificationManager.Notifications.SortByTypeAndUrgency
                                        groupMode: NotificationManager.Notifications.GroupApplicationsFlat
                                        groupLimit: 2
                                        expandUnread: true
                                        urgencies: {
                                            var urgencies = NotificationManager.Notifications.CriticalUrgency
                                                        | NotificationManager.Notifications.NormalUrgency;
                                            return urgencies;
                                        }

                                        onCountChanged: {
                                            if(count > 0 || activeNotificationsCount > 0){
                                                dtAnimate.stop();
                                                dtItem.setToPosition();
                                            } else if (!unlockDrawer.opened 
                                                        && DpmsPlugin.WlrDpmsManagerV1.pwrOn) {
                                                dtItem.getNewPosition();
                                            }
                                        }

                                        onActiveNotificationsCountChanged: {
                                            if(count > 0 || activeNotificationsCount > 0){
                                                dtAnimate.stop();
                                                dtItem.setToPosition();
                                            } else if (!unlockDrawer.opened 
                                                        && DpmsPlugin.WlrDpmsManagerV1.pwrOn) {
                                                dtItem.getNewPosition();
                                            }
                                        }
                                    }

    width: Screen.width
    height: Screen.height

    visible: true

    Connections {
        target: DpmsPlugin.WlrDpmsManagerV1

        function onPwrOnChanged() {
            if (!DpmsPlugin.WlrDpmsManagerV1.pwrOn){
                unlockDrawer.close()
                dtAnimate.stop();
                dtItem.setToPosition();
            } else if (!unlockDrawer.opened
                        && notificationsModel.count == 0
                        && notificationsModel.activeNotificationsCount == 0){
                dtItem.getNewPosition();
            }
        }
    }

    Component.onCompleted: {
        SolidBattery.initBattery();
    }

    Rectangle {
        id: fallbackBg
        anchors.fill: parent
        color: "black"
        visible: wallpaper.status != Image.Ready

        Kirigami.Icon {
            anchors.centerIn: parent

            implicitWidth: 160
            implicitHeight: 160
            source: "file:/usr/share/icons/vendor/scalable/emblems/emblem-vendor.svg"
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file:"+SessionLockSettings.wallpaperFile
        fillMode: Image.PreserveAspectCrop
    }

    WallpaperBlur {
        source: wallpaper.status == Image.Ready ? wallpaper : fallbackBg
        anchors.fill: wallpaper.status == Image.Ready ? wallpaper : fallbackBg
        opacity: call.callActive ? 1 : unlockDrawer.position
    }

    TopPanel {
        id: topPanel
        anchors.top: parent.top
    }

    ColumnLayout {
        width: root.width
        height: root.height - swipeIndicator.height - y
        anchors.top: dtItem.bottom
        anchors.topMargin: topPanel.height
        visible: !call.callActive

        MobileShell.MediaControlsWidget {
            id: mediaControl
            Layout.alignment: Qt.AlignCenter
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            Layout.fillWidth: true
            Layout.fillHeight: false
        }

        MobileShell.NotificationsWidget {
            id: notificationsList
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            historyModelType: MobileShell.NotificationsModelType.NotificationsModel
            actionsRequireUnlock: true
            historyModel: root.notificationsModel
            notificationSettings: root.notificationSettings
            inLockscreen: true

            onUnlockRequested: {
                requestNotificationAction = true;
                unlockDrawer.open();
            }
        }
    }

    RowLayout {
        spacing: 5
        width: root.width * 0.4
        height: root.height * 0.04
        anchors.left: root.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.bottomMargin: 10

        visible: unlockDrawer.position == 0 && SessionLockSettings.showChargingInfo

        PW.BatteryIcon {
            id: batteryIcon

            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: false
            height: chargingLbl.height
            width: height * 2

            hasBattery: SolidBattery.primary.present
            percent: SolidBattery.primary.chargePercent
            pluggedIn: SolidBattery.primary.chargeState === 1
        }

        Label {
            id: chargingLbl
            property var chargeAmp: Math.floor((SolidBattery.primary.energyRate / SolidBattery.primary.voltage) * 1000)
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.preferredWidth: parent.width - batteryIcon.width
            text: SolidBattery.primary.chargeState === 1
                     ? "Charging: "+chargeAmp+"mA" : "Discharging: "+chargeAmp+"mA"
            font.bold: true
            font.pixelSize: 14
            fontSizeMode: Text.Fit
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
    }

    Sensors.SensorDataModel {
        id: netTraffic
        sensors: ["network/all/download","network/all/upload"]
    }

    TableView {
        id: traffic
        visible: unlockDrawer.position == 0 && SessionLockSettings.showNetworkTraffic
        width: root.width * 0.4
        height: root.height * 0.04
        anchors.right: root.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        model: netTraffic

        delegate: Item {
            implicitWidth: traffic.width / 2
            implicitHeight: traffic.height
            Label {
                anchors.fill: parent
                property var indicator: model.index ? '\u21E7' : '\u21E9'
                property var speedValue: FormattedValue != "" ? FormattedValue : "0B/s"
                text: model.index ? indicator+" "+speedValue : speedValue+" "+indicator
                font.bold: true
                font.pixelSize: 14
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: model.index ? Text.AlignLeft : Text.AlignRight
            }
        }
    }

    Kirigami.Icon {
        id: swipeIndicator
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20

        visible: call.callActive ? false : unlockDrawer.position == 0

        implicitWidth: Kirigami.Units.iconSizes.small
        implicitHeight: Kirigami.Units.iconSizes.small
        source: "arrow-up"
    }

    Item {
        id: dtItem

        property var newX
        property var newY

        property var oldX
        property var oldY

        property var animDuration: 5000

        property var speed: 24 //Higher value will slow down

        width: root.width * 0.8
        height: root.height * 0.2

        x: (Screen.width - dtItem.width) / 2
        y: topPanel.height * 2

        visible: !call.callActive

        function getNewPosition(){
            if(!SessionLockSettings.movingClock || mediaControl.visible)
                return;
            dtItem.oldX = dtItem.x
            dtItem.oldY = dtItem.y
            dtItem.newX = Math.random() * (Screen.width - dtItem.width)
            dtItem.newY = Math.random() * (Screen.height - dtItem.height)

            if(dtItem.newY < topPanel.height)
                dtItem.newY = topPanel.height

            dtItem.animDuration = Math.max(Math.abs(dtItem.oldX - dtItem.newX), 
                Math.abs(dtItem.y - dtItem.newY)) * dtItem.speed

            if (dtItem.animDuration == 0)
                dtItem.animDuration = 5000

            dtAnimate.start()
        }

        function setToPosition(){
            if(!SessionLockSettings.movingClock || mediaControl.visible)
                return;
            dtItem.oldX = dtItem.x
            dtItem.oldY = dtItem.y
            dtItem.newX = (Screen.width - dtItem.width) / 2
            dtItem.newY = topPanel.height * 2

            if(dtItem.newY < topPanel.height)
                dtItem.newY = topPanel.height

            dtItem.animDuration = 500

            if (dtItem.animDuration == 0)
                dtItem.animDuration = 5000

            dtAnimate.start()
        }

        Label {
            id: dateLbl
            width: parent.width
            height: parent.height * 0.6
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(topPanel.currentDT, "dddd, MMMM d")
            fontSizeMode: Text.Fit
            font.pointSize: 28
            font.bold: true
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: timeLbl
            width: parent.width
            height: parent.height * 0.38
            anchors.top: dateLbl.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: topPanel.currentDT.toLocaleTimeString(Locale.ShortFormat)
            fontSizeMode: Text.Fit;
            font.pointSize: 36
            font.bold: true
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
        }

        ParallelAnimation {
            id: dtAnimate
            running: false
            NumberAnimation { target: dtItem; property: "x"; to: dtItem.newX; duration: dtItem.animDuration }
            NumberAnimation { target: dtItem; property: "y"; to: dtItem.newY; duration: dtItem.animDuration }

            onFinished: {
                if (!unlockDrawer.opened 
                    && DpmsPlugin.WlrDpmsManagerV1.pwrOn
                    && notificationsModel.count == 0)
                    dtItem.getNewPosition();
            }
        }

        Component.onCompleted: {
            dtItem.getNewPosition();
        }
    }

    MobileShell.ActionDrawerOpenSurface {
        id: swipeArea
        actionDrawer: qsDrawer
        anchors.fill: topPanel
    }

    MobileShell.ActionDrawer {
        id: qsDrawer
        anchors.fill: parent

        visible: true
        restrictedPermissions: true

        notificationSettings: NotificationManager.Settings {}
        notificationModel: root.notificationsModel
        notificationModelType: MobileShell.NotificationsModelType.NotificationsModel
    }

    PhoneCall {
        id: call
        anchors.fill: parent

        onCallActiveChanged: {
            if(call.callActive){
                qsDrawer.close()
                unlockDrawer.close()
            }
        }
    }

    Drawer {
        id: unlockDrawer
        edge: Qt.BottomEdge
        dragMargin: 30
        opacity: position

        background: Rectangle {
            implicitWidth: root.width
            implicitHeight: root.height > root.width ? Math.min(root.width, root.height) * 0.7
                : Math.min(root.width, root.height) * 0.5
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.6)
        }

        UnlockComponent {
            id: unlocker
            anchors.fill: parent
        }

        onClosed: unlocker.clearPassword()

        onOpenedChanged: {
            if(unlockDrawer.opened){
                qsDrawer.close();
                dtAnimate.stop();
                dtItem.setToPosition();
            } else if (DpmsPlugin.WlrDpmsManagerV1.pwrOn
                        && notificationsModel.count == 0){
                dtItem.getNewPosition();
            }
        }
    }
}
