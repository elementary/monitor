/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetFrequency : Monitor.IndicatorWidget {
    construct {
        label.width_chars = 7;
    }

    public override void update_label (Value value) {
        double frequency = value.get_double ();
        label.label = Utils.Strings.format_frequency (frequency);
    }
}
