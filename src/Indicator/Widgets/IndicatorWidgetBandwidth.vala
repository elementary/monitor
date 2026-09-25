/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetBandwidth : Monitor.IndicatorWidget {
    public IndicatorWidgetBandwidth (string icon_name) {
        base (icon_name);
    }

    construct {
        label.xalign = 0.5f;
        label.margin_end = 0;
        label.width_chars = 3;
        label.max_width_chars = 3;
        secondary_label.xalign = 1;
        secondary_label.visible = true;
        append (secondary_label);
    }

    public override void update_label (Value value) {
        uint64 bandwidth = value.get_uint64 ();

        string speed_value;
        string speed_unit;
        Utils.Strings.format_network_speed (bandwidth, out speed_value, out speed_unit);

        label.label = speed_value;
        secondary_label.label = speed_unit;
    }
}
