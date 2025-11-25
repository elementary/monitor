/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.GPUAmd : IGPU, Object {

    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public string hwmon_module_name { get; set; }

    public string driver_name { get; set; }

    public string name { get; set; }

    public int percentage { get; protected set; }

    public int memory_percentage { get; protected set; }

    public double memory_vram_used { get; protected set; }

    public double memory_vram_total { get; set; }

    public double temperature { get; protected set; }

    protected string sysfs_path { get; set; }

    public GPUAmd (Pci.Access pci_access, Pci.Dev pci_device) {
        name = pci_parse_name (pci_access, pci_device);
        name = "AMD® " + name;

        sysfs_path = pci_parse_sysfs_path (pci_access, pci_device);
        driver_name = pci_device.get_string_property (Pci.FILL_DRIVER);
    }

    private void update_temperature () {
        temperature = double.parse (hwmon_temperatures.get ("edge").input) / 1000;
    }

    private void update_memory_vram_used () {
        memory_vram_used = double.parse (get_sysfs_value (sysfs_path + "/mem_info_vram_used"));
    }

    private void update_memory_vram_total () {
        memory_vram_total = double.parse (get_sysfs_value (sysfs_path + "/mem_info_vram_total"));
    }

    private void update_memory_percentage () {
        memory_percentage = (int) (Math.round ((memory_vram_used / memory_vram_total) * 100));
    }

    private void update_percentage () {
        percentage = int.parse (get_sysfs_value (sysfs_path + "/gpu_busy_percent"));
    }

    public void update () {
        update_temperature ();
        update_memory_vram_used ();
        update_memory_vram_total ();
        update_memory_percentage ();
        update_percentage ();
    }

}
