# - Try to find libwnck
# Once done this will define
#  LIBWNCK2_FOUND - System has libwnck
#  LIBWNCK2_INCLUDE_DIRS - The libwnck include directories
#  LIBWNCK2_LIBRARIES - The libraries needed to use libwnck
#  LIBWNCK2_DEFINITIONS - Compiler switches required for using libwnck

find_package(PkgConfig)
pkg_check_modules(PC_LIBWNCK QUIET libwnck-3.0)
set(LIBWNCK2_DEFINITIONS ${PC_LIBWNCK_CFLAGS_OTHER})

find_path(LIBWNCK_INCLUDE_DIR libwnck/libwnck.h
          HINTS ${PC_LIBWNCK_INCLUDEDIR} ${PC_LIBWNCK_INCLUDE_DIRS}
      PATH_SUFFIXES libwnck )

find_library(LIBWNCK_LIBRARY NAMES libwnck-3.0
             HINTS ${PC_LIBWNCK_LIBDIR} ${PC_LIBWNCK_LIBRARY_DIRS} )

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LIBWNCK_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(libwnck  DEFAULT_MSG
                                  LIBWNCK_LIBRARY LIBWNCK_INCLUDE_DIR)

mark_as_advanced(LIBWNCK_INCLUDE_DIR LIBWNCK_LIBRARY )

set(LIBWNCK_LIBRARIES ${LIBWNCK_LIBRARY} )
set(LIBWNCK_INCLUDE_DIRS ${LIBWNCK_INCLUDE_DIR} )
