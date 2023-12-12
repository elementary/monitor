namespace Monitor {
    public class ProcessProvider {
        private static GLib.Once<ProcessProvider> instance;
        public static unowned ProcessProvider get_default () {
            return instance.once (() => { return new ProcessProvider (); });
        }

        public Gee.HashSet<int> pids = new Gee.HashSet<int> ();
        public Gee.HashMap<int, string> pids_cmdline = new Gee.HashMap<int, string> ();
        public Gee.HashMap<int, string> pids_stat = new Gee.HashMap<int, string> ();
        public Gee.HashMap<int, string> pids_io = new Gee.HashMap<int, string> ();
        public Gee.HashMap<int, string> pids_status = new Gee.HashMap<int, string> ();

        DBusWorkaroundClient dbus_workaround_client;

        public ProcessProvider () {
            if (ProcessUtils.is_flatpak_env ()) {
                dbus_workaround_client = DBusWorkaroundClient.get_default ();
            }
        }

        public int[] get_pids () {
            if (ProcessUtils.is_flatpak_env ()) {
                int[] pids;
                try {
                    HashTable<string, string>[] procs = dbus_workaround_client.interface.get_processes ("");
                    pids = new int[procs.length];
                    debug ("Workaround: pids: %d", procs.length);
                    for (int i = 0; i < procs.length; i++) {
                        //  debug (procs[i]["pid"]);
                        pids[i] = int.parse (procs[i]["pid"]);
                        pids_cmdline.set (pids[i], procs[i]["cmdline"]);
                        pids_stat.set (pids[i], procs[i]["stat"]);
                        pids_status.set (pids[i], procs[i]["status"]);
                        pids_io.set (pids[i], procs[i]["io"]);
                    }
                } catch (Error e) {
                    warning (e.message);
                }
                return pids;
            }
            GTop.ProcList proclist;
            // var pids = GTop.get_proclist (out proclist, GTop.GLIBTOP_KERN_PROC_UID, uid);
            var pids = GTop.get_proclist (out proclist, GTop.GLIBTOP_KERN_PROC_ALL, Posix.getuid ());
            pids.length = (int) proclist.number;

            return pids;
        }

        private bool process_line (IOChannel channel, IOCondition condition, GLib.List<int> _pids) {
            if (condition == IOCondition.HUP) {
                // debug ("%s: The fd has been closed.\n", stream_name);
                return false;
            }

            try {
                string line;
                channel.read_line (out line, null, null);
                if (line[0].isdigit ()) {
                    print ("%d\n", int.parse (line));
                    // pids.add (line.strip ());

                }
            } catch (IOChannelError e) {
                warning ("IOChannelError: %s\n", e.message);
                return false;
            } catch (ConvertError e) {
                warning ("ConvertError: %s\n", e.message);
                return false;
            }

            return true;
        }

    }
}
