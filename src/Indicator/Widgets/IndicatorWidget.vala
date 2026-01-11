/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorWidget : Gtk.Box {

    public string icon_name { get; construct; }

    protected Gtk.Label label;

    public IndicatorWidget (string icon_name) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            icon_name: icon_name,
            visible: false
            );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.SMALL_TOOLBAR);

        label = new Gtk.Label (Utils.NOT_AVAILABLE) {
            margin = 2,
            width_chars = 4,
        };

        pack_start (icon);
        pack_start (label);
    }

    public virtual void update_label (Value value) {
        // NOP; should be overridden by child classes
    }
}
