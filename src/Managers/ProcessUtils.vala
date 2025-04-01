/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

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
        if (is_shell (splitted_commandline[0]) || is_python (splitted_commandline[0]) ) {
            return commandline;
        }

        //  if (!splitted_commandline[0].contains ("/")) {
        //      return commandline;
        //  }

        return splitted_commandline[0];
    }

    public static string ? read_file (string path) {
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

    public static Icon ? get_default_icon () {
        try {
            return Icon.new_for_string ("application-x-executable");
        } catch (Error e) {
            warning (e.message);
            return null;
        }
    }
}
