# Monitor
Manage processes and monitor system resources.

![Monitor Screenshot](https://github.com/stsdc/monitor/raw/master/data/com.github.stsdc.monitor.screenshot.png)

## Building and Installation

You'll need the following dependencies to build:
* cmake
* libgtk-3-dev
* valac
* libgranite-dev
* libbamf3-dev
* libwnck-3-dev
* libgtop2-dev

## How To Build

    git clone https://github.com/stsdc/monitor
    cd monitor
    mkdir build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    sudo make install
