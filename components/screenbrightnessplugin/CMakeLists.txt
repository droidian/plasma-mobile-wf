# SPDX-FileCopyrightText: 2024 Devin Lin <devin@kde.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(screenbrightnessplugin URI org.kde.plasma.private.mobileshell.screenbrightnessplugin GENERATE_PLUGIN_SOURCE)

target_sources(screenbrightnessplugin PRIVATE
    screenbrightnessutil.cpp
    ${DBUS_SRCS}
)

pkg_check_modules(PKG_LIBDROID_0 REQUIRED libdroid-0)

include_directories(${PKG_LIBDROID_0_INCLUDE_DIRS})

target_link_libraries(screenbrightnessplugin PRIVATE
    Qt::Qml
    Qt::DBus
    Qt::Gui
    Qt::Quick
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::I18n
    KF6::Screen
    ${PKG_LIBDROID_0_LIBRARIES}
)

ecm_finalize_qml_module(screenbrightnessplugin)
