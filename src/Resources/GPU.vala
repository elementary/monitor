[DBus (name = "org.gnome.SessionManager")]
public interface SessionManager : Object {
    [DBus (name = "Renderer")]
    public abstract string renderer { owned get;}
}

public class Monitor.GPU : Object {
    private SessionManager? session_manager;

    public Gee.HashMap<string, PathsTemperature> paths_temperatures;

    public string name {
        owned get {
            return session_manager.renderer.split ("(", 2)[0];
        }
    }

    public int percentage {
        get {
            return int.parse (get_sysfs_value ("/sys/class/drm/card0/device/gpu_busy_percent"));
        }
    }

    public int memory_percentage {
        get {
            return int.parse (get_sysfs_value ("/sys/class/drm/card0/device/mem_busy_percent"));
        }
    }

    public int memory_vram_used {
        get {
            return int.parse (get_sysfs_value ("/sys/class/drm/card0/device/mem_info_vram_used"));
        }
    }

    public double temperature {
        get {
            return int.parse (get_sysfs_value (paths_temperatures.get ("edge").input)) / 1000;
        }
    }

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
