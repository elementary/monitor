/*
 * SPDX-License-Identifier: LGPL-3.0-or-later
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

        if (typed.isalnum () && !window.headerbar.search.is_focus) {
            window.headerbar.search.activate_entry (e.str);
            handled = true;
        }

        if ((e.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
            switch (e.keyval) {
            case Gdk.Key.f:
                window.headerbar.search.activate_entry ();
                handled = true;
                break;
            case Gdk.Key.e:
                window.process_view.process_tree_view.end_process ();
                handled = true;
                break;
            case Gdk.Key.k:
                window.process_view.process_tree_view.kill_process ();
                handled = true;
                break;
            case Gdk.Key.comma:
                handled = true;
                break;
            case Gdk.Key.period:
                handled = true;
                break;
            default:
                break;
            }
        }

        switch (e.keyval) {
        case Gdk.Key.Return:
            window.process_view.process_tree_view.focus_on_first_row ();
            handled = true;
            break;
        case Gdk.Key.Left:
            window.process_view.process_tree_view.collapse ();
            handled = true;
            break;
        case Gdk.Key.Right:
            window.process_view.process_tree_view.expanded ();
            handled = true;
            break;
        default:
            break;
        }

        return handled;
    }

}
