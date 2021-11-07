public class Monitor.GPUPathsParser : Object {

    public string name;

    private Gee.HashMap<int, PathsTemperature> _paths_temperatures = new Gee.HashMap<int, PathsTemperature> ();
    public Gee.HashMap<string, PathsTemperature> paths_temperatures = new Gee.HashMap<string, PathsTemperature> ();

    private Gee.HashMap<int, PathsVoltage> _paths_voltages= new Gee.HashMap<int, PathsVoltage> ();
    public Gee.HashMap<string, PathsVoltage> paths_voltages = new Gee.HashMap<string, PathsVoltage> ();

    private Gee.HashMap<int, PathsFrequency> _paths_frequencies= new Gee.HashMap<int, PathsFrequency> ();
    public Gee.HashMap<string, PathsFrequency> paths_frequencies = new Gee.HashMap<string, PathsFrequency> ();

    public Gee.HashMap<int, PathsFan> paths_fans= new Gee.HashMap<int, PathsFan> ();

    public Gee.HashMap<int, PathsPWM> paths_pwms = new Gee.HashMap<int, PathsPWM> ();

    public Gee.HashMap<int, PathsPower> paths_powers = new Gee.HashMap<int, PathsPower> ();

    private Gee.HashSet<string> all_paths = new Gee.HashSet<string> ();

    construct {

    }

    public void parse () {
        foreach (var path in all_paths) {
            var basename = Path.get_basename (path);
            if (basename.contains ("name")) {
                this.name = basename;
            } else if (basename.contains ("temp")) {
                debug ("Found GPU temperature interface path: %s", basename);
                if (!_paths_temperatures.has_key (basename[4])) {
                    _paths_temperatures.set (basename[4], new PathsTemperature ());
                    //  debug ("- Created struct");
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
                debug ("Found GPU voltage interface path: %s", basename);
                if (!_paths_voltages.has_key (basename[2])) {
                    _paths_voltages.set (basename[2], new PathsVoltage ());
                }

                if (basename.contains ("label")) {
                    _paths_voltages.get (basename[2]).label = path;
                } else if (basename.contains ("input")) {
                    _paths_voltages.get (basename[2]).input = path;
                }
            }

            else if (basename.contains ("freq")) {
                debug ("Found GPU frequnecy interface path: %s", basename);
                if (!_paths_frequencies.has_key (basename[4])) {
                    _paths_frequencies.set (basename[4], new PathsFrequency ());
                }

                if (basename.contains ("label")) {
                    _paths_frequencies.get (basename[4]).label = path;
                } else if (basename.contains ("input")) {
                    _paths_frequencies.get (basename[4]).input = path;
                }
            }

            else if (basename.contains ("fan")) {
                debug ("Found GPU fan interface path: %s", basename);
                if (!paths_fans.has_key (basename[3])) {
                    paths_fans.set (basename[3], new PathsFan ());
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
                debug ("Found GPU PWM interface path: %s", basename);
                if (!paths_pwms.has_key (basename[3])) {
                    paths_pwms.set (basename[3], new PathsPWM ());
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
                debug ("Found GPU power interface path: %s", basename);
                if (!paths_powers.has_key (basename[5])) {
                    paths_powers.set (basename[5], new PathsPower());
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
            paths_temperatures.set (open_file (paths_holder.label), paths_holder);
            debug ("🌡️ Parsed GPU temperature interface: %s", open_file (paths_holder.label));
        }

        foreach (var paths_holder in _paths_voltages.values) {
            paths_voltages.set (open_file (paths_holder.label), paths_holder);
            debug ("⚡ Parsed GPU voltage interface: %s", open_file (paths_holder.label));
        }

        foreach (var paths_holder in _paths_frequencies.values) {
            paths_frequencies.set (open_file (paths_holder.label), paths_holder);
            debug ("⏰ Parsed GPU frequency interface: %s", open_file (paths_holder.label));
        }

        debug ("💨 Parsed GPU fan interfaces: %d", paths_fans.size);
        debug ("✨ Parsed GPU PWM interfaces: %d", paths_pwms.size);
        debug ("💪 Parsed GPU power interfaces: %d", paths_powers.size);

    }

    public void add_path (string path) {
        all_paths.add (path);
    }

    private string open_file (string filename) {
        try {
            string read;
            FileUtils.get_contents (filename, out read);
            return read.replace ("\n", "");
        } catch (FileError e) {
            warning ("%s", e.message);
            return "";
        }
    }
}
