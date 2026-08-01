/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Widgets.PopoverWidget : Gtk.Box {
    /* Button to hide the indicator */
    private Wingpanel.PopoverMenuItem show_monitor_button;
    private Wingpanel.PopoverMenuItem quit_monitor_button;

    public signal void quit_monitor ();
    public signal void show_monitor ();

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        show_monitor_button = new Wingpanel.PopoverMenuItem ();
        show_monitor_button.text = _("Show Monitor");
        show_monitor_button.hexpand = true;
        quit_monitor_button = new Wingpanel.PopoverMenuItem ();
        quit_monitor_button.text = _("Quit Monitor");
        quit_monitor_button.hexpand = true;
        show_monitor_button.clicked.connect (() => show_monitor ());
        quit_monitor_button.clicked.connect (() => quit_monitor ());

        append (show_monitor_button);
        append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        append (quit_monitor_button);
    }
}
