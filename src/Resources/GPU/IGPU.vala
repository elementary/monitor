/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public interface Monitor.IGPU : Object {

    public abstract Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public abstract string hwmon_module_name { get; protected set; }

    public abstract string name { get; protected set; }

    public abstract int percentage { get; protected set; }

    public abstract int memory_percentage { get; protected set; }

    public abstract double memory_vram_used { get; protected set; }

    public abstract double memory_vram_total { get; protected set; }

    public abstract double temperature { get; protected set; }

    protected abstract string sysfs_path { get; protected set; }

    public abstract void update_temperature ();

    public abstract void update_memory_vram_used ();

    public abstract void update_memory_vram_total ();

    public abstract void update_memory_percentage ();

    public abstract void update_percentage ();

    public abstract void update ();

    public virtual void set_pci_properties (Pci.Access pci_access, Pci.Dev pci_device) {
        string pci_path_domain_bus = "%04x:%02x".printf (pci_device.domain_16, pci_device.bus);
        string pci_path_dev_func = "%02x.%d".printf (pci_device.dev, pci_device.func);
        sysfs_path = "/sys/class/pci_bus/%s/device/%s:%s".printf (pci_path_domain_bus, pci_path_domain_bus, pci_path_dev_func);
        debug ("GPU path: %s", sysfs_path);

        char namebuf[256];
        name = pci_access.lookup_name (namebuf, Pci.LookupMode.DEVICE, pci_device.vendor_id, pci_device.device_id);
    }

    public virtual string get_sysfs_value (string path) {
        string content;
        try {
            FileUtils.get_contents (path, out content);
        } catch (Error e) {
            warning (e.message);
            content = "0";
        }
        return content;
    }

}
