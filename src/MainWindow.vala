    public class Monitor.MainWindow : Gtk.Window {
        // application reference
        public Settings saved_state;
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

        public DBusServer dbusserver;

        private Updater updater;


        // Constructs a main window
        public MainWindow (MonitorApp app) {
            this.set_application (app);
            saved_state = Settings.get_default ();
            this.set_default_size (saved_state.window_width, saved_state.window_height);

            if (saved_state.is_maximized) { this.maximize (); }
            this.window_position = Gtk.WindowPosition.CENTER;

            get_style_context ().add_class ("rounded");

            updater = Updater.get_default ();

            dbusserver = DBusServer.get_default();


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

            updater.update.connect ((sysres) => {
                statusbar.update ();
                dbusserver.update (sysres);
                });

            shortcuts = new Shortcuts (this);
            key_press_event.connect ((e) => shortcuts.handle (e));

            // Maybe move it from here to Settings
            delete_event.connect (() => {
                    int window_width;
                    int window_height;
                    get_size (out window_width, out window_height);
                    saved_state.window_width = window_width;
                    saved_state.window_height = window_height;
                    saved_state.is_maximized = this.is_maximized;
                    return false;
            });
        }
    }
