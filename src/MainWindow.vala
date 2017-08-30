

namespace elementarySystemMonitor {

    public class MainWindow : Gtk.Window {
        // application reference
        private elementarySystemMonitorApp app;

        // Settings
        private Settings saved_state;

        // Shortcuts LOL
        private Shortcuts shortcuts;

        // Widgets
        private Gtk.HeaderBar header_bar;
        private Search search;
        private Gtk.Button kill_process_button;
        //  private Gtk.Button process_info_button;
        private Gtk.ScrolledWindow process_view_window;
        private ProcessView process_view;

        private ProcessMonitor process_monitor;
        private ApplicationProcessModel app_model;
        private Gtk.TreeModelSort sort_model;

        public Gtk.TreeModelFilter filter;


        // Constructs a main window
        public MainWindow (elementarySystemMonitorApp app) {
            this.app = app;
            this.set_application (app);
            saved_state = Settings.get_default ();
            this.set_default_size (saved_state.window_width, saved_state.window_height);
            // Maximize window if necessary
            switch (saved_state.window_state) {
                case Settings.WindowState.MAXIMIZED:
                    this.maximize ();
                    break;
                default:
                    break;
            }
            this.window_position = Gtk.WindowPosition.CENTER;
            set_icon_name (app.app_icon);

            shortcuts = new Shortcuts (this, app);
            shortcuts.search_signal.connect (() => {
                search.activate_entry ();
            });

            // setup header bar
            header_bar = new Gtk.HeaderBar ();
            header_bar.show_close_button = true;
            header_bar.title = _("Monitor");

            // setup buttons
            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            //  button_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);

            // setup process info button
            //  process_info_button = new Gtk.Button.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            //  process_info_button.get_style_context ().remove_class ("image-button");
            //  button_box.add (process_info_button);

            // setup kill process button

            kill_process_button = new Gtk.Button.with_label (_("End process"));
            kill_process_button.clicked.connect (kill_process);
            //  kill_process_button.tooltip_text = (_("Kill process"));
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
            search = new Search (process_view, app_model.model);
            header_bar.pack_end (search);
            this.key_press_event.connect (key_press_event_handler);

            process_view_window.add (process_view);
            this.add (process_view_window);

            sort_model = new Gtk.TreeModelSort.with_model (search.filter_model);
            process_view.set_model (sort_model);

            this.show_all ();

            // Maybe move it from here to Settings
            delete_event.connect (() => {
                    int window_width;
                    int window_height;
                    get_size (out window_width, out window_height);
                    saved_state.window_width = window_width;
                    saved_state.window_height = window_height;
                    if (is_maximized) {
                        saved_state.window_state = Settings.WindowState.MAXIMIZED;
                    } else {
                        saved_state.window_state = Settings.WindowState.NORMAL;
                    }
                    return false;
            });
        }

        // Handle key presses on window, so that the filter search entry is updated
        private bool key_press_event_handler (Gdk.EventKey event) {
            char typed = event.str[0];

            // if the character typed is an alpha-numeric and the search doesn't currently have focus
            if (typed.isalnum () && !search.is_focus ) {
                search.activate_entry (event.str);
                return true; // tells the window that the event was handled, don't pass it on
            }

            return false; // tells the window that the event wasn't handled, pass it on
        }

        private void kill_process (Gtk.Button button) {
            int pid = process_view.get_pid_of_selected ();
            if (pid > 0) {
                app_model.kill_process (pid);
            }
        }
    }
}
