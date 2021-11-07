public class Monitor.SystemStorageView : Gtk.Grid {
    private Chart storage_chart;
    private Storage storage;

    private LabelH4 storage_name_label;
    private LabelRoundy storage_read_label;
    private LabelRoundy storage_write_label;

    construct {
        margin = 12;
        column_spacing = 12;
        set_vexpand (false);
    }

    public SystemStorageView (Storage _storage) {
        storage = _storage;

        storage_name_label = new LabelH4 (_("Storage"));

        storage_write_label = new LabelRoundy (_("WRITE"));
        storage_write_label.val.set_width_chars (7);
        storage_write_label.set_color ("blue");

        storage_read_label = new LabelRoundy (_("READ"));
        storage_read_label.val.set_width_chars (7);
        storage_read_label.set_color ("green");

        storage_chart = new Chart (2);
        storage_chart.config.y_axis.fixed_max = null;
        storage_chart.set_serie_color(0, { 155/255.0, 219/255.0, 77/255.0, 1.0 });
        storage_chart.set_serie_color(1, { 100/255.0, 186/255.0, 255/255.0, 1.0 });

        var labels_grid = new Gtk.Grid ();
        labels_grid.row_spacing = 6;
        labels_grid.column_spacing = 6;
        labels_grid.margin = 6;
        labels_grid.attach (storage_write_label, 0, 0, 1, 1);
        labels_grid.attach (storage_read_label, 1, 0, 1, 1);

        attach (storage_name_label, 0, 0, 1, 1);
        attach (labels_grid, 0, 1, 2, 2);
        attach (storage_chart, 0, 1, 2, 2);
    }

    public void update () {
        double up_bytes = storage.bytes_read;
        double down_bytes = storage.bytes_write;
        if (up_bytes >= 0 && down_bytes >= 0) {
            storage_write_label.set_text (("%s/s").printf (Utils.HumanUnitFormatter.string_bytes_to_human (down_bytes.to_string ())));
            storage_read_label.set_text (("%s/s").printf (Utils.HumanUnitFormatter.string_bytes_to_human (up_bytes.to_string ())));
            storage_chart.update (0, up_bytes);
            storage_chart.update (1, down_bytes);
        }
    }

}
