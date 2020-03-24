public class Monitor.OpenFilesListBox : Gtk.ListBox {
    public OpenFilesListBox () {
        set_selection_mode (Gtk.SelectionMode.NONE);
        vexpand = true;
        
    }

    public void update (Process process) {
        foreach (var path in process.open_files_paths) {
            //  Gtk.ListBoxRow row = new Gtk.ListBoxRow ();
            var path_label = new Gtk.Label (path);
            debug (path);
            //  row.add (path_label);
            add (path_label);
        }
        show_all();
    }
}