namespace Monitor {

    public class MainWindow : Gtk.Window {
        // application reference
        private MonitorApp app;
        private Settings saved_state;
        private Shortcuts shortcuts;

        // Widgets
        public Headerbar headerbar;
        //  private Gtk.Button process_info_button;
        private Gtk.ScrolledWindow process_view_window;
        public OverallView process_view;
        private Statusbar statusbar;

        public GenericModel generic_model;
        public Gtk.TreeModelSort sort_model;

        public Gtk.TreeModelFilter filter;


        // Constructs a main window
        public MainWindow (MonitorApp app) {
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

            get_style_context ().add_class ("rounded");

            //  button_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);

            // setup process info button
            //  process_info_button = new Gtk.Button.from_icon_name ("dialog-information-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
            //  process_info_button.get_style_context ().remove_class ("image-button");
            //  button_box.add (process_info_button);

            // setup kill process button


            // TODO: Granite.Widgets.ModeButton to switch between view modes

            // add a process view
            process_view_window = new Gtk.ScrolledWindow (null, null);
            generic_model = new GenericModel ();
            process_view = new OverallView (generic_model);
            
            headerbar = new Headerbar (this);
            set_titlebar (headerbar);

            process_view_window.add (process_view);

            statusbar = new Statusbar ();

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.pack_start (process_view_window, true, true, 0);
            main_box.pack_start (statusbar, false, true, 0);
            this.add (main_box);

            this.show_all ();

            shortcuts = new Shortcuts (this);
            key_press_event.connect ((e) => shortcuts.handle (e));

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
    }
}
