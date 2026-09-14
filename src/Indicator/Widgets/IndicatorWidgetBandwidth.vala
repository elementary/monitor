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

        label.label = ("%s %s/s").printf (
                format_size ((uint64) bandwidth * Utils.BITS_IN_BYTES, BITS | IEC_UNITS | ONLY_VALUE),
                format_size ((uint64) bandwidth * Utils.BITS_IN_BYTES, BITS | ONLY_UNIT)
            );
    }
}
