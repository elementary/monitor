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
    <img alt="GitHub Workflow Status" src="https://img.shields.io/github/workflow/status/stsdc/monitor/CI">
    <a href="https://copr.fedorainfracloud.org/coprs/stsdc/monitor/package/com.github.stsdc.monitor/"><img src="https://copr.fedorainfracloud.org/coprs/stsdc/monitor/package/com.github.stsdc.monitor/status_image/last_build.png" /></a>
    <a href="https://github.com/stsdc/monitor/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/stsdc/monitor.svg">
    </a>
</p>

![Monitor Screenshot](https://github.com/stsdc/monitor/raw/master/data/screenshots/monitor-processes.png)
![Monitor Screenshot](https://github.com/stsdc/monitor/raw/master/data/screenshots/monitor-system.png)

## Install

### elementary os (Odin)

```bash
    sudo add-apt-repository ppa:stsdc/monitor
    sudo apt install com.github.stsdc.monitor
```
### Fedora (34)

```bash
    sudo dnf copr enable stsdc/monitor 
    sudo dnf install com.github.stsdc.monitor
```

## Development

### Install dependencies

* valac
* libgtk-3-dev
* libgranite-dev (>= 5.2.0)
* libwnck-3-dev
* libgtop2-dev
* libwingpanel-3.0-dev
* libhandy-1-dev
* meson
* sassc

### Clone, Build & Install

    git clone https://github.com/stsdc/monitor
    cd monitor
    meson build --prefix=/usr
    cd build
    sudo ninja install

### Debug
`G_MESSAGES_DEBUG=all GTK_DEBUG=interactive ./com.github.stsdc.monitor`
