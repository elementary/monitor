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

                permission_error_infobar.revealed = false;

                process_info_io_stats.open_files_tree_view.model.process = _process;
                // @TODO: Find workaround for show_all() in PRocessInfoView
                // process_info_io_stats.open_files_tree_view.show_all ();
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

        permission_error_infobar = new Gtk.InfoBar ();
        permission_error_infobar.message_type = Gtk.MessageType.ERROR;
        permission_error_infobar.revealed = false;
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
            tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl>E" })
        };

        kill_process_button = new Gtk.Button.with_label (_("Force Quit…")) {
            tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl>K" })
        };
        kill_process_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

        process_action_bar = new Gtk.Box (HORIZONTAL, 12) {
            halign = END,
            valign = END,
            homogeneous = true,
            margin_top = 12
        };
        process_action_bar.append (end_process_button);
        process_action_bar.append (kill_process_button);

        kill_process_button.clicked.connect (() => {
            var confirmation_dialog = new Granite.MessageDialog (
                _("Force “%s” to quit without initiating shutdown tasks?").printf (process_info_header.application_name.label),
                _("This may lead to data loss. Only Force Quit if Shut Down has failed."),
                new ThemedIcon ("computer-fail"),
                Gtk.ButtonsType.CANCEL
                ) {
                badge_icon = new ThemedIcon ("process-stop"),
                modal = true,
                // transient_for = (Gtk.Window) get_toplevel ()
            };

            var accept_button = confirmation_dialog.add_button (_("Force Quit"), Gtk.ResponseType.ACCEPT);
            accept_button.add_css_class (Granite.STYLE_CLASS_DESTRUCTIVE_ACTION);

            confirmation_dialog.response.connect ((response) => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    // @TODO: maybe add a toast that process killed
                    process.kill ();
                }

                confirmation_dialog.close ();
            });

            confirmation_dialog.present ();
        });

        end_process_button.clicked.connect (() => {
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
            accept_button.add_css_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

            confirmation_dialog.response.connect ((response) => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    // TODO: maybe add a toast that process killed
                    process.end ();
                }

                confirmation_dialog.close ();
            });

            confirmation_dialog.present ();
        });

        grid.attach (process_action_bar, 0, 5);
    }

    private void show_permission_error_infobar (string error) {
        if (permission_error_infobar.revealed == false) {
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
            // @TODO: Find workaround for show_all() in PRocessInfoView

            // process_info_io_stats.open_files_tree_view.show_all ();
        }
    }

}
