public class Monitor.MainWindow : Hdy.ApplicationWindow {
    // application reference
    private Shortcuts shortcuts;

    private Resources resources;

    // Widgets
    public Headerbar headerbar;

    public ProcessView process_view;
    public SystemView system_view;
    private Gtk.Stack stack;

    private Statusbar statusbar;

    public DBusServer dbusserver;


    // Constructs a main window
    public MainWindow (MonitorApp app) {
        Hdy.init ();
        this.set_application (app);

        setup_window_state ();

        title = _("Monitor");

        get_style_context ().add_class ("rounded");

        resources = new Resources ();

        process_view = new ProcessView ();
        system_view = new SystemView (resources);

        stack = new Gtk.Stack ();
        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
        stack.add_titled (process_view, "process_view", _("Processes"));
        stack.add_titled (system_view, "system_view", _("System"));

        Gtk.StackSwitcher stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.valign = Gtk.Align.CENTER;
        stack_switcher.set_stack (stack);

        headerbar = new Headerbar (this);
        headerbar.set_custom_title (stack_switcher);
        var sv = new PreferencesView ();
        headerbar.preferences_grid.add (sv);
        sv.show_all ();

        statusbar = new Statusbar ();

        var grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        grid.add (headerbar);
        grid.add (stack);
        grid.add (statusbar);

        add (grid);

        show_all ();

        dbusserver = DBusServer.get_default ();

        headerbar.search_revealer.set_reveal_child (stack.visible_child_name == "process_view");
        stack.notify["visible-child-name"].connect (() => {
            headerbar.search_revealer.set_reveal_child (stack.visible_child_name == "process_view");
        });

        new Thread<void> ("upd", () => {
            Timeout.add_seconds (MonitorApp.settings.get_int ("update-time"), () => {
                process_view.update ();

                Idle.add (() => {
                    system_view.update ();
                    dbusserver.indicator_state (MonitorApp.settings.get_boolean ("indicator-state"));
                    var res = resources.serialize ();
                    statusbar.update (res);
                    dbusserver.update (res);
                    return false;
                });
                return true;
            });
        });


        dbusserver.quit.connect (() => app.quit ());
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

            MonitorApp.settings.set_string ("opened-view", stack.visible_child_name);

            if (MonitorApp.settings.get_boolean ("indicator-state")) {
                this.hide_on_delete ();
            } else {
                dbusserver.indicator_state (false);
                app.quit ();
            }

            return true;
        });

        dbusserver.indicator_state (MonitorApp.settings.get_boolean ("indicator-state"));
        stack.visible_child_name = MonitorApp.settings.get_string ("opened-view");
    }

    private void setup_window_state () {
        int window_width = MonitorApp.settings.get_int ("window-width");
        int window_height = MonitorApp.settings.get_int ("window-height");
        this.set_default_size (window_width, window_height);

        if (MonitorApp.settings.get_boolean ("is-maximized")) {
            this.maximize ();
        }

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
