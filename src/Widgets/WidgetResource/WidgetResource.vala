/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.WidgetResource : Gtk.Box {
    private Granite.HeaderLabel _title = new Granite.HeaderLabel (Utils.NO_DATA) {
        valign = Gtk.Align.CENTER,
    };

    public string title {
        set {
            _title.label = value;
        }
    }

    private LabelVertical _label_vertical_main_metric = new LabelVertical (_("UTILIZATION"));

    public string label_vertical_main_metric {
        set {
            _label_vertical_main_metric.set_text (value);
        }
    }

    private Gtk.Box charts_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

    private Gtk.Grid grid_main_chart_container;
    private Gtk.Grid grid_main_onchart_info_container;
    private Gtk.Grid grid_header;


    construct {
        margin_start = 12;
        margin_end = 12;
        margin_bottom = 12;
        margin_top = 6;
        set_vexpand (false);
        orientation = Gtk.Orientation.VERTICAL;



        grid_header = new Gtk.Grid () {
            column_spacing = 6,
        };
        grid_header.attach (_title, 0, 0, 1, 1);
        append (grid_header);


        grid_main_chart_container = new Gtk.Grid ();

        grid_main_onchart_info_container = new Gtk.Grid () {
            column_spacing = 6,
            margin_top = 6,
            margin_end = 6,
            margin_bottom = 6,
            margin_start = 6,
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
        };

        grid_main_onchart_info_container.add_css_class ("usage-label-container");
        grid_main_onchart_info_container.attach (_label_vertical_main_metric, 0, 0, 1, 1);

        charts_container.append (grid_main_chart_container);

        append (charts_container);

    }


    public void set_main_chart (Chart chart) {
        grid_main_chart_container.attach (chart, 0, 0, 1, 1);
    }

    public void set_main_chart_overlay (Gtk.Widget widget) {
        grid_main_onchart_info_container.attach (widget, 1, 0, 1, 1);
        grid_main_chart_container.attach (grid_main_onchart_info_container, 0, 0, 1, 1);

    }

    public void add_charts_container (Gtk.Widget widget) {
        charts_container.append (widget);
    }

    public void set_popover_more_info (Gtk.Widget widget) {
        var popover_more_info = new Gtk.Popover () {
            position = Gtk.PositionType.BOTTOM,
            // visible = false,
            autohide = true,
            child = widget,
        };
        var button_more_info = new Gtk.MenuButton () {
            focusable = false,
            icon_name = "dialog-information",
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
            popover = popover_more_info,

        };
        button_more_info.add_css_class ("circular");
        button_more_info.add_css_class ("popup");

        grid_header.attach (button_more_info, 1, 0, 1, 1);
    }

}
