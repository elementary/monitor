/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessInfoView : Gtk.Box {
    private Process _process;
    public Process? process {
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

    private Gtk.Box process_action_bar;
    private ProcessInfoIOStats process_info_io_stats;

    private Gtk.InfoBar permission_error_infobar;
    private Gtk.Label permission_error_label;

    private ProcessInfoHeader process_info_header;
    private ProcessInfoCPURAM process_info_cpu_ram;

    construct {
        permission_error_label = new Gtk.Label (Utils.NO_DATA);

        permission_error_infobar = new Gtk.InfoBar () {
            message_type = ERROR,
            revealed = false
        };
        permission_error_infobar.add_child (permission_error_label);

        process_info_header = new ProcessInfoHeader ();

        var separator = new Gtk.Separator (HORIZONTAL) {
            margin_top = 12,
            margin_bottom = 12
        };

        process_info_cpu_ram = new ProcessInfoCPURAM ();
        process_info_cpu_ram.hide ();

        process_info_io_stats = new ProcessInfoIOStats ();

        var app = (Gtk.Application) GLib.Application.get_default ();

        var end_process_button = new Gtk.Button.with_label (_("Shut Down…")) {
            action_name = "process.end",
            tooltip_markup = Granite.markup_accel_tooltip (app.get_accels_for_action ("process.end"))
        };

        var kill_process_button = new Gtk.Button.with_label (_("Force Quit…")) {
            action_name = "process.kill",
            tooltip_markup = Granite.markup_accel_tooltip (app.get_accels_for_action ("process.kill"))
        };
        kill_process_button.add_css_class (Granite.CssClass.DESTRUCTIVE);

        process_action_bar = new Granite.Box (HORIZONTAL) {
            halign = END,
            valign = END,
            homogeneous = true,
            margin_top = 12
        };
        process_action_bar.append (end_process_button);
        process_action_bar.append (kill_process_button);

        var box = new Granite.Box (VERTICAL) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        box.append (process_info_header);
        box.append (separator);
        box.append (process_info_cpu_ram);
        box.append (process_info_io_stats);
        box.append (process_action_bar);

        orientation = VERTICAL;
        hexpand = true;
        append (permission_error_infobar);
        append (box);
    }

    private void show_permission_error_infobar (string error) {
        if (!permission_error_infobar.revealed) {
            permission_error_label.label = error;
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
