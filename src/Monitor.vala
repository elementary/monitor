namespace Monitor {

    public class MonitorApp : Gtk.Application {
        private MainWindow window = null;
        public string[] args;

        private static bool start_in_background = false;
        private static bool status_background = false;
        private const GLib.OptionEntry[] cmd_options = {
        // --start-in-background
            { "start-in-background", 'b', 0, OptionArg.NONE, ref start_in_background, "Start in background with wingpanel indicator", null },
            // list terminator
            { null }
        };

        // contructor replacement, flags added
        public MonitorApp (bool status_indicator) {
            Object (
                application_id : "com.github.stsdc.monitor",
                flags: ApplicationFlags.FLAGS_NONE
            );
            status_background = status_indicator;
        }

        public override void activate () {
            // only have one window
            if (get_windows () != null) {
                window.show_all ();
                window.present ();
                return;
            }

            window = new MainWindow (this);

            // start in background with indicator
            if (status_background || window.saved_state.background_state) {
                if (!window.saved_state.indicator_state) {
                    window.saved_state.indicator_state = true;
                }

                window.hide ();
                window.saved_state.background_state = true;
            } else {
                window.show_all ();
            }

            window.process_view.focus_on_first_row ();

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
            // add command line options 
            try {
                var opt_context = new OptionContext ("");
                opt_context.set_help_enabled (true);
                opt_context.add_main_entries (cmd_options, null);
                opt_context.parse (ref args);
            } catch (OptionError e) {
                print ("Error: %s\n", e.message);
                print ("Run '%s --help' to see a full list of available command line options.\n\n", args[0]);
                return 0;
            }

            var app = new MonitorApp (start_in_background);

            return app.run (args);
        }
    }
}
