public class Monitor.Appearance : Object {
    public static void set_prefered_style() {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        bool is_dark = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        gtk_settings.gtk_application_prefer_dark_theme = is_dark;


        var provider = new Gtk.CssProvider ();

        if (is_dark) {
            provider.load_from_resource ("/com/github/stsdc/monitor/monitor-dark.css");
        } else {
            provider.load_from_resource ("/com/github/stsdc/monitor/monitor-light.css");
        }

        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            
        // We listen to changes in Granite.Settings and update our app if the user changes their preference
        granite_settings.notify["prefers-color-scheme"].connect (() => {
            is_dark = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            gtk_settings.gtk_application_prefer_dark_theme = is_dark;
            
            if (is_dark) {
                provider.load_from_resource ("/com/github/stsdc/monitor/monitor-dark.css");
            } else {
                provider.load_from_resource ("/com/github/stsdc/monitor/monitor-light.css");
            }
        });
    }

    public static void retrofit () {
        if (Gtk.Settings.get_default ().gtk_theme_name.has_prefix("io.elementary") ) {
            debug("Chewie, We are home.");
        } else {
            debug("Retrofitting styles to make Monitor usable with a current theme.");
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/stsdc/monitor/monitor-retrofit.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
    }
}