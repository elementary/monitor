
public class Monitor.ProcessTreeView : Granite.Bin {
    private Gtk.ColumnView list;

    public ProcessTreeView (TreeViewModel model) {

        list = new Gtk.ColumnView (model.selection_model) {
            name = "monitor-process-column-view",
            reorderable = false,
            hexpand = true,
            vexpand = true
        };
        model.sorter = list.sorter;

        child = new Gtk.ScrolledWindow () {
            child = list
        };

        var name_item_factory = new Gtk.SignalListItemFactory ();
        var cpu_item_factory = new Gtk.SignalListItemFactory ();
        var memory_item_factory = new Gtk.SignalListItemFactory ();
        var pid_item_factory = new Gtk.SignalListItemFactory ();

        name_item_factory.setup.connect ((factory, obj) => {
            var cell = (Gtk.ColumnViewCell) obj;

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4) {
                hexpand = true,
                halign = START
            };
            var icon = new Gtk.Image.from_icon_name ("application-x-executable") {
                pixel_size = 16
            };

            box.append (icon);
            box.append (new Gtk.Label (Utils.NO_DATA));
            cell.child = box;
        });

        name_item_factory.bind.connect ((factory, obj) => {
            var cell = (Gtk.ColumnViewCell) obj;
            var box = (Gtk.Box) cell.child;
            var label = (Gtk.Label) box.get_last_child ();
            var icon = (Gtk.Image) box.get_first_child ();

            var item = (ProcessRowData) cell.item;
            label.label = item.name;
            icon.gicon = item.icon;
        });

        var name_column = new Gtk.ColumnViewColumn (_("Process Name"), name_item_factory) {
            sorter = model.str_sorter ("name"),
            expand = true
        };
        list.append_column (name_column);

        cpu_item_factory.setup.connect (metric_setup_factory);

        cpu_item_factory.bind.connect ((factory, obj) => {
            var cell = (Gtk.ColumnViewCell) obj;
            var label = (Gtk.Label) cell.child;
            var item = (ProcessRowData) cell.item;
            label.label = "%.0f%%".printf (item.cpu);
        });

        var cpu_column = new Gtk.ColumnViewColumn (_("CPU"), cpu_item_factory) {
            sorter = model.num_sorter ("cpu"),
            expand = false
        };
        list.append_column (cpu_column);

        memory_item_factory.setup.connect (metric_setup_factory);

        memory_item_factory.bind.connect ((factory, obj) => {
            var cell = (Gtk.ColumnViewCell) obj;
            var label = (Gtk.Label) cell.child;
            var item = (ProcessRowData) cell.item;

            label.label = format_size (item.memory, IEC_UNITS);
        });

        var mem_column = new Gtk.ColumnViewColumn (_("Memory"), memory_item_factory) {
            sorter = model.num_sorter ("memory"),
            expand = false
        };
        list.append_column (mem_column);

        pid_item_factory.setup.connect (metric_setup_factory);

        pid_item_factory.bind.connect ((factory, obj) => {
            var cell = (Gtk.ColumnViewCell) obj;
            var label = (Gtk.Label) cell.child;
            var item = (ProcessRowData) cell.item;
            label.label = "%d".printf (item.pid);
        });

        var pid_column = new Gtk.ColumnViewColumn (_("PID"), pid_item_factory) {
            sorter = model.num_sorter ("pid"),
            expand = false
        };
        list.append_column (pid_column);

    }

    private void metric_setup_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        cell.child = new Gtk.Label (Utils.NO_DATA) {
            hexpand = true,
            halign = START
        };
    }

}
