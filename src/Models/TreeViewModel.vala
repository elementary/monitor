/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public enum Monitor.Column {
    ICON,
    NAME,
    CPU,
    MEMORY,
    GPU,
    PID,
    CMD,
}

public class Monitor.TreeViewModel : Gtk.TreeStore {
    public ProcessManager process_manager;
    private Gee.Map<int, Gtk.TreeIter ? > process_rows;
    public signal void added_first_row ();

    construct {
        process_rows = new Gee.HashMap<int, Gtk.TreeIter ? > ();

        set_column_types (new Type[] {
            typeof (string),
            typeof (string),
            typeof (double),
            typeof (int64),
            typeof (double),
            typeof (int),
            typeof (string),
        });

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
            Gtk.TreeIter iter;
            append (out iter, null); // null means top-level

            // donno what is going on, but maybe just use a string instead of Icon ??
            // coz it lagz
            // string icon_name = process.icon.to_string ();

            set (iter,
                 Column.NAME, process.application_name,
                 Column.ICON, process.icon.to_string (),
                 Column.PID, process.stat.pid,
                 Column.CMD, process.command,
                 -1);
            if (process_rows.size < 1) {
                added_first_row ();
            }
            // add the process to our cache of process_rows
            process_rows.set (process.stat.pid, iter);
            return true;
        }
        return false;
    }

    private void update_model () {
        foreach (int pid in process_rows.keys) {
            Process process = process_manager.get_process (pid);
            Gtk.TreeIter iter = process_rows[pid];
            set (iter,
                 Column.CPU, process.cpu_percentage,
                 Column.MEMORY, process.mem_usage,
                 Column.GPU, process.gpu_percentage,
                 -1);
        }
    }

    private void remove_process (int pid) {
        debug ("remove process %d from model".printf (pid));
        // if process rows has pid
        if (process_rows.has_key (pid)) {
            var cached_iter = process_rows.get (pid);
            remove (ref cached_iter);
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
