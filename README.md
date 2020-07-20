<p align="center">
    <img align="left" width="64" height="64" src="data/icons/64/com.github.stsdc.monitor.svg">
    <h1 class="rich-diff-level-zero">Monitor</h1>
</p>

<h4 align="left">Manage processes and monitor system resources</h4>

<p align="left">
    <a href="https://paypal.me/stsdc/10">
        <img src="https://img.shields.io/badge/Donate-PayPal-green.svg">
    </a>
    <a href="https://github.com/stsdc/monitor/releases">
        <img src="https://img.shields.io/github/release/stsdc/monitor.svg" alt="Release">
    </a>
    <a href="https://travis-ci.org/stsdc/monitor">
        <img src="https://travis-ci.org/stsdc/monitor.svg?branch=master" alt="Build Status">
    </a>
    <a href="https://github.com/stsdc/monitor/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/stsdc/monitor.svg">
    </a>
</p>

![Monitor Screenshot](https://github.com/stsdc/monitor/raw/master/data/screenshots/monitor-processes.png)

## Development

### Install dependencies

* valac
* libgtk-3-dev
* libgranite-dev (>= 5.2.0)
* libbamf3-dev
* libwnck-3-dev
* libgtop2-dev
* libwingpanel-2.0-dev
* libxml2-utils
* meson

### Clone, Build & Install

    git clone https://github.com/stsdc/monitor
    cd monitor
    meson build --prefix=/usr
    cd build
    sudo ninja install

### Debug
`G_MESSAGES_DEBUG=all ./com.github.stsdc.monitor`

## Other OSes

### Arch Linux

Arch Linux users can find Monitor under the name [pantheon-system-monitor-git](https://aur.archlinux.org/packages/pantheon-system-monitor-git/) in the **AUR**:

`$ aurman -S pantheon-system-monitor-git`

### Fedora

Fedora users can find Monitor under the name [monitor](https://copr.fedorainfracloud.org/coprs/decathorpe/elementary-appcenter/package/monitor/) in **COPR**:

`$ dnf copr enable decathorpe/elementary-appcenter`

`$ dnf install monitor`
