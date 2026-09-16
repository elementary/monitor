/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetBandwidth : Monitor.IndicatorWidget {
    public IndicatorWidgetBandwidth (string icon_name) {
        base (icon_name);
    }

    construct {
        label.use_markup = true;
        label.width_chars = 8;
        label.xalign = 0;
    }

    public override void update_label (Value value) {
        uint64 bandwidth = value.get_uint64 ();

        label.label = GLib.Markup.printf_escaped (
            "<span font_features='tnum'>%s</span>",
            Utils.Strings.format_network_speed (bandwidth)
        );
    }
}
