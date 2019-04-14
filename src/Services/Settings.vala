namespace Monitor {
    public class Settings : Granite.Services.Settings {
        private static GLib.Once<Settings> instance;
        public static unowned Settings get_default () {
            return instance.once (() => { return new Settings (); });
        }

        public int window_width { get; set; }
        public int window_height { get; set; }
        public bool is_maximized { get; set; }

        public bool indicator_state { get; set; }

        public bool background_state { get; set; }

        construct {
            // Controls the direction of the sort indicators
            Gtk.Settings.get_default ().set ("gtk-alternative-sort-arrows", true, null);
        }

        private Settings ()  {
            base ("com.github.stsdc.monitor.settings");
        }
    }
}
