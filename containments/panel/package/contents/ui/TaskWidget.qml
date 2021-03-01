/*
 *   SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: taskIcon
    width: parent.height
    height: width
    //hide application status icons
    opacity: (Category != "ApplicationStatus" && Status != "Passive") ? 1 : 0
    onOpacityChanged: visible = opacity

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    PlasmaCore.IconItem {
        source: IconName ? IconName : Icon
        width: Math.min(parent.width, parent.height)
        height: width
        anchors.centerIn: parent
        colorGroup: PlasmaCore.ColorScope.colorGroup
    }

    MouseArea {
        anchors.fill: taskIcon
        onClicked: {
            //print(iconSvg.hasElement(IconName))
            var service = statusNotifierSource.serviceForSource(DataEngineSource)
            var operation = service.operationDescription("Activate")
            operation.x = parent.x

            // kmix shows main window instead of volume popup if (parent.x, parent.y) == (0, 0), which is the case here.
            // I am passing a position right below the panel (assuming panel is at screen's top).
            // Plasmoids' popups are already shown below the panel, so this make kmix's popup more consistent
            // to them.
            operation.y = parent.y + parent.height + 6
            service.startOperationCall(operation)
        }
    }
}
