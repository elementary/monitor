namespace Monitor {

    public class ModelUtils {
        private Gtk.TreeStore model;

        public ModelUtils (Gtk.TreeStore _model) {
            model = _model;
        }

        public void set_static_columns (Gtk.TreeIter iter, string icon, string name, int pid) {
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
