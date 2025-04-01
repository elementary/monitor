/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    public IndicatorWidget cpu_widget = new IndicatorWidget ("cpu-symbolic");
    public IndicatorWidget cpu_frequency_widget = new IndicatorWidget ("cpu-symbolic");
    public IndicatorWidget cpu_temperature_widget = new IndicatorWidget ("temperature-sensor-symbolic");

    public IndicatorWidget memory_widget = new IndicatorWidget ("ram-symbolic");

    public IndicatorWidget network_up_widget = new IndicatorWidget ("go-up-symbolic");
    public IndicatorWidget network_down_widget = new IndicatorWidget ("go-down-symbolic");

    public IndicatorWidget gpu_widget = new IndicatorWidget ("gpu-symbolic");
    public IndicatorWidget gpu_memory_widget = new IndicatorWidget ("gpu-vram-symbolic");
    public IndicatorWidget gpu_temperature_widget = new IndicatorWidget ("temperature-gpu-symbolic");

    construct {
        valign = Gtk.Align.CENTER;

        add (cpu_widget);
        add (cpu_frequency_widget);
        add (cpu_temperature_widget);
        add (memory_widget);
        add (gpu_widget);
        add (gpu_memory_widget);
        add (gpu_temperature_widget);
        add (network_up_widget);
        add (network_down_widget);
    }
}
