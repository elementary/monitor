


namespace elementarySystemMonitor {

    /**
     * What columns are expected for a TreeView/TreeModel for Processes
     */
    public enum ProcessColumns {
        NAME,
        CPU,
        MEMORY,
        NUM_COLUMNS
    }

    public class ProcessView : Gtk.TreeView {
        private Gtk.TreeViewColumn name_column;
        private Gtk.TreeViewColumn cpu_column;
        private Gtk.TreeViewColumn memory_column;

        /**
         * Constructs a new ProcessView
         */
        public ProcessView () {
            rules_hint = true;

            // setup process column
            var name_cell = new Gtk.CellRendererText ();
            name_column = new Gtk.TreeViewColumn.with_attributes (_("Process"), name_cell, "text", ProcessColumns.NAME);
            name_column.fixed_width = 300;
            name_column.max_width = 300;
            insert_column (name_column, -1);

            // setup cpu column
            var cpu_cell = new Gtk.CellRendererText ();
            cpu_cell.xalign = 0.5f;
            cpu_column = new Gtk.TreeViewColumn.with_attributes (_("CPU (%)"), cpu_cell, "text", ProcessColumns.CPU);
            cpu_column.alignment = 0.5f;
            insert_column (cpu_column, -1);

            // setup memory column
            var memory_cell = new Gtk.CellRendererText ();
            memory_cell.xalign = 0.5f;
            memory_column = new Gtk.TreeViewColumn.with_attributes (_("Memory (MiB)"), memory_cell, "text", ProcessColumns.MEMORY);
            memory_column.alignment = 0.5f;
            insert_column (memory_column, -1);

            // resize all of the columns
            columns_autosize ();
        }
    }
}
