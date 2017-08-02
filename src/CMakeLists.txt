configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_BINARY_DIR}/src/config.vala)

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.26" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    ./elementarySystemMonitor.vala
    ./MainWindow.vala
    ./ProcessMonitor/ProcessMonitor.vala
    ./ProcessMonitor/Process.vala
    ./Widgets/ProcessView.vala
    ./Models/ApplicationProcessModel.vala
    ./Services/AppManager.vala
    ${CMAKE_BINARY_DIR}/src/config.vala
PACKAGES
    ${SYSTEM_MONITOR_DEPS}
OPTIONS
    --thread
    --enable-checking
    --enable-experimental
    -v
    -g
)

add_executable(${EXEC_NAME} ${VALA_C})
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
