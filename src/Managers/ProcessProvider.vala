namespace Monitor {
    public class ProcessProvider : GLib.Object{
        private static GLib.Once<ProcessProvider> instance;
        public static unowned ProcessProvider get_default () {
            return instance.once (() => { return new ProcessProvider (); });
        }

        private bool is_flatpak;

        public Gee.HashMap<int, string> pids_cmdline = new Gee.HashMap<int, string> ();
        public Gee.HashMap<int, string> pids_stat = new Gee.HashMap<int, string> ();
        public Gee.HashMap<int, string> pids_statm = new Gee.HashMap<int, string> ();
        public Gee.HashMap<int, string> pids_io = new Gee.HashMap<int, string> ();
        public Gee.HashMap<int, string> pids_status = new Gee.HashMap<int, string> ();
        public Gee.HashMap<int, string> pids_children = new Gee.HashMap<int, string> ();

        DBusWorkaroundClient dbus_workaround_client;

        construct {
            this.is_flatpak = ProcessUtils.is_flatpak_env ();
            if (this.is_flatpak) {
                //  this.spawn_workaround ();
                dbus_workaround_client = DBusWorkaroundClient.get_default ();
            }
        }

        private bool spawn_workaround () {
            try {
                debug ("Spawning workaround...");
                string app_path = ProcessUtils.get_flatpak_app_path ();
                string command = @"flatpak-spawn --host env LANG=C $app_path/share/workaround/com.github.stsdc.monitor-workaround.py";
                return GLib.Process.spawn_command_line_async (command);
            } catch (SpawnError e) {
                warning ("Spawning workaround error: %s\n", e.message);
                return false;
            }
        }

        public int[] get_pids () {
            if (this.is_flatpak) {
                int[] pids;
                pids_cmdline.clear ();
                pids_stat.clear ();
                pids_io.clear ();
                pids_status.clear ();
                pids_children.clear ();
                try {
                    HashTable<string, string>[] procs = dbus_workaround_client.interface.get_processes ("");
                    pids = new int[procs.length];
                    debug ("Workaround client: retrieved pids: %d", procs.length);
                    for (int i = 0; i < procs.length; i++) {
                        // debug (procs[i]["pid"]);
                        pids[i] = int.parse (procs[i]["pid"]);
                        pids_cmdline.set (pids[i], procs[i]["cmdline"]);
                        pids_stat.set (pids[i], procs[i]["stat"]);
                        pids_statm.set (pids[i], procs[i]["statm"]);
                        pids_io.set (pids[i], procs[i]["io"]);
                        pids_children.set (pids[i], procs[i]["children"]);
                        pids_status.set (pids[i], procs[i]["status"]);
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

        public void end_process (int pid) {
            DBusWorkaroundClient.get_default ();
        }
    }
}
