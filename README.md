# Monitor
Manage processes and monitor system resources.

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.stsdc.monitor)

![Monitor Screenshot](https://github.com/stsdc/monitor/raw/master/data/com.github.stsdc.monitor.screenshot.png)

## For coffee
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/stsdc/10)


## Building and Installation

You'll need the following dependencies to build:
* valac
* libgtk-3-dev
* libgranite-dev
* libbamf3-dev
* libwnck-3-dev
* libgtop2-dev
* meson

## How To Build

    git clone https://github.com/stsdc/monitor
    cd monitor
    meson build --prefix=/usr
    cd build
    sudo ninja install
    
## Arch Linux
Arch Linux users can find Monitor under the name [pantheon-system-monitor-git](https://aur.archlinux.org/packages/pantheon-system-monitor-git/) in the **AUR**:

`$ aurman -S pantheon-system-monitor-git`
