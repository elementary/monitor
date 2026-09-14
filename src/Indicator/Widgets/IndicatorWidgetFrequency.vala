/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetFrequency : Monitor.IndicatorWidget {
    public IndicatorWidgetFrequency (string icon_name) {
        base (icon_name);
    }

    construct {
        label.use_markup = true;
    }

    public override void update_label (Value value) {
        double frequency = value.get_double ();

        label.label = ("<span font-features='tnum'>%.2f %s</span>").printf (frequency, _("GHz"));
    }
}
