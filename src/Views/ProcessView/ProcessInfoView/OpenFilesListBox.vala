public class Monitor.OpenFilesListBox : Gtk.ScrolledWindow {
    Gtk.ListBox listbox;
    construct {
        get_style_context ().add_class ("open_files_list_box_wrapper");
        hadjustment = null;
        vadjustment = null;

        listbox = new Gtk.ListBox ();
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

        foreach (var path in process.open_files_paths) {
            var row = new OpenFilesListBoxRow (path);
            listbox.add (row);
        }
        show_all ();
    }
}


public class Monitor.OpenFilesListBoxRow : Gtk.ListBoxRow {
    construct {
        margin = 6;
    }
    public OpenFilesListBoxRow (string text) {
        Gtk.Label label = new Gtk.Label (text);
        label.halign = Gtk.Align.START;

        add (label);
    }
}