namespace Monitor {
    public class ProcessManager {
        private static GLib.Once<ProcessManager> instance;
        public static unowned ProcessManager get_default () {
            return instance.once (() => { return new ProcessManager (); });
        }

        public double cpu_load { get; private set; }
        public double[] cpu_loads { get; private set; }

        uint64 cpu_last_used = 0;
        uint64 cpu_last_total = 0;
        uint64[] cpu_last_useds = new uint64[32];
        uint64[] cpu_last_totals = new uint64[32];

        private Gee.TreeMap<int, Process> process_list;
        private Gee.HashSet<int> kernel_process_blacklist;
        private Gee.HashMap<string, AppInfo> apps_info_list;

        public signal void process_added (Process process);
        public signal void process_removed (int pid);
        public signal void updated ();

        // Construct a new ProcessManager
        public ProcessManager () {
            process_list = new Gee.TreeMap<int, Process> ();
            kernel_process_blacklist = new Gee.HashSet<int> ();
            apps_info_list = new Gee.HashMap<string, AppInfo> ();

            populate_apps_info ();
            update_processes.begin ();
        }

        public void populate_apps_info () {
            var _apps_info = AppInfo.get_all ();

            foreach (AppInfo app_info in _apps_info) {
                string commandline = (app_info.get_commandline ());
                // GLib.DesktopAppInfo? dai = info as GLib.DesktopAppInfo;

                // if (dai != null) {
                // string id = dai.get_string ("X-Flatpak");
                // if (id != null)
                // appid_map.insert (id, info);
                // }
                if (commandline == null)
                    continue;

                apps_info_list.set (commandline, app_info);
            }
        }

