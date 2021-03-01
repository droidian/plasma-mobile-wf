/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as Controls

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0


LauncherContainer {
    id: root

    readonly property int count: flow.width / cellWidth

    flow.flow: Flow.TopToBottom

    visible: flow.children.length > 0 || launcherDragManager.active || dropArea.containsDrag

    opacity: launcherDragManager.active && plasmoid.nativeInterface.applicationListModel.favoriteCount >= plasmoid.nativeInterface.applicationListModel.maxFavoriteCount ? 0.3 : 1

    height: visible ? cellHeight : 0

    frame.implicitWidth: cellWidth * Math.max(1, flow.children.length) + frame.leftPadding + frame.rightPadding

    Behavior on height {
        NumberAnimation {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on opacity {
        OpacityAnimator {
            duration: units.longDuration * 4
            easing.type: Easing.InOutQuad
        }
    }
}
