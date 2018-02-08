namespace Monitor {
    public class Settings : Granite.Services.Settings {

        public int window_width { get; set; }
        public int window_height { get; set; }
        public bool is_maximized { get; set; }

        private static GLib.Once<Settings> instance;
        public static unowned Settings get_default () {
            return instance.once (() => { return new Settings (); });
        }

        construct {
            // Controls the direction of the sort indicators
            Gtk.Settings.get_default ().set ("gtk-alternative-sort-arrows", true, null);
        }

        private Settings ()  {
            base ("com.github.stsdc.monitor.settings");
        }
    }
}
