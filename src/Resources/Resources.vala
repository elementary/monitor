[DBus (name = "org.gnome.SessionManager")]
public interface SessionManager : Object {
    [DBus (name = "Renderer")]
    public abstract string renderer { owned get;}
}

public class Monitor.Resources : Object {
    public CPU cpu;
    public Memory memory;
    public Swap swap;
    public Network network;
    public Storage storage;
    public IGPU gpu;
    public UDevGPUInfo gpuinfo;
    private HwmonPathParser hwmon_path_parser;
    // public string? gpu_model;
    // public string? gpu_name;
    construct {
        hwmon_path_parser = new HwmonPathParser ();

        memory = new Memory ();
        cpu = new CPU ();
        swap = new Swap ();
        network = new Network ();
        storage = new Storage ();
        gpuinfo = new UDevGPUInfo ();

        SessionManager session_manager = get_sessman ();
        string? gpu_name = session_manager.renderer;

        if (gpu_name == ""){
            gpu_name = gpuinfo.get_driver_name();
        }


/*        const string[] subsystems = { "pci" };
        var client = new GUdev.Client(subsystems); 
        var enumerator = new GUdev.Enumerator(client);
        var devices = enumerator.execute();

        foreach (var device in devices) {
            if (device.get_property("DRIVER") == "nvidia") {
                // stdout.printf("  Vendor: %s\n", device.get_property("ID_VENDOR_FROM_DATABASE"));
                // stdout.printf("  Model: %s\n", device.get_property("ID_MODEL_FROM_DATABASE"));
                // stdout.printf("  Driver: %s\n", device.get_property("DRIVER"));
                gpu_name = "nvidia";
                gpu_model = device.get_property("ID_MODEL_FROM_DATABASE");
                debug ("GPU: %s", gpu_model);
            }
        } */       

        if (gpu_name.contains ("intel")) {

        } else if (gpu_name.contains ("nvidia") || gpu_name.contains ("geforce")) {
            gpu = new GPUNvidia ();
            gpu.session_manager = session_manager;
        } else if (gpu_name.contains ("amd")) {
            gpu = new GPUAmd ();
            gpu.session_manager = session_manager;
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
            //debug ("GPU: %s", session_manager.renderer);
            return session_manager;

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
                   gpu_percentage = gpu != null ? gpu.percentage : 0
        };
    }
}
