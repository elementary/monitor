/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidget : Gtk.Box {
    protected Gtk.Label label;
    public bool revealed { get; set; }

    construct {
        label = new Gtk.Label (Utils.NOT_AVAILABLE) {
            valign = BASELINE_CENTER
        };
        label.add_css_class (Granite.CssClass.NUMERIC);

        append (label);
    }

    public virtual void update_label (Value value) {
        // NOP; should be overridden by child classes
    }
}
