

namespace elementarySystemMonitor {

    public class Process {
        /**
         * The size of each RSS page, in bytes
         */
        private static long PAGESIZE = Posix.sysconf (Posix._SC_PAGESIZE);

        /**
         * Number of 'clock ticks' a second. Generally about 100
         */
        private static long TICKS_PER_SEC = Posix.sysconf (Posix._SC_CLK_TCK);

        /**
         * Whether or not the PID leads to something
         */
        public bool exists { get; private set; }

        /**
         * Process ID
         */
        public int pid { get; private set; }

        /**
         * Parent Process ID
         */
        public int ppid { get; private set; }

        /**
         * Process Group ID; 0 if a kernal process/thread
         */
        public int pgrp { get; private set; }

        /**
         * Command from stat file, truncated to 16 chars
         */
        public string comm { get; private set; }

        /**
         * Full command from cmdline file
         */
        public string command { get; private set; }

        /**
         * CPU usage of this process from the last time that it was updated, measured in percent
         *
         * Will be 0 on first update.
         */
        public double cpu_usage { get; private set; }

        /**
         * Memory usage of the process, measured in KiB.
         *
         * Measured from RSS, so it will overestimate because it overcounts shared memory libraries
         */
        public uint64 mem_usage { get; private set; }

        private uint64 utime;
        private uint64 stime;
        private uint64 last_total;
        private int64 last_monotonic_time;

        private uint64 rss;


        /**
         * Construct a new process
         */
        public Process (int _pid) {
            pid = _pid;
            last_total = 0;
            last_monotonic_time = 0;

            exists = read_stat ();
            read_cmdline ();
        }

        /**
         * Updates the process to get latest information
         *
         * Returns if the update was successful
         */
        public bool update () {
            exists = read_stat ();
            return exists;
        }

        /**
         * Kills the process
         * 
         * Returns if the update was successful
         */
        public bool kill () {
            if (Posix.kill (pid, Posix.SIGINT) == 0) {
                return true;
            }
            return false;
        }

        /**
         * Reads the /proc/%pid%/stat file and updates the process with the information therein.
         */
        private bool read_stat () {
            // grab the stat file from /proc/%pid%/stat
            var stat_file = File.new_for_path ("/proc/%d/stat".printf (pid));

            // make sure that it exists, not an error if it doesn't
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

                // split the contents into an array and parse each value that we care about
                var stat = stat_contents.split (" ");

                comm = stat[1][1:-1];

                ppid = int.parse (stat[3]);
                pgrp = int.parse (stat[4]);

                // calculate how many clock ticks we've had since last update
                last_total = utime + stime;
                utime = uint64.parse (stat[13]);
                stime = uint64.parse (stat[14]);
                var cur_monotonic_time = GLib.get_monotonic_time ();

                // if last_monotonic_time is 0, then we've never run this calculation before
                // so we should skip it
                if (last_monotonic_time != 0) {
                    // TODO: need to somehow grab the offical cpu time or have it passed in to us
                    double time_gap_seconds = (cur_monotonic_time - last_monotonic_time) / 1000000.0; // number of seconds between measurements
                    double cpu_seconds = (((utime + stime) - last_total) * 1.0) / (TICKS_PER_SEC * 1.0);
                    cpu_usage = cpu_seconds / time_gap_seconds;
                }

                last_monotonic_time = cur_monotonic_time;

                // calculate mem usage using rss, not very accurate
                rss = int64.parse (stat[23]);
                mem_usage = (rss * PAGESIZE) / (1024); // unit is KiB
            }
            catch (Error e) {
                stderr.printf ("Error reading stat file '%s': %s\n", stat_file.get_path (), e.message);
                return false;
            }

            return true;
        }

        /**
         * Reads the /proc/%pid%/cmdline file and updates from the information contained therein.
         */
        private bool read_cmdline () {
            // grab the cmdline file from /proc/%pid%/cmdline
            var cmdline_file = File.new_for_path ("/proc/%d/cmdline".printf (pid));

            // make sure that it exists
            if (!cmdline_file.query_exists ()) {
                stderr.printf ("File '%s' doesn't exist.\n", cmdline_file.get_path ());
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
