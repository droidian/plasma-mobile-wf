// SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
// SPDX-FileCopyrightText: 2021-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.plasma.core as PlasmaCore
import org.kde.notificationmanager as Notifications
import org.kde.plasma.components 3.0 as PC3

import org.kde.kirigami 2.12 as Kirigami
import org.kde.plasma.private.mobileshell.wallpaperimageplugin as WallpaperImagePlugin
import org.kde.plasma.private.mobileshell.sessionlockplugin as SessionLockPlugin

/**
 * Lockscreen component that is loaded after the device is locked.
 *
 * Special attention must be paid to ensuring the GUI loads as fast as possible.
 */
Window {
    id: root

    color: "transparent"

    readonly property var lockScreenState: LockScreenState {}
    property var notifModel

    // Only show widescreen mode for short height devices (ex. phone landscape)
    readonly property bool isWidescreen: root.height < 720 && (root.height < root.width * 0.75)
    property bool notificationsShown: false

    property var passwordBar: flickableLoader.item ? flickableLoader.item.passwordBar : null

    Rectangle {
        id: bgRect
        color: "black"
        anchors.fill: parent

        Behavior on opacity { PropertyAnimation {duration: 300} }

        Kirigami.Icon {
            anchors.centerIn: bgRect
            width: Kirigami.Units.iconSizes.huge
            height: width
            source: "channel-secure-symbolic"
            color: Kirigami.Theme.textColor
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        opacity: bgRect.opacity
        fillMode: Image.PreserveAspectCrop
        source: "file:/" + WallpaperImagePlugin.WallpaperPlugin.lockscreenWallpaperPath
    }

    // Listen for keyboard events, and focus on input area
    Item {
        focus: true
        Keys.onPressed: (event)=> {
            console.log("KEY PRESSED", event.text, event.key)
        }
    }

    // Wallpaper blur
    Loader {
        id: wallpaperLoader
        anchors.fill: parent
        active: false
        asynchronous: true

        // This take a while to load, don't pause initial lockscreen loading for it
        Timer {
            running: true
            repeat: false
            onTriggered: wallpaperLoader.active = true
        }

        sourceComponent: WallpaperBlur {
            source: wallpaper.status == Image.Ready ? wallpaper : bgRect
            opacity: flickableLoader.item ? flickableLoader.item.openFactor : 0
        }
    }

    Connections {
        target: root.lockScreenState

        // Ensure keypad is opened when password is updated (ex. keyboard)
        function onPasswordChanged() {
            if (root.lockScreenState.password !== "" && flickableLoader.item) {
                flickableLoader.item.goToOpenPosition();
            }
        }
    }

    Connections {
        target: SessionLockPlugin.SessionLockManager

        function onSucceeded() {
            bgRect.opacity = 0
        }
    }

    Item {
        id: lockscreenContainer
        anchors.fill: parent
        opacity: bgRect.opacity

        // Header bar and action drawer
        HeaderComponent {
            id: headerBar
            z: 1
            anchors.fill: parent
            statusBarHeight: Kirigami.Units.gridUnit * 1.25
            openFactor: flickableLoader.item ? flickableLoader.item.openFactor : 0
            notificationsModel: root.notifModel
            onPasswordRequested: root.askPassword()
        }

        // Add loading indicator when status bar has not loaded yet
        PC3.BusyIndicator {
            id: flickableLoadingBusyIndicator
            anchors.centerIn: parent
            visible: flickableLoader.status != Loader.Ready

            implicitHeight: Kirigami.Units.iconSizes.huge
            implicitWidth: Kirigami.Units.iconSizes.huge

            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        }

        // Load flickable async
        Loader {
            id: flickableLoader

            active: false
            asynchronous: true
            opacity: status == Loader.Ready ? 1 : 0
            visible: opacity > 0
            anchors.fill: parent

            Behavior on opacity {
                NumberAnimation {}
            }

            // This take a while to load, don't pause initial lockscreen and wallpaper loading for it
            Timer {
                id: loadTimer
                running: true
                repeat: false
                onTriggered: {
                    flickableLoader.active = true
                }
            }

            // Container for lockscreen contents
            sourceComponent: FlickContainer {
                id: flickable
                property alias passwordBar: keypad.passwordBar

                // Speed up animation when passwordless
                animationDuration: root.lockScreenState.canBeUnlocked ? 400 : 800

                // Distance to swipe to fully open keypad
                keypadHeight: Kirigami.Units.gridUnit * 20

                Component.onCompleted: {
                    // Go to closed position when loaded
                    flickable.position = 0;
                    flickable.goToClosePosition();
                }

                // Unlock lockscreen if it's already unlocked and keypad is opened
                onOpened: {
                    if (root.lockScreenState.canBeUnlocked) {
                        //Qt.quit();
                    }
                }

                // Unlock lockscreen if it's already unlocked and keypad is open
                Connections {
                    target: root.lockScreenState
                    function onCanBeUnlockedChanged() {
                        if (root.lockScreenState.canBeUnlocked && flickable.openFactor > 0.8) {
                        }
                    }
                }

                // Clear entered password after closing keypad
                onOpenFactorChanged: {
                    if (flickable.openFactor < 0.1 && !flickable.movingUp) {
                        root.passwordBar.clear();
                    }
                }

                LockScreenContent {
                    id: lockScreenContent

                    isVertical: !root.isWidescreen
                    opacity: Math.max(0, 1 - flickable.openFactor * 2)
                    transform: [
                        Scale {
                            origin.x: lockScreenContent.width / 2
                            origin.y: lockScreenContent.height / 2
                            yScale: 1 - (flickable.openFactor * 2) * 0.1
                            xScale: 1 - (flickable.openFactor * 2) * 0.1
                        }
                    ]

                    fullHeight: root.height

                    lockScreenState: root.lockScreenState
                    notificationsModel: root.notifModel
                    onNotificationsShownChanged: root.notificationsShown = notificationsShown
                    onPasswordRequested: flickable.goToOpenPosition()

                    anchors.topMargin: headerBar.statusBarHeight
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                // scroll up icon
                BottomIconIndicator {
                    id: scrollUpIconLoader
                    lockScreenState: root.lockScreenState
                    opacity: Math.max(0, 1 - flickable.openFactor * 2)

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Kirigami.Units.gridUnit + flickable.position * 0.1
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    id: keypadScrim
                    anchors.fill: parent
                    visible: opacity > 0
                    opacity: flickable.openFactor
                    color: Qt.rgba(0, 0, 0, 0.5)
                }

                Keypad {
                    id: keypad
                    visible: true//!root.lockScreenState.canBeUnlocked // don't show for passwordless login
                    anchors.fill: parent
                    openProgress: flickable.openFactor
                    lockScreenState: root.lockScreenState

                    // only show in last 50% of anim
                    opacity: (flickable.openFactor - 0.5) * 2
                    transform: Translate { y: (flickable.keypadHeight - flickable.position) * 0.1 }
                }
            }
        }
    }
}
