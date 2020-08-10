public class Monitor.CPU : Object {
    private float last_used;
    private float last_total;
    private float load;

    public string? model_name;
    public string? model;
    public string? family;
    public string? microcode;
    public string? cache_size;
    public string? flags;
    public string? bogomips;
    public string? bugs;
    public string? address_sizes;

    GTop.Cpu ? cpu;

    public int percentage {
        get {
            return (int)(Math.round (load * 100));
        }
    }

    public Gee.ArrayList<Core> core_list;

    private double _frequency;
    public double frequency {
        get {
            // Convert kH to GHz
            return (double)(_frequency / 1000000);
        }
    }

    construct {
        last_used = 0;
        last_total = 0;

        core_list = new  Gee.ArrayList<Core> ();

        model_name = get_cpu_info ();

        parse_cpuinfo ();

        debug ("Number of cores: %d", (int) get_num_processors ());
        for (int i = 0; i < (int) get_num_processors (); i++) {
            var core = new Core(i);
            core_list.add (core);
        }
    }

    public void update () {
        update_percentage();
        update_frequency();

        foreach (var core in core_list) {
            core.update();
        }
    }

    private void update_percentage () {
        GTop.get_cpu (out cpu);

        var used = (float)(cpu.user + cpu.sys + cpu.nice + cpu.irq + cpu.softirq);
        var idle = (float)(cpu.idle + cpu.iowait);
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
        for (uint cpu_id = 0, isize = (int)get_num_processors (); cpu_id < isize; ++cpu_id) {
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

        _frequency = (double)maxcur;
    }

    private void parse_cpuinfo () {
        unowned GTop.SysInfo? info = GTop.glibtop_get_sysinfo ();

        if (info == null) {
            warning ("No CPU info");
            return;
        }

        // let core 0 represents whole processor
        // TODO: parse all the values to corresponding core objects in core_list
        // does it even makes sense??

        unowned GLib.HashTable<string, string> values = info.cpuinfo[0].values;
        model = values["model"];
        family = values["cpu family"];
        microcode = values["microcode"];
        cache_size = values["cache size"];
        flags = values["flags"];
        bogomips = values["bogomips"];
        bugs = values["bugs"];
        address_sizes = values["address sizes"];
    }

    // straight from elementary about-plug
    private string? get_cpu_info () {
        unowned GTop.SysInfo? info = GTop.glibtop_get_sysinfo ();

        if (info == null) {
            return null;
        }

        var counts = new Gee.HashMap<string, uint> ();
        const string[] KEYS = { "model name", "cpu", "Processor" };

        for (int i = 0; i < info.ncpu; i++) {
            unowned GLib.HashTable<string, string> values = info.cpuinfo[i].values;
            string? model = null;
            foreach (var key in KEYS) {
                model = values.lookup (key);

                if (model != null) {
                    break;
                }
            }

            string? core_count = values.lookup ("cpu cores");
            if (core_count != null) {
                counts.@set (model, int.parse (core_count));
                continue;
            }

            if (!counts.has_key (model)) {
                counts.@set (model, 1);
            } else {
                counts.@set (model, counts.@get (model) + 1);
            }
        }

        if (counts.size == 0) {
            return null;
        }

        string result = "";
        foreach (var cpu in counts.entries) {
            if (result.length > 0) {
                result += "\n";
            }

            if (cpu.@value == 2) {
                result += _("Dual-Core %s").printf ( (cpu.key));
            } else if (cpu.@value == 4) {
                result += _("Quad-Core %s").printf ( (cpu.key));
            } else if (cpu.@value == 6) {
                result += _("Hexa-Core %s").printf ( (cpu.key));
            } else {
                result += "%u\u00D7 %s ".printf (cpu.@value,  (cpu.key));
            }
        }

       return Utils.Strings.beautify (result);
    }
}
