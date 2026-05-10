
public class Monitor.ProcessTreeView : Granite.Bin {

    public ProcessTreeView (TreeViewModel model) {

        var column_view = new Gtk.ColumnView (model.selection_model) {
            name = "monitor-process-column-view",
            reorderable = false,
            hexpand = true,
            vexpand = true
        };
        model.sorter = column_view.sorter;

        child = new Gtk.ScrolledWindow () {
            child = column_view
        };

        var name_item_factory = new Gtk.SignalListItemFactory ();
        name_item_factory.setup.connect (name_item_setup_factory);
        name_item_factory.bind.connect (name_item_bind_factory);
        name_item_factory.unbind.connect (name_item_unbind_factory);

        var cpu_item_factory = new Gtk.SignalListItemFactory ();
        cpu_item_factory.setup.connect (generic_item_setup_factory);
        cpu_item_factory.bind.connect (cpu_item_bind_factory);
        cpu_item_factory.unbind.connect (cpu_item_unbind_factory);

        var memory_item_factory = new Gtk.SignalListItemFactory ();
        memory_item_factory.setup.connect (generic_item_setup_factory);
        memory_item_factory.bind.connect (memory_item_bind_factory);
        memory_item_factory.unbind.connect (memory_item_unbind_factory);

        var pid_item_factory = new Gtk.SignalListItemFactory ();
        pid_item_factory.setup.connect (generic_item_setup_factory);
        pid_item_factory.bind.connect (pid_item_bind_factory);
        pid_item_factory.unbind.connect (pid_item_unbind_factory);


        var name_column = new Gtk.ColumnViewColumn (_("Process Name"), name_item_factory) {
            sorter = model.str_sorter ("name"),
            expand = true
        };
        column_view.append_column (name_column);

        var cpu_column = new Gtk.ColumnViewColumn (_("CPU"), cpu_item_factory) {
            sorter = model.num_sorter ("cpu"),
            expand = false
        };
        column_view.append_column (cpu_column);


        var mem_column = new Gtk.ColumnViewColumn (_("Memory"), memory_item_factory) {
            sorter = model.num_sorter ("memory"),
            expand = false
        };
        column_view.append_column (mem_column);

        var pid_column = new Gtk.ColumnViewColumn (_("PID"), pid_item_factory) {
            sorter = model.num_sorter ("pid"),
            expand = false
        };
        column_view.append_column (pid_column);

    }

    private void generic_item_setup_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        cell.child = new Gtk.Label (Utils.NO_DATA) {
            hexpand = true,
            halign = START
        };
    }

    private void name_item_setup_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;

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
    }

    private void name_item_bind_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var box = (Gtk.Box) cell.child;
        var label = (Gtk.Label) box.get_last_child ();
        var icon = (Gtk.Image) box.get_first_child ();

        var item = (ProcessRowData) cell.item;

        var binding_name = item.bind_property ("name", label, "label", SYNC_CREATE);
        item.bindings.set ("name", binding_name);

        var binding_icon = item.bind_property ("icon", icon, "gicon", SYNC_CREATE);
        item.bindings.set ("icon", binding_icon);
    }

    private void name_item_unbind_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var box = (Gtk.Box) cell.child;
        var label = (Gtk.Label) box.get_last_child ();
        var icon = (Gtk.Image) box.get_first_child ();
        label.label = null;
        icon.gicon = null;
        ((ProcessRowData) cell.item).bindings["name"].unbind ();
    }

    private void cpu_item_bind_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        var binding_cpu = item.bind_property ("cpu", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            int percentage = from_val.get_int ();
            to_val.set_string ("%.0f%%".printf (percentage));
            return true;
        });
        item.bindings.set ("cpu", binding_cpu);
    }

    private void cpu_item_unbind_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        label.label = null;
        item.bindings["cpu"].unbind ();
    }

    private void memory_item_bind_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        var binding_memory = item.bind_property ("memory", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            to_val.set_string (format_size (from_val.get_uint64 () * 1024, IEC_UNITS));
            return true;
        });
        item.bindings.set ("memory", binding_memory);
    }

        private void memory_item_unbind_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        label.label = null;
        item.bindings["memory"].unbind ();
    }

    private void pid_item_bind_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        var binding_pid = item.bind_property ("pid", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            to_val.set_string ("%d".printf (from_val.get_int ()));
            return true;
        });
        item.bindings.set ("pid", binding_pid);
    }

        private void pid_item_unbind_factory (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        label.label = null;
        item.bindings["pid"].unbind ();
    }

}
