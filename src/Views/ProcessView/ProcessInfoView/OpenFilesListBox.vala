public class Monitor.OpenFilesListBox : Gtk.ScrolledWindow {
    Gtk.ListBox listbox;
    construct {
        get_style_context ().add_class ("open_files_list_box_wrapper");
        hadjustment = null;
        vadjustment = null;

        listbox = new Gtk.ListBox ();
        listbox.get_style_context ().add_class ("open_files_list_box");
        listbox.set_selection_mode (Gtk.SelectionMode.NONE);
        listbox.get_style_context ().add_class ("open_files_list_box");
        listbox.vexpand = true;

        add (listbox);
    }

    public void update (Process process) {
        // removeing all "rows"
        // probably should be done with model
        foreach (Gtk.Widget element in listbox.get_children ())
            listbox.remove (element);


        if (process.open_files_paths.size > 0) {
            foreach (var path in process.open_files_paths) {
                // display only real paths
                // probably should be done in process class
                if (path.substring (0, 1) == "/") {
                    var row = new OpenFilesListBoxRow (path, path.contains ("(deleted)"));
                    listbox.add (row);
                }
            }
        }
        show_all ();
    }

}


public class Monitor.OpenFilesListBoxRow : Gtk.ListBoxRow {
    construct {
        get_style_context ().add_class ("open_files_list_box_row");
    }
    public OpenFilesListBoxRow (string _text, bool is_deleted) {
        var text = _text;
        var grid = new Gtk.Grid ();
        grid.column_spacing = 2;

        var icon = new Gtk.Image ();
        icon.halign = Gtk.Align.START;
        icon.pixel_size = 16;
        icon.gicon = new ThemedIcon ("emblem-documents-symbolic");

        if (is_deleted) {
            icon = new Gtk.Image.from_icon_name ("file-deleted-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            icon.tooltip_text = _("Deleted");
            text = text.replace ("(deleted)", "");
        }


        grid.attach (icon, 0, 0, 1, 1);

        Gtk.Label label = new Gtk.Label (text);
        label.halign = Gtk.Align.START;
        grid.attach (label, 1, 0, 1, 1);

        add (grid);
    }
}
