/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public enum Monitor.Column {
    ICON,
    NAME,
    CPU,
    MEMORY,
    PID,
    CMD
}

public class Monitor.TreeViewModel : GLib.Object {

    public ProcessManager process_manager;

    public TreeViewFilter filtered;
    public Gtk.SingleSelection selection_model;

    public signal void added_first_row ();
    public signal void process_selected (Process process);

    public Gtk.Sorter sorter {
        get { return sorted.sorter; }
        set {
            sorted.sorter = value;
        }
    }

    private GLib.ListStore store;
    private Gtk.SortListModel sorted;

    private Gee.Map<int, ProcessRowData ?> process_rows;


    construct {
        process_rows = new Gee.HashMap<int, ProcessRowData ?> ();
        store = new GLib.ListStore (typeof (ProcessRowData));
        sorted = new Gtk.SortListModel (store, null);

        filtered = new TreeViewFilter (sorted);

        selection_model = new Gtk.SingleSelection (filtered.model_out) {
            autoselect = true
        };

        selection_model.notify["selected-item"].connect ((sender, property) => {
            var row_data = selection_model.get_selected_item () as ProcessRowData;
            Process process = process_manager.get_process (row_data.pid);
            process_selected (process);
        });

        process_manager = ProcessManager.get_default ();
        process_manager.process_added.connect ((process) => add_process (process));
        process_manager.process_removed.connect ((pid) => remove_process (pid));
        process_manager.updated.connect (update_model);

        Idle.add (() => { add_running_processes (); return false; });
    }

    public Gtk.StringSorter str_sorter (string column_name) {
        return new Gtk.StringSorter (new Gtk.PropertyExpression (typeof (ProcessRowData), null, column_name));
    }

    public Gtk.NumericSorter num_sorter (string column_name) {
        return new Gtk.NumericSorter (new Gtk.PropertyExpression (typeof (ProcessRowData), null, column_name)) {
            sort_order = Gtk.SortType.DESCENDING
        };
    }

    private void add_running_processes () {
        debug ("add_running_processes");
        var running_processes = process_manager.get_process_list ();
        foreach (var process in running_processes.values) {
            add_process (process);
        }
    }

    private bool add_process (Process process) {
        if (process != null && !process_rows.has_key (process.stat.pid)) {
            debug ("Add process %d Parent PID: %d", process.stat.pid, process.stat.ppid);
            // add the process to the model
            var row = new ProcessRowData () {
                icon = process.icon,
                name = process.application_name,
                cpu = (int) process.cpu_percentage,
                memory = process.mem_usage,
                pid = process.stat.pid,
                cmd = process.command
            };

            store.append (row);

            if (process_rows.size < 1) {
                added_first_row ();
            }
            // add the process to our cache of process_rows
            process_rows.set (process.stat.pid, row);
            return true;
        }
        return false;
    }

    public void update_model () {
        foreach (int pid in process_rows.keys) {
            Process process = process_manager.get_process (pid);
            var process_row = process_rows.get (pid);

            uint pos;
            if (store.find (process_row, out pos)) {
                var item = store.get_item (pos) as ProcessRowData;
                item.cpu = (int) process.cpu_percentage;
                item.memory = process.mem_usage;
                store.items_changed (pos, 1, 1);
            } else {
                debug ("Failed to find process row for pid %d", pid);
            }
        }
    }

    private void remove_process (int pid) {
        debug ("remove process %d from model".printf (pid));
        // if process rows has pid
        if (process_rows.has_key (pid)) {
            uint pos;
            var process_row = process_rows.get (pid);
            if (store.find (process_row, out pos)) {
                store.remove (pos);
            }
            process_rows.unset (pid);
        }
    }

    public void kill_process (int pid) {
        if (pid > 0) {
            var process = process_manager.get_process (pid);
            process.kill ();
            info ("Kill:%d", process.stat.pid);
        }
    }

    public void end_process (int pid) {
        if (pid > 0) {
            var process = process_manager.get_process (pid);
            process.end ();
            info ("End:%d", process.stat.pid);
        }
    }

}
