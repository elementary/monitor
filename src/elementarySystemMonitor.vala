namespace elementarySystemMonitor {

    public class elementarySystemMonitorApp : Granite.Application {
        private MainWindow window = null;
        public string[] args;

        construct {
            app_years = "2014-2017";
            app_icon = "com.github.stsdc.monitor";
            application_id = "com.github.stsdc.monitor";
            app_launcher = application_id + ".desktop";
        }

        public elementarySystemMonitorApp () {
            Granite.Services.Logger.initialize ("LOL");
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
        }

        public override void activate () {
            // only have one window
            if (get_windows () == null) {
                window = new MainWindow (this);
                window.show_all ();
            } else {
                window.present ();
            }
        }

        public static int main (string [] args) {
            var app = new elementarySystemMonitorApp ();
            app.args = args;
            return app.run (args);
        }
    }
}
