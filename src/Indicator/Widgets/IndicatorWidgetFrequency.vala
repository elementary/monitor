/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetFrequency : Monitor.IndicatorWidget {
    public IndicatorWidgetFrequency (string icon_name) {
        base (icon_name);
    }

    construct {
        secondary_label.width_chars = 3;
        secondary_label.margin_start = 0;
        secondary_label.visible = true;
        append (secondary_label);
    }

    public override void update_label (Value value) {
        double frequency = value.get_double ();

        string frequency_value;
        string frequency_unit;
        Utils.Strings.format_frequency (frequency, out frequency_value, out frequency_unit);

        label.label = frequency_value;
        secondary_label.label = frequency_unit;
    }
}
