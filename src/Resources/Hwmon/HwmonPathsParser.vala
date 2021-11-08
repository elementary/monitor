class Monitor.HwmonPathParser : Object {
    private const string HWMON_PATH = "/sys/class/hwmon";

    public HwmonGPUPathsParser gpu_paths_parser = new HwmonGPUPathsParser ();
    public HwmonNVMePathsParser nvme_paths_parser = new HwmonNVMePathsParser ();
    public HwmonIwlwifiPathsParser iwlwifi_paths_parser = new HwmonIwlwifiPathsParser ();
    public HwmonCPUPathsParser cpu_paths_parser = new HwmonCPUPathsParser ();

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

    construct {
        cpu_temp_paths = new Gee.ArrayList<string> ();
        detect_sensors ();
    }

    private void detect_sensors () {
        try {
            Dir hwmon_dir = Dir.open (HWMON_PATH, 0);

            string ? hwmonx = null;
            while ((hwmonx = hwmon_dir.read_name ()) != null) {
                string hwmonx_name = Path.build_filename (HWMON_PATH, hwmonx, "name");

                string interface_name = open_file (hwmonx_name);

                // thank u, next
                if (interface_name == "") continue;

                if (interface_name == "coretemp" || interface_name == "k10temp") {
                    debug ("Found HWMON CPU Interface: %s", interface_name);

                    Dir hwmonx_dir = Dir.open (Path.build_filename (HWMON_PATH, hwmonx), 0);
                    string ? hwmonx_prop = null;
                    while ((hwmonx_prop = hwmonx_dir.read_name ()) != null) {
                        cpu_paths_parser.add_path (Path.build_filename (HWMON_PATH, hwmonx, hwmonx_prop));
                    }
                    cpu_paths_parser.parse ();
                // Raspberry Pi 4
                } else if (interface_name == "cpu_thermal") {
                    debug ("Found temp. sensor: %s", interface_name);
                    Dir hwmonx_dir = Dir.open (Path.build_filename (HWMON_PATH, hwmonx), 0);
                    string ? hwmonx_prop = hwmonx_dir.read_name ();
                    string tempx_input = "temp%c_input".printf (hwmonx_prop[4]);
                    cpu_temp_paths.add (Path.build_filename (HWMON_PATH, hwmonx, tempx_input));
                    debug (open_file (cpu_temp_paths[0]));

                } else if (interface_name == "amdgpu") {
                    debug ("Found HWMON GPU Interface: %s", interface_name);

                    Dir hwmonx_dir = Dir.open (Path.build_filename (HWMON_PATH, hwmonx), 0);
                    string ? hwmonx_prop = null;

                    while (( hwmonx_prop = hwmonx_dir.read_name ()) != null) {
                        gpu_paths_parser.add_path (Path.build_filename (HWMON_PATH, hwmonx, hwmonx_prop));
                    }

                    gpu_paths_parser.parse ();
                } else if (interface_name == "nvme") {
                    debug ("Found HWMON NVMe Interface: %s", interface_name);

                    Dir hwmonx_dir = Dir.open (Path.build_filename (HWMON_PATH, hwmonx), 0);
                    string ? hwmonx_prop = null;

                    while (( hwmonx_prop = hwmonx_dir.read_name ()) != null) {
                        nvme_paths_parser.add_path (Path.build_filename (HWMON_PATH, hwmonx, hwmonx_prop));
                    }

                    nvme_paths_parser.parse ();
                } else if (interface_name == "iwlwifi_1") {
                    debug ("Found HWMON iwlwifi Interface: %s", interface_name);

                    Dir hwmonx_dir = Dir.open (Path.build_filename (HWMON_PATH, hwmonx), 0);
                    string ? hwmonx_prop = null;

                    while (( hwmonx_prop = hwmonx_dir.read_name ()) != null) {
                        iwlwifi_paths_parser.add_path (Path.build_filename (HWMON_PATH, hwmonx, hwmonx_prop));
                    }

                    iwlwifi_paths_parser.parse ();
                } else {
                    debug ("Found uknown HWMON Interface: %s", interface_name);
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
