<p align="center">
    <img align="left" width="64" height="64" src="data/icons/64/io.elementary.monitor.svg">
    <h1 class="rich-diff-level-zero">Monitor</h1>
</p>

<h4 align="left">Manage processes and monitor system resources</h4>

[![](https://img.shields.io/github/release/stsdc/monitor.svg)]()
[![Github Workflow Status](https://github.com/stsdc/monitor/actions/workflows/ci.yml/badge.svg)]()
[![Translation status](https://l10n.elementary.io/widget/desktop/monitor/svg-badge.svg)](https://l10n.elementary.io/engage/desktop/)

![Monitor Screenshot](https://github.com/stsdc/monitor/raw/dev/data/screenshots/monitor-processes.png)
![Monitor Screenshot](https://github.com/stsdc/monitor/raw/dev/data/screenshots/monitor-system.png)

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
sudo apt install build-essential cmake sassc valac libgtk-3-dev libgee-0.8-dev libgranite-dev libgtop2-dev libwnck-3-dev libhandy-1-dev libudisks2-dev libjson-glib-dev libflatpak-dev libxnvctrl-dev libwingpanel-dev
```

Alternatively, if you plan to install WITHOUT a wingpanel-indicator

```bash
sudo apt install build-essential cmake sassc valac libgtk-3-dev libgee-0.8-dev libgranite-dev libgtop2-dev libwnck-3-dev libhandy-1-dev libudisks2-dev libjson-glib-dev libflatpak-dev libxnvctrl-dev 
```


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
G_MESSAGES_DEBUG=all GTK_DEBUG=interactive io.elementary.monitor
```
