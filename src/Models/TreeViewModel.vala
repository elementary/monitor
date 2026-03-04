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

public class Monitor.ProcessRowData : GLib.Object {
    public Icon icon { get; set; }
    public string name { get; set; }
    public int cpu { get; set; }
    public uint64 memory { get; set; }
    public int pid { get; set; }
    public string cmd { get; set; }
}

public class Monitor.TreeViewModel : GLib.Object {
    public string needle = "";

    public ProcessManager process_manager;
    public GLib.ListStore list_store;
    public Gtk.SortListModel sorted_list;
    public Gtk.StringFilter name_filter;
    public Gtk.StringFilter cmd_filter;
    public Gtk.CustomFilter pid_filter;
    public Gtk.FilterListModel filtered_list;
    public Gtk.SingleSelection selection_model;
    private Gee.Map<int, ProcessRowData ? > process_rows;
    public signal void added_first_row ();
    public signal void process_selected (Process process);


    public Gee.MapFunc<Gtk.StringSorter, string> str_sorter = (property_name) =>
                new Gtk.StringSorter(new Gtk.PropertyExpression(typeof (ProcessRowData), null, property_name) );

    public Gee.MapFunc<Gtk.NumericSorter, string> num_sorter = (property_name) =>
                new Gtk.NumericSorter(new Gtk.PropertyExpression(typeof (ProcessRowData), null, property_name) ) {
                    sort_order = Gtk.SortType.DESCENDING
                };

    construct {
        process_rows = new Gee.HashMap<int, ProcessRowData ? > ();
        list_store = new GLib.ListStore (typeof (ProcessRowData));
        sorted_list = new Gtk.SortListModel (list_store, null);


        var expression = new Gtk.PropertyExpression (typeof (ProcessRowData), null, "name");
        name_filter = new Gtk.StringFilter (expression) {
            ignore_case = true,
            match_mode = SUBSTRING,
            search = needle
        };

        cmd_filter = new Gtk.StringFilter (new Gtk.PropertyExpression (typeof (ProcessRowData), null, "cmd")) {
            ignore_case = true,
            match_mode = SUBSTRING,
            search = needle
        };

        // since the pid property is an int, we need to use a custom filter to convert it to a string
        pid_filter = new Gtk.CustomFilter ((obj) => {
            var item = (ProcessRowData) obj;
            bool pid_found = item.pid.to_string ().contains (needle.casefold ()) || false;
            return pid_found;
        });

        var any_filter = new Gtk.AnyFilter ();
        any_filter.append (name_filter);
        any_filter.append (cmd_filter);
        any_filter.append (pid_filter);

        filtered_list = new Gtk.FilterListModel (sorted_list, any_filter);

        selection_model = new Gtk.SingleSelection (filtered_list) {
            autoselect = true
        };

        selection_model.notify["selected-item"].connect ((sender, property) => {
            var row_data = selection_model.get_selected_item () as ProcessRowData;
            Process process = process_manager.get_process (row_data.pid);
            process_selected (process);
        });

        //  set_column_types (new Type[] {
        //      typeof (string),
        //      typeof (string),
        //      typeof (double),
        //      typeof (int64),
        //      typeof (int),
        //      typeof (string),
        //  });

        process_manager = ProcessManager.get_default ();
        process_manager.process_added.connect ((process) => add_process (process));
        process_manager.process_removed.connect ((pid) => remove_process (pid));
        process_manager.updated.connect (update_model);

        Idle.add (() => { add_running_processes (); return false; });
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
            //  Gtk.TreeIter iter;
            //  append (out iter, null); // null means top-level
            var row = new ProcessRowData () {
                icon = process.icon,
                name = process.application_name,
                cpu = (int) process.cpu_percentage,
                memory = process.mem_usage,
                pid = process.stat.pid,
                cmd = process.command
            };

            list_store.append (row);

            if (process_rows.size < 1) {
                added_first_row ();
            }
            // add the process to our cache of process_rows
            process_rows.set (process.stat.pid, row);
            return true;
        }
        return false;
    }

    private void update_model () {
        foreach (int pid in process_rows.keys) {
            Process process = process_manager.get_process (pid);
            var process_row = process_rows.get (pid);

            uint pos;
            if (list_store.find (process_row, out pos)) {
                var item = list_store.get_item (pos) as ProcessRowData;
                item.cpu = (int) process.cpu_percentage;
                item.memory = process.mem_usage;
                list_store.items_changed (pos, 1, 1);
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
            if (list_store.find (process_row, out pos)) {
                list_store.remove (pos);
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
