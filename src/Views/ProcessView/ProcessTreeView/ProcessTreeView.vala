
public class Monitor.ProcessTreeView : Granite.Bin {
    private Gtk.ColumnView list;

    // private new TreeViewModel model;
    public ProcessTreeView (TreeViewModel model) {

        // model = new Gtk.TreeListModel();
        // Constructor implementation


        var sorted_list = new Gtk.SortListModel (model.list_store, null);

        var selection_model = new Gtk.SingleSelection (sorted_list) {
            autoselect = true
        };


        list = new Gtk.ColumnView (selection_model) {
            name = "monitor-process-column-view",
            reorderable = false,
            hexpand = false,
            vexpand = true
        };

        var row_factory = new Gtk.SignalListItemFactory ();

        row_factory.setup.connect ((factory, obj) => {
            var row = obj as Gtk.ColumnViewRow;
            row.focusable = false;
            row.activatable = false;
        });

        list.row_factory = row_factory;

        child = new Gtk.ScrolledWindow () {
            child = list
        };


        var proc_name_factory = new Gtk.SignalListItemFactory ();
        proc_name_factory.setup.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            cell.child = new Gtk.Label (Utils.NO_DATA) {
                hexpand = true,
                halign = Gtk.Align.START
            };
        });

        proc_name_factory.bind.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            var label = cell.child as Gtk.Label;
            var item = cell.item as ProcessRowData;
            label.set_text (item.name);
        });

        var name_column = new Gtk.ColumnViewColumn (_("Process Name"), proc_name_factory) {
            sorter = model.str_sorter ("name")
        };
        list.append_column (name_column);
        sorted_list.sorter = list.sorter;

        var proc_cpu_factory = new Gtk.SignalListItemFactory ();
        proc_cpu_factory.setup.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            cell.child = new Gtk.Label (Utils.NO_DATA) {
                hexpand = true,
                halign = Gtk.Align.START
            };
        });

        proc_cpu_factory.bind.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            var label = cell.child as Gtk.Label;
            var item = cell.item as ProcessRowData;
            label.set_text ("%.0f%%".printf (item.cpu));
        });

        var cpu_column = new Gtk.ColumnViewColumn (_("CPU"), proc_cpu_factory) {
            sorter = model.num_sorter ("cpu"),
            expand = false
        };
        list.append_column (cpu_column);

        var proc_mem_factory = new Gtk.SignalListItemFactory ();
        proc_mem_factory.setup.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            cell.child = new Gtk.Label (Utils.NO_DATA) {
                hexpand = true,
                halign = Gtk.Align.START
            };
        });

        proc_mem_factory.bind.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            var label = cell.child as Gtk.Label;
            var item = cell.item as ProcessRowData;

            double memory_usage_double = (double) item.memory;
            string units = _("KiB");

            // convert to MiB if needed
            if (memory_usage_double > 1024.0) {
                memory_usage_double /= 1024.0;
                units = _("MiB");
            }

            // convert to GiB if needed
            if (memory_usage_double > 1024.0) {
                memory_usage_double /= 1024.0;
                units = _("GiB");
            }

            label.set_text ("%.1f %s".printf (memory_usage_double, units));
        });

        var mem_column = new Gtk.ColumnViewColumn (_("Memory"), proc_mem_factory) {
            sorter = model.num_sorter ("memory"),
            expand = false
        };
        list.append_column (mem_column);

    }

    public void collapse_all () {
        // Method implementation
    }

    public void focus_on_child_row () {
        // Method implementation
    }

    public void focus_on_first_row () {
        // Method implementation
    }

}