        /**
         * Gets a process by its pid, making sure that it's updated.
         */
        public Process ? get_process (int pid) {
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
                if (process.stat.ppid == pid) {
                    sub_processes.add (process.stat.pid);
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
         * Gets all new process and adds them
         */
         public async void update_processes () {
            /* CPU */
            GTop.Cpu cpu_data;
            GTop.get_cpu (out cpu_data);
            var used = cpu_data.user + cpu_data.nice + cpu_data.sys;
            cpu_load = ((double) (used - cpu_last_used)) / (cpu_data.total - cpu_last_total);
            cpu_loads = new double[cpu_data.xcpu_user.length];
            var useds = new uint64[cpu_data.xcpu_user.length];

            for (int i = 0; i < cpu_data.xcpu_user.length; i++) {
                useds[i] = cpu_data.xcpu_user[i] + cpu_data.xcpu_nice[i] + cpu_data.xcpu_sys[i];
            }

            for (int i = 0; i < cpu_data.xcpu_user.length; i++) {
                cpu_loads[i] = ((double) (useds[i] - cpu_last_useds[i])) /
                               (cpu_data.xcpu_total[i] - cpu_last_totals[i]);
            }

            var remove_me = new Gee.HashSet<int> ();

            /* go through each process and update it, removing the old ones */
            foreach (var process in process_list.values) {
                if (!process.update (cpu_data.total, cpu_last_total)) {
                    /* process doesn't exist any more, flag it for removal! */
                    remove_me.add (process.stat.pid);
                }
            }

            /* remove everything from flags */
            foreach (var pid in remove_me) {
                remove_process (pid);
            }

            var process_provider = ProcessProvider.get_default ();
            var pids = process_provider.get_pids ();

            foreach (int pid in pids) {
                if (!process_list.has_key (pid) && !kernel_process_blacklist.contains (pid)) {
                    add_process (pid);
                }
            }

            cpu_last_used = used;
            cpu_last_total = cpu_data.total;
            cpu_last_useds = useds;
            cpu_last_totals = cpu_data.xcpu_total;

            /* emit the updated signal so that subscribers can update */
            updated ();

        }

        /** Sets name and icon for a process that is a Flatpak app and its children. */
        private void set_flatpak_name_icon (Process process, GLib.Icon icon, string name) {
            process.application_name = name;
            process.icon = icon;
            foreach (int pid in process.children) {
                var _process = this.get_process (pid);
                if (_process != null) {
                    set_flatpak_name_icon (_process, icon, name);
                }
            }
        }

        private bool match_process_app (Process process) {
            var command_sanitized = ProcessUtils.sanitize_commandline (process.command);
            var command_sanitized_basename = Path.get_basename (command_sanitized);

            process.application_name = command_sanitized_basename;

            foreach (var flatpak_app in Flatpak.Instance.get_all ()) {
                if (flatpak_app.get_pid () == process.stat.pid || flatpak_app.get_child_pid () == process.stat.pid) {
                    debug ("Found Flatpak app: %s ", flatpak_app.get_app ());
                    foreach (var key in apps_info_list.keys) {
                        if (apps_info_list.get (key).get_id ().replace (".desktop", "") == flatpak_app.get_app ()) {
                            set_flatpak_name_icon (process, apps_info_list.get (key).get_icon (), apps_info_list.get (key).get_name ());
                        }
                    }
                }
            }

            foreach (var key in apps_info_list.keys) {
                if (apps_info_list.get (key).get_executable () == command_sanitized) {
                    process.application_name = apps_info_list.get (key).get_name ();
                    process.icon = apps_info_list.get (key).get_icon ();
                } else if (apps_info_list.get (key).get_executable () == process.command.split (" ")[1]) {
                    process.application_name = apps_info_list.get (key).get_name ();
                    process.icon = apps_info_list.get (key).get_icon ();
                } else if (key.split (" ")[1] != null) {
                    if (key.split (" ")[1].contains ("%") || key.split (" ")[1].contains ("--")) {
                        if (apps_info_list.get (key).get_executable () == command_sanitized_basename) {
                            process.application_name = apps_info_list.get (key).get_name ();
                            process.icon = apps_info_list.get (key).get_icon ();
                            return true;
                        }
                    }

                    // Steam case
                    // Must match a proper executable and not game executable e.g. steam steam://rungameid/210770
                    if ((Path.get_basename (key.split (" ")[0]) == command_sanitized_basename) && !key.split (" ")[1].contains ("steam")) {
                        process.application_name = apps_info_list.get (key).get_name ();
                        process.icon = apps_info_list.get (key).get_icon ();
                        return true;
                    }

                    // workaround for some flatpak apps
                    if (process.command.contains (apps_info_list.get (key).get_id ().replace (".desktop", ""))) {
                        process.application_name = apps_info_list.get (key).get_name ();
                        process.icon = apps_info_list.get (key).get_icon ();
                        return true;
                    }
                } else if (apps_info_list.get (key).get_commandline () == process.command) {
                    process.application_name = apps_info_list.get (key).get_name ();
                    process.icon = apps_info_list.get (key).get_icon ();
                    return true;


                } else if (process.command.split (" ")[0].contains (".exe")) {
                    var splitted = process.command.split (" ")[0].split ("\\");
                    process.application_name = splitted[splitted.length - 1].chomp ();
                    process.icon = new ThemedIcon ("application-x-ms-dos-executable");
                    return true;
                }
                // some processes have semicolon in command
                // do not sanitize to improve readability
                else if (process.command.split (" ")[0].contains (":")) {
                    process.application_name = process.command;
                    return true;
                }
            }

            if (ProcessUtils.is_shell (command_sanitized_basename)) {
                process.icon = new ThemedIcon ("bash");
                debug ("app name is " + process.application_name);
            }
            if (command_sanitized_basename == "docker" || command_sanitized_basename == "dockerd" || command_sanitized_basename == "docker-proxy") {
                process.icon = new ThemedIcon ("docker");
                process.application_name = command_sanitized_basename;
                debug ("app name is " + process.application_name);
            }

            // process.application_name = process.command;

            return true;
        }

        /**
         * Parses a pid and adds a Process to our `process_list` or to the `kernel_blacklist`
         *
         * returns the created process
         */
        private Process ? add_process (int pid, bool lazy_signal = false) {
            // create the process
            var process = new Process (pid);

            if (!process.exists) {
                return null;
            }

            this.match_process_app (process);

            if (process.exists) {
                if (process.stat.pgrp != 0) {
                    // regular process, add it to our cache
                    process_list.set (pid, process);

                    // call the signal, lazily if needed
                    if (lazy_signal)
                        Idle.add (() => { process_added (process); return false; });
                    else
                        process_added (process);

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
            } else if (kernel_process_blacklist.contains (pid)) {
                kernel_process_blacklist.remove (pid);
            }
        }

    }
}
