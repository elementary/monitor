public class Monitor.GPUNvidia : IGPU, Object {
    public SessionManager? session_manager { get; protected set; }

    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public string hwmon_module_name { get; set; }

    public int percentage { get; protected set; }

    public int memory_percentage { get; protected set; }

    public int memory_vram_used { get; protected set; }

    public double temperature { get; protected set; }

    construct {
        session_manager = get_sessman ();
    }

    private void update_temperature () { }

    private void update_memory_vram_used () { }

    private void update_memory_percentage () { }

    private void update_percentage () { }

    public void update () {
        update_temperature ();
        update_memory_vram_used ();
        update_memory_percentage ();
        update_percentage ();
    }
}
