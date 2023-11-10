public class Monitor.WidgetResource : Gtk.Box {
    private Gtk.Label _title = new Gtk.Label (Utils.NO_DATA);

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
        margin_bottom = 12;
        margin_start = 12;
        margin_end = 12;
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
            margin_start = 6,
            margin_end = 6,
            margin_top = 6,
            margin_bottom = 6,
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
        };

        grid_main_onchart_info_container.get_style_context ().add_class ("usage-label-container");
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
        //  button_more_info.set_focusable (false)
        button_more_info.get_style_context ().add_class ("circular");
        //  button_more_info.get_style_context ().add_class ("popup");

        button_more_info.set_icon_name ("dialog-information");

        popover_more_info = new Gtk.Popover () {
            position = Gtk.PositionType.BOTTOM,
            visible = false,
        };
        popover_more_info.set_autohide (true);

        button_more_info.set_popover (popover_more_info);

        //  Note: `Gtk.MenuButton.set_active' is not available in gtk4 4.6.9. Use gtk4 >= 4.10
        //  popover_more_info.closed.connect (() => { button_more_info.set_active (false); });
        //  button_more_info.clicked.connect (() => { popover_more_info.present (); });

        popover_more_info.set_child (widget);

        grid_header.attach (button_more_info, 1, 0, 1, 1);
    }
}
