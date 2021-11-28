public class Monitor.GPUNvidia : IGPU, Object {
    public SessionManager? session_manager { get; protected set; }

    public Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public string hwmon_module_name { get; set; }

    public int percentage { get; protected set; }

    public int memory_percentage { get; protected set; }

    public int memory_vram_used { get; protected set; }

    public double temperature { get; protected set; }

    public int temp = 0;

    public int u_mem = 0;

    public int p_mem = 0;

    public int p_gpu = 0;

    public bool res;

    public bool res1;

    public bool res2;

    public bool res3;

    public char *used = "";

    public X.Display nvidia_display;

    construct {
        session_manager = get_sessman ();
        nvidia_display = new X.Display ();
    }

    private void update_nv_resources () {
        res = NVCtrl.XNVCTRLQueryAttribute(
            nvidia_display,
            0,
            0,
            NV_CTRL_GPU_CORE_TEMPERATURE,
            &temp
        );

        if(!res) {
            stdout.printf("Could not query NV_CTRL_GPU_CORE_TEMPERATURE attribute!\n");
            return;
        }

        res1 = NVCtrl.XNVCTRLQueryTargetAttribute(
            nvidia_display,
            NV_CTRL_TARGET_TYPE_GPU,
            0,
            0,
            NV_CTRL_USED_DEDICATED_GPU_MEMORY,
            &u_mem
        );

        if(!res1) {
            stdout.printf("Could not query NV_CTRL_USED_DEDICATED_GPU_MEMORY attribute!\n");
            return ;
        }

        res3 = NVCtrl.XNVCTRLQueryTargetStringAttribute(
            nvidia_display,
            NV_CTRL_TARGET_TYPE_GPU,
            0,
            0,
            NV_CTRL_STRING_GPU_UTILIZATION,
            &used
        );

        var str_used = (string)used;
        p_gpu = int.parse(str_used.split_set("=,")[1]);
        p_mem = int.parse(str_used.split_set("=,")[3]);
        debug("USED_GRAPHICS: %d%\n", p_gpu);
        debug("USED_MEMORY: %d%\n", p_mem);

        if(!res3) {
            stdout.printf("Could not query NV_CTRL_STRING_GPU_UTILIZATION attribute!\n");
            return ;
        }

    }

    private void update_temperature () { temperature = temp; }

    private void update_memory_vram_used () { memory_vram_used = u_mem; }

    private void update_memory_percentage () { memory_percentage = p_mem; }

    private void update_percentage () { percentage = p_gpu; }

    public void update () {
        update_nv_resources ();
        update_temperature ();
        update_memory_vram_used ();
        update_memory_percentage ();
        update_percentage ();
    }
}
