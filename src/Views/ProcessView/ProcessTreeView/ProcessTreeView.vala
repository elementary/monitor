
public class Monitor.ProcessTreeView : Granite.Bin {
    private Gtk.ColumnView list;

    public signal void process_selected (Process process);


    // private new TreeViewModel model;
    public ProcessTreeView (TreeViewModel model) {

        var sorted_list = new Gtk.SortListModel (model.list_store, null);

        var selection_model = new Gtk.SingleSelection (sorted_list) {
            autoselect = true
        };

        selection_model.selection_changed.connect ((position, n_items) => {
            var row_data = selection_model.get_selected_item () as ProcessRowData;
            Process process = model.process_manager.get_process (row_data.pid);
            process_selected (process);
        });

        list = new Gtk.ColumnView (selection_model) {
            name = "monitor-process-column-view",
            reorderable = false,
            hexpand = true,
            vexpand = true
        };

        var row_factory = new Gtk.SignalListItemFactory ();

        row_factory.setup.connect ((factory, obj) => {
            var row = obj as Gtk.ColumnViewRow;
        });

        list.row_factory = row_factory;

        child = new Gtk.ScrolledWindow () {
            child = list
        };

        var name_item_factory = new Gtk.SignalListItemFactory ();
        var cpu_item_factory = new Gtk.SignalListItemFactory ();
        var memory_item_factory = new Gtk.SignalListItemFactory ();
        var pid_item_factory = new Gtk.SignalListItemFactory ();


        name_item_factory.setup.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            cell.child = new Gtk.Label (Utils.NO_DATA) {
                hexpand = true,
                halign = Gtk.Align.START
            };
        });

        name_item_factory.bind.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            var label = cell.child as Gtk.Label;
            var item = cell.item as ProcessRowData;
            label.set_text (item.name);
        });

        var name_column = new Gtk.ColumnViewColumn (_("Process Name"), name_item_factory) {
            sorter = model.str_sorter ("name")
        };
        list.append_column (name_column);
        sorted_list.sorter = list.sorter;

        cpu_item_factory.setup.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            cell.child = new Gtk.Label (Utils.NO_DATA) {
                hexpand = true,
                halign = Gtk.Align.START
            };
        });

        cpu_item_factory.bind.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            var label = cell.child as Gtk.Label;
            var item = cell.item as ProcessRowData;
            label.set_text ("%.0f%%".printf (item.cpu));
        });

        var cpu_column = new Gtk.ColumnViewColumn (_("CPU"), cpu_item_factory) {
            sorter = model.num_sorter ("cpu"),
            expand = false
        };
        list.append_column (cpu_column);

        memory_item_factory.setup.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            cell.child = new Gtk.Label (Utils.NO_DATA) {
                hexpand = true,
                halign = Gtk.Align.START
            };
        });

        memory_item_factory.bind.connect ((factory, obj) => {
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

        var mem_column = new Gtk.ColumnViewColumn (_("Memory"), memory_item_factory) {
            sorter = model.num_sorter ("memory"),
            expand = false
        };
        list.append_column (mem_column);

        pid_item_factory.setup.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            cell.child = new Gtk.Label (Utils.NO_DATA) {
                hexpand = true,
                halign = Gtk.Align.START
            };
        });

        pid_item_factory.bind.connect ((factory, obj) => {
            var cell = obj as Gtk.ColumnViewCell;
            var label = cell.child as Gtk.Label;
            var item = cell.item as ProcessRowData;
            label.set_text ("%d".printf (item.pid));
        });

        var pid_column = new Gtk.ColumnViewColumn (_("PID"), pid_item_factory) {
            sorter = model.num_sorter ("pid"),
            expand = false
        };
        list.append_column (pid_column);

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
