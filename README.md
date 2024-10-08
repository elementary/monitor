<p align="center">
    <img align="left" width="64" height="64" src="data/icons/64/com.github.stsdc.monitor.svg">
    <h1 class="rich-diff-level-zero">Monitor</h1>
</p>

<h4 align="left">Manage processes and monitor system resources</h4>

<p align="left">
    <a href="https://github.com/stsdc/monitor/releases">
        <img src="https://img.shields.io/github/release/stsdc/monitor.svg" alt="Release">
    </a>
    <img alt="GitHub Workflow Status" src="https://github.com/stsdc/monitor/actions/workflows/ci/badge.svg">
    <a href="https://github.com/stsdc/monitor/blob/master/LICENSE">
        <img src="https://img.shields.io/github/license/stsdc/monitor.svg">
    </a>
</p>

[![Translation status](https://l10n.elementary.io/widget/desktop/monitor/svg-badge.svg)](https://l10n.elementary.io/engage/desktop/)

![Monitor Screenshot](https://github.com/stsdc/monitor/raw/dev/data/screenshots/monitor-processes.png)
![Monitor Screenshot](https://github.com/stsdc/monitor/raw/dev/data/screenshots/monitor-system.png)
![Monitor Screenshot](https://github.com/stsdc/monitor/raw/dev/data/screenshots/monitor-containers.png)

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

Check dependencies in [the deb control file](debian/control).

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
