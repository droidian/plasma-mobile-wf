/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.bluezqt 1.0 as BluezQt
import org.kde.colorcorrect 0.1 as CC

Item {
    id: root

    implicitWidth: flow.implicitWidth + units.smallSpacing * 6
    implicitHeight: flow.implicitHeight + units.smallSpacing * 6

    signal closeRequested
    signal closed

    property bool screenshotRequested: false

    PlasmaNM.Handler {
        id: nmHandler
    }

    PlasmaNM.EnabledConnections {
        id: enabledConnections
    }

    Connections {
        target: BluezQt.Manager

        function onBluetoothOperationalChanged() {
            settingsModel.get(2).enabled = BluezQt.Manager.bluetoothOperational
        }
    }

    function toggleAirplane() {
        print("toggle airplane mode")
    }

    function toggleTorch() {
        plasmoid.nativeInterface.toggleTorch()
        settingsModel.get(6).enabled = plasmoid.nativeInterface.torchEnabled
    }

    function toggleWifi() {
        nmHandler.enableWireless(!enabledConnections.wirelessEnabled)
        settingsModel.get(1).enabled = !enabledConnections.wirelessEnabled
    }

    function toggleWwan() {
        nmHandler.enableWwan(!enabledConnections.wwanEnabled)
        settingsModel.get(3).enabled = !enabledConnections.wwanEnabled
    }

    function toggleRotation() {
        const enable = !plasmoid.nativeInterface.autoRotateEnabled
        plasmoid.nativeInterface.autoRotateEnabled = enable
        settingsModel.get(9).enabled = enable
    }

    function toggleBluetooth() {
        var enable = !BluezQt.Manager.bluetoothOperational;
        BluezQt.Manager.bluetoothBlocked = !enable;

        for (var i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            var adapter = BluezQt.Manager.adapters[i];
            adapter.powered = enable;
        }
    }
    
    function toggleNightColor() {
        if (compositorAdaptor.active) {
            compositorAdaptor.activeStaged = false;
        } else {
            compositorAdaptor.activeStaged = true;
            compositorAdaptor.modeStaged = 3; // always on
        }
        compositorAdaptor.sendConfigurationAll();
        settingsModel.get(10).enabled = compositorAdaptor.active;
    }

    function requestShutdown() {
        print("Shutdown requested, depends on ksmserver running");
        var service = pmSource.serviceForSource("PowerDevil");
        //note the strange camelCasing is intentional
        var operation = service.operationDescription("requestShutDown");
        return service.startOperationCall(operation);
    }

    signal plasmoidTriggered(var applet, var id)
    Layout.minimumHeight: flow.implicitHeight + units.largeSpacing*2

    property int screenBrightness
    property bool disableBrightnessUpdate: true
    readonly property int maximumScreenBrightness: pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 0

    onScreenBrightnessChanged: {
        if(!disableBrightnessUpdate) {
            var service = pmSource.serviceForSource("PowerDevil");
            var operation = service.operationDescription("setBrightness");
            operation.brightness = screenBrightness;
            operation.silent = true
            service.startOperationCall(operation);
        }
    }

    function requestScreenshot() {
        screenshotRequested = true;
        root.closeRequested();
    }

    onClosed: {
        if (screenshotRequested) {
            plasmoid.nativeInterface.takeScreenshot();
            screenshotRequested = false;
        }
    }

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: {
            if (source === "PowerDevil") {
                disconnectSource(source);
                connectSource(source);
            }
        }
        onDataChanged: {
            disableBrightnessUpdate = true;
            root.screenBrightness = pmSource.data["PowerDevil"]["Screen Brightness"];
            disableBrightnessUpdate = false;
        }
    }
    
    // night color
    CC.CompositorAdaptor {
        id: compositorAdaptor
    }
    
    //HACK: make the list know about the applet delegate which is a qtobject
    QtObject {
        id: nullApplet
    }
    Component.onCompleted: {
        //NOTE: add all in javascript as the static decl of listelements can't have scripts
        settingsModel.append({
            "text": i18n("Settings"),
            "icon": "configure",
            "enabled": false,
            "settingsCommand": "plasma-settings",
            "toggleFunction": "",
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Wifi"),
            "icon": "network-wireless-signal",
            "settingsCommand": "plasma-settings -m kcm_mobile_wifi",
            "toggleFunction": "toggleWifi",
            "enabled": enabledConnections.wirelessEnabled,
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Bluetooth"),
            "icon": "network-bluetooth",
            "settingsCommand": "plasma-settings -m kcm_bluetooth",
            "toggleFunction": "toggleBluetooth",
            "delegate": "",
            "enabled": BluezQt.Manager.bluetoothOperational,
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Mobile Data"),
            "icon": "network-modem",
            "settingsCommand": "plasma-settings -m kcm_mobile_broadband",
            "toggleFunction": "toggleWwan",
            "enabled": enabledConnections.wwanEnabled,
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Battery"),
            "icon": "battery-full",
            "enabled": false,
            "settingsCommand": "plasma-settings -m kcm_mobile_power",
            "toggleFunction": "",
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Sound"),
            "icon": "audio-speakers-symbolic",
            "enabled": false,
            "settingsCommand": "plasma-settings -m kcm_pulseaudio",
            "toggleFunction": "",
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Flashlight"),
            "icon": "flashlight-on",
            "enabled": plasmoid.nativeInterface.torchEnabled,
            "settingsCommand": "",
            "toggleFunction": "toggleTorch",
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Location"),
            "icon": "gps",
            "enabled": false,
            "settingsCommand": "",
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Screenshot"),
            "icon": "spectacle",
            "enabled": false,
            "settingsCommand": "",
            "toggleFunction": "requestScreenshot",
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Auto-rotate"),
            "icon": "rotation-allowed",
            "enabled": plasmoid.nativeInterface.autoRotateEnabled,
            "settingsCommand": "",
            "toggleFunction": "toggleRotation",
            "applet": null
        });
        settingsModel.append({
            "text": i18n("Night Color"),
            "icon": "redshift-status-on",
            "enabled": compositorAdaptor.active,
            "settingsCommand": "", // change once night color kcm is added
            "toggleFunction": "toggleNightColor",
            "applet": null
        });

        brightnessSlider.moved.connect(function() {
            root.screenBrightness = brightnessSlider.value;
        });
        disableBrightnessUpdate = false;
    }

    ListModel {
        id: settingsModel
    }

    Flow {
        id: flow
        anchors {
            fill: parent
            margins: units.smallSpacing
        }
        readonly property real cellSizeHint: units.iconSizes.large + units.smallSpacing * 6
        readonly property real columnWidth: Math.floor(width / Math.floor(width / cellSizeHint))
        spacing: 0
        Repeater {
            model: settingsModel
            delegate: Delegate {
                id: delegateItem

                //FIXME: why this is needed?
                width: flow.columnWidth

                Connections {
                    target: delegateItem
                    onCloseRequested: root.closeRequested();
                }
                Connections {
                    target: root
                    onClosed: delegateItem.panelClosed();
                }
            }
        }

        BrightnessItem {
            id: brightnessSlider
            width: flow.width
            icon: "video-display-brightness"
            label: i18n("Display Brightness")
            value: root.screenBrightness
            maximumValue: root.maximumScreenBrightness
            Connections {
                target: root
                onScreenBrightnessChanged: brightnessSlider.value = root.screenBrightness
            }
        }
    }
}
