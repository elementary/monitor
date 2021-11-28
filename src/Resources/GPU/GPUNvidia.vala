public class Monitor.GPUNvidia : IGPU, Object {
    public SessionManager? session_manager { get; protected set; }

    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public string hwmon_module_name { get; set; }

    public int percentage { get; protected set; }

    public int memory_percentage { get; protected set; }

    public int memory_vram_used { get; protected set; }

    public double temperature { get; protected set; }

    public int nvidia_temperature = 0;

    public int nvidia_memory_vram_used = 0;

    public int nvidia_memory_percentage = 0;

    public int nvidia_percentage = 0;

    public char *nvidia_used = "";

    public bool nvidia_resources_temperature;

    public bool nvidia_resources_vram_used;

    public bool nvidia_resources_used;

    public X.Display nvidia_display;

    construct {
        session_manager = get_sessman ();
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
            stdout.printf ("Could not query NV_CTRL_GPU_CORE_TEMPERATURE attribute!\n");
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
            stdout.printf ("Could not query NV_CTRL_USED_DEDICATED_GPU_MEMORY attribute!\n");
            return ;
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
        nvidia_percentage = int.parse (((string)nvidia_used).split_set("=,")[1]);
        nvidia_memory_percentage = int.parse (((string)nvidia_used).split_set("=,")[3]);
        debug ("USED_GRAPHICS: %d%\n", nvidia_percentage);
        debug ("USED_MEMORY: %d%\n", nvidia_memory_percentage);

        if (!nvidia_resources_used) {
            stdout.printf ("Could not query NV_CTRL_STRING_GPU_UTILIZATION attribute!\n");
            return ;
        }

    }

    private void update_temperature () { temperature = nvidia_temperature; }

    private void update_memory_vram_used () { memory_vram_used = nvidia_memory_vram_used; }

    private void update_memory_percentage () { memory_percentage = nvidia_memory_percentage; }

    private void update_percentage () { percentage = nvidia_percentage; }

    public void update () {
        update_nv_resources ();
        update_temperature ();
        update_memory_vram_used ();
        update_memory_percentage ();
        update_percentage ();
    }
}
