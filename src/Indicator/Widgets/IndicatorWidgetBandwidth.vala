/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetBandwidth : Monitor.IndicatorWidget {
    public IndicatorWidgetBandwidth (string icon_name) {
        base (icon_name);
    }

    public override void update_label (Value value) {
        uint64 bandwidth = value.get_uint64 ();

        label.label = format_size (bandwidth);
    }
}
