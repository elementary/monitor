

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

            app_copyright = "2014";
            app_years = "2014";
            // TODO: GIVE ME REAL ICON
            app_icon = "application-default-icon";
            // TODO: GIVE ME REAL DESKTOP FILE
            app_launcher = "elementarySystemMonitor.desktop";
            // TODO: CHANGE ME TO REAL NAME
            application_id = "net.launchpad.elementarySystemMonitor";

            // TODO: CHANGE ME TO REAL NAME
            main_url = "https://code.launchpad.net/elementarySystemMonitor";
            bug_url = "https://bugs.launchpad.net/elementarySystemMonitor";
            help_url = "https://code.launchpad.net/elementarySystemMonitor";
            translate_url = "https://translations.launchpad.net/elementarySystemMonitor";

            about_authors = {"Michael P. Starkweather <mpstark@gmail.com>"};
            about_documenters = {"Michael P. Starkweather <mpstark@gmail.com>"};
            about_artists = {"Michael P. Starkweather <mpstark@gmail.com>"};
            about_comments = "System Monitor for the Modern Desktop"; // TODO
            about_translators = null;
            about_license = "to be selected";
            about_license_type = Gtk.License.GPL_3_0; // TODO
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
