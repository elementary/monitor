/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    construct {
        valign = Gtk.Align.CENTER;

        var cpu_widget = new IndicatorWidgetPercentage ("cpu-symbolic");
        var cpu_frequency_widget = new IndicatorWidgetFrequency ("cpu-symbolic");
        var cpu_temperature_widget = new IndicatorWidgetTemperature ("temperature-sensor-symbolic");

        var memory_widget = new IndicatorWidgetPercentage ("ram-symbolic");

        var network_up_widget = new IndicatorWidgetBandwidth ("go-up-symbolic");
        var network_down_widget = new IndicatorWidgetBandwidth ("go-down-symbolic");

        var gpu_widget = new IndicatorWidgetPercentage ("gpu-symbolic");
        var gpu_memory_widget = new IndicatorWidgetPercentage ("gpu-vram-symbolic");
        var gpu_temperature_widget = new IndicatorWidgetTemperature ("temperature-gpu-symbolic");

        unowned var dbusclient = DBusClient.get_default ();

        dbusclient.monitor_appeared.connect (() => {
            cpu_widget.visible = Indicator.settings.get_boolean ("indicator-cpu-state");
            cpu_frequency_widget.visible = Indicator.settings.get_boolean ("indicator-cpu-frequency-state");
            cpu_temperature_widget.visible = Indicator.settings.get_boolean ("indicator-cpu-temperature-state");
            memory_widget.visible = Indicator.settings.get_boolean ("indicator-memory-state");
            network_up_widget.visible = Indicator.settings.get_boolean ("indicator-network-upload-state");
            network_down_widget.visible = Indicator.settings.get_boolean ("indicator-network-download-state");
            gpu_widget.visible = Indicator.settings.get_boolean ("indicator-gpu-state");
            gpu_memory_widget.visible = Indicator.settings.get_boolean ("indicator-gpu-memory-state");
            gpu_temperature_widget.visible = Indicator.settings.get_boolean ("indicator-gpu-temperature-state");
        });

        dbusclient.interface.indicator_cpu_state.connect ((state) => cpu_widget.visible = state);
        dbusclient.interface.indicator_cpu_frequency_state.connect ((state) => cpu_frequency_widget.visible = state);
        dbusclient.interface.indicator_cpu_temperature_state.connect ((state) => cpu_temperature_widget.visible = state);
        dbusclient.interface.indicator_memory_state.connect ((state) => memory_widget.visible = state);
        dbusclient.interface.indicator_network_up_state.connect ((state) => network_up_widget.visible = state);
        dbusclient.interface.indicator_network_down_state.connect ((state) => network_down_widget.visible = state);
        dbusclient.interface.indicator_gpu_state.connect ((state) => gpu_widget.visible = state);
        dbusclient.interface.indicator_gpu_memory_state.connect ((state) => gpu_memory_widget.visible = state);
        dbusclient.interface.indicator_gpu_temperature_state.connect ((state) => gpu_temperature_widget.visible = state);

        dbusclient.interface.update.connect ((sysres) => {
            var cpu_percentage = Value (typeof (uint));
            cpu_percentage.set_uint (sysres.cpu_percentage);
            cpu_widget.update_label (cpu_percentage);

            var cpu_frequency = Value (typeof (double));
            cpu_frequency.set_double (sysres.cpu_frequency);
            cpu_frequency_widget.update_label (cpu_frequency);

            var cpu_temperature = Value (typeof (int));
            cpu_temperature.set_int ((int) Math.round (sysres.cpu_temperature));
            cpu_temperature_widget.update_label (cpu_temperature);

            var memory_percentage = Value (typeof (uint));
            memory_percentage.set_uint (sysres.memory_percentage);
            memory_widget.update_label (memory_percentage);

            var network_up = Value (typeof (uint64));
            network_up.set_uint64 (sysres.network_up);
            network_up_widget.update_label (network_up);

            var network_down = Value (typeof (uint64));
            network_down.set_uint64 (sysres.network_down);
            network_down_widget.update_label (network_down);

            var gpu_percentage = Value (typeof (uint));
            gpu_percentage.set_uint (sysres.gpu_percentage);
            gpu_widget.update_label (gpu_percentage);

            var gpu_memory_percentage = Value (typeof (uint));
            gpu_memory_percentage.set_uint (sysres.gpu_memory_percentage);
            gpu_memory_widget.update_label (gpu_memory_percentage);

            var gpu_temperature = Value (typeof (int));
            gpu_temperature.set_int ((int) Math.round (sysres.gpu_temperature));
            gpu_temperature_widget.update_label (gpu_temperature);
        });

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
