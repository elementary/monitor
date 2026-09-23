/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public class Monitor.ProcessTreeView : Granite.Bin {
    public TreeViewModel model { private get; construct; }

    public ProcessTreeView (TreeViewModel model) {
        Object (model: model);
    }

    construct {
        var name_item_factory = new Gtk.SignalListItemFactory ();
        name_item_factory.setup.connect (setup_name_item);
        name_item_factory.bind.connect (bind_name_item);

        var cpu_item_factory = new Gtk.SignalListItemFactory ();
        cpu_item_factory.setup.connect (setup_label_item);
        cpu_item_factory.bind.connect (bind_cpu_item);
        cpu_item_factory.unbind.connect ((obj) => unbind_label_item (obj, "cpu"));

        var memory_item_factory = new Gtk.SignalListItemFactory ();
        memory_item_factory.setup.connect (setup_label_item);
        memory_item_factory.bind.connect (bind_memory_item);
        memory_item_factory.unbind.connect ((obj) => unbind_label_item (obj, "memory"));

        var gpu_item_factory = new Gtk.SignalListItemFactory ();
        gpu_item_factory.setup.connect (setup_label_item);
        gpu_item_factory.bind.connect (bind_gpu_item);
        gpu_item_factory.unbind.connect ((obj) => unbind_label_item (obj, "gpu"));

        var pid_item_factory = new Gtk.SignalListItemFactory ();
        pid_item_factory.setup.connect (setup_label_item);
        pid_item_factory.bind.connect (bind_pid_item);
        pid_item_factory.unbind.connect ((obj) => unbind_label_item (obj, "pid"));

        var name_column = new Gtk.ColumnViewColumn (_("Process Name"), name_item_factory) {
            sorter = model.str_sorter ("name"),
            expand = true
        };

        var cpu_column = new Gtk.ColumnViewColumn (_("CPU"), cpu_item_factory) {
            sorter = model.num_sorter ("cpu")
        };

        var mem_column = new Gtk.ColumnViewColumn (_("Memory"), memory_item_factory) {
            sorter = model.num_sorter ("memory")
        };

        var gpu_column = new Gtk.ColumnViewColumn (_("GPU"), gpu_item_factory) {
            sorter = model.num_sorter ("gpu"),
            expand = false
        };

        var pid_column = new Gtk.ColumnViewColumn (_("PID"), pid_item_factory) {
            sorter = model.num_sorter ("pid")
        };

        var column_view = new Gtk.ColumnView (model.selection_model) {
            reorderable = false
        };
        column_view.append_column (name_column);
        column_view.append_column (cpu_column);
        column_view.append_column (mem_column);

        // Prevent adding the GPU column, if GPU was not detected
        var resources = Resources.get_default ();
        if (resources.gpu_list.size > 0) {
            column_view.append_column (gpu_column);
        }

        column_view.append_column (pid_column);

        model.sorter = column_view.sorter;

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = column_view
        };

        child = scrolled_window;
    }

    private void setup_name_item (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        cell.child = new ProcessTreeViewNameCell ();
    }

    private void bind_name_item (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var item = (ProcessRowData) cell.item;

        var name_cell = (ProcessTreeViewNameCell) cell.child;
        name_cell.label.label = item.name;
        name_cell.icon.gicon = item.icon;
    }

    private void setup_label_item (Object object) {
        var label = new Gtk.Label (Utils.NO_DATA) {
            halign = START
        };
        label.add_css_class (Granite.CssClass.NUMERIC);

        var cell = (Gtk.ColumnViewCell) object;
        cell.child = label;
    }

    private void bind_cpu_item (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;

        item.bindings.set ("cpu", item.bind_property ("cpu", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            double percentage = from_val.get_double ();
            to_val.set_string ("%.2f%%".printf (percentage));
            return true;
        }));
    }

    private void bind_memory_item (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;

        item.bindings.set ("memory", item.bind_property ("memory", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            to_val.set_string (format_size (from_val.get_uint64 () * 1024, IEC_UNITS));
            return true;
        }));
    }

    private void bind_pid_item (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;

        item.bindings.set ("pid", item.bind_property ("pid", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            to_val.set_string ("%d".printf (from_val.get_int ()));
            return true;
        }));
    }

    private void bind_gpu_item (Object object) {
        var cell = (Gtk.ColumnViewCell) object;
        var label = (Gtk.Label) cell.child;
        var item = (ProcessRowData) cell.item;
        item.bindings.set ("gpu", item.bind_property ("gpu", label, "label", SYNC_CREATE, (_, from_val, ref to_val) => {
            double percentage = from_val.get_double ();
            to_val.set_string ("%.2f%%".printf (percentage));
            return true;
        }));
    }

    private void unbind_label_item (Object object, string key) {
        var cell = (Gtk.ColumnViewCell) object;

        var item = (ProcessRowData) cell.item;
        item.bindings[key].unbind ();

        var label = (Gtk.Label) cell.child;
        label.label = Utils.NO_DATA;
    }
}
