/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessView : Gtk.Box {
    public string needle = "";

    public CPUProcessTreeView process_tree_view { get; private set; }

    private ProcessInfoView process_info_view;
    private TreeViewModel treeview_model;

    construct {
        treeview_model = new TreeViewModel ();

        var filter_model = new Gtk.TreeModelFilter (treeview_model, null);
        filter_model.set_visible_func (filter_func);

        var sort_model = new Gtk.TreeModelSort.with_model (filter_model);

        process_tree_view = new CPUProcessTreeView (treeview_model);
        process_tree_view.process_selected.connect ((process) => on_process_selected (process));
        process_tree_view.set_model (sort_model);

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

        notify["needle"].connect (filter_model.refilter);
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

    private bool filter_func (Gtk.TreeModel model, Gtk.TreeIter iter) {
        string name_haystack;
        int pid_haystack;
        string cmd_haystack;
        bool found = false;

        if (needle.length == 0) {
            return true;
        }

        model.get (iter, Column.NAME, out name_haystack, -1);
        model.get (iter, Column.PID, out pid_haystack, -1);
        model.get (iter, Column.CMD, out cmd_haystack, -1);

        // sometimes name_haystack is null
        if (name_haystack != null) {
            bool name_found = name_haystack.casefold ().contains (needle.casefold ()) || false;
            bool pid_found = pid_haystack.to_string ().casefold ().contains (needle.casefold ()) || false;
            bool cmd_found = cmd_haystack.casefold ().contains (needle.casefold ()) || false;
            found = name_found || pid_found || cmd_found;
        }

        Gtk.TreeIter child_iter;
        bool child_found = false;

        if (model.iter_children (out child_iter, iter)) {
            do {
                child_found = filter_func (model, child_iter);
            } while (model.iter_next (ref child_iter) && !child_found);
        }

        if (child_found && needle.length > 0) {
            process_tree_view.expand_all ();
        }

        return found || child_found;
    }
}
