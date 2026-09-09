/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetPercentage : Monitor.IndicatorWidget {
    public IndicatorWidgetPercentage (string icon_name) {
        base (icon_name);
    }

    public override void update_label (Value value) {
        uint percentage = value.get_uint ();

        label.label = "%u%%".printf (percentage);
        label.remove_css_class ("monitor-indicator-label-warning");
        label.remove_css_class ("monitor-indicator-label-critical");

        if (percentage > 80) {
            label.add_css_class ("monitor-indicator-label-warning");
        }

        if (percentage > 90) {
            label.add_css_class ("monitor-indicator-label-critical");
        }
    }
}
