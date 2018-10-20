namespace Monitor {

    public class MonitorApp : Gtk.Application {
        private MainWindow window = null;
        public string[] args;

        construct {
            application_id = "com.github.stsdc.monitor";
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
            var app = new MonitorApp ();
            return app.run (args);
        }
    }
}
