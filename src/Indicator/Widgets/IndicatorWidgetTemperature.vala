/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidgetTemperature : Monitor.IndicatorWidget {

    public override void update_label (Value value) {
        int temperature = value.get_int ();

        label.width_chars = 3;
        label.label = "<span font-features='tnum'>%i℃</span>".printf (temperature);
    }
}
