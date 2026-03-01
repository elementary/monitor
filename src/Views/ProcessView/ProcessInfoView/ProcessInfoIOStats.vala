/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.ProcessInfoIOStats : Gtk.Grid {
    public OpenFilesTreeView open_files_tree_view { get; private set; }

    private Gtk.Label write_bytes_label;
    private Gtk.Label read_bytes_label;
    private Gtk.Label cancelled_write_bytes_label;

    private Gtk.Box ports_list_box;
    private string last_ports_key = "";

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

        var ports_header_label = new Granite.HeaderLabel (_("Listening Ports"));

        ports_list_box = new Gtk.Box (VERTICAL, 3);

        column_spacing = 6;
        row_spacing = 6;
        column_homogeneous = true;

        attach (io_label, 0, 1);
        attach (create_label_with_icon (read_bytes_label, "go-up-symbolic"), 0, 2);
        attach (create_label_with_icon (write_bytes_label, "go-down-symbolic"), 0, 3);
        attach (cancelled_write_label, 1, 1);
        attach (cancelled_write_bytes_label, 1, 2);
        attach (ports_header_label, 0, 4, 2);
        attach (ports_list_box, 0, 5, 2);
        attach (open_files_tree_view_scrolled, 0, 6, 2);
    }

    public void update (Process process) {
        write_bytes_label.label = format_size ((uint64) process.io.write_bytes, IEC_UNITS);
        read_bytes_label.label = format_size ((uint64) process.io.read_bytes, IEC_UNITS);
        cancelled_write_bytes_label.label = format_size ((uint64) process.io.cancelled_write_bytes, IEC_UNITS);
        update_ports (process);
    }

    public void update_ports (Process process) {
        // Build a full key from all port data to avoid stale display
        var key_builder = new StringBuilder ();
        foreach (var lp in process.listening_ports) {
            key_builder.append ("%s:%u:%s,".printf (lp.protocol, lp.port, lp.local_address));
        }
        var ports_key = key_builder.str;

        if (ports_key == last_ports_key) {
            return;
        }
        last_ports_key = ports_key;

        // Remove old dynamic children from ports_list_box
        var child = ports_list_box.get_first_child ();
        while (child != null) {
            var next = child.get_next_sibling ();
            ports_list_box.remove (child);
            child = next;
        }

        if (process.listening_ports.size > 0) {
            // Show each port as a label
            foreach (var lp in process.listening_ports) {
                var addr_display = NetworkConnections.simplify_address (lp.local_address);
                var port_label = new Gtk.Label ("%s:%u (%s)".printf (lp.protocol, lp.port, addr_display)) {
                    halign = START
                };
                ports_list_box.append (port_label);
            }
        } else {
            // Own process with no ports
            var no_data_label = new Gtk.Label (Utils.NO_DATA) {
                halign = START
            };
            ports_list_box.append (no_data_label);
        }
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
