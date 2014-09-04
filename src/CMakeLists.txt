configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_BINARY_DIR}/src/config.vala)

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.22" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    ./elementarySystemMonitor.vala
    ./MainWindow.vala
    ./ProcessMonitor/ProcessMonitor.vala
    ./ProcessMonitor/Process.vala
    ./Widgets/ProcessView.vala
    ./Models/ApplicationProcessModel.vala
    ${CMAKE_BINARY_DIR}/src/config.vala
PACKAGES
    ${SYSTEM_MONITOR_DEPS}
    posix
OPTIONS
    --thread
    --enable-checking
    -v
)

add_executable(${EXEC_NAME} ${VALA_C})
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
