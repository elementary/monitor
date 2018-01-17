namespace Monitor {

    // can't use TreeIter in HashMap for some reason, wrap it in a class
    public class ApplicationProcessRow {
        public Gtk.TreeIter iter;
        public ApplicationProcessRow (Gtk.TreeIter iter) { this.iter = iter; }
    }

    public class ModelHelper {
        private Gtk.TreeStore model;

        public ModelHelper (Gtk.TreeStore model) { this.model = model; }

        public void set_static_columns (Gtk.TreeIter iter, string icon, string name, int pid=0) {
            model.set (iter,
                ProcessColumns.NAME, name,
                ProcessColumns.ICON, icon,
                ProcessColumns.PID, pid,
                -1);
        }

        public void set_dynamic_columns (Gtk.TreeIter iter, double cpu, uint64 mem) {
            model.set (iter,
                ProcessColumns.CPU, cpu,
                ProcessColumns.MEMORY, mem,
                -1);
        }
    }
}
