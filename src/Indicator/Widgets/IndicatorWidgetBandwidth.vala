/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetBandwidth : Monitor.IndicatorWidget {
    public IndicatorWidgetBandwidth (string icon_name) {
        base (icon_name);
    }

    construct {
        label.width_chars = 8;
    }

    public override void update_label (Value value) {
        uint64 bandwidth = value.get_uint64 ();

        label.label = format_network_speed (bandwidth);
    }

    private string format_network_speed (uint64 bandwidth, bool use_bits = false) {
        const int SCALE = 1000;
        bandwidth = bandwidth * (use_bits ? 8 : 1);
        string unit_suffix = use_bits ? "bps" : "Bps";
        string[] units = { "", "K", "M", "G", "T" };

        int unit_index = 0;

        while (bandwidth >= SCALE && unit_index < units.length - 1) {
            bandwidth /= SCALE;
            unit_index++;
        }

        return "%llu %s%s".printf (bandwidth, units[unit_index], unit_suffix);
    }
}
