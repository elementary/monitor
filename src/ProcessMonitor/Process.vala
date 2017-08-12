

namespace elementarySystemMonitor {

    public class Process {
        /**
         * The size of each RSS page, in bytes
         */
        private static long PAGESIZE = Posix.sysconf (Posix._SC_PAGESIZE);

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

        private uint64 cpu_last_used;

        /**
         * Memory usage of the process, measured in KiB.
         *
         * Measured from RSS, so it will overestimate because it overcounts shared memory libraries
         */
        public uint64 mem_usage { get; private set; }

        private uint64 last_total;

        private uint64 rss;


        /**
         * Construct a new process
         */
        public Process (int _pid) {
            pid = _pid;
            last_total = 0;

            exists = read_stat (0, 1);
            read_cmdline ();
        }

        /**
         * Updates the process to get latest information
         *
         * Returns if the update was successful
         */
        public bool update (uint64 cpu_total, uint64 cpu_last_total) {
        exists = read_stat (cpu_total, cpu_last_total);

        return exists;
}

        // Kills the process
        // Returns if kill was successful
        public bool kill () {
            if (Posix.kill (pid, Posix.SIGINT) == 0) {
                return true;
            }
            return false;
        }

        /**
         * Reads the /proc/%pid%/stat file and updates the process with the information therein.
         */
        private bool read_stat (uint64 cpu_total, uint64 cpu_last_total) {
            /* grab the stat file from /proc/%pid%/stat */
            var stat_file = File.new_for_path ("/proc/%d/stat".printf (pid));

            /* make sure that it exists, not an error if it doesn't */
            if (!stat_file.query_exists ()) {
                return false;
            }

            try {
                /* read the single line from the file */
                var dis = new DataInputStream (stat_file.read ());
                string? stat_contents = dis.read_line ();

                if (stat_contents == null) {
                    stderr.printf ("Error reading stat file '%s': couldn't read_line ()\n", stat_file.get_path ());

                    return false;
                }

                /* split the contents into an array and parse each value that we care about */
                var stat = stat_contents.split (" ");

                comm = stat[1][1 : -1];

                ppid = int.parse (stat[3]);
                pgrp = int.parse (stat[4]);

                // Processor usage
                GTop.ProcTime proc_time;
                GTop.get_proc_time (out proc_time, pid);
                cpu_usage = ((double)(proc_time.rtime - cpu_last_used)) / (cpu_total - cpu_last_total);
                cpu_last_used = proc_time.rtime;

                // Memory usage
                GTop.Memory mem;
                GTop.get_mem (out mem);

                GTop.ProcMem proc_mem;
                GTop.get_proc_mem (out proc_mem, pid);
                mem_usage = (proc_mem.resident - proc_mem.share)/1024; // in KiB
                debug ("%d", (int)mem_usage);
                
            } catch (Error e) {
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
