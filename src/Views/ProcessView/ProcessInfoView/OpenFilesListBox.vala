public class Monitor.OpenFilesListBox : Gtk.ListBox {
    public OpenFilesListBox () {
        set_selection_mode (Gtk.SelectionMode.NONE);
        vexpand = true;
        
    }

    public void update (Process process) {
        // removeing all "rows"
        // probably should be done with model
        foreach (Gtk.Widget element in get_children ())
            remove (element);

        foreach (var path in process.open_files_paths) {
            var path_label = new Gtk.Label (path);
            debug (path);
            //  row.add (path_label);
            add (path_label);
        }
        show_all();
    }
}