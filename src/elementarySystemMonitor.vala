namespace elementarySystemMonitor {

    public class elementarySystemMonitorApp : Granite.Application {
        private MainWindow window = null;
        public string[] args;

        construct {
            program_name = Constants.RELEASE_NAME;
            exec_name = Constants.EXEC_NAME;

            build_data_dir = Constants.DATADIR;
            build_pkg_data_dir = Constants.PKGDATADIR;
            build_release_name = Constants.RELEASE_NAME;
            build_version = Constants.VERSION;
            build_version_info = Constants.VERSION_INFO;

            app_years = "2014-2017";
            app_icon = "com.github.stsdc.monitor";
            app_launcher = application_id + ".desktop";
            application_id = "com.github.stsdc.monitor";

        }

        public elementarySystemMonitorApp () {
            Granite.Services.Logger.initialize (Constants.RELEASE_NAME);
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
