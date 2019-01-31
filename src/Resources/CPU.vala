    public class Monitor.CPU : Object {
        private float last_used;
        private float last_total;
        private float load;

        GTop.Cpu? cpu;

        public int percentage {
            get {
                update ();
                return (int) (Math.round(load * 100));
            }
        }
        construct {
            last_used = 0;
            last_total = 0;
        }

        public CPU () { }

        private void update () {
            GTop.get_cpu (out cpu);

            var used = (float) (cpu.user + cpu.sys + cpu.nice + cpu.irq + cpu.softirq);
            var idle = (float) (cpu.idle + cpu.iowait);
            var total = used + idle;

            var diff_used = used - last_used;
            var diff_total = total - last_total;

            load = diff_used.abs () / diff_total.abs ();

            last_used = used;
            last_total = total;
        }
    }
