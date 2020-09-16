public class Monitor.SystemNetworkView : Gtk.Grid {
    private Chart network_chart;
    private Network network;

    private LabelH4 network_name_label;
    private LabelRoundy network_upload_label;
    private LabelRoundy network_download_label;

    construct {
        margin = 12;
        column_spacing = 12;
        set_vexpand (false);
    }

    public SystemNetworkView (Network _network) {
        network = _network;

        network_name_label = new LabelH4 (_("Network"));
        network_download_label = new LabelRoundy (_("DOWN"));
        network_download_label.val.set_width_chars (7);
        network_upload_label = new LabelRoundy (_("UP"));
        network_upload_label.val.set_width_chars (7);

        network_chart = new Chart (2);
        network_chart.config.y_axis.fixed_max = null;

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
            network_download_label.set_text (("%s/s").printf (Utils.HumanUnitFormatter.string_bytes_to_human (down_bytes.to_string ())));
            network_upload_label.set_text (("%s/s").printf (Utils.HumanUnitFormatter.string_bytes_to_human (up_bytes.to_string ())));
            network_chart.update (0, up_bytes);
            network_chart.update (1, down_bytes);
        }
    }

}
