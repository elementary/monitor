class TemperatureSensor : Object {
    private const string HWMON_PATH = "/sys/class/hwmon";

    // contains list of paths to files with a temperature values
    // Intel reports per core temperature, while AMD Ryzen Tdie
    public Gee.ArrayList<string ? > cpu_temp_paths;

    public double cpu {
        get {
            double total_temperature = 0;
            // this should handle null
            foreach (var path in cpu_temp_paths) {
                total_temperature += double.parse (open_file (path));
            }
            return total_temperature / cpu_temp_paths.size;
        }
    }

    private string path_hwmon_amdgpu;
    public double gpu {
        get {
            return double.parse (open_file (HWMON_PATH + "/hwmon0/temp1_input"));
        }
    }

    construct {
        cpu_temp_paths = new Gee.ArrayList<string> ();
        detect_sensors ();
    }

    public TemperatureSensor () {
    }

    private void detect_sensors () {
        try {
            Dir hwmon_dir = Dir.open (HWMON_PATH, 0);

            string ? hwmonx = null;
            while ((hwmonx = hwmon_dir.read_name ()) != null) {
                string hwmonx_name = Path.build_filename (HWMON_PATH, hwmonx, "name");

                string sensor_name = open_file (hwmonx_name);

                // thank u, next
                if (sensor_name == "") continue;

                if (sensor_name == "coretemp" || sensor_name == "k10temp") {
                    debug ("Found temp. sensor: %s", sensor_name);

                    Dir hwmonx_dir = Dir.open (Path.build_filename (HWMON_PATH, hwmonx), 0);
                    string ? hwmonx_prop = null;
                    while ((hwmonx_prop = hwmonx_dir.read_name ()) != null) {
                        // debug (open_file (hwmonx_name));

                        if (hwmonx_prop.contains ("temp")) {
                            // AMD stuff
                            // Tdie contains true temperature value, while Tctl contains value for fans
                            // Tctl = Tdie + offset in some processors
                            if ("Tdie" == open_file (Path.build_filename (HWMON_PATH, hwmonx, hwmonx_prop))) {
                                string tempx_input = "temp%c_input".printf (hwmonx_prop[4]);
                                cpu_temp_paths.add (Path.build_filename (HWMON_PATH, hwmonx, tempx_input));

                                debug (open_file (cpu_temp_paths[0]));

                                // Intel stuff
                                // Intel reports per core
                            } else if (open_file (Path.build_filename (HWMON_PATH, hwmonx, hwmonx_prop)).contains ("Core")) {
                                string tempx_input = "temp%c_input".printf (hwmonx_prop[4]);
                                cpu_temp_paths.add (Path.build_filename (HWMON_PATH, hwmonx, tempx_input));
                                debug (open_file (cpu_temp_paths[0]));
                            }
                        }
                    }

                // Raspberry Pi 4
                } else if (sensor_name == "cpu_thermal") {
                    debug ("Found temp. sensor: %s", sensor_name);
                    Dir hwmonx_dir = Dir.open (Path.build_filename (HWMON_PATH, hwmonx), 0);
                    string ? hwmonx_prop = hwmonx_dir.read_name ();
                    string tempx_input = "temp%c_input".printf (hwmonx_prop[4]);
                    cpu_temp_paths.add (Path.build_filename (HWMON_PATH, hwmonx, tempx_input));
                    debug (open_file (cpu_temp_paths[0]));

                } else if (sensor_name == "amdgpu") {
                    debug ("Found temp. sensor: %s", sensor_name);
                    path_hwmon_amdgpu = Path.build_filename (HWMON_PATH, hwmonx, "temp1_input");
                    debug (open_file (path_hwmon_amdgpu));
                } else {
                    debug ("Found temp. sensor: %s", sensor_name);
                }
            }
        } catch (FileError e) {
            warning ("Could not open dir: %s", e.message);
        }
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
