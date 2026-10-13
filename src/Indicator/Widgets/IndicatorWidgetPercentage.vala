/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetPercentage : Monitor.IndicatorWidget {
    construct {
        label.width_chars = 4;
    }

    public override void update_label (Value value) {
        uint percentage = value.get_uint ();

        label.label = "%u%%".printf (percentage);

        if (percentage > 90) {
            label.css_classes = {Granite.CssClass.ERROR};
            return;
        }

        if (percentage > 80) {
            label.css_classes = {Granite.CssClass.WARNING};
            return;
        }

        label.css_classes = {""};
    }
}
