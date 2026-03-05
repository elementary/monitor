/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessView : Granite.Bin {

    public ProcessTreeView process_tree_view { get; private set; }
    private ProcessInfoView process_info_view;
    public TreeViewModel treeview_model { get; private set; }


    private SimpleAction end_action;
    private SimpleAction kill_action;

    construct {
        treeview_model = new TreeViewModel ();

        process_tree_view = new ProcessTreeView (treeview_model);
        treeview_model.process_selected.connect ((process) => on_process_selected (process));

        process_info_view = new ProcessInfoView () {
            // This might be useless since first process is selected
            // automatically and this triggers on_process_selected ().
            // Keeping it just to not forget what was the OG behavior 
            // in GTK3 version.
            visible = false,
        };
        treeview_model.process_manager.updated.connect ( process_info_view.update);

        var paned = new Gtk.Paned (HORIZONTAL) {
            start_child = process_tree_view,
            end_child = process_info_view,
            shrink_end_child = false,
            resize_end_child = false,
            hexpand = true
        };
        paned.position = paned.max_position;

        child = paned;


        kill_action = new SimpleAction ("kill", null);
        kill_action.activate.connect (action_kill);

        end_action = new SimpleAction ("end", null);
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

        end_action.set_enabled (process.uid == Posix.getuid ());
        kill_action.set_enabled (process.uid == Posix.getuid ());
    }


}
