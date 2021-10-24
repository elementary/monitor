public class Monitor.SystemStorageView : Gtk.Grid {
    private Chart storage_chart;
    private Storage storage;

    private LabelH4 storage_name_label;
    private LabelRoundy storage_read_label;
    private LabelRoundy storage_write_label;

    private Gtk.Box drive_cards_container;

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
        storage_chart.set_serie_color (0, { 155 / 255.0, 219 / 255.0, 77 / 255.0, 1.0 });
        storage_chart.set_serie_color (1, { 100 / 255.0, 186 / 255.0, 255 / 255.0, 1.0 });

        var labels_grid = new Gtk.Grid ();
        labels_grid.row_spacing = 6;
        labels_grid.column_spacing = 6;
        labels_grid.margin = 6;
        labels_grid.attach (storage_write_label, 0, 0, 1, 1);
        labels_grid.attach (storage_read_label, 1, 0, 1, 1);

        drive_cards_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        storage.get_drives ().foreach (add_drive_card);

        attach (storage_name_label, 0, 0, 1, 1);
        attach (drive_cards_container, 0, 1, 1, 1);
        attach (labels_grid, 0, 2, 2, 2);
        attach (storage_chart, 0, 2, 2, 2);
    }

    private bool add_drive_card (owned DiskDrive? drive) {
        drive_cards_container.add (build_drive_card (drive.model, drive.device, drive.size, drive.free));
        return true;
    }

    private Gtk.Box build_drive_card (string model, string device, uint64 size, uint64 free) {
        var drive_card = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        drive_card.get_style_context ().add_class ("card");
        drive_card.get_style_context ().add_class ("rounded");

        drive_card.halign = Gtk.Align.START;
        drive_card.margin_end = 12;
        drive_card.margin_top = 6;
        drive_card.margin_bottom = 12;

        var drive_grid = new Gtk.Grid ();
        //  drive_grid.row_spacing = 6;
        drive_grid.column_spacing = 6;
        drive_grid.margin = 6;

        var drive_name_label = new Gtk.Label (model);
        drive_name_label.get_style_context ().add_class ("h3");
        drive_name_label.margin = 6;
        drive_name_label.margin_bottom = 0;
        drive_name_label.halign = Gtk.Align.START;

        string size_string = Utils.HumanUnitFormatter.double_bytes_to_human(size);
        string used_string = Utils.HumanUnitFormatter.double_bytes_to_human((size - free));

        string drive_block_name_and_size_string = "%s 𐄁 %s / %s".printf (device, used_string, size_string);
        

        debug (size.to_string());

        if (free == 0) drive_block_name_and_size_string = "%s 𐄁 %s".printf (device, size_string);

        var drive_block_name_and_size_label = new Gtk.Label (drive_block_name_and_size_string);
        drive_block_name_and_size_label.get_style_context ().add_class ("h4");
        drive_block_name_and_size_label.get_style_context ().add_class ("text-secondary");
        drive_block_name_and_size_label.margin = 6;
        drive_block_name_and_size_label.margin_top = 0;
        drive_block_name_and_size_label.halign = Gtk.Align.START;

        var drive_not_mounted_label = new Gtk.Label ("Not mounted");
        drive_not_mounted_label.halign = Gtk.Align.START;
        drive_not_mounted_label.get_style_context ().add_class ("h4");
        drive_not_mounted_label.margin_start = 6;
        
        var usagebar = new Gtk.LevelBar ();
        usagebar.get_style_context ().add_class ("flat");
        usagebar.margin = 6;
        usagebar.margin_top = 0;
        usagebar.set_max_value (100.0);
        usagebar.set_min_value (0.0);
        usagebar.set_value (100.0 * (size - free) / size);

        drive_grid.attach (drive_name_label, 0, 0, 1, 1);
        drive_grid.attach (drive_block_name_and_size_label, 0, 1, 1, 1);
        if (free == 0) { 
            drive_grid.attach (drive_not_mounted_label, 0, 2, 1, 1);
        } else {
            drive_grid.attach (usagebar, 0, 2, 1, 1);
        }
        drive_card.add (drive_grid);

        return drive_card;
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