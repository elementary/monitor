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

        close_request.connect (() => {
            if (MonitorApp.settings.get_boolean ("indicator-state")) {
                debug ("Indicator is enabled, hiding the window instead of closing");
                hide ();
                return Gdk.EVENT_STOP;
            }
            debug ("Close the window");
            return Gdk.EVENT_PROPAGATE;
        });


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

        var headerbar = new Gtk.HeaderBar () {
            title_widget = stack_switcher
        };
        headerbar.pack_start (search_revealer);
        headerbar.pack_end (preferences_button);

        var statusbar = new Statusbar ();

        var toolbox = new Adw.ToolbarView () {
            content = stack,
            top_bar_style = RAISED,
            bottom_bar_style = RAISED_BORDER
        };
        toolbox.add_top_bar (headerbar);
        toolbox.add_bottom_bar (statusbar);

        child = toolbox;
        titlebar = new Gtk.Grid () { visible = false };

        var dbusserver = DBusServer.get_default ();

        search_revealer.reveal_child = stack.visible_child == process_view;
        stack.notify["visible-child"].connect (() => {
            toolbox.reveal_bottom_bars = stack.visible_child == process_view;
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
            process_view.treeview_model.filtered.needle = search_entry.text;
            search_entry.grab_focus ();
        });

        var search_action = new GLib.SimpleAction ("search", null);
        search_action.activate.connect (() => {
            search_entry.text = "";
            search_entry.search_changed ();
        });

        add_action (search_action);
    }
}
