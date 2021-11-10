public class Monitor.HwmonPathsParserIwlwifi : Object, IHwmonPathsParserInterface {

    public string name { get; protected set; }

    private Gee.HashMap<int, HwmonPathsTemperature> _paths_temperatures = new Gee.HashMap<int, HwmonPathsTemperature> ();
    public Gee.HashMap<string, HwmonPathsTemperature> paths_temperatures = new Gee.HashMap<string, HwmonPathsTemperature> ();

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
                debug ("Found HWMON iwlwifi temperature interface path: %s", basename);
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
                } else if (basename.contains ("max")) {
                    _paths_temperatures.get (basename[4]).max = path;
                } else if (basename.contains ("min")) {
                    _paths_temperatures.get (basename[4]).min = path;
                }
            }
        }

        foreach (var paths_holder in _paths_temperatures.values) {
            if (paths_holder.label != null) {
                this.paths_temperatures.set (paths_holder.label, paths_holder);
                debug ("🌡️ Parsed HWMON iwlwifi temperature interface: %s", open_file (paths_holder.label));

            } else {
                // let's just hope that there is always one temp_input per iwlwifi
                paths_temperatures.set (this.name, paths_holder);
                debug ("🌡️ Parsed HWMON iwlwifi temperature interface: %s", this.name);
            }
        }
    }
}
