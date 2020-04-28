namespace Monitor {

    public class Updater : Object {
        private static GLib.Once<Updater> instance;
        public static unowned Updater get_default () {
            return instance.once (() => { return new Updater (); });
        }

        private int interval = 2; // in secs

        private CPU cpu;
        private Memory memory;
        private Swap swap;
        private Utils.SystemResources sysres;

        public signal void update (Utils.SystemResources sysres);

        construct {
            memory = new Memory ();
            cpu = new CPU ();
            swap = new Swap ();

            Timeout.add_seconds (interval, update_resources);
        }

        private bool update_resources () {
            sysres = Utils.SystemResources () {
                cpu_percentage = cpu.percentage,
                cpu_frequency = cpu.frequency,
                memory_percentage = memory.percentage,
                memory_used = memory.used,
                memory_total = memory.total,
                swap_percentage = swap.percentage,
                swap_used = swap.used,
                swap_total = swap.total
            };
            update (sysres);
            return true;
        }
    }
}
