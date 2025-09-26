/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.SystemCPUView : Monitor.WidgetResource {
    private Chart cpu_utilization_chart;
    private Chart cpu_frequency_chart;
    private Chart cpu_temperature_chart;
    private CPU cpu;

    private LabelRoundy cpu_frequency_label;
    private LabelRoundy cpu_temperature_label;

    private Gee.ArrayList<Gtk.Label ?> core_label_list;

    public SystemCPUView (CPU _cpu) {
        cpu = _cpu;
        title = cpu.model_name;

        set_popover_more_info (new SystemCPUInfoPopover (cpu));

        cpu_utilization_chart = new Chart (cpu.core_list.size, MonitorApp.settings.get_boolean ("smooth-lines-state"), 1.0);
        cpu_utilization_chart.config.y_axis.tick_interval = 100;
        cpu_utilization_chart.config.y_axis.fixed_max = 100.0 * cpu.core_list.size;

        main_chart = cpu_utilization_chart;
        set_main_chart_overlay (grid_core_labels ());
    }

    construct {
        cpu_temperature_chart = new Chart (1) {
            height_request = -1
        };
        cpu_temperature_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_500));

        core_label_list = new Gee.ArrayList<Gtk.Label> ();

        cpu_frequency_label = new LabelRoundy (_("Frequency")) {
            margin_top = 2,
            margin_end = 6,
            margin_bottom = 6,
            margin_start = 6
        };

        cpu_temperature_label = new LabelRoundy (_("Temperature")) {
            margin_top = 2,
            margin_end = 6,
            margin_bottom = 6,
            margin_start = 6
        };

        cpu_frequency_chart = new Chart (1) {
            height_request = -1
        };
        cpu_frequency_chart.set_serie_color (0, Utils.Colors.get_rgba_color (Utils.Colors.LIME_500));
        cpu_frequency_chart.config.y_axis.fixed_max = 5.0;

        var freq_info_overlay = new Gtk.Overlay () {
            child = cpu_frequency_chart
        };
        freq_info_overlay.add_overlay (cpu_frequency_label);

        var temp_info_overlay = new Gtk.Overlay () {
            child = cpu_temperature_chart
        };
        temp_info_overlay.add_overlay (cpu_temperature_label);

        var small_charts_box = new Gtk.Box (VERTICAL, 6) {
            hexpand = false,
            width_request = 200
        };
        small_charts_box.append (freq_info_overlay);
        small_charts_box.append (temp_info_overlay);

        add_charts_container (small_charts_box);
    }

    public void update () {
        cpu_frequency_chart.update (0, cpu.frequency);

        cpu_temperature_chart.update (0, cpu.temperature_mean);
        cpu_temperature_label.text = ("%.2f %s").printf (cpu.temperature_mean, _("℃"));

        double cpu_prev_util = 0;

        for (int i = 0; i < cpu.core_list.size; i++) {
            // must reverse to render layers in the right order
            int reversed_i = cpu.core_list.size - i - 1;

            double core_percentage = cpu.core_list[i].percentage_used;
            double core_percentage_reversed = cpu.core_list[reversed_i].percentage_used;

            if (i == 0) {
                cpu_utilization_chart.update (reversed_i, core_percentage_reversed);
            } else {
                cpu_utilization_chart.update (reversed_i, core_percentage_reversed + cpu_prev_util);
            }

            cpu_prev_util = cpu_prev_util + core_percentage_reversed;

            string percentage_formatted = ("% 3d%%").printf ((int) core_percentage);
            core_label_list[i].set_text (percentage_formatted);

            core_label_list[i].remove_css_class ("core_badge-mild-warning");
            core_label_list[i].remove_css_class ("core_badge-strong-warning");
            core_label_list[i].remove_css_class ("core_badge-critical-warning");

            if (core_percentage > 75.0) {
                core_label_list[i].add_css_class ("core_badge-mild-warning");
                core_label_list[i].remove_css_class ("core_badge-strong-warning");
                core_label_list[i].remove_css_class ("core_badge-critical-warning");
            }

            if (core_percentage > 85.0) {
                core_label_list[i].add_css_class ("core_badge-strong-warning");
                core_label_list[i].remove_css_class ("core_badge-mild-warning");
                core_label_list[i].remove_css_class ("core_badge-critical-warning");
            }

            if (core_percentage > 90.0) {
                core_label_list[i].add_css_class ("core_badge-critical-warning");
                core_label_list[i].remove_css_class ("core_badge-mild-warning");
                core_label_list[i].remove_css_class ("core_badge-strong-warning");
            }
        }

        main_metric_value = ("%d%%").printf (cpu.percentage);
        cpu_frequency_label.text = ("%.2f %s").printf (cpu.frequency, _("GHz"));
    }

    private Gtk.Grid grid_core_labels () {
        Gtk.Grid grid = new Gtk.Grid () {
            column_spacing = 8,
            row_spacing = 4,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6,
        };

        int column = 0;
        int row = 0;
        for (int i = 0; i < cpu.core_list.size; i++) {
            var core_label = new Gtk.Label (Utils.NO_DATA) {
                width_chars = 4
            };
            core_label.add_css_class ("core_badge");
            // core_label.set_text (Utils.NO_DATA);
            core_label_list.add (core_label);

            grid.attach (core_label, column, row, 1, 1);

            row++;
            if (row > 1) {
                column++;
                row = 0;
            }
        }
        var threads_label = new Gtk.Label (_("THREADS"));
        // this can be archived by Gtk.STYLE_CLASS_DIM_LABEL and
        // Granite.STYLE_CLASS_SMALL_LABEL, however the style is
        // differs from the OG
        threads_label.add_css_class ("small-label");
        grid.attach (threads_label, 0, -1, column, 1);

        return grid;
    }

}
