/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Widgets.DisplayWidget : Gtk.Box {
    construct {
        valign = Gtk.Align.CENTER;

        var cpu_group_widget = new IndicatorGroupWidget ("cpu-symbolic");
        var cpu_widget = new IndicatorWidgetPercentage ();
        var cpu_frequency_widget = new IndicatorWidgetFrequency ();
        var cpu_temperature_widget = new IndicatorWidgetTemperature ();

        var memory_group_widget = new IndicatorGroupWidget ("ram-symbolic");
        var memory_widget = new IndicatorWidgetPercentage ();

        var gpu_group_widget = new IndicatorGroupWidget ("gpu-symbolic");
        var gpu_widget = new IndicatorWidgetPercentage ();
        var gpu_memory_widget = new IndicatorWidgetPercentage ();
        var gpu_temperature_widget = new IndicatorWidgetTemperature ();

        var network_group_widget = new IndicatorGroupWidget ("network-symbolic");
        var network_up_widget = new IndicatorWidgetBandwidth ();
        var network_down_widget = new IndicatorWidgetBandwidth ();

        unowned var dbusclient = DBusClient.get_default ();

        dbusclient.monitor_appeared.connect (() => {
            cpu_widget.revealed = Indicator.settings.get_boolean ("indicator-cpu-state");
            cpu_frequency_widget.revealed = Indicator.settings.get_boolean ("indicator-cpu-frequency-state");
            cpu_temperature_widget.revealed = Indicator.settings.get_boolean ("indicator-cpu-temperature-state");
            cpu_group_widget.revealed = cpu_widget.revealed || cpu_frequency_widget.revealed || cpu_temperature_widget.revealed;

            memory_widget.revealed = Indicator.settings.get_boolean ("indicator-memory-state");
            memory_group_widget.revealed = memory_widget.revealed;

            network_up_widget.revealed = Indicator.settings.get_boolean ("indicator-network-upload-state");
            network_down_widget.revealed = Indicator.settings.get_boolean ("indicator-network-download-state");
            network_group_widget.revealed = network_up_widget.revealed || network_down_widget.revealed;

            gpu_widget.revealed = Indicator.settings.get_boolean ("indicator-gpu-state");
            gpu_memory_widget.revealed = Indicator.settings.get_boolean ("indicator-gpu-memory-state");
            gpu_temperature_widget.revealed = Indicator.settings.get_boolean ("indicator-gpu-temperature-state");
            gpu_group_widget.revealed = gpu_widget.revealed || gpu_memory_widget.revealed || gpu_temperature_widget.revealed;
        });

        dbusclient.interface.indicator_cpu_state.connect ((state) => {
            cpu_widget.revealed = state;
            cpu_group_widget.revealed = cpu_widget.revealed || cpu_frequency_widget.revealed || cpu_temperature_widget.revealed;

        });
        dbusclient.interface.indicator_cpu_frequency_state.connect ((state) => {
            cpu_frequency_widget.revealed = state;
            cpu_group_widget.revealed = cpu_widget.revealed || cpu_frequency_widget.revealed || cpu_temperature_widget.revealed;
        });

        dbusclient.interface.indicator_cpu_temperature_state.connect ((state) => {
            cpu_temperature_widget.revealed = state;
            cpu_group_widget.revealed = cpu_widget.revealed || cpu_frequency_widget.revealed || cpu_temperature_widget.revealed;
        });

        dbusclient.interface.indicator_memory_state.connect ((state) => {
            memory_widget.revealed = state;
            memory_group_widget.revealed = memory_widget.revealed;
        });

        dbusclient.interface.indicator_gpu_state.connect ((state) => {
            gpu_widget.revealed = state;
            gpu_group_widget.revealed = gpu_widget.revealed || gpu_memory_widget.revealed || gpu_temperature_widget.revealed;
        });
        dbusclient.interface.indicator_gpu_memory_state.connect ((state) => {
            gpu_memory_widget.revealed = state;
            gpu_group_widget.revealed = gpu_widget.revealed || gpu_memory_widget.revealed || gpu_temperature_widget.revealed;
        });
        dbusclient.interface.indicator_gpu_temperature_state.connect ((state) => {
            gpu_temperature_widget.revealed = state;
            gpu_group_widget.revealed = gpu_widget.revealed || gpu_memory_widget.revealed || gpu_temperature_widget.revealed;
        });

        dbusclient.interface.indicator_network_up_state.connect ((state) => {
            network_up_widget.revealed = state;
            network_group_widget.revealed = network_up_widget.revealed || network_down_widget.revealed;
        });
        dbusclient.interface.indicator_network_down_state.connect ((state) => {
            network_down_widget.revealed = state;
            network_group_widget.revealed = network_up_widget.revealed || network_down_widget.revealed;
        });

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

            var gpu_percentage = Value (typeof (uint));
            gpu_percentage.set_uint (sysres.gpu_percentage);
            gpu_widget.update_label (gpu_percentage);

            var gpu_memory_percentage = Value (typeof (uint));
            gpu_memory_percentage.set_uint (sysres.gpu_memory_percentage);
            gpu_memory_widget.update_label (gpu_memory_percentage);

            var gpu_temperature = Value (typeof (int));
            gpu_temperature.set_int ((int) Math.round (sysres.gpu_temperature));
            gpu_temperature_widget.update_label (gpu_temperature);

            var network_up = Value (typeof (uint64));
            network_up.set_uint64 (sysres.network_up);
            network_up_widget.update_label (network_up);

            var network_down = Value (typeof (uint64));
            network_down.set_uint64 (sysres.network_down);
            network_down_widget.update_label (network_down);

        });


        cpu_group_widget.append (cpu_widget);
        cpu_group_widget.append (cpu_frequency_widget);
        cpu_group_widget.append (cpu_temperature_widget);
        append (cpu_group_widget);

        memory_group_widget.append (memory_widget);
        append (memory_group_widget);

        gpu_group_widget.append (gpu_widget);
        gpu_group_widget.append (gpu_memory_widget);
        gpu_group_widget.append (gpu_temperature_widget);
        append (gpu_group_widget);

        network_group_widget.append (network_up_widget);
        network_group_widget.append (network_down_widget);
        append (network_group_widget);
    }

    public new void append (IndicatorGroupWidget widget) {
        var revealer = new Gtk.Revealer () {
            child = widget,
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
        };
        widget.bind_property ("revealed", revealer, "reveal-child", DEFAULT);
        base.append (revealer);
    }

}
