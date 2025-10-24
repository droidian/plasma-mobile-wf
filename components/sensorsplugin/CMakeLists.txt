# SPDX-FileCopyrightText: 2024 Alexander Rutz <arpio@droidian.org>
# SPDX-License-Identifier: GPL-2.0-or-later

ecm_add_qml_module(sensorsplugin URI org.kde.plasma.private.mobileshell.sensorsplugin GENERATE_PLUGIN_SOURCE)
target_sources(sensorsplugin PRIVATE sensors.cpp)

target_link_libraries(sensorsplugin PRIVATE
    Qt::Qml
    Qt::Sensors
)

ecm_finalize_qml_module(sensorsplugin)