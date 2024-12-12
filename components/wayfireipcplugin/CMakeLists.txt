# SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(wayfireipcplugin URI org.kde.plasma.private.mobileshell.wayfireipcplugin GENERATE_PLUGIN_SOURCE)
target_sources(wayfireipcplugin PRIVATE wayfireipc.cpp)

target_link_libraries(wayfireipcplugin PRIVATE
    Qt::Qml
    Qt::Network
)

ecm_finalize_qml_module(wayfireipcplugin)