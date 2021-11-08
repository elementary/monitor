public class Monitor.HwmonNVMePathsParser : Object {

    public string name;

    private Gee.HashMap<int, HwmonPathsTemperature> _paths_temperatures = new Gee.HashMap<int, HwmonPathsTemperature> ();
    public Gee.HashMap<string, HwmonPathsTemperature> paths_temperatures = new Gee.HashMap<string, HwmonPathsTemperature> ();

    private Gee.HashSet<string> all_paths = new Gee.HashSet<string> ();

    construct {

    }

    public void parse () {
        foreach (var path in all_paths) {
            var basename = Path.get_basename (path);
            if (basename.contains ("name")) {
                this.name = basename;
            } else if (basename.contains ("temp")) {
                debug ("Found HWMON NVMe temperature interface path: %s", basename);
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
            paths_temperatures.set (open_file (paths_holder.label), paths_holder);
            debug ("🌡️ Parsed HWMON NVMe temperature interface: %s", open_file (paths_holder.label));
        }
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
