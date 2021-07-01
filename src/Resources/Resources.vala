public class Monitor.Resources : Object {
    public CPU cpu;
    public Memory memory;
    public Swap swap;
    public Network network;
    public Storage storage;

    construct {
        memory = new Memory ();
        cpu = new CPU ();
        swap = new Swap ();
        network = new Network ();
        storage = new Storage ();
        storage.init ();

        if (!storage.init ()) {
            //
        } else {
            storage.get_drives ().foreach (add_drive);
        }
    }

    private bool add_drive (owned DiskDrive? drive) {
        debug(drive.model);
        return true;
    }

    public void update () {
        cpu.update ();
        memory.update ();
        network.update ();
        //  storage.update ();
    }

    public ResourcesSerialized serialize () {
        return ResourcesSerialized () {
                   cpu_percentage = cpu.percentage,
                   cpu_frequency = cpu.frequency,
                   cpu_temperature = cpu.temperature,
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
