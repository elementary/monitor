public class Monitor.ProcessView : Gtk.Box {
    public CPUProcessTreeView process_tree_view;
    public ProcessInfoView process_info_view;

    construct {

        process_info_view = new ProcessInfoView ();
        
    }

    public ProcessView(CPUProcessTreeView process_tree_view) {

        // making tree view scrollable
        var process_tree_view_scrolled = new Gtk.ScrolledWindow (null, null);
        process_tree_view_scrolled.add (process_tree_view);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (process_tree_view_scrolled, false, false);
        paned.pack2 (process_info_view, false, false);
        paned.set_position (500);
        paned.set_hexpand (true);
        
        add (paned);
    }
}