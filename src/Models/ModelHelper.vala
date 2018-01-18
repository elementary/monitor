namespace Monitor {

    public enum Column {
        ICON,
        NAME,
        CPU,
        MEMORY,
        PID,
    }

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
                Column.NAME, name,
                Column.ICON, icon,
                Column.PID, pid,
                -1);
        }

        public void set_dynamic_columns (Gtk.TreeIter iter, double cpu, uint64 mem) {
            model.set (iter,
                Column.CPU, cpu,
                Column.MEMORY, mem,
                -1);
        }
    }
}
