# SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(wlrdpmsplugin URI org.kde.plasma.private.mobileshell.wlrdpmsplugin GENERATE_PLUGIN_SOURCE)

target_sources(wlrdpmsplugin PRIVATE
    wlrdpms.cpp)

target_link_libraries(wlrdpmsplugin PRIVATE
    Qt::Qml
    Qt::Network
    Qt::WaylandClient
    Qt::WaylandClientPrivate
)

qt6_generate_wayland_protocol_client_sources(wlrdpmsplugin
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/protocols/wlr-output-power-management-unstable-v1.xml
)

ecm_finalize_qml_module(wlrdpmsplugin)