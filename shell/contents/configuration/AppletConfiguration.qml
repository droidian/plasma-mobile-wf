// SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
// SPDX-FileCopyrightText: 2022 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import org.kde.kirigami 2.19 as Kirigami
import org.kde.plasma.configuration 2.0
import org.kde.kitemmodels 1.0 as KItemModels

Rectangle {
    id: root
    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    color: "transparent"

//BEGIN properties
    
    property bool isContainment: false
    property alias appComponent: app
    
//END properties

//BEGIN model

    property ConfigModel globalConfigModel: globalAppletConfigModel

    ConfigModel {
        id: globalAppletConfigModel
    }

    KItemModels.KSortFilterProxyModel {
        id: configDialogFilterModel
        sourceModel: configDialog.configModel
        filterRowCallback: (row, parent) => {
            return sourceModel.data(sourceModel.index(row, 0), ConfigModel.VisibleRole);
        }
    }
    
//END model

//BEGIN functions

    function saveConfig() {
        if (app.pageStack.currentItem.saveConfig) {
            app.pageStack.currentItem.saveConfig()
        }
        for (var key in plasmoid.configuration) {
            if (app.pageStack.currentItem["cfg_"+key] !== undefined) {
                plasmoid.configuration[key] = app.pageStack.currentItem["cfg_"+key]
            }
        }
    }

    function configurationHasChanged() {
        for (var key in plasmoid.configuration) {
            if (app.pageStack.currentItem["cfg_"+key] !== undefined) {
                //for objects == doesn't work
                if (typeof plasmoid.configuration[key] == 'object') {
                    for (var i in plasmoid.configuration[key]) {
                        if (plasmoid.configuration[key][i] != app.pageStack.currentItem["cfg_"+key][i]) {
                            return true;
                        }
                    }
                    return false;
                } else if (app.pageStack.currentItem["cfg_"+key] != plasmoid.configuration[key]) {
                    return true;
                }
            }
        }
        return false;
    }


    function settingValueChanged() {
        if (app.pageStack.currentItem.saveConfig !== undefined) {
            app.pageStack.currentItem.saveConfig();
        } else {
            root.saveConfig();
        }
    }
    
    function pushReplace(item, config) {
        let page;
        if (app.pageStack.depth === 0) {
            page = app.pageStack.push(item, config);
        } else {
            page = app.pageStack.replace(item, config);
        }
        app.currentConfigPage = page;
    }
    
    function open(item) {
        app.isAboutPage = false;
        if (item.source) {
            app.isAboutPage = item.source === "AboutPlugin.qml";
            pushReplace(Qt.resolvedUrl("ConfigurationAppletPage.qml"), {configItem: item, title: item.name});
        } else if (item.kcm) {
            pushReplace(configurationKcmPageComponent, {kcm: item.kcm, internalPage: item.kcm.mainUi});
        } else {
            app.pageStack.pop();
        }
    }
    
//END functions


//BEGIN connections

    Connections {
        target: root.Window.window
        function onVisibleChanged() {
            if (root.Window.window.visible) {
                root.Window.window.showMaximized();
            }
        }
    }

    Component.onCompleted: {
        // if we are a containment then the first item will be ConfigurationContainmentAppearance
        // if the applet does not have own configs then the first item will be Shortcuts
        if (isContainment || !configDialog.configModel || configDialog.configModel.count === 0) {
            open(root.globalConfigModel.get(0))
        } else {
            open(configDialog.configModel.get(0))
        }
    }
    
//END connections

//BEGIN UI components

    Component {
        id: configurationKcmPageComponent
        ConfigurationKcmPage {}
    }

    Component {
        id: configCategoryDelegate
        Kirigami.NavigationTabButton {
            icon.name: model.icon
            text: model.name
//             recolorIcon: false
            QQC2.ButtonGroup.group: footerBar.tabGroup
            
            onClicked: {
                if (checked) {
                    root.open(model);
                }
            }
            
            checked: {
                if (app.pageStack.currentItem) {
                    if (model.kcm && app.pageStack.currentItem.kcm) {
                        return model.kcm == app.pageStack.currentItem.kcm;
                    } else if (app.pageStack.currentItem.configItem) {
                        return model.source == app.pageStack.currentItem.configItem.source;
                    } else {
                        return app.pageStack.currentItem.source == Qt.resolvedUrl(model.source);
                    }
                }
                return false;
            }
        }
    }
    
    Kirigami.ApplicationItem {
        id: app
        anchors.fill: parent
        
        pageStack.globalToolBar.canContainHandles: true
        pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.ToolBar
        pageStack.globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.ShowBackButton;
        
        property var currentConfigPage: null
        property bool isAboutPage: false
        
        // pop pages when not in use
        Connections {
            target: app.pageStack
            function onCurrentIndexChanged() {
                // wait for animation to finish before popping pages
                timer.restart();
            }
        }
        
        Timer {
            id: timer
            interval: 300
            onTriggered: {
                let currentIndex = app.pageStack.currentIndex;
                while (app.pageStack.depth > (currentIndex + 1) && currentIndex >= 0) {
                    app.pageStack.pop();
                }
            }
        }

        footer: Kirigami.NavigationTabBar {
            id: footerBar
            visible: count > 1
            height: visible ? implicitHeight : 0
            Repeater {
                model: root.isContainment ? globalConfigModel : undefined
                delegate: configCategoryDelegate
            }
            Repeater {
                model: configDialogFilterModel
                delegate: configCategoryDelegate
            }
            Repeater {
                model: !root.isContainment ? globalConfigModel : undefined
                delegate: configCategoryDelegate
            }
        }
    }
//END UI components
}

