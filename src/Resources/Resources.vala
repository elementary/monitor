public class Monitor.Resources : Object {
    public CPU cpu;
    public Memory memory;
    public Swap swap;
    public Network network;
    public Storage storage;
    public GPU gpu;

    private HwmonPathParser hwmon_path_parser;

    construct {
        hwmon_path_parser = new HwmonPathParser ();

        memory = new Memory ();
        cpu = new CPU ();
        swap = new Swap ();
        network = new Network ();
        storage = new Storage ();

        cpu.temperatures = hwmon_path_parser.cpu_paths_parser.temperatures;

        if (hwmon_path_parser.gpu_paths_parser.name == "amdgpu") {
            gpu = new GPU ();
            gpu.temperatures = hwmon_path_parser.gpu_paths_parser.temperatures;
        }

    }

    public void update () {
        cpu.update ();
        memory.update ();
        network.update ();
        storage.update ();
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
