class TemperatureSensor : Object {
    private const string hwmon_path = "/sys/class/hwmon";

    public struct Sensor {
        public string location;
        public double tdie_current_temperature;
        public double tdie_critical_temperature;
        public double tctl_current_temperature;
        public double tctl_critical_temperature;
    } public Sensor at_cpu;

    construct { }

    public TemperatureSensor() {
    }

    public TemperatureSensor.cpu () {
        traverser ();
    }


    private void traverser () {
        int hwmon_counter = 0;

        Dir hwmon_dir = Dir.open (hwmon_path, 0);

        string ? hwmonx = null;
        while ((hwmonx = hwmon_dir.read_name ()) != null) {
            string hwmonx_name = Path.build_filename (hwmon_path, hwmonx, "name");
            string sensor_location = open_file (hwmonx_name).replace ("\n","");

            if (sensor_location == "coretemp" || sensor_location == "k10temp") {
                debug (sensor_location);

                Dir hwmonx_dir = Dir.open (Path.build_filename (hwmon_path, hwmonx), 0);
                string ? hwmonx_props = null;
                while ((hwmonx_props = hwmonx_dir.read_name ()) != null) {
                    debug (hwmonx_props);
                }
            }
        }
    }

    private string open_file (string filename) {
        try {
            string read;
            FileUtils.get_contents (filename, out read);
            return read;
        } catch (FileError e) {
            error ("%s\n", e.message);
            return "0";
        }
    }
}