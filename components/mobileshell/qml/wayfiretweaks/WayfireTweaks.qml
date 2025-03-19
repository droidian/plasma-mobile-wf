// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-FileCopyrightText: 2025 Deepak Kumar <notwho53@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.private.mobileshell.sessionlockplugin as SessionLockPlugin
import org.kde.plasma.private.mobileshell.wlrdpmsplugin as DpmsPlugin
import org.kde.plasma.private.mobileshell.wayfireipcplugin as WayfireIpcPlugin
import org.kde.plasma.private.mobileshell.screenbrightnessplugin as ScreenBrightness
import org.kde.telephony

Item {
    id: root

    property var wasLocked: false
    property var lastBrightness: 150
    property bool callActive: ActiveCallModel.active

    onCallActiveChanged: {
         if(callActive && SessionLockPlugin.SessionLock.locked){
             DpmsPlugin.WlrDpmsManagerV1.pwrOn = true;
             notifArrived.stop();
             dimOut.stop();
             dimIn.start();
         }
    }

    Component.onCompleted: {
        // initialize dpms plugin
        DpmsPlugin.WlrDpmsManagerV1.dpmsInit();

        // lock the screen
        lockSplash.lockText = "Locking..."
        lockSplash.visible = true
        SessionLockPlugin.SessionLock.requestLock();
    }

    Connections {
        target: SessionLockPlugin.SessionLock

        function onLockedChanged(){
            if(!SessionLockPlugin.SessionLock.locked){
                lockSplash.lockText = "Locked"
                lockSplash.visible = false
            }
        }

        function onUnlockRequested(){
            lockSplash.lockText = "Unlocking..."
        }

        function onFailed(){
            lockSplash.lockText = "Locked"
        }
    }

    Connections {
        target: WayfireIpcPlugin.WayfireIPC

        function onPwrKeyStateChanged(state: var) {
            if (!state) {
                if(DpmsPlugin.WlrDpmsManagerV1.pwrOn){
                    lockSplash.lockText = "Locking..."
                    lockSplash.visible = true
                    if(ScreenBrightness.ScreenBrightnessUtil.brightness > 0)
                        lastBrightness = ScreenBrightness.ScreenBrightnessUtil.brightness
                    SessionLockPlugin.SessionLock.requestLock();
                    dimIn.stop();
                    dimOut.start();
                } else {
                    notifArrived.stop();
                    DpmsPlugin.WlrDpmsManagerV1.pwrOn = true;
                    dimOut.stop();
                    dimIn.start();
                }
            }
        }

        function onIdleTimout() {
            if(DpmsPlugin.WlrDpmsManagerV1.pwrOn){
                lockSplash.lockText = "Locking..."
                lockSplash.visible = true
                if(ScreenBrightness.ScreenBrightnessUtil.brightness > 0)
                        lastBrightness = ScreenBrightness.ScreenBrightnessUtil.brightness
                SessionLockPlugin.SessionLock.requestLock();
                dimIn.stop();
                dimOut.start();
            }
        }
    }

    Timer {
        id: notifArrived
        running: false
        interval: 10000
        onTriggered: {
            if(SessionLockPlugin.SessionLock.locked){
                 dimIn.stop();
                 dimOut.start();
            }
        }
    }

    PropertyAnimation { id: dimOut;
        target: ScreenBrightness.ScreenBrightnessUtil;
        property: "brightness";
        to: 0;
        duration: 200

        onFinished: DpmsPlugin.WlrDpmsManagerV1.pwrOn = false;
    }

    PropertyAnimation { id: dimIn;
        target: ScreenBrightness.ScreenBrightnessUtil;
        property: "brightness";
        to: lastBrightness;
        duration: 200
    }

    NotificationManager.Notifications {
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

        onActiveNotificationsCountChanged: {
             if(SessionLockPlugin.SessionLock.locked && !callActive
                    && !DpmsPlugin.WlrDpmsManagerV1.pwrOn){
                 if(activeNotificationsCount > 0){
                     DpmsPlugin.WlrDpmsManagerV1.pwrOn = true;
                     notifArrived.stop();
                     dimOut.stop();
                     dimIn.start();
                     notifArrived.restart();
                     return;
                 }
             }

             if(SessionLockPlugin.SessionLock.locked && !callActive
                    && DpmsPlugin.WlrDpmsManagerV1.pwrOn)
                notifArrived.stop();
        }
    }

    LockScreenSplash {
        id: lockSplash
        visible: false
    }
}
