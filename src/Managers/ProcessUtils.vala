public class Monitor.ProcessUtils {
    // checks if it is run by shell
    public static bool is_shell (string chunk) {
        return "sh" == chunk || "bash" == chunk || "zsh" == chunk;
    }

    public static bool is_python (string chunk) {
        return chunk.contains ("python");
    }

    public static string sanitize_commandline (string ? commandline) {
        if (commandline == null) return "";

        // splitting command; might include many options
        var splitted_commandline = commandline.split (" ");

        // check if started by any shell
        if (is_shell (splitted_commandline[0]) || is_python (splitted_commandline[0])) {
            return commandline;
        }

        // if (!splitted_commandline[0].contains ("/")) {
        // return commandline;
        // }

        return splitted_commandline[0];
    }

    public static string ? read_file (string path) {
        if (ProcessUtils.is_flatpak_env ()) {
            return ProcessUtils.read_file_on_host (path);
        }

        return ProcessUtils.read_file_native (path);
    }

    public static string ? read_file_native (string path) {
        var file = File.new_for_path (path);

        /* make sure that it exists, not an error if it doesn't */
        if (!file.query_exists ()) {
            return null;
        }
        var text = new StringBuilder ();
        try {
            var dis = new DataInputStream (file.read ());

            // Doing this because of cmdline file.
            // cmdline is a single line file with each arg separated by a null character ('\0')
            string line = dis.read_upto ("\0", 1, null);
            while (line != null) {
                text.append (line);
                text.append (" ");
                dis.skip (1);
                line = dis.read_upto ("\0", 1, null);
            }

            return text.str;
        } catch (Error e) {
            warning ("Error reading cmdline file '%s': %s\n", file.get_path (), e.message);
            return null;
        }
    }

    public static string ? read_file_on_host (string path) {
        string stdout;
        string stderr;
        string stdin;
        int status;

        int standard_input;
        int standard_output;
        int standard_error;


        string command = "flatpak-spawn --host cat " + path;
        string[] spawn_args = { "flatpak-spawn", "--host", "env", "LANG=C", "cat", path };
        Pid child_pid;

        try {
            //  string command = "flatpak-spawn --host cat " + path + " | grep -av DEBUG";
            debug (command);
            GLib.Process.spawn_command_line_sync
            (
            command,
            out stdout,
            out stderr,
            out status
            );


            //  GLib.Process.spawn_async_with_pipes
            //      ("/",
            //      spawn_args,
            //      Environ.get (),
            //      SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
            //      null,
            //      out child_pid,
            //      out standard_input,
            //      out standard_output,
            //      out standard_error
            //      );
            // debug ("Status: %d", status);
        } catch (SpawnError e) {
            error (e.message);
        }
        //  IOChannel output = new IOChannel.unix_new (standard_output);
		//  output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
		//  	if (condition == IOCondition.HUP) {
        //          print ("%s: The fd has been closed.\n", "stream_name");
        //          return false;
        //      }
        
        //      try {
        //          string line;
        //          channel.read_line (out line, null, null);
        //          print ("%s: %s", "stream_name", line);
        //      } catch (IOChannelError e) {
        //          print ("%s: IOChannelError: %s\n", "stream_name", e.message);
        //          return false;
        //      } catch (ConvertError e) {
        //          print ("%s: ConvertError: %s\n", "stream_name", e.message);
        //          return false;
        //      }
        
        //      return true;
		//  });

        //  ChildWatch.add (child_pid, (pid, status) => {
		//  	// Triggered when the child indicated by child_pid exits
		//  	GLib.Process.close_pid (pid);
		//  });

        
        string ? stdout_no_debug = "";

        if (stdout == "" || status != 0) {
            warning ("Tried to execute %s, but got null. Status: %d", command, status);
            return null;
        }

        foreach (var line in stdout.split ("\n")) {
            if (!line.contains ("DEBUG")) {
                stdout_no_debug += line + "\n";
            }
        }
        // print (stdout_no_debug);
        //  return null;
        return stdout_no_debug;
    }

    public static Icon ? get_default_icon () {
        try {
            return Icon.new_for_string ("application-x-executable");
        } catch (Error e) {
            warning (e.message);
            return null;
        }
    }

    public static bool is_flatpak_env () {
        string environment = GLib.Environment.get_variable ("container");
        // debug ("Monitor is running in %s environment", environment);
        if (environment == "flatpak") {
            return true;
        }
        return false;
    }

}
