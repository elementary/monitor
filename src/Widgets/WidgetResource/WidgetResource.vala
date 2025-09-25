/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.WidgetResource : Gtk.Box {
    public string title {
        set {
            _title.label = value;
        }
    }

    public string main_metric_value {
        set {
            main_metric_label.label = value;
        }
    }

    public Chart main_chart {
        set {
            main_overlay.child = value;
        }
    }

    private Granite.HeaderLabel _title;
    private Gtk.Box charts_box;
    private Gtk.Box header_box;
    private Gtk.Overlay main_overlay;
    private Gtk.Box info_box;
    private Gtk.Label main_metric_label;

    construct {
        _title = new Granite.HeaderLabel (Utils.NO_DATA);

        header_box = new Gtk.Box (HORIZONTAL, 6);
        header_box.add (_title);

        var main_metric_title = new Gtk.Label (_("Utilization").up ());
        main_metric_title.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        main_metric_title.get_style_context ().add_class (Granite.STYLE_CLASS_SMALL_LABEL);

        main_metric_label = new Gtk.Label (Utils.NO_DATA);
        main_metric_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var main_metric_box = new Gtk.Box (VERTICAL, 0) {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 12
        };
        main_metric_box.add (main_metric_title);
        main_metric_box.add (main_metric_label);

        info_box = new Gtk.Box (HORIZONTAL, 6) {
            halign = START,
            valign = START
        };
        info_box.get_style_context ().add_class ("usage-label-container");
        info_box.add (main_metric_box);

        main_overlay = new Gtk.Overlay ();
        main_overlay.add_overlay (info_box);

        charts_box = new Gtk.Box (HORIZONTAL, 6);
        charts_box.add (main_overlay);

        margin_top = 6;
        margin_end = 12;
        margin_bottom = 12;
        margin_start = 12;

        orientation = VERTICAL;
        add (header_box);
        add (charts_box);
    }

    public void set_main_chart_overlay (Gtk.Widget widget) {
        info_box.add (widget);
    }

    public void add_charts_container (Gtk.Widget widget) {
        charts_box.add (widget);
    }

    public void set_popover_more_info (Gtk.Widget widget) {
        widget.show_all ();

        var popover_more_info = new Gtk.Popover (null) {
            child = widget,
            position = BOTTOM
        };

        var button_more_info = new Gtk.MenuButton () {
            halign = START,
            valign = START,
            has_focus = false,
            image = new Gtk.Image.from_icon_name ("dialog-information", SMALL_TOOLBAR),
            popover = popover_more_info
        };
        button_more_info.get_style_context ().add_class ("circular");

        header_box.add (button_more_info);
    }
}
