/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetTemperature : Monitor.IndicatorWidget {
    construct {
        label.width_chars = 3;
    }

    public override void update_label (Value value) {
        int temperature = value.get_int ();
        label.label = "%i℃".printf (temperature);
    }
}
