

namespace elementarySystemMonitor {

    public class MainWindow : Gtk.Window {
        // application reference
        private elementarySystemMonitorApp app;

        // Widgets
        private Gtk.HeaderBar header_bar;
        private Gtk.SearchEntry search;
        private Gtk.Button kill_process_button;
        private Gtk.Button process_info_button;
        private Gtk.ScrolledWindow process_view_window;
        private ProcessView process_view;

        private ProcessMonitor process_monitor;
        private ApplicationProcessModel app_model;


        /**
         * Constructs a main window
         */
        public MainWindow (elementarySystemMonitorApp app) {
            this.app = app;
            this.set_application (app);
            this.set_default_size (800, 600);
            this.window_position = Gtk.WindowPosition.CENTER;
            set_icon_name (app.app_icon);

            // setup header bar
            header_bar = new Gtk.HeaderBar ();
            header_bar.show_close_button = true;
            header_bar.title = _("Monitor");

            // setup search in header bar
            search = new Gtk.SearchEntry ();
            search.placeholder_text = _("Search Process");
            header_bar.pack_end (search);
            this.key_press_event.connect (key_press_event_handler);

            // setup buttons
            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            button_box.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            // setup process info button
            process_info_button = new Gtk.Button.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            button_box.add (process_info_button);

            // setup kill process button
            kill_process_button = new Gtk.Button.from_icon_name ("process-stop-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            kill_process_button.clicked.connect (kill_process);
            button_box.add (kill_process_button);

            // put the buttons in the headerbar
            header_bar.pack_start (button_box);

            // set the headerbar as the titlebar
            this.set_titlebar (header_bar);

            // TODO: Granite.Widgets.ModeButton to switch between view modes

            // add a process view
            process_view_window = new Gtk.ScrolledWindow (null, null);
            process_monitor = new ProcessMonitor ();
            app_model = new ApplicationProcessModel (process_monitor);
            process_view = new ProcessView ();
            process_view.set_model (app_model.model);

            process_view_window.add (process_view);
            this.add (process_view_window);

            this.show_all ();
        }

        /**
         * Handle key presses on window, so that the filter search entry is updated
         */
        private bool key_press_event_handler (Gdk.EventKey event) {
            char typed = event.str[0];

            // if the character typed is an alpha-numeric and the search doesn't currently have focus
            if (typed.isalnum () && !search.is_focus ) {
                // reset filter, grab focus and insert the character
                search.text = "";
                search.grab_focus ();
                search.insert_at_cursor (event.str);
                return true; // tells the window that the event was handled, don't pass it on
            }

            return false; // tells the window that the event wasn't handled, pass it on
        }

        private void kill_process (Gtk.Button button) {
            Gtk.TreeModel model;
            string str = "";
            var selection = process_view.get_selection ().get_selected_rows (out model);
            foreach (var path in selection) {
                Gtk.TreeIter iter;
		        model.get_iter (out iter, path);
		        model.get (iter, 1, out str);
            }
            debug ("Button clicked %s", str);
        }
    }
}
