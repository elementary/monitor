public class Monitor.Cgroup : GLib.Object {
    public string id;
    public string memory_usage_by_bytes {
        owned get {
            return open_file ("/sys/fs/cgroup/memory/docker/%s/memory.usage_in_bytes".printf (id), read_memory_usage_in_bytes) ?? "0";
        } private set {
        }
    }
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

    // public string get_memory_usage_by_bytes () {
    // return open_file ("/sys/fs/cgroup/memory/docker/%s/memory.usage_in_bytes".printf (this.id), read_memory_usage_in_bytes);
    // }

}
