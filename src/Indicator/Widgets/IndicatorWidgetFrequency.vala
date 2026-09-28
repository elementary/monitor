/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetFrequency : Monitor.IndicatorWidget {

public override void update_label (Value value) {
        double frequency = value.get_double ();

        label.add_css_class (Granite.CssClass.NUMERIC);
        label.width_chars = 7;
        label.label = "%s".printf (Utils.Strings.format_frequency (frequency));
    }
}
