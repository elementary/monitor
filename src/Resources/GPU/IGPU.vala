[DBus (name = "org.gnome.SessionManager")]
public interface SessionManager : Object {
    [DBus (name = "Renderer")]
    public abstract string renderer { owned get;}
}

public interface Monitor.IGPU : Object {
    public abstract SessionManager? session_manager { get; protected set; }

    public abstract Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public abstract string hwmon_module_name { get; protected set; }

    public string name {
        owned get {
            return session_manager.renderer.split ("(", 2)[0];
        }
    }

    public abstract int percentage { get; protected set; }

    public abstract int memory_percentage { get; protected set; }

    public abstract int memory_vram_used { get; protected set; }

    public abstract double temperature { get; protected set; }

    // error: internal: Redefinition of `monitor_igpu_get_session_manager'
    // so renamed to sessman; if anyone knows why it's happening, please
    // feel free to send a PR to fix it
    public virtual SessionManager? get_sessman () {
        try {
            SessionManager session_manager = Bus.get_proxy_sync (
                BusType.SESSION,
                "org.gnome.SessionManager",
                "/org/gnome/SessionManager"
            );
            return session_manager;

        } catch (IOError e) {
            warning (e.message);
            debug (session_manager.renderer);
            return null;
        }
    }

    public abstract void update_temperature ();

    public abstract void update_memory_vram_used ();

    public abstract void update_memory_percentage ();

    public abstract void update_percentage ();

    public abstract void update ();


    public virtual  string get_sysfs_value (string path) {
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
