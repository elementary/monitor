

namespace Monitor {

    public class Process  : GLib.Object {
        // The size of each RSS page, in bytes
        //  private static long PAGESIZE = Posix.sysconf (Posix._SC_PAGESIZE);

        // Whether or not the PID leads to something
        public bool exists { get; private set; }

        // Full command from cmdline file
        public string command { get; private set; }

        public string application_name;

        // Contains info about io
        ProcessIO io;

        // Contains status info
        public ProcessStatus stat;


        /**
         * CPU usage of this process from the last time that it was updated, measured in percent
         *
         * Will be 0 on first update.
         */
        public double cpu_usage { get; private set; }

        private uint64 cpu_last_used;

        //Memory usage of the process, measured in KiB.

        public uint64 mem_usage { get; private set; }

        private uint64 last_total;


        // Construct a new process
        public Process (int _pid) {
            //  pid = _pid;
            last_total = 0;

            io = {};
            stat = {};
            stat.pid = _pid;


            exists = read_stat (0, 1) && read_cmdline ();
        }


        // Updates the process to get latest information
        // Returns if the update was successful
        public bool update (uint64 cpu_total, uint64 cpu_last_total) {
            exists = read_stat (cpu_total, cpu_last_total);
            parse_io();

            return exists;
        }

        // Kills the process
        // Returns if kill was successful
        public bool kill () {
            //  Sends a kill signal that cannot be ignored
            if (Posix.kill (stat.pid, Posix.Signal.KILL) == 0) {
                return true;
            }
            return false;
        }

        // Ends the process
        // Returns if end was successful
        public bool end () {
            //  Sends a terminate signal
            if (Posix.kill (stat.pid, Posix.Signal.TERM) == 0) {
                return true;
            }
            return false;
        }

        private bool parse_io () {
            var io_file = File.new_for_path ("/proc/%d/io".printf (stat.pid));

            if (!io_file.query_exists ()) {
                return false;
            }

            try {
                var dis = new DataInputStream (io_file.read ());
                string? line;

                while ((line = dis.read_line ()) != null){
                    var splitted_line = line.split (":");
                    switch (splitted_line[0]) {
                        case "wchar":
                            io.wchar = (uint64)splitted_line[1];
                            break;
                        case "rchar":
                            io.rchar = (uint64)splitted_line[1];
                            break;
                        case "syscr":
                            io.syscr = (uint64)splitted_line[1];
                            break;
                            case "syscw":
                            io.syscw = (uint64)splitted_line[1];
                            break;
                        case "read_bytes":
                            io.read_bytes = (uint64)splitted_line[1];
                            break;
                        case "write_bytes":
                            io.write_bytes = (uint64)splitted_line[1];
                            break;
                        case "cancelled_write_bytes":
                            io.cancelled_write_bytes = (uint64)splitted_line[1];
                            break;
                        default:
                            warning ("Unknown value in /proc/%d/io", stat.pid);
                            break;
                        }

                }

            } catch (Error e) {
                if (e.code != 14) {
                    // if the error is not `no access to file`, because regular user
                    // TODO: remove `magic` number
                
                    warning ("Can't read process io: '%s' %d", e.message, e.code);
                }
                return false;
            }
            return true;
        }

        // Reads the /proc/%pid%/stat file and updates the process with the information therein.
        private bool read_stat (uint64 cpu_total, uint64 cpu_last_total) {
            /* grab the stat file from /proc/%pid%/stat */
            var stat_file = File.new_for_path ("/proc/%d/stat".printf (stat.pid));

            /* make sure that it exists, not an error if it doesn't */
            if (!stat_file.query_exists ()) {
                return false;
            }

            try {
                // read the single line from the file
                var dis = new DataInputStream (stat_file.read ());
                string? stat_contents = dis.read_line ();

                if (stat_contents == null) {
                    stderr.printf ("Error reading stat file '%s': couldn't read_line ()\n", stat_file.get_path ());
                    return false;
                }

                /* split the contents into an array and parse each value that we care about */

                // But first we have to extract the command name, since it might include spaces
                // First find the command in stat file
                Regex regex = /\((.*?)\)/;
                MatchInfo match_info;
                regex.match (stat_contents, 0, out match_info);
                string matched_command = match_info.fetch (0);
                
                // Remove command from stat_contents
                stat_contents = stat_contents.replace (matched_command, "");

                // split the string 
                var splitted_stat = stat_contents.split (" ");
                stat.comm = matched_command[1 : -1];

                stat.state = splitted_stat[2];
                stat.ppid = int.parse (splitted_stat[3]);
                stat.pgrp = int.parse (splitted_stat[4]);

                // Get process UID
                GTop.ProcUid uid;
                GTop.get_proc_uid (out uid, stat.pid);
                //  stat.ppid = uid.ppid; // pid of parent process
                //  stat.pgrp = uid.pgrp; // process group id


                // Get CPU usage by process
                GTop.ProcTime proc_time;
                GTop.get_proc_time (out proc_time, stat.pid);
                cpu_usage = ((double)(proc_time.rtime - cpu_last_used)) / (cpu_total - cpu_last_total);
                cpu_last_used = proc_time.rtime;

                // Get memory usage by process
                GTop.Memory mem;
                GTop.get_mem (out mem);

                GTop.ProcMem proc_mem;
                GTop.get_proc_mem (out proc_mem, stat.pid);
                mem_usage = (proc_mem.resident - proc_mem.share) / 1024; // in KiB

                if (Gdk.Display.get_default () is Gdk.X11.Display) {
                    Wnck.ResourceUsage resu = Wnck.ResourceUsage.pid_read (Gdk.Display.get_default(), stat.pid);
                    mem_usage += (resu.total_bytes_estimate / 1024);
                }
            } catch (Error e) {
                warning ("Can't read process stat: '%s'", e.message);
                return false;
            }

            return true;
    }

        /**
         * Reads the /proc/%pid%/cmdline file and updates from the information contained therein.
         */
        private bool read_cmdline () {
            // grab the cmdline file from /proc/%pid%/cmdline
            var cmdline_file = File.new_for_path ("/proc/%d/cmdline".printf (stat.pid));

            // make sure that it exists
            if (!cmdline_file.query_exists ()) {
                warning ("File '%s' doesn't exist.\n", cmdline_file.get_path ());
                return false;
            }
            try {
                // read the single line from the file
                var dis = new DataInputStream (cmdline_file.read ());
                uint8[] cmdline_contents_array = new uint8[4097]; // 4096 is max size with a null terminator
                var size = dis.read (cmdline_contents_array);

                if (size <= 0) {
                    // was empty, not an error
                    return true;
                }

                // cmdline is a single line file with each arg seperated by a null character ('\0')
                // convert all \0 and \n to spaces
                for (int pos = 0; pos < size; pos++) {
                    if (cmdline_contents_array[pos] == '\0' || cmdline_contents_array[pos] == '\n') {
                        cmdline_contents_array[pos] = ' ';
                    }
                }
                cmdline_contents_array[size] = '\0';
                string cmdline_contents = (string) cmdline_contents_array;

                //TODO: need to make sure that this works
                GTop.ProcState proc_state;
                GTop.get_proc_state (out proc_state, stat.pid);

                command = cmdline_contents;

            }
            catch (Error e) {
                stderr.printf ("Error reading cmdline file '%s': %s\n", cmdline_file.get_path (), e.message);
                return false;
            }

            return true;
        }
    }
}
