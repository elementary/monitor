/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Appearance : Object {
    public static void set_prefered_style () {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        bool is_dark = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        gtk_settings.gtk_application_prefer_dark_theme = is_dark;


        var provider = new Gtk.CssProvider ();

        if (is_dark) {
            provider.load_from_resource ("/io/elementary/monitor/monitor-dark.css");
        } else {
            provider.load_from_resource ("/io/elementary/monitor/monitor-light.css");
        }

        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        // We listen to changes in Granite.Settings and update our app if the user changes their preference
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            is_dark = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            gtk_settings.gtk_application_prefer_dark_theme = is_dark;

            if (is_dark) {
                provider.load_from_resource ("/io/elementary/monitor/monitor-dark.css");
            } else {
                provider.load_from_resource ("/io/elementary/monitor/monitor-light.css");
            }
        });
    }
}
