/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 elementary, Inc. (https://elementary.io)
 */

public class Monitor.IndicatorGroupWidget : Gtk.Box {

    public string icon_name { get; construct; }
    public bool revealed { get; set; }

    protected Gtk.Label label;

    public IndicatorGroupWidget (string icon_name) {
        Object (
            orientation: Gtk.Orientation.HORIZONTAL,
            icon_name: icon_name
           );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name) {
            margin_start = 6,
            margin_end = 2,
        };
        base.append (icon);
    }

    public new void append (IndicatorWidget widget) {
        var revealer = new Gtk.Revealer () {
            child = widget,
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
        };
        widget.bind_property ("revealed", revealer, "reveal-child", DEFAULT);
        base.append (revealer);
    }

}
