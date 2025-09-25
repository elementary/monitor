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

    public string label_vertical_main_metric {
        set {
            _label_vertical_main_metric.set_text (value);
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
    private LabelVertical _label_vertical_main_metric;

    construct {
        _title = new Granite.HeaderLabel (Utils.NO_DATA);

        header_box = new Gtk.Box (HORIZONTAL, 6);
        header_box.add (_title);

        _label_vertical_main_metric = new LabelVertical (_("UTILIZATION"));

        info_box = new Gtk.Box (HORIZONTAL, 6) {
            halign = START,
            valign = START
        };
        info_box.get_style_context ().add_class ("usage-label-container");
        info_box.add (_label_vertical_main_metric);

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
