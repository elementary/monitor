public class Monitor.Resources : Object {
    public CPU cpu;
    public Memory memory;
    public Swap swap;
    public Network network;

    construct {
        memory = new Memory ();
        cpu = new CPU ();
        swap = new Swap ();
        network = new Network ();
    }

    public void update() {
        cpu.update();
        memory.update();
    }
    public ResourcesSerialized serialize () {
        return ResourcesSerialized () {
            cpu_percentage = cpu.percentage,
            cpu_frequency = cpu.frequency,
            memory_percentage = memory.percentage,
            memory_used = memory.used,
            memory_total = memory.total,
            swap_percentage = swap.percentage,
            swap_used = swap.used,
            swap_total = swap.total
        };
    }

}