public class Monitor.HwmonPathsParserGPU: Object, IHwmonPathsParserInterface {

    public string name { get; protected set; }

    private Gee.HashMap<int, HwmonPathsTemperature> _paths_temperatures = new Gee.HashMap<int, HwmonPathsTemperature> ();
    public Gee.HashMap<string, HwmonPathsTemperature> paths_temperatures = new Gee.HashMap<string, HwmonPathsTemperature> ();

    private Gee.HashMap<int, HwmonPathsVoltage> _paths_voltages= new Gee.HashMap<int, HwmonPathsVoltage> ();
    public Gee.HashMap<string, HwmonPathsVoltage> paths_voltages = new Gee.HashMap<string, HwmonPathsVoltage> ();

    private Gee.HashMap<int, HwmonPathsFrequency> _paths_frequencies= new Gee.HashMap<int, HwmonPathsFrequency> ();
    public Gee.HashMap<string, HwmonPathsFrequency> paths_frequencies = new Gee.HashMap<string, HwmonPathsFrequency> ();

    public Gee.HashMap<int, HwmonPathsFan> paths_fans= new Gee.HashMap<int, HwmonPathsFan> ();

    public Gee.HashMap<int, HwmonPathsPWM> paths_pwms = new Gee.HashMap<int, HwmonPathsPWM> ();

    public Gee.HashMap<int, HwmonPathsPower> paths_powers = new Gee.HashMap<int, HwmonPathsPower> ();

    protected Gee.HashSet<string> all_paths { get; protected set; }

    construct {
        all_paths = new Gee.HashSet<string> ();
    }

    public void parse () {
        foreach (var path in all_paths) {
            var basename = Path.get_basename (path);
            if (basename.contains ("name")) {
                this.name = open_file (path);
            } else if (basename.contains ("temp")) {
                debug ("Found HWMON GPU temperature interface path: %s", basename);
                if (!_paths_temperatures.has_key (basename[4])) {
                    _paths_temperatures.set (basename[4], new HwmonPathsTemperature ());
                }

                if (basename.contains ("label")) {
                    _paths_temperatures.get (basename[4]).label = path;
                } else if (basename.contains ("input")) {
                    _paths_temperatures.get (basename[4]).input = path;
                } else if (basename.contains ("crit")) {
                    _paths_temperatures.get (basename[4]).crit = path;
                } else if (basename.contains ("crit_hyst")) {
                    _paths_temperatures.get (basename[4]).crit_hyst = path;
                } else if (basename.contains ("emergency")) {
                    _paths_temperatures.get (basename[4]).emergency = path;
                }

            } else if (basename.has_prefix ("in")) {
                debug ("Found HWMON GPU voltage interface path: %s", basename);
                if (!_paths_voltages.has_key (basename[2])) {
                    _paths_voltages.set (basename[2], new HwmonPathsVoltage ());
                }

                if (basename.contains ("label")) {
                    _paths_voltages.get (basename[2]).label = path;
                } else if (basename.contains ("input")) {
                    _paths_voltages.get (basename[2]).input = path;
                }
            }

            else if (basename.contains ("freq")) {
                debug ("Found HWMON GPU frequnecy interface path: %s", basename);
                if (!_paths_frequencies.has_key (basename[4])) {
                    _paths_frequencies.set (basename[4], new HwmonPathsFrequency ());
                }

                if (basename.contains ("label")) {
                    _paths_frequencies.get (basename[4]).label = path;
                } else if (basename.contains ("input")) {
                    _paths_frequencies.get (basename[4]).input = path;
                }
            }

            else if (basename.contains ("fan")) {
                debug ("Found HWMON GPU fan interface path: %s", basename);
                if (!paths_fans.has_key (basename[3])) {
                    paths_fans.set (basename[3], new HwmonPathsFan ());
                }

                if (basename.contains ("input")) {
                    paths_fans.get (basename[3]).input = path;
                } else if (basename.contains ("max")) {
                    paths_fans.get (basename[3]).max = path;
                } else if (basename.contains ("min")) {
                    paths_fans.get (basename[3]).min = path;
                } else if (basename.contains ("target")) {
                    paths_fans.get (basename[3]).target = path;
                } else if (basename.contains ("enable")) {
                    paths_fans.get (basename[3]).enable = path;
                }
            }

            else if (basename.contains ("pwm")) {
                debug ("Found HWMON GPU PWM interface path: %s", basename);
                if (!paths_pwms.has_key (basename[3])) {
                    paths_pwms.set (basename[3], new HwmonPathsPWM ());
                }

                if (basename == "pwm") {
                    paths_pwms.get (basename[3]).pwm = path;
                } else if (basename.contains ("max")) {
                    paths_pwms.get (basename[3]).max = path;
                } else if (basename.contains ("min")) {
                    paths_pwms.get (basename[3]).min = path;
                } else if (basename.contains ("enable")) {
                    paths_pwms.get (basename[3]).enable = path;
                }
            }

            // `power` is a dir
            else if (basename.contains ("power") && basename != "power") {
                debug ("Found HWMON GPU power interface path: %s", basename);
                if (!paths_powers.has_key (basename[5])) {
                    paths_powers.set (basename[5], new HwmonPathsPower ());
                }

                if (basename.contains ("average")) {
                    paths_powers.get (basename[5]).average = path;
                } else if (basename.contains ("cap_max")) {
                    paths_powers.get (basename[5]).cap_max = path;
                } else if (basename.contains ("cap_min")) {
                    paths_powers.get (basename[5]).cap_min = path;
                } else if (basename.has_suffix ("cap")) {
                    paths_powers.get (basename[5]).cap = path;
                }
            }
        }

        foreach (var paths_holder in _paths_temperatures.values) {
            paths_temperatures.set (paths_holder.label, paths_holder);
            debug ("🌡️ Parsed HWMON GPU temperature interface: %s", paths_holder.label);
        }

        foreach (var paths_holder in _paths_voltages.values) {
            paths_voltages.set (paths_holder.label, paths_holder);
            debug ("⚡ Parsed HWMON GPU voltage interface: %s", open_file (paths_holder.label));
        }

        foreach (var paths_holder in _paths_frequencies.values) {
            paths_frequencies.set (paths_holder.label, paths_holder);
            debug ("⏰ Parsed HWMON GPU frequency interface: %s", paths_holder.label);
        }

        debug ("💨 Parsed HWMON GPU fan interfaces: %d", paths_fans.size);
        debug ("✨ Parsed HWMON GPU PWM interfaces: %d", paths_pwms.size);
        debug ("💪 Parsed HWMON GPU power interfaces: %d", paths_powers.size);

    }
}
