public class Monitor.ProcessView : Gtk.Box {
    public TreeViewModel treeview_model;
    public CPUProcessTreeView process_tree_view;

    public ProcessInfoView process_info_view;

    construct {
        process_info_view = new ProcessInfoView ();

        // hide on startup
        process_info_view.no_show_all = true;
    }

    public ProcessView () {
        treeview_model = new TreeViewModel ();

        process_tree_view = new CPUProcessTreeView (treeview_model);
        process_tree_view.process_selected.connect ((process) => on_process_selected (process));

        // making tree view scrollable
        var process_tree_view_scrolled = new Gtk.ScrolledWindow (null, null);
        process_tree_view_scrolled.add (process_tree_view);

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.pack1 (process_tree_view_scrolled, true, false);
        paned.pack2 (process_info_view, false, false);
        // paned.set_min_position (200);
        paned.set_position (paned.max_position);
        paned.set_hexpand (true);

        add (paned);
    }

    public void on_process_selected (IProcess process) {
        process_info_view.process = process;
        process_info_view.no_show_all = false;
        //  process_info_view.show_all ();
    }

    public void update () {
        new Thread<bool> ("update-processes", () => {
            Idle.add (() => {
                process_info_view.update ();
                treeview_model.process_manager.update_processes.begin ();

                return false;
            });
            return true;
        });

    }

}
