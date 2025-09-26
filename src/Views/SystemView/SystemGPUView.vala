/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.SystemGPUView : Monitor.WidgetResource {
    private Chart gpu_chart;
    private Chart gpu_vram_percentage_chart;
    private Chart gpu_temperature_chart;
    private IGPU gpu;

    private LabelRoundy gpu_vram_percentage_label;
    private LabelRoundy gpu_temperature_label;


    construct {
        gpu_vram_percentage_label = new LabelRoundy (_("VRAM"));
        gpu_vram_percentage_label.margin = 6;
        gpu_vram_percentage_label.margin_top = 2;

        gpu_temperature_label = new LabelRoundy (_("TEMPERATURE"));
        gpu_temperature_label.margin = 6;
        gpu_temperature_label.margin_top = 2;

        gpu_vram_percentage_chart = new Chart (1);
        gpu_vram_percentage_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_500));
        gpu_vram_percentage_chart.height_request = -1;
        gpu_vram_percentage_chart.config.y_axis.fixed_max = 100.0;
        gpu_temperature_chart = new Chart (1);
        gpu_temperature_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_500));
        gpu_temperature_chart.height_request = -1;

        var grid_frequency_info = new Gtk.Grid ();
        grid_frequency_info.attach (gpu_vram_percentage_label, 0, 0, 1, 1);
        grid_frequency_info.attach (gpu_vram_percentage_chart, 0, 0, 1, 1);

        var grid_temperature_info = new Gtk.Grid ();
        grid_temperature_info.attach (gpu_temperature_label, 0, 0, 1, 1);
        grid_temperature_info.attach (gpu_temperature_chart, 0, 0, 1, 1);



        var smol_charts_container = new Gtk.Grid ();
        smol_charts_container.width_request = 200;
        smol_charts_container.hexpand = false;
        smol_charts_container.halign = Gtk.Align.START;
        smol_charts_container.attach (grid_frequency_info, 0, 0, 1, 1);
        smol_charts_container.attach (grid_temperature_info, 0, 1, 1, 1);
        smol_charts_container.row_spacing = 6;
        smol_charts_container.margin_start = 6;

        add_charts_container (smol_charts_container);
    }

    public SystemGPUView (IGPU _gpu) {
        gpu = _gpu;

        title = gpu.name;

        gpu_chart = new Chart (1);
        gpu_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_500));
        main_chart = gpu_chart;

        set_main_chart_overlay (gpu_usage_grid ());
    }

    private Gtk.Grid gpu_usage_grid () {
        Gtk.Grid grid = new Gtk.Grid () {
            column_spacing = 8,
            row_spacing = 4,
            margin = 6
        };

        return grid;
    }

    public void update () {
        main_metric_value = (("%d%%").printf (gpu.percentage));
        gpu_chart.update (0, gpu.percentage);

        gpu_vram_percentage_chart.update (0, gpu.memory_percentage);
        gpu_temperature_chart.update (0, gpu.temperature);
        gpu_vram_percentage_label.text = ("%.2f %s").printf (gpu.memory_percentage, "%");
        gpu_temperature_label.text = ("%.2f %s").printf (gpu.temperature, _("℃"));

    }

}
