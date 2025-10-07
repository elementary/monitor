/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessInfoView : Gtk.Box {
    private Gtk.Box process_action_bar;
    private ProcessInfoIOStats process_info_io_stats = new ProcessInfoIOStats ();

    private Process _process;
    public Process ? process {
        get {
            return _process;
        }
        set {
            // remember to disconnect before assigning a new value
            if (_process != null) {
                _process.fd_permission_error.disconnect (show_permission_error_infobar);
            }
            _process = value;

            process_info_header.update (_process);

            if (_process.uid != Posix.getuid ()) {
                process_info_cpu_ram.hide ();
                process_info_io_stats.hide ();
                process_action_bar.hide ();
            } else {
                _process.fd_permission_error.connect (show_permission_error_infobar);

                process_info_io_stats.update (_process);

                process_info_cpu_ram.clear_graphs ();
                process_info_cpu_ram.set_charts_data (_process);

                // Setting visibility
                process_info_cpu_ram.visible = true;
                process_action_bar.visible = true;
                process_info_io_stats.visible = true;

                permission_error_infobar.revealed = false;

                process_info_io_stats.open_files_tree_view.model.process = _process;
                process_info_io_stats.open_files_tree_view.visible = true;
            }
        }
    }
    public string ? icon_name;

    private Gtk.InfoBar permission_error_infobar;
    private Gtk.Label permission_error_label;

    private ProcessInfoHeader process_info_header;
    private ProcessInfoCPURAM process_info_cpu_ram;

    private Gtk.Button end_process_button;
    private Gtk.Button kill_process_button;

    public ProcessInfoView () {
        orientation = Gtk.Orientation.VERTICAL;
        hexpand = true;

        var application = (Gtk.Application) GLib.Application.get_default ();
        application.set_accels_for_action ("process.end", { "<Ctrl>E" });
        application.set_accels_for_action ("process.kill", { "<Ctrl>K" });

        permission_error_infobar = new Gtk.InfoBar () {
            message_type = Gtk.MessageType.ERROR,
            revealed = false,
        };
        permission_error_label = new Gtk.Label (Utils.NO_DATA);
        permission_error_infobar.add_child (permission_error_label);
        append (permission_error_infobar);

        var grid = new Gtk.Grid () {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            hexpand = true,
            column_spacing = 12
        };
        append (grid);


        process_info_header = new ProcessInfoHeader ();
        grid.attach (process_info_header, 0, 0, 1, 1);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12,
            hexpand = true
        };
        grid.attach (separator, 0, 1, 1, 1);

        process_info_cpu_ram = new ProcessInfoCPURAM ();
        process_info_cpu_ram.hide ();
        grid.attach (process_info_cpu_ram, 0, 2, 1, 1);

        grid.attach (process_info_io_stats, 0, 4, 1, 1);

        end_process_button = new Gtk.Button.with_label (_("Shut Down…")) {
            action_name = "process.end"
        };
        end_process_button.tooltip_markup = Granite.markup_accel_tooltip (
            application.get_accels_for_action (end_process_button.action_name)
        );

        kill_process_button = new Gtk.Button.with_label (_("Force Quit…")) {
            action_name = "process.kill"
        };
        kill_process_button.tooltip_markup = Granite.markup_accel_tooltip (
            application.get_accels_for_action (kill_process_button.action_name)
        );
        kill_process_button.add_css_class (Granite.CssClass.DESTRUCTIVE);

        process_action_bar = new Gtk.Box (HORIZONTAL, 12) {
            halign = END,
            valign = END,
            homogeneous = true,
            margin_top = 12
        };
        process_action_bar.append (end_process_button);
        process_action_bar.append (kill_process_button);

        grid.attach (process_action_bar, 0, 5);

        var kill_action = new SimpleAction ("kill", null);
        kill_action.activate.connect (() => {
            var confirmation_dialog = new Granite.MessageDialog (
                _("Force “%s” to quit without initiating shutdown tasks?").printf (process_info_header.application_name.label),
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
                    process.kill ();
                }

                confirmation_dialog.close ();
            });

            confirmation_dialog.present ();
        });

        var end_action = new SimpleAction ("end", null);
        end_action.activate.connect (() => {
            var confirmation_dialog = new Granite.MessageDialog (
                _("Ask “%s” to shut down?").printf (process_info_header.application_name.label),
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
                    process.end ();
                }

                confirmation_dialog.close ();
            });

            confirmation_dialog.present ();
        });

        var action_group = new SimpleActionGroup ();
        action_group.add_action (kill_action);
        action_group.add_action (end_action);

        insert_action_group ("process", action_group);
    }

    private void show_permission_error_infobar (string error) {
        if (!permission_error_infobar.revealed) {
            permission_error_label.set_text (error);
            permission_error_infobar.revealed = true;
        }
    }

    public void update () {
        if (process != null) {
            process_info_header.update (process);
            process_info_cpu_ram.update (process);
            process_info_io_stats.update (process);

            process_info_io_stats.open_files_tree_view.model.process = _process;

            process_info_io_stats.open_files_tree_view.visible = true;
        }
    }

}
