/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.MainWindow : Hdy.ApplicationWindow {
    public ProcessView process_view { get; private set; }

    private Gtk.SearchEntry search_entry;

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

        search_entry = new Gtk.SearchEntry () {
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

            MonitorApp.settings.set_string ("opened-view", stack.visible_child_name);

            if (MonitorApp.settings.get_boolean ("indicator-state")) {
                this.hide_on_delete ();
            } else {
                dbusserver.indicator_state (false);
                application.quit ();
            }

            return true;
        });

        dbusserver.indicator_state (MonitorApp.settings.get_boolean ("indicator-state"));
        stack.visible_child_name = MonitorApp.settings.get_string ("opened-view");

        var filter_model = new Gtk.TreeModelFilter (process_view.treeview_model, null);
        filter_model.set_visible_func (filter_func);

        var sort_model = new Gtk.TreeModelSort.with_model (filter_model);

        process_view.process_tree_view.set_model (sort_model);

        search_entry.search_changed.connect (() => {
            // collapse tree only when search is focused and changed
            if (search_entry.is_focus) {
                process_view.process_tree_view.collapse_all ();
            }

            filter_model.refilter ();

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

    private bool filter_func (Gtk.TreeModel model, Gtk.TreeIter iter) {
        string name_haystack;
        int pid_haystack;
        string cmd_haystack;
        bool found = false;
        var needle = search_entry.text;

        // should help with assertion errors, donno
        // if (needle == null) return true;

        if (needle.length == 0) {
            return true;
        }

        model.get (iter, Column.NAME, out name_haystack, -1);
        model.get (iter, Column.PID, out pid_haystack, -1);
        model.get (iter, Column.CMD, out cmd_haystack, -1);

        // sometimes name_haystack is null
        if (name_haystack != null) {
            bool name_found = name_haystack.casefold ().contains (needle.casefold ()) || false;
            bool pid_found = pid_haystack.to_string ().casefold ().contains (needle.casefold ()) || false;
            bool cmd_found = cmd_haystack.casefold ().contains (needle.casefold ()) || false;
            found = name_found || pid_found || cmd_found;
        }


        Gtk.TreeIter child_iter;
        bool child_found = false;

        if (model.iter_children (out child_iter, iter)) {
            do {
                child_found = filter_func (model, child_iter);
            } while (model.iter_next (ref child_iter) && !child_found);
        }

        if (child_found && needle.length > 0) {
            process_view.process_tree_view.expand_all ();
        }

        return found || child_found;
    }
}
