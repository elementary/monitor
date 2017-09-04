
namespace elementarySystemMonitor {

    public class Resources {
        // CPU usage info
        long total_cpu = 0;
        long idle_cpu = 0;
        public float total_memory;
        public float used_memory;

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
                
    			var newTotalCPU = cpu.total;
    			var newIdleCPU = cpu.idle;

    			var total_cpu_diff = (total_cpu - (long)cpu.total).abs();
    			var idle_cpu_diff  = (idle_cpu  - (long)cpu.idle).abs();

    			var percentage = cpu.frequency - (idle_cpu_diff * 100 / total_cpu_diff);

    			total_cpu = (long)newTotalCPU;
                idle_cpu = (long)newIdleCPU;

                return (int) (Math.round(percentage));
        }
    }
}