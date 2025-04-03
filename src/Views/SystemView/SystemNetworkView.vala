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
        margin = 12;
        column_spacing = 12;
        set_vexpand (false);
    }

    public SystemNetworkView (Network _network) {
        network = _network;

        network_name_label = new Granite.HeaderLabel (_("Network"));

        network_download_label = new LabelRoundy (_("DOWN"));
        network_download_label.val.set_width_chars (7);
        network_download_label.set_color ("blue");

        network_upload_label = new LabelRoundy (_("UP"));
        network_upload_label.val.set_width_chars (7);
        network_upload_label.set_color ("green");

        network_chart = new Chart (2);
        network_chart.config.y_axis.fixed_max = null;

        network_chart.set_serie_color (0, { 155 / 255.0, 219 / 255.0, 77 / 255.0, 1.0 });
        network_chart.set_serie_color (1, { 100 / 255.0, 186 / 255.0, 255 / 255.0, 1.0 });

        var labels_grid = new Gtk.Grid ();
        labels_grid.row_spacing = 6;
        labels_grid.column_spacing = 6;
        labels_grid.margin = 6;
        labels_grid.attach (network_download_label, 0, 0, 1, 1);
        labels_grid.attach (network_upload_label, 1, 0, 1, 1);

        attach (network_name_label, 0, 0, 1, 1);
        attach (labels_grid, 0, 1, 2, 2);
        attach (network_chart, 0, 1, 2, 2);
    }

    public void update () {
        double up_bytes = network.bytes_out;
        double down_bytes = network.bytes_in;
        if (up_bytes >= 0 && down_bytes >= 0) {
            network_download_label.set_text (("%s/s").printf (format_size ((uint64) down_bytes, IEC_UNITS)));
            network_upload_label.set_text (("%s/s").printf (format_size ((uint64) up_bytes, IEC_UNITS)));
            network_chart.update (0, up_bytes);
            network_chart.update (1, down_bytes);
        }
    }

}
