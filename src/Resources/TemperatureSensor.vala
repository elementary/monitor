class TemperatureSensor : Object {
    private const string hwmon_path = "/sys/class/hwmon";

    // contains list of paths to files with a temperature values
    // Intel reports per core temperature, while AMD Ryzen Tdie
    public Gee.ArrayList<string?> cpu_temp_paths;

    public double cpu {
        get {
            double total_temperature = 0;
            foreach (var path in cpu_temp_paths) {
                total_temperature += double.parse (open_file (path));
            }
            return total_temperature / cpu_temp_paths.size;
        }
    }

    construct {
        cpu_temp_paths = new  Gee.ArrayList<string> ();
        traverser ();
     }

    public TemperatureSensor() {
        
    }


    private void traverser () {
        try {
            Dir hwmon_dir = Dir.open (hwmon_path, 0);

            string ? hwmonx = null;
            while ((hwmonx = hwmon_dir.read_name ()) != null) {
                string hwmonx_name = Path.build_filename (hwmon_path, hwmonx, "name");

                string sensor_name = open_file (hwmonx_name);

                // thank u, next
                if (sensor_name == "") { continue; }

                if (sensor_name == "coretemp" || sensor_name == "k10temp") {
                    debug ("Found temp. sensor: %s", sensor_name);

                    Dir hwmonx_dir = Dir.open (Path.build_filename (hwmon_path, hwmonx), 0);
                    string ? hwmonx_prop = null;
                    while ((hwmonx_prop = hwmonx_dir.read_name ()) != null) {
                        //  debug (open_file (hwmonx_name));

                        if (hwmonx_prop.contains ("temp")) {
                            // AMD stuff
                            // Tdie contains true temperature value, while Tctl contains value for fans
                            // Tctl = Tdie + offset in some processors
                            if ("Tdie" == open_file (Path.build_filename (hwmon_path, hwmonx, hwmonx_prop))) {
                                string tempx_input = "temp%c_input".printf(hwmonx_prop[4]);
                                cpu_temp_paths.add (Path.build_filename (hwmon_path, hwmonx, tempx_input));
                                
                                debug (open_file (cpu_temp_paths[0]));

                            // Intel stuff
                            // Intel reports per core
                            } else if (open_file (Path.build_filename (hwmon_path, hwmonx, hwmonx_prop)).contains ("Core")) {
                                string tempx_input = "temp%c_input".printf(hwmonx_prop[4]);
                                cpu_temp_paths.add (Path.build_filename (hwmon_path, hwmonx, tempx_input));
                                debug (open_file (cpu_temp_paths[0]));
                            }
                        }
                    }
                } else if (sensor_name == "amdgpu" ) {
                    debug ("Found temp. sensor: %s", sensor_name);
                } else {
                    debug ("Found temp. sensor: %s", sensor_name);
                }
            }
        } catch (FileError e) {
            warning (@"Could not open dir: %s", e.message);
        }
    }

    private string open_file (string filename) {
        try {
            string read;
            FileUtils.get_contents (filename, out read);
            return read.replace ("\n","");
        } catch (FileError e) {
            warning ("%s", e.message);
            return "";
        }
    }
}