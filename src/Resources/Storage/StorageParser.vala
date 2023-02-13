class Monitor.StorageParser : Object {
    private const string BLOCKS_PATH = "/sys/block";

    public Gee.ArrayList<string?> get_slaves_names (string volume_name) {
        Gee.ArrayList<string?> slaves_names = new Gee.ArrayList<string?> ();

        try {
            Dir slaves_dir = Dir.open (Path.build_filename (BLOCKS_PATH, volume_name, "slaves"), 0);

            string ? slave = null;

            while ((slave = slaves_dir.read_name ()) != null) {
                debug ("Found slave: " + slave);
                slaves_names.add (slave);
            }

        } catch (FileError e) {
            warning ("%s", e.message);
        }

        return slaves_names;
    }

}
