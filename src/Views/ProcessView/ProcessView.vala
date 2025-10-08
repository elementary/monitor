/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessView : Granite.Bin {
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

        var process_tree_view_scrolled = new Gtk.ScrolledWindow () {
            child = process_tree_view
        };

        process_info_view = new ProcessInfoView () {
            // This might be useless since first process is selected
            // automatically and this triggers on_process_selected ().
            // Keeping it just to not forget what was the OG behavior 
            // in GTK3 version.
            visible = false,
        };

        var paned = new Gtk.Paned (HORIZONTAL) {
            start_child = process_tree_view_scrolled,
            end_child = process_info_view,
            shrink_end_child = false,
            resize_end_child = false,
            hexpand = true
        };
        paned.position = paned.max_position;

        child = paned;

        notify["needle"].connect (filter_model.refilter);

        var kill_action = new SimpleAction ("kill", null);
        kill_action.activate.connect (action_kill);

        var end_action = new SimpleAction ("end", null);
        end_action.activate.connect (action_end);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (kill_action);
        action_group.add_action (end_action);

        insert_action_group ("process", action_group);

        var key_controller = new Gtk.EventControllerKey ();
        key_controller.key_pressed.connect ((keyval, keycode, state) => {
            if ((state & Gdk.ModifierType.CONTROL_MASK) != 0) {
                switch (keyval) {
                    case Gdk.Key.k:
                        activate_action ("process.kill", null);
                        return Gdk.EVENT_STOP;
                    case Gdk.Key.e:
                        activate_action ("process.end", null);
                        return Gdk.EVENT_STOP;
                }
            }

            return Gdk.EVENT_PROPAGATE;
        });

        add_controller (key_controller);
    }

    private void action_end () {
        var confirmation_dialog = new Granite.MessageDialog (
            _("Ask “%s” to shut down?").printf (process_info_view.process.application_name),
            _("The process will be asked to initiate shutdown tasks and close. In some cases the process may not quit."),
            new ThemedIcon ("system-shutdown"),
            Gtk.ButtonsType.CANCEL
        ) {
            badge_icon = new ThemedIcon ("dialog-question"),
            modal = true,
            transient_for = (Gtk.Window) get_root ()
        };

        var accept_button = confirmation_dialog.add_button (_("Shut Down"), Gtk.ResponseType.ACCEPT);
        accept_button.add_css_class (Granite.CssClass.SUGGESTED);

        confirmation_dialog.response.connect ((response) => {
            if (response == Gtk.ResponseType.ACCEPT) {
                // TODO: maybe add a toast that process killed
                process_info_view.process.end ();
            }

            confirmation_dialog.close ();
        });

        confirmation_dialog.present ();
    }

    private void action_kill () {
        var confirmation_dialog = new Granite.MessageDialog (
            _("Force “%s” to quit without initiating shutdown tasks?").printf (process_info_view.process.application_name),
            _("This may lead to data loss. Only Force Quit if Shut Down has failed."),
            new ThemedIcon ("computer-fail"),
            Gtk.ButtonsType.CANCEL
        ) {
            badge_icon = new ThemedIcon ("process-stop"),
            modal = true,
            transient_for = (Gtk.Window) get_root ()
        };

        var accept_button = confirmation_dialog.add_button (_("Force Quit"), Gtk.ResponseType.ACCEPT);
        accept_button.add_css_class (Granite.CssClass.DESTRUCTIVE);

        confirmation_dialog.response.connect ((response) => {
            if (response == Gtk.ResponseType.ACCEPT) {
                // @TODO: maybe add a toast that process killed
                process_info_view.process.kill ();
            }

            confirmation_dialog.close ();
        });

        confirmation_dialog.present ();
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
