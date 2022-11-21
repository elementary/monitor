public class Monitor.Cgroup : GLib.Object {
    /**
     * This class only parses necessery values from cgroup files.
     * @TODO: Properly parse all values in files.
     */
    public string id;
    public string memory_usage_by_bytes {
        owned get {
            return open_file ("/sys/fs/cgroup/memory/docker/%s/memory.usage_in_bytes".printf (id), read_memory_usage_in_bytes) ?? "0";
        } private set {
        }
    }

    public string memory_stat_total_inactive_file {
        owned get {
            return open_file ("/sys/fs/cgroup/memory/docker/%s/memory.stat".printf (id), read_memory_stat_total_inactive_file) ?? "0";
        } private set {
        }
    }

    public string cpuaact_usage_sys {
        owned get {
            return open_file ("/sys/fs/cgroup/cpuacct/docker/%s/memory.usage_in_bytes".printf (id), read_cpuacct_usage_sys) ?? "0";
        } private set {
        }
    }

    //  public CgroupMemoryStat memory_stat;
    public Cgroup (string _id) {
        id = _id;
    }

    delegate string DelegateReadFileFunc (File file);

    private string open_file (string path, DelegateReadFileFunc read_file) {
        File file = File.new_for_path (path);

        /* make sure that it exists, not an error if it doesn't */
        if (!file.query_exists ()) {
            warning ("File doesn't exist ???");
            return "";
        }
        return read_file (file);
    }

    private string read_memory_usage_in_bytes (File file) {
        try {
            var dis = new DataInputStream (file.read ());
            return dis.read_line ();
        } catch (Error e) {
            warning ("Error reading file '%s': %s\n", file.get_path (), e.message);
            return "";
        }
    }

    // Reads very specific value from a file. Should basically read whole file
    // but am too lazy
    private string read_memory_stat_total_inactive_file (File file) {
        try {
            var dis = new DataInputStream (file.read ());
            string ? line;
            while ((line = dis.read_line ()) != null) {
                var splitted_line = line.split (":");
                if (splitted_line[0] == "total_inactive_file") {
                    return splitted_line[1];
                }
            }
            return "";
        } catch (Error e) {
            warning ("Error reading file '%s': %s\n", file.get_path (), e.message);
            return "";
        }
    }

    private string read_cpuacct_usage_sys (File file) {
        try {
            var dis = new DataInputStream (file.read ());
            return dis.read_line ();
        } catch (Error e) {
            warning ("Error reading file '%s': %s\n", file.get_path (), e.message);
            return "";
        }
    }

}
