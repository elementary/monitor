/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public class Monitor.ProcessTreeView : Granite.Bin {

    public ProcessTreeView (TreeViewModel model) {
        var column_view = new Gtk.ColumnView (model.selection_model) {
            name = "monitor-process-column-view",
            reorderable = false,
            hexpand = true,
            vexpand = true
        };
        model.sorter = column_view.sorter;

        var name_item_factory = new Gtk.SignalListItemFactory ();
        name_item_factory.setup.connect (name_item_factory_setup);
        name_item_factory.bind.connect (name_item_factory_bind);

        var cpu_item_factory = new Gtk.SignalListItemFactory ();
        cpu_item_factory.setup.connect (generic_item_factory_setup);
        cpu_item_factory.bind.connect (cpu_item_factory_bind);
        cpu_item_factory.unbind.connect (cpu_item_factory_unbind);

        var memory_item_factory = new Gtk.SignalListItemFactory ();
        memory_item_factory.setup.connect (generic_item_factory_setup);
        memory_item_factory.bind.connect (memory_item_factory_bind);
        memory_item_factory.unbind.connect (memory_item_factory_unbind);

        var pid_item_factory = new Gtk.SignalListItemFactory ();
        pid_item_factory.setup.connect (generic_item_factory_setup);
        pid_item_factory.bind.connect (pid_item_factory_bind);
        pid_item_factory.unbind.connect (pid_item_factory_unbind);

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

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = column_view
        };
        child = scrolled_window;
    }

    private void generic_item_factory_setup (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = new Gtk.Label (Utils.NO_DATA) {
            hexpand = true,
            halign = START
        };
        cell.child = label;
    }

    private void setup_origin (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new LogCell (ORIGIN);
    }

    private void name_item_factory_setup (Object object) {
        var item = (Gtk.ListItem) object;
        item.child = new ProcessTreeViewNameCell ();
    }

    private void name_item_factory_bind (Object object) {
        var item = (Gtk.ListItem) object;
        var process_row_data = (ProcessRowData) item.item;
        var cell = (ProcessTreeViewNameCell) item.child;
        cell.bind (process_row_data);
    }

    private void cpu_item_factory_bind (Object object) {
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

    private void cpu_item_factory_unbind (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        label.label = null;
        item.bindings["cpu"].unbind ();
    }

    private void memory_item_factory_bind (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        var binding_memory = item.bind_property ("memory", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            to_val.set_string (format_size (from_val.get_uint64 () * 1024, IEC_UNITS));
            return true;
        });
        item.bindings.set ("memory", binding_memory);
    }

    private void memory_item_factory_unbind (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        label.label = null;
        item.bindings["memory"].unbind ();
    }

    private void pid_item_factory_bind (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        var binding_pid = item.bind_property ("pid", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            to_val.set_string ("%d".printf (from_val.get_int ()));
            return true;
        });
        item.bindings.set ("pid", binding_pid);
    }

    private void pid_item_factory_unbind (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        label.label = null;
        item.bindings["pid"].unbind ();
    }

}
