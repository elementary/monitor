/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.SystemStorageView : Gtk.Box {
    public Storage storage { get; construct; }

    private Chart storage_chart;
    private LabelRoundy storage_read_label;
    private LabelRoundy storage_write_label;

    public SystemStorageView (Storage _storage) {
        Object (storage: _storage);
    }

    construct {
        var storage_name_label = new Granite.HeaderLabel (_("Storage"));

        storage_write_label = new LabelRoundy (_("WRITE")) {
            width_chars = 7
        };
        storage_write_label.add_css_class ("blue");

        storage_read_label = new LabelRoundy (_("READ")) {
            width_chars = 7
        };
        storage_read_label.add_css_class ("green");

        storage_chart = new Chart (2) {
            height_request = 120,
            valign = START
        };
        storage_chart.config.y_axis.fixed_max = null;
        storage_chart.set_serie_color (0, { 155 / 255.0f, 219 / 255.0f, 77 / 255.0f, 1.0f });
        storage_chart.set_serie_color (1, { 100 / 255.0f, 186 / 255.0f, 255 / 255.0f, 1.0f });

        var labels_box = new Gtk.Box (HORIZONTAL, 6) {
            margin_top = 6,
            margin_end = 6,
            margin_bottom = 6,
            margin_start = 6
        };
        labels_box.append (storage_write_label);
        labels_box.append (storage_read_label);

        var chart_overlay = new Gtk.Overlay () {
            child = storage_chart
        };
        chart_overlay.add_overlay (labels_box);

        var drive_cards_container = new Gtk.Box (HORIZONTAL, 12) {
            margin_top = 6,
            margin_bottom = 12
        };

        margin_top = 12;
        margin_end = 12;
        margin_bottom = 12;
        margin_start = 12;
        orientation = VERTICAL;

        append (storage_name_label);
        append (drive_cards_container);
        append (chart_overlay);

        storage.get_drives ().foreach ((drive) => {
            drive_cards_container.append (
                new DriveCard (drive)
            );

            return GLib.Source.CONTINUE;
        });
    }

    public void update () {
        double up_bytes = storage.bytes_read;
        double down_bytes = storage.bytes_write;
        if (up_bytes >= 0 && down_bytes >= 0) {
            storage_write_label.text = ("%s/s").printf (format_size ((uint64) down_bytes, IEC_UNITS));
            storage_read_label.text = ("%s/s").printf (format_size ((uint64) up_bytes, IEC_UNITS));
            storage_chart.update (0, up_bytes);
            storage_chart.update (1, down_bytes);
        }
    }

    private class DriveCard : Gtk.Box {
        public Disk drive { get; construct; }

        public DriveCard (Disk drive) {
            Object (drive: drive);
        }

        construct {
            var drive_name_label = new Gtk.Label (drive.model) {
                halign = START
            };
            drive_name_label.add_css_class (Granite.HeaderLabel.Size.H3);

            string size_string = format_size ((uint64) drive.size, IEC_UNITS);
            string used_string = format_size ((uint64) (drive.size - drive.free), IEC_UNITS);

            string drive_block_name_and_size_string = "%s 𐄁 %s / %s".printf (drive.device, used_string, size_string);

            if (drive.free == 0) {
                drive_block_name_and_size_string = "%s 𐄁 %s".printf (drive.device, size_string);
            }

            var drive_block_name_and_size_label = new Gtk.Label (drive_block_name_and_size_string) {
                halign = START,
                margin_bottom = 6
            };
            drive_block_name_and_size_label.add_css_class (Granite.CssClass.DIM);

            var drive_not_mounted_label = new Gtk.Label (_("Not mounted")) {
                halign = START
            };
            drive_not_mounted_label.add_css_class (Granite.CssClass.DIM);

            var usagebar = new Gtk.LevelBar () {
                max_value = 100.0,
                min_value = 0.0,
                margin_bottom = 6
            };
            usagebar.add_css_class (Granite.STYLE_CLASS_FLAT);
            usagebar.set_value (100.0 * (drive.size - drive.free) / drive.size);

            var drive_box = new Gtk.Box (VERTICAL, 0) {
                margin_top = 6,
                margin_end = 12,
                margin_bottom = 6,
                margin_start = 12
            };
            drive_box.append (drive_name_label);
            drive_box.append (drive_block_name_and_size_label);
            if (drive.free == 0) {
                drive_box.append (drive_not_mounted_label);
            } else {
                drive_box.append (usagebar);
            }

            add_css_class (Granite.CssClass.CARD);
            append (drive_box);
        }
    }
}
