/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    public IndicatorWidgetPercentage cpu_widget = new IndicatorWidgetPercentage ("cpu-symbolic");
    public IndicatorWidgetFrequency cpu_frequency_widget = new IndicatorWidgetFrequency ("cpu-symbolic");
    public IndicatorWidgetTemperature cpu_temperature_widget = new IndicatorWidgetTemperature ("temperature-sensor-symbolic");

    public IndicatorWidgetPercentage memory_widget = new IndicatorWidgetPercentage ("ram-symbolic");

    public IndicatorWidgetBandwidth network_up_widget = new IndicatorWidgetBandwidth ("go-up-symbolic");
    public IndicatorWidgetBandwidth network_down_widget = new IndicatorWidgetBandwidth ("go-down-symbolic");

    public IndicatorWidgetPercentage gpu_widget = new IndicatorWidgetPercentage ("gpu-symbolic");
    public IndicatorWidgetPercentage gpu_memory_widget = new IndicatorWidgetPercentage ("gpu-vram-symbolic");
    public IndicatorWidgetTemperature gpu_temperature_widget = new IndicatorWidgetTemperature ("temperature-gpu-symbolic");

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
