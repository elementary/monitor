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
    private Gtk.Overlay main_overlay;
    private Gtk.Box info_box;
    private Granite.HeaderLabel main_metric_label;
    private Gtk.Grid header_grid;
    private Gtk.Label? header_info = null;

    construct {
        _title = new Granite.HeaderLabel (Utils.NO_DATA);

        header_grid = new Gtk.Grid () {
            row_spacing = 0,
            column_spacing = 6,
        };
        header_grid.attach (_title, 0, 0);

        var main_metric_title = new Gtk.Label (_("Utilization").up ());
        main_metric_title.add_css_class (Granite.CssClass.DIM);
        main_metric_title.add_css_class (Granite.CssClass.SMALL);

        main_metric_label = new Granite.HeaderLabel (Utils.NO_DATA) {
            size = H2
        };

        var main_metric_box = new Gtk.Box (VERTICAL, 0) {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 12
        };
        main_metric_box.append (main_metric_title);
        main_metric_box.append (main_metric_label);

        info_box = new Gtk.Box (HORIZONTAL, 6) {
            halign = START,
            valign = START
        };
        info_box.add_css_class ("usage-label-container");
        info_box.append (main_metric_box);

        main_overlay = new Gtk.Overlay ();
        main_overlay.add_overlay (info_box);

        charts_box = new Gtk.Box (HORIZONTAL, 6);
        charts_box.append (main_overlay);

        margin_top = 6;
        margin_end = 12;
        margin_bottom = 12;
        margin_start = 12;

        orientation = VERTICAL;
        append (header_grid);
        append (charts_box);
    }

    public void add_header_info (Gtk.Label label) {
        header_grid.attach_next_to (label, _title, Gtk.PositionType.BOTTOM);
        header_info = label;
    }

    public void set_main_chart_overlay (Gtk.Widget widget) {
        info_box.append (widget);
    }

    public void add_charts_container (Gtk.Widget widget) {
        charts_box.append (widget);
    }

    public void set_popover_more_info (Gtk.Widget widget) {
        var popover_more_info = new Gtk.Popover () {
            child = widget,
            position = BOTTOM
        };

        var button_more_info = new Gtk.MenuButton () {
            halign = START,
            valign = START,
            focusable = false,
            icon_name = "dialog-information",
            popover = popover_more_info
        };
        button_more_info.add_css_class (Granite.CssClass.CIRCULAR);

        header_grid.attach_next_to (button_more_info, header_info, Gtk.PositionType.RIGHT);
    }

}
