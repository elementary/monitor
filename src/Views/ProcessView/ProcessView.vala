/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessView : Gtk.Box {
    public TreeViewModel treeview_model;
    public CPUProcessTreeView process_tree_view;

    public ProcessInfoView process_info_view;

    construct {
        process_info_view = new ProcessInfoView (){
            // This might be useless since first process is selected
            // automatically and this triggers on_process_selected ().
            // Keeping it just to not forget what was the OG behavior 
            // in GTK3 version.
            visible = false,
        };
    }

    public ProcessView () {
        treeview_model = new TreeViewModel ();

        process_tree_view = new CPUProcessTreeView (treeview_model);
        process_tree_view.process_selected.connect ((process) => on_process_selected (process));

        // making tree view scrollable
        var process_tree_view_scrolled = new Gtk.ScrolledWindow () {
            child = process_tree_view
        };

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.set_start_child (process_tree_view_scrolled);
        paned.set_end_child (process_info_view);
        paned.set_shrink_end_child (false);
        paned.set_resize_end_child (false);
        paned.set_position (paned.max_position - 200);
        paned.set_hexpand (true);

        append (paned);
    }

    public void on_process_selected (Process process) {
        process_info_view.process = process;

        process_info_view.visible = true;
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
