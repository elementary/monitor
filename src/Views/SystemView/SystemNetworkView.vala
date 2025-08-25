/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.SystemNetworkView : Gtk.Grid {
    private Chart network_chart;
    private Network network;

    private Granite.HeaderLabel network_name_label;
    private LabelRoundy network_upload_label;
    private LabelRoundy network_download_label;

    construct {
        margin_top = 12;
        margin_bottom = 12;
        margin_start = 12;
        margin_end = 12;
        column_spacing = 12;
        set_vexpand (false);
    }

    public SystemNetworkView (Network _network) {
        network = _network;

        network_name_label = new Granite.HeaderLabel (_("Network"));

        network_download_label = new LabelRoundy (_("DOWN")) {
            width_chars = 7
        };
        network_download_label.get_style_context ().add_class ("blue");

        network_upload_label = new LabelRoundy (_("UP")) {
            width_chars = 7
        };
        network_upload_label.get_style_context ().add_class ("green");

        network_chart = new Chart (2);
        network_chart.config.y_axis.fixed_max = null;

        network_chart.set_serie_color (0, { 155 / 255.0f, 219 / 255.0f, 77 / 255.0f, 1.0f });
        network_chart.set_serie_color (1, { 100 / 255.0f, 186 / 255.0f, 255 / 255.0f, 1.0f });

        var labels_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin_top = 6,
            margin_end = 6,
            margin_bottom = 6,
            margin_start = 6
        };

        labels_box.append (network_download_label);
        labels_box.append (network_upload_label);

        attach (network_name_label, 0, 0, 1, 1);
        attach (labels_box, 0, 1, 2, 2);
        attach (network_chart, 0, 1, 2, 2);
    }

    public void update () {
        double up_bytes = network.bytes_out;
        double down_bytes = network.bytes_in;
        if (up_bytes >= 0 && down_bytes >= 0) {
            network_download_label.text = ("%s/s").printf (format_size ((uint64) down_bytes, IEC_UNITS));
            network_upload_label.text = ("%s/s").printf (format_size ((uint64) up_bytes, IEC_UNITS));
            network_chart.update (0, up_bytes);
            network_chart.update (1, down_bytes);
        }
    }

}
