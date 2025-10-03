/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.MainWindow : Gtk.ApplicationWindow {
    public ProcessView process_view { get; private set; }

    public MainWindow (MonitorApp app) {
        Object (application: app);
    }

    construct {
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

        var preferences_view = new PreferencesView ();

        var preferences_popover = new Gtk.Popover () {
            child = preferences_view
        };

        var preferences_button = new Gtk.MenuButton () {
            icon_name = "open-menu",
            primary = true,
            popover = preferences_popover,
            tooltip_markup = ("%s\n" + Granite.TOOLTIP_SECONDARY_TEXT_MARKUP).printf (
                _("Settings"),
                "F10"
            )
        };
        preferences_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search process name or PID"),
            valign = CENTER
        };
        search_entry.set_key_capture_widget (this);

        var search_revealer = new Gtk.Revealer () {
            child = search_entry,
            transition_type = SLIDE_LEFT,
            overflow = VISIBLE
        };

        var headerbar = new Adw.HeaderBar ();
        headerbar.pack_start (search_revealer);
        headerbar.set_title_widget (stack_switcher);
        headerbar.pack_end (preferences_button);

        var statusbar = new Statusbar ();

        var main_container = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        set_titlebar (headerbar);
        main_container.append (stack);
        main_container.append (statusbar);

        child = main_container;

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

        dbusserver.indicator_state (MonitorApp.settings.get_boolean ("indicator-state"));

        MonitorApp.settings.bind ("opened-view", stack, "visible-child-name", DEFAULT);

        search_entry.search_changed.connect (() => {
            // collapse tree only when search is focused and changed
            if (search_entry.is_focus ()) {
                process_view.process_tree_view.collapse_all ();
            }

            process_view.needle = search_entry.text;

            // focus on child row to avoid the app crashes by clicking "Kill/End Process" buttons in headerbar
            process_view.process_tree_view.focus_on_child_row ();
            search_entry.grab_focus ();
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
}
