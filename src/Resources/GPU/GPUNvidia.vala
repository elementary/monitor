/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.GPUNvidia : IGPU, Object {

    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public string hwmon_module_name { get; set; }

    public string name { get; set; }

    public int percentage { get; protected set; }

    public int memory_percentage { get; protected set; }

    public int fb_percentage { get; protected set; }

    public double memory_vram_used { get; protected set; }

    public double memory_vram_total { get; set; }

    public double temperature { get; protected set; }

    public int nvidia_temperature = 0;

    public int nvidia_memory_vram_used = 0;

    public int nvidia_memory_vram_total = 0;

    public int nvidia_memory_percentage = 0;

    public int nvidia_fb_percentage = 0;

    public int nvidia_percentage = 0;

    public char * nvidia_used = "";

    public bool nvidia_resources_temperature;

    public bool nvidia_resources_vram_used;

    public bool nvidia_resources_vram_total;

    public bool nvidia_resources_used;

    public X.Display nvidia_display;

    construct {
        nvidia_display = new X.Display ();
    }

    private void update_nv_resources () {
        nvidia_resources_temperature = NVCtrl.XNVCTRLQueryAttribute (
            nvidia_display,
            0,
            0,
            NV_CTRL_GPU_CORE_TEMPERATURE,
            &nvidia_temperature
            );

        if (!nvidia_resources_temperature) {
            warning ("Could not query NV_CTRL_GPU_CORE_TEMPERATURE attribute!\n");
            return;
        }

        nvidia_resources_vram_used = NVCtrl.XNVCTRLQueryTargetAttribute (
            nvidia_display,
            NV_CTRL_TARGET_TYPE_GPU,
            0,
            0,
            NV_CTRL_USED_DEDICATED_GPU_MEMORY,
            &nvidia_memory_vram_used
            );

        if (!nvidia_resources_vram_used) {
            warning ("Could not query NV_CTRL_USED_DEDICATED_GPU_MEMORY attribute!\n");
            return;
        }

        nvidia_resources_vram_total = NVCtrl.XNVCTRLQueryTargetAttribute (
            nvidia_display,
            NV_CTRL_TARGET_TYPE_GPU,
            0,
            0,
            NV_CTRL_TOTAL_DEDICATED_GPU_MEMORY,
            &nvidia_memory_vram_total
            );

        if (!nvidia_resources_vram_total) {
            warning ("Could not query NV_CTRL_TOTAL_DEDICATED_GPU_MEMORY attribute!\n");
            return;
        }

        nvidia_resources_used = NVCtrl.XNVCTRLQueryTargetStringAttribute (
            nvidia_display,
            NV_CTRL_TARGET_TYPE_GPU,
            0,
            0,
            NV_CTRL_STRING_GPU_UTILIZATION,
            &nvidia_used
            );

        // var str_used = (string)nvidia_used;
        nvidia_percentage = int.parse (((string) nvidia_used).split_set ("=,")[1]);
        nvidia_fb_percentage = int.parse (((string) nvidia_used).split_set ("=,")[3]);
        debug ("USED_GRAPHICS: %d%\n", nvidia_percentage);
        debug ("USED_FB_MEMORY: %d%\n", nvidia_fb_percentage);

        if (!nvidia_resources_used) {
            warning ("Could not query NV_CTRL_STRING_GPU_UTILIZATION attribute!\n");
            return;
        }

    }

    private void update_temperature () {
        temperature = nvidia_temperature;
    }

    private void update_memory_vram_used () {
        memory_vram_used = (double) nvidia_memory_vram_used * 1000000.0;
    }

    private void update_memory_vram_total () {
        memory_vram_total = (double) nvidia_memory_vram_total * 1000000.0;
    }

    private void update_memory_percentage () {
        memory_percentage = (int) (Math.round ((memory_vram_used / memory_vram_total) * 100));
    }

    private void update_fb_percentage () {
        fb_percentage = nvidia_fb_percentage;
    }

    private void update_percentage () {
        percentage = nvidia_percentage;
    }

    public void update () {
        update_nv_resources ();
        update_temperature ();
        update_memory_vram_used ();
        update_memory_vram_total ();
        update_memory_percentage ();
        update_percentage ();
    }

}
