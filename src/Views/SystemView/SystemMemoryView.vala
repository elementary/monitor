/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.SystemMemoryView : Monitor.WidgetResource {
    private Chart memory_chart;
    private Memory memory;
    private Swap swap;

    private LabelRoundy memory_buffered_label = new LabelRoundy (_("Buffered"));
    private LabelRoundy memory_cached_label = new LabelRoundy (_("Cached"));
    private LabelRoundy memory_locked_label = new LabelRoundy (_("Locked"));
    private LabelRoundy memory_total_label = new LabelRoundy (_("Total"));
    private LabelRoundy memory_used_label = new LabelRoundy (_("Used"));
    private LabelRoundy memory_shared_label = new LabelRoundy (_("Shared"));
    private LabelRoundy swap_total_label = new LabelRoundy (_("Swap Total"));
    private LabelRoundy swap_used_label = new LabelRoundy (_("Swap Used"));

    construct {
        title = (_("Memory"));

    }

    public SystemMemoryView (Memory _memory, Swap _swap) {
        memory = _memory;
        swap = _swap;

        memory_chart = new Chart (1);
        memory_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_300));
        // memory_used_label.set_color ("grape_500");

        // memory_chart.set_serie_color (1, Utils.Colors.get_rgba_color (Utils.Colors.LIME_300));
        // memory_shared_label.set_color ("blueberry_100");

        // memory_chart.set_serie_color (2, Utils.Colors.get_rgba_color (Utils.Colors.LIME_500));
        // memory_chart.set_serie_color (3, Utils.Colors.get_rgba_color (Utils.Colors.LIME_700));
        // memory_chart.set_serie_color (4, Utils.Colors.get_rgba_color (Utils.Colors.LIME_900));
        main_chart = memory_chart;

        set_main_chart_overlay (memory_usage_grid ());
    }

    private Gtk.Grid memory_usage_grid () {
        Gtk.Grid grid = new Gtk.Grid () {
            column_spacing = 8,
            row_spacing = 4,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6,
        };

        grid.attach (memory_used_label, 0, 0, 1, 1);
        grid.attach (memory_total_label, 0, 1, 1, 1);
        grid.attach (memory_shared_label, 1, 0, 1, 1);
        grid.attach (memory_buffered_label, 1, 1, 1, 1);
        grid.attach (memory_cached_label, 2, 0, 1, 1);
        grid.attach (memory_locked_label, 2, 1, 1, 1);
        grid.attach (swap_total_label, 3, 0, 1, 1);
        grid.attach (swap_used_label, 3, 1, 1, 1);

        return grid;
    }

    public void update () {
        main_metric_value = (("%u%%").printf (memory.used_percentage));
        memory_chart.update (0, memory.used_percentage);
        // memory_chart.update (1, memory.shared_percentage);
        // memory_chart.update (2, memory.shared_percentage + memory.buffer_percentage);
        // memory_chart.update (3, memory.shared_percentage + memory.buffer_percentage + memory.cached_percentage);
        // memory_chart.update (3, memory.shared_percentage + memory.buffer_percentage + memory.cached_percentage + memory.locked_percentage);

        memory_total_label.text = format_size ((uint64) memory.total, IEC_UNITS);
        memory_used_label.text = format_size ((uint64) memory.used, IEC_UNITS);
        memory_buffered_label.text = format_size ((uint64) memory.buffer, IEC_UNITS);
        memory_cached_label.text = format_size ((uint64) memory.cached, IEC_UNITS);
        memory_locked_label.text = format_size ((uint64) memory.locked, IEC_UNITS);

        memory_shared_label.text = format_size ((uint64) memory.shared, IEC_UNITS);

        swap_total_label.text = format_size ((uint64) swap.total, IEC_UNITS);
        swap_used_label.text = format_size ((uint64) swap.used, IEC_UNITS);
    }

}
