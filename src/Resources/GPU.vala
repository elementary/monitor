[DBus (name = "org.gnome.SessionManager")]
public interface SessionManager : Object {
    [DBus (name = "Renderer")]
    public abstract string renderer { owned get;}
}

public class Monitor.GPU : Object {
    private SessionManager? session_manager;

    public Gee.HashMap<string, HwmonTemperature> temperatures;

    public string hwmon_module_name;

    public string name {
        owned get {
            return session_manager.renderer.split ("(", 2)[0];
        }
    }

    public int percentage { get; private set; }

    public int memory_percentage { get; private set; }

    public int memory_vram_used { get; private set; }

    public double temperature { get; private set; }

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
        try {
            session_manager = Bus.get_proxy_sync (
                BusType.SESSION,
                "org.gnome.SessionManager",
                "/org/gnome/SessionManager"
            );
        } catch (IOError e) {
            warning (e.message);
        }

        debug (session_manager.renderer);

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

    private void update_temperature () {
        if (Resources.nv_card == false) {
            temperature = double.parse (temperatures.get ("edge").input) / 1000;
        } else {
            temperature = temp;
        }
    }

    private void update_memory_vram_used () {
        if (Resources.nv_card == false) {
            memory_vram_used = int.parse (get_sysfs_value ("/sys/class/drm/card0/device/mem_info_vram_used"));
        } else {
            memory_vram_used = u_mem;
        }
    }

    private void update_memory_percentage () {
        if (Resources.nv_card == false) {
            memory_percentage = int.parse (get_sysfs_value ("/sys/class/drm/card0/device/mem_busy_percent"));
        } else {
            memory_percentage = p_mem;
        }
    }

    private void update_percentage () {
        if (Resources.nv_card == false) {
            percentage = int.parse (get_sysfs_value ("/sys/class/drm/card0/device/gpu_busy_percent"));
        } else {
            percentage = p_gpu;
        }
    }

    public void update () {
        update_nv_resources ();
        update_temperature ();
        update_memory_vram_used ();
        update_memory_percentage ();
        update_percentage ();
    }


    private string get_sysfs_value (string path) {
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
