/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Appearance : Object {
    private static Gtk.CssProvider provider;

    public static void set_prefered_style () {
        provider = new Gtk.CssProvider ();
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var granite_settings = Granite.Settings.get_default ();
        update_style_provider (granite_settings.prefers_color_scheme);

        // We listen to changes in Granite.Settings and update our app if the user changes their preference
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            update_style_provider (granite_settings.prefers_color_scheme);
        });
    }

    private static void update_style_provider (Granite.Settings.ColorScheme color_scheme) {
        if (color_scheme == DARK) {
            provider.load_from_resource ("/io/elementary/monitor/monitor-dark.css");
        } else {
            provider.load_from_resource ("/io/elementary/monitor/monitor-light.css");
        }
    }
}
