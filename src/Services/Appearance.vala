public class Monitor.Appearance : Object {
    public static void set_prefered_style () {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        bool is_dark = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        gtk_settings.gtk_application_prefer_dark_theme = is_dark;

        load_style (is_dark);

        // We listen to changes in Granite.Settings and update our app if the user changes their preference
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            is_dark = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            gtk_settings.gtk_application_prefer_dark_theme = is_dark;
            load_style (is_dark);
        });
    }

    private static void load_style (bool is_dark) {
        var provider = new Gtk.CssProvider ();

            if (is_dark) {
                provider.load_from_resource ("/com/github/stsdc/monitor/monitor-dark.css");
            } else {
                provider.load_from_resource ("/com/github/stsdc/monitor/monitor-light.css");
            }
        // @TODO: Fix styles
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

    }

    public static void retrofit () {
        if (Gtk.Settings.get_default ().gtk_theme_name.has_prefix ("io.elementary") ) {
            debug ("Chewie, We are home.");
        } else {
            debug ("Retrofitting styles to make Monitor usable with a current theme.");
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/stsdc/monitor/monitor-retrofit.css");
            // @TODO: Fix retrofitting styles
            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
    }
}
