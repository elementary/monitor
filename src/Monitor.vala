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

            var quit_action = new SimpleAction ("quit", null);
            add_action (quit_action);
            set_accels_for_action ("app.quit", {"<Ctrl>q"});
            quit_action.activate.connect (() => {
                if (window != null) {
                    window.destroy ();
                }
            });
        }

        public static int main (string [] args) {
            var app = new MonitorApp ();
            return app.run (args);
        }
    }
}
