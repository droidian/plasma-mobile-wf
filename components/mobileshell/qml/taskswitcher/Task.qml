/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <notmart@gmail.com>
 *   SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.2 as QQC2

import org.kde.taskmanager 0.1 as TaskManager
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: delegate

    required property var taskSwitcher
    
    required property var model
    required property var displaysModel

    readonly property point taskScreenPoint: Qt.point(model.ScreenGeometry.x, model.ScreenGeometry.y)
    readonly property real dragOffset: -control.y
    
    property bool active: model.IsActive
    
    required property real previewHeight
    required property real previewWidth
    property real scale: 1
    
    opacity: 1 - dragOffset / taskSwitcher.height
    
//BEGIN functions
    function syncDelegateGeometry() {
        let pos = pipeWireLoader.mapToItem(tasksView, 0, 0);
        if (taskSwitcher.visible) {
            tasksModel.requestPublishDelegateGeometry(tasksModel.index(model.index, 0), Qt.rect(pos.x, pos.y, pipeWireLoader.width, pipeWireLoader.height), pipeWireLoader);
        }
    }
    
    function closeApp() {
        tasksModel.requestClose(tasksModel.index(model.index, 0));
    }
    
    function activateApp() {
        taskSwitcher.activateWindow(model.index);
    }
//END functions
    
    Component.onCompleted: syncDelegateGeometry();
    
    Connections {
        target: taskSwitcher
        function onVisibleChanged() {
            syncDelegateGeometry();
        }
    }

    QQC2.Control {
        id: control
        width: parent.width
        height: parent.height
        
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        
        // drag up gesture
        DragHandler {
            id: dragHandler
            target: parent
            yAxis.enabled: true
            xAxis.enabled: false
            yAxis.maximum: 0
            onActiveChanged: {
                yAnimator.stop();
                
                if (parent.y < -PlasmaCore.Units.gridUnit * 2) {
                    yAnimator.to = -root.height;
                } else {
                    yAnimator.to = 0;
                }
                yAnimator.start();
            }
        }
        
        NumberAnimation on y {
            id: yAnimator
            running: !dragHandler.active
            duration: PlasmaCore.Units.longDuration
            easing.type: Easing.InOutQuad
            to: 0
            onFinished: {
                if (to != 0) { // close app
                    delegate.closeApp();
                }
            }
        }

        // application
        contentItem: ColumnLayout {
            id: column
            spacing: 0
            
            // header
            RowLayout {
                id: appHeader
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: column.height - appView.height
                spacing: PlasmaCore.Units.smallSpacing * 2
                
                PlasmaCore.IconItem {
                    Layout.preferredHeight: PlasmaCore.Units.iconSizes.smallMedium
                    Layout.preferredWidth: PlasmaCore.Units.iconSizes.smallMedium
                    Layout.alignment: Qt.AlignVCenter
                    usesPlasmaTheme: false
                    source: model.decoration
                }
                
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                    text: model.AppName
                    color: "white"
                }
                
                Repeater {
                    id: rep
                    model: displaysModel
                    delegate: PlasmaComponents.ToolButton {
                        Layout.alignment: Qt.AlignVCenter
                        text: model.modelName
                        visible: model.position !== delegate.taskScreenPoint
                        display: rep.count < 3 ? QQC2.Button.IconOnly : QQC2.Button.TextBesideIcon
                        icon.name: "tv" //TODO provide a more adequate icon

                        onClicked: {
                            displaysModel.sendWindowToOutput(delegate.model.WinIdList[0], model.output)
                        }
                    }
                }
                
                PlasmaComponents.ToolButton {
                    Layout.alignment: Qt.AlignVCenter
                    z: 99
                    icon.name: "window-close"
                    icon.width: PlasmaCore.Units.iconSizes.smallMedium
                    icon.height: PlasmaCore.Units.iconSizes.smallMedium
                    onClicked: delegate.closeApp()
                }
            }
            
            // app preview
            QQC2.Control {
                id: appView
                Layout.preferredWidth: delegate.previewWidth
                Layout.preferredHeight: delegate.previewHeight
                Layout.maximumWidth: delegate.previewWidth
                Layout.maximumHeight: delegate.previewHeight
                
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                
                transform: Scale {
                    origin.x: item.width / 2
                    origin.y: item.height / 2
                    xScale: delegate.scale
                    yScale: delegate.scale
                }
                
                background: Rectangle {
                    color: PlasmaCore.Theme.backgroundColor
                }
                
                contentItem: Item {
                    id: item
                    
                    Loader {
                        id: pipeWireLoader
                        anchors.fill: parent
                        source: Qt.resolvedUrl("./Thumbnail.qml")
                        onStatusChanged: {
                            if (status === Loader.Error) {
                                source = Qt.resolvedUrl("./TaskIcon.qml");
                            }
                        }
                    }
                    TapHandler {
                        onTapped: delegate.activateApp()
                    }
                }
            }
        }
    }
}

