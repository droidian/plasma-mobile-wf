# SPDX-FileCopyrightText: 2025 Alexander Rutx <arpio@droidian.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(sessionlockplugin URI org.kde.plasma.private.mobileshell.sessionlockplugin GENERATE_PLUGIN_SOURCE)
target_sources(sessionlockplugin PRIVATE sessionlock.cpp)

file(GLOB_RECURSE _qml_sources
    "qml/*.qml"
)
ecm_target_qml_sources(sessionlockplugin SOURCES ${_qml_sources})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/")
find_package(PAM REQUIRED)

target_link_libraries(sessionlockplugin PUBLIC
    Qt::Qml
    Qt::Gui
    Qt::Widgets
    Qt::Quick
    KF6::I18n
    KF6::ConfigCore
    KF6::ConfigGui
    KF6::CoreAddons
    KF6::DBusAddons
    KF6::Package
    SessionLockQtInterface
    ${PAM_LIBRARIES}
    Qt::WaylandClient
    Qt::WaylandClientPrivate
)

target_include_directories(sessionlockplugin PUBLIC
                            ${CMAKE_SOURCE_DIR}/3rdparty
                            ${PAM_INCLUDE_DIR})

ecm_finalize_qml_module(sessionlockplugin)
