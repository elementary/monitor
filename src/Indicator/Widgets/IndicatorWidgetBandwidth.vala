/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetBandwidth : Monitor.IndicatorWidget {
    construct {
        label.width_chars = 9;
    }

    public override void update_label (Value value) {
        uint64 bandwidth = value.get_uint64 ();
        label.label = "%s".printf (Utils.Strings.format_network_speed (bandwidth));
    }
}
