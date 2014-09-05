


namespace elementarySystemMonitor {

    public class ProcessMonitor {
        private Gee.HashMap<int, Process> process_list;
        private Gee.HashSet<int> kernel_process_blacklist;

        public signal void process_added (int pid, Process process);
        public signal void process_removed (int pid);
        public signal void updated ();

        /**
         * Construct a new ProcessMonitor
         */
        public ProcessMonitor () {
            process_list = new Gee.HashMap<int, Process> ();
            kernel_process_blacklist = new Gee.HashSet<int> ();
            update_processes ();

            Timeout.add (2000, handle_timeout);
        }

        /**
         * Gets a process by its pid, making sure that it's updated.
         */
        public Process? get_process (int pid) {
            // if the process is in the kernel blacklist, we don't want to deal with it.
            if (kernel_process_blacklist.contains (pid)) {
                return null;
            }

            // else, return our cached version.
            if (process_list.has_key (pid)) {
                return process_list[pid];
            }

            // else return the result of add_process
            // make sure to lazily call the callback since this is a greedy add
            // this way we don't interrupt whatever this method is being called for
            // with a handle_add_process
            return add_process (pid, true);
        }

        /**
         * Returns all direct sub processes of this process
         */
        public Gee.Set<int> get_sub_processes (int pid) {
            var sub_processes = new Gee.HashSet<int> ();

            // go through and add all of the processes with PPID set to this one
            foreach (var process in process_list.values) {
                if (process.ppid == pid) {
                    sub_processes.add (process.pid);
                }
            }

            return sub_processes;
        }

        /**
         * Gets a read only map of the processes currently cached
         */
        public Gee.Map<int, Process> get_process_list () {
            return process_list.read_only_view;
        }

        /**
         * Handle updating the process list
         */
        private bool handle_timeout () {
            update_processes ();
            return true;
        }

        /**
         * Gets all new process and adds them
         */
        private void update_processes () {
            var remove_me = new Gee.HashSet<int>();

            // go through each process and update it, removing the old ones
            foreach (var process in process_list.values) {
                if (!process.update ()) {
                    // process doesn't exist any more, flag it for removal!
                    remove_me.add (process.pid);
                }
            }

            // remove everything from flags
            foreach (var pid in remove_me) {
                remove_process (pid);
            }

            try {
                var proc_dir = File.new_for_path ("/proc/");
                var dir_enumerator = proc_dir.enumerate_children ("standard::*", 0);

                FileInfo info;

                // go through the files
                while ((info = dir_enumerator.next_file ()) != null) {
                    int pid = 0;

                    // if file is a directory and the name is a number
                    if ((info.get_file_type () == FileType.DIRECTORY)
                            && ((pid = int.parse (info.get_name ())) != 0)) {
                        // got a process id, does it belong to a process that we already have?
                        if (!process_list.has_key (pid) && !kernel_process_blacklist.contains (pid)) {
                            add_process (pid);
                        }
                    }
                }
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }

            // call the updated signal so that subscribers can update
            updated ();
        }

        /**
         * Parses a pid and adds a Process to our process_list or to the kernel_blacklist
         *
         * returns the created process
         */
        private Process? add_process (int pid, bool lazy_signal = false) {
            // create the process
            var process = new Process (pid);

            if (process.exists) {
                if (process.pgrp != 0) {
                    // regular process, add it to our cache
                    process_list.set (pid, process);

                    // call the signal, lazily if needed
                    if (lazy_signal)
                        Idle.add (() => { process_added (pid, process); return false; });
                    else
                        process_added (pid, process);

                    return process;
                } else {
                    // add it to our kernel processes blacklist
                    kernel_process_blacklist.add (pid);
                }
            }

            return null;
        }


        /**
         * Remove the process from all lists and broadcast the process_removed signal if removed.
         */
        private void remove_process (int pid) {
            if (process_list.has_key (pid)) {
                process_list.unset (pid);
                process_removed (pid);
            }
            else if (kernel_process_blacklist.contains (pid)) {
                kernel_process_blacklist.remove (pid);
            }
        }
    }
}
