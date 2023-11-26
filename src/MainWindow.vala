public class Monitor.MainWindow : Gtk.ApplicationWindow {
    // application reference
    private Shortcuts shortcuts;

    private Resources resources;

    public ProcessView process_view;
    public SystemView system_view;
    public ContainerView container_view;
    private Gtk.Stack stack;

    private Statusbar statusbar;

    public DBusServer dbusserver;


    // Constructs a main window
    public MainWindow (MonitorApp app) {
        //  Adw.init ();
        Granite.init ();

        this.set_application (app);

        setup_window_state ();

        title = _("Monitor");

        get_style_context ().add_class ("rounded");

        resources = new Resources ();

        process_view = new ProcessView ();
        system_view = new SystemView (resources);
        container_view = new ContainerView ();

        stack = new Gtk.Stack ();
        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
        stack.add_titled (process_view, "process_view", _("Processes"));
        stack.add_titled (system_view, "system_view", _("System"));

        if (MonitorApp.settings.get_boolean ("containers-view-state")) {
            stack.add_titled (container_view, "container_view", _("Containers"));
        }

        Gtk.StackSwitcher stack_switcher = new Gtk.StackSwitcher ();
        stack_switcher.valign = Gtk.Align.CENTER;
        stack_switcher.set_stack (stack);

        var headerbar = this.build_headerbar (stack_switcher);
        set_titlebar (headerbar);

        statusbar = new Statusbar ();

        var grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        grid.attach (stack, 0, 1, 1, 1);
        grid.attach (statusbar, 0, 2, 1, 1);

        set_child (grid);

        present ();

        dbusserver = DBusServer.get_default ();


        new Thread<void> ("upd", () => {
            Timeout.add_seconds (MonitorApp.settings.get_int ("update-time"), () => {
                process_view.update ();
                container_view.update ();


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
            this.present ();
            setup_window_state ();
            this.present ();
        });

        shortcuts = new Shortcuts (this);
        //  key_press_event.connect ((e) => shortcuts.handle (e));

        app.window_removed.connect (() => {
            int position_x, position_y;
            int window_width = get_size (Gtk.Orientation.HORIZONTAL);
            int window_height = get_size (Gtk.Orientation.VERTICAL);
            //  get_position (out position_x, out position_y);
            MonitorApp.settings.set_int ("window-width", window_width);
            MonitorApp.settings.set_int ("window-height", window_height);
            //  MonitorApp.settings.set_int ("position-x", position_x);
            //  MonitorApp.settings.set_int ("position-y", position_y);
            //  MonitorApp.settings.set_boolean ("is-maximized", this.is_maximized);

            MonitorApp.settings.set_string ("opened-view", stack.visible_child_name);

            if (MonitorApp.settings.get_boolean ("indicator-state")) {
                // Read: https://discourse.gnome.org/t/how-to-hide-widget-instead-removing-them-in-gtk-4/8176
                //  this.hide_on_delete ();

            } else {
                dbusserver.indicator_state (false);
                app.quit ();
            }

            //  return true;
        });

        dbusserver.indicator_state (MonitorApp.settings.get_boolean ("indicator-state"));
        stack.visible_child_name = MonitorApp.settings.get_string ("opened-view");
    }

    private Adw.HeaderBar build_headerbar (Gtk.Widget widget) {
        // The headerbar
        var headerbar = new Adw.HeaderBar ();
        headerbar.set_title_widget (widget);

        // Preferences button
        var preferences_button = new Gtk.MenuButton ();
        preferences_button.has_tooltip = true;
        preferences_button.tooltip_text = (_("Settings"));
        preferences_button.set_icon_name ("open-menu");
        headerbar.pack_end (preferences_button);

        var preferences_grid = new Gtk.Grid () {
            orientation = Gtk.Orientation.VERTICAL
        };

        var preferences_popover = new Gtk.Popover ();
        preferences_popover.set_child (preferences_grid);
        preferences_button.popover = preferences_popover;

        preferences_grid.attach (new PreferencesView (), 0, 0, 1, 1);

        // Search entry
        var search = new Search (process_view.process_tree_view) {
            valign = Gtk.Align.CENTER,
        };

        Gtk.Revealer search_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
        };
        search_revealer.set_child (search);
        headerbar.pack_start (search_revealer);

        search_revealer.set_reveal_child (stack.visible_child_name == "process_view");
        stack.notify["visible-child-name"].connect (() => {
            search_revealer.set_reveal_child (stack.visible_child_name == "process_view");
        });

        return headerbar;
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

        // Can't move window to a specific position in GTK4
        // Read: https://discourse.gnome.org/t/how-to-center-gtkwindows-in-gtk4/3112

        //  if (position_x == -1 || position_y == -1) {
        //      // -1 is default value of these keys, which means this is the first launch
        //      this.window_position = Gtk.WindowPosition.CENTER;
        //  } else {
        //      move (position_x, position_y);
        //  }
    }

}
