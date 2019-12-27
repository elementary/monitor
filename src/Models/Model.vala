public class Monitor.Model : Gtk.TreeStore {
    ModelHelper helper;
    private ProcessManager process_manager;
    private Gee.Map<int, ApplicationProcessRow> process_rows;

    Gtk.TreeIter main_iter;

    construct {

        process_rows = new Gee.HashMap<int, ApplicationProcessRow> ();

        set_column_types (new Type[] {
            typeof (string),
            typeof (string),
            typeof (double),
            typeof (int64),
            typeof (int),
        });

        helper = new ModelHelper (this);

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
        if (process_rows.has_key (process.pid)) {
            // process already in process rows, no need to add
            debug ("Process %d already in model", process.pid);
            return false;
        }

        if (process != null && process.pid != 1) {
            debug ("Add process %d Parent PID: %d", process.pid, process.ppid);

            if (process.ppid > 1) {
                // is a sub process of something
                if (process_rows.has_key (process.ppid)) {
                    // is a subprocess of something in the rows
                    add_process_to_row (process_rows[process.ppid].iter, process.pid);
                } else {
                    add_process_to_row (null, process.pid);
                    debug ("Is a subprocess of something but has no parent");
                }
                // if parent not in yet, then child will be added in after
            } else {
                // isn't a subprocess of anything, put it into background processes
                // it can be moved afterwards to an application
                add_process_to_row (null, process.pid);
            }

            return true;
        }

        return false;
    }

    private void update_model () {
        foreach (int pid in process_rows.keys) {
            update_process (pid);
        }
    }

    private void update_process (int pid) {
        var process = process_manager.get_process (pid);

        if (process_rows.has_key (pid) && process != null) {
            Gtk.TreeIter process_iter = process_rows[pid].iter;
            helper.set_dynamic_columns (process_iter, process.cpu_usage, process.mem_usage);
        }
    }


    private void get_children_total (Gtk.TreeIter iter, ref int64 memory, ref double cpu) {
        // go through all children and add up CPU/Memory usage
        // TODO: this is a naive way to do things
        Gtk.TreeIter child_iter;

        if (iter_children (out child_iter, iter)) {
            do {
                get_children_total (child_iter, ref memory, ref cpu);
                Value cpu_value;
                Value memory_value;
                get_value (child_iter, Column.CPU,    out cpu_value);
                get_value (child_iter, Column.MEMORY, out memory_value);
                memory += memory_value.get_int64 ();
                cpu += cpu_value.get_double ();
            } while (iter_next (ref child_iter));
        }
    }


    // THE BUG IS SOMEWHERE IN HERE
    // reparent children to background processes
    private void reparent (ref Gtk.TreeIter iter) {
        Gtk.TreeIter child_iter;
        Value pid_value_prev;

        while (iter_children (out child_iter, iter)) {
            Value pid_value;
            get_value (child_iter, Column.PID, out pid_value);
            pid_value_prev = pid_value;
            debug ("reparent %d", pid_value.get_int ());
            var iter2 = Gtk.TreeIter ();
            add_process_to_row (iter2, pid_value.get_int ());
        }
    }

    private void remove_process (int pid) {
        debug ("remove process %d from model".printf (pid));
        // if process rows has pid
        if (process_rows.has_key (pid)) {
            var row = process_rows.get (pid);
            Gtk.TreeIter iter = row.iter;

            //  debug ("remove process: user_data %d, stamp %d", (int) iter.user_data, iter.stamp);

            Value pid_value;
            get_value (iter, Column.PID, out pid_value);

            // Column.NAME, for example returns (null)
            // Column.PID return 0

            debug ("removing %d", pid_value.get_int ());

            // sometimes iter has null values
            // this potentially should prevent segfaults
            if (pid_value.get_int () != 0) {
                reparent (ref iter);
                // remove row from model
                remove (ref iter);
            }

            // remove row from row cache
            process_rows.unset (pid);
        }
    }



    // Addes a process to an existing row;
    // reparenting it and it's children if it already exists.
    private bool add_process_to_row (Gtk.TreeIter ? row, int pid) {
        var process = process_manager.get_process (pid);
        debug ("add_process_to_row pid:%d", pid);

        if (process != null) {
            // if process is already in list, then we need to reparent it and it's children
            // can't remove it now because we need to remove all of the children first.
            Gtk.TreeIter ? old_location = null;
            if (process_rows.has_key (pid)) {
                old_location = process_rows[pid].iter;
            }

            // add the process to the model
            Gtk.TreeIter iter;
            append (out iter, row);

            helper.set_static_columns (iter, "application-x-executable", process.command, process.pid);

            helper.set_dynamic_columns (iter, process.cpu_usage, process.mem_usage);

            // add the process to our cache of process_rows
            var process_row = new ApplicationProcessRow (iter);
            process_rows.set (pid, process_row);

            // add all subprocesses to this row, recursively
            var sub_processes = process_manager.get_sub_processes (pid);
            foreach (var sub_pid in sub_processes) {
                // only add subprocesses that either arn't in yet or are parented to the old location
                // i.e. skip if subprocess is already in but isn't an ancestor of this process row
                if (process_rows.has_key (sub_pid) && (
                        (old_location != null && !is_ancestor (old_location, process_rows[sub_pid].iter))
                        || old_location == null)) {
                    continue;
                }
                add_process_to_row (iter, sub_pid);
            }

            // remove old row where the process used to be
            if (old_location != null) {
                remove (ref old_location);
            }

            return true;
        }

        return false;
    }

    public void kill_process (int pid) {
        if (pid > 0) {
            var process = process_manager.get_process (pid);
            process.kill ();
            info ("Kill:%d",process.pid);
        }
    }

    public void end_process (int pid) {
        if (pid > 0) {
            var process = process_manager.get_process (pid);
            process.end ();
            info ("End:%d",process.pid);
        }
    }
}
