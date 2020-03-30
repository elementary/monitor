    public class Monitor.CPU : Object {
        private float last_used;
        private float last_total;
        private float load;

        GTop.Cpu? cpu;

        public int percentage {
            get {
                update_percentage ();
                return (int) (Math.round(load * 100));
            }
        }

        private double _frequency;
        public double frequency {
            get {
                update_frequency ();
                // Convert kH to GHz
                return (double) (_frequency / 1000000);
            }
        }

        construct {
            last_used = 0;
            last_total = 0;
        }

        public CPU () { }

        private void update_percentage () {
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

        // From https://github.com/PlugaruT/wingpanel-monitor/blob/edcfea6a31f794aa44da6d8b997378ea1a8d8fa3/src/Services/Cpu.vala#L61-L85
        private void update_frequency () {
            double maxcur = 0;
            for (uint cpu_id = 0, isize = (int) get_num_processors (); cpu_id < isize; ++cpu_id) {
                string cur_content;
                try {
                    FileUtils.get_contents ("/sys/devices/system/cpu/cpu%u/cpufreq/scaling_cur_freq".printf (cpu_id), out cur_content);
                } catch (Error e) {
                    warning (e.message);
                    cur_content = "0";
                }
    
                var cur = double.parse (cur_content);
    
                if (cpu_id == 0) {
                    maxcur = cur;
                } else {
                    maxcur = double.max (cur, maxcur);
                }
            }

            _frequency = (double) maxcur;
        }
    }
