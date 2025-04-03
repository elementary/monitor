/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Shortcuts : Object {
    private MainWindow window;
    public bool handled;

    public Shortcuts (MainWindow window) {
        this.window = window;
    }

    public bool handle (Gdk.EventKey e) {
        handled = false;
        char typed = e.str[0];

        if (typed.isalnum () && !window.search.is_focus) {
            window.search.activate_entry (e.str);
            handled = true;
        }

        return handled;
    }

}
