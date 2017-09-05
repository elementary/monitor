project (com.github.stsdc.monitor)

cmake_minimum_required (VERSION 2.8.9)
cmake_policy(VERSION 2.8)

include (GNUInstallDirs)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (EXEC_NAME ${CMAKE_PROJECT_NAME})
set (DATADIR ${CMAKE_INSTALL_FULL_DATAROOTDIR})
set (PKGDATADIR "${DATADIR}/${PROJECT_NAME}")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})
set (RELEASE_NAME "Monitor")
set (VERSION "0.3.1")
set (VERSION_INFO "Alpha")
set (DOLLAR "$")

# enable_testing ()
set (CMAKE_BUILD_TYPE Debug)
add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"" -DWNCK_I_KNOW_THIS_IS_UNSTABLE)

set (SYSTEM_MONITOR_DEPS
    gtk+-3.0
    gee-0.8
    libbamf3
    libwnck-3.0
    gobject-2.0
    glib-2.0
    gio-2.0
    granite
)

find_package (PkgConfig)
# pkg_check_modules(WNCK REQUIRED libwnck-3.0)
pkg_check_modules (DEPS REQUIRED ${SYSTEM_MONITOR_DEPS})

# Comment this out to enable C compiler warnings
add_definitions (-w)

add_definitions (${DEPS_CFLAGS} ${WNCK_CFLAGS})
link_libraries (${DEPS_LIBRARIES} ${WNCK_LIBRARIES} gtop-2.0 -lm)
link_directories (${DEPS_LIBRARY_DIRS})

include_directories(/usr/include/libgtop-2.0)

add_subdirectory (src)
add_subdirectory (po)
add_subdirectory (data)

# uninstall target
configure_file (
    "${CMAKE_SOURCE_DIR}/cmake/Uninstall.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/Uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target (uninstall
COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/Uninstall.cmake)