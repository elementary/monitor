public class Monitor.GPUAmd : IGPU, Object {
    public SessionManager? session_manager { get; protected set; }

    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public string hwmon_module_name { get; set; }

    public int percentage { get; protected set; }

    public int memory_percentage { get; protected set; }

    public int memory_vram_used { get; protected set; }

    public double temperature { get; protected set; }

    construct {
        //  session_manager = get_sessman ();
    }

    private void update_temperature () {
        temperature = double.parse (hwmon_temperatures.get ("edge").input) / 1000;
    }

    private void update_memory_vram_used () {
        memory_vram_used = int.parse (get_sysfs_value ("/sys/class/drm/card0/device/mem_info_vram_used"));
    }

    private void update_memory_percentage () {
        memory_percentage = int.parse (get_sysfs_value ("/sys/class/drm/card0/device/mem_busy_percent"));
    }

    private void update_percentage () {
        percentage = int.parse (get_sysfs_value ("/sys/class/drm/card0/device/gpu_busy_percent"));
    }

    public void update () {
        update_temperature ();
        update_memory_vram_used ();
        update_memory_percentage ();
        update_percentage ();
    }
}
