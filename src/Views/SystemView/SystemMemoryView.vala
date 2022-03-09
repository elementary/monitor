public class Monitor.SystemMemoryView : Monitor.WidgetResource {
    private Chart memory_chart;
    private Memory memory;

    private Gtk.Label memory_shared_label;
    private Gtk.Label memory_buffered_label;
    private Gtk.Label memory_cached_label;
    private Gtk.Label memory_locked_label;
    private Gtk.Label memory_total_label;
    private Gtk.Label memory_used_label;

    construct {
        title = (_("Memory"));
    }

    public SystemMemoryView (Memory _memory) {
        memory = _memory;

        memory_total_label = new Gtk.Label (_("Total: ") + Utils.NO_DATA);
        memory_total_label.halign = Gtk.Align.START;

        memory_used_label = new Gtk.Label (_("Used: ") + Utils.NO_DATA);
        memory_used_label.halign = Gtk.Align.START;

        memory_shared_label = new Gtk.Label (_("Shared: ") + Utils.NO_DATA);
        memory_shared_label.halign = Gtk.Align.START;

        memory_buffered_label = new Gtk.Label (_("Buffered: ") + Utils.NO_DATA);
        memory_buffered_label.halign = Gtk.Align.START;

        memory_cached_label = new Gtk.Label (_("Cached: ") + Utils.NO_DATA);
        memory_cached_label.halign = Gtk.Align.START;

        memory_locked_label = new Gtk.Label (_("Locked: ") + Utils.NO_DATA);
        memory_locked_label.halign = Gtk.Align.START;

        memory_chart = new Chart (1);
        memory_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_500));
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
        grid.attach (memory_total_label, 1, 0, 1, 1);
        grid.attach (memory_shared_label, 0, 1, 1, 1);
        grid.attach (memory_buffered_label, 1, 1, 1, 1);
        grid.attach (memory_cached_label, 0, 2, 1, 1);
        grid.attach (memory_locked_label, 1, 2, 1, 1);

        return grid;
    }

    public void update () {
        label_vertical_main_metric = (("%d%%").printf (memory.percentage));
        memory_chart.update (0, memory.percentage);

        memory_total_label.set_text ((_("Total: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.total)));
        memory_used_label.set_text ((_("Used: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.used)));
        memory_shared_label.set_text ((_("Shared: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.shared)));
        memory_buffered_label.set_text ((_("Buffered: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.buffer)));
        memory_cached_label.set_text ((_("Cached: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.cached)));
        memory_locked_label.set_text ((_("Locked: %s")).printf (Utils.HumanUnitFormatter.double_bytes_to_human (memory.locked)));
    }

}
