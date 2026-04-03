/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

[Compact]
[CCode (cname = "MonitorNvmlGpu", free_function = "monitor_nvml_gpu_free")]
private class MonitorNvmlGpu {
}

[CCode (cname = "MonitorNvmlSample")]
private struct MonitorNvmlSample {
    public uint gpu_percent;
    public uint64 mem_used;
    public uint64 mem_total;
    public uint temperature_c;
    public bool ok_util;
    public bool ok_mem;
    public bool ok_temp;
}

[CCode (cname = "monitor_nvml_gpu_new_from_pci_bus_id")]
private extern MonitorNvmlGpu? monitor_nvml_gpu_new_from_pci_bus_id (string pci_bus_id);

[CCode (cname = "monitor_nvml_gpu_sample")]
private extern bool monitor_nvml_gpu_sample (MonitorNvmlGpu gpu, out MonitorNvmlSample sample);

public class Monitor.GPUNvidia : IGPU, Object {
    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }
    public string hwmon_module_name { get; protected set; }
    public string driver_name { get; protected set; }
    public string name { get; protected set; }
    public int percentage { get; protected set; }
    public int memory_percentage { get; protected set; }
    public int fb_percentage { get; protected set; }
    public double memory_vram_used { get; protected set; }
    public double memory_vram_total { get; protected set; }
    public double temperature { get; protected set; }
    protected string sysfs_path { get; protected set; }

    private MonitorNvmlGpu? nvml_gpu;
    private MonitorNvmlSample sample_cache;

    public GPUNvidia (Pci.Access pci_access, Pci.Dev pci_device) {
        name = "NVIDIA " + pci_parse_name (pci_access, pci_device);
        sysfs_path = pci_parse_sysfs_path (pci_access, pci_device);
        driver_name = pci_device.get_string_property (Pci.FILL_DRIVER);
        hwmon_module_name = driver_name;
        hwmon_temperatures = new Gee.HashMap<string, HwmonTemperature> ();

#if NVIDIA_SUPPORT
        string pci_bus_id = "%04x:%02x:%02x.%u".printf (
            pci_device.domain_16,
            pci_device.bus,
            pci_device.dev,
            pci_device.func
        );

        nvml_gpu = monitor_nvml_gpu_new_from_pci_bus_id (pci_bus_id);
        if (nvml_gpu == null) {
            warning ("Failed to initialize NVML handle for %s (%s)", name, pci_bus_id);
        }
#endif
    }

    private bool update_nv_resources () {
#if NVIDIA_SUPPORT
        if (nvml_gpu == null) {
            return false;
        }

        if (!monitor_nvml_gpu_sample (nvml_gpu, out sample_cache)) {
            return false;
        }

        return true;
#else
        return false;
#endif
    }

    public void update_temperature () {
#if NVIDIA_SUPPORT
        if (sample_cache.ok_temp) {
            temperature = (double) sample_cache.temperature_c;
        } else {
            temperature = 0;
        }
#else
        temperature = 0;
#endif
    }

    public void update_memory_vram_used () {
#if NVIDIA_SUPPORT
        if (sample_cache.ok_mem) {
            memory_vram_used = (double) sample_cache.mem_used;
        } else {
            memory_vram_used = 0;
        }
#else
        memory_vram_used = 0;
#endif
    }

    public void update_memory_vram_total () {
#if NVIDIA_SUPPORT
        if (sample_cache.ok_mem) {
            memory_vram_total = (double) sample_cache.mem_total;
        } else {
            memory_vram_total = 0;
        }
#else
        memory_vram_total = 0;
#endif
    }

    public void update_memory_percentage () {
        if (memory_vram_total > 0) {
            memory_percentage = (int) Math.round ((memory_vram_used / memory_vram_total) * 100.0);
            fb_percentage = memory_percentage;
        } else {
            memory_percentage = 0;
            fb_percentage = 0;
        }
    }

    public void update_percentage () {
#if NVIDIA_SUPPORT
        if (sample_cache.ok_util) {
            percentage = (int) sample_cache.gpu_percent;
        } else {
            percentage = 0;
        }
#else
        percentage = 0;
#endif
    }

    public void update () {
        bool ok = update_nv_resources ();

        if (!ok) {
            percentage = 0;
            memory_percentage = 0;
            fb_percentage = 0;
            memory_vram_used = 0;
            memory_vram_total = 0;
            temperature = 0;
            return;
        }

        update_temperature ();
        update_memory_vram_used ();
        update_memory_vram_total ();
        update_memory_percentage ();
        update_percentage ();
    }
}