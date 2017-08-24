namespace elementarySystemMonitor {
    public class Settings : Granite.Services.Settings {
        public enum WindowState {
            NORMAL,
            MAXIMIZED
        }

        public int window_width { get; set; }
        public int window_height { get; set; }
        public WindowState window_state { get; set; }
        
        private static Settings _settings;
        public static unowned Settings get_default () {
            if (_settings == null) {
                _settings = new Settings ();
            }
            return _settings;
        }

        private Settings ()  {
            base ("com.github.stsdc.monitor.settings");

        }
    }
}