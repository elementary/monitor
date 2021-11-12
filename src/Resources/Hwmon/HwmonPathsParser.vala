class Monitor.HwmonPathParser : Object {
    private const string HWMON_PATH = "/sys/class/hwmon";
    //  private const string HWMON_PATH = "/home/stsdc/test";

    public HwmonPathsParserGPU gpu_paths_parser = new HwmonPathsParserGPU ();
    public HwmonPathsParserNVMe nvme_paths_parser = new HwmonPathsParserNVMe ();
    public HwmonPathsParserIwlwifi iwlwifi_paths_parser = new HwmonPathsParserIwlwifi ();
    public HwmonPathsParserCPU cpu_paths_parser = new HwmonPathsParserCPU ();

    //  public double cpu {
    //      get {
    //          double total_temperature = 0;
    //          // this should handle null
    //          foreach (var path in cpu_temp_paths) {
    //              total_temperature += double.parse (open_file (path));
    //          }
    //          return total_temperature / cpu_temp_paths.size;
    //      }
    //  }

    construct {
        //  cpu_temp_paths = new Gee.ArrayList<string> ();
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

                if (interface_name == "coretemp" || interface_name == "k10temp" || interface_name == "cpu_thermal") {
                    debug ("Found HWMON CPU Interface: %s", interface_name);
                    this.parse (cpu_paths_parser, hwmonx);

                } else if (interface_name == "amdgpu") {
                    debug ("Found HWMON GPU Interface: %s", interface_name);
                    this.parse (gpu_paths_parser, hwmonx);

                } else if (interface_name == "nvme") {
                    debug ("Found HWMON NVMe Interface: %s", interface_name);
                    this.parse (nvme_paths_parser, hwmonx);

                } else if (interface_name == "iwlwifi_1") {
                    debug ("Found HWMON iwlwifi Interface: %s", interface_name);
                    this.parse (iwlwifi_paths_parser, hwmonx);

                } else {
                    debug ("Found unknown HWMON Interface: %s", interface_name);
                }
            }
        } catch (FileError e) {
            warning ("Could not open dir: %s", e.message);
        }
    }

    private void parse (IHwmonPathsParserInterface parser, string hwmonx) {
        try {
            Dir hwmonx_dir = Dir.open (Path.build_filename (HWMON_PATH, hwmonx), 0);
            string ? hwmonx_prop = null;

            while (( hwmonx_prop = hwmonx_dir.read_name ()) != null) {
                parser.add_path (Path.build_filename (HWMON_PATH, hwmonx, hwmonx_prop));
            }

            parser.parse ();
        } catch (FileError e) {
            warning ("%s", e.message);
        }
    }

    private string open_file (string filename) {
        try {
            string read;
            if (!FileUtils.test (filename, FileTest.IS_REGULAR)) return "";
            FileUtils.get_contents (filename, out read);
            return read.replace ("\n", "");
        } catch (FileError e) {
            warning ("%s", e.message);
            return "";
        }
    }
}
