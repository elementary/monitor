namespace Monitor {


    public class GenericModel : Object {
        private AppManager app_manager;
        private ProcessManager process_manager;
        private Gee.Map<string, ApplicationProcessRow> app_rows;
        private Gee.Map<int, ApplicationProcessRow> process_rows;
        // private Gtk.TreeIter background_apps_iter;
        public Gtk.TreeStore model { get; private set; }

        construct {
            process_manager = ProcessManager.get_default ();
            process_manager.process_added.connect ((int pid) => { remove_process (pid); });
            process_manager.process_removed.connect (handle_process_removed);
            process_manager.updated.connect (handle_monitor_update);

            app_manager = AppManager.get_default ();
            app_manager.application_opened.connect (handle_application_opened);
            app_manager.application_closed.connect (handle_application_closed);
        }

        public GenericModel (Type[] types) {
            model = new Gtk.TreeStore.newv (types);
        }


        private void remove_process (int pid) {
            debug ("remove process %d from model".printf(pid));
            // if process rows has pid
            if (process_rows.has_key (pid)) {
                var row = process_rows.get (pid);
                var iter = row.iter;

                // reparent children to background processes; let the ProcessManager take care of removing them
                Gtk.TreeIter child_iter;
                while (model.iter_children (out child_iter, iter)) {
                    Value pid_value;
                    model.get_value (child_iter, ProcessColumns.PID, out pid_value);
                    add_process_to_row (background_apps_iter, pid_value.get_int ());
                }

                // remove row from model
                model.remove (ref iter);

                // remove row from row cache
                process_rows.unset (pid);
            }
        }
    }

}
