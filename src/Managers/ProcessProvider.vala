namespace Monitor {
    public class ProcessProvider {
        private static GLib.Once<ProcessProvider> instance;
        public static unowned ProcessProvider get_default () {
            return instance.once (() => { return new ProcessProvider (); });
        }

        public Gee.HashSet<int> pids = new Gee.HashSet<int> ();

        DBusWorkaroundClient dbus_workaround_client;

        public ProcessProvider () {
            if (ProcessUtils.is_flatpak_env ()) {
                dbus_workaround_client = DBusWorkaroundClient.get_default ();
            }
        }

        public int[] get_pids () {
            // try {
            // HashTable<string, string>[] p = dbus_workaround_client.interface.get_processes ("");
            // debug ("%s", p[400]["cmdline"] );
            // } catch (Error e) {
            // warning (e.message);
            // }
            GTop.ProcList proclist;
            // var pids = GTop.get_proclist (out proclist, GTop.GLIBTOP_KERN_PROC_UID, uid);
            int[] pids = GTop.get_proclist (out proclist, GTop.GLIBTOP_KERN_PROC_ALL, Posix.getuid ());
            debug("%d", pids.length);
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
