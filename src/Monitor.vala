namespace Monitor {

    public class MonitorApp : Gtk.Application {
        private MainWindow window = null;
        public string[] args;

        private static bool start_minimized = false;
        private static bool status_minimized = false;
    private const GLib.OptionEntry[] cmd_options = {
		    // --start-minimized
		    { "start-minimized", 'm', 0, OptionArg.NONE, ref start_minimized, "Start minimized with wingpanel indicator", null },
		    // list terminator
		    { null }
	    };

        //contructor replacement, flags added
        public MonitorApp (bool start_minimized_status) {
            Object (
                application_id : "com.github.stsdc.monitor",
                flags: ApplicationFlags.FLAGS_NONE
            );
            status_minimized = start_minimized_status;
        }

        public override void activate () {
            // only have one window
            if (get_windows () == null) {
                window = new MainWindow (this);

                //start minimized 
                if (status_minimized) {
                    window.hide ();
                } else {
                    window.show_all ();
                }
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
            // add command line options 
            try {
		        var opt_context = new OptionContext ("");
		            opt_context.set_help_enabled (true);
			        opt_context.add_main_entries (cmd_options, null);
			        opt_context.parse (ref args);
            } catch (OptionError e) {
                print ("error: %s\n", e.message);
			    print ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
			    return 0;
            }

            MonitorApp app;

            if (start_minimized) {
                app = new MonitorApp (true);
            } else {
                app = new MonitorApp (false);
            }

            return app.run (args);
        }
    }
}
