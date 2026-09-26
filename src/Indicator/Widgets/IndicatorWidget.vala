/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidget : Gtk.Box {

    protected Gtk.Label label;

    public IndicatorWidget () {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            visible: false
            );
    }

    construct {
        label = new Gtk.Label (Utils.NOT_AVAILABLE) {
            margin_start = 2,
            margin_end = 2,
            margin_top = 2,
            margin_bottom = 2,
            width_chars = 4,
            use_markup = true,
        };

        append (label);
    }

    public virtual void update_label (Value value) {
        // NOP; should be overridden by child classes
    }
}
