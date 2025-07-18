/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.WidgetResource : Gtk.Box {
    private Granite.HeaderLabel _title = new Granite.HeaderLabel (Utils.NO_DATA);

    public string title {
        set {
            _title.label = value;
        }
    }

    public Gtk.Popover popover_more_info;
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
        grid_main_chart_container.attach (build_grid_main_onchart_info_container (), 0, 0, 1, 1);

        charts_container.prepend (grid_main_chart_container);

        append (charts_container);

    }

    private Gtk.Grid build_grid_main_onchart_info_container () {
        grid_main_onchart_info_container = new Gtk.Grid () {
            column_spacing = 6,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6,
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
        };

        grid_main_onchart_info_container.add_css_class ("usage-label-container");
        grid_main_onchart_info_container.attach (_label_vertical_main_metric, 0, 0, 1, 1);

        return grid_main_onchart_info_container;
    }

    public void set_main_chart (Chart chart) {
        grid_main_chart_container.attach (chart, 0, 0, 1, 1);
    }

    public void set_main_chart_overlay (Gtk.Widget widget) {
        grid_main_onchart_info_container.attach (widget, 1, 0, 1, 1);
    }

    public void add_charts_container (Gtk.Widget widget) {
        charts_container.prepend (widget);
    }

    public void set_popover_more_info (Gtk.Widget widget) {
        var button_more_info = new Gtk.MenuButton () {
            focusable = false,
            valign = Gtk.Align.START,
            halign = Gtk.Align.START
        };
        button_more_info.add_css_class ("circular");
        button_more_info.add_css_class ("popup");


        button_more_info.set_icon_name ("dialog-information");

        popover_more_info = new Gtk.Popover () {
            position = Gtk.PositionType.BOTTOM,
            visible = false,
            autohide = true,
            child = widget,
        };

        grid_header.attach (button_more_info, 1, 0, 1, 1);
    }

}
