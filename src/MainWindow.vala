/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.MainWindow : Hdy.ApplicationWindow {
    public ProcessView process_view { get; private set; }

    public MainWindow (MonitorApp app) {
        Object (application: app);
    }

    construct {
        setup_window_state ();

        title = _("Monitor");

        var resources = new Resources ();

        process_view = new ProcessView ();
        var system_view = new SystemView (resources);

        var stack = new Gtk.Stack () {
            transition_type = SLIDE_LEFT_RIGHT
        };
        stack.add_titled (process_view, "process_view", _("Processes"));
        stack.add_titled (system_view, "system_view", _("System"));

        var stack_switcher = new Gtk.StackSwitcher () {
            stack = stack,
            valign = CENTER
        };

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

        var search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search process name or PID"),
            valign = CENTER
        };

        var search_revealer = new Gtk.Revealer () {
            child = search_entry,
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

        var statusbar = new Statusbar ();

        var box = new Gtk.Box (VERTICAL, 0);
        box.add (headerbar);
        box.add (stack);
        box.add (statusbar);

        child = box;

        show_all ();

        var dbusserver = DBusServer.get_default ();

        search_revealer.reveal_child = stack.visible_child == process_view;
        stack.notify["visible-child"].connect (() => {
            search_revealer.reveal_child = stack.visible_child == process_view;
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


        dbusserver.quit.connect (() => application.quit ());
        dbusserver.show.connect (() => {
            this.deiconify ();
            this.present ();
            setup_window_state ();
            this.show_all ();
        });

        key_press_event.connect (search_entry.handle_event);

        this.delete_event.connect (() => {
            int window_width, window_height;
            get_size (out window_width, out window_height);
            MonitorApp.settings.set_int ("window-width", window_width);
            MonitorApp.settings.set_int ("window-height", window_height);
            MonitorApp.settings.set_boolean ("is-maximized", this.is_maximized);


            if (MonitorApp.settings.get_boolean ("indicator-state")) {
                this.hide_on_delete ();
            } else {
                dbusserver.indicator_state (false);
                application.quit ();
            }

            return true;
        });

        dbusserver.indicator_state (MonitorApp.settings.get_boolean ("indicator-state"));

        MonitorApp.settings.bind ("opened-view", stack, "visible-child-name", DEFAULT);

        search_entry.search_changed.connect (() => {
            // collapse tree only when search is focused and changed
            if (search_entry.is_focus) {
                process_view.process_tree_view.collapse_all ();
            }

            process_view.needle = search_entry.text;

            // focus on child row to avoid the app crashes by clicking "Kill/End Process" buttons in headerbar
            process_view.process_tree_view.focus_on_child_row ();
            search_entry.grab_focus ();

            if (search_entry.text != "") {
                search_entry.insert_at_cursor ("");
            }
        });

        search_entry.activate.connect (() => {
            process_view.process_tree_view.focus_on_first_row ();
        });

        var search_action = new GLib.SimpleAction ("search", null);
        search_action.activate.connect (() => {
            search_entry.text = "";
            search_entry.search_changed ();
        });

        add_action (search_action);
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
