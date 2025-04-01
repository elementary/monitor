/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Monitor {
    public struct App {
        public string name;
        public string icon;
        public string ? desktop_file;
        public int[] pids;
        public uint32 xid;
    }
    /**
     * Wrapper for Bamf.Matcher
     */
    public class AppManager {
        public signal void application_opened (App app);
        public signal void application_closed (App app);

        static AppManager ? app_manager = null;
        private Bamf.Matcher ? matcher;
        private Gee.ArrayList<uint> transient_xids;

        public static AppManager get_default () {
            if (app_manager == null)
                app_manager = new AppManager ();
            return app_manager;
        }

        public AppManager () {
            transient_xids = new Gee.ArrayList<uint> ();

            matcher = Bamf.Matcher.get_default ();
            matcher.view_opened.connect_after (handle_view_opened);
            matcher.view_closed.connect_after (handle_view_closed);
        }

        ~AppManager () {
            matcher.view_opened.disconnect (handle_view_opened);
            matcher.view_closed.disconnect (handle_view_closed);
            matcher = null;
        }

        // Function retrieves a Bamf.view, checks if it's a window,
        // then extracts name, icon, desktop_file and pid. After that,
        // sends signal.

        private void handle_view_opened (Bamf.View view) {
            if (view is Bamf.Window && is_main_window (view)) {
                int[] win_pids = {};
                var window = (Bamf.Window)view;
                var app = matcher.get_application_for_window (window);
                win_pids += (int) window.get_pid ();
                if (has_desktop_file (app.get_desktop_file ())) {
                    debug ("Handle View Opened: %s", view.get_name ());
                    application_opened (
                        App () {
                        name = app.get_name (),
                        icon = app.get_icon (),
                        desktop_file = app.get_desktop_file (),
                        pids = win_pids,
                        xid = app.get_xids ().index (0)
                    });
                }
            }
        }

        private void handle_view_closed (Bamf.View view) {
            if (view is Bamf.Window && is_main_window (view)) {
                int[] win_pids = {};
                var window = (Bamf.Window)view;
                var app = matcher.get_application_for_window (window);
                win_pids += (int) window.get_pid ();
                if (has_desktop_file (app.get_desktop_file ())) {
                    debug ("Handle View Closed: %s", view.get_name ());
                    application_closed (
                        App () {
                        name = app.get_name (),
                        icon = app.get_icon (),
                        desktop_file = app.get_desktop_file (),
                        pids = win_pids,
                        xid = app.get_xids ().index (0)
                    });
                }
            }
        }

        private bool has_desktop_file (string ? desktop_file) {
            return !(desktop_file == null || desktop_file == "");
        }

        // Getting all apps with desktop_file and returning array of apps
        public App[] get_running_applications () {
            debug ("---Get Running Apps---");
            App[] apps = {};
            foreach (var bamf_app in matcher.get_running_applications ()) {
                int[] win_pids = {};
                // go through the windows of the application and add all of the pids
                var windows = bamf_app.get_windows ();
                foreach (var window in windows) {
                    win_pids += (int) window.get_pid ();
                }
                if (has_desktop_file (bamf_app.get_desktop_file ())) {
                    apps += App () {
                        name = bamf_app.get_name (),
                        icon = bamf_app.get_icon (),
                        desktop_file = bamf_app.get_desktop_file (),
                        pids = win_pids,
                        xid = bamf_app.get_xids ().index (0)
                    };
                }
            }
            return apps;
        }

        private bool is_main_window (Bamf.View view) {
            var window_type = ((Bamf.Window)view).get_window_type ();
            debug ("Window type: %d, Is transient: %d", window_type, (int) is_transient (view));
            return (window_type == Bamf.WindowType.NORMAL ||
                    window_type == Bamf.WindowType.DOCK) && !is_transient (view);
        }

        // if window is transient add its xid to array and return true
        private bool is_transient (Bamf.View view) {
            if (transient_xids.size > 0 && transient_xids.contains (((Bamf.Window)view).get_xid ())) {
                return true;
            }
            if (((Bamf.Window)view).get_transient () != null) {
                transient_xids.add (((Bamf.Window)view).get_xid ());
                return true;
            }
            return false;
        }

    }
}
