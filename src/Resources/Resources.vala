public class Monitor.Resources : Object {
    public CPU cpu;
    public Memory memory;
    public Swap swap;
    public Network network;
    public Storage storage;
    public IGPU gpu;
    public int nvidia_info = 0;
    public bool nvidia_resources;
    public int vendor_id;
    // public int dev_id;
    public X.Display nvidia_display;

    private HwmonPathParser hwmon_path_parser;

    construct {
        hwmon_path_parser = new HwmonPathParser ();

        memory = new Memory ();
        cpu = new CPU ();
        swap = new Swap ();
        network = new Network ();
        storage = new Storage ();
        nvidia_display = new X.Display ();

        nvidia_resources = NVCtrl.XNVCTRLQueryTargetAttribute (
            nvidia_display,
            NV_CTRL_TARGET_TYPE_GPU,
            0,
            0,
            NV_CTRL_PCI_ID,
            &nvidia_info
        );

        if (!nvidia_resources) {
            stdout.printf ("Could not query NV_CTRL_PCI_ID attribute!\n");
            return ;
        }

        vendor_id = nvidia_info >> 16;
        // dev_id = nvidia_info&0xFFFF;
        debug ("VENDOR_ID: %d\n", vendor_id);
        // debug ("DEVICE_ID: %d\n", dev_id);

        cpu.temperatures = hwmon_path_parser.cpu_paths_parser.temperatures;

        if (hwmon_path_parser.gpu_paths_parser.name == "amdgpu") {
            gpu = new GPUAmd ();
            gpu.hwmon_temperatures = hwmon_path_parser.gpu_paths_parser.temperatures;
        }

        if (vendor_id == 4318) {
            gpu = new GPUNvidia ();
        }

        update ();
    }

    public void update () {
        Timeout.add_seconds (2, () => {
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

    public ResourcesSerialized serialize () {
        return ResourcesSerialized () {
                   cpu_percentage = cpu.percentage,
                   cpu_frequency = cpu.frequency,
                   cpu_temperature = cpu.temperature_mean,
                   memory_percentage = memory.percentage,
                   memory_used = memory.used,
                   memory_total = memory.total,
                   swap_percentage = swap.percentage,
                   swap_used = swap.used,
                   swap_total = swap.total,
                   network_up = network.bytes_out,
                   network_down = network.bytes_in
        };
    }
}
