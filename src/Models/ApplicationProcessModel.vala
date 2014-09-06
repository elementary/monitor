


namespace elementarySystemMonitor {

    // can't use TreeIter in HashMap for some reason, wrap it in a class
    public class ApplicationProcessRow {
        public Gtk.TreeIter iter;

        public ApplicationProcessRow (Gtk.TreeIter iter) {
            this.iter = iter;
        }
    }

    /**
     * Using a TreeStore (model), describes the relationships between running applications
     * and their processes to be displayed in a TreeView.
     */
    public class ApplicationProcessModel : Object {
        private ProcessMonitor process_monitor;
        private Bamf.Matcher matcher;
        private Gee.Map<string, ApplicationProcessRow> app_rows;
        private Gee.Map<int, ApplicationProcessRow> process_rows;
        private Gtk.TreeIter background_applications;

        /**
         * The tree store that will be passed to a TreeView to be displayed.
         */
        public Gtk.TreeStore model { get; private set; }

        /**
         * Constuct an ApplicationProcessModel given a ProcessMonitor
         */
        public ApplicationProcessModel (ProcessMonitor _monitor) {
            process_monitor = _monitor;

            model = new Gtk.TreeStore (ProcessColumns.NUM_COLUMNS, typeof (string), typeof (string), typeof(int), typeof (double), typeof (int64));
            model.append (out background_applications, null);
            model.set (background_applications, ProcessColumns.NAME, _("Background Applications"),
                                                ProcessColumns.ICON, "system-run",
                                                ProcessColumns.MEMORY, (uint64)0,
                                                ProcessColumns.CPU, -4.0,
                                                -1);

            matcher = Bamf.Matcher.get_default ();

            app_rows = new Gee.HashMap<string, ApplicationProcessRow> ();
            process_rows = new Gee.HashMap<int, ApplicationProcessRow> ();

            // handle views closing and opening
            matcher.view_opened.connect (handle_view_opened);
            matcher.view_closed.connect (handle_view_closed);

            // handle processes being added and removed
            process_monitor.process_added.connect (handle_process_added);
            process_monitor.process_removed.connect (handle_process_removed);
            process_monitor.updated.connect (handle_monitor_update);

            // run when application is done loading to populate list
            Idle.add (() => { add_running_applications (); return false; } );
            Idle.add (() => { add_running_processes (); return false; } );
        }

        /**
         * Handles a updated signal from ProcessMonitor by refreshing all of the process rows in the list
         */
        private void handle_monitor_update () {
            foreach (var pid in process_rows.keys) {
                update_process (pid);
            }

            foreach (var desktop_file in app_rows.keys) {
                update_application (desktop_file);
            }
        }

        /**
         * Handles a process-added signal from ProcessMonitor by adding the process to our list
         */
        private void handle_process_added (int pid, Process process) {
            debug ("handle_process_added %d".printf(pid));
            add_process (pid);
        }

        /**
         * Handles a process-removed signal from ProcessMonitor by removing the process from our list
         */
        private void handle_process_removed (int pid) {
            debug ("handle_process_removed %d".printf(pid));
            remove_process (pid);
        }

        /**
         * Handle the view-opened signal from libbamf and add an application to the list when it is opened
         */
        private void handle_view_opened (Bamf.View view) {
            debug ("handle_view_opened %s".printf(view.get_name ()));
            // if the view added was an application, then add it
            var app = view as Bamf.Application;
            if (app != null) {
                add_application (app);
            }
        }

        /**
         * Handle the view-closed signal from libbamf and remove an application from the list when it is closed.
         */
        private void handle_view_closed (Bamf.View view) {
            debug ("handle_view_closed %s".printf(view.get_name ()));
            var app = view as Bamf.Application;
            if (app != null) {
                remove_application (app);
            }
        }

        /**
         * Adds all running applications to the list.
         */
        private void add_running_applications () {
            debug ("add_running_applications");
            // get all running applications and add them to the tree store
            var running_applications = matcher.get_running_applications ();
            foreach (var app in running_applications) {
                add_application (app);
            }
        }

        /**
         * Adds all running processes to the list.
         */
        private void add_running_processes () {
            debug ("add_running_processes");
            var running_processes = process_monitor.get_process_list ();
            foreach (var pid in running_processes.keys) {
                add_process (pid);
            }
        }

        /**
         * Adds an application to the list, assuming that it has a desktop file and that isn't already on the list.
         */
        private bool add_application (Bamf.Application app) {
            debug ("add_application %s".printf(app.get_name ()));
            string? desktop_file = app.get_desktop_file ();

            // make sure application has desktop file, if it doesn't, then we won't display it
            // TODO: this might be a bad decision, revisit
            if (desktop_file == null || desktop_file == "" || app_rows.has_key (desktop_file)) {
                return false;
            }

            // add the application to the model
            Gtk.TreeIter iter;
            model.append (out iter, null);
            model.set (iter, ProcessColumns.NAME, app.get_name (),
                             ProcessColumns.ICON, app.get_icon (),
                             -1);

            // add the application to our cache of app_rows
            var row = new ApplicationProcessRow (iter);
            app_rows.set (desktop_file, row);

            // go through the windows of the application and add all of the pids
            var windows = app.get_windows ();
            foreach (var window in windows) {
                add_process_to_row (iter, (int) window.get_pid ());
            }

            // update the application columns
            update_application (desktop_file);

            return true;
        }

