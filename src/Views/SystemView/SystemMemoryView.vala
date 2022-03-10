public class Monitor.SystemMemoryView : Monitor.WidgetResource {
    private Chart memory_chart;
    private Memory memory;

    private LabelRoundy memory_buffered_label = new LabelRoundy(_("Buffered"));
    private LabelRoundy memory_cached_label = new LabelRoundy(_("Cached"));
    private LabelRoundy memory_locked_label = new LabelRoundy(_("Locked"));
    private LabelRoundy memory_total_label = new LabelRoundy(_("Total"));
    private LabelRoundy memory_used_label = new LabelRoundy(_("Used"));
    private LabelRoundy memory_shared_label = new LabelRoundy (_("Shared"));

    private Gdk.RGBA color_memory_used = Utils.Colors.get_rgba_color (Utils.Colors.GRAPE_500);

    construct {
        title = (_("Memory"));

    }

    public SystemMemoryView (Memory _memory) {
        memory = _memory;

        memory_chart = new Chart (5);
        memory_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.GRAPE_500));
        memory_used_label.set_color ("grape_500");

        memory_chart.set_serie_color (1, Utils.Colors.get_rgba_color (Utils.Colors.BLUEBERRY_100));
        memory_shared_label.set_color ("blueberry_100");

        memory_chart.set_serie_color (2, Utils.Colors.get_rgba_color (Utils.Colors.GRAPE_100));
        memory_chart.set_serie_color (3, Utils.Colors.get_rgba_color (Utils.Colors.BLUEBERRY_500));
        memory_chart.set_serie_color (4, Utils.Colors.get_rgba_color (Utils.Colors.BUBBLEGUM_100));
        set_main_chart (memory_chart);

        set_main_chart_overlay (memory_usage_grid ());
    }

    private Gtk.Grid memory_usage_grid () {
        Gtk.Grid grid = new Gtk.Grid () {
            column_spacing = 8,
            row_spacing = 4,
            margin = 6
        };

        grid.attach (memory_used_label, 0, 0, 1, 1);
        grid.attach (memory_total_label, 0, 1, 1, 1);
        grid.attach (memory_shared_label, 1, 0, 1, 1);
        grid.attach (memory_buffered_label, 1, 1, 1, 1);
        grid.attach (memory_cached_label, 2, 0, 1, 1);
        grid.attach (memory_locked_label, 2, 1, 1, 1);

        return grid;
    }

    public void update () {
        label_vertical_main_metric = (("%u%%").printf (memory.used_percentage));
        memory_chart.update (0, memory.used_percentage);
        memory_chart.update (1, memory.shared_percentage);
        memory_chart.update (2, memory.shared_percentage + memory.buffer_percentage);
        memory_chart.update (3, memory.shared_percentage + memory.buffer_percentage + memory.cached_percentage);
        memory_chart.update (3, memory.shared_percentage + memory.buffer_percentage + memory.cached_percentage + memory.locked_percentage);

        memory_total_label.set_text (("%s").printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.total)));
        memory_used_label.set_text (("%s").printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.used)));
        memory_buffered_label.set_text (("%s").printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.buffer)));
        memory_cached_label.set_text (("%s").printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.cached)));
        memory_locked_label.set_text (("%s").printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.locked)));

        memory_shared_label.set_text (("%s").printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.shared)));
    }

}
