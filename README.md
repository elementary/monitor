<p align="center">
    <img align="left" width="64" height="64" src="data/icons/64/io.elementary.monitor.svg">
    <h1 class="rich-diff-level-zero">Monitor</h1>
</p>

<h4 align="left">Manage processes and monitor system resources</h4>

[![](https://img.shields.io/github/release/elementary/monitor.svg)]()
[![Github Workflow Status](https://github.com/elementary/monitor/actions/workflows/ci.yml/badge.svg)]()
[![Translation status](https://l10n.elementary.io/widget/desktop/monitor/svg-badge.svg)](https://l10n.elementary.io/engage/desktop/)

![Monitor Screenshot](https://github.com/elementary/monitor/raw/main/data/screenshots/monitor-processes.png)
![Monitor Screenshot](https://github.com/elementary/monitor/raw/main/data/screenshots/monitor-system.png)

## Install

### elementary OS 7 Horus

If you have never added a PPA on your system before, you might need to run this command first:

```bash
sudo apt install -y software-properties-common
```

Add the PPA of Monitor and then install it:

```bash
sudo add-apt-repository ppa:stsdc/monitor
sudo apt install com.github.stsdc.monitor
```

Monitor will be available from the Applications menu.

## Development

### Install dependencies

If you plan to install WITH a wingpanel-indicator

```bash
sudo apt install build-essential cmake sassc valac libgtk-3-dev libgee-0.8-dev libgranite-dev libgtop2-dev libhandy-1-dev libudisks2-dev libjson-glib-dev libflatpak-dev libxnvctrl-dev liblivechart-1-dev libpci-dev libwingpanel-dev meson xvfb
```

Alternatively, if you plan to install WITHOUT a wingpanel-indicator

```bash
sudo apt install build-essential cmake sassc valac libgtk-3-dev libgee-0.8-dev libgranite-dev libgtop2-dev libhandy-1-dev libudisks2-dev libjson-glib-dev libflatpak-dev libxnvctrl-dev liblivechart-1-dev libpci-dev meson xvfb
```


### Clone, Build & Install

1. Clone:
   ```bash
   git clone https://github.com/elementary/monitor
   cd monitor
   ```

2. To build with the wingpanel indicator:
   ```bash
   meson setup -Dindicator-wingpanel=enabled build
   ```
   Alternatively, to build without the wingpanel indicator:
   ```bash
   meson setup build
   ```

3. Install:
   ```bash
   cd build
   sudo ninja install
   ```

### Debug logging

```bash
G_MESSAGES_DEBUG=all GTK_DEBUG=interactive io.elementary.monitor
```
