/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.CPU : Object {
    private float last_used;
    private float last_total;
    private float load;

    public string ? model_name;
    public string ? model;
    public string ? family;
    public string ? microcode;
    public string ? cache_size;
    public string ? bogomips;
    public Gee.HashMap<string, string> bugs = new Gee.HashMap<string, string> ();
    public Gee.HashMap<string, string> features = new Gee.HashMap<string, string> ();

    public string ? address_sizes;

    public Gee.HashMap<string, HwmonTemperature> temperatures;

    public Gee.HashMap<string, int> cache_multipliers = new Gee.HashMap<string, int> ();


    GTop.Cpu ? cpu;

    public int percentage {
        get {
            return (int) (Math.round (load * 100));
        }
    }

    public Gee.ArrayList<Core> core_list = new Gee.ArrayList<Core> ();

    private double _frequency;
    public double frequency {
        get {
            // Convert kHz to GHz
            return (double) (_frequency / 1000000);
        }
    }
    public double temperature_mean {
        get {
            double summed = 0;
            int number_of_temperatures = temperatures.size;
            if (number_of_temperatures == 0) return 0.0;
            foreach (var temperature in temperatures.values) {

                // checking if AMD Ryzen; in AMD Ryzen we only want Tdie
                if (temperature.label == "Tdie") return double.parse (temperature.input) / 1000;

                // for Intel we want only temperatures of cores
                if (temperature.label.contains ("Package")) {
                    number_of_temperatures--;
                    continue;
                }
                ;

                summed += double.parse (temperature.input) / 1000;
            }
            return summed / number_of_temperatures;
        }
    }

    construct {
        last_used = 0;
        last_total = 0;

        model_name = get_cpu_info ();

        parse_cpuinfo ();

        debug ("Number of cores: %d", (int) get_num_processors ());
        for (int i = 0; i < (int) get_num_processors (); i++) {
            var core = new Core (i);
            core_list.add (core);
        }


        // This will iterate through all the cores (not only physical) and will create 
        // a flat hashset of all the caches. Then we will count the caches that share 
        // the same cores (threads).
        // If You feel like this could be done in a better way, please let me know.
        var temp_caches = new Gee.HashMap<string, string> ();

        foreach (var core in core_list) {
            foreach (var cache in core.caches) {

                if (temp_caches.has_key (cache.key)) {
                    if (temp_caches.get (cache.key) == cache.value.shared_cpu_map) {
                        cache_multipliers.set (cache.key, cache_multipliers.get (cache.key) + 1);
                    }
                } else {
                    cache_multipliers.set (cache.key, 1);
                    temp_caches.set (cache.key, cache.value.shared_cpu_map);
                }
            }
        }

        foreach (var mult in cache_multipliers) {
            mult.value = core_list.size / mult.value;
        }
        temp_caches.clear ();
    }

    public void update () {
        update_percentage ();
        update_frequency ();

        foreach (var core in core_list) {
            core.update ();
        }
    }

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
        // using harmonic mean to calculate frequency values
        double inverse_sum = 0;
        double freq_value = 0 ;

        int core_total_number = (int) get_num_processors ();

        for (uint cpu_id = 0; cpu_id < core_total_number; ++cpu_id) {
            string cur_content;
            try {
                FileUtils.get_contents ("/sys/devices/system/cpu/cpu%u/cpufreq/scaling_cur_freq".printf (cpu_id), out cur_content);
            } catch (Error e) {
                warning (e.message);
                cur_content = "0";
            }
            freq_value = double.parse (cur_content);
            inverse_sum += 1 / freq_value;
        }
        _frequency = (double) core_total_number / inverse_sum ;
    }

    // private void get_cache () {
    // double maxcur = 0;
    // for (uint cpu_id = 0, isize = (int) get_num_processors (); cpu_id < isize; ++cpu_id) {
    // string cur_content;
    // try {
    // FileUtils.get_contents ("/sys/devices/system/cpu/cpu%u/cpufreq/scaling_cur_freq".printf (cpu_id), out cur_content);
    // } catch (Error e) {
    // warning (e.message);
    // cur_content = "0";
    // }

    // var cur = double.parse (cur_content);

    // if (cpu_id == 0) {
    // maxcur = cur;
    // } else {
    // maxcur = double.max (cur, maxcur);
    // }
    // }

    // _frequency = (double) maxcur;
    // }

    private void parse_cpuinfo () {
        unowned GTop.SysInfo ? info = GTop.glibtop_get_sysinfo ();

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
        parse_flags (values["flags"], features, DBDIR + "/cpu_features.csv");
        bogomips = values["bogomips"];
        parse_flags (values["bugs"], bugs, DBDIR + "/cpu_bugs.csv");
        address_sizes = values["address sizes"];

        // values.foreach ((key, value) => {
        // debug("%s: %s\n", key, value);
        // });
    }

    private void parse_flags (string _flags, Gee.HashMap<string, string> flags, string path) {
        File csv_file = File.new_for_path (path);
        DataInputStream dis;
        var all_flags = new Gee.HashMap<string, string> ();
        if (!csv_file.query_exists ()) {
            warning ("File %s does not exist", csv_file.get_path ());
        } else {
            try {
                dis = new DataInputStream (csv_file.read ());
                string flag_data;
                while ((flag_data = dis.read_line ()) != null) {

                    int comma_position = flag_data.index_of_char (',');
                    
                    if (comma_position == -1) break; // quick exit if no commas are in the line

                    string key = flag_data.substring (0, comma_position);
                    string value = flag_data.substring (comma_position + 1)
                        .replace ("\"", "")
                        .replace ("  ", " ")
                        .strip ();
                    
                    all_flags.set (key, value.replace ("\r", ""));
                }
                debug ("Parsed file %s", csv_file.get_path ());

            } catch (Error e) {
                warning (e.message);
            }
        }

        foreach (string flag in _flags.split (" ")) {
            if (all_flags.has_key (flag)) {
                flags.set (flag, all_flags.get (flag));
            } else {
                flags.set (flag, Utils.NOT_AVAILABLE);
            }
        }
    }

    // straight from elementary about-plug
    private string ? get_cpu_info () {
        unowned GTop.SysInfo ? info = GTop.glibtop_get_sysinfo ();

        if (info == null) {
            return null;
        }

        var counts = new Gee.HashMap<string, uint> ();
        const string[] KEYS = { "model name", "cpu", "Processor" };

        for (int i = 0; i < info.ncpu; i++) {
            unowned GLib.HashTable<string, string> values = info.cpuinfo[i].values;
            string ? model = null;
            foreach (var key in KEYS) {
                model = values.lookup (key);

                if (model != null) {
                    break;
                }
            }

            string ? core_count = values.lookup ("cpu cores");
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
                result += _("Dual-Core %s").printf ((cpu.key));
            } else if (cpu.@value == 4) {
                result += _("Quad-Core %s").printf ((cpu.key));
            } else if (cpu.@value == 6) {
                result += _("Hexa-Core %s").printf ((cpu.key));
            } else {
                result += "%u\u00D7 %s ".printf (cpu.@value, (cpu.key));
            }
        }

        return Utils.Strings.beautify (result);
    }
}
