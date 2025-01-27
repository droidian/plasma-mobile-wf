# SPDX-FileCopyrightText: 2025 Alexander Rutx <arpio@droidian.org>
# SPDX-License-Identifier: GPL-2.0-or-later

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/")

find_package(PAM REQUIRED)
find_package(KDSingleApplication-qt6 CONFIG REQUIRED)

add_executable(plamolock
    main.cpp
    sessionlock.cpp
    qml/qml.qrc
)

target_link_libraries(plamolock PUBLIC
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
    KDAB::kdsingleapplication
)

target_include_directories(plamolock PRIVATE ${CMAKE_BINARY_DIR})
target_include_directories(plamolock PUBLIC
                            ${CMAKE_SOURCE_DIR}/3rdparty
                            ${PAM_INCLUDE_DIR})
install(TARGETS plamolock ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
