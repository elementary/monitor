namespace Monitor {

    // can't use TreeIter in HashMap for some reason, wrap it in a class
        public class ApplicationProcessRow {
            public Gtk.TreeIter iter;

            public ApplicationProcessRow (Gtk.TreeIter iter) {
                this.iter = iter;
            }
    }
    public class GenericModel : Gtk.TreeStore {
        private AppManager app_manager;
        private ProcessManager process_manager;
        private Gee.Map<string, ApplicationProcessRow> app_rows;
        private Gee.Map<int, ApplicationProcessRow> process_rows;
        private Gtk.TreeIter background_apps_iter;
        public Gtk.TreeStore model { get; private set; }
        private Type[] types;
        construct {
            app_rows = new Gee.HashMap<string, ApplicationProcessRow> ();
            process_rows = new Gee.HashMap<int, ApplicationProcessRow> ();

            types = new Type[] {
                typeof (string),
                typeof (string),
                typeof (int),
                typeof (double),
                typeof (int64)
            };
            set_column_types(types);

            process_manager = ProcessManager.get_default ();
            process_manager.process_added.connect ((pid) => { add_process (pid); });
            process_manager.process_removed.connect ((pid) => { remove_process (pid); });
            process_manager.updated.connect (update_model);

            app_manager = AppManager.get_default ();
            app_manager.application_opened.connect ((app) => { add_app (app); });
            app_manager.application_closed.connect ((app) => { remove_app (app); });

            Idle.add (() => { add_running_apps (); return false; } );
            Idle.add (() => { add_running_processes (); return false; } );
        }

        public GenericModel () {
            add_background_apps_row ();
        }

        private void add_running_apps () {
            debug ("add_running_applications");
            // get all running applications and add them to the tree store
            var running_applications = app_manager.get_running_applications ();
            foreach (var app in running_applications) {
                add_app (app);
            }
        }

        private void add_running_processes () {
            debug ("add_running_processes");
            var running_processes = process_manager.get_process_list ();
            foreach (var pid in running_processes.keys) {
                add_process (pid);
            }
        }

        private void update_model () {
            foreach (var pid in process_rows.keys) {
                update_process (pid);
            }

            foreach (var desktop_file in app_rows.keys) {
                update_app (desktop_file);
            }
            update_app_row (background_apps_iter);
        }

        private void update_process (int pid) {
            var process = process_manager.get_process (pid);

            if (process_rows.has_key (pid) && process != null) {
                Gtk.TreeIter process_iter = process_rows[pid].iter;
                set (process_iter,
                                ProcessColumns.CPU, process.cpu_usage,
                                ProcessColumns.MEMORY, process.mem_usage,
                                 -1);
            }
        }

        private void update_app (string desktop_file) {
            if (!app_rows.has_key (desktop_file))
                return;

            var app_iter = app_rows[desktop_file].iter;
            update_app_row (app_iter);
        }

        private void update_app_row (Gtk.TreeIter iter) {
            int64 total_mem = 0;
            double total_cpu = 0;
            get_children_total (iter, ref total_mem, ref total_cpu);
            set (iter, ProcessColumns.MEMORY, total_mem,
                             ProcessColumns.CPU, total_cpu,
                            -1);
        }

        private void get_children_total (Gtk.TreeIter iter, ref int64 memory, ref double cpu) {
            // go through all children and add up CPU/Memory usage
            // TODO: this is a naive way to do things
            Gtk.TreeIter child_iter;

            if (iter_children (out child_iter, iter)) {
                do {
                    get_children_total (child_iter, ref memory, ref cpu);
                    Value cpu_value;
                    Value memory_value;
                    get_value (child_iter, ProcessColumns.CPU, out cpu_value);
                    get_value (child_iter, ProcessColumns.MEMORY, out memory_value);
                    memory += memory_value.get_int64 ();
                    cpu += cpu_value.get_double ();
                } while (iter_next (ref child_iter));
            }
        }

        private void add_app (App app) {
            if (app_rows.has_key (app.desktop_file)) {
                // App already in application rows, no need to add
                debug ("Skip App");
                return;
            }
            // add the application to the model
            Gtk.TreeIter iter;
            append (out iter, null);
            set (iter,
                ProcessColumns.NAME, app.name,
                ProcessColumns.ICON, app.icon,
                -1);

            // add the application to our cache of app_rows
            var row = new ApplicationProcessRow (iter);
            app_rows.set (app.desktop_file, row);

            // go through the windows of the application and add all of the pids
            for (var i = 0; i < app.pids.length; i++) {
                debug ("Add App: %s %d", app.name, app.pids[i]);
                add_process_to_row (iter, app.pids[i]);
                // adds pid to application
                set (iter, ProcessColumns.PID, app.pids[i]);
            }

            update_app (app.desktop_file);
        }

        private bool remove_app (App app) {
            debug ("Remove App: %s", app.name);

            // check if desktop file is in our row cache
            if (!app_rows.has_key (app.desktop_file)) {
                return false;
            }
            var app_iter = app_rows[app.desktop_file].iter;

            // reparent children to background processes; let the ProcessManager take care of removing them
            Gtk.TreeIter child_iter;
            while (iter_children (out child_iter, app_iter)) {
                Value pid_value;
                get_value (child_iter, ProcessColumns.PID, out pid_value);
                debug ("Reparent Process to Background: %d", pid_value.get_int ());
                add_process_to_row (background_apps_iter, pid_value.get_int ());
            }

            // remove row from model
            remove (ref app_iter);

            // remove row from row cache
            app_rows.unset (app.desktop_file);

            return true;
        }

        // reparent children to background processes
        private void reparent (Gtk.TreeIter iter) {
            Gtk.TreeIter child_iter;
            while (iter_children (out child_iter, iter)) {
                Value pid_value;
                get_value (child_iter, ProcessColumns.PID, out pid_value);
                add_process_to_row (background_apps_iter, pid_value.get_int ());
            }
        }

        private void remove_process (int pid) {
            debug ("remove process %d from model".printf(pid));
            // if process rows has pid
            if (process_rows.has_key (pid)) {
                var row = process_rows.get (pid);
                var iter = row.iter;
                reparent (iter);
                // remove row from model
                remove (ref iter);
                // remove row from row cache
                process_rows.unset (pid);
            }
        }

        private bool add_process (int pid) {
            debug ("add_process %d to model", pid);
            if (process_rows.has_key (pid)) {
                // process already in process rows, no need to add
                debug ("Skipping Add Process %d", pid);
                return false;
            }

            var process = process_manager.get_process (pid);

            if (process != null && process.pid != 1) {
                debug ("Parent PID: %d", process.ppid);
                if (process.ppid > 1) {
                    // is a sub process of something
                    if (process_rows.has_key (process.ppid)) {
                        // is a subprocess of something in the rows
                        add_process_to_row (process_rows[process.ppid].iter, pid);
                    } else {
                        add_process_to_row (background_apps_iter, pid);
                        debug ("Is a subprocess of something but has no parent");
                    }
                    // if parent not in yet, then child will be added in after
                } else {
                    // isn't a subprocess of anything, put it into background processes
                    // it can be moved afterwards to an application
                    add_process_to_row (background_apps_iter, pid);
                }

                return true;
            }

            return false;
        }

        // Addes a process to an existing row;
        // reparenting it and it's children if it already exists.
        private bool add_process_to_row (Gtk.TreeIter row, int pid) {
            var process = process_manager.get_process (pid);
            debug ("add_process_to_row %d", pid);

            if (process != null) {
                // if process is already in list, then we need to reparent it and it's children
                // can't remove it now because we need to remove all of the children first.
                Gtk.TreeIter? old_location = null;
                if (process_rows.has_key (pid)) {
                    old_location = process_rows[pid].iter;
                }

                // add the process to the model
                Gtk.TreeIter iter;
                append (out iter, row);
                set (iter, ProcessColumns.NAME, process.command,
                                 ProcessColumns.ICON, "application-x-executable",
                                 ProcessColumns.PID, process.pid,
                                 ProcessColumns.CPU, process.cpu_usage,
                                 ProcessColumns.MEMORY, process.mem_usage,
                                 -1);

                // add the process to our cache of process_rows
                var process_row = new ApplicationProcessRow (iter);
                process_rows.set (pid, process_row);

                // add all subprocesses to this row, recursively
                var sub_processes = process_manager.get_sub_processes (pid);
                foreach (var sub_pid in sub_processes) {
                    // only add subprocesses that either arn't in yet or are parented to the old location
                    // i.e. skip if subprocess is already in but isn't an ancestor of this process row
                    if (process_rows.has_key (sub_pid) && (
                             (old_location != null && !is_ancestor (old_location, process_rows[sub_pid].iter))
                             || old_location == null))
                        continue;

                    add_process_to_row (iter, sub_pid);
                }

                // remove old row where the process used to be
                if (old_location != null) {
                    remove (ref old_location);
                }

                return true;
            }

            return false;
        }

        private void add_background_apps_row () {
            append (out background_apps_iter, null);
            set (background_apps_iter,
                ProcessColumns.NAME, _("Background Applications"),
                ProcessColumns.ICON, "system-run",
                ProcessColumns.MEMORY, (uint64)0,
                ProcessColumns.CPU, -4.0,
                -1);
        }
    }

}
