<p align="center">
    <img align="left" width="64" height="64" src="data/icons/64/com.github.stsdc.monitor.svg">
    <h1 class="rich-diff-level-zero">Monitor</h1>
</p>

<h4 align="left">Manage processes and monitor system resources</h4>

<p align="left">
    <a href="https://paypal.me/stsdc/10">
        <img src="https://img.shields.io/badge/Donate-PayPal-green.svg">
    </a>
    <a href="https://ko-fi.com/stsdc" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee" /></a>
    <a href="https://github.com/stsdc/monitor/releases">
        <img src="https://img.shields.io/github/release/stsdc/monitor.svg" alt="Release">
    </a>
    <img alt="GitHub Workflow Status" src="https://github.com/stsdc/monitor/actions/workflows/main.yml/badge.svg">
    <a href="https://copr.fedorainfracloud.org/coprs/stsdc/monitor/package/com.github.stsdc.monitor/"><img src="https://copr.fedorainfracloud.org/coprs/stsdc/monitor/package/com.github.stsdc.monitor/status_image/last_build.png" /></a>
    <a href="https://github.com/stsdc/monitor/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/stsdc/monitor.svg">
    </a>
</p>
![Monitor Screenshot](https://github.com/stsdc/monitor/raw/master/data/screenshots/monitor-processes.png)
![Monitor Screenshot](https://github.com/stsdc/monitor/raw/master/data/screenshots/monitor-system.png)

## Install

### elementary os 6 and 6.1

If you have never added a PPA on your system before, you might need to run this command first:

```bash
sudo apt install -y software-properties-common
```

Add the PPA of Monitor and then install it:

```bash
sudo add-apt-repository ppa:stsdc/monitor
sudo apt install com.github.stsdc.monitor
```

Monitor will then be available from the Applications menu.

### Fedora (34, 35)

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
* libudisks2-dev
* libxnvctrl-dev
* meson
* sassc

### Clone, Build & Install

1. Clone:
   ```bash
   git clone --recursive https://github.com/stsdc/monitor
   cd monitor
   ```

2. To build with the wingpanel indicator:
   ```bash
   meson builddir --prefix=/usr -Dindicator-wingpanel=enabled
   ```
   Alternatively, to build without the wingpanel indicator:
   ```bash
   meson builddir --prefix=/usr
   ```

3. Install:
   ```bash
   cd builddir
   sudo ninja install
   ```

### Debug logging

```bash
G_MESSAGES_DEBUG=all GTK_DEBUG=interactive com.github.stsdc.monitor
```
