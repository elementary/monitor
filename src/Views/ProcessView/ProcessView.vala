/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessView : Gtk.Box {
    public TreeViewModel treeview_model { get; private set; }
    public CPUProcessTreeView process_tree_view { get; private set; }

    private ProcessInfoView process_info_view;

    construct {
        treeview_model = new TreeViewModel ();

        process_tree_view = new CPUProcessTreeView (treeview_model);
        process_tree_view.process_selected.connect ((process) => on_process_selected (process));

        var process_tree_view_scrolled = new Gtk.ScrolledWindow (null, null) {
            child = process_tree_view
        };

        process_info_view = new ProcessInfoView () {
            // hide on startup
            no_show_all = true
        };

        var paned = new Gtk.Paned (HORIZONTAL) {
            hexpand = true
        };
        paned.position = paned.max_position;
        paned.pack1 (process_tree_view_scrolled, true, false);
        paned.pack2 (process_info_view, false, false);

        add (paned);
    }

    public void on_process_selected (Process process) {
        process_info_view.process = process;
        process_info_view.no_show_all = false;
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
