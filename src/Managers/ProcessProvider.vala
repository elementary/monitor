namespace Monitor {
    public class ProcessProvider {
        private static GLib.Once<ProcessProvider> instance;
        public static unowned ProcessProvider get_default () {
            return instance.once (() => { return new ProcessProvider (); });
        }

        public Gee.HashSet<int> pids = new Gee.HashSet<int> ();

        public ProcessProvider () {
        }

        public GLib.List<int> get_pids () {
            var new_pids = new GLib.List<int> ();

            try {
                string[] spawn_args = { "flatpak-spawn", "--host", "ls" };
                string[] spawn_env = Environ.get ();
                Pid child_pid;

                int standard_input;
                int standard_output;
                int standard_error;


                string ls_stdout;
                string ls_stderr;
                int ls_status;

                // GLib.Process.spawn_async_with_pipes
                // (
                // "/proc/",
                // spawn_args,
                // spawn_env,
                // SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                // null,
                // out child_pid,
                // out standard_input,
                // out standard_output,
                // out standard_error
                // );

                GLib.Process.spawn_command_line_sync (
                    "flatpak-spawn --host ls /proc/",
                    out ls_stdout,
                    out ls_stderr,
                    out ls_status);

                // stdout:
                // IOChannel output = new IOChannel.unix_new (standard_output);
                // output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                // return process_line (channel, condition, new_pids);
                // });

                //// stderr:
                // IOChannel error = new IOChannel.unix_new (standard_error);
                // error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
                ////  return process_line (channel, condition, "stderr");
                // return true;
                // });

                // ChildWatch.add (child_pid, (pid, status) => {
                ////// Triggered when the child indicated by child_pid exits
                // GLib.Process.close_pid (pid);
                //// loop.quit ();
                // });

                // debug (ls_stdout);
                foreach (var line in ls_stdout.strip ().split ("\n")) {
                    if (line[0].isdigit ()) {
                        //  print ("---->" + line + "\n");
                        new_pids.append (int.parse (line));
                    }
                }


            } catch (SpawnError e) {
                error ("Error: %s\n", e.message);
            }
            return new_pids;
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
