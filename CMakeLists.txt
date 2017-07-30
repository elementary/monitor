set (PROJECT_NAME "com.github.stsdc.monitor")
project (${PROJECT_NAME})

cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (EXEC_NAME "${PROJECT_NAME}")
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/${PROJECT_NAME}")
set (GETTEXT_PACKAGE ${PROJECT_NAME})
set (RELEASE_NAME "Monitor")
set (VERSION "0.1")
set (VERSION_INFO "Alpha")
set (DOLLAR "$")

# enable_testing ()

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
    posix
)
# find_package (libwnck-3.0)
# if (WNCK_FOUND)
#   include_directories(${WNCK_INCLUDE_DIRS})
#   target_link_libraries (${PROJECT_NAME} ${WNCK_LIBRARIES})
# endif (WNCK_FOUND)

find_package (PkgConfig)
# pkg_check_modules(WNCK REQUIRED libwnck-3.0)
pkg_check_modules (DEPS REQUIRED ${SYSTEM_MONITOR_DEPS})

add_definitions (${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS} )
link_libraries (${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS} )

add_subdirectory (src)
add_subdirectory (po)
add_subdirectory (data)
