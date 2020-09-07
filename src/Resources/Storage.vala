public class Monitor.Storage : GLib.Object {
    public int bytes_write;
    private ulong sectors_write_old;

    public int bytes_read;
    private ulong sectors_read_old;

    // flag first run
    // bc first calculasion is wrong
    private bool dumb_flag;

    public Storage () {
        bytes_write = 0;
        sectors_write_old = 0;
        bytes_read = 0;
        sectors_read_old = 0;
        dumb_flag = true;
    }

    public void update () {
        ulong sectors_read_new = 0;
        ulong sectors_write_new = 0;

        try {
            string content = null;
            FileUtils.get_contents (@"/proc/diskstats", out content);
            InputStream input_stream = new MemoryInputStream.from_data (content.data, GLib.g_free);
            DataInputStream dis = new DataInputStream (input_stream);
            string line;

            while ((line = dis.read_line ()) != null) {
                string[] reg_split = Regex.split_simple ("[ ]+", line);
                if (reg_split[1] == "8" && Regex.match_simple ("sd[a-z]{1}$", reg_split[3])) {
                    sectors_read_new += ulong.parse (reg_split[6]);
                    sectors_write_new += ulong.parse (reg_split[10]);
                }
            }
        } catch (Error e) {
            warning ("Unable to retrieve storage data.");
        }

        // bc 2 sec updates
        if (!dumb_flag) {
            bytes_read = (int)((sectors_read_new - sectors_read_old) * 512 / 2);
            bytes_write = (int)((sectors_write_new - sectors_write_old) * 512 / 2);
        }
        dumb_flag = false;

        sectors_read_old = sectors_read_new;
        sectors_write_old = sectors_write_new;
    }
}

