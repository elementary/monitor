[DBus (name = "org.gnome.SessionManager")]
public interface SessionManager : Object {
    [DBus (name = "Renderer")]
    public abstract string renderer { owned get;}
}

[DBus (name = "net.hadess.SwitcherooControl")]
public interface SwitcherooControl : Object {
    [DBus (name = "HasDualGpu")]
    public abstract bool has_dual_gpu { owned get; }

    [DBus (name = "GPUs")]
    public abstract HashTable<string, Variant>[] gpus { owned get; }

    public string default_gpu_name {
        owned get {
            string gpu_name = "";

            foreach (unowned HashTable<string, Variant> gpu in gpus) {
                bool is_default = gpu.get ("Default").get_boolean ();
                if (!is_default) continue;

                gpu_name = gpu.get ("Name").get_string ();
            }

            return gpu_name;
        }
    }
}

public class Monitor.Resources : Object {
    public CPU cpu;
    public Memory memory;
    public Swap swap;
    public Network network;
    public Storage storage;
    public IGPU gpu;
    private HwmonPathParser hwmon_path_parser;

    construct {
        hwmon_path_parser = new HwmonPathParser ();

        memory = new Memory ();
        cpu = new CPU ();
        swap = new Swap ();
        network = new Network ();
        storage = new Storage ();

        string gpu_name;

        SessionManager session_manager = get_sessman ();
        SwitcherooControl switcheroo_control = get_switcherooctl ();
        if (session_manager != null) {
            gpu_name = session_manager.renderer.down ();
        } else {
            gpu_name = switcheroo_control.default_gpu_name.down ();
        }

        if (gpu_name.contains ("intel")) {

        } else if (gpu_name.contains ("nvidia") || gpu_name.contains ("geforce")) {
            gpu = new GPUNvidia ();
            gpu.session_manager = session_manager;
            gpu.switcheroo_control = switcheroo_control;
        } else if (gpu_name.contains ("amd")) {
            gpu = new GPUAmd ();
            gpu.session_manager = session_manager;
            gpu.switcheroo_control = switcheroo_control;
            gpu.hwmon_temperatures = hwmon_path_parser.gpu_paths_parser.temperatures;
        } else {
            warning ("GPU: Unknown: %s", gpu_name);
        }

        cpu.temperatures = hwmon_path_parser.cpu_paths_parser.temperatures;

        update ();
    }

    public void update () {
        Timeout.add_seconds (MonitorApp.settings.get_int ("update-time"), () => {
            new Thread<void> ("update-resources", () => {
                    cpu.update ();
                    memory.update ();
                    network.update ();
                    storage.update ();
                    if (gpu != null) gpu.update ();

            });
            return true;
        });
    }

    public SessionManager? get_sessman () {
        try {
            SessionManager session_manager = Bus.get_proxy_sync (
                BusType.SESSION,
                "org.gnome.SessionManager",
                "/org/gnome/SessionManager"
            );
            debug ("GPU: %s", session_manager.renderer);
            return session_manager.renderer != "" ? session_manager : null;

        } catch (IOError e) {
            warning (e.message);
            return null;
        }
    }

    public SwitcherooControl? get_switcherooctl () {
        try {
            SwitcherooControl switcheroo_control = Bus.get_proxy_sync (
                BusType.SYSTEM,
                "net.hadess.SwitcherooControl",
                "/net/hadess/SwitcherooControl"
            );
            debug ("GPU: %s", switcheroo_control.default_gpu_name);
            return switcheroo_control;

        } catch (IOError e) {
            warning (e.message);
            return null;
        }
    }

    public ResourcesSerialized serialize () {
        return ResourcesSerialized () {
            cpu_percentage = cpu.percentage,
            cpu_frequency = cpu.frequency,
            cpu_temperature = cpu.temperature_mean,
            memory_percentage = memory.used_percentage,
            memory_used = memory.used,
            memory_total = memory.total,
            swap_percentage = swap.percentage,
            swap_used = swap.used,
            swap_total = swap.total,
            network_up = network.bytes_out,
            network_down = network.bytes_in,
            gpu_percentage = gpu != null ? gpu.percentage : 0,
            gpu_memory_percentage = gpu != null ? gpu.memory_percentage : 0,
            gpu_memory_used = gpu != null ? gpu.memory_vram_used : 0,
            gpu_memory_total = gpu != null ? gpu.memory_vram_total : 0,
            gpu_temperature = gpu != null ? gpu.temperature : 0
        };
    }
}
