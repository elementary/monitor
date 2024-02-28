public interface Monitor.IGPU : Object {
    public abstract SessionManager ? session_manager { get; public set; }

    public abstract Gee.HashMap<string, HwmonTemperature> hwmon_temperatures { get; set; }

    public abstract string hwmon_module_name { get; protected set; }

    public string name {
        owned get {
            return session_manager.renderer.split ("(", 2)[0];
        }
    }

    public abstract int percentage { get; protected set; }

    public abstract int memory_percentage { get; protected set; }

    public abstract double memory_vram_used { get; protected set; }

    public abstract double memory_vram_total { get; protected set; }

    public abstract double temperature { get; protected set; }

    public abstract void update_temperature ();

    public abstract void update_memory_vram_used ();

    public abstract void update_memory_vram_total ();

    public abstract void update_memory_percentage ();

    public abstract void update_percentage ();

    public abstract void update ();


    public virtual string get_sysfs_value (string path) {
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
