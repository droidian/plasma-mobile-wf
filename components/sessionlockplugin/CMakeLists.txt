# SPDX-FileCopyrightText: 2025 Alexander Rutz <arpio@droidian.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(sessionlockplugin URI org.kde.plasma.private.mobileshell.sessionlockplugin GENERATE_PLUGIN_SOURCE)

target_sources(sessionlockplugin PRIVATE
                sessionlock.cpp
                extsessionlockmanager.cpp
                extsessionlock.cpp
                extsessionlocksurface.cpp
                solidbattery.cpp
                sessionlocksettings.cpp)

file(GLOB_RECURSE _qml_sources
    "qml/*.qml"
)

ecm_target_qml_sources(sessionlockplugin SOURCES ${_qml_sources})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/")
find_package(PAM REQUIRED)

target_link_libraries(sessionlockplugin PRIVATE
    Qt::Qml
    Qt::Quick
    KF6::I18n
    KF6::CoreAddons
    KF6::ModemManagerQt
    KF6::Solid
    KF6::ConfigCore
    KF6::ConfigGui
    Qt::WaylandClient
    Qt::WaylandClientPrivate
    KSysGuard::Sensors
    ${PAM_LIBRARIES}
)

qt6_generate_wayland_protocol_client_sources(sessionlockplugin
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/protocols/ext-session-lock-v1.xml
)

target_include_directories(sessionlockplugin PUBLIC ${PAM_INCLUDE_DIR})

ecm_finalize_qml_module(sessionlockplugin)