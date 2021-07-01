public struct Monitor.DriveSmart {
    public bool enabled;
    public uint64 updated;
    public bool failing;
    public uint64 power_seconds;
    public uint64 power_counts;
    public string selftest_status;
    public uint life_left;
}

public struct Monitor.MonitorVolume {
    public string device;
    public string label;
    public string type;
    public string uuid;
    public string mount_point;
    public uint64 size;
    public uint64 free;
    public uint64 offset;
}

public class Monitor.DiskDrive : GLib.Object {
    public string model;
    public uint64 size;
    public string revision;
    public string id;
    public string device;
    public string partition;
    public GLib.Icon drive_icon;



    private Gee.ArrayList<MonitorVolume?> volumes;

    private DriveSmart? smart = null;
    public bool has_smart {
        get {
            return smart != null;
        }
    }

    public DiskDrive () {
        volumes = new Gee.ArrayList <MonitorVolume?> ();
    }

    public DriveSmart? get_smart () {
        return smart;
    }

    public void add_smart (DriveSmart s) {
        smart = s;
    }

    public void add_volume (MonitorVolume vol) {
        volumes.add (vol);
    }

    public Gee.ArrayList<MonitorVolume?> get_volumes () {
        var volumes_arr = new Gee.ArrayList<MonitorVolume?> ();

        volumes.foreach ((vol) => {

            volumes_arr.add (vol);

            return true;
        });

        volumes_arr.sort (compare_volumes);

        return volumes_arr;
    }

    private int compare_volumes (MonitorVolume? vol1, MonitorVolume? vol2) {
        if (vol1 == null) {
            return (vol2 == null) ? 0 : -1;
        }

        if (vol2 == null) {
            return 1;
        }

        return GLib.strcmp (vol1.device, vol2.device);
    }
}