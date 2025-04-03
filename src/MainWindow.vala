/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.MainWindow : Hdy.ApplicationWindow {
    // application reference
    private Shortcuts shortcuts;

    private Resources resources;

    // Widgets
    public Search search { get; private set; }

    public ProcessView process_view;
    public SystemView system_view;
    private Gtk.Stack stack;

    private Statusbar statusbar;

    public DBusServer dbusserver;


    // Constructs a main window
    public MainWindow (MonitorApp app) {
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

        var sv = new PreferencesView ();
        sv.show_all ();

        var preferences_popover = new Gtk.Popover (null) {
            child = sv
        };

        var preferences_button = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR),
            popover = preferences_popover,
            tooltip_text = (_("Settings"))
        };

        search = new Search (this) {
            valign = CENTER
        };

        var search_revealer = new Gtk.Revealer () {
            child = search,
            transition_type = SLIDE_LEFT
        };

        var headerbar = new Hdy.HeaderBar () {
            has_subtitle = false,
            show_close_button = true,
            title = _("Monitor")
        };
        headerbar.pack_start (search_revealer);
        headerbar.set_custom_title (stack_switcher);
        headerbar.pack_end (preferences_button);

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

        search_revealer.set_reveal_child (stack.visible_child_name == "process_view");
        stack.notify["visible-child-name"].connect (() => {
            search_revealer.set_reveal_child (stack.visible_child_name == "process_view");
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
            int window_width, window_height;
            get_size (out window_width, out window_height);
            MonitorApp.settings.set_int ("window-width", window_width);
            MonitorApp.settings.set_int ("window-height", window_height);
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
    }

}
