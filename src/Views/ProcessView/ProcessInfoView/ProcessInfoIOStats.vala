/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessInfoIOStats : Gtk.Grid {
    public OpenFilesTreeView open_files_tree_view { get; private set; }

    private Gtk.Label write_bytes_label;
    private Gtk.Label read_bytes_label;
    private Gtk.Label cancelled_write_bytes_label;

    construct {
        var io_label = new Granite.HeaderLabel (_("Read/Written"));

        write_bytes_label = create_label (_("N/A"));
        read_bytes_label = create_label (_("N/A"));

        var cancelled_write_label = new Granite.HeaderLabel (_("Cancelled write"));

        cancelled_write_bytes_label = create_label (Utils.NO_DATA);

        open_files_tree_view = new OpenFilesTreeView ();

        var open_files_tree_view_scrolled = new Gtk.ScrolledWindow () {
            child = open_files_tree_view
        };

        column_spacing = 6;
        row_spacing = 6;
        column_homogeneous = true;

        attach (io_label, 0, 1);
        attach (create_label_with_icon (read_bytes_label, "go-up-symbolic"), 0, 2);
        attach (create_label_with_icon (write_bytes_label, "go-down-symbolic"), 0, 3);
        attach (cancelled_write_label, 1, 1);
        attach (cancelled_write_bytes_label, 1, 2);
        attach (open_files_tree_view_scrolled, 0, 4, 2);
    }

    public void update (Process process) {
        write_bytes_label.label = format_size ((uint64) process.io.write_bytes, IEC_UNITS);
        read_bytes_label.label = format_size ((uint64) process.io.read_bytes, IEC_UNITS);
        cancelled_write_bytes_label.label = format_size ((uint64) process.io.cancelled_write_bytes, IEC_UNITS);
    }

    private Gtk.Label create_label (string text) {
        var label = new Gtk.Label (text) {
            halign = START
        };

        return label;
    }

    private Gtk.Box create_label_with_icon (Gtk.Label label, string icon_name) {
        var image = new Gtk.Image.from_icon_name (icon_name);

        var box = new Gtk.Box (HORIZONTAL, 3);
        box.append (image);
        box.append (label);

        return box;
    }
}
