
namespace Monitor {

    public class Resources {
        // CPU usage info
        long total_cpu = 0;
        long idle_cpu = 0;
        public float total_memory;
        public float used_memory;

        private double cpu_load;
        private double[] x_cpu_load;
        private float last_used = 0;
        private float last_total = 0;
        private long cpu_last_used = 0;
        private long cpu_last_total = 0;
        private uint64 cpu_last_total_step = 0;

        public Resources () { }

        public int get_memory_usage () {
            GTop.Memory memory;
    		GTop.get_mem (out memory);

    		total_memory = (float) (memory.total / 1024 / 1024) / 1000;
            used_memory = (float) (memory.user / 1024 / 1024) / 1000;

            return (int) (Math.round((used_memory / total_memory) * 100));
        }

        public int get_cpu_usage () {

            // CPU
    			GTop.Cpu cpu;
                GTop.get_cpu (out cpu);

    			var used = (float) (cpu.user + cpu.sys + cpu.nice + cpu.irq + cpu.softirq);
    			var idle = (float) (cpu.idle + cpu.iowait);
                var total = used + idle;

                var diff_used = used - last_used;
                var diff_total = total - last_total;

                var load = diff_used.abs () / diff_total.abs ();

                last_used = used;
                last_total = total;

                return (int) (Math.round(load * 100));
        }
    }
}
