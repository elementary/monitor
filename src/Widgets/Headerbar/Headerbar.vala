/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Monitor.Headerbar : Hdy.HeaderBar {
    private MainWindow window;

    public Search search;
    public Gtk.Grid preferences_grid;

    public Gtk.Revealer search_revealer = new Gtk.Revealer () {
        transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
    };

    construct {
        show_close_button = true;
        has_subtitle = false;
        title = _("Monitor");
    }

    public Headerbar (MainWindow window) {
        this.window = window;

        var preferences_button = new Gtk.MenuButton ();
        preferences_button.has_tooltip = true;
        preferences_button.tooltip_text = (_("Settings"));
        preferences_button.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR));
        pack_end (preferences_button);

        preferences_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        var preferences_popover = new Gtk.Popover (null);
        preferences_popover.add (preferences_grid);
        preferences_button.popover = preferences_popover;

        preferences_grid.show_all ();

        search = new Search (window) {
            valign = Gtk.Align.CENTER
        };

        search_revealer.add (search);

        pack_start (search_revealer);

    }
}
