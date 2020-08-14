class TemperatureSensor : Object {
    private const string hwmon_path = "/sys/class/hwmon";
    private string? cpu_temp_path;

    public struct Sensor {
        public string location;
        public float temperature;
        public float temperature_critical;
        //  public double tdie_current_temperature;
        //  public double tdie_critical_temperature;
        //  public double tctl_current_temperature;
        //  public double tctl_critical_temperature;
    } public Sensor sensor;


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
            string sensor_location = open_file (hwmonx_name);

            if (sensor_location == "coretemp" || sensor_location == "k10temp") {
                debug ("Found temp. sensor: %s", sensor_location);

                Dir hwmonx_dir = Dir.open (Path.build_filename (hwmon_path, hwmonx), 0);
                string ? hwmonx_prop = null;
                while ((hwmonx_prop = hwmonx_dir.read_name ()) != null) {
                    //  debug (open_file (hwmonx_name));

                    if (hwmonx_prop.contains ("temp")) {
                        // Tdie contains true temperature value, while Tctl contains value for fans
                        // Tctl = Tdie + offset
                        if ("Tdie" == open_file (Path.build_filename (hwmon_path, hwmonx, hwmonx_prop))) {
                            cpu_temp_path = Path.build_filename (hwmon_path, hwmonx, "temp%c_input".printf(hwmonx_prop[4]));
                            debug (open_file (cpu_temp_path));
                        }
                    }
                }
            } else if (sensor_location == "amdgpu" ) {
                debug ("Found temp. sensor: %s", sensor_location);
            } else {
                debug ("Found temp. sensor: %s", sensor_location);
            }
        }
    }

    private string open_file (string filename) {
        try {
            string read;
            FileUtils.get_contents (filename, out read);
            return read.replace ("\n","");
        } catch (FileError e) {
            error ("%s\n", e.message);
            return "0";
        }
    }
}