set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX /usr)
endif ()

include(GNUInstallDirs)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

set(CONFIG_CMAKE_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/SessionLockQt"
    CACHE STRING "Install dir for cmake config files")

set(INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/SessionLockQt")

find_package(Qt6 REQUIRED COMPONENTS Core Gui WaylandClient Qml)
find_package(Qt6WaylandScannerTools REQUIRED)

find_package(Wayland 1.3 COMPONENTS Client Server)
find_package(PkgConfig REQUIRED)

pkg_check_modules(XKBCOMMON xkbcommon REQUIRED IMPORTED_TARGET)

add_library(SessionLockQtInterface SHARED)

qt6_generate_wayland_protocol_client_sources(SessionLockQtInterface FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/misc/ext-session-lock-v1.xml
)

target_sources(SessionLockQtInterface PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/window.h
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/window.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/shell.h
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/shell.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/command.h
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/command.cpp
)

generate_export_header(SessionLockQtInterface)

target_link_libraries(SessionLockQtInterface PUBLIC
    Qt6::Gui
    Qt6::Core
    Qt6::WaylandClient
    Wayland::Client
)

target_link_libraries(SessionLockQtInterface PRIVATE
    Qt6::WaylandClientPrivate
    PkgConfig::XKBCOMMON
)

set_target_properties(SessionLockQtInterface PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    EXPORT_NAME Interface
)

target_include_directories(SessionLockQtInterface PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/SessionLockQt>
)

install(TARGETS SessionLockQtInterface
        EXPORT SessionLockQtTargets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(EXPORT SessionLockQtTargets
        FILE SessionLockQtTargets.cmake
        NAMESPACE SessionLockQt::
        DESTINATION ${CONFIG_CMAKE_INSTALL_DIR}
)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/cmake/SessionLockQtConfig.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/SessionLockQtConfig.cmake"
    INSTALL_DESTINATION ${CONFIG_CMAKE_INSTALL_DIR})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/SessionLockQtConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/SessionLockQtConfigVersion.cmake
        DESTINATION ${CONFIG_CMAKE_INSTALL_DIR})

add_library(ext-session-lock-v1 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/wayland-ext-session-lock-v1-client-protocol.h
    ${CMAKE_CURRENT_BINARY_DIR}/wayland-ext-session-lock-v1-protocol.c
    ${CMAKE_CURRENT_BINARY_DIR}/qwayland-ext-session-lock-v1.h
    ${CMAKE_CURRENT_BINARY_DIR}/qwayland-ext-session-lock-v1.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/qwaylandextsessionlocksurface.h
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/qwaylandextsessionlocksurface.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/qwaylandextsessionlockmanagerintegration.h
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/qwaylandextsessionlockmanagerintegration.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/qwaylandextsessionlockintegrationplugin.h
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/qwaylandextsessionlockintegrationplugin.cpp
)

target_link_libraries(ext-session-lock-v1
    Qt6::WaylandClient
    Qt6::WaylandClientPrivate
    Qt6::Core
    SessionLockQtInterface
    PkgConfig::XKBCOMMON
)

set_target_properties(ext-session-lock-v1 PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/wayland-shell-integration"
)

install(TARGETS ext-session-lock-v1
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/qt6/plugins/wayland-shell-integration)

set(HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/shell.h
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/window.h
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces/command.h
    ${CMAKE_CURRENT_BINARY_DIR}/sessionlockqtinterface_export.h
)

install(FILES
    ${HEADERS}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/SessionLockQt COMPONENT Devel
)

target_include_directories(ext-session-lock-v1 PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock/src/interfaces
    ${CMAKE_CURRENT_SOURCE_DIR}/qt-session-lock
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/SessionLockQtConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/SessionLockQtConfigVersion.cmake
        DESTINATION ${CONFIG_CMAKE_INSTALL_DIR})