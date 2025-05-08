/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.GPUIntel : IGPU, Object {

    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public string hwmon_module_name { get; set; }

    public string name { get; set; }

    public int percentage { get; protected set; }

    public int memory_percentage { get; protected set; }

    public double memory_vram_used { get; protected set; }

    public double memory_vram_total { get; set; }

    public double temperature { get; protected set; }

    protected string sysfs_path { get; set; }

    public GPUIntel (Pci.Access pci_access, Pci.Dev pci_device) {
        set_pci_properties (pci_access, pci_device);
        name = "Intel® " + name;
    }

    private void update_temperature () {
        // @TODO: Intel GPU temperature retrieval needs implementation.
        temperature = 0;
    }

    private void update_memory_vram_used () {
        // @TODO: Intel GPU used VRAM retrieval needs implementation.
        memory_vram_used = 0;
    }

    private void update_memory_vram_total () {
        // @TODO: Intel GPU total VRAM retrieval needs implementation.
        memory_vram_total = 0;
    }

    private void update_memory_percentage () {
        // @TODO: Intel GPU memory percentage needs implementation.
        memory_percentage = 0;
    }

    private void update_percentage () {
        // @TODO: Intel GPU usage percentage needs implementation.
        percentage = 0;
    }

    public void update () {
        update_temperature ();
        update_memory_vram_used ();
        update_memory_vram_total ();
        update_memory_percentage ();
        update_percentage ();
    }

}
