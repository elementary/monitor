/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorGroupWidget : Gtk.Box {

    public string icon_name { get; construct; }

    protected Gtk.Label label;

    public IndicatorGroupWidget (string icon_name) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            icon_name: icon_name,
            visible: false
            );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name);
        append (icon);
    }

}
