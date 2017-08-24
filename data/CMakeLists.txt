# install our .desktop file so the Applications menu will see it
install (FILES com.github.stsdc.monitor.desktop DESTINATION share/applications/)
# install our .appdata.xml file so AppCenter will see it
install (FILES com.github.stsdc.monitor.appdata.xml DESTINATION share/metainfo/)

install (FILES icons/16/com.github.stsdc.monitor.svg DESTINATION share/icons/hicolor/16x16/apps)
install (FILES icons/24/com.github.stsdc.monitor.svg DESTINATION share/icons/hicolor/24x24/apps)
install (FILES icons/32/com.github.stsdc.monitor.svg DESTINATION share/icons/hicolor/32x32/apps)
install (FILES icons/48/com.github.stsdc.monitor.svg DESTINATION share/icons/hicolor/48x48/apps)
install (FILES icons/64/com.github.stsdc.monitor.svg DESTINATION share/icons/hicolor/64x64/apps)
install (FILES icons/128/com.github.stsdc.monitor.svg DESTINATION share/icons/hicolor/128x128/apps)

install (FILES icons/64/com.github.stsdc.monitor.svg DESTINATION share/icons/hicolor/scalable/apps)

include (GSettings)
add_schema (com.github.stsdc.monitor.gschema.xml)