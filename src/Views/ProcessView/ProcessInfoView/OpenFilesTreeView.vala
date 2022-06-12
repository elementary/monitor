public class Monitor.OpenFilesTreeView : Gtk.TreeView {
    public new OpenFilesTreeViewModel model;
    private Gtk.TreeViewColumn path_column;
    private Regex ? regex;

    public signal void process_selected (Process process);

    public OpenFilesTreeView (OpenFilesTreeViewModel model) {
        this.model = model;
        /* *INDENT-OFF* */
        regex = /(?i:^.*\.(xpm|png)$)/; // vala-lint=space-before-paren,
        /* *INDENT-ON* */

        show_expanders = false;

        // setup name column
        path_column = new Gtk.TreeViewColumn ();
        path_column.title = _("Opened files");
        path_column.expand = true;
        path_column.min_width = 250;
        path_column.set_sort_column_id (Column.NAME);

        var icon_cell = new Gtk.CellRendererPixbuf ();
        path_column.pack_start (icon_cell, false);
        // path_column.add_attribute (icon_cell, "icon_name", Column.ICON);
        path_column.set_cell_data_func (icon_cell, icon_cell_layout);

        var name_cell = new Gtk.CellRendererText ();
        name_cell.ellipsize = Pango.EllipsizeMode.END;
        name_cell.set_fixed_height_from_font (1);
        path_column.pack_start (name_cell, false);
        path_column.add_attribute (name_cell, "text", Column.NAME);
        insert_column (path_column, -1);

        // resize all of the columns
        columns_autosize ();

        set_model (model);

        hadjustment = null;
        vadjustment = null;
        vexpand = true;

    }

    // public void update (Process process) {
    // model.update_model (process);
    // show_all ();
    // }

    public void icon_cell_layout (Gtk.CellLayout cell_layout, Gtk.CellRenderer icon_cell, Gtk.TreeModel model, Gtk.TreeIter iter) {
        try {
            var icon = Icon.new_for_string ("emblem-documents-symbolic");
            ((Gtk.CellRendererPixbuf)icon_cell).icon_name = icon.to_string ();
        } catch (Error e) {
            warning (e.message);
        }
    }

}
