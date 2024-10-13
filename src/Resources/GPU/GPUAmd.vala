public class Monitor.GPUAmd : IGPU, Object {
    public SessionManager ? session_manager { get; protected set; }

    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public string hwmon_module_name { get; set; }

    public int percentage { get; protected set; }

    public int memory_percentage { get; protected set; }

    public double memory_vram_used { get; protected set; }

    public double memory_vram_total { get; set; }

    public double temperature { get; protected set; }

    private string path { get; set; }

    construct {
        // session_manager = get_sessman ();
        // When path for GPU is created it can be assigned to card0 or card1
        // this a bit random. This should be removed when multiple GPU
        // support will be added.
        try {
            var dir = Dir.open ("/sys/class/drm/");
            string ? name;
            while ((name = dir.read_name ()) != null) {
                if (name == "card0") {
                    path = "/sys/class/drm/card0/";
                    debug ("GPU path: %s", path);

                } else if (name == "card1") {
                    path = "/sys/class/drm/card1/";
                    debug ("GPU path: %s", path);

                }
            }
            if (path == null) {
                debug ("Can't detect right path for AMD GPU");
            }
        } catch (Error e) {
            print ("Error: %s\n", e.message);
        }
    }

    private void update_temperature () {
        temperature = double.parse (hwmon_temperatures.get ("edge").input) / 1000;
    }

    private void update_memory_vram_used () {
        memory_vram_used = double.parse (get_sysfs_value (path + "device/mem_info_vram_used"));
    }

    private void update_memory_vram_total () {
        memory_vram_total = double.parse (get_sysfs_value (path + "device/mem_info_vram_total"));
    }

    private void update_memory_percentage () {
        memory_percentage = (int) (Math.round ((memory_vram_used / memory_vram_total) * 100));
    }

    private void update_percentage () {
        percentage = int.parse (get_sysfs_value (path + "device/gpu_busy_percent"));
    }

    public void update () {
        update_temperature ();
        update_memory_vram_used ();
        update_memory_vram_total ();
        update_memory_percentage ();
        update_percentage ();
    }

}
