// SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Button {
    id: root

    property bool noBorder: false

    background: Rectangle {
        width: root.width
        height: root.height
        color: root.pressed ? Kirigami.Theme.highlightColor : "transparent"
        border.color: root.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
        border.width: root.noBorder ? 0 : 1
        radius: 5
    }

    contentItem: Text {
        text: root.text
        fontSizeMode: Text.Fit
        font.pixelSize: 24
        font.bold: false
        color: Kirigami.Theme.textColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}