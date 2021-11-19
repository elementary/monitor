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

    public int percentage;

    public int memory_percentage;

    public int memory_vram_used;

    public double temperature;

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
    }

    private void update_temperature () {
        temperature = double.parse (temperatures.get ("edge").input) / 1000;
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
