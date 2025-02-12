// SPDX-FileCopyrightText: 2022-2024 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQml
import QtQuick
import org.kde.plasma.private.mobileshell.sessionlockplugin as SessionLockPlugin

QtObject {
    id: root

    // current password being typed
    property string password: ""

    // whether waiting for authentication after trying password
    property bool waitingForAuth: false

    // the info message given
    property string info: ""

    // whether the lockscreen can be unlocked (no password needed, passwordless login)
    readonly property bool canBeUnlocked: true//authenticator.unlocked

    // whether the device can log in with fingerprint
    readonly property bool isFingerprintSupported: false //authenticator.authenticatorTypes & ScreenLocker.Authenticator.Fingerprint

    // whether we are in keyboard mode (hiding the numpad)
    property bool isKeyboardMode: false

    property string pinLabel: enterPinLabel
    readonly property string enterPinLabel: i18n("Enter PIN")
    readonly property string wrongPinLabel: i18n("Wrong PIN")

    signal reset()
    signal unlockSucceeded()
    signal unlockFailed()

    function tryPassword() {
        if (root.password !== '') {
            root.waitingForAuth = true;
        }
        SessionLockPlugin.SessionLockManager.requestUnlock(root.password);
    }

    function resetPassword() {
        password = "";
        root.reset();
    }

    function resetPinLabel(): void {
        pinLabel = enterPinLabel;
    }

    property var graceLockTimer: Timer {
        interval: 1000
        onTriggered: {
            root.waitingForAuth = false;
            root.password = "";
        }
    }

    property var connections: Connections {
        target: SessionLockPlugin.SessionLockManager

        function onSucceeded() {
            console.log('login succeeded');
            root.waitingForAuth = false;
            root.unlockSucceeded();
        }

        function onFailed(kind: int): void {
            console.log('login failed');
            graceLockTimer.restart();
            root.pinLabel = root.wrongPinLabel;
            root.unlockFailed();
        }

        // TODO
        function onInfoMessageChanged() {
            console.log('info: ' + authenticator.infoMessage);
            root.info += authenticator.infoMessage + " ";
        }

        // TODO
        function onErrorMessageChanged() {
            console.log('error: ' + authenticator.errorMessage);
        }

        // TODO
        function onPromptChanged() {
            console.log('prompt: ' + authenticator.prompt);
        }

        // TODO
        function onPromptForSecretChanged() {
            console.log('prompt secret: ' + authenticator.promptForSecret);
        }
    }
}
