/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetBandwidth : Monitor.IndicatorWidget {
    public bool use_bits = false;

    public IndicatorWidgetBandwidth (string icon_name) {
        base (icon_name);
    }

    construct {
        label.width_chars = 8;
    }

    public override void update_label (Value value) {
        uint64 bandwidth = value.get_uint64 ();

        label.label = Utils.Strings.format_network_speed (bandwidth, use_bits);
    }
}
