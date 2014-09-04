


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
        private Gee.Map<string, Gee.Set<int>> app_pids;
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

            model = new Gtk.TreeStore (ProcessColumns.NUM_COLUMNS, typeof (string), typeof (string), typeof (string));
            model.append (out background_applications, null);
            model.set (background_applications, 0, _("Background Applications"), 1, "", 2, "", -1);

            matcher = Bamf.Matcher.get_default ();

            app_rows = new Gee.HashMap<string, ApplicationProcessRow> ();
            process_rows = new Gee.HashMap<int, ApplicationProcessRow> ();
            app_pids = new Gee.HashMap<string, Gee.Set<int>> ();

            // handle views closing and opening
            matcher.view_opened.connect (handle_view_opened);
            matcher.view_closed.connect (handle_view_closed);

            // handle processes being added and removed
            process_monitor.process_added.connect (handle_process_added);
            process_monitor.process_removed.connect (handle_process_removed);
            process_monitor.updated.connect (handle_monitor_update);

            // run when application is done loading to populate list
            Idle.add (() => { add_running_applications(); return false; } );
        }

        private void handle_monitor_update () {
            foreach (var pid in process_rows.keys) {
                update_process (pid);
            }
        }

        private void handle_process_added (int pid, Process process) {
            debug ("handle_process_added %d".printf(pid));
            add_process (pid);
        }

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
            // get all running applications and add them to the tree store
            var running_applications = matcher.get_running_applications ();
            foreach (var app in running_applications) {
                add_application (app);
            }
        }

        /**
         * Adds an application to the list, assuming that it has a desktop file and that isn't already on the list.
         */
        private bool add_application (Bamf.Application app) {
            debug ("add_application %s".printf(app.get_name ()));
            string? desktop_file = app.get_desktop_file ();

            // make sure application has desktop file, if it doesn't, then we won't display it
            if (desktop_file == null || desktop_file == "" || app_rows.has_key (desktop_file)) {
                return false;
            }

            // add the application to the model
            Gtk.TreeIter iter;
            model.append (out iter, null);
            model.set (iter, 0, app.get_name (), 1, "", 2, "", -1);

            // add the application to our cache of app_rows
            var row = new ApplicationProcessRow (iter);
            app_rows.set (desktop_file, row);

            // go through the windows of the application and add all of the pids
            var windows = app.get_windows ();
            foreach (var window in windows) {
                add_process_to_application (desktop_file, iter, (int) window.get_pid ());
            }

            return true;
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

            // remove pids
            if (app_pids.has_key (desktop_file)) {
                // remove each process
                foreach (var pid in app_pids[desktop_file]) {
                    // TODO: really should reparent to background process
                    remove_process (pid);
                }
                app_pids.unset (desktop_file);
            }

            // remove row from model
            model.remove (ref iter);

            // remove row from row cache
            app_rows.unset (desktop_file);

            return true;
        }

        private string? get_desktop_file_from_pid (int pid) {
            // go through our app_pid cache and find desktop file, if it exists
            // FIXME: this is gross
            foreach (var entry in app_pids.entries) {
                foreach (var _pid in entry.value) {
                    if (pid == _pid) {
                        return entry.key;
                    }
                }
            }
            return null;
        }

        private bool add_process (int pid) {
            if (process_rows.has_key (pid)) {
                // process already in process rows
                return false;
            }

            var process = process_monitor.get_process (pid);

            if (process != null) {
                if (process.ppid > 1) {
                    // is a sub process of something
                    if (process_rows.has_key (process.ppid)) {
                        // we have the parent pid in the row cache
                        var desktop_file = get_desktop_file_from_pid (process.ppid);
                        if (desktop_file != null) {
                            // add it to that application
                            add_process_to_application (desktop_file, process_rows[process.ppid].iter, pid);
                        }
                        else {
                            warning ("Not adding process because it doesn't belong to an application");
                        }
                    }
                    else {
                        warning ("Not adding because parent process (%d) isn't in process_rows", process.ppid);
                    }
                }
                else {
                    warning ("Not adding a process because it isn't a sub process to something else");
                }

                return true;
            }

            return false;
        }

        private bool add_process_to_application (string desktop_file, Gtk.TreeIter row, int pid) {
            debug ("add_process_to_application %s %d".printf(desktop_file, pid));
            if (process_rows.has_key (pid)) {
                // TODO: deal with reparenting existing process row to this row
                return false;
            }

            var process = process_monitor.get_process (pid);

            if (process != null)
            {
                // get the application's pid list
                Gee.Set<int> pids;
                if (app_pids.has_key (desktop_file)) {
                    pids = app_pids[desktop_file];
                }
                else {
                    pids = new Gee.HashSet<int> ();
                    app_pids.set (desktop_file, pids);
                }

                // add the process to the model
                Gtk.TreeIter iter;
                model.append (out iter, row);
                model.set (iter, 0, process.command, 1, "%0.f%%".printf (process.cpu_usage * 100.0), 2, "%0.2f MiB".printf (process.mem_usage / 1024.0), -1);

                // add all subprocesses to this row
                var sub_processes = process_monitor.get_sub_processes (pid);
                foreach (var sub_pid in sub_processes) {
                    add_process_to_application (desktop_file, iter, sub_pid);
                }

                // add the process to our cache of process_rows
                var process_row = new ApplicationProcessRow (iter);
                process_rows.set (pid, process_row);

                // add this pid to the application pid list
                pids.add (pid);
            }

            return true;
        }

        private void remove_process (int pid) {
            debug ("remove process %d".printf(pid));
            // if process rows has pid
            if (process_rows.has_key (pid)) {
                var row = process_rows.get (pid);
                var iter = row.iter;

                // remove row from model
                model.remove (ref iter);

                // remove row from row cache
                process_rows.unset (pid);
            }
        }

        private void update_process (int pid) {
            Gtk.TreeIter row;
            var process = process_monitor.get_process (pid);

            if (process_rows.has_key (pid) && process != null) {
                row = process_rows[pid].iter;
                model.set (row, 0, process.command, 1, "%0.f%%".printf (process.cpu_usage * 100.0), 2, "%0.2f MiB".printf (process.mem_usage / 1024.0), -1);
            }
        }
    }
}