        private void get_children_total (Gtk.TreeIter iter, ref int64 memory, ref double cpu) {
            // go through all children and add up CPU/Memory usage
            // TODO: this is a naive way to do things
            Gtk.TreeIter child_iter;
            
            if (model.iter_children (out child_iter, iter)) {
                do {
                    get_children_total (child_iter, ref memory, ref cpu);
                    Value cpu_value;
                    Value memory_value;
                    model.get_value (child_iter, ProcessColumns.CPU, out cpu_value);
                    model.get_value (child_iter, ProcessColumns.MEMORY, out memory_value);
                    memory += memory_value.get_int64 ();
                    cpu += cpu_value.get_double ();
                } while (model.iter_next (ref child_iter));
            }
        }

        private void update_application (string desktop_file) {
            if (!app_rows.has_key (desktop_file))
                return;

            var iter = app_rows[desktop_file].iter;
            int64 total_mem = 0;
            double total_cpu = 0;

            get_children_total (iter, ref total_mem, ref total_cpu);

            model.set (iter, ProcessColumns.MEMORY, total_mem,
                             ProcessColumns.CPU, total_cpu,
                             -1);
        }

        /**
         * Removes an application from the list.
         */
        private bool remove_application (Bamf.Application app) {
            debug ("remove_application %s".printf(app.get_name ()));
            string? desktop_file = app.get_desktop_file ();

            // check if desktop file is in our row cache
            if (desktop_file == null || desktop_file == "" || !app_rows.has_key (desktop_file)) {
                return false;
            }

            var row = app_rows.get (desktop_file);
            var iter = row.iter;

            // reparent children to background processes; let the ProcessMonitor take care of removing them
            Gtk.TreeIter child_iter;
            while (model.iter_children (out child_iter, iter)) {
                Value pid_value;
                model.get_value (child_iter, ProcessColumns.PID, out pid_value);
                add_process_to_row (background_applications, pid_value.get_int ());
            }

            // remove row from model
            model.remove (ref iter);

            // remove row from row cache
            app_rows.unset (desktop_file);

            return true;
        }

        /**
         * Adds a process by pid, making sure to parent it to the right process
         */
        private bool add_process (int pid) {
            debug ("add_process %d", pid);
            if (process_rows.has_key (pid)) {
                // process already in process rows, no need to add
                debug ("SKIPPING");
                return false;
            }

            var process = process_monitor.get_process (pid);

            if (process != null && process.pid != 1) {
                if (process.ppid > 1) {
                    // is a sub process of something
                    if (process_rows.has_key (process.ppid)) {
                        // is a subprocess of something in the rows
                        add_process_to_row (process_rows[process.ppid].iter, pid);
                    }
                    // if parent not in yet, then child will be added in after
                }
                else {
                    // isn't a subprocess of something, put it into background processes
                    // it can be moved afterwards to an application
                    add_process_to_row (background_applications, pid);
                }

                return true;
            }

            return false;
        }

        /**
         * Addes a process to an existing row; reparenting it and it's children it it already exists.
         */
        private bool add_process_to_row (Gtk.TreeIter row, int pid) {
            debug ("add_process_to_row %d".printf(pid));
            var process = process_monitor.get_process (pid);

            if (process != null)
            {
                // if process is already in list, then we need to reparent it and it's children
                // can't remove it now because we need to remove all of the children first.
                Gtk.TreeIter? old_location = null;
                if (process_rows.has_key (pid)) {
                    old_location = process_rows[pid].iter;
                }

                // add the process to the model
                Gtk.TreeIter iter;
                model.append (out iter, row);
                model.set (iter, ProcessColumns.NAME, process.command,
                                 ProcessColumns.ICON, "application-default-icon",
                                 ProcessColumns.PID, process.pid,
                                 ProcessColumns.CPU, process.cpu_usage,
                                 ProcessColumns.MEMORY, process.mem_usage,
                                 -1);

                // add the process to our cache of process_rows
                var process_row = new ApplicationProcessRow (iter);
                process_rows.set (pid, process_row);

                // add all subprocesses to this row, recursively
                var sub_processes = process_monitor.get_sub_processes (pid);
                foreach (var sub_pid in sub_processes) {
                    // only add subprocesses that either arn't in yet or are parented to the old location
                    // i.e. skip if subprocess is already in but isn't an ancestor of this process row
                    if (process_rows.has_key (sub_pid) && (
                             (old_location != null && !model.is_ancestor (old_location, process_rows[sub_pid].iter))
                             || old_location == null))
                        continue;

                    add_process_to_row (iter, sub_pid);
                }

                // remove old row where the process used to be
                if (old_location != null) {
                    model.remove (ref old_location);
                }

                return true;
            }

            return false;
        }

        /**
         * Removes a process from the model by pid
         */
        private void remove_process (int pid) {
            debug ("remove process %d".printf(pid));
            // if process rows has pid
            if (process_rows.has_key (pid)) {
                var row = process_rows.get (pid);
                var iter = row.iter;

                // reparent children to background processes; let the ProcessMonitor take care of removing them
                Gtk.TreeIter child_iter;
                while (model.iter_children (out child_iter, iter)) {
                    Value pid_value;
                    model.get_value (child_iter, ProcessColumns.PID, out pid_value);
                    add_process_to_row (background_applications, pid_value.get_int ());
                }

                // remove row from model
                model.remove (ref iter);

                // remove row from row cache
                process_rows.unset (pid);
            }
        }

        /**
         * Updates a process by pid
         */
        private void update_process (int pid) {
            Gtk.TreeIter row;
            var process = process_monitor.get_process (pid);

            if (process_rows.has_key (pid) && process != null) {
                row = process_rows[pid].iter;
                model.set (row, ProcessColumns.CPU, process.cpu_usage,
                                ProcessColumns.MEMORY, process.mem_usage,
                                 -1);
            }
        }
    }
}
