

namespace elementarySystemMonitor {

    public class MainWindow : Gtk.Window {
        // application reference
        private elementarySystemMonitorApp app;

        // Widgets
        private Gtk.HeaderBar header_bar;
        private Gtk.SearchEntry search_entry;
        private Gtk.Button kill_process_button;
        private Gtk.Button process_info_button;
        private Gtk.ScrolledWindow process_view_window;
        private ProcessView process_view;

        private ProcessMonitor process_monitor;
        private ApplicationProcessModel app_model;

        public Gtk.TreeModelFilter filter;

        // taken from Torrential
        private SimpleActionGroup actions = new SimpleActionGroup ();
        private const string ACTION_GROUP_PREFIX_NAME = "mon";
        private const string ACTION_GROUP_PREFIX = ACTION_GROUP_PREFIX_NAME + ".";
        private const string ACTION_SEARCH = "search";

        private const ActionEntry[] action_entries = {
            {ACTION_SEARCH,                on_search          }
        };

        public static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

        static construct {
            action_accelerators.set (ACTION_SEARCH, "<Ctrl>f");
        }

        // Constructs a main window
        public MainWindow (elementarySystemMonitorApp app) {
            this.app = app;
            this.set_application (app);
            this.set_default_size (800, 600);
            this.window_position = Gtk.WindowPosition.CENTER;
            set_icon_name (app.app_icon);

            actions.add_action_entries (action_entries, this);
            insert_action_group (ACTION_GROUP_PREFIX_NAME, actions);
            foreach (var action in action_accelerators.get_keys ()) {
                app.set_accels_for_action (ACTION_GROUP_PREFIX + action, action_accelerators[action].to_array ());
            }

            // setup header bar
            header_bar = new Gtk.HeaderBar ();
            header_bar.show_close_button = true;
            header_bar.title = _("Monitor");

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

            // setup search in header bar
            search_entry = new Gtk.SearchEntry ();
            search_entry.placeholder_text = _("Search Process");
            header_bar.pack_end (search_entry);
            this.key_press_event.connect (key_press_event_handler);

            filter = new Gtk.TreeModelFilter( app_model.model, null );

            search_entry.search_changed.connect (() => {
                filter.refilter ();
            });


            filter.set_visible_func(filter_func);

            process_view.set_model (filter);

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
            if (typed.isalnum () && !search_entry.is_focus ) {
                // reset filter, grab focus and insert the character
                search_entry.text = "";
                search_entry.grab_focus ();
                search_entry.insert_at_cursor (event.str);
                return true; // tells the window that the event was handled, don't pass it on
            }

            return false; // tells the window that the event wasn't handled, pass it on
        }

        private void kill_process (Gtk.Button button) {
            int pid = process_view.get_pid_of_selected ();
            app_model.kill_process (pid);
        }

        private void on_search (SimpleAction action) {
            search_entry.text = "";
            search_entry.grab_focus ();
        }

        private bool filter_func (Gtk.TreeModel model, Gtk.TreeIter iter) {
            string name_haystack;
            int pid_haystack;
            var needle = search_entry.text;
            if ( needle.length == 0 ) {
                return true;
            }

            model.get( iter, ProcessColumns.NAME, out name_haystack, -1 );
            model.get( iter, ProcessColumns.PID, out pid_haystack, -1 );
            bool name_found = name_haystack.casefold().contains( needle.casefold());
            bool pid_found = pid_haystack.to_string().casefold().contains( needle.casefold());
            bool found = name_found || pid_found;
            return found;
        }


    }
}
