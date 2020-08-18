public class Monitor.CPUProcessTreeView : Gtk.TreeView {
    private new TreeViewModel model;
    private Gtk.TreeViewColumn name_column;
    private Gtk.TreeViewColumn pid_column;
    private Gtk.TreeViewColumn cpu_column;
    private Gtk.TreeViewColumn memory_column;
    private Regex ? regex;

    public signal void process_selected (Process process);

    public CPUProcessTreeView (TreeViewModel model) {
        this.model = model;
        regex = /(?i:^.*\.(xpm|png)$)/;

        // setup name column
        name_column = new Gtk.TreeViewColumn ();
        name_column.title = _("Process Name");
        name_column.expand = true;
        name_column.min_width = 250;
        name_column.set_sort_column_id (Column.NAME);

        var icon_cell = new Gtk.CellRendererPixbuf ();
        name_column.pack_start (icon_cell, false);
        // name_column.add_attribute (icon_cell, "icon_name", Column.ICON);
        name_column.set_cell_data_func (icon_cell, icon_cell_layout);

        var name_cell = new Gtk.CellRendererText ();
        name_cell.ellipsize = Pango.EllipsizeMode.END;
        name_cell.set_fixed_height_from_font (1);
        name_column.pack_start (name_cell, false);
        name_column.add_attribute (name_cell, "text", Column.NAME);
        insert_column (name_column, -1);

        // setup cpu column
        var cpu_cell = new Gtk.CellRendererText ();
        cpu_cell.xalign = 0.5f;

        cpu_column = new Gtk.TreeViewColumn.with_attributes (_ ("CPU"), cpu_cell);
        cpu_column.expand = false;
        cpu_column.set_cell_data_func (cpu_cell, cpu_usage_cell_layout);
        cpu_column.alignment = 0.5f;
        cpu_column.set_sort_column_id (Column.CPU);
        insert_column (cpu_column, -1);

        // setup memory column
        var memory_cell = new Gtk.CellRendererText ();
        memory_cell.xalign = 0.5f;

        memory_column = new Gtk.TreeViewColumn.with_attributes (_ ("Memory"), memory_cell);
        memory_column.expand = false;
        memory_column.set_cell_data_func (memory_cell, memory_usage_cell_layout);
        memory_column.alignment = 0.5f;
        memory_column.set_sort_column_id (Column.MEMORY);
        insert_column (memory_column, -1);

        // setup PID column
        var pid_cell = new Gtk.CellRendererText ();
        pid_cell.xalign = 0.5f;
        pid_column = new Gtk.TreeViewColumn.with_attributes (_ ("PID"), pid_cell);
        pid_column.set_cell_data_func (pid_cell, pid_cell_layout);
        pid_column.expand = false;
        pid_column.alignment = 0.5f;
        pid_column.set_sort_column_id (Column.PID);
        pid_column.add_attribute (pid_cell, "text", Column.PID);
        insert_column (pid_column, -1);

        // resize all of the columns
        columns_autosize ();

        set_model (model);


        cursor_changed.connect (_cursor_changed);
        //  model.process_manager.updated.connect (_cursor_changed);
    }
    public void icon_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer icon_cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
        Value icon_name;
        model.get_value (iter, Column.ICON, out icon_name);
        string path = ((string)icon_name);

        if (regex.match (path)) {

            try {
                Gdk.Pixbuf icon = new Gdk.Pixbuf.from_file_at_size (path, 16, -1);
                ((Gtk.CellRendererPixbuf)icon_cell).pixbuf = icon;
            } catch (Error e) {
                warning (e.message);
            }
        } else {
            ((Gtk.CellRendererPixbuf)icon_cell).icon_name = path;
        }
    }

    public void cpu_usage_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
        // grab the value that was store in the model and convert it down to a usable format
        Value cpu_usage_value;
        model.get_value (iter, Column.CPU, out cpu_usage_value);
        double cpu_usage = cpu_usage_value.get_double ();

        // format the double into a string
        if (cpu_usage < 0.0)
            ((Gtk.CellRendererText)cell).text = Utils.NO_DATA;
        else
            ((Gtk.CellRendererText)cell).text = "%.0f%%".printf (cpu_usage);
    }

    public void memory_usage_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
        // grab the value that was store in the model and convert it down to a usable format
        Value memory_usage_value;
        model.get_value (iter, Column.MEMORY, out memory_usage_value);
        int64 memory_usage = memory_usage_value.get_int64 ();
        double memory_usage_double = (double)memory_usage;
        string units = _ ("KiB");

        // convert to MiB if needed
        if (memory_usage_double > 1024.0) {
            memory_usage_double /= 1024.0;
            units = _ ("MiB");
        }

        // convert to GiB if needed
        if (memory_usage_double > 1024.0) {
            memory_usage_double /= 1024.0;
            units = _ ("GiB");
        }

        // format the double into a string
        if (memory_usage == 0)
            ((Gtk.CellRendererText)cell).text = Utils.NO_DATA;
        else
            ((Gtk.CellRendererText)cell).text = "%.1f %s".printf (memory_usage_double, units);
    }

    private void pid_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
        Value pid_value;
        model.get_value (iter, Column.PID, out pid_value);
        int pid = pid_value.get_int ();
        // format the double into a string
        if (pid == 0) {
            ((Gtk.CellRendererText)cell).text = Utils.NO_DATA;
        }
    }

    public void focus_on_first_row () {
        Gtk.TreePath tree_path = new Gtk.TreePath.from_indices (0);
        this.set_cursor (tree_path, null, false);
        grab_focus ();
    }

    public void focus_on_child_row () {
        Gtk.TreePath tree_path = new Gtk.TreePath.from_indices (0, 0);
        this.set_cursor (tree_path, null, false);
        grab_focus ();
    }

    public int get_pid_of_selected () {
        Gtk.TreeIter iter;
        Gtk.TreeModel model;
        int pid = 0;
        var selection = this.get_selection ().get_selected_rows (out model).nth_data (0);
        model.get_iter (out iter, selection);
        model.get (iter, Column.PID, out pid);
        return pid;
    }

    // How about GtkTreeSelection ?

    public void expanded () {
        Gtk.TreeModel model;
        var selection = this.get_selection ().get_selected_rows (out model).nth_data (0);
        this.expand_row (selection, false);
    }

    public void collapse () {
        Gtk.TreeModel model;
        var selection = this.get_selection ().get_selected_rows (out model).nth_data (0);
        this.collapse_row (selection);
    }

    public void kill_process () {
        int pid = get_pid_of_selected ();
        model.kill_process (pid);
    }

    public void end_process () {
        int pid = get_pid_of_selected ();
        model.end_process (pid);
    }

    // when row is selected send signal to update process_info_view
    public void _cursor_changed () {
        Gtk.TreeModel tree_model;
        Gtk.TreeIter iter;
        int pid = 0;
        var selection = get_selection ().get_selected_rows (out tree_model).nth_data (0);

        if (selection != null) {
            tree_model.get_iter (out iter, selection);
            tree_model.get (iter, Column.PID, out pid);
            Process process = model.process_manager.get_process (pid);
            process_selected (process);
            //  debug ("cursor changed");
        }
    }
}
