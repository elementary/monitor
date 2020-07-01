    public class Monitor.MainWindow : Gtk.Window {
        // application reference
        private Shortcuts shortcuts;

        // Widgets
        public Headerbar headerbar;
        //  private Gtk.Button process_info_button;

        public ProcessView process_view;
        public SystemView system_view;

        private Statusbar statusbar;

        public DBusServer dbusserver;

        private Updater updater;


        // Constructs a main window
        public MainWindow (MonitorApp app) {
            this.set_application (app);

            setup_window_state ();

            get_style_context ().add_class ("rounded");

            process_view = new ProcessView ();
            system_view = new SystemView ();

            Gtk.Stack stack = new Gtk.Stack ();
            stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            stack.add_titled (process_view, "process_view", "Processes");
            stack.add_titled (system_view, "system_view", "System");

            Gtk.StackSwitcher stack_switcher = new Gtk.StackSwitcher ();
            stack_switcher.set_stack(stack);

            headerbar = new Headerbar (this);
            headerbar.set_custom_title (stack_switcher);
            set_titlebar (headerbar);

            statusbar = new Statusbar ();

            var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            main_box.pack_start (stack, true, true, 0);
            main_box.pack_start (statusbar, false, true, 0);
            this.add (main_box);

            updater = Updater.get_default ();
            dbusserver = DBusServer.get_default ();

            updater.update.connect ((resources) => {
                var res = resources.serialize ();
                statusbar.update (res);
                dbusserver.update (res);
                process_view.update();
                dbusserver.indicator_state (MonitorApp.settings.get_boolean ("indicator-state"));
            });


            dbusserver.quit.connect (() => app.quit());
            dbusserver.show.connect (() => {
                this.deiconify ();
                this.present ();
                setup_window_state ();
                this.show_all ();
            });

            shortcuts = new Shortcuts (this);
            key_press_event.connect ((e) => shortcuts.handle (e));

            this.delete_event.connect (() => {
                int window_width, window_height, position_x, position_y;
                get_size (out window_width, out window_height);
                get_position (out position_x, out position_y);
                MonitorApp.settings.set_int ("window-width", window_width);
                MonitorApp.settings.set_int ("window-height", window_height);
                MonitorApp.settings.set_int ("position-x", position_x);
                MonitorApp.settings.set_int ("position-y", position_y);
                MonitorApp.settings.set_boolean ("is-maximized", this.is_maximized);

                if (MonitorApp.settings.get_boolean ("indicator-state")) {
                    this.hide_on_delete ();
                } else {
                    dbusserver.indicator_state (false);
                    app.quit ();
                }

                return true;
            });

            dbusserver.indicator_state (MonitorApp.settings.get_boolean ("indicator-state"));
        }

        private void setup_window_state () {
            int window_width = MonitorApp.settings.get_int ("window-width");
            int window_height = MonitorApp.settings.get_int ("window-height");
            this.set_default_size (window_width, window_height);

            if (MonitorApp.settings.get_boolean ("is-maximized")) { this.maximize (); }

            int position_x = MonitorApp.settings.get_int ("position-x");
            int position_y = MonitorApp.settings.get_int ("position-y");
            if (position_x == -1 || position_y == -1) {
                // -1 is default value of these keys, which means this is the first launch
                this.window_position = Gtk.WindowPosition.CENTER;
            } else {
                move (position_x, position_y);
            }
        }
    }
